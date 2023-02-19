function outputSignal = lowPassButter(inputSignal, fc, fs, order)
% LOWPASSBUTTER filter signal with a low pass butterworth filter
%    outputSignal = lowPassButter(inputSignal, cutoffFrequency, samplingFrequency, order)

[b,a] = butter(order,fc/(fs/2),'low'); % Butterworth filter of order 6
outputSignal = filtfilt(b,a,inputSignal); % Will be the filtered signal
end

