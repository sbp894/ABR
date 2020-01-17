function dc_struct= remove_rect_from_abr(abr, fs, plotYes)

%% Implement this later

% assuming first column is for the highest SPL

% find min and max: then edge detect at half
if ~exist('plotYes', 'var')
    plotYes= false;
end

ind_vals= nan(1, 2);

cur_abr= abr(:, end);
cur_min= min(cur_abr);
cur_max= max(cur_abr);

cur_edge_detect= .5*(cur_min+cur_max);

% check if positive or negative DC shift
% Know that stim is ON 1-4 ms
if mean(cur_abr(round(fs*1e-3):round(4*1e-3)))<mean(cur_abr(round(fs*11e-3):round(14*1e-3)))
    ind_vals(1)= find(cur_abr(1:end-1) > cur_edge_detect & cur_abr(2:end) < cur_edge_detect, 1);
    ind_vals(2)= find(cur_abr(1:end-1) < cur_edge_detect & cur_abr(2:end) > cur_edge_detect, 1);
else
    ind_vals(1)= find(cur_abr(1:end-1) < cur_edge_detect & cur_abr(2:end) > cur_edge_detect, 1);
    ind_vals(2)= find(cur_abr(1:end-1) > cur_edge_detect & cur_abr(2:end) < cur_edge_detect, 1);
end


dc_struct.times= ind_vals/fs;
dc_struct.offset= mean(mean(abr(ind_vals(1):ind_vals(2), end)));
dc_struct.true= mean(mean(abr(ind_vals(2)+1:end, end)));
abr_mask= cur_abr*0 + dc_struct.true;
abr_mask(ind_vals(1):ind_vals(2))= dc_struct.offset;
dc_struct.abr_mask= abr_mask;

if plotYes
    
    
    
    figure(111); clf;
    hold on;
    plot((1:length(cur_abr))/fs, cur_abr);
    plot([1 length(cur_abr)]/fs, [cur_edge_detect cur_edge_detect], 'k', 'LineWidth', 1.5);
    plot((1:length(cur_abr))/fs, abr_mask, 'r', 'LineWidth', 2);
end
