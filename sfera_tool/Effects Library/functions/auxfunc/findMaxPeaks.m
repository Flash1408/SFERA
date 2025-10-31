function [peaksVal, peaksIdx] = findMaxPeaks(y, ampThresh, minDist)
% findMaxPeaks  Trova i massimi locali significativi in un segnale
%
%   [peaksVal, peaksIdx] = findMaxPeaks(y, ampThresh, minDist)
%
%   y          : segnale (vettore)
%   ampThresh  : soglia minima di ampiezza (es. 0.2*max(y))
%   minDist    : distanza minima tra picchi (in campioni)
%
%   peaksVal   : valori dei picchi trovati
%   peaksIdx   : indici corrispondenti

    if nargin < 2 || isempty(ampThresh)
        ampThresh = 0; % default: nessuna soglia
    end
    if nargin < 3 || isempty(minDist)
        minDist = 1; % default: nessuna distanza minima
    end

    y = y(:);

    % --- individua candidati a massimo locale ---
    candIdx = find(y(2:end-1) > y(1:end-2) & y(2:end-1) >= y(3:end)) + 1;

    % --- applica soglia di ampiezza ---
    candIdx = candIdx(y(candIdx) >= ampThresh);

    if isempty(candIdx)
        peaksVal = [];
        peaksIdx = [];
        return;
    end

    % --- applica distanza minima tra picchi ---
    peaksIdx = [];
    lastIdx = -inf;
    for k = 1:numel(candIdx)
        idx = candIdx(k);
        if idx - lastIdx > minDist
            peaksIdx(end+1) = idx; %#ok<AGROW>
            lastIdx = idx;
        else
            % se sono troppo vicini, tieni il più alto
            if y(idx) > y(peaksIdx(end))
                peaksIdx(end) = idx;
                lastIdx = idx;
            end
        end
    end

    peaksVal = y(peaksIdx);
end




