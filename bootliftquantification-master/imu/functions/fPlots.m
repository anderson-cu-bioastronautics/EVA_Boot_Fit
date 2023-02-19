% for inheritance to OpalIMUData()
classdef fPlots < handle % filter plotter class
    properties
    end
    methods % can't be static--otherwise you can't inherit them
        function comp(obj) 
            if ~isa(obj,'OpalIMUData')
              error('Can only pass in OpalIMUData objects');
            end
            numSensors=length(obj);
            for s=1:numSensors
                allQ=getQuats(obj);
                N=numel(allQ);
                q={}; time={};
                for k=1:N
                    q=[q;eval(strcat('obj(s).',allQ{k}))];
                    time=[time;obj(s).time];
                end

                tol=pi*180/180; % tolerance for unwrap (150 deg)

                q_figh=figure('name',obj(s).name);
                %% Quaternion plots
                for k=1:N

                    dq=q{k};    

                    subplot(4,1,1)
                    hold on;
                    plot(time{k},dq(:,1))
                    grid on;
                    ylabel('q0 (scalar)')
                    yl=ylim;
                    hold off;

                    subplot(4,1,2)
                    hold on;
                    plot(time{k},dq(:,2))
                    grid on;
                    ylabel('q1')
                    hold off;

                    subplot(4,1,3)
                    hold on;
                    plot(time{k},dq(:,3))
                    grid on;
                    ylabel('q2')
                    hold off;

                    subplot(4,1,4)
                    hold on;
                    plot(time{k},dq(:,4))
                    grid on;
                    ylabel('q3')
                    hold off;
                    xlabel('time (s)')

                end

                legend(allQ)
%                 tightfig;
                %% raw Euler Angles
                raw_figh=figure('name',obj(s).name);
                subplot(3,1,1)

                for k=1:N
                    x=q{k};
                    % Organizing filter output
                    [r1r,r2r,r3r]=quat2angle(x(:,1:4));
                    r1_raw{k}=r1r; r2_raw{k}=r2r; r3_raw{k}=r3r;
                    % r1_raw{k}=wrapTo2Pi(r1r); r2_raw{k}=wrapTo2Pi(r2r); r3_raw{k}=wrapTo2Pi(r3r);
                    % r1_raw{k}=wrapToPi(r1r); r2_raw{k}=wrapToPi(r2r); r3_raw{k}=wrapToPi(r3r);
                    %% Plotting unwrapped figure
                    % figure1 = figure('position',[50 50 1000 900]);

                    subplot(3,1,1)
                    hold on;
                    plot(time{k},rad2deg(r1_raw{k}))
                    % legend(filterlabel,'APDM')
                    grid on;
                    ylabel('z-rot / U (deg)')
                    yl=ylim;
                    hold off;

                    subplot(3,1,2)
                    hold on;
                    plot(time{k},rad2deg(r2_raw{k}))
                    grid on;
                    ylabel('y-rot / W (deg)')
                    hold off;

                    subplot(3,1,3)
                    hold on;
                    plot(time{k},rad2deg(r3_raw{k}))
                    grid on;
                    ylabel('x-rot / N (deg)')
                    xlabel('time (s)')
                    hold off;
                end
                subplot(3,1,1)
                title('raw plots')
                legend(allQ)

        %         tightfig;


                %% Unwrapped Euler Angles
                UW_figh=figure('name',obj(s).name);
                subplot(3,1,1)

                for k=1:N
                    x=q{k};
                    % Organizing filter output
                    % [r1_raw,r2_raw,r3_raw]=quat2angle(x(:,1:4));
                    all_uw=rad2deg(unwrap([r1_raw{k} r2_raw{k} r3_raw{k}],tol));
                    r1_uw{k}=all_uw(:,1); r2_uw{k}=all_uw(:,2); r3_uw{k}=all_uw(:,3);

                    %% Plotting unwrapped figure
                    % figure1 = figure('position',[50 50 1000 900]);

                    subplot(3,1,1)
                    hold on;
                    plot(time{k},r1_uw{k})
                    % legend(filterlabel,'APDM')
                    grid on;
                    ylabel('z-rot / U (deg)')
                    yl=ylim;
                    hold off;

                    subplot(3,1,2)
                    hold on;
                    plot(time{k},r2_uw{k})
                    grid on;
                    ylabel('y-rot / W (deg)')
                    hold off;

                    subplot(3,1,3)
                    hold on;
                    plot(time{k},r3_uw{k})
                    grid on;
                    ylabel('x-rot / N (deg)')
                    xlabel('time (s)')
                    hold off;
                end
                subplot(3,1,1)
                title('unwrapped plots')
                legend(allQ)

%                 tightfig;

                %% plotting error b/w truth and each dataset (for UW Euler)
                if length(allQ) > 1
                    err_figh=figure('name',obj(s).name);
                    for k=1:N

                        chop_vec=round(linspace(1,length(q{k}),length(q{1}))); % vector to chop down filter points to align with truth data
                    %     ec{k}=[r1_uw{k}(chop_vec) r2_uw{k}(chop_vec) r3_uw{k}(chop_vec)]; % chopped IMU Euler angles

                        r1_uw_err{k}=r1_uw{1}-r1_uw{k}(chop_vec);
                        r2_uw_err{k}=r2_uw{1}-r2_uw{k}(chop_vec);
                        r3_uw_err{k}=r3_uw{1}-r3_uw{k}(chop_vec);

                        %% Plotting error figure
                        % figure1 = figure('position',[50 50 1000 900]);

                        subplot(3,1,1)
                        hold on;
                        plot(time{1},r1_uw_err{k})
                        % legend(filterlabel,'APDM')
                        grid on;
                        ylabel('z-rot / U (deg)')
                        yl=ylim;
                        hold off;

                        subplot(3,1,2)
                        hold on;
                        plot(time{1},r2_uw_err{k})
                        grid on;
                        ylabel('y-rot / W (deg)')
                        hold off;

                        subplot(3,1,3)
                        hold on;
                        plot(time{1},r3_uw_err{k})
                        grid on;
                        ylabel('x-rot / N (deg)')
                        xlabel('time (s)')
                        hold off;
                    end
                    subplot(3,1,1)
                    legend(allQ)
                    title('Errors of unwrapped plots')
    %                 tightfig;

                    %% printing stats
                    fprintf('*** Quaternion unity check from compPlots() ***\n')
                    for k=1:numel(q)
                        jj=q{k}; qn=quatnorm(jj);
                        fprintf('   norm of %s: max=%.4f min=%.4f\n',allQ{k},max(qn),min(qn))
                    end
                    fprintf('*** Quaternion unity check complete! ***\n\n')

                    if length(q{1})>15000; return; end;
                    %% printing MSE
                    fprintf('*** RMSE computation ***\n')
                    fprintf('   Assuming truth data is: %s\n',allQ{1})
                    for k=2:numel(q)
                        chop_vec=round(linspace(1,length(q{k}),length(q{1}))); % vector to chop down filter points to align with truth data
                        qc=q{k}(chop_vec,:); % chopped IMU quaternions
                        ec{k}=[r1_uw{k}(chop_vec) r2_uw{k}(chop_vec) r3_uw{k}(chop_vec)]; % chopped IMU Euler angles
                        fprintf('   RMSE of [ %s - %s ]:\n',allQ{1},allQ{k})
                        % quaternion MSE computation
                        [RMSE1q,RMSE2q,RMSE3q,RMSE4q,RMSEnormq,RMSEmeanq]=computeRMSE(q{1},qc);
                        fprintf('      Quaternion: [%.3f %.3f %.3f %.3f], norm=%.3f, mean=%.3f\n',RMSE1q,RMSE2q,RMSE3q,RMSE4q,RMSEnormq,RMSEmeanq)  
                        % Euler angle MSE computation
                        [RMSE1eul,RMSE2eul,RMSE3eul,RMSEnormeul,RMSEmeaneul]=computeRMSE([r1_uw{1} r2_uw{1} r3_uw{1}],ec{k});
                        fprintf('      UW Euler Angles (deg): [%.3f %.3f %.3f], norm=%.3f, mean=%.3f\n',RMSE1eul,RMSE2eul,RMSE3eul,RMSEnormeul,RMSEmeaneul)  
                    end
                    fprintf('*** RMSE computation complete! ***\n\n')
                end
            end  
        end % comp()
            
        function figh=plot_data(obj,str)
            % plots accels, mags, and gyros
            % update 2/6/17: allow handling nx1 obj array (multiple sensors)
            % 	             allow sensor to be turned off
            if nargin == 1
                str = 'agmqtbe';
            end
            numSensors=length(obj);
            str = lower(str);
            for s=1:numSensors
                requestVec=~cellfun(@isempty,regexp(str,{'a','g','m','q','t','b','e','u'}));
                plotVec = [[obj(s).enableVector,1].*requestVec,~isempty(regexp(str,'n'))];
                subPlotsIdx=cumsum(plotVec(1:8)); % number of subplots to make
                numSubPlots=max(subPlotsIdx);
                if isempty(obj(s).label)
                    label = obj(s).name;
                else
                    label = obj(s).label;
                end
                figh=figure('units','inches','position',[2 0 6 10],'name',['Sensor ',label]); 
                if plotVec(1) == 1
                    subplot(numSubPlots,1,subPlotsIdx(1)) % accels
                    plot(obj(s).time,obj(s).ax,'r','linewidth',2); hold on;
                    plot(obj(s).time,obj(s).ay,'Color',[0,0.5,0],'linewidth',2);
                    plot(obj(s).time,obj(s).az,'b','linewidth',2)
                    if plotVec(9) == 1
                        plot(obj(s).time,obj(s).normA,'Color',[1,0.5,0],'linewidth',2)
                    end
                    grid on;
                    ylabel('acceleration (m/s^2)');
                    if subPlotsIdx(1) == numSubPlots
                        xlabel('time (s)');
                        if plotVec(9) == 1
                            legend('x','y','z','norm','location','southeast');
                        else
                            legend('x','y','z','location','southeast');
                        end
                    end
                    title(['Accelerometer Raw Data for ',label])
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(2) == 1
                    subplot(numSubPlots,1,subPlotsIdx(2)) % gyros
                    plot(obj(s).time,obj(s).gx,'r','linewidth',2); hold on;
                    plot(obj(s).time,obj(s).gy,'Color',[0,0.5,0],'linewidth',2);
                    plot(obj(s).time,obj(s).gz,'b','linewidth',2);
                    if plotVec(9) == 1
                        plot(obj(s).time,obj(s).normG,'Color',[1,0.5,0],'linewidth',2)
                    end
                    grid on;
                    ylabel('angular velocity (rad/s)')
                    if subPlotsIdx(2) == numSubPlots
                        xlabel('time (s)');
                        if plotVec(9) == 1
                            legend('x','y','z','norm','location','southeast');
                        else
                            legend('x','y','z','location','southeast');
                        end
                    end
                    title(['Gyroscope Raw Data for ',label])
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(3) == 1
                    subplot(numSubPlots,1,subPlotsIdx(3)) % mags
                    plot(obj(s).time,obj(s).mx,'r','linewidth',2); hold on;
                    plot(obj(s).time,obj(s).my,'Color',[0,0.5,0],'linewidth',2);
                    plot(obj(s).time,obj(s).mz,'b','linewidth',2);
                    grid on;
                    ylabel('magnetic field (G)')
                    if subPlotsIdx(3) == numSubPlots
                        xlabel('time (s)');
                        if plotVec(9) == 1
                            legend('x','y','z','norm','location','southeast');
                        else
                            legend('x','y','z','location','southeast');
                        end
                    end
                    title(['Magnetometer Raw Data for ',label])
                    legend('x','y','z','location','southeast')
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(4) == 1
                    subplot(numSubPlots,1,subPlotsIdx(4)) % quats
                    q = obj(s).qAPDM;
                    hold on;
                    plot(obj(s).time,q(:,1),'k','linewidth',2);
                    plot(obj(s).time,q(:,2),'r','linewidth',2);
                    plot(obj(s).time,q(:,3),'g','linewidth',2);
                    plot(obj(s).time,q(:,4),'b','linewidth',2);
                    title([label,' Processed Quaternion Data']);
                    grid on;
                    if subPlotsIdx(4) == numSubPlots
                        xlabel('time (s)');
                    end
                    ylabel('Quaternion');
                    legend('q0','q1','q2','q3');
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(5) == 1
                    subplot(numSubPlots,1,subPlotsIdx(5)) % temp
                    plot(obj(s).time,obj(s).temperature,'linewidth',2);
                    title(['Temperature for ', label]);
                    grid on;
                    if subPlotsIdx(5) == numSubPlots
                        xlabel('time (s)');
                    end
                    ylabel('temperatire (deg C)');
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(6) == 1
                    subplot(numSubPlots,1,subPlotsIdx(6)) % temp
                    plot(obj(s).time,obj(s).barometer,'linewidth',2); grid on;
                    title(['Pressure for ', label]);
                    grid on;
                    xlabel('time (s)');
                    ylabel('pressure (kPa)');
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(7) == 1
                    subplot(numSubPlots,1,subPlotsIdx(7)) % euler angles
                    e = obj(s).eulerAPDM;
                    hold on;
                    plot(obj(s).time,e(:,1),'b','linewidth',2);
                    plot(obj(s).time,e(:,2),'g','linewidth',2);
                    plot(obj(s).time,e(:,3),'r','linewidth',2);
                    title([label,' APDM Euler Angles']);
                    grid on;
                    if subPlotsIdx(7) == numSubPlots
                        xlabel('time (s)');
                    end
                    ylabel('Euler angle (rad)');
                    legend('Z','Y','X');
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if plotVec(8) == 1
                    subplot(numSubPlots,1,subPlotsIdx(8)) % euler angles
                    q = obj(s).qPF;
                    hold on;
                    plot(obj(s).time,q(:,1),'k','linewidth',2);
                    plot(obj(s).time,q(:,2),'r','linewidth',2);
                    plot(obj(s).time,q(:,3),'g','linewidth',2);
                    plot(obj(s).time,q(:,4),'b','linewidth',2);
                    title([label,' Computed PF']);
                    grid on;
                    if subPlotsIdx(8) == numSubPlots
                        xlabel('time (s)');
                    end
                    ylabel('Quaternion');
                    legend('q0','q1','q2','q3');
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
                if regexp(str,'f')
                    figh2=figure('name',['Sensor ',label, ' FG']); 
                    hold on;
                    plot(obj(s).time,obj(s).gxFilt,'r','linewidth',2);
                    plot(obj(s).time,obj(s).gyFilt,'Color',[0,0.5,0],'linewidth',2);
                    plot(obj(s).time,obj(s).gzFilt,'b','linewidth',2)
                    grid on;
                    ylabel('angular velocity (rad/s)');
                    xlabel('time (s)');
                    title(['Filtered Gyroscope Raw Data for ',label])
                    xlim([obj(s).time(1), obj(s).time(end)]);
                end
%                 tightfig;
            end
            
        end % plot_data()
        
        function figh=pos(obj)
            % plot position of IMU, double integrated from accels
            removeGravity(obj);
            zeroPoint=obj.calEndIdx;
            % chop a
%             ax=obj.axd(zeroPoint:end); ay=obj.ayd(zeroPoint:end); az=obj.azd(zeroPoint:end);
            ax=obj.ax; ay=obj.ay; az=obj.az;
            t_IMU=obj.time;
            
            % Design High Pass Filter
            fs = obj.sampleRate; % Sampling Rate
            fc = .1/30; % Cut off Frequency
            order = 6; % 6th Order Filter
            % Filter Acceleration Signals
            [b1, a1] = butter(order,fc,'high');
            axff=filtfilt(b1,a1,ax);

            axf=noise_filter(ax,fs,5); ayf=noise_filter(ay,fs,5); azf=noise_filter(az,fs,5);
            figh=figure; 
            plot(t_IMU,axf); hold on;
            plot(t_IMU,ayf)
            plot(t_IMU,azf)
            title('acceleration over time')
            
            vx=cumtrapz(t_IMU,axf); vxf=noise_filter(vx,fs,5);
            vy=cumtrapz(t_IMU,ayf); vyf=noise_filter(vy,fs,5);
            vz=cumtrapz(t_IMU,azf); vzf=noise_filter(vz,fs,5);
            figh=figure; 
            plot(t_IMU,vxf); hold on;
            plot(t_IMU,vyf)
            plot(t_IMU,vzf)
            title('velocity over time')
            
            px=cumtrapz(t_IMU,vxf); pxf=filtfilt(b1,a1,px);
            py=cumtrapz(t_IMU,vyf); pyf=filtfilt(b1,a1,py);
            pz=cumtrapz(t_IMU,vzf); pzf=filtfilt(b1,a1,pz);
            
            figh=figure;
            plot(t_IMU,px); hold on;
            plot(t_IMU,py)
            plot(t_IMU,pz)
             title('position over time')
             
            function outdata = noise_filter(s,f,f_cutoff)
            data=s;
            % f=30;%  sampling frequency
            % f_cutoff = 5; % cutoff frequency

            fnorm =f_cutoff/(f/2); % normalized cut off freq, you can change it to any value depending on your requirements

            [b1,a1] = butter(10,fnorm,'low'); % Low pass Butterworth filter of order 10
            low_data = filtfilt(b1,a1,data); % filtering


            % freqz(b1,a1,128,f), title('low pass filter characteristics')
            % figure
            % subplot(2,1,1), plot(data), title('Actual data')
            % subplot(2,1,2), plot(low_data), title('Filtered data')

            outdata=low_data;
            end
            
        end % fPlots.pos()
                        
    end % methods
    
end

function varargout=computeRMSE(truth,est) % compute RMSE 
    switch size(truth,2)
        case 4 % quaternion MSE
%                         for k=1:length(truth)
            RMSE1=sqrt(mean((truth(:,1)-est(:,1)).^2));
            RMSE2=sqrt(mean((truth(:,2)-est(:,2)).^2));
            RMSE3=sqrt(mean((truth(:,3)-est(:,3)).^2));
            RMSE4=sqrt(mean((truth(:,4)-est(:,4)).^2));
            RMSEnorm=norm([RMSE1 RMSE2 RMSE3 RMSE4]);
            RMSEmean=mean([RMSE1 RMSE2 RMSE3 RMSE4]);
%                         end
        varargout={RMSE1,RMSE2,RMSE3,RMSE4,RMSEnorm,RMSEmean};
        case 3 % Euler angles (deg) MSE
    %                         for k=1:length(truth)
                RMSE1=sqrt(mean((truth(:,1)-est(:,1)).^2));
                RMSE2=sqrt(mean((truth(:,2)-est(:,2)).^2));
                RMSE3=sqrt(mean((truth(:,3)-est(:,3)).^2));
                RMSEnorm=norm([RMSE1 RMSE2 RMSE3]);
                RMSEmean=mean([RMSE1 RMSE2 RMSE3]);
    %                         end
            varargout={RMSE1,RMSE2,RMSE3,RMSEnorm,RMSEmean};
    end
end