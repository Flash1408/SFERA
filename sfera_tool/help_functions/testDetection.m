clc
clearvars

rng('default')

data = load('firstfault.mat');
y_data = data.actual_speed_fault.signals.values;

[y, idx] = cleanSignal(y_data, 'adaptive');

t = 1:length(y);

figure
plot(t,y);

L = 250000;   %segment length
segments = {};  % cell array per salvare i segmenti


segments{1} = y(1:200000-1);
segments{2} = y(200000:500000-1);
segments{3} = y(500000:length(y));


% startIdx = 1;

% while startIdx <= length(y)
%     endIdx = min(startIdx + L - 1, length(y));  % assicurati di non uscire dai limiti
%     segments{end+1} = y(startIdx:endIdx);
%     startIdx = startIdx + L;  % passo al segmento successivo
% end

N = length(segments);  %number of segments

result = cell(N, 2);  % 1° column: isDiv, 2° column: howDiv

for k = 1:N
    seg = segments(:,k);
    [isDiv, howDiv] = isDivergent(seg);  
    result{k,1} = isDiv;               
    result{k,2} = howDiv;             
end

