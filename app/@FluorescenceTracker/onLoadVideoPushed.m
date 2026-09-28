function onLoadVideoPushed(app)

if isempty(app.Video)
    app.Video.Path = [];
end

[fileName,filePath] = uigetfile("*.mp4;*.avi","Select Video to Load",app.Video.Path);
figure(app.UIFigure) % bring app to foreground
if ~ischar(fileName)
    return % uigetfile cancelled by user
end
progress = uiprogressdlg(app.UIFigure, Title="Please Wait", ...
    Message="Loading Video...", Indeterminate="on");

% Validate video aspect ratio
temp = VideoReader(fullfile(filePath,fileName));
h = temp.Height;
w = temp.Width;
aspectRatio = h/w;
if (aspectRatio == 9/16)
    w = w/4;
    h = h/3;
    app.CropVideo.Enable = "on";

elseif (aspectRatio == 6/4)
    h = h/2;
    app.CropVideo.Enable = "off";

else
    close(progress)
    msg = ["Video file must have a width:height aspect ratio of 16:9 before cropping or 4:6 after cropping out inset thumbnails."; ...
        ""; "Before cropping, the video must contain three inset 4:3 thumbnails stacked along the left as follows:"; ...
        "   * visible light image (top)"; "   * infrared image (middle)"; "   * false colour composite image (bottom)"];
    uialert(app.UIFigure,msg,"Invalid Video File");
    return
end
app.Video = temp; % check A/R before over-writing app.Video

% Setup frame parameters
app.FrameSize.Text = "Frame Size:  " + h + " x " + w;
app.AutoGridHeight.Limits = [1, floor(h/10)];
app.AutoGridWidth.Limits  = [1, floor(w/10)];
hgts = 1:floor(h/10); % all possible heights
wths = 1:floor(w/10); % all possible widths
app.gridRows = hgts(rem(h,hgts)==0); % find integer divisors
app.gridCols = wths(rem(w,wths)==0); % find integer divisors
if ~ismember(app.AutoGridHeight.Value,app.gridRows) || ...
        ~ismember(app.AutoGridWidth.Value,app.gridCols)
    [~,i] = min(abs(app.gridRows-(h/30)));
    [~,j] = min(abs(app.gridCols-(w/30)));
    app.AutoGridHeight.Value = app.gridRows(i);
    app.AutoGridWidth.Value  = app.gridCols(j);
end
resetComponents(app)
close(progress)

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.