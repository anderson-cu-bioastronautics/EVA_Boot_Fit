%for inhertance to OpalIMUData to Calibrate data
classdef CalIMUData < handle %data calibration class
    properties (Hidden)
        gxFilt %Calibrated Gyro Data
        gyFilt %Calibrated Gyro Data
        gzFilt %Calibrated Gyro Data
        normGFilt %Filtered Gyroscope Magnitude
        % accelerometer cal properties
        axCalMean % ax reading in cal
        axCalVar % ax noise variance in cal
        ayCalMean % ax reading in cal
        ayCalVar % ax noise variance in cal
        azCalMean % ax reading in cal
        azCalVar % ax noise variance in cal
        % gyro cal properties
        gxCalMean % ax reading in cal
        gxCalVar % ax noise variance in cal
        gyCalMean % ax reading in cal
        gyCalVar % ax noise variance in cal
        gzCalMean % ax reading in cal
        gzCalVar % ax noise variance in cal
        % mag cal properties
        mxCalMean % ax reading in cal
        mxCalVar % ax noise variance in cal
        myCalMean % ax reading in cal
        myCalVar % ax noise variance in cal
        mzCalMean % ax reading in cal
        mzCalVar % ax noise variance in cal
        calStartIdx % index of cal start
        calEndIdx % index of cal end
    end
    properties %Public Properties
        calStartTime=0; % cal start (sec)
        calEndTime=0; % cal end (sec)
        calCheck=0; % T/F... did calculated Cal pass check?
        staticCalQuat=zeros(1,4); % static cal quaternion
    end
    methods
        function approxCal(obj) % approximate calibration start and end
            numSensors=length(obj);
            for s = 1:numSensors
                % finds largest still period in data
                dacc=diff(obj(s).normA);
                good_data=abs(dacc)<0.3; % assuming this means not much motion (logical)
                X=diff(good_data)~=0;
                B=find([true,X]); % beginning of each group
                E=find([X,true]); % end of each group
                L=1+E-B; % length of each group
                B=B(L>1); E=E(L>1); L=L(L>1); % let's cut to only groups that are longer than one index
                
                [~,idx] = max(E-B);
                c1m=B(idx); % index of beginning of found cal period
                c2m=E(idx); % index of beginning of found cal period
                c1=round(c1m+(c2m-c1m)*0.2); % chop off first 20 percent
                c2=round(c2m-(c2m-c1m)*0.2); % chop off last 20 percent
                % ==> you're left with middle 60% of cal data
                
                % now check if c1 and c2 work for other sensor data
                noiseLvlArray=[.35 .35 .35 .05 .05 .05 2.2 2.2 2.2];
                chk=checkCal(obj(s),noiseLvlArray,c1,c2);
                
                obj(s).calStartTime=c1/obj(s).sampleRate; obj(s).calEndTime=c2/obj(s).sampleRate;
                obj(s).calStartIdx=c1; obj(s).calEndIdx=c2;
                
                if all(chk>0)
                    fprintf('\nCal time passes as %.3f to %.3f sec (idx %d:%d)\n',obj(s).calStartTime,obj(s).calEndTime,c1,c2);
                    obj(s).calCheck=1;
                else
                    sensors={'ax' 'ay' 'az' 'gx' 'gy' 'gz' 'mx' 'my' 'mz'};
                    didNotPass=sensors(chk==0);
                    warn=fprintf('Sensor [%s] did not pass cal check\n',didNotPass{:});
                    warning('One or more sensors didn''t pass cal check!')
                    obj(s).calCheck=0;
                end
                % NOTES:
                % confirmed working for Vicon data ViconPilotAll_032216_IMU2459.h5'
                % need to check robot data
            end    
        end % approxCal
        
        function chks=checkCal(obj,noiseLvlArray,c1,c2) % checks other instruments
            if obj.enableVector(1)
                if all(diff(obj.ax(c1:c2)')<noiseLvlArray(1))
                    chks(1) = 1;
                else
                    chks(1) = 0;
                end% check
                if all(diff(obj.ay(c1:c2)')<noiseLvlArray(2))
                    chks(2) = 1;
                else
                    chks(2) = 0;
                end% check
                if all(diff(obj.az(c1:c2)')<noiseLvlArray(3))
                    chks(3) = 1;
                else
                    chks(3) = 0;
                end% check
            else
                chks(1:3) = 2;
            end
            if obj.enableVector(2)
                if all(diff(obj.gx(c1:c2)')<noiseLvlArray(4))
                    chks(4) = 1;
                else
                    chks(4) = 0;
                end% check
                if all(diff(obj.gy(c1:c2)')<noiseLvlArray(5))
                    chks(5) = 1;
                else
                    chks(5) = 0;
                end% check
                if all(diff(obj.gz(c1:c2)')<noiseLvlArray(6))
                    chks(6) = 1;
                else
                    chks(6) = 0;
                end% check
            else
                chks(4:6) = 2;
            end
            if obj.enableVector(3)
                if all(diff(obj.mx(c1:c2)')<noiseLvlArray(7))
                    chks(7) = 1;
                else
                    chks(7) = 0;
                end% check
                if all(diff(obj.my(c1:c2)')<noiseLvlArray(8))
                    chks(8) = 1;
                else
                    chks(8) = 0;
                end% check
                if all(diff(obj.mz(c1:c2)')<noiseLvlArray(9))
                    chks(9) = 1;
                else
                    chks(9) = 0;
                end% check
            end
        end %end checkCal
        
        function setCalData(obj,calobj) % sets all cal readings & noise 
            numSensors = numel(obj);
            if nargin == 1
                calobj = obj;
            else
                if numel(obj) ~= numel(calobj)
                    error('Your calibration and data file are not the same size!');
                elseif any(obj(1).name ~= calobj(1).name)
                    error('Sensors IDs do match match!');
                end
            end
            for s = 1:numSensors
                % first, check to see if cal times have been set
                if ~any([calobj(s).calStartTime calobj(s).calEndTime calobj(s).calStartIdx calobj(s).calEndIdx])
                    error('Cal times have not been set!')
                end
                % next, throw warning if the cal doesn't seem good
                if calobj(s).calCheck==0
                    warning('Cal does not look that good')
                end
                % set zero indeces if the times are set
                if any([calobj(s).calStartIdx calobj(s).calEndIdx])
                    % we're good
                else % set them from the nonzero times
                    calobj(s).calStartIdx=round(calobj(s).calStartTime*calobj(s).sampleRate);
                    calobj(s).calEndIdx=round(calobj(s).calEndTime*calobj(s).sampleRate);
                end
                % now, go ahead and set cal readings
                obj(s).axCalMean=mean(calobj(s).ax(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).ayCalMean=mean(calobj(s).ay(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).azCalMean=mean(calobj(s).az(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gxCalMean=mean(calobj(s).gx(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gyCalMean=mean(calobj(s).gy(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gzCalMean=mean(calobj(s).gz(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).mxCalMean=mean(calobj(s).mx(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).myCalMean=mean(calobj(s).my(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).mzCalMean=mean(calobj(s).mz(calobj(s).calStartIdx:calobj(s).calEndIdx));
                % set cal noise variances
                obj(s).axCalVar=var(calobj(s).ax(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).ayCalVar=var(calobj(s).ay(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).azCalVar=var(calobj(s).az(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gxCalVar=var(calobj(s).gx(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gyCalVar=var(calobj(s).gy(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).gzCalVar=var(calobj(s).gz(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).mxCalVar=var(calobj(s).mx(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).myCalVar=var(calobj(s).my(calobj(s).calStartIdx:calobj(s).calEndIdx));
                obj(s).mzCalVar=var(calobj(s).mz(calobj(s).calStartIdx:calobj(s).calEndIdx));
            end
        end %setCalData
        
        function filter_gyro(obj)
            %Removes gyro offset and applies a 30Hz low-pass 6th order butterworth
            %filter to gyroscope data with zero velocity updates
            numSensors=length(obj);
            for s = 1:numSensors
                obj(s).gxFilt = obj(s).gx - obj(s).gxCalMean;
                obj(s).gyFilt = obj(s).gy - obj(s).gyCalMean;
                obj(s).gzFilt = obj(s).gz - obj(s).gzCalMean;
                [b,a] = butter(6,30/obj(s).sampleRate,'low');
                obj(s).gxFilt = filtfilt(b,a,obj(s).gx);
                obj(s).gxFilt(obj(s).gxFilt<0.03 & obj(s).gxFilt>-0.03) = 0;
                obj(s).gyFilt = filtfilt(b,a,obj(s).gy);
                obj(s).gyFilt(obj(s).gyFilt<0.03 & obj(s).gyFilt>-0.03) = 0;
                obj(s).gzFilt = filtfilt(b,a,obj(s).gz);
                obj(s).gzFilt(obj(s).gzFilt<0.03 & obj(s).gzFilt>-0.03) = 0;
                obj(s).normGFilt=sqrt(sum([obj(s).gxFilt,obj(s).gyFilt,obj(s).gzFilt].^2,2)); 
                obj(s).gyroFiltered = 1;
            end
        end % filter_gyro
        
        function [obj_cut] = cutOpalIMU(obj,strIdx,endIdx)
            obj_cut = copy(obj);
            for n = 1:length(obj)
                obj_cut(n).ax = obj(n).ax(strIdx:endIdx);
                obj_cut(n).ay = obj(n).ay(strIdx:endIdx);
                obj_cut(n).az = obj(n).az(strIdx:endIdx);
                obj_cut(n).gx = obj(n).gx(strIdx:endIdx);
                obj_cut(n).gy = obj(n).gy(strIdx:endIdx);
                obj_cut(n).gz = obj(n).gz(strIdx:endIdx);
                if obj(n).magEnabled > 0
                    obj_cut(n).mx = obj(n).mx(strIdx:endIdx);
                    obj_cut(n).my = obj(n).my(strIdx:endIdx);
                    obj_cut(n).mz = obj(n).mz(strIdx:endIdx);
                end
                if obj(n).buttonEnabled > 0
                    obj_cut(n).button = obj(n).button(strIdx:endIdx);
                end
                obj_cut(n).unixTime = obj(n).unixTime(strIdx:endIdx);
                obj_cut(n).datenumVec = obj(n).datenumVec(strIdx:endIdx);
                obj_cut(n).startTime = datestr(obj(n).datenumVec(1));
                obj_cut(n).endTime = datestr(obj(n).datenumVec(end));
                obj_cut(n).time = obj(n).time(strIdx:endIdx) - obj(n).time(strIdx+1);
                obj_cut(n).numSamples = length(obj_cut(n).time);
                
                obj_cut(n).normA = obj(n).normA(strIdx:endIdx);
                obj_cut(n).normG = obj(n).normG(strIdx:endIdx);
                
                obj_cut(n).temperature = obj(n).temperature(strIdx:endIdx);
                obj_cut(n).barometer = obj(n).barometer(strIdx:endIdx);
                obj_cut(n).qAPDM = obj(n).qAPDM(strIdx:endIdx,:);
                if length(obj(n).qEKF) == length(obj(n).qAPDM)
                    obj_cut(n).qEKF = obj(n).qEKF(strIdx:endIdx,:);
                elseif length(obj(n).qUKF) == length(obj(n).qAPDM)
                    obj_cut(n).qUKF = obj(n).qUKF(strIdx:endIdx,:);
                elseif length(obj(n).qPF) == length(obj(n).qAPDM)
                    obj_cut(n).qPF = obj(n).qPF(strIdx:endIdx,:);
                end
                if obj(n).gyroFiltered == 1
                    obj_cut(n).gxFilt = obj(n).gxFilt(strIdx:endIdx);
                    obj_cut(n).gyFilt = obj(n).gyFilt(strIdx:endIdx);
                    obj_cut(n).gzFilt = obj(n).gzFilt(strIdx:endIdx);
                    obj_cut(n).normGFilt = obj(n).normGFilt(strIdx:endIdx);
                end
            end
        end
        
        function sfile = saveCalFile(obj)
            l = length(obj);
            sfile = cell(20,l);
            for n = 1:l
                % accelerometer cal properties
                sfile{1,n} = obj(n).axCalMean; % ax reading in cal
                sfile{2,n} = obj(n).axCalVar; % ax noise variance in cal
                sfile{3,n} = obj(n).ayCalMean; % ax reading in cal
                sfile{4,n} = obj(n).ayCalVar; % ax noise variance in cal
                sfile{5,n} = obj(n).azCalMean; % ax reading in cal
                sfile{6,n} = obj(n).azCalVar; % ax noise variance in cal
                % gyro cal properties
                sfile{7,n} = obj(n).gxCalMean; % ax reading in cal
                sfile{8,n} = obj(n).gxCalVar; % ax noise variance in cal
                sfile{9,n} = obj(n).gyCalMean; % ax reading in cal
                sfile{10,n} = obj(n).gyCalVar; % ax noise variance in cal
                sfile{11,n} = obj(n).gzCalMean; % ax reading in cal
                sfile{12,n} = obj(n).gzCalVar; % ax noise variance in cal
                % mag cal properties
                sfile{13,n} = obj(n).mxCalMean; % ax reading in cal
                sfile{14,n} = obj(n).mxCalVar; % ax noise variance in cal
                sfile{15,n} = obj(n).myCalMean; % ax reading in cal
                sfile{16,n} = obj(n).myCalVar; % ax noise variance in cal
                sfile{17,n} = obj(n).mzCalMean; % ax reading in cal
                sfile{18,n} = obj(n).mzCalVar; % ax noise variance in cal
                %IMU labels
                sfile{19,n} = obj(n).label;
                sfile{20,n} = obj(n).num;
            end
        end
        
        function loadCalFile(obj,sfile)
            l = length(obj);
            for n = 1:l
                idx = ~cellfun(@isempty,regexp(obj(n).label,sfile(19,:)));
                if sum(idx) == 0
                    warning(['An error occured. It appears the calibration file does not match IMU ', obj(n).label]);
                    continue;
                end
                 % accelerometer cal properties
                obj(n).axCalMean = sfile{1,idx}; % ax reading in cal
                obj(n).axCalVar = sfile{2,idx}; % ax noise variance in cal
                obj(n).ayCalMean = sfile{3,idx}; % ax reading in cal
                obj(n).ayCalVar = sfile{4,idx}; % ax noise variance in cal
                obj(n).azCalMean = sfile{5,idx}; % ax reading in cal
                obj(n).azCalVar = sfile{6,idx}; % ax noise variance in cal
                % gyro cal properties
                obj(n).gxCalMean = sfile{7,idx}; % ax reading in cal
                obj(n).gxCalVar = sfile{8,idx}; % ax noise variance in cal
                obj(n).gyCalMean = sfile{9,idx}; % ax reading in cal
                obj(n).gyCalVar = sfile{10,idx}; % ax noise variance in cal
                obj(n).gzCalMean = sfile{11,idx}; % ax reading in cal
                obj(n).gzCalVar = sfile{12,idx}; % ax noise variance in cal
                % mag cal properties
                obj(n).mxCalMean = sfile{13,idx}; % ax reading in cal
                obj(n).mxCalVar = sfile{14,idx}; % ax noise variance in cal
                obj(n).myCalMean = sfile{15,idx}; % ax reading in cal
                obj(n).myCalVar = sfile{16,idx}; % ax noise variance in cal
                obj(n).mzCalMean = sfile{17,idx}; % ax reading in cal
                obj(n).mzCalVar = sfile{18,idx}; % ax noise variance in cal
                obj(n).calCheck = 1;
                filter_gyro(obj(n));
            end
            fprintf('Calibration data successfully loaded in %i IMUs!\n',l)
        end
end %end methods
end