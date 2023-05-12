function plotFeatures(features)

% Extract decay times
dTdecay = string(features.Properties.VariableNames);
dTdecay = dTdecay(startsWith(dTdecay,"Idecay"));
dTdecay = sort(str2double(extractBetween(dTdecay,"Idecay","s")));
m = numel(dTdecay);

% Extract values to plot
if ismember("tRamp",features.Properties.VariableNames)
    t0 = features.tRamp;
else
    t0 = zeros(size(features,1),1);
end
tpk = t0 + features.dTpeak;
Ihalf = features.Ibase + (features.Ipeak-features.Ibase)/2;
Idecay = features{:,end-m+1:end};

% Get current handles and legend data (if any)
ax = gca;
h = flip(ax.Children);
leg = string(get(h,"DisplayName"));
h = h(leg~="");
leg = leg(leg~="");

if isempty(h)
    % Create and add underlying feature curves
    time = [t0 t0+features.dThalf tpk tpk+dTdecay]';
    feat = [features.Ibase Ihalf features.Ipeak Idecay]';

    % Color code by labels (if available)
    if ismember("Label",features.Properties.VariableNames)
        leg = unique(features.Label);
        n = numel(leg);
        cmap = flipud(lines(n));
        h = gobjects(n,1);
        for k = 1:numel(leg)
            idx = (features.Label == leg(k));
            hk = plot(time(:,idx),feat(:,idx), ...
                LineWidth=1, Color=cmap(k,:));
            h(k) = hk(1);
            hold on
        end
    else
        line(time,feat, LineWidth=1, Color=[0.7 0.7 0.7]);
        hold on
    end
    grid on
end

% Setup color order
cmap = turbo(2*(3+m));
cmap = cmap(round((3+m)/2)+(1:(3+m)),:);
colororder(cmap)
ax.ColorOrderIndex = 1;

% Plot features
hf = gobjects(3+m,1);
hf(1) = scatter(t0,features.Ibase,18,"s","filled",MarkerEdgeColor="k");
hf(2) = scatter(t0+features.dThalf,Ihalf,18,"d","filled",MarkerEdgeColor="k");
hf(3) = scatter(tpk,features.Ipeak,18,"^","filled",MarkerEdgeColor="k");
hf(3+(1:m)) = scatter(tpk+dTdecay,Idecay,18,"o","filled",MarkerEdgeColor="k");

% Update legend
legend([h; hf],[leg; "Ibase"; "Ihalf (dThalf)"; "Ipeak (dTpeak)"; ...
    "Idecay"+dTdecay'+"s"], Location="southeast", NumColumns=2, ...
    FontName="Cambria",FontSize=7.5) % Cambria for a serif "I"

end

% Copyright 2023 The MathWorks, Inc.