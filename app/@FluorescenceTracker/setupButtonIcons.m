function setupButtonIcons(app)

% Use built-in icons
iconPath = fullfile( matlabroot, "ui", "icons", "24x24" );

% "Setup" Tab Buttons
app.LoadVideo.Icon = fullfile( iconPath, "browseFolder.svg" );
app.CropVideo.Icon = fullfile( iconPath, "scissorToolUI.svg" );
app.SelectRegion.Icon = fullfile( iconPath, "select_region.svg" );
app.AutoGridRegions.Icon = fullfile( iconPath, "edit_grid.svg" );
app.ClearRegion.Icon = fullfile( iconPath, "removeRegion.svg" );
app.PlayButton.Icon = fullfile( iconPath, "video.svg" );

% "Setup" Tab - Frame Buttons
app.BackFrame1.Icon = fullfile( iconPath, "arrowBackTo.svg" );
app.NextFrame1.Icon = fullfile( iconPath, "arrowGoTo.svg" );
app.BackFrame2.Icon = fullfile( iconPath, "arrowBackTo.svg" );
app.NextFrame2.Icon = fullfile( iconPath, "arrowGoTo.svg" );

% "Fluorescence Intensity" Tab Buttons
app.ToggleLegend.Icon = fullfile( iconPath, "legend.svg" );
app.SaveButton.Icon = fullfile( iconPath, "unsaved.svg" );

% "Grid Labeling" Tab Buttons
app.LabelRegion.Icon = fullfile( iconPath, "select_region.svg" );
app.ClearLabel.Icon = fullfile( iconPath, "removeRegion.svg" );
app.RefreshPlots.Icon = fullfile( iconPath, "refresh.svg" );
app.SaveLabels.Icon = fullfile( iconPath, "unsaved.svg" );

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.