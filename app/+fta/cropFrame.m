function [cframe,iframe] = cropFrame(frame)

arguments
    frame (:,:,:) {mustBeNumeric}
end

[h,w] = size(frame,1:2);
aspectRatio = h/w;

% Check if frame has already been cropped
if (aspectRatio == 9/16)
    % Crop top/middle of left 3 insets
    w = w/4;
    h = h/3;
elseif (aspectRatio == 6/4)
    % Split top/bottom of pre-cropped frame
    h = h/2;
end

% crop rectangle = [xmin ymin width height]
cframe = imcrop(frame,[0 0 w h]);     % top inset or top half
iframe = imcrop(frame,[0 1+h w h]);   % middle inset or bottom half

% If necessary, resize to ensure consistent dimensions
% imcrop doc: "The actual size of the output image does not always
% correspond exactly with the width and height specified by rect."
if ~all(size(cframe,1:2) == [h w])
    cframe = imresize(cframe,[h w]);  % [numrows numcols]
end
if ~all(size(iframe,1:2) == [h w])
    iframe = imresize(iframe,[h w]);  % [numrows numcols]
end
iframe = im2gray(iframe);

end

% Copyright 2023 The MathWorks, Inc.