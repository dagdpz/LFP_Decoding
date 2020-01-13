function [ resampled_lfp, timebins ] = lfp_tfa_decode_resample_timebins( raw_lfp, orig_timepoints, nsamples_timebin )
%lfp_tfa_decode_resample_timebins - function to time bin the raw LFP
%   Each time bin contains the average raw LFP of all timepoints within
%   that bin for each site. Each bin is assigned a timestamp equal to the timestamp of
%   middle timepoint of that bin
%
% USAGE:
%   [ resampled_lfp, timebins ] = lfp_tfa_decode_resample_timebins(
%   raw_lfp, orig_timepoints, nsamples_timebin ) 
%
% INPUTS: 
%   raw_lfp             - raw LFP data (nsites x ntimepoints)
%   orig_timepoints     - timestamps of raw LFP data (1 x ntimepoints)
%   nsamples_timebin    - number of raw LFP samples to be included in a
%   time bin
% OUTPUTS:
%   resampled_lfp       - Resampled LFP data (nsites x nbins),
%   ntimebins = round(numel(orig_timepoints) / nsamples_timebin)
%   timebins            - Timestamps of the raw LFP bins (1 x nbins)
%

% find number of bins possible
nbins = floor(length(orig_timepoints) / nsamples_timebin);

% find the new timestamps
timebins_idx = round(nsamples_timebin/2):nsamples_timebin:length(orig_timepoints)-round(nsamples_timebin/2);
timebins = orig_timepoints(timebins_idx);

% resampling by averaging
resampled_lfp = zeros(size(raw_lfp, 1), nbins);
for k = 1:nbins
    bin_samples_idx = (k-1)*nsamples_timebin + 1:k*nsamples_timebin;
    resampled_lfp(:,k) = nanmean(raw_lfp(:, bin_samples_idx), 2);
end

