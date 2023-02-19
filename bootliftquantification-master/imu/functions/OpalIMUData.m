%%%------Opal IMU Data MATLAB Class v1.0------%%%
%% OpalIMUData()
classdef OpalIMUData < handle & fPlots & CalIMUData & matlab.mixin.Copyable 
    % IMU Data from APDM .h5 dataset
    properties (Hidden)
        ax; ay; az % (m/s^2) | acceleration in x, y, z
        gx; gy; gz % (rad/s) | angular velocity x, y, z
        mx; my; mz % [uT]    | magnetic field x, y, z
        button % binary vector of button pushed (1) or not (0)
        fullfile % full path to h5 file

        unixTime % unix time in microseconds
        datenumVec % vector time in MATLAB datenum format
        
        normA % a norms
        normG % g norms
        axd % dynamic acceleration (gravity removed)
        ayd
        azd
        % ID
        ID % XI-###### (string)
        num % parsed numbers from ID (double)
        env='none'; % descriptor of magnetic environment IMU was in
        version % h5 file version number
        accelEnabled % accelerometer enabled? (binary)
        magEnabled
        gyroEnabled
        buttonEnabled
        tempEnabled = 1;
        baroEnabled = 0;
        quatEnabled = 1;
        enableVector
        gyroFiltered = 0;
        eulerAPDM % ZYX (3-2-1) Euler angles in rad
        eulerEnabled=1;
    end
    properties % public properties
        name % string for dataset name
        label % string label (set in MotionStudio)
        numSamples % number of samples
        data % sampled IMU Data (all, Nx9)
        time % time vector
        sampleRate % Sample rate (Hz)
        filename % just end file title (with .h5)
        qAPDM % filtered quaternion dataset from APDM // q[NWU->local]
        qEKF=[0 0 0 0] % filtered EKF orientation
        qUKF=[0 0 0 0] % filtered UKF orientation
        qPF=[0 0 0 0] % filtered PF orientation
        startTime % string for global start time
        endTime % string for global data end time
        temperature % temp in deg C
        barometer % pressure in kPa
    end
    properties (Constant, Hidden)
        gc=9.80665; % accel due to gravity, m/s^2
    end
    methods
        function obj=OpalIMUData(varargin) % construct from h5 file
            %% handle inputs
            switch nargin
                case 0
                    %                     warning('OpalIMUData() needs to be passed a string which represents a valid .h5 file of Opal IMU Data. Creating blank object.')
                    return
                case 1
                    FILE=varargin{1};
                    mfiledir = fileparts(mfilename('fullpath')); % current path that OpalIMUData() is in
                    if strcmp(FILE,'') % called like x=OpalIMUData('');
                        %                         h5_files=dir([mfiledir, filesep ,'*.h5']);
                        %                         FILE=h5_files(1).name; % use first h5 file you find in directory
                        filename='v5_two_sensors.h5';
                        FILE=fullfile(mfiledir,'example_OpalIMUData',filename);
                        warning('No file specified, using default of: %s',filename);
                    end
                    if ~exist(FILE,'file') % file doesn't exist
                        % try to look in example data folder for the FILE
                        FILE=fullfile(mfiledir,'example_OpalIMUData',FILE);
                    end
                otherwise; error('right now can''t support more than one .h5 file');
            end % handling of inputs
            
            %% handle h5 version differences
            % Opal v2 uses v5 of h5 file. Splitting constructor method to
            % account for the different h5 version types:
            h5_version=get_file_format_version(FILE); % version 4->Opalv1/ v5->Opalv2
            switch h5_version
                case 4
                    obj=construct_v4(FILE,obj);
                case 5
                    obj=construct_v5(FILE,obj);
                otherwise; error('h5 version not found or not supported');
            end
            numSensors=length(obj);
            for i=1:numSensors; obj(i).version=h5_version; end
        end
        
        function s=getQuats(obj) % finds all computed quaternions
            % and returns as a cell array of strings
            
            h=properties(obj); % returns cell array of strings of all properties
            strToFind='q[A-Z]*'; % must start with q and have all uppercase letters after
            
            allQs = ~cellfun(@isempty,regexp(h,strToFind,'match'));
            h=h(allQs);
            
            s=cell(0);
            for k=1:numel(h)
                r=eval(strcat('obj.',h{k}));
                if numel(r)>10 % there's some data here
                    s=[s;h{k}];
                end
            end
        end
        
        function getStaticCalQuat(obj)
            obj.staticCalQuat = mean(obj.qAPDM(obj.calStartIdx:obj.calEndIdx,:),1);
            obj.staticCalQuat = quatnormalize(obj.staticCalQuat);
        end % getStaticCalQuat
        
        function dynAcc=removeGravity(obj)
            axDynamic=obj.ax; ayDynamic=obj.ay; azDynamic=obj.az;
            q=obj.qAPDM;
            gcDynamic=[0 0 obj.gc];
            
            for k=1:length(axDynamic)
                % gc to local frame:
                localGravity=quatrotate(q(k,:),gcDynamic);
                axDynamic(k)=axDynamic(k)-localGravity(1); ayDynamic(k)=ayDynamic(k)-localGravity(2); azDynamic(k)=azDynamic(k)-localGravity(3);
            end
            dynAcc=[axDynamic ayDynamic azDynamic];
            obj.axd=axDynamic;
            obj.ayd=ayDynamic;
            obj.azd=azDynamic;
            
        end
        
        function alignTime(varargin)
            % takes in varargin number of OpalIMUData objects and finds the minimum and maximum overlapping times.
            % Then, it chops the data to align the data in time
            for k=1:nargin % find mins and maxes
                allmin(k)=min(varargin{k}.unixTime);
                allmax(k)=max(varargin{k}.unixTime);
            end
            gmin=max(allmin); gmax=min(allmax); % overlap min/max
            
            for k=1:nargin % indeces to chop at
                chopmin(k)=find(varargin{k}.unixTime==gmin);
                chopmax(k)=find(varargin{k}.unixTime==gmax);
            end
            
            for k=1:nargin % chop data
                % chop all [a g m], data, time, temperature, numSamples, qAPDM
                varargin{k}.ax=varargin{k}.ax(chopmin(k):chopmax(k)); varargin{k}.ay=varargin{k}.ay(chopmin(k):chopmax(k)); varargin{k}.az=varargin{k}.az(chopmin(k):chopmax(k));
                varargin{k}.gx=varargin{k}.gx(chopmin(k):chopmax(k)); varargin{k}.gy=varargin{k}.gy(chopmin(k):chopmax(k)); varargin{k}.gz=varargin{k}.gz(chopmin(k):chopmax(k));
                varargin{k}.mx=varargin{k}.mx(chopmin(k):chopmax(k)); varargin{k}.my=varargin{k}.my(chopmin(k):chopmax(k)); varargin{k}.mz=varargin{k}.mz(chopmin(k):chopmax(k));
                varargin{k}.data=varargin{k}.data(chopmin(k):chopmax(k),:);
                varargin{k}.temperature=varargin{k}.temperature(chopmin(k):chopmax(k));
                varargin{k}.numSamples=length(chopmin(k):chopmax(k));
                varargin{k}.qAPDM=varargin{k}.qAPDM(chopmin(k):chopmax(k),:);
                varargin{k}.time=varargin{k}.time(chopmin(k):chopmax(k)); varargin{k}.time=varargin{k}.time-varargin{k}.time(1);
            end
            
        end % alignTime()
        
        function upVectors=find_vertical_dir(obj)
            % takes in an OpalIMUData object and returns a Nx3 array of the 'up' direction in the IMU frame at each timestep k, k=1:N
            % Global frame [xyz] is North-West-Up
            % and quat is q[global frame -> local frame]
            % therefore, the up direction is simple [0 0 1] in the global frame!
            upVectors=quatrotate(quatinv(obj.qAPDM),repmat([0 0 1],length(obj.qAPDM),1));
            % --> or: z[NWU]=inv(q[NWU->local])*z[local]
        end
    end
end

function versionNum=get_file_format_version(FILE)
% 2/1/17
% returns integer that represents h5 file version.
% version 4 == Opal v1
% version 5 == Opal v2
versionNum=h5readatt(FILE,'/','FileFormatVersion');
% fprintf('version %d\n',versionNum)
end % get file format version

function obj=construct_v4(FILE,obj) % old IMU
% h5disp('2999_longCalib1.h5') % for example
all_str=strsplit(FILE,'\');
filename=all_str{end}; % just end file name
idstrlist=h5readatt(FILE,'/','CaseIdList');
numSensors=length(idstrlist);
%     h5disp(FILE)
for n=1:numSensors % number of sensors in the file
    obj(n).fullfile=FILE;
    obj(n).filename=filename;
    idstr=idstrlist{n};
    monstr=regexp(idstr,'SI-\d*','match');
    monstr=monstr{1};
    datatype='Filtered';
    try
        h5read(FILE,strcat('/',monstr,'/',datatype,'/','Accelerometers'));
    catch
        datatype='Calibrated';
        warning('Could not find Filtered data in data set')
    end
    obj(n).ID=monstr;
    obj(n).name=obj(n).ID;
    obj(n).num=str2double(obj(n).ID(end-5:end));
    
    % setting all data
    % label
    obj(n).label=''; % FLAG: can't find this in the data. need an example.
    % button
    obj(n).button=double(h5read(FILE,strcat('/',monstr,'/ButtonStatus'))); % button status vector
    if any(obj(n).button) % horrible way to do this. Just a quick fix. Figure out where this flag is in the h5 file later.
        obj(n).buttonEnabled=1;
    else
        obj(n).buttonEnabled=0;
    end
    % accelerometer data:
    obj(n).accelEnabled=double(h5readatt(FILE,strcat('/',monstr,'/'),'AccelerometersEnabled'));
    if obj(n).accelEnabled
        accels=h5read(FILE,strcat('/',monstr,'/',datatype,'/','Accelerometers'));
        obj(n).ax=accels(1,:)'; % (m/s^2) | acceleration in x
        obj(n).ay=accels(2,:)'; % (m/s^2) | acceleration in y
        obj(n).az=accels(3,:)'; % (m/s^2) | acceleration in z
    else
        obj(n).ax=nan; obj(n).ay=nan; obj(n).az=nan;
    end
    
    % gyro data (angular velocities):
    obj(n).gyroEnabled=double(h5readatt(FILE,strcat('/',monstr,'/'),'GyroscopesEnabled'));
    if obj(n).gyroEnabled
        gyro=h5read(FILE,strcat('/',monstr,'/',datatype,'/','Gyroscopes'));
        obj(n).gx=gyro(1,:)'; % (rad/s) | angular velocity x
        obj(n).gy=gyro(2,:)'; % (rad/s) | angular velocity y
        obj(n).gz=gyro(3,:)'; % (rad/s) | angular velocity z
%         gyroCal=h5read(FILE,strcat('/',monstr,'/Calibrated/','Gyroscopes'));
%         % commented out this part because we moved cal stuff out to its
%         own class
%         obj(n).gxCal=gyroCal(1,:)'; % (rad/s) | angular velocity x
%         obj(n).gyCal=gyroCal(2,:)'; % (rad/s) | angular velocity y
%         obj(n).gzCal=gyroCal(3,:)'; % (rad/s) | angular velocity z
    else
        obj(n).gx=nan; obj(n).gy=nan; obj(n).gz=nan;
    end
    
    % magnetometer data:
    obj(n).magEnabled=double(h5readatt(FILE,strcat('/',monstr,'/'),'MagnetometersEnabled'));
    if obj(n).magEnabled
        mags=h5read(FILE,strcat('/',monstr,'/',datatype,'/','Magnetometers'));
        convmultiplier=1; % so stay in uT
        obj(n).mx=mags(1,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field x
        obj(n).my=mags(2,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field y
        obj(n).mz=mags(3,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field z
    else
        obj(n).mx=nan; obj(n).my=nan; obj(n).mz=nan;
    end
    
    obj(n).numSamples=length(obj(n).ax);
    obj(n).qAPDM=h5read(FILE,strcat('/',monstr,'/Calibrated/Orientation'))';
    [obj(n).eulerAPDM(:,1),obj(n).eulerAPDM(:,2),obj(n).eulerAPDM(:,3)]=quat2angle(obj(n).qAPDM,'ZYX'); % ZYX euler angles in radians
    
    % timevector
    obj(n).unixTime=double(h5read(FILE,strcat('/',monstr,'/Time'))); % unix time in microseconds
    obj(n).datenumVec=obj(n).unixTime./86400./1E6 + datenum(1970,1,1)-datenum(0,0,0,5,0,0); % subtract 5 hours to put in EST
    obj(n).startTime = datestr(obj(n).datenumVec(1));
    obj(n).endTime = datestr(obj(n).datenumVec(end));
    timevec=obj(n).unixTime-obj(n).unixTime(1);
    obj(n).time=timevec./1E6; % convert to seconds to store in obj(n)
    obj(n).sampleRate=1/(obj(n).time(3)-obj(n).time(2)); % Hz
    obj(n).temperature=h5read(FILE,strcat('/',monstr,'/','Calibrated','/','Temperature')); % temp in deg C
    
    obj(n).normA=sqrt(sum([obj(n).ax,obj(n).ay,obj(n).az].^2,2));
    obj(n).normG=sqrt(sum([obj(n).gx,obj(n).gy,obj(n).gz].^2,2));
    
    obj(n).enableVector = logical([obj(n).accelEnabled, obj(n).gyroEnabled, obj(n).magEnabled, obj(n).quatEnabled, obj(n).tempEnabled, obj(n).baroEnabled obj(n).eulerEnabled]);
    
    %obj(n).data=[obj(n).ax obj(n).ay obj(n).az obj(n).gx obj(n).gy obj(n).gz obj(n).mx obj(n).my obj(n).mz];
end
end % constuctor v4

function obj=construct_v5(FILE,obj)
%2/16: there is something funny going on. Why doesn't think work anymore?
% There seems to be an ambiguity. Sometimes it's Sensors/999/..,
% Somtimes it's Sensors/XI-000999/...
% create a switch in get_sensor_list to handle two types
%     h5disp('v5_one_sensor.h5')  % for example
all_str=strsplit(FILE,'\');
filename=all_str{end}; % just end file name
[ID_list,num_list,stringMode]=get_sensor_list_v5(FILE);
% ID_list - > cell array of strings XI-######
% num_list - > array of doubles that are the ID number
% stringMode=1 wants ID_list, 2 wants num_list
numSensors=length(num_list);
textprogressbar(sprintf('Constructing %d IMU(s): ',numSensors)); textprogressbar(0); % initialize textprogressbar
for n=1:numSensors % number of sensors in the file
    obj(n).fullfile=FILE;
    obj(n).filename=filename;
    if stringMode==1 % use ID_list (XI-######)
        monstr=ID_list{n};
    elseif stringMode==2 % use num_list
        monstr=num2str(num_list(n));
    end
    obj(n).ID=ID_list{n};
    obj(n).name=obj(n).ID;
    obj(n).num=num_list(n);
    
    % setting all data
    % label
    label0=strrep(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Label 0'),char(0),'');
    label1=strrep(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Label 1'),char(0),'');
    label2=strrep(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Label 2'),char(0),''); % you can add up to three labels here
    allLabels={label0,label1,label2};
    allLabels(strcmp(allLabels,''))=[];
    obj(n).label=strjoin(allLabels,'/');
    % button
    button = h5read(FILE,'/Annotations');
    if ~isempty(button.Time)
        obj(n).buttonEnabled = 1;
        obj(n).button = double(button.Time);
    else
        obj(n).buttonEnabled = 0;
    end
    % accelerometer data:
    obj(n).accelEnabled=double(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Accelerometer Enabled'));
    if obj(n).accelEnabled
        accels=h5read(FILE,strcat('/Sensors/',monstr,'/Accelerometer'));
        obj(n).ax=accels(1,:)'; % (m/s^2) | acceleration in x
        obj(n).ay=accels(2,:)'; % (m/s^2) | acceleration in y
        obj(n).az=accels(3,:)'; % (m/s^2) | acceleration in z
    else; obj(n).ax=nan; obj(n).ay=nan; obj(n).az=nan;
    end
    
    % gyro data (angular velocities):
    obj(n).gyroEnabled=double(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Gyroscope Enabled'));
    if obj(n).gyroEnabled
        gyro=h5read(FILE,strcat('/Sensors/',monstr,'/Gyroscope'));
        obj(n).gx=gyro(1,:)'; % (rad/s) | angular velocity x
        obj(n).gy=gyro(2,:)'; % (rad/s) | angular velocity y
        obj(n).gz=gyro(3,:)'; % (rad/s) | angular velocity z
        %         gyroCal=h5read(FILE,strcat('/',monstr,'/Calibrated/','Gyroscopes'));
        %         obj(n).gxCal=gyroCal(1,:)'; % (rad/s) | angular velocity x
        %         obj(n).gyCal=gyroCal(2,:)'; % (rad/s) | angular velocity y
        %         obj(n).gzCal=gyroCal(3,:)'; % (rad/s) | angular velocity z
    else; obj(n).gx=nan; obj(n).gy=nan; obj(n).gz=nan;
    end
    
    % magnetometer data:
    obj(n).magEnabled=double(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Magnetometer Enabled'));
    if obj(n).magEnabled
        mags=h5read(FILE,strcat('/Sensors/',monstr,'/Magnetometer'));
        convmultiplier=1; % so stay in uT
        obj(n).mx=mags(1,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field x
        obj(n).my=mags(2,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field y
        obj(n).mz=mags(3,:)'.*convmultiplier; % [uT] -> [uT] | magnetic field z
    else; obj(n).mx=nan; obj(n).my=nan; obj(n).mz=nan;
    end
    
    obj(n).numSamples=length(obj(n).ax);
    obj(n).qAPDM=h5read(FILE,strcat('/Processed/',monstr,'/Orientation'))';
    [obj(n).eulerAPDM(:,1),obj(n).eulerAPDM(:,2),obj(n).eulerAPDM(:,3)]=quat2angle(obj(n).qAPDM,'ZYX'); % ZYX euler angles in radians
    
    % timevector
    obj(n).unixTime=double(h5read(FILE,strcat('/Sensors/',monstr,'/Time'))); % unix time in microseconds
    obj(n).datenumVec=obj(n).unixTime./86400./1E6 + datenum(1970,1,1)-datenum(0,0,0,5,0,0); % subtract 5 hours to put in EST
    obj(n).startTime = datestr(obj(n).datenumVec(1));
    obj(n).endTime = datestr(obj(n).datenumVec(end));
    timevec=obj(n).unixTime-obj(n).unixTime(1);
    obj(n).time=timevec./1E6; % convert to seconds to store in obj(n)
    obj(n).sampleRate=1/(obj(n).time(3)-obj(n).time(2)); % Hz
    
    obj(n).temperature=h5read(FILE,strcat('/Sensors/',monstr,'/Temperature')); % temperature in deg C
    
    % barometer data:
    obj(n).baroEnabled=double(h5readatt(FILE,strcat('/Sensors/',monstr,'/Configuration/'),'Barometer Enabled'));
    if obj(n).baroEnabled
        obj(n).barometer=h5read(FILE,strcat('/Sensors/',monstr,'/Barometer')); % presure in kPa
    else
        obj(n).barometer = nan;
    end
    
    for k=1:length(obj(n).ax)
        obj(n).normA(k)=norm([obj(n).ax(k) obj(n).ay(k) obj(n).az(k)]);
        obj(n).normG(k)=norm([obj(n).gx(k) obj(n).gy(k) obj(n).gz(k)]);
    end
    
    obj(n).enableVector = [obj(n).accelEnabled, obj(n).gyroEnabled, obj(n).magEnabled, obj(n).quatEnabled, obj(n).tempEnabled, obj(n).baroEnabled obj(n).eulerEnabled];
    
    %obj(n).data=[obj(n).ax obj(n).ay obj(n).az obj(n).gx obj(n).gy obj(n).gz obj(n).mx obj(n).my obj(n).mz];
%     waith=loop_waitbar(n,numSensors,ceil(numSensors/500),s,waith); % update waitbar
    textprogressbar(n/numSensors*100); % update textprogressbar
end
% waith=waitbar(1,waith,'OpalIMUConstruction Complete!'); close(waith);
textprogressbar(' Complete!');
end % constuctor v5


function [ID_list,num_list,stringMode]=get_sensor_list_v5(FILE)
% retrieves sensor list from v5 files
% makes a switch to see if it wants ID_list or num_list
info=h5info(FILE,'/Sensors/');
numSensors=length(info.Groups);
for k=1:numSensors
    sensor_paths{k}=info.Groups(k).Name;
    trash=strsplit(sensor_paths{k},'/');
    endstring=trash{end};
    if strcmp(endstring(1:2),'XI') % pull last 4 numbers, convert to num
        ID_list{k}=endstring;
        num_list(k)=str2num(endstring(end-3:end));
        stringMode=1; % wants ID list (XI-######)
    else
        num_list(k)=str2num(endstring); % straight number in list
        s='XI-000000'; % lets put numbers in there
        s(end-(length(num2str(num_list(k)))-1):end)=num2str(num_list(k));
        ID_list{k}=s;
        stringMode=2; % wants num_list
    end
end
end % retrieve sensor list v5

function h=loop_waitbar(k,N,m,s,h)
% input:
% k: iteration number
% N: total number of iterations
% m: how many iterations to update the waitbar on (updating it every
% iteration, i.e. m=1 is too slow
% s: handle to clock object you start at beginning of loop
% h: handle to waitbar
%% update waitbar
if mod(k,m)==0
    is = etime(clock,s); % elapsed time on clock from when it started
    isper=is/k; % average time per iteration
    esttime=isper*(N-k); % estimated time remaining
    str=sprintf('remaining time = %.2f sec',esttime); % string to print on waitbar box
    h = waitbar(k/N,h,str); % update percentage on waitbar
end
end

function [e1,e2,e3] = quat2ZYX(q)
    %This function takes quanternions and converts them to euler angles in
    %the ZYX (Body 3-2-1) euler angles 
    %code taken from Wikipedia: https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Quaternion_to_Euler_Angles_Conversion
    
    t0 = 2*(q(:,1).*q(:,2) + q(:,3).*q(:,4));
    t1 = 1 - 2*(q(:,2).^2 + q(:,3).^2);
    e1 = atan2(t0,t1);
    e1 = unwrap(e1);
    
    t2 = 2*(q(:,1).*q(:,3) - q(:,4).*q(:,2));
    if t2 > 1
        t2 = 1;
    elseif t2 < -1
        t2 = -1;
    end
    e2 = asin(t2);
    e2 = unwrap(e2);
    
    t3 = 2*(q(:,1).*q(:,4) + q(:,2).*q(:,3));
    t4 = 1 - 2*(q(:,3).^2 + q(:,4).^2);
    e3 = atan2(t3,t4);
    e3 = unwrap(e3);
end

function textprogressbar(c)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress (from 0 to 100)
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

%% Initialization
persistent strCR;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

%% Main 

if isempty(strCR) && ~ischar(c),
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(strCR) && ischar(c),
    % Progress bar - initialization
    fprintf('%s',c);
    strCR = -1;
elseif ~isempty(strCR) && ischar(c),
    % Progress bar  - termination
    strCR = [];  
    fprintf([c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
    c = floor(c);
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1,
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end
end % text progress bar
