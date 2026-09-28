function onSaveButtonPushed(app,flag)

data.time = app.InitialTime.Value;
data.LabelTable = app.LabelTable.Data;
data.LabelTable.Properties.VariableNames = app.LabelTable.ColumnName;

vars = ["cframe","region","nRows","nCols"];
for k = 1:numel(vars)
    data.(vars(k)) = app.(vars(k));
end

if isequal(flag,"all")
    vars = string(properties(app.Angio));
    vars(vars=="DisplayMode") = [];
    vars(vars=="VideoWriter") = [];
    for k = 1:numel(vars)
        data.(vars(k)) = app.Angio.(vars(k));
    end
    data.Video = string(data.Video.Name);
    vars = ["groupIds","Igroup","Ismooth","dIdtGroup"];
    for k = 1:numel(vars)
        data.(vars(k)) = app.(vars(k));
    end
    data.nGroups = app.nGroups.Value;
end

if isdeployed
    msg = [];
else
    vars = string(fieldnames(data));
    for k = 1:numel(vars)
        assignin("base",vars(k),data.(vars(k)))
    end
    msg = "Press 'Save' to write data to file or " ...
        + "Press 'Cancel' to only load into MATLAB Workspace";
end

[~,fileName] = fileparts(app.Video.Name); % remove extension
fileName = fullfile(app.Video.Path,fileName);
[fileName,filePath] = uiputfile(["*.mat";"*.xlsx";"*.xls"],msg,fileName);
figure(app.UIFigure) % bring app to foreground
if isequal(fileName, 0)
    return % uiputfile cancelled by user
end
progress = uiprogressdlg(app.UIFigure, Title="Please Wait", Message="Saving Data...");

[~,~,ext] = fileparts(fileName);
fileName = fullfile(filePath,fileName);
if strcmp(ext,".mat")
    save(fileName,"-struct","data")
    progress.Value = 1;
elseif (strcmp(ext,".xlsx") || strcmp(ext,".xls"))
    fta.writeData(data,fileName,progress)
else
    msg = "Please select a valid save type (*.mat, *.xlsx, or *.xls).";
    uialert(app.UIFigure,msg,"Invalid File Format");
end
close(progress)

end % function

% Copyright 2020 - 2026 The MathWorks, Inc.