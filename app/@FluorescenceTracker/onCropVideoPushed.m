function onCropVideoPushed(app)

[~,fileName] = fileparts(app.Video.Name); % remove extension
tag = "_"+round(app.InitialTime.Value)+"s-"+round(app.FinalTime.Value)+"s";
fileName = fullfile(app.Video.Path,fileName+tag+".mp4");

[fileName,filePath] = uiputfile("*.mp4",[],fileName);
figure(app.UIFigure) % bring app to foreground
if isequal(fileName, 0)
    return % uiputfile cancelled by user
end
progress = uiprogressdlg(app.UIFigure, Title="Please Wait", ...
    Message="Cropping and Saving Video...");

% Setup video writer (use default FrameRate = 30, since app.Video.FrameRate 
% is the average frame rate for variable-frame rate video)
writer = VideoWriter(fullfile(filePath,fileName),"MPEG-4");
open(writer)

% Loop through video frames
app.Video.CurrentTime = app.InitialTime.Value;
tDuration = app.FinalTime.Value - app.InitialTime.Value;
while hasFrame(app.Video) && (app.Video.CurrentTime <= app.FinalTime.Value)
    progress.Value = (app.Video.CurrentTime - app.InitialTime.Value)/tDuration;
    frame = readFrame(app.Video);
    [cframeK,iframeK] = fta.cropFrame(frame);
    frame = vertcat(cframeK,repmat(iframeK,1,1,3));
    writeVideo(writer,frame)
end
close(writer)

% Load cropped video
app.Video = VideoReader(fullfile(filePath,fileName));
resetComponents(app)
app.CropVideo.Enable = "off";
close(progress)

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.