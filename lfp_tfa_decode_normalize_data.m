function [ train_data_norm, test_data_norm ] = lfp_tfa_decode_normalize_data( train_data, test_data, normalization )
%lfp_tfa_decode_normalize_data Normalize the train and test data using a
%normalization factor obtained using only the train data. 
%   Detailed explanation goes here
%
% USAGE:
%   [ train_data_norm, test_data_norm ] = lfp_tfa_decode_normalize_data(...
%   train_data, test_data, normalization )
%
% INOUTS: 
%   train_data      - unnormalized train data (ntrainsamples x nfeatures)
%   test_data       - unnormalized train data (ntestsamples x nfeatures)
%   normalization   - type of normalization to be applied. Can be 'minmax
%   or 'zscore' 
%       'minmax'    - normalized = (unnormalized - train_min) / (trian_max
%       - train_min). i.e., each feature in train data gets normalized
%       between 0 and 1
%       'zscore'    - normalized = (unnormalized - train_mean) /
%       (trian_std)
% OUTPUTS:
%   train_data_norm - normalized train data (ntrainsamples x nfeatures)
%   test_data_norm  - normalized train data (ntestsamples x nfeatures)

switch(normalization)
    case 'minmax'
        train_min = min(train_data);
        train_max = max(train_data);
        train_data_norm = (train_data - ...
            repmat(train_min, size(train_data, 1), 1)) ./ ...
            repmat(train_max - train_min, size(train_data, 1), 1);
        test_data_norm = (test_data - ...
            repmat(train_min, size(test_data, 1), 1)) ./ ...
            repmat(train_max - train_min, size(test_data, 1), 1);
    case 'zscore'
        train_mean = mean(train_data);
        train_std = std(train_data);
        train_data_norm = (train_data - ...
            repmat(train_mean, size(train_data, 1), 1)) ./ ...
            repmat(train_std, size(train_data, 1), 1);
        test_data_norm = (test_data - ...
            repmat(train_mean, size(test_data, 1), 1)) ./ ...
            repmat(train_std, size(test_data, 1), 1);
end

end

