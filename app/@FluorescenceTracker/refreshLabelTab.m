function refreshLabelTab(app)

[labeled,tbl,color] = fta.updateLabels(app.cframe, ...
    app.region, app.gridIds, app.gridLabels);
app.LabeledFrame.Children.CData = labeled;
app.LabelTable.Data = tbl;
app.LabelTable.RowName = "numbered";

color = color + (1-color)*2/3; % lighten color
labs = unique(tbl{:,3},"stable");
for j = 1:numel(labs)
    rows = find(tbl{:,3} == labs(j));
    if ~isempty(rows)
        sty = uistyle("BackgroundColor",color(j,:));
        addStyle(app.LabelTable,sty,row=rows)
    end
end

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.