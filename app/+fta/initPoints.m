function points = initPoints(cframe,roi,rid,opts)

arguments
    cframe (:,:,:) {mustBeNumeric}
    roi (:,4) {mustBeNumeric}
    rid (:,1) {mustBeNumeric,mustBeCompDim(roi,rid)}
    opts.points (:,2) {mustBeNumeric} = NaN(numel(rid),2,"single")
    opts.validity (:,1) logical = false(numel(rid),1)
    opts.Detector {mustBeMember(opts.Detector,["detectMinEigenFeatures", ...
        "detectBRISKFeatures","detectFASTFeatures","detectHarrisFeatures", ...
        "detectKAZEFeatures","detectSURFFeatures"])} = "detectMinEigenFeatures"
end

% For use outside of the app, do not assume rnum is 1:(# of regions)
rnum = unique(rid,"stable"); % unique region number for each roi
cframe = im2gray(cframe);    % ensure image is grayscale for detector
points = opts.points;
val = opts.validity;

for r = unique(rid(~val))'  % regions with invalid/missing points
    % Detect new points in current roi
    j = (r==rnum); % get corresponding logical row index for "roi"
    pts = feval(opts.Detector,cframe,ROI=roi(j,:)); 

    % Only keep points not already contained in valid points
    reg = (r==rid);     % logical row indices for current roi
    keep = ~ismember(pts.Location,points(val&reg,:),"rows");
    pts = pts(keep);

    % Determine total number of points needed and select the strongest
    rows = (~val&reg);  % logical row indices for invalid points in roi
    mPts = nnz(rows);   % number of missing points to be filled
    if (pts.Count > mPts)
        pts = selectStrongest(pts,mPts);
    end
    nPts = pts.Count;   % number of points filled by detected "pts"
    pts = pts.Location;

    % Determine number of points still needed and fill randomly
    dPts = mPts - nPts; % point deficit
    if (dPts > 0)
        pts = [pts; roi(j,1:2)+roi(j,3:4).*rand(dPts,2)]; %#ok<AGROW> 
    end
    points(rows,:) = pts;
end

end

%% Custom Validation Functions
function mustBeCompDim(roi,rid)
if ~isequal(numel(unique(rid)),size(roi,1))
    eid = "Dimension:notCompatabile";
    msg = "Number of unique elements in rid must equal the height of roi.";
    throwAsCaller(MException(eid,msg))
end
end

% Copyright 2023 The MathWorks, Inc.