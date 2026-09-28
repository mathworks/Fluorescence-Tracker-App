function initialize(obj,method,arg2,arg3)

% Initialize and validate points and regions.
%               Option 1    |    Option 2     |     Option 3
% method   =    <either>    |  "point-based"  |  "region-based"
% arg2     =  region (mx4)  |    roi (mx4)    |  gridSize (1x2)
% arg3     =  points (nx2)  |    rid (nx1)    |  maxPoints (1x1)
% functions:      none      |  fta.initPoints |  fta.initRegions

% Ensure valid video times (in case changed by user)
if (obj.FinalTime <= obj.InitialTime) || (obj.FinalTime > obj.Video.Duration)
    eid = "IntensityTracker:InputTimeInvalid";
    msg = "Video FinalTime must be > InitialTime and <= Video.Duration.";
    throwAsCaller(MException(eid,msg))
end

% Ensure video is reset (in case already played)
obj.Video.CurrentTime = obj.InitialTime;
frame = readFrame(obj.Video);
[obj.cframe,obj.iframe] = fta.cropFrame(frame);
obj.cframe1 = obj.cframe;

% Parse inputs
if (size(arg2,2)==4) && (size(arg3,2)==2) % Option 1
    region = arg2;
    points = arg3;

elseif (method == "point-based") % Option 2
    region = arg2;
    points = fta.initPoints(obj.cframe1, ...
        arg2, arg3, Detector=obj.Detector);

elseif (method == "region-based") % Option 3
    [region,points] = fta.initRegions(obj.cframe1, ...
        arg2, arg3, Detector=obj.Detector);
end

% Validate all regions are in color frame
[h,w] = size(obj.cframe1,1:2);
xf = 0.5+[0;w;w;0;0]; % Intrinsic Coordinates
yf = 0.5+[0;0;h;h;0]; % Intrinsic Coordinates
xr = [region(:,1); region(:,1)+region(:,3)];
yr = [region(:,2); region(:,2)+region(:,4)];
in = inpolygon(xr,yr,xf,yf);
if any(~in)
    eid = "IntensityTracker:regionsNotInFrame";
    msg = "All regions must be fully contained in color frame.";
    throwAsCaller(MException(eid,msg))
end

% Validate all points are in color frame
in = inpolygon(points(:,1),points(:,2),xf,yf);
if any(~in)
    eid = "IntensityTracker:pointsNotInFrame";
    msg = "All points must be contained in color frame.";
    throwAsCaller(MException(eid,msg))
end

% Extract region IDs for each point
nReg = size(region,1);       % number of regions with points
rnum = (1:nReg)';            % region numbers
rid = NaN(size(points,1),1); % region IDs for each point
for j = 1:nReg
    xr = region(j,1) + region(j,3)*[0;1;1;0;0];
    yr = region(j,2) + region(j,4)*[0;0;1;1;0];
    in = inpolygon(points(:,1),points(:,2),xr,yr);
    rid(in) = rnum(j);
end

% Validate all points are in a region (point-based only)
if (method == "point-based")
    if any(isnan(rid))
        eid = "IntensityTracker:pointsNotInRegion";
        msg = "All points must be contained in a region.";
        throwAsCaller(MException(eid,msg))
    end
    obj.region1 = region; % does not change for region-based
end

% Accept region and point values
obj.Method   = method;
obj.region   = region;
obj.points   = points;
obj.points1  = points;
obj.pointIds = rid;

% Initialize intensity values at tracking points
tDuration = obj.FinalTime - obj.InitialTime;
nFrames = ceil(tDuration*ceil(obj.Video.FrameRate));
nPts = size(obj.points,1);
obj.time = NaN(nFrames,1);
obj.time(1) = obj.InitialTime;
obj.Ipoints = NaN(nFrames,nPts);
obj.Ipoints(1,:) = fta.imhoodstat(obj.iframe,obj.points1,obj.PixelHood,@mean);

end

% Copyright 2023 The MathWorks, Inc.