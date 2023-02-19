function main(subject, config,t,side,plotB)
close all
% Change default axes fonts.

%(0,'DefaultAxesFontName', 'Helvetica')
%set(0,'DefaultAxesFontSize', 18)


% Change default text fonts.
%set(0,'DefaultTextFontname', 'Helvetica')
%set(0,'DefaultTextFontSize', 18)

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
hrtib_euler = hrtib.euler-hrtib.euler(1,:);
srtib.euler=srtib.eulerFromQuart;
srtib_euler = srtib.euler-srtib.euler(1,:);
% eulerInd = 3;
% hrtib_eulero = hrtib_euler(:,eulerInd);
% srtib_eulero = srtib_euler(:,eulerInd);
% for i =1:length(hrtib_eulero)-1
% if abs(hrtib_eulero(i+1)-hrtib_eulero(i))>pi
% hrtib_eulero(i+1)=hrtib_eulero(i+1)+2*pi;
% end
% end
% 
% for i =1:length(srtib_eulero)-1
% if abs(srtib_eulero(i+1)-srtib_eulero(i))>pi
% srtib_eulero(i+1)=srtib_eulero(i+1)+2*pi;
% end
% end

vertAngH = -hsign*devVert(hrtib.invquart);
vertAngH = vertAngH-vertAngH(1);
vertAngS = -ssign*devVert(srtib.invquart);
vertAngS = vertAngS-vertAngS(1);

%Filter all
hrtib_time = hrtib.time;
srtib_time = srtib.time;
hrtib_accelX = hsign*hrtib.accel(:,1);
hrtib_euler = hsign*hrtib.euler;
%hrtib_accelX = highPassButter(-hrtib.accel(:,1), 1/10, hrtib.sampleRate, 6); %low pass filtered
srtib_accelX = ssign*srtib.accel(:,1);
srtib_euler = ssign*srtib.euler;
%srtib_accelX = highPassButter(-srtib.accel(:,1), 1/10, hrtib.sampleRate, 6); %low pass filtered

% %Downsample all
% downsampleFactor = 6;
% hrtib_timeF = downsample(hrtib.time,downsampleFactor);
% srtib_timeF = downsample(srtib.time,downsampleFactor);
% 
% hrtib_accelXF = downsample(hrtib_accelX,downsampleFactor);
% srtib_accelXF = downsample(srtib_accelX,downsampleFactor);


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
%hrtib_vel = highPassButter(hrtib_vel,0.7,hrtib.sampleRate,5);
%srtib_vel = highPassButter(srtib_vel,0.7,srtib.sampleRate,5);


hrtib_accelXSmooth = smooth(hrtib_accelX, 30);
srtib_accelXSmooth = smooth(srtib_accelX, 30);

%JointAngleVel
hrtibTotalEuler = sqrt(hrtib.euler(:,1).^2+hrtib.euler(:,2).^2+hrtib.euler(:,3).^2); %adding together all Euler angles to get total
hrtibTotalEulerF = lowPassButter(hrtibTotalEuler, 50, hrtib.sampleRate, 6);

hrtibTotalAVF = diff(hrtibTotalEulerF)./diff(hrtib.time); %get total angular velocity of the segment (filtered)
hrtibTotalAV = diff(hrtibTotalEuler)./diff(hrtib.time); %get total angular velocity of the segment (not-filtered)
HJTime = hrtib.time(2:end); %take out the first value of time since diff has one less value

srtibTotalEuler = sqrt(srtib.euler(:,1).^2+srtib.euler(:,2).^2+srtib.euler(:,3).^2); %adding together all Euler angles to get total
srtibTotalEulerF = lowPassButter(srtibTotalEuler, 50, srtib.sampleRate, 6);

srtibTotalAVF = diff(srtibTotalEulerF)./diff(srtib.time); %get total angular velocity of the segment (filtered)
srtibTotalAV = diff(srtibTotalEuler)./diff(srtib.time); %get total angular velocity of the segment (not-filtered)
SJTime = srtib.time(2:end); %take out the first value of time since diff has one less value

%sacrum = tname{1,1}{1,1};
%hlt = tname{1,1}{1,2};
figure(222);
hsi = segmentSteps(hrtib_accelXF3,smooth(vertAngH,5), hrtib_time, hrtib.sampleRate, blue);
ssi = segmentSteps(srtib_accelXF3,smooth(vertAngS,5), srtib_time, srtib.sampleRate,red);

%hrtib_accelXF = lowPassButter(hrtib_accelXF, 8, hrtib.sampleRate/downsampleFactor, 6); %low pass filtered
%srtib_accelXF = lowPassButter(srtib_accelXF, 8, hrtib.sampleRate/downsampleFactor, 6); %low pass filtered
stanceFig = figure(101);

HstanceTimes = zeros(length(hsi), 2);
SstanceTimes = zeros(length(hsi), 2);

if length(hsi)>length(ssi)
   hsi=ssi;
elseif length(ssi)>length(hsi)
   ssi=hsi;
end

if length(hsi)==length(ssi)
    for step=1:length(hsi)
        Shrtib_accelXSeg=hrtib_accelXSmooth(hsi(step,1):hsi(step,2));
        Shrtib_time=hrtib_time(hsi(step,1):hsi(step,2));
        Ssrtib_accelXSeg=srtib_accelXSmooth(ssi(step,1):ssi(step,2));
        Ssrtib_time=srtib_time(ssi(step,1):ssi(step,2));
        thresh=.75;
        SHstanceTimes = zeroAccelThres(Shrtib_accelXSeg, Shrtib_time,thresh,plotB,blue);
        SSstanceTimes =  zeroAccelThres(Ssrtib_accelXSeg, Ssrtib_time,thresh,plotB,red);
        
        HstanceTimes(step,:) = SHstanceTimes;
        SstanceTimes(step,:) = SSstanceTimes;

        
        figure(stanceFig)
        hold on
        x = 0:max(hrtib_time);
        plot(x,-thresh*ones(size(x)),':')
        plot(x,thresh*ones(size(x)),':')
        thresh=6;
        r1=patch([SHstanceTimes(1),SHstanceTimes(1),SHstanceTimes(2),SHstanceTimes(2)],[-thresh,thresh,thresh,-thresh],blue,'EdgeColor','None');
        alpha(r1,0.25)
        r2=patch([SSstanceTimes(1),SSstanceTimes(1),SSstanceTimes(2),SSstanceTimes(2)],[-thresh,thresh,thresh,-thresh],red,'EdgeColor','None');
        alpha(r2,0.25)

        
        %{
        figure()
        hold on
        stepHA = hrtib_accelX(hsi(step,1):hsi(step,2));
        stepSA = srtib_accelX(ssi(step,1):ssi(step,2));
        HcVel = zeroVelUpdate(cumtrapz(Shrtib_time,stepHA), hrtib_time,HstanceTimes,plotB,'blue');
        ScVel = zeroVelUpdate(cumtrapz(Ssrtib_time,stepSA), srtib_time,SstanceTimes,plotB,'red');
        
        plot(Shrtib_time, cumtrapz(Shrtib_time,HcVel))
        plot(Ssrtib_time, cumtrapz(Ssrtib_time,ScVel))
        title(sprintf('Step %d',step))
        %}
    
        %end
        %plot(hrtib_timeF, hrtib_accelXF)
        %plot(srtib_timeF, srtib_accelXF)
    end


    if ~all(HstanceTimes,'all') && ~all(SstanceTimes,'all')
        print('No Stance Phases Detected')
    end

    saveStr = sprintf('Subject%d Config%d Trial%d %s Stance Phases',subject,config,t,side);


    figure(stanceFig)
    hold on
    plot(hrtib_time,hrtib_accelXF3,'LineWidth',4,'Color',blue)
    plot(srtib_time, srtib_accelXF3,'LineWidth',4,'Color',red)
    xlim([0,max(hrtib_time)])
    %ylim([-5,5])
    %title(saveStr)

    %{
    %zero accel thresholding
    thresh=0.35;
    HstanceTimes = zeroAccelThres(hrtib_accelXF2, hrtib_time,thresh,plotB,'blue');
    SstanceTimes =  zeroAccelThres(srtib_accelXF2, srtib_time,thresh,plotB,'red');

    [HstanceTimes, SstanceTimes] = correlateStanceTimes(HstanceTimes, SstanceTimes);
    figure(101)
    for l=1:length(HstanceTimes)
        r1=patch([HstanceTimes(l,1),HstanceTimes(l,1),HstanceTimes(l,2),HstanceTimes(l,2)],[-thresh,thresh,thresh,-thresh],'blue');
        alpha(r1,0.5)
        r2=patch([SstanceTimes(l,1),SstanceTimes(l,1),SstanceTimes(l,2),SstanceTimes(l,2)],[-thresh,thresh,thresh,-thresh],'red');
        alpha(r2,0.5)
    end
    saveStr = sprintf('Subject%dConfig%dTrial%d_aPhases%s',subject,config,t,side);
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','normalized');
    set(gcf,'PaperPosition', [0 0 1 1]);
    saveas(gcf,horzcat('figs/',saveStr,'.pdf'))


    xlim([-1,12])
    legend('Human Vertical Acceleration','Suit Vertical Acceleration', 'Human Stance', 'Suit Stance')
    %}

    %zero velocity update
    HcVel = zeroVelUpdate(hrtib_vel, hrtib_accelXF3, hrtib_time,HstanceTimes,plotB,blue,stanceFig);
    ScVel = zeroVelUpdate(srtib_vel, srtib_accelXF3, srtib_time,SstanceTimes,plotB,red,stanceFig);
    plotSS_Human_Diff(subject,config,t,side)
    %HcVel = highPassButter(cumtrapz(hrtib_time, hrtib_accelX),1/1.5,hrtib.sampleRate,6);
    %ScVel = highPassButter(cumtrapz(srtib_time, srtib_accelX),1/1.5,srtib.sampleRate,6);


    figure(201);
    set(gca,'DefaultLineLineWidth',2)

    plot(hrtib_time, HcVel, '-','LineWidth',4,'Color',blue)
    hold on
    plot(hrtib_time, hrtib_velo, ':','LineWidth',4,'Color',blue)
    plot(srtib_time, ScVel, '-','LineWidth',4,'Color',red)
    plot(srtib_time, srtib_velo, ':','LineWidth',4,'Color',red)
    set(gca,'FontSize',14)
    %legend('Human Vertical Vel Corrected', 'Human Vertical Vel Uncorrected', 'Suit Vertical Vel Corrected', 'Suit Vertical Vel Uncorrected')
    %xlabel('time (s)')
    %ylabel('m/s')
    xlim([0,12])
    grid on

    xlim([-1,12])
    saveStr = sprintf('Subject%dConfig%dTrial%d_bVel%s',subject,config,t,side);
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','normalized');
    set(gcf,'PaperPosition', [0 0 1 1]);
    saveas(gcf,horzcat('figs/',saveStr,'.pdf'))
end
end