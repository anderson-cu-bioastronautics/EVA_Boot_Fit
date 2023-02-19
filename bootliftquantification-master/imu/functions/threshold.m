function logicalIndexes = threshold(inputSig, threshold)
% THRESHOLD identifies points in a signal which are between the positive
% and negative threshold value
%
%   valInds = threshold(inputSig, threshold) returns the indices of values in
%   the input signal (inputSig) which lie the positive and negative values of
%   the threshold
%


logicalIndexes = (inputSig<threshold) & (inputSig>-threshold);


end
