function img = insertRegions( img, region, opts )

% Helper function for workshop attendees without Computer Vision Toolbox.
% However, a better/easier way would be to use the function insertShape:
% img = insertShape( img, "rectangle", region, Color=255*cmap, LineWidth=2 );

arguments
    img (:,:,:) {mustBeNumeric}
    region (:,4) {mustBeNumeric,mustBePositive}
    opts.Color (:,3) {mustBeNumeric} = 255*[1 1 1]
    opts.LineWidth (1,1) {mustBeInteger,mustBePositive} = 2
end

nReg = height( region );
[m,n,p] = size( img );
w = (1:opts.LineWidth) - opts.LineWidth/2;

cmap = opts.Color;
if (p == 1)
    cmap = cmap*[0.299; 0.587; 0.114]; % rgb to gray
end
if (height(cmap) == 1)
    cmap = repmat( cmap, nReg , 1 );
end

for k = 1:nReg % each region
    % Setup line width
    ypts = region(k,2) + (w(1):(region(k,4)+w(end)));
    cols = region(k,1) + [w (region(k,3)+w)];
    rows = region(k,2) + [w (region(k,4)+w)];
    xpts = region(k,1) + (w(1):(region(k,3)+w(end)));

    % Ensure regions fit on image
    ypts = clip( round( ypts ), 1, m );
    cols = clip( round( cols ), 1, n );
    rows = clip( round( rows ), 1, m );
    xpts = clip( round( xpts ), 1, n );

    % Apply to each color channel/page
    for j = 1:p
        img(ypts,cols,j) = cmap(k,j); % vertical lines
        img(rows,xpts,j) = cmap(k,j); % horizontal lines
    end
end

end

% Copyright 2024 The MathWorks, Inc.