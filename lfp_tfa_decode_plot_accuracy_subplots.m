function session_info = lfp_tfa_decode_plot_accuracy_subplots(lfp_decode_accuracy, figtitle, results_folder )
%lfp_tfa_decode_plot_accuracy Plot the decoding accuracy
%   Detailed explanation goes here
%
% USAGE:
%   lfp_tfa_decode_plot_accuracy( lfp_decode_accuracy, figtitle, results_folder )
%
% INPUTS:
%   lfp_decode_accuracy - struct which stores the decoding accuracy
%   figtitle            - title of the figure being plotted
%   results_folder      - folder to which the resulting plot should be
%   saved

if ~exist([results_folder '\sites'], 'dir')
    try
        mkdir([results_folder '\sites']);
    catch e
        warning('Cannot create results folder. \nReason: %s\n\n', e.message());
    end
end

num_per_fig = 8;
session_info = struct();
for site = 1:size(lfp_decode_accuracy.test_accuracy, 1)
    for ep = 1:length(lfp_decode_accuracy.timebins)
        session_info.means{site,ep} = [];
    end
end

iter = ceil(size(lfp_decode_accuracy.test_accuracy, 1)/num_per_fig);
counter = 1;
for i = 1:iter
    h = figure('name', figtitle);
    set(h, 'position', [10, 10,900, 675]);
    noffset = 2;
    
    for s = 1:num_per_fig
        if (i*num_per_fig > size(lfp_decode_accuracy.test_accuracy, 1)) && ((i*num_per_fig - (num_per_fig - s)) > size(lfp_decode_accuracy.test_accuracy, 1))
            break
        else
            subplot(2, num_per_fig/2, s);
            curr_lfp_test_accuracy = lfp_decode_accuracy.test_accuracy(num_per_fig*(i-1)+s,:);
            hold on;
            set(gca, 'YLim', [0, 1])
            timebin_samples = [0];
            timebin_values = [];
            event_onset_samples = zeros(1, length(lfp_decode_accuracy.timebins));
            wnd_start_samples = zeros(1, length(lfp_decode_accuracy.timebins));
            wnd_end_samples = zeros(1, length(lfp_decode_accuracy.timebins));
            
            for ep = 1:length(lfp_decode_accuracy.timebins)
                event_onset_sample = find(abs(lfp_decode_accuracy.timebins{ep}) == ...
                    min(abs(lfp_decode_accuracy.timebins{ep})), 1, 'last');
                event_onset_samples(ep) = timebin_samples(end) + event_onset_sample;
                wnd_start_samples(ep) = timebin_samples(end) + 1;
                wnd_end_samples(ep) = timebin_samples(end) + length(lfp_decode_accuracy.timebins{ep});
                timebin_samples = ...
                    timebin_samples(end) + (1:(length(lfp_decode_accuracy.timebins{ep}) + noffset));
                timebin_values = [timebin_values, lfp_decode_accuracy.timebins{ep}, nan(1, noffset)];
                shadedErrorBar(timebin_samples(1:length(lfp_decode_accuracy.timebins{ep})), ...
                    nanmean(curr_lfp_test_accuracy{ep},2), ...
                    nanstd(curr_lfp_test_accuracy{ep},0,2), ...
                    'b',1);
                session_info.means{counter,ep} = nanmean(curr_lfp_test_accuracy{ep},2);
                session_info.stds{counter,ep} = nanstd(curr_lfp_test_accuracy{ep},0,2);
                line([event_onset_samples(ep) event_onset_samples(ep)], ylim, 'color', 'k');
                text(event_onset_samples(ep) + 0.5, 0.5, lfp_decode_accuracy.epoch_name{ep});
            end
            counter = counter + 1;
            
            
            xticks = [wnd_start_samples; event_onset_samples; wnd_end_samples];
            xticks = unique(xticks(:));
            set(gca, 'xtick', xticks)
            set(gca, 'xticklabels', round(timebin_values(xticks), 1))
            set(gca, 'xticklabelrotation', 45);
            
            if s == 1
                ylabel('Accuracy');
                xlabel('Time (s)');
            end
            title(sprintf('site %g',num_per_fig*(i-1)+s));
            
            
            % save figure
            
        end
    end
    
    figtitleSub = [figtitle ' fig' num2str(i)];
    results_file = fullfile(results_folder,'/sites' , figtitleSub);
    
    try
        %                     export_fig(h, results_file, '-svg');
        export_fig(h, results_file, '-pdf');
    catch e
        warning('Cannot save figures. Reason: %s\n\n', e.message());
    end
end
close all
end