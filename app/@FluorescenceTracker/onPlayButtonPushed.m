function onPlayButtonPushed(app)

nGrp = [sum(app.nPoints) numel(app.nPoints)];
if any(nGrp > 500)
    groups = ["points" "regions"];
    groups = groups(app.GridEnabled+1);
    nGrp = nGrp(app.GridEnabled+1);
    msg = [nGrp+" "+groups+" have been selected for tracking. " + ...
        "Post-processing time histories for more than 500 "+groups+" could " + ...
        "take a moment and/or cause the app to become unresponsive."; ...
        ""; "Press 'Cancel' to reduce the number of "+groups+"."];
    selection = uiconfirm(app.UIFigure,msg,"Confirm Excessive Groups", ...
        Icon="warning",Options=["Proceed" "Cancel"],DefaultOption=2);
    if (selection == "Cancel")
        return
    end
end

msg = "Press 'Save' to write tracked video or " ...
    + "Press 'Cancel' to process without saving";
[~,fileName] = fileparts(app.Video.Name); % remove extension
fileName = fullfile(app.Video.Path,"Tracked_"+fileName+".mp4");
[fileName,filePath] = uiputfile("*.mp4",msg,fileName);
figure(app.UIFigure) % bring app to foreground
if isequal(fileName, 0)
    writer = []; % uiputfile cancelled by user
else
    writer = VideoWriter(fullfile(filePath,fileName),"MPEG-4");
end

% Display regions with color coded points
nReg = numel(app.nPoints); % number of regions with points
rnum = (1:nReg)';          % region numbers
rid = repelem(rnum,app.nPoints,1); % region IDs for each point
if (nReg > 7)
    ptmap = turbo(nReg);
else
    ptmap = lines(nReg);
end

% Tab 1: Initial Frame
cmarked = insertShape(app.cframe,"rectangle",app.region,Color="white");
cmarked = insertMarker(cmarked,app.points,"+",Color=255*ptmap(rid,:));
j = all(app.region(:,3:4)>=30,2);
if any(j) % display region numbers, if region size permits
    cmarked = insertText(cmarked,app.region(j,1:2)+app.region(j,3:4)/2, ...
        rnum(j), BoxOpacity=0, TextColor="white", AnchorPoint="center");
end
imshow(cmarked, Parent=app.InitialFrame, Border="tight");
axis(app.InitialFrame,"image")

% Track point/region intensities
app.Angio = IntensityTracker(app.Video, ...
    InitialTime=app.InitialTime.Value, ...
    FinalTime=app.FinalTime.Value, ...
    DisplayMode=app.UIFigure, ...
    VideoWriter=writer, ...
    Detector=app.DetectionAlgorithm.Value, ...
    PixelHood=app.PixelNeighbors.Value, ...
    AutoReInit=app.AutoReInit.Value);

if app.GridEnabled
    method = "region-based";
else
    method = "point-based";
end
track(app.Angio,method,app.region,app.points)

if isscalar(app.Angio.time)
    ClearRegionPushed(app)
    app.ToggleLegend.Enable = "off";
    app.nGroups.Enable = "off";
    app.SmoothingFactor.Enable = "off";
    return
end

progress = uiprogressdlg(app.UIFigure, Title="Please Wait", ...
    Message="Updating Figures...", Indeterminate="on");

pval = all(~isnan(app.Angio.Ipoints));
if app.GridEnabled
    rval = ~any(isnan(app.Angio.Iregion),1)';
    maxGroups = nnz(rval);
else
    rval = ismember(rnum,rid(pval));
    maxGroups = nnz(pval);
end

% Tab 1: Final Frame
roi = app.Angio.region;
cmarked = insertMarker(app.Angio.cframe, app.Angio.points(pval,:), ...
    "+", Color=255*ptmap(rid(pval),:));
cmarked = insertShape(cmarked,"rectangle",roi(rval,:), Color="white");
j = (rval & all(roi(:,3:4)>=30,2));
if any(j) % display region numbers, if possible
    cmarked = insertText(cmarked,roi(j,1:2)+roi(j,3:4)/2, rnum(j), ...
        BoxOpacity=0, TextColor="white", AnchorPoint="center");
end
imshow(cmarked, Parent=app.FinalFrame, Border="tight");
axis(app.FinalFrame,"image")

% Tab 2: Time Histories
hold(app.IntensityHistories,"off")
plot(app.IntensityHistories,app.Angio.time,app.Angio.Ipoints, Color=0.8*[1 1 1]);
hold(app.IntensityHistories,"on")

% Tab 3: Time Histories
Ismo = smoothdata(app.Angio.Ipoints, SmoothingFactor=0.1);
dt = diff(app.Angio.time);
dIdt = diff(Ismo,[],1)./dt;
t = app.Angio.time(1:end-1) + dt;
hold(app.IntensityRate,"off")
plot(app.IntensityRate,t,dIdt, Color=0.8*[1 1 1])
hold(app.IntensityRate,"on")

% Group intensities before smoothing
app.nGroups.Limits = [0 maxGroups];
if (maxGroups > 500)
    app.nGroups.Value = 2;
else
    app.nGroups.Value = 0; % default to selected regions
end
if (maxGroups <= 1)
    app.nGroups.Enable = "off";
else
    app.nGroups.Enable = "on";
end

% Refresh remaining plots and switch tabs
close(progress)
nGroupsValueChanged(app) % also calls SmoothingFactorValueChanged
app.TabGroup.SelectedTab = app.IntensityTab;

% Disable/enable components
app.CropVideo.Enable = "off";
app.SelectRegion.Enable = "off";
app.AutoGridRegions.Enable = "off";
app.InitialTime.Enable = "off";
app.FinalTime.Enable = "off";
app.BackFrame1.Enable = "off";
app.BackFrame2.Enable = "off";
app.NextFrame1.Enable = "off";
app.NextFrame2.Enable = "off";
app.ToggleLegend.Enable = "on";
app.SmoothingFactor.Enable = "on";
app.SaveButton.Enable = "on";
if app.GridEnabled
    app.RefreshPlots.Enable = "on";
end

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.