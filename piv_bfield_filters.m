function [fu, fv] = piv_bfield_filters(OPTIONS, x, y, fu, fv, snr, pkh)

% filter based on SNR threshold (it looks okay actually, mean is like 3)
[fu, fv] = snrfilt(x, y, fu, fv, snr, OPTIONS.thold_snr);

% filter based on the universal outlier detector
% [fu, fv] = unifilt(x, y, fu, fv);

% filter based on peak height filtering
[fu, fv] = peakfilt(x, y, fu, fv, pkh, OPTIONS.thold_peak);

% global filtering
% [fu, fv] = globfilt(x, y, fu, fv, OPTIONS.thold_global);
% [fu, fv] = globfilt(x, y, fu, fv, OPTIONS.thold_global, OPTIONS.Nglobal); % crash if more than 5 inputs?
[fu, fv] = globfilt(x, y, fu, fv, OPTIONS.thold_global);

% local filtering
[fu, fv] = localfilt(x, y, fu, fv, OPTIONS.thold_local, OPTIONS.thold_local_stat, OPTIONS.thold_local_num);

% interpolate the outliers
% [fu, fv] = naninterp(fu, fv, OPTIONS.int, x, y);

end % function

