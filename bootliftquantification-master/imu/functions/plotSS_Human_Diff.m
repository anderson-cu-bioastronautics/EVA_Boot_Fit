function plotSS_Human_Diff(subject,config,t,side)
figHandles = findobj('Type', 'figure');
lags = zeros(size(figHandles));
meas = zeros(size(figHandles));
ssDriftLim = 5;
for f=1:length(figHandles)
    if figHandles(f).Number < 10
        try
        figure(figHandles(f).Number)
        lines = findobj(subplot(2,3,1), 'Type', 'Line', 'LineStyle', '-');
        vlines = findobj(subplot(2,3,4), 'Type', 'Line', 'LineStyle', '-');
        xLimP = get(findobj(subplot(2,3,1),'Type','Axes'),'XLim');
        xLimV = get(findobj(subplot(2,3,4),'Type','Axes'),'XLim');
        

        %fill(xP, [lines(1).YData
        
        sTime = lines(1).XData;
        sPos = lines(1).YData;
        sV = vlines(1).YData;
        hTime=lines(2).XData;
        hPos=lines(2).YData;
        hV = vlines(2).YData;
        
            if sTime(1) > hTime(1)
                %[~,delay]=min(abs(hTime-sTime(1)));
                delay =  find(lines(2).XData == lines(1).XData(1));
                stanceDelay = sTime(1)-hTime(1);
                hTime = hTime(delay:end);
                hPos = hPos(delay:end);
                hV = hV(delay:end);
                sTime = sTime(1:length(hTime));
                sPos = sPos(1:length(hPos));
                sV = sV(1:length(hV));
                
                color = [129 190 161]/255;
                
                subplot(2,3,1)
                indDelay = find(lines(2).XData == lines(1).XData(1));
                %xP = lines(1).XData(1):lines(1).XData(2)-lines(1).XData(1):lines(1).XData(1+15);
                xP = sTime(1:16);
                xP = [xP, fliplr(xP)];
                inBetween = [lines(1).YData(1:16), fliplr(lines(2).YData(indDelay:indDelay+15))];
                fill(xP, inBetween, color,'facealpha',0.5,'edgecolor','none');
                
                subplot(2,3,4)
                indDelay = find(vlines(2).XData == vlines(1).XData(1));
                xP = vlines(1).XData(1):vlines(1).XData(2)-vlines(1).XData(1):vlines(1).XData(1+15);
                xP = [xP, fliplr(xP)];
                inBetween = [vlines(1).YData(1:length(xP)/2), fliplr(vlines(2).YData(indDelay:indDelay+length(xP)/2 -1))];
                fill(xP, inBetween, color,'facealpha',0.5, 'edgecolor', 'none');
                val = hPos(delay);

                
            else
                [~,delay]=min(abs(sTime-hTime(1)));
                sTime = sTime(delay:delay+ss);
                sPos = sPos(delay:delay+99);
                sV = sV(delay:delay+99);
                hTime = hTime(1:100);
                hPos = hPos(1:100);
                hV = hV(1:100);
                stanceDelay = 0;
                val = hPos(1);
            end

            figure(figHandles(f).Number)
            diff = hPos-sPos;
            %val = %diff(ssDriftLim);%max(diff(1:15));
%             subplot(2,3,2)
%             hold on
%             text(hTime(ind),val,sprintf('%0.5f cm \rightarrow', val))
%             text(hTime(ind), val+2, sprintf('%1.2f s', stanceDelay))
%             plot(hTime,diff,'-')
%             ylim([0,10])
%             title('Vert Pos Difference')
%             xlim(xLimP)
%             
%             vdiff = hV-sV;
%             subplot(2,3,5)
%             hold on
%             plot(hTime,vdiff,'-')
%             ylim([0,10])
%             title('Vert Velocity Difference')
%             xlim(xLimV)
            lags(f) = stanceDelay;
            meas(f) = val;
        catch
        end
        
        saveStr = sprintf('Subject%dConfig%dTrial%d_c%sStep%d',subject,config,t,side,figHandles(f).Number);
        set(gcf,'PaperOrientation','landscape');
        set(gcf,'PaperUnits','normalized');
        set(gcf,'PaperPosition', [0 0 1 1]);
        %saveas(gcf,horzcat('figs/',saveStr,'.pdf'))
        
    end
    
end

if side == 'l'
    s = 1;
elseif side == 'r'
    s = 2;
end

toWriteLags = [subject, config, t, s, lags'];
toWriteMeas = [subject, config, t, s, meas'];

dlmwrite('lags.csv', toWriteLags, '-append')
dlmwrite('meas.csv', toWriteMeas, '-append')

end
