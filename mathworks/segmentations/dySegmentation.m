function changePts = dySegmentation(y, t) 
    % Derivative-based segmentation
    %
    % INPUT:
    %   y : input signal (vector)
    %   t : time signal (vector) 
    %
    % OUTPUT:
    %   changePts : indices of detected change points
    
    
    % === 1. Compute the first derivative ===
    % The derivative highlights sudden changes in the signal
    dy = diff(y);
    
    % === 2. Define a threshold based on derivative statistics ===
    th = 2 * std(dy);
    
    % === 3. Find candidate change points ===
    cand = find(abs(dy) > th);
    
    % === 4. Enforce a minimum distance between change points ===
    minDist = max(floor(length(y)/10), 1);
    %changePts = cand([true; diff(cand) > minDist]);

    if ~isempty(cand)
        keep = true(size(cand));
        lastPt = cand(1);
        for i = 2:length(cand)
            if cand(i) - lastPt < minDist
                keep(i) = false;
            else
                lastPt = cand(i);
            end
        end
        changePts = cand(keep);
    else
        changePts = [];
    end


    changePts = [changePts; length(y)];
    
    % === 5. Plot results ===
    % figure
    % plot(t, y, 'DisplayName', 'Input signal'); % plot original signal
    % legend show
    % hold on
    % xline(t(changePts), 'k--', 'LineWidth', 1.5, ...
    %       'HandleVisibility','off');           % vertical lines at change points
    % title('Derivative-based segmentation')
end



