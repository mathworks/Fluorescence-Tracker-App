function onSelectRegionPushed(app)

if isempty(app.points)
    cmarked = app.cframe;
else
    cmarked = app.InitialFrame.Children.CData;
end
[h,w] = size(cmarked,1:2);    % [numrows numcols]

progress = uiprogressdlg(app.UIFigure, ...
    Title="Waiting for User Selection", Indeterminate="on", ...
    Message=["Please select desired region in figure window."; ...
    "Or close figure window to cancel selection."]);
figure(Position=[app.UIFigure.Position(1:2) w h], NumberTitle="off", ...
    Name="Select Region (double-click in rectangle to accept)")
[~,cropBox] = imcrop(cmarked);
if isempty(cropBox)
    return
end
close(gcf)
close(progress)

% Find initial points to be tracked in region(s) of interest
if (app.AutoReInit.Value && isfinite(app.MaxPoints.Value))
    rid = ones(app.MaxPoints.Value,1);
    pts = fta.initPoints(app.cframe,cropBox,rid, ...
        Detector=app.DetectionAlgorithm.Value);
else
    pts = feval(app.DetectionAlgorithm.Value,im2gray(app.cframe),ROI=cropBox);
    if (pts.Count > app.MaxPoints.Value)
        pts = selectStrongest(pts,app.MaxPoints.Value);
    end
    pts = pts.Location;
end

if isempty(pts)
    msg = ["No points were detected in the selected region."; ""; ...
        "Please select a different region or detection algorithm."];
    uialert(app.UIFigure,msg,"No Points Found",Icon="warning");
else
    app.region  = [app.region; cropBox];
    app.points  = [app.points; pts];
    app.nPoints = [app.nPoints; size(pts,1)];
    cmarked = insertShape(cmarked,"rectangle",cropBox,Color="white");
    cmarked = insertMarker(cmarked,pts,"+",Color="white");
    imshow(cmarked,Parent=app.InitialFrame,Border="tight");
    axis(app.InitialFrame,"image")
end

if ~isempty(app.points)
    app.ClearRegion.Enable = "on";
    app.PlayButton.Enable = "on";
    app.AutoGridRegions.Enable = "off";
end
cla(app.LabeledFrame)
app.LabelTable.Data = table([],[],[]);
app.gridIds = {}; app.gridLabels = {};

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.