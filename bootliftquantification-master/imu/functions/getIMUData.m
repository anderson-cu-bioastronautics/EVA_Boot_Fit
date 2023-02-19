function [newIMU] = getIMUData(SC)
% GETIMUDATA retrieve and reformat IMU data
%   newIMU = getIMUData(IMUTrial)
    time = SC.time;
    %accel = [SC.axd,SC.ayd,SC.azd];
    accel = SC.removeGravity;
    quart = SC.qAPDM;
    
    newIMU = IMUData;
    newIMU.name = SC.label;
    newIMU.accel = accel;
    newIMU.time = time;
    newIMU.quart = quart;
    newIMU.invquart = quatinv(quart);
    newIMU.euler = SC.eulerAPDM;
    newIMU.eulerFromQuart = quart2euler(quart);
    newIMU.eulerFromQuartInv = quart2euler(newIMU.invquart);
    newIMU.sampleRate = SC.sampleRate;
    %newIMU.pos = getPosition(time,accel);
end