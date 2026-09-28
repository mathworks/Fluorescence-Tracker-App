function onInitialTimeChanged(app)

app.Video.CurrentTime = app.InitialTime.Value;
frame = readFrame(app.Video);
[app.cframe,iframe] = fta.cropFrame(frame);
frame = vertcat(app.cframe,repmat(iframe,1,1,3));
imshow(frame,Parent=app.InitialFrame,Border="tight");
axis(app.InitialFrame,"image")

app.FinalTime.Limits = [app.InitialTime.Value app.Video.Duration];
if (app.InitialTime.Value >= app.InitialTime.Limits(1)+1/app.Video.FrameRate)
    app.BackFrame1.Enable = "on";
else
    app.BackFrame1.Enable = "off";
end
if (app.InitialTime.Value <= app.InitialTime.Limits(2)-1/app.Video.FrameRate)
    app.NextFrame1.Enable = "on";
else
    app.NextFrame1.Enable = "off";
end

% Clear out all initial points and grids
app.region = [];
app.points = [];
app.nPoints = [];
cla(app.LabeledFrame)
app.LabelTable.Data = table([],[],[]);
app.gridIds = {}; app.gridLabels = {};

% Disable components
app.ClearRegion.Enable = "off";
app.PlayButton.Enable = "off";
app.LabelRegion.Enable = "off";
app.ClearLabel.Enable = "off";
app.RefreshPlots.Enable = "off";
app.SaveLabels.Enable = "off";

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.