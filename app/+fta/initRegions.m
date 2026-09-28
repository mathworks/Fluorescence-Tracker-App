function [region,points,nPts] = initRegions(cframe,gridSize,maxPoints,opts)

arguments
    cframe (:,:,:) {mustBeNumeric}
    gridSize (1,2) {mustBeInteger,mustBePositive}
    maxPoints (1,1) {mustBePositive} = Inf
    opts.ptsPerRegion (1,1) {mustBeInteger} = 1
    opts.FillEmpty (1,1) logical = false
    opts.Detector {mustBeMember(opts.Detector,["detectMinEigenFeatures", ...
        "detectBRISKFeatures","detectFASTFeatures","detectHarrisFeatures", ...
        "detectKAZEFeatures","detectSURFFeatures"])} = "detectMinEigenFeatures"
end

% Setup region grid (image intrinsic coordinate system)
cframe = im2gray(cframe);
[h,w] = size(cframe,1:2); % [numrows numcols]
nRows = gridSize(1);
nCols = gridSize(2);
hReg  = ceil(h/nRows);
wReg  = ceil(w/nCols);
[X,Y] = meshgrid(0.5+(0:(nCols-1))*wReg,0.5+(0:(nRows-1))*hReg);
region = [X(:) Y(:) min(wReg,w+0.5-X(:)) min(hReg,h+0.5-Y(:))];
mPts = round(maxPoints);

% Detect points and only keep specified maximum points
if (nargout > 1)

    if ~isfinite(mPts)
        % Detecting points on full frame can results in clusters of points
        pts = feval(opts.Detector,cframe);
        if (pts.Count > 200)
            % Reduce potential redundancy (by half) to improve 
            % computation speed of transformation during registration
            mPts = round(pts.Count/2);
            pts = selectUniform(pts,mPts,[h,w]);
        end
    
    else
        % To prevent clusters, spread points across a grid of regions
        % with the grid size based on the max points specified
        rPts = opts.ptsPerRegion; % points per region, rPts*nr*nc >= mPts
        nr = sqrt((mPts/rPts)*(h/w));
        nc = min(floor(w/10),ceil(nr*w/h)); % number of cols
        nr = min(floor(h/10),ceil(nr));     % number of rows
        ng = nr*nc; % number of grid regions
        
        [X,Y] = meshgrid(0.5+(0:(nc-1))*w/nc,0.5+(0:(nr-1))*h/nr);
        grids = [X(:) Y(:) (w/nc)*ones(ng,1) (h/nr)*ones(ng,1)];
        idx = 0;
        for j = 1:ng
            ptsRoi = feval(opts.Detector,cframe,ROI=grids(j,:));
            if (j == 1)
                % Preallocate based on point feature type
                pts = feval(class(ptsRoi),ones(rPts*ng,2));
            end

            jPts = ptsRoi.Count;
            if (jPts > rPts)
                idx = idx(end) + (1:rPts);
                pts(idx) = selectStrongest(ptsRoi,rPts);
                jPts = rPts;
            elseif (jPts > 0)
                idx = idx(end) + (1:jPts);
                pts(idx) = ptsRoi;
            end

            % Make up point deficit with random points
            dPts = rPts - jPts; % point deficit
            if (opts.FillEmpty && (dPts > 0))
                idx = idx(end) + (1:dPts);
                pts(idx).Location = grids(j,1:2) + grids(j,3:4).*rand(dPts,2);
            end            
        end
        pts = pts(1:idx(end));
  
        % May end up with more points due to number of regions
        if (pts.Count > mPts)
            pts = selectUniform(pts,mPts,[h,w]);
        end
    end

    % Sort by corresponding region ids
    points = pts.Location;
    rows = ceil((points(:,2)-0.5)/hReg);
    cols = ceil((points(:,1)-0.5)/wReg);
    [rid,idx] = sort(sub2ind([nRows nCols],rows,cols));
    points = points(idx,:);
    nPts = sum(rid==(1:(nRows*nCols)),1)'; % sum(nPts) = numel(rid)
end

end

% Copyright 2023 The MathWorks, Inc.