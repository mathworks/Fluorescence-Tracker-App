function [frame,tbl,cmap] = updateLabels(frame,region,gridIds,labels)

arguments
    frame (:,:,:) {mustBeNumeric}
    region (:,4) {mustBeNumeric}
    gridIds (1,:) cell
    labels (1,:) cell
end

frame = insertShape(frame,"rectangle",region,Color="white");

s = numel(gridIds); % number of selections
if (s > 0)
    m = cellfun(@numel,gridIds); % grid regions in each selection
    sel = repelem((1:s)',m,1);   % ROI Selection Number
    gid = vertcat(gridIds{:});   % Region Grid Indices
    lab = repelem(vertcat(labels{:}),m,1); % ROI Label

    % If selection regions overlap, assign to most recent selection
    [~,idx] = unique(flip(gid),"stable"); % flip order to keep most recent
    idx = numel(gid) - flip(idx) + 1; % b/c can't use "last" with "stable"
    sel = sel(idx);
    gid = gid(idx);
    lab = lab(idx);
    tbl = table(sel,gid,lab);

    % Color code based on labels (not selection)
    [~,~,grp] = unique(lab,"stable"); % findgroups is not "stable"
    n = max(grp);
    if (n > 7)
        cmap = turbo(n);
    else
        cmap = lines(n);
    end

    frame = insertShape(frame,"filled-rectangle", ...
        region(gid,:),Color=255*cmap(grp,:),Opacity=0.5);
    if all(region(gid,3:4)>=30)
        frame = insertText(frame,region(gid,1:2)+region(gid,3:4)/2, ...
            gid,BoxOpacity=0,TextColor="white",AnchorPoint="center");
    elseif all(region(gid,3:4)>=20)
        frame = insertText(frame,region(gid,1:2)+region(gid,3:4)/2, ...
            sel,BoxOpacity=0,TextColor="white",AnchorPoint="center");
    end
else
    tbl = table([],[],[]);
    cmap = [];
end

end

% Copyright 2023 The MathWorks, Inc.