function stanceTimes = zeroAccelThres(accel,time, thresh, plotB, plotColor)
    % Elements that meet threshold requirement
    %thresh = 0.5;
    accelThres = threshold(accel, thresh);
    vd = diff([0 accelThres' 0]); %the 0s ensure that there's always a pair of [+1 -1] in the diff
    starts = find(vd == 1);
    ends = find(vd == -1); 
    [longest_streak, idx] = max(ends-starts);
    

    stanceTimes = [time(starts(idx)), time(ends(idx)-1)];
    
    
    
%{
    %% Streak
    % Get the times of threshold elements and get rid of zeros
    timeThresh = nonzeros(accelThres.*time);
    
    % Find the difference in each time in 'timeThresh' element
    delta_t = diff(timeThresh);
    
    % Find the elements where the difference in time is greater than a
    % specified threshold, 'diffThresh'.
    diffThresh = 0.1;
    elements = nonzeros(find(delta_t>diffThresh))+1;

    % Find the start and end times of each zero-acceleration block
    times = zeros(length(elements),3);
    previousElem = 1;
    for i=1:length(elements)
        currentElem = elements(i)-1;
        times(i,1) = timeThresh(previousElem);
        times(i,2) = timeThresh(currentElem);
        times(i,3) = times(i,2)-times(i,1);
        previousElem = currentElem+1;
    end

    % If the time of each zero-accel block is less than the specified
    % threshold, get rid of it 
    blockThresh = 0.33;
    counter = 0;
    for j=1:length(times)
        if(times(j,3) > blockThresh)
            counter = counter + 1;
            stanceTimes(counter,:) = times(j,1:2);      
        end
    end
    
    %add padding to detection
    for l = 1:length(stanceTimes)
        pad = 0.125*(stanceTimes(l,2)-stanceTimes(l,1));
        stanceTimes(l,1) = stanceTimes(l,1)+pad/2;
        stanceTimes(l,2) = stanceTimes(l,2)-pad/2;
    end
    
    
    if plotB == 1
        figure(101)
        plot(time, accel,'Color', plotColor,'LineStyle','-', 'LineWidth', 1.2)%plot signal
        hold on
        %{
        for l=1:length(stanceTimes)
            r=patch([stanceTimes(l,1),stanceTimes(l,1),stanceTimes(l,2),stanceTimes(l,2)],[-thresh,thresh,thresh,-thresh],plotColor);
            alpha(r,0.5)
        end
        %}
        for i=1:length(accel)
           if accelThres(i) == 1
               %plot(time(i), accel(i), 'ro')
           end
        end
        title('Highlighted Stance Phase','FontSize',16)
        xlabel('Time','FontSize',16)
        ylabel('Acceleration (x) [m/s^2]','FontSize',16)
        xlim([0,12])
        ylim([-6,6])
    end
%}
end

%{
%clc; clear;

%load('matlab.mat')
%hrtib = IMUs(6);
hrtibA = hrtib.accel(:,1);
hrtibAF = lowPassButter(hrtibA, 60, SC.sampleRate, 6); %low pass filtered

% Elements that meet threshold requirement
    thresh = 0.1;
    hrtibThres = threshold(hrtibAF, thresh);

%% Streak
% Get the times of threshold elements and get rid of zeros
    timeThresh = nonzeros(hrtibThres.*hrtib.time);
    
% Find the difference in each time in 'timeThresh' element
    delta_t = diff(timeThresh);
    
% Find the elements where the difference in time is greater than a
% specified threshold, 'diffThresh'.
    diffThresh = 0.1;
    elements = nonzeros(find(delta_t>diffThresh))+1;

% Find the start and end times of each zero-acceleration block
    times = zeros(length(elements),3);
    previousElem = 1;
    for i=1:length(elements)
        currentElem = elements(i)-1;
        times(i,1) = timeThresh(previousElem);
        times(i,2) = timeThresh(currentElem);
        times(i,3) = times(i,2)-times(i,1);
        previousElem = currentElem+1;
    end

% If the time of each zero-accel block is less than the specified
% threshold, get rid of it 
    blockThresh = 0.25;
    counter = 0;
    for j=1:length(times)
        if(times(j,3) > blockThresh)
            counter = counter + 1;
            newTimes(counter,:) = times(j,1:2);      
        end
    end

%% Integrate to find Velocity
velocity = cumsimpsum(hrtibAF);
newVel = velocity;
for k=1:length(newTimes)-1
    startIndex = find(newTimes(k,1)==hrtib.time);
    endIndex = find(newTimes(k,2)==hrtib.time);
    nextIndex = find(newTimes(k+1,1)==hrtib.time);
    velTemp = mean(newVel(startIndex:endIndex));
    newVel(startIndex:nextIndex) = newVel(startIndex:nextIndex) - velTemp;
    figure(k)
    hold on
    titleStr = horzcat('Step ',num2str(k));
    
    plot(hrtib.time(startIndex:nextIndex),cumsimpsum(newVel(startIndex:nextIndex)))
    title(titleStr)
    if(k == length(newTimes)-1)
        startIndex = find(newTimes(k+1,1)==hrtib.time);
        endIndex = find(newTimes(k+1,2)==hrtib.time);
        velTemp = mean(newVel(startIndex:endIndex));
        newVel(startIndex:end) = newVel(startIndex:end) - velTemp;
    end
        
end
figure(20)
plot(hrtib.time,velocity,'LineWidth',2)
hold on;
plot(hrtib.time,newVel,'LineWidth',2)
legend('Before Zero-Velocity Check','After Zero-Velocity Check')

pos_zeroVel = cumsimpsum(newVel);
pos_old = cumsimpsum(velocity);

figure(21)
plot(hrtib.time,pos_old,'LineWidth',2)
hold on;
plot(hrtib.time,pos_zeroVel,'LineWidth',2)
legend('Before Zero-Velocity Check','After Zero-Velocity Check')
%%  plotting
figure
hold on
for l=1:length(newTimes)
    rectangle('Position',[newTimes(l,1),-2,newTimes(l,2)-newTimes(l,1),4],'FaceColor','y')
end
plot(hrtib.time, hrtibAF,'b-')%filter signal
for i=1:length(hrtibAF)
   if hrtibThres(i) == 1
       plot(hrtib.time(i), hrtibAF(i), 'ro')
   end
end
title('Highlighted Stance - Right Tibia','FontSize',16)
xlabel('Time','FontSize',16)
ylabel('Acceleration (x) [m/s^2]','FontSize',16)
%}

