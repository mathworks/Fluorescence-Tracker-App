function [LabelTable,LabelColors] = labelRegions(gTruth,regionSize,labelLimit)

arguments
    gTruth (1,1) groundTruth % e.g. exported from Image Labeler
    regionSize (1,2) {mustBeNumeric} % [hReg wReg]
    labelLimit (1,1) {mustBeLessThanOrEqual(labelLimit,1)} = 0.75
    % labelLimit = min percent of labeled pixels in grid region
end

pixelLabels = imread( gTruth.LabelData.PixelLabelData{1} );
labels = string( gTruth.LabelDefinitions.Name );
ids = cell2mat( gTruth.LabelDefinitions.PixelLabelID );

func = @(I) mean( I.data, "all" );
nIds = numel( ids );
LabelTable = cell( nIds, 1 );
for k = 1:nIds
    lab = (pixelLabels == ids(k));
    lab = blockproc( lab, regionSize, func );
    idx = find( lab >= labelLimit );
    nReg = numel( idx );
    LabelTable{k} = table( repmat(ids(k), nReg ,1 ), ...
        idx, repmat( labels(k), nReg, 1 ), ...
        VariableNames=["Selection" "Grid Region" "Label"]);
end

LabelTable = vertcat( LabelTable{:} );
LabelColors = gTruth.LabelDefinitions.LabelColor(ids,:);
if iscell( LabelColors )
    LabelColors = cell2mat( LabelColors );
end

end