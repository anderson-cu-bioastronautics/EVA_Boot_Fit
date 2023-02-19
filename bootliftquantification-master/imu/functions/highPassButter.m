function outputSignal = highPassButter(inputSignal, fc, fs, order)
% HIGHPASSBUTTER filter signal with a high pass butterworth filter
%    outputSignal = highPassButter(inputSignal, cutoffFrequency, samplingFrequency, order)
fc = fc/(2*pi);
fs = fs/(2*pi);
[b,a] = butter(order,fc/(fs/2),'high'); % Butterworth filter of order 6
outputSignal = filtfilt(b,a,inputSignal); % Will be the filtered signal
end