function onClearRegionPushed(app)

% Clear most recent set of points
app.region(end,:) = [];
app.points((end-app.nPoints(end)+1):end,:) = [];
app.nPoints(end) = [];

if isempty(app.points) || (app.SelectRegion.Enable == "off")
    % Reset frames and enable components (in case video was played)
    onInitialTimeChanged(app);
    onFinalTimeChanged(app);
    app.InitialTime.Enable = "on";
    app.FinalTime.Enable = "on";
else
    cmarked = app.cframe;
    rows = 0;
    for j = 1:numel(app.nPoints)
        rows = rows(end) + (1:app.nPoints(j));
        cmarked = insertShape(cmarked,"rectangle",app.region(j,:),Color="white");
        cmarked = insertMarker(cmarked,app.points(rows,:),"+",Color="white");
    end
    app.InitialFrame.Children.CData = cmarked;
    app.ClearRegion.Enable = "on";
    app.PlayButton.Enable = "on";
end

app.SelectRegion.Enable = "on";
if isempty(app.points)
    app.AutoGridRegions.Enable = "on";
    app.AutoReInit.Enable = "on";
else
    app.AutoGridRegions.Enable = "off";
end

app.GridEnabled = false;
app.LabelRegion.Enable = "off";
app.RefreshPlots.Enable = "off";
cla(app.LabeledFrame)
app.LabelTable.Data = table([],[],[]);
app.gridIds = {};
app.gridLabels = {};

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.