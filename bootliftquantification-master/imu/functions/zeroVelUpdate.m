function cVel = zeroVelUpdate(velocity, accel, time, stanceTimes, plotB,plotColor,stanceFig)
    cVel = velocity;
    %cVel = lowPassButter(velocity,10,128,6);
    samp = time(2) - time(1);
    for k=2:length(stanceTimes)-1
        %if k ~= 1 && k ~= length(stanceTimes)
       
        
        startIndex = min(find(stanceTimes(k,1)>=(time) & stanceTimes(k,1)<=(time))); %toe strike
        endIndex = max(find(stanceTimes(k,2)>=(time) & stanceTimes(k,2)<=(time))); %heel off 
        if k == length(stanceTimes)
            nextIndex = length(time);
        else
            nextIndex = min(find(stanceTimes(k+1,1)>=(time-samp) & stanceTimes(k+1,1)<=(time+samp)));%next heel strike
        end
        accel = lowPassButter(accel,2,128,5);
        ephase = accel(endIndex-20:endIndex+30);
        %[val,eoffset]=max(diff(ephase));
        %endIndex = endIndex-20-1+eoffset;
        [val,eoffset]=min(ephase);
        %[val, eoffset] = min(abs(accel(endIndex-5:endIndex+20)));
        endIndex = endIndex-20-1+eoffset;
        %{
        sphase = cVel(startIndex-25:startIndex+50);
        [val,soffset]=min(sphase);
        startIndex = startIndex+soffset;
        %}
        
        toeStrike = startIndex;
        heelOff = endIndex;
        len = heelOff-toeStrike;

        
        
        
        %we shoud reupdate the stance phase since now we have a better
        %estimate of the velocity and only start integrating from heeloff
        %stepSegment = velocity(startIndex:nextIndex);
        %figure(201)
        %nvelThres = threshold(stepSegment, 0.1); %threshold to find new stance times
        %cVelA = diff(cVel(endIndex:endIndex+100))>0;
        

        
        midStanceS =floor(mean(heelOff,toeStrike)-.125*(len));
        midStance = floor(mean(heelOff,toeStrike));
        midStanceE =floor(mean(heelOff,toeStrike)+.125*(len));
        %velAvg = mean(cVel(startIndex:endIndex));
        %velAvg = mean(cVel(midStanceS:midStanceE)); %middle 50% of stance 
        velAvg = cVel(endIndex);
        
        %plot the new stance regions
                
%         figure(stanceFig)
%         hold on
%         thresh=0.3;
%         r1=patch([time(startIndex),time(startIndex),time(endIndex),time(endIndex)],[-thresh,thresh,thresh,-thresh],plotColor);
%         alpha(r1,0.5)
        
        sInt = endIndex;

        for v=startIndex:nextIndex
            if v <= endIndex
                cVel(v) = cVel(v) - velAvg;
            else
                %cVel(v) = cVel(v) - velAvg;
                cVel(v) = cVel(v) - (time(v)-time(nextIndex))/(time(endIndex)-time(nextIndex)) .* velAvg;
            end
        end
        %cVel(startIndex:nextIndex) = cVel(startIndex:nextIndex) - velTemp;
        figure(k)
        set(gcf, 'Position',  [0, 0, 900, 600])
        hold on
        titleStr = horzcat('Step ',num2str(k));
        
        %%% After we do the first correction, we might want to recalculate
        %%% the end of stance by looking at the minimum velocity. This
        %%% should help alleviate the noise causing a negative integration,
        %%% causing false values. This makes the assumption that during
        %%% stance, the SS is perfectly flat (reasonable?)
        
        %%% To do this, look for min(cVel), +/- 30? values from the
        %%% previously calculated end stance
        [a0,b0]=min(abs(diff(cVel(sInt:sInt+50)))); 
        [a1,b1]= min(cVel(sInt:sInt+50));
        if b1 > b0; b=b1;end
        if b0>b1;b=b0;elseif b0==b1; b=b0;end
        sInt = sInt+b;
        %cVel = cVel-cVel(sInt);
        cVel(sInt:nextIndex) = cVel(sInt:nextIndex) - cVel(sInt);
        %disp(b)
%         if strcmp(plotColor,'red')
%            disp('ss') 
%         end
        
        if plotB
            %midStance=endIndex;
            nextIndex = sInt + 100;
            cVelHP = highPassButter(cVel,0.05,128,5);
            pos=cumtrapz(time(sInt:nextIndex),cVel(sInt:nextIndex))*100;
            %pos = highPassButter(pos, 1/10, 1/samp, 5);
            %plot(time(startIndex:endIndex),cumtrapz(time(startIndex:endIndex),cVel(startIndex:endIndex)))
            subplot(2,3,1)
            hold on
            plot(time(sInt:nextIndex),pos,'Color', plotColor,'LineStyle','-','LineWidth',2)
            %plot(time(toeStrike),0,'^')
            %plot(time(midStance),0,'^')
            plot(time(sInt),0,'^','Color',plotColor)
            ylim([-0.25,3])
            xlim([time(sInt-30), time(sInt+50)])
            %title(horzcat(titleStr,' IMU Position'))
            set(gca,'FontSize',16)
            %xlabel('time(s)')
            %ylabel('vertical position (cm)')
            
           
            subplot(2,3,4)
            hold on
            plot(time(sInt:nextIndex),cVel(sInt:nextIndex),'Color', plotColor,'LineStyle','-','LineWidth',2)
            %plot(time(toeStrike),0,'^')
            %plot(time(midStance),0,'^')
            %plot(time(heelOff),0,'^')
            plot(time(sInt),0,'^','Color',plotColor)
            ylim([-0.25,1])
            xlim([time(sInt-30), time(sInt+50)])
            %title(horzcat(titleStr,' IMU Vert Velocity'))
            set(gca,'FontSize',16)
            %xlabel('time(s)')
            %ylabel('vertical position (cm)')
            %{
            if(k == length(stanceTimes)-1)
                startIndex = find(stanceTimes(k+1,1)==time);
                endIndex = find(stanceTimes(k+1,2)==time);
                velAvg = mean(cVel(startIndex:endIndex));
                cVel(startIndex:nextIndex) = cVel(startIndex:nextIndex) - velAvg;
            end
            %}
        end
        %end
    end
 
end