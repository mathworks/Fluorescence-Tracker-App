function onFinalTimeChanged(app)

app.Video.CurrentTime = app.FinalTime.Value;
if hasFrame(app.Video)
    frame = readFrame(app.Video);
else
    app.Video.CurrentTime = app.Video.CurrentTime - (1/app.Video.FrameRate);
    frame = readFrame(app.Video);
    app.FinalTime.Limits(end) = app.Video.CurrentTime;
    app.FinalTime.Value = app.FinalTime.Limits(end);
end

[cframeN,iframeN] = fta.cropFrame(frame);
frame = vertcat(cframeN,repmat(iframeN,1,1,3));
imshow(frame,Parent=app.FinalFrame,Border="tight");
axis(app.FinalFrame,"image")

app.InitialTime.Limits = [0 app.FinalTime.Value];
if (app.FinalTime.Value >= app.FinalTime.Limits(1)+1/app.Video.FrameRate)
    app.BackFrame2.Enable = "on";
else
    app.BackFrame2.Enable = "off";
end

if (app.FinalTime.Value <= app.FinalTime.Limits(2)-1/app.Video.FrameRate)
    app.NextFrame2.Enable = "on";
else
    app.NextFrame2.Enable = "off";
end

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.