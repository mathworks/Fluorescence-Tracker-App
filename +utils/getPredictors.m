function features = getPredictors(time,intensity,dTdecay)

% Ensure intensity is [m (regions) x n (frames)]
time = time(:); % make column vector
[m,n] = size(intensity);
if (n ~= numel(time))
    % FTApp outputs intensity as [n (frames) x m (regions)]
    intensity = intensity'; % ...so it must be transposed
    [m,n] = size(intensity);
end

dIramp = 2;  % intensity change indicating start of ramp-up
dTramp = 45; % max ramp-up duration
kramp = ones(m,1); % indices for first dIramp unit increase
kpeak = ones(m,1); % indices for first dI < 0 after ramp-up
khalf = ones(m,1); % indices when intensity = Ipeak/2
Ibase = NaN(m,1);
Ipeak = NaN(m,1);
for j = 1:m
    % Find start of ramp-up (back-diff'ed intensity can be too noisy)
    krmp = find((intensity(j,:)-intensity(j,1))>dIramp,1,"first");
    if ~isempty(krmp)
        kramp(j) = krmp;
        Ibase(j) = intensity(j,kramp(j));

        % Find first peak
        idx = (time <= (time(kramp(j)) + dTramp));
        [~,kpeak(j)] = max(intensity(j,idx));
        Ipeak(j) = intensity(j,kpeak(j));

        % Find time to half-peak
        Ihalf = Ibase(j) + (Ipeak(j) - Ibase(j))/2;
        rng = kramp(j):kpeak(j);
        [~,khalf(j)] = min(abs(intensity(j,rng)-Ihalf),[],2);
        khalf(j) = khalf(j) + rng(1) - 1;
    end
end

% Extract values for predictor table
tRamp  = time(kramp);
dThalf = time(khalf) - time(kramp);
dTpeak = time(kpeak) - time(kramp);

% Add intensity values at peak + dTdecay
features = table(tRamp,dThalf,dTpeak,Ibase,Ipeak);
Hz = round(mean(1./diff(time)));
for i = 1:numel(dTdecay)
    kdt = kpeak+(dTdecay(i)*Hz);
    idx = sub2ind([m n],(1:m)',min(kdt,n));
    Idecay = intensity(idx);
    Idecay(kdt>n) = NaN;
    features.("Idecay"+dTdecay(i)+"s") = Idecay;
end

% If no ramp-up found
features{kramp==1,:} = NaN;

% Copyright 2023 The MathWorks, Inc.