function velf = getVelocity(time,accel)
%% Following code is from https://www.mathworks.com/matlabcentral/answers/166890-double-integration-of-the-acceleration-signals-to-obtain-displacment-signals
    %% Design High Pass Filter
    fs = 127; % Sampling Rate
    fc = 0.1/(127.99/2);  % Cut off Frequency
    order = 6; % 6th Order Filter
    %% Filter  Acceleration Signals
    [b1,a1] = butter(order,fc,'high');
    accf=filtfilt(b1,a1,accel);
    
    %% First Integration (Acceleration - Veloicty)
    velocity=cumtrapz(time,accf);
    
    %% Filter  Veloicty Signals
    [b2,a2] = butter(order,fc,'high');
    velf = filtfilt(b2,a2,velocity);

end