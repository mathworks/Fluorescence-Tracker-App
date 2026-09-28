function [progress,player] = parseDisplay(DisplayMode)

% Setup progress bar, if needed
if isa(DisplayMode,"matlab.ui.Figure")
    progress = uiprogressdlg(DisplayMode, Title="Please Wait", ...
        Message="Processing Video...");

elseif isa(DisplayMode,"matlab.ui.dialog.ProgressDialog")
    progress = DisplayMode;

else
    progress = struct;
end
progress.Value = 0;

% Configure video player, if needed
if isa(DisplayMode,"matlab.ui.Figure")
    scale = 1.5; % monitor scaling
    monPos = get(groot,"MonitorPositions");
    figPos = scale*DisplayMode.Position;
    figPos(2) = (1-scale)*monPos(1,4) + figPos(2);
    try
        player = vision.DeployableVideoPlayer(Location=round(figPos(1:2)), ...
            Name="Close Player for Option to Stop Processing", ...
            Size="Custom", CustomSize=round([1 3/4]*figPos(3)/2));
    catch
        % vision.DeployableVideoPlayer "functionality is not 
        % available on remote platforms" (MATLAB Online)
        player = [];
    end

elseif isa(DisplayMode,"vision.DeployableVideoPlayer")
    player = DisplayMode;

else
    player = [];
end

end

% Copyright 2023 The MathWorks, Inc.