clc
clearvars

% This is a file used for testing and debugging.
y = load('damping.mat');
t = load('time.mat');
diff = y.yDiff{1,6};
tdiff = t.t{1,6};

changePts = dySegmentation(diff, tdiff);

segments = cell(length(changePts) - 1, 1);
times = cell(length(changePts) - 1, 1);
for k = 1:length(segments)
    segments{k} = diff(changePts(k):changePts(k + 1) - 1);
    [segments{k}, idx] = cleanSignal(segments{k});
    times{k} = tdiff(changePts(k):changePts(k + 1) - 1);
    times{k} = times{k}(idx:end);
end

seg3 = segments{3,1};
t3 = times{3,1};

opt = dampOscillationOptions();
opt.t = t3;
isDiv = isDampOscillating(seg3, opt);