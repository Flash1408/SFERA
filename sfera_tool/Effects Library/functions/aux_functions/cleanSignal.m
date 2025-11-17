function [y_clean, idx_start] = cleanSignal(y, method, varargin)
% CLEAN SIGNAL removes the initial "inactive" part of the signal y.
% [y_clean, idx_start] = cleanSignal(y, method, ...)
% method: 'adaptive' (default), 'percent', 'peak', 'baseline'
% Additional options (varargin):
%  - for 'percent': p (0-1), default 0.02
%  - for 'peak': alpha (default 0.02)
%  - for 'baseline': W (window, default min(200, round(0.02*N))), k (default 3)

    if nargin < 2 || isempty(method)
        method = 'adaptive';
    end

    y = y(:); % column (forced)
    N = length(y);
    idx_start = 1;

    switch lower(method)
        case 'percent'
            p = 0.02;
            if ~isempty(varargin), p = varargin{1}; end
            p = max(0, min(0.2, p)); % bound
            idx_start = min(N, round(p * N) + 1);

        case 'peak'
            alpha = 0.02;
            if ~isempty(varargin), alpha = varargin{1}; end
            thr = alpha * max(abs(y));
            pos = find(abs(y) > thr, 1, 'first');
            if ~isempty(pos), idx_start = pos; end

        case 'baseline'
            W = min(200, max(20, round(0.02 * N)));
            if ~isempty(varargin), W = varargin{1}; end
            k = 3;
            if length(varargin) >= 2, k = varargin{2}; end
            mu0 = mean(y(1:min(W,N)));
            sigma0 = std(y(1:min(W,N)));
            pos = find(abs(y - mu0) > k * sigma0, 1, 'first');
            if ~isempty(pos), idx_start = pos; end

        case 'adaptive'
            % combination: try baseline, else if peak, else percent
            W = min(200, max(20, round(0.02 * N)));
            mu0 = mean(y(1:min(W,N)));
            sigma0 = std(y(1:min(W,N)));
            pos = find(abs(y - mu0) > 3 * sigma0, 1, 'first');
            if ~isempty(pos)
                idx_start = pos;
            else
                thr = 0.02 * max(abs(y));
                pos2 = find(abs(y) > thr, 1, 'first');
                if ~isempty(pos2)
                    idx_start = pos2;
                else
                    % fallback: 1% signal length (min 10 champions)
                    idx_start = min(N, max(2, round(0.01 * N)));
                end
            end

        otherwise
            error('Method not recognized');
    end

    % offset
    idx_start = max(1, idx_start);
    y_clean = y(idx_start:end);
end
