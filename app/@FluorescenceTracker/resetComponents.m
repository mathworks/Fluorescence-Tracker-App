function resetComponents(app)

% Display first and last frame
app.InitialTime.Limits = [0 app.Video.Duration];
app.FinalTime.Limits = [0 app.Video.Duration];
app.InitialTime.Value = app.InitialTime.Limits(1);
app.FinalTime.Value = app.FinalTime.Limits(end);
InitialTimeChanged(app)
FinalTimeChanged(app)

% Display video file name
videoName = fullfile( app.Video.Path, app.Video.Name );
app.UIFigure.Name = "Fluorescence Tracker - " + videoName;

% Enable/disable components
app.SelectRegion.Enable = "on";
app.AutoGridRegions.Enable = "on";
app.ClearRegion.Enable = "off";
app.PlayButton.Enable = "off";
app.SaveButton.Enable = "off";
app.ToggleLegend.Enable = "off";
app.SmoothingFactor.Enable = "off";
app.nGroups.Enable = "off";
app.InitialTime.Enable = "on";
app.FinalTime.Enable = "on";
app.LabelRegion.Enable = "off";
app.ClearLabel.Enable = "off";
app.RefreshPlots.Enable = "off";
app.SaveLabels.Enable = "off";

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.