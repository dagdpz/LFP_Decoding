function lfp_tfa_decode_plot_accuracy_main( lfp_decode_accuracy, session_info, figtitle, results_folder )
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
    h = figure('name', figtitle);
    set(h, 'position', [10, 10,900, 675]);
    noffset = 2;
    for s = 1:size(lfp_decode_accuracy.test_accuracy, 1)
        subplot(size(lfp_decode_accuracy.test_accuracy, 1), 1, s);
        hold on;
        set(gca, 'YLim', [0, 1])
        timebin_samples = [0];
        timebin_values = [];
        event_onset_samples = zeros(1, length(lfp_decode_accuracy.timebins));
        wnd_start_samples = zeros(1, length(lfp_decode_accuracy.timebins));
        wnd_end_samples = zeros(1, length(lfp_decode_accuracy.timebins));

        for ep = 1:length(lfp_decode_accuracy.timebins)
            combined = [];
            for i = 1:size(session_info.means,1)
                combined = cat(2, combined, session_info.means{i,ep});
            end
            event_onset_sample = find(abs(lfp_decode_accuracy.timebins{ep}) == ...
                min(abs(lfp_decode_accuracy.timebins{ep})), 1, 'last');
            event_onset_samples(ep) = timebin_samples(end) + event_onset_sample;
            wnd_start_samples(ep) = timebin_samples(end) + 1;
            wnd_end_samples(ep) = timebin_samples(end) + length(lfp_decode_accuracy.timebins{ep});
            timebin_samples = ...
                timebin_samples(end) + (1:(length(lfp_decode_accuracy.timebins{ep}) + noffset));
            timebin_values = [timebin_values, lfp_decode_accuracy.timebins{ep}, nan(1, noffset)];
            shadedErrorBar(timebin_samples(1:length(lfp_decode_accuracy.timebins{ep})), ...
                        nanmean(lfp_decode_accuracy.test_accuracy{s, ep}, 2), ...
                        nanstd(combined,0,2), ...
                        'lineProps','b');

            line([event_onset_samples(ep) event_onset_samples(ep)], ylim, 'color', 'k');
            text(event_onset_samples(ep) + 0.5, 0.5, lfp_decode_accuracy.epoch_name{ep});

        end

        xlabel('Time (s)');
        xticks = [wnd_start_samples; event_onset_samples; wnd_end_samples];
        xticks = unique(xticks(:));
        set(gca, 'xtick', xticks)
        set(gca, 'xticklabels', round(timebin_values(xticks), 1))
        set(gca, 'xticklabelrotation', 45);
        if s == 1, title(figtitle); end
        if size(lfp_decode_accuracy.test_accuracy, 1) == 1
            ylabel('Accuracy');
        else
            ylabel(sprintf('nsites = %g', s));
        end
    end
    
    % save figure
    results_file = fullfile(results_folder, figtitle);
    try
        export_fig(h, results_file, '-svg');
        %export_fig(h, results_file, '-pdf');
    catch e
        warning('Cannot save figures. Reason: %s\n\n', e.message());
    end
end