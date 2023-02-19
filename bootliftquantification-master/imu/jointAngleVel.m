subject=3;config=0;t=1;side='l';
close all
%Add functions subfolder to Path
subfolders = split(genpath(pwd),';');
for sf = 1:length(subfolders)
    if endsWith(subfolders{sf},'functions')
       addpath(subfolders{sf}) 
    end
end

addpath(genpath(pwd)); %add all subfolders to path

varName = strcat('S',string(subject),'C',string(config),'T',string(t));
saveDir = strcat('Data\Subject',string(subject),'\','S',string(subject),'C',string(config),'T',string(t),'.mat');
tname = load(char(saveDir));
tname = struct2cell(tname);




if side == 'r'
    hrtib = tname{1,1}{1,4};
    srtib = tname{1,1}{1,6};
elseif side == 'l'
    hrtib = tname{1,1}{1,8};
    srtib = tname{1,1}{1,10};
end

hrtibTotalEuler = sqrt(hrtib.euler(:,1).^2+hrtib.euler(:,2).^2+hrtib.euler(:,3).^2); %adding together all Euler angles to get total
hrtibTotalEulerF = lowPassButter(hrtibTotalEuler, 50, hrtib.sampleRate, 6);

hrtibTotalAVF = diff(hrtibTotalEulerF)./diff(hrtib.time); %get total angular velocity of the segment (filtered)
hrtibTotalAV = diff(hrtibTotalEuler)./diff(hrtib.time); %get total angular velocity of the segment (not-filtered)
dTime = hrtib.time(2:end); %take out the first value of time since diff has one less value

%plotting
figure
plot(dTime, hrtibTotalAV,'g--')
title('Right Tibia Joint Angular Velocity')
xlabel('time')
ylabel('rad/s')
hold on
plot(dTime, hrtibTotalAVF,'b-')
logicalIndexes = threshold(hrtibTotalAVF, 0.35); %get values between -1.5 and 1.5 rad/s
for i=1:length(hrtibTotalAV)
    if logicalIndexes(i) == 1
        plot(dTime(i), hrtibTotalAVF(i), 'ro')
    end
end

