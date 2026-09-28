function onAutoGridRegionsPushed(app)

progress = uiprogressdlg(app.UIFigure, Title="Please Wait", ...
    Message="Creating Region Grid...", Indeterminate="on");

% Extract and confirm grid parameters
[~,i] = min(abs(app.gridRows-app.AutoGridHeight.Value));
[~,j] = min(abs(app.gridCols-app.AutoGridWidth.Value));
app.nRows = app.gridRows(i);
app.nCols = app.gridCols(j);

if (app.nRows ~= app.AutoGridHeight.Value) || (app.nCols ~= app.AutoGridWidth.Value)
    msg = ["Adjust grid size as follows to be more compatible with frame size?"; ...
        "";"Grid Height: "+app.nRows;"Grid Width: "+app.nCols];
    selection = uiconfirm(app.UIFigure,msg, ...
        "Confirm Auto-Grid Size",Options=["Yes" "No"]);
    if (selection == "Yes")
        app.AutoGridHeight.Value = app.nRows;
        app.AutoGridWidth.Value  = app.nCols;
    else
        app.nRows = app.AutoGridHeight.Value;
        app.nCols = app.AutoGridWidth.Value;
    end
end

[roi,pts,nPts] = fta.initRegions(app.cframe,[app.nRows app.nCols], ...
    app.MaxPoints.Value, Detector=app.DetectionAlgorithm.Value);
if (size(pts,1) < 3)
    msg = ["Less than 3 points were detected in the initial frame."; ""; ...
        "Please select a different detection algorithm or initial time."];
    uialert(app.UIFigure,msg,"Insufficient Points",Icon="warning");
    return
end
app.region = roi;
app.points = pts;
app.nPoints = nPts;

% Tab 4: Labeled Frame
cmarked = insertShape(app.cframe,"rectangle",app.region,Color="white");
imshow(cmarked,Parent=app.LabeledFrame,Border="tight");
axis(app.LabeledFrame,"image")
app.LabelTable.Data = table([],[],[]);
app.gridIds = {}; app.gridLabels = {};

% Tab 1: Initial Frame
cmarked = insertMarker(cmarked,app.points,"+",Color="white");
imshow(cmarked,Parent=app.InitialFrame,Border="tight");
axis(app.InitialFrame,"image")

app.SelectRegion.Enable = "off";
app.ClearRegion.Enable = "on";
app.PlayButton.Enable = "on";
app.AutoReInit.Enable = "off";
app.AutoReInit.Value = false;
app.LabelRegion.Enable = "on";
app.RefreshPlots.Enable = "on";
app.GridEnabled = true;
close(progress)

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.