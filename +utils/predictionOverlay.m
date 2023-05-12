function overlay = predictionOverlay(frame,region,val,score,cmap,opts)

arguments
    frame (:,:,:) {mustBeNumeric}
    region (:,4) {mustBeNumeric}
    val (:,1) logical {mustBeEqualHeight(val,region)}
    score (:,2) {mustBeNumeric,mustBeCompDim(score,val)}
    cmap (256,3) {mustBeNumeric} = 255*turbo(256)
    opts.interp (1,1) logical = true
end

% Map scores, for turbo color map: [-1 1] -> [blue red]
prob = zeros(size(score,1),1);
c1 = (score(:,1) > score(:,2));     % Class1 prediction
prob( c1) = -2*(score( c1,1)-0.5);  % [0.5 1] -> [0 -1] (Class1)
prob(~c1) =  2*(score(~c1,2)-0.5);  % [0.5 1] -> [0 +1] (Class2)

% Interpolate prediction score heatmap
if opts.interp
    % Setup probability grid
    nRows = numel(unique(region(:,2)));
    nCols = numel(unique(region(:,1)));
    X = round(region(:,1) + region(:,3)/2); % region x-center
    Y = round(region(:,2) + region(:,4)/2); % region y-center
    X = reshape(X,nRows,nCols);
    Y = reshape(Y,nRows,nCols);
    P = zeros(nRows,nCols);
    P(val) = prob;

    % Interpolate at query points
    [h,w] = size(frame,1:2);
    [Xq,Yq] = meshgrid(1:w,1:h);
    Pq = interp2(X,Y,P,Xq,Yq,"spline");
    Pq = max(Pq,-1);
    Pq = min(Pq, 1);
    jq = round(255*(Pq+1)/2 + 1); % index into cmap, [-1 1] -> [1 256]

    % Find valid query points
    Vq = zeros(nRows*nCols,1);
    Vq(val) = 1;
    Vq = imresize(reshape(Vq,nRows,nCols),[h w]);
    Vq = (Vq>0.5);

    % Overlay interpolated prediction heatmap
    overlay = frame;
    for k = 1:3
        F = overlay(:,:,k);
        C = reshape(cmap(jq,k),[h w]);
        F(Vq) = C(Vq); % only overlay valid query points
        overlay(:,:,k) = F;
    end
    overlay = imfuse(frame,overlay,"blend", Scaling="none");

else 
    % Return prediction heatmap without interpolation
    j = round(255*(prob+1)/2 + 1); % index into cmap, [-1 1] -> [1 256]
    overlay = insertShape(frame,"filled-rectangle", ...
        region(val,:), Color=cmap(j,:), Opacity=0.5);
end

end

%% Custom Validation Functions

function mustBeEqualHeight(val,region)
if ~isequal(size(val,1),size(region,1))
    eid = "Height:notEqual";
    msg = "Height of val must equal height of region.";
    throwAsCaller(MException(eid,msg))
end
end

function mustBeCompDim(score,val)
if ~isequal(size(score,1),nnz(val))
    eid = "Dimension:notCompatabile";
    msg = "Height of score must equal number of nonzero elements in val.";
    throwAsCaller(MException(eid,msg))
end
end

% Copyright 2023 The MathWorks, Inc.