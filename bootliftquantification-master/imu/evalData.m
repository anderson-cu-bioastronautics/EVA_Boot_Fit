function evalData(subject, config,t,side)
close all
% Change default axes fonts.

%(0,'DefaultAxesFontName', 'Helvetica')
%set(0,'DefaultAxesFontSize', 18)


% Change default text fonts.
%set(0,'DefaultTextFontname', 'Helvetica')
%set(0,'DefaultTextFontSize', 18)
set(0,'DefaultLineLineWidth',2)
load('params.mat');

green = [129 190 161]/255;
blue = [54 134 160]/255; 
red = [188 39 49]/255;

%Add functions subfolder to Path
subfolders = split(genpath(pwd),';');
for sf = 1:length(subfolders)
    if endsWith(subfolders{sf},'functions')
       addpath(subfolders{sf}) 
    end
end

addpath(genpath(pwd)); %add all subfolders to path

varName = strcat('S',string(subject),'C',string(config),'T',string(t));
saveDir = strcat('Z:\ResearchData\NRI Study Data - Shared\IMU Data Processed\Subject',string(subject),'\','S',string(subject),'C',string(config),'T',string(t),'.mat');
tname = load(char(saveDir));
tname = struct2cell(tname);




if side == 'r'
    hTibI = params(subject,config+1,1);
    srTibI = params(subject,config+1,2);
    hrtib = tname{1,1}{1,hTibI};
    srtib = tname{1,1}{1,srTibI};
elseif side == 'l'
    hTibI = params(subject,config+1,3);
    srTibI = params(subject,config+1,4);
    hrtib =tname{1,1}{1,hTibI};
    srtib = tname{1,1}{1,srTibI};
end

if subject == 4 && config == 2 && strcmp(side,'l')
    hTibI = params(subject,config+1,1);
    srTibI = params(subject,config+1,4);
    hrtib =tname{1,1}{1,hTibI};
    srtib = tname{1,1}{1,srTibI};
elseif subject == 4 && config == 2 && strcmp(side,'r')
    hTibI = params(subject,config+1,3);
    srTibI = params(subject,config+1,2);
    hrtib = tname{1,1}{1,hTibI};
    srtib = tname{1,1}{1,srTibI};
end

hsign = params(subject,config+1, 5);
ssign = params(subject,config+1, 6);

if subject == 4 && config == 0 && strcmp(side,'l')
    hsign = -hsign;
    
end

if subject == 4 && config == 1 && strcmp(side, 'l')
    hsign = -hsign;
    
end

hrtib.euler = hrtib.eulerFromQuart;
srtib.euler=srtib.eulerFromQuart;

vertAngH = -hsign*devVert(hrtib.invquart);
vertAngH = vertAngH-vertAngH(1);
vertAngS = -ssign*devVert(srtib.invquart);
vertAngS = vertAngS-vertAngS(1);

%Filter all
hrtib_time = hrtib.time;
srtib_time = srtib.time;
hrtib_accelX = hsign*hrtib.accel(:,1);
hrtib_euler = hsign*hrtib.euler;
hrtib_euler = hrtib_euler-hrtib_euler(1,:);
%hrtib_accelX = highPassButter(-hrtib.accel(:,1), 1/10, hrtib.sampleRate, 6); %low pass filtered
srtib_accelX = ssign*srtib.accel(:,1);
srtib_euler = ssign*srtib.euler;
strib_euler = srtib_euler-srtib_euler(1,:);
%srtib_accelX = highPassButter(-srtib.accel(:,1), 1/10, hrtib.sampleRate, 6); %low pass filtered

eulerInd = 3;
hrtib_eulero = hrtib_euler(:,eulerInd);
srtib_eulero = srtib_euler(:,eulerInd);

% 
% for i =1:length(hrtib_eulero)-1
%     if abs(hrtib_eulero(i+1)-hrtib_eulero(i))>pi
%         if (abs(hrtib_eulero(i))-abs(hrtib_eulero(i+1)))<pi/8
%             hrtib_eulero(i+1:end)=-hrtib_eulero(i+1:end);
%         else
%         hrtib_eulero(i+1)=2*pi-abs(hrtib_eulero(i+1));
%         end
%     end
% end
% 
% for i =1:length(srtib_eulero)-1
%     if abs(srtib_eulero(i+1)-srtib_eulero(i))>pi
%         if (abs(srtib_eulero(i))-abs(srtib_eulero(i+1)))<pi/8
%             srtib_eulero(i+1:end)=-srtib_eulero(i+1:end);
%         else
%             srtib_eulero(i+1)=srtib_eulero(i+1)+2*pi;
%         end
%     end
% % end
% 
% hrtib_eulerF = smooth(hrtib_euler(:,eulerInd),50);
% srtib_eulerF = smooth(srtib_euler(:,eulerInd),50);

fs = hrtib.sampleRate;
hrtibF = fftshift(hrtib_accelX);
srtibF = fftshift(srtib_accelX);

nH = length(hrtibF);          % number of samples
nS = length(srtibF);
fH = (-nH/2:nH/2-1)*(fs/nH);     % frequency range
fS = (-nS/2:nS/2-1)*(fs/nS); 
powerH = abs(hrtibF).^2/nH;    % power of the DFT
powerS = abs(srtibF).^2/nS;


hrtib_accelXF2 = lowPassButter(hrtib_accelX,10,hrtib.sampleRate,5);
srtib_accelXF2 = lowPassButter(srtib_accelX,10,srtib.sampleRate,5);
hrtib_velo = cumtrapz(hrtib_time,hrtib_accelXF2);
srtib_velo = cumtrapz(srtib_time,srtib_accelXF2);
%hrtib_vel = highPassButter(cumtrapz(hrtib_time,hrtib_accelXF2),1/5,hrtib.sampleRate,5);
%srtib_vel = highPassButter(cumtrapz(srtib_time,srtib_accelXF2),1/5,srtib.sampleRate,5);
hrtib_accelXF3 = highPassButter(hrtib_accelXF2,0.7,hrtib.sampleRate,5);
srtib_accelXF3 = highPassButter(srtib_accelXF2,0.7,srtib.sampleRate,5);
hrtib_vel = cumtrapz(hrtib_time,hrtib_accelXF3);
srtib_vel = cumtrapz(srtib_time,srtib_accelXF3);
hrtib_vel = highPassButter(hrtib_vel,0.7,hrtib.sampleRate,5);
srtib_vel = highPassButter(srtib_vel,0.7,srtib.sampleRate,5);

LhrtibF = fftshift(hrtib_accelXF2);
LsrtibF = fftshift(srtib_accelXF2);

LnH = length(LhrtibF);          % number of samples
LnS = length(LsrtibF);
LfH = (-LnH/2:LnH/2-1)*(fs/LnH);     % frequency range
LfS = (-LnS/2:LnS/2-1)*(fs/LnS);
LpowerH = abs(LhrtibF).^2/LnH;    % power of the DFT
LpowerS = abs(LsrtibF).^2/LnS;


% DDI
hrtib_time2 = hrtib_time(2:end-1);
srtib_time2 = srtib_time(2:end-1);

hrtib_velDDI = cumtrapz(hrtib_time2,cumtrapz(hrtib_time2,diff(diff(hrtib_velo))));
srtib_velDDI = cumtrapz(srtib_time2,cumtrapz(srtib_time2,diff(diff(srtib_velo))));


%%Figures

figure();
plot(hrtib_time, hrtib_accelX,'Color', blue)
hold on
plot(srtib_time, srtib_accelX,'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('m/s^2')
title('Tibia Vertical Acceleration')
grid on

figure();
plot(fH,powerH,'Color',blue);
hold on
plot(fS,powerS,'Color',red);
xlabel('Frequency')
ylabel('Power')
title('Power Spectral Analysis of Vertical Acceleration')
legend('human','spacesuit')
grid on

figure();
plot(LfH,LpowerH,'Color',blue);
hold on
plot(LfS,LpowerS,'Color',red);
xlabel('Frequency')
ylabel('Power')
title('Power Spectral Analysis of LPF Vertical Acceleration')
legend('human','spacesuit')
grid on

figure();
plot(hrtib_time, hrtib_accelXF2,'Color', blue)
hold on
plot(srtib_time, srtib_accelXF2,'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('m/s^2')
title('Tibia Vertical Acceleration - Low Pass Filtered')
grid on

figure();
plot(hrtib_time, hrtib_vel,'Color', blue)
hold on
plot(srtib_time, srtib_vel,'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('m/s')
title('Tibia Vertical Velocity')
grid on

figure();
plot(hrtib_time2, hrtib_velDDI,'Color', blue)
hold on
plot(srtib_time2, srtib_velDDI,'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('m/s')
title('Tibia Vertical Velocity - DDI')
grid on

vertAngH = rad2deg(vertAngH);
vertAngS = rad2deg(vertAngS);

figure();
plot(hrtib_time, vertAngH,'Color', blue)
hold on
plot(srtib_time, vertAngS,'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('deg')
title('IMU Pitch Angle')
grid on


figure();
plot(hrtib_time, smooth(vertAngH,10),'Color', blue)
hold on
plot(srtib_time, smooth(vertAngS,10),'Color', red)
legend('human','spacesuit')
xlabel('time (s)')
ylabel('deg')
title('IMU Pitch Angle - Moving Average')
grid on

figure();
plot(hrtib_time, vertAngS-vertAngH,'Color', blue)
legend('spacesuit human difference')
ylabel('deg')
title('IMU Pitch Angle')
grid on

end
