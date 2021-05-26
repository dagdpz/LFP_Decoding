function [ timefreqbinned_tfs, bin_timestamps, bin_freq ] = ...
    lfp_tfa_decode_resample_timefreqbins(lfp_tfs, orig_timepoints, orig_freqpoints, nsamples_timebin, nsamples_freqbin, subsample, subsamplerange)
%lfp_tfa_decode_resample_timebins - function to time bin the raw LFP
%   Each time bin contains the average raw LFP of all timepoints within
%   that bin for each site. Each bin is assigned a timestamp equal to the timestamp of
%   middle timepoint of that bin
%
% USAGE:
%   [ timefreqbinned_tfs, bin_timestamps, bin_freq ] = ...
%    lfp_tfa_decode_resample_timefreqbins( lfp_tfs, orig_timepoints, ...
%    orig_freqpoints, nsamples_timebin, nsamples_freqbin) 
%
% INPUTS: 
%   lfp_tfs             - LFP TFS data (nsites x nfreqs x ntimepoints)
%   orig_timepoints     - timestamps of LFP TFS data (1 x ntimepoints)
%   orig_freqpoints     - frequencies of LFP TFS data (1 x nfreqs)
%   nsamples_timebin    - number of LFP TFS samples to be included in a
%   bin
%   nsamples_freqbin    - number of LFP TFS frequencies to be included in a
%   bin
% OUTPUTS:
%   timefreqbinned_tfs      - Resampled LFP TFS data (nsites x ntbins x
%   nfbins), 
%   ntbins = round(numel(orig_timepoints) / nsamples_timebin) and
%   nfbins = round(numel(orig_freqpoints) / nsamples_freqbin) 
%   bin_timestamps          - Timestamps of the bins (1 x ntbins)
%   bin_freq                - Timestamps of the bins (1 x nfbins)


% find number of bins possible
ntimebins = floor(length(orig_timepoints) / nsamples_timebin);
nfreqbins = floor(length(orig_freqpoints) / nsamples_freqbin);

% find the bin timestamps
timebins_idx = round(nsamples_timebin/2):nsamples_timebin:length(orig_timepoints)-round(nsamples_timebin/2);
bin_timestamps = orig_timepoints(timebins_idx);

% resampling by averaging
timebinned_tfs = zeros(size(lfp_tfs, 1), size(lfp_tfs, 2), ntimebins);
for k = 1:ntimebins
    bin_samples_idx = (k-1)*nsamples_timebin + 1:k*nsamples_timebin;
    timebinned_tfs(:,:,k) = nanmean(lfp_tfs(:, :, bin_samples_idx), 3);
end

% find the bin frequencies
freqbins_idx = round(nsamples_freqbin/2):nsamples_freqbin:length(orig_freqpoints)-round(nsamples_freqbin/2);
bin_freq = orig_freqpoints(freqbins_idx);

% resampling by averaging
timefreqbinned_tfs = zeros(size(timebinned_tfs, 1), nfreqbins, size(timebinned_tfs, 3));
for f = 1:nfreqbins
    bin_samples_idx = (f-1)*nsamples_freqbin + 1:f*nsamples_freqbin;
    timefreqbinned_tfs(:,f,:) = nanmean(timebinned_tfs(:, bin_samples_idx, :), 2);
end

if subsample
    idx_start = find(subsamplerange(1)<orig_freqpoints);
    idx_start = idx_start(1);
    idx_end = find(orig_freqpoints>subsamplerange(2));
    idx_end = idx_end(1);
    timefreqbinned_tfs = timefreqbinned_tfs(:,idx_start:1:idx_end,:);
end
