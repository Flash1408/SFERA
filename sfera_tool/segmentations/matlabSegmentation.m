function changePts = matlabSegmentation(y, t)
    % Built-in segmentation
    %
    % INPUT:
    %   y : input signal (vector)
    %   t : time signal (vector) 
    %
    % OUTPUT:
    %   changePts : indices of detected change points

    maxChanges = floor(0.02*length(y));
    
    changePts = findchangepts(y, 'Statistic','mean','MaxNumChanges', maxChanges);
    changePts = [changePts(:); length(y)];
    
    % figure
    % plot(t,y), title('Original signal')
    % title('matlab Segmentation')
    % hold on
    % xline(t(changePts), 'r--');
    % hold off
end

