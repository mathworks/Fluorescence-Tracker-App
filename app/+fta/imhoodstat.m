function stat = imhoodstat(im,pts,dp,func)

arguments
    im (:,:,:) {mustBeNumeric}
    pts (:,2) {mustBeNumeric}
    dp (1,1) {mustBeInteger} = 5 % default pixel neighbourhood
    func (1,1) function_handle = @mean % default statistic
end

im = im2gray(im); % ensure image is grayscale
sz = size(im);
pts = round(pts);
nPts = size(pts,1);
stat = NaN(1,nPts);
nPix = 2*dp+1; % rows/cols of neighborhood about each point

% Compute image intensity statistic for a neighbourhood around each pixel point
for j = 1:nPts
    if ~any(isnan(pts(j,:))) % check that point is valid
        % Expand rows around pixel point to get neighbourhood rows
        rows = ((pts(j,2)-dp):(pts(j,2)+dp))';
        rows = max(rows,1);     % if overflow image, use edge value
        rows = min(rows,sz(1)); % if overflow image, use edge value
        rows = repmat(rows,nPix,1);
        
        % Expand cols around pixel point to get neighbourhood cols
        cols = ((pts(j,1)-dp):(pts(j,1)+dp));
        cols = max(cols,1);     % if overflow image, use edge value
        cols = min(cols,sz(2)); % if overflow image, use edge value
        cols = reshape(ones(nPix,1)*cols,nPix^2,1);
        
        % Convert row/col subscripts to linear indices
        % Note, mean will output class double unless im is class single
        idx = sub2ind(sz,rows,cols);
        stat(j) = func(im(idx));
    end
end

end

% Copyright 2023 The MathWorks, Inc.