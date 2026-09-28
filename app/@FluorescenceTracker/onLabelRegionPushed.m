function onLabelRegionPushed(app)

labeled = app.LabeledFrame.Children.CData;
[h,w] = size(app.cframe,1:2);  % [numrows numcols]


% uiprogressdlg blocks entire MATLAB Online UI (R2025b) 
% instead of only the parent uifigure
if app.IsOnline
    progress = [];
else
    progress = uiprogressdlg( app.UIFigure, ...
        Title="Waiting for User Selection", Indeterminate="on", ...
        Message=["Please select desired region in figure window."; ...
        "Or close figure window to cancel selection."] );
end

fig = figure( NumberTitle="off", MenuBar="none", ...
    Position=[app.UIFigure.Position(1:2), w, h], ...
    Name="Select Region (double-click in rectangle to accept)" );
[~,cropBox] = imcrop(labeled);

close(progress)
if isempty(cropBox)
    return; % user closed figure without selection
end
close(fig)

% Get corresponding grid IDs
corners = [cropBox(1:2); cropBox(1:2)+cropBox(3:4)];
rows = ceil((corners(:,2)-0.5)/(h/app.nRows));
cols = ceil((corners(:,1)-0.5)/(w/app.nCols));
gid = reshape(1:(app.nRows*app.nCols),app.nRows,app.nCols);
gid = gid(rows(1):rows(2),cols(1):cols(2));
app.gridIds{end+1} = gid(:);
if ~isempty(app.LabelEditField.Value)
    app.gridLabels{end+1} = string(app.LabelEditField.Value);
else
    app.gridLabels{end+1} = "";
end

% Update figure and table
refreshLabelTab(app)
app.ClearLabel.Enable = "on";
app.SaveLabels.Enable = "on";

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.