function changePts = uniformSegmentation(y, t, perc)
    % Uniform segmentation: split the signal into equal-length segments
    %
    % INPUTS:
    %   y    : input signal (vector)
    %   t    : time signal (vector) 
    %   perc : percentage of the signal for each segment (0–100)
    %
    % OUTPUT:
    %   changePts : indices of detected change points

    if nargin < 3
        perc = 10;  % default = 10% of signal
    end

    N = max(t);                % total signal length
    step = round(N * perc / 100); % samples per segment

    % Indices where a segment ends
    t_init = min(t);
    if t_init == 0
        t_init = 1;
    end
    changePts = t_init:step:N;
    if changePts(end) ~= N
        changePts = [changePts N]; % ensure last point is included
    end

    % Plot
    %t = 1:N;
    % figure
    % plot(t, y, 'DisplayName', 'Signal');
    % hold on
    % xline(changePts, 'r--', 'LineWidth', 1.5, ...
    %       'HandleVisibility','off');
    % title(['Uniform segmentation (' num2str(perc) '%)'])
    % legend show
end


