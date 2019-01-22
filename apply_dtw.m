%% function to align secondary_sig with template_sig.
%
% aligned_secondary=APPLY_DTW(template_sig,secondary_sig,Sakoe_Chiba_band)
% Optional parameter: Sakoe_Chiba_band (default 20)

% Created by SP
% 19 Aug, 2016

function [aligned_secondary_sloped,ind2_slope]=apply_dtw(template_sig,secondary_sig,Sakoe_Chiba_band)

if nargin==2
    Sakoe_Chiba_band=20;
end

D=dtw_lib.dtw(template_sig,secondary_sig,Sakoe_Chiba_band);

ind2_slope=align_time_slope_constraint(D);
aligned_secondary_sloped=secondary_sig(ind2_slope);

