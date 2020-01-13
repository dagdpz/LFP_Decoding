function class_condition_idx = lfp_tfa_decode_get_class_condition(conditions,class)
%lfp_tfa_decode_get_class_condition - Function to match trial conditions to
%the classes to be decoded
%   Detailed explanation goes here
%
% USAGE:
%	class_condition_idx = lfp_tfa_decode_get_class_condition(conditions, class)
%
% INPUTS:
%       conditions      - the different conditions of the recorded trials.
%       Condition is a combination of perturbation, choice, type-effector?,
%       reach hand, and reach space
%       class           - conditions of a class to be decoded
%
% OUTPUTS:
%		class_condition_idx        - the index of the conditions which
%		belong to the given class
%
%
% See also lfp_tfa_decoe_predict_classes
%

class_condition_idx = true(1, length(conditions));
% get conditions to be checked
fields = fieldnames(class);
for f = 1:length(fields)
    field = fields{f};
    if isempty(class.(field))
        continue;
    end
    if ~strcmp(field, 'label') && ~strcmp(field, 'perturbation') && ~strcmp(field, 'hs_label') ...
            && ~strcmp(field, 'reach_hand') && ~strcmp(field, 'reach_space') && ~strcmp(field, 'choice_trial')
        % get trials based on each condition
        if isfield(conditions, field) && any(~isinf(class.(field)))
            class_condition_idx = class_condition_idx & ...
                ismember([conditions.(field)], class.(field));
        end
    elseif strcmp(field, 'perturbation')
        % get trials based on perturbation
        if isfield(conditions, field) && any(~isinf(class.(field)))
            if class.(field) == 0 
                class_condition_idx = class_condition_idx & [conditions.(field)] == 0;
            else
                class_condition_idx = class_condition_idx & [conditions.(field)] ~= 0;
            end
        end
    elseif strcmp(field, 'hs_label') || strcmp(field, 'reach_hand') || strcmp(field, 'reach_space')
        % get trials based on each condition
        if isfield(conditions, field) && any(~isinf(class.(field)))
            class_condition_idx = class_condition_idx & ...
                strcmp({conditions.(field)}, class.(field));
        end
    elseif strcmp(field, 'choice_trial')
        % get trials based on each condition
        if isfield(conditions, 'choice') && any(~isinf(class.(field)))
            class_condition_idx = class_condition_idx & ...
                ismember([conditions.choice], class.(field));
        end
    end
end

class_condition_idx = find(class_condition_idx);


end

