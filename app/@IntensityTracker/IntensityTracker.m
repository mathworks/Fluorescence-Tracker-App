classdef IntensityTracker < handle

% IntensityTracker Track intensity of points or regions in a video
%
% IntensityTracker objects analyze and track pixel intensities over time
% from a VideoReader source. Two tracking modes are supported:
%   - "point-based"  : track intensity at automatically detected or
%                      user-specified points using feature tracking.
%   - "region-based" : track mean intensity within rectangular regions.
%
% Creation:
%   obj = IntensityTracker(video) creates a tracker for the VideoReader
%   object 'video'. Optional name-value parameters may be supplied to the
%   constructor as a struct 'opts' (see constructor signature for details).
%
% Properties (selected):
%   Method       - Current tracking method ("point-based" or "region-based").
%   Video        - VideoReader object used as the source.
%   InitialTime  - Start time (seconds) for tracking.
%   FinalTime    - End time (seconds) for tracking.
%   PixelHood    - Pixel neighborhood radius used for point intensity.
%   Detector     - Feature detector used for point selection (text scalar).
%   AutoReInit   - If true, automatically re-initialize lost points.
%   cframe1,cframe,iframe,iframe - current/previous color and intensity frames.
%   region1,region - region definitions [x y w h] for previous/current frame.
%   points1,points - point coordinates for previous/current frame.
%   Ipoints      - Intensity time series for tracked points (nFrames x nPoints).
%   Iregion      - Intensity time series for tracked regions (nFrames x nRegions).
%
% Methods:
%   track(obj, method, arg2, arg3) - Start tracking using specified method.
%       For "point-based":
%           arg2 = roi or gridSize (to determine initial point selection)
%           arg3 = points (nx2) to use (optional) or maxPoints (scalar)
%       For "region-based":
%           arg2 = regions (m x 4) or roi
%           arg3 = regionIds (optional)
%
% Example:
%   vr = VideoReader("myVideo.mp4");
%   t = IntensityTracker(vr);
%   t.InitialTime = 0;
%   t.FinalTime = 10;
%   t.track("region-based", regions);
%
% See also VideoReader, vision.PointTracker

    properties (SetAccess=private)
        Method {mustBeTextScalar} = ""
        Video (1,1) % validated by constructor
        cframe1 (:,:,:) {mustBeNumeric}
        cframe (:,:,:) {mustBeNumeric}
        iframe (:,:) {mustBeNumeric}
        region1 (:,4) {mustBeNumeric}   % nRegions x 4 [x y w h]
        region (:,4) {mustBeNumeric}    % nRegions x 4 [x y w h]
        pointIds (:,1) {mustBeNumeric}  % nPoints x 1
        points1 (:,2) {mustBeNumeric}   % nPoints x 2 [x y]
        points (:,2) {mustBeNumeric}    % nPoints x 2 [x y]
        time (:,1) {mustBeNumeric}      % nFrames x 1
        Ipoints (:,:) {mustBeNumeric}   % nFrames x nPoints
        Iregion (:,:) {mustBeNumeric}   % nFrames x nRegions
    end
    
    properties
        InitialTime (1,1) {mustBeNumeric,mustBeNonnegative}
        FinalTime (1,1) {mustBeNumeric,mustBeNonnegative}
        PixelHood (1,1) {mustBeInteger,mustBeNonnegative,mustBeNumeric} = 5
        Detector {mustBeTextScalar,mustBeMember(Detector,["detectMinEigenFeatures", ...
            "detectBRISKFeatures","detectFASTFeatures","detectHarrisFeatures", ...
            "detectKAZEFeatures","detectSURFFeatures"])} = "detectMinEigenFeatures"
        DisplayMode {mustBeScalarOrEmpty,mustBeTypeOrEmpty(DisplayMode, ...
            ["uiFigure","vision.DeployableVideoPlayer","matlab.ui.dialog.ProgressDialog"])}
        VideoWriter {mustBeTypeOrEmpty(VideoWriter,"VideoWriter")}
        AutoReInit (1,1) logical = false % only used if "point-based"
    end

    methods

        function obj = IntensityTracker(video,opts)
            arguments
                video VideoReader % can be filename
                opts.InitialTime = video.CurrentTime
                opts.FinalTime = video.Duration
                opts.VideoWriter
                opts.DisplayMode
                opts.Detector
                opts.PixelHood
                opts.AutoReInit
            end

            if (nargin==1)
                if (opts.FinalTime <= opts.InitialTime) || (opts.FinalTime > video.Duration)
                    eid = "IntensityTracker:InputTimeInvalid";
                    msg = "Video FinalTime must be > InitialTime and <= Video.Duration.";
                    throw(MException(eid,msg))
                end

                obj.Video = video;
                frame = readFrame(video);
                [obj.cframe,obj.iframe] = fta.cropFrame(frame);
                props = string(fieldnames(opts));
                for k = 1:numel(props)
                    obj.(props(k)) = opts.(props(k));
                end
            end
        end

        function track(obj,method,arg2,arg3)
            arguments
                obj (1,1) IntensityTracker
                method {mustBeMember(method,["point-based" "region-based"])}
                arg2 % region (mx4) or roi (mx4) or gridSize (1x2)
                arg3 % points (nx2) or rid (nx1) or maxPoints (1x1)
            end
            initialize(obj,method,arg2,arg3)

            if (obj.Method == "point-based")
                trackPoints(obj)
            elseif (obj.Method == "region-based")
                trackRegions(obj)
            end
        end
    end

    methods (Access=private)
        initialize(obj,method,arg2,arg3)
        trackPoints(obj)
        trackRegions(obj)
    end

    methods (Access=private,Static=true)
        [progress,player] = parseDisplay(DisplayMode)
    end    
end

%% Custom Validation Function
function mustBeTypeOrEmpty(value,type)
cval = class(value);
if (cval=="matlab.ui.Figure") && matlab.ui.internal.isUIFigure(value)
    cval = "uiFigure";
end
if ~ismember(cval,type) && ~isempty(value)
    eid = "IntensityTracker:InputTypeInvalid";
    msg = "Value must be " + join(type," or ") + " or empty.";
    throwAsCaller(MException(eid,msg))
end
end

% Copyright 2023 The MathWorks, Inc.