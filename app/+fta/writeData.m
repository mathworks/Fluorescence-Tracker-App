function writeData(data,fileName,progress)

arguments
    data (1,1) struct
    fileName {mustBeTextScalar}
    progress (1,1) = struct % matlab.ui.dialog.ProgressDialog
end

if isfield(data,"Ipoints")
    % Save all data
    pval = all(~isnan(data.Ipoints));
    GroupName = "Group"+unique(data.groupIds)';
    if (data.Method == "region-based")
        PointID = "RegionID";
        nRows = numel(unique(data.region(:,2))); % number of grid rows
        nCols = numel(unique(data.region(:,1))); % number of grid columns
        [h,w] = size(data.cframe1,1:2); % [numrows numcols]
        rows = ceil((data.points1(:,2)-0.5)/(h/nRows));
        cols = ceil((data.points1(:,1)-0.5)/(w/nCols));
        ptid = sub2ind([nRows nCols],rows,cols);
        if (data.nGroups~=0) % Grouping selected, ignore labels
            msg = "Set groups to zero to use labels.";
            data.LabelTable = table([],VariableNames=msg);
        end
        if ~isempty(data.LabelTable)
            GroupName = unique(data.LabelTable.Label)';
        end
    else
        PointID = "GroupID";
        ptid = NaN(numel(pval),1);
        ptid(pval) = data.groupIds; % invalid points already removed
    end

    progress.Message = "Saving Points, Validity, and IDs...";
    T = array2table([data.points1 pval' ptid]);
    T.Properties.VariableNames = ["X_Initial" "Y_Initial" "Validity_Final" PointID];
    writetable(T,fileName,Sheet="Point_Groups",WriteMode="overwritesheet")
    progress.Value = 1/6;

    progress.Message = "Saving Point Intensity...";
    T = array2table([data.time data.Ipoints]);
    T.Properties.VariableNames = ["Time" "Point"+(1:size(data.Ipoints,2))];
    writetable(T,fileName,Sheet="Point_Intensity",WriteMode="overwritesheet")
    progress.Value = 2/6;

    progress.Message = "Saving Unsmoothed Region Intensity...";
    T = array2table([data.time data.Iregion]);
    T.Properties.VariableNames = ["Time" "Region"+(1:size(data.Iregion,2))];
    writetable(T,fileName,Sheet="Region_Intensity",WriteMode="overwritesheet")
    progress.Value = 3/6;

    progress.Message = "Saving Smoothed Group Intensity...";
    T = array2table([data.time data.Ismooth]);
    T.Properties.VariableNames = ["Time" GroupName];
    writetable(T,fileName,Sheet="Smoothed_Intensity",WriteMode="overwritesheet")
    progress.Value = 4/6;

    progress.Message = "Saving Group Intensity Rate of Change...";
    T = array2table([data.time [data.dIdtGroup; NaN(1,size(data.dIdtGroup,2))]]);
    T.Properties.VariableNames = ["Time" GroupName];
    writetable(T,fileName,Sheet="Intensity_Rate",WriteMode="overwritesheet")
    progress.Value = 5/6;

    if (data.Method == "region-based")
        progress.Message = "Saving Grid Labels...";
        writetable(data.LabelTable,fileName,Sheet="Grid_Labels",WriteMode="overwritesheet")
    end
    progress.Value = 6/6;

else
    % Save labels only
    progress.Message = "Saving Grid Labels...";
    writetable(data.LabelTable,fileName,Sheet="Grid_Labels",WriteMode="overwritesheet")
    progress.Value = 1;
end

end

% Copyright 2023 The MathWorks, Inc.