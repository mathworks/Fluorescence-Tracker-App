function onGroupsValueChanged(app)

if (app.nGroups.Value > 500)
    msg = ["Processing time histories for more than 500 groups could " + ...
        "take a moment and/or cause the app to become unresponsive."; ...
        ""; "Press 'Cancel' to reduce the number of groups."];
    selection = uiconfirm(app.UIFigure,msg,"Confirm Excessive Groups", ...
        Icon="warning",Options=["Proceed" "Cancel"],DefaultOption=2);
    if (selection == "Cancel")
        app.nGroups.Value = app.nGrpPrev;
        return
    end
end  
app.nGrpPrev = app.nGroups.Value;

% Extract valid intensity values and setup groups
pval = all(~isnan(app.Angio.Ipoints));
if app.GridEnabled
    rval = ~any(isnan(app.Angio.Iregion),1)';
    I = app.Angio.Iregion(:,rval); % frames x regions
    if (app.nGroups.Value == 0)
        nReg = size(app.Angio.region,1);
        if (~isempty(app.LabelTable.Data) && (nReg==size(app.region,1)))
            % Group using provided labels
            rval = app.LabelTable.Data{:,2};
            I = app.Angio.Iregion(:,rval); % frames x regions
            [~,~,grpID] = unique(app.LabelTable.Data{:,3},"stable");
            nGrp = max(grpID); % (note: findgroups is not "stable")
        else
            % Group using initial region selection
            nGrp  = nReg;
            grpID = (1:nGrp)';
            grpID = grpID(rval); % groups with valid regions
        end
    else
        % Group valid regions using k-means clustering
        nGrp  = app.nGroups.Value;
        grpID = kmeans(I',nGrp);
    end

else
    I = app.Angio.Ipoints(:,pval); % frames x points
    if (app.nGroups.Value == 0)
        % Group using initial region selection
        nGrp  = numel(app.nPoints);
        grpID = repelem((1:nGrp)',app.nPoints,1);
        grpID = grpID(pval); % groups with valid points
    else
        % Group using k-means clustering
        nGrp  = app.nGroups.Value;
        grpID = kmeans(I',nGrp);
    end
end

% Compute group intensities (frames x regions)
if isscalar(grpID)
    app.Igroup = I;
else
    % Transpose back and forth to use grpstats
    app.Igroup = grpstats(I',grpID,"mean")';
end

% Order groups based on final group intensity value
if (app.nGroups.Value ~= 0)
    [~,isort] = sort(app.Igroup(end,:),"descend");
    app.Igroup = app.Igroup(:,isort);
    [~,isort] = sort(isort(:),"ascend");
    grpID = isort(grpID);
end
app.groupIds = grpID;

% Setup group color map
if (nGrp > 7)
    app.cmap = turbo(nGrp);
    app.ToggleLegend.Value = false;
else
    app.cmap = lines(nGrp);
    app.ToggleLegend.Value = true;
end

% Tab 2/3: Final Frame
if app.GridEnabled
    imarked = insertMarker(app.Angio.iframe, ...
        app.Angio.points(pval,:),"+",Color="white");
    imarked = insertShape(imarked,"filled-rectangle", ...
        app.Angio.region(rval,:),Color=255*app.cmap(grpID,:),Opacity=0.2);
else
    imarked = insertMarker(app.Angio.iframe,app.Angio.points(pval,:), ...
        "+",Color=255*app.cmap(grpID,:));
end
imshow(imarked,Parent=app.iFrameFinal2,Border="tight");
axis(app.iFrameFinal2,"image")
imshow(imarked,Parent=app.iFrameFinal3,Border="tight");
axis(app.iFrameFinal3,"image")

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.