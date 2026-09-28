function onSmoothingValueChanged(app)

progress = uiprogressdlg(app.UIFigure, Title="Please Wait", ...
    Message="Plotting Intensity Curves...", Indeterminate="on");

% Compute smoothed group intensity and group intensity rate
app.Ismooth = smoothdata(app.Igroup,SmoothingFactor=app.SmoothingFactor.Value);
dt = diff(app.Angio.time);
app.dIdtGroup = diff(app.Ismooth,[],1)./dt;
app.dIdtGroup = smoothdata(app.dIdtGroup,SmoothingFactor=app.SmoothingFactor.Value);
t = app.Angio.time(1:end-1) + dt;

if (app.GridEnabled && (app.nGroups.Value == 0) ...
        && ~isempty(app.LabelTable.Data) ...
        && (size(app.Angio.region,1)==size(app.region,1)))
    grpID = unique(app.groupIds,"stable");
    lgnd  = unique(app.LabelTable.Data{:,3},"stable");
else
    grpID = unique(app.groupIds);
    lgnd  = "Group " + grpID;
end

% Tab 2: Time Histories
delete(app.hLines2)
set(app.IntensityHistories,ColorOrderIndex=1)
colororder(app.IntensityHistories,app.cmap(grpID,:))
app.hLines2 = plot(app.IntensityHistories,app.Angio.time,app.Ismooth,LineWidth=1.5);
app.hLegend2 = legend(app.hLines2,lgnd,Location="northwest");
if app.ToggleLegend.Value
    app.hLegend2.Visible = "on";
else
    app.hLegend2.Visible = "off";
end

% Tab 3: Time Histories
delete(app.hLines3)
set(app.IntensityRate,ColorOrderIndex=1)
colororder(app.IntensityRate,app.cmap(grpID,:))
app.hLines3 = plot(app.IntensityRate,t,app.dIdtGroup,LineWidth=1.5);
minRate = min(app.dIdtGroup,[],"all");
minRate = min(0,minRate - abs(minRate)/10);
maxRate = max(app.dIdtGroup,[],"all");
maxRate = maxRate + abs(maxRate)/10;
ylim(app.IntensityRate,[minRate maxRate])

close(progress)

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.