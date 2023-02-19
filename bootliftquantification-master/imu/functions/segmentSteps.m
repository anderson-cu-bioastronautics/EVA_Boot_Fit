function idx = segmentSteps(accel,euler, time,sampleRate,plotColor)
    euler = euler-euler(1);
    [pks,locs] = findpeaks(euler,'MinPeakDistance',1.5*sampleRate);
    %[pks1,locs1]=findpeaks(euler,'MinPeakDistance',sampleRate*3/5,'MinPeakProminence',0.05);
    %[pks2,locs2]=findpeaks(euler,'MinPeakDistance',sampleRate,'MinPeakProminence',0.05);
    %if length(locs1)>length(locs2)
    %pks = pks;locs=locs;
    %else
    %    pks=pks2;locs=locs2;
    %end
    steps = zeros(length(locs)-1,2);
    idx = zeros(length(locs)-1,2);

    for i = 1:length(locs)-1
        steps(i,:) = [time(locs(i)),time(locs(i+1))];
        idx(i,:) = [locs(i),locs(i+1)];
    end
    
    
    figure(222)
    hold on
    plot(time,rad2deg(euler),'Color',plotColor, 'LineWidth', 4)
    xlim([0,max(time)])
    N = length(steps); %numsteps
    vec = 'ymcrgbk';
    clr = [188 39 49
           54 134 160
           56 54 97
           107 78 113
           56 54 97
           188 39 49
           54 134 160
           56 54 97
           107 78 113
           56 54 97
           188 39 49
           54 134 160
           56 54 97
           107 78 113
           56 54 97]/255;
    %clr = vec(randi(numel(vec),N)); %generate random colors for steps
    for i = 1:N
        r1=patch([steps(i,1),steps(i,1),steps(i,2),steps(i,2)],[-10,40,40,-10],clr(i,:));
        alpha(r1,0.25)
        %if strcmp(plotColor,'blue')
        %    r1=patch([steps(i,1),steps(i,1),steps(i,2),steps(i,2)],[0,8,8,0],clr(i));
        %    alpha(r1,0.5)
        %elseif strcmp(plotColor,'red')
        %    r1=patch([steps(i,1),steps(i,1),steps(i,2),steps(i,2)],[-8,0,0,-8],clr(i));
        %    alpha(r1,0.5)
        %end
    end
    xlabel('time (s)')
    ylabel('angle (deg)')
    set(gca,'FontSize',20)

    %text(locs+.02,pks,num2str((1:numel(pks))'))
    


end