function [fu, fv] = piv_bfield_filters(OPTIONS, x, y, fu, fv)

% filter based on SNR threshold (it looks okay actually, mean is like 3)
% [fu, fv] = snrfilt(x, y, fu, fv, snr, thold_snr);

% filter based on the universal outlier detector
% [fu, fv] = unifilt(x, y, fu, fv);

% filter based on peak height filtering
% [fu, fv] = peakfilt(x, y, fu, fv, pkh, 0.5);

% global filtering
[fu, fv] = globfilt(x, y, fu, fv, OPTIONS.thold_global); % change to call with LOOP method

% local filtering
[fu, fv] = localfilt(x, y, fu, fv, OPTIONS.thold_local, 'median');

% interpolate the outliers
% [fu, fv] = naninterp(fu, fv, 'linear', x, y);


end % function

