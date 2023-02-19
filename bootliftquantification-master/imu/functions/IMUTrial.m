classdef IMUTrial < handle
    %Converts Opal IMU data into full RCM analysis 
    properties (Hidden)
        IMUs
        IMUNames
        strIdx
        endIdx
    end
    properties 
        subject
        config
        trialNum
        numSamples
        trialLength
        time
        sampleRate
    end
    methods
        function obj = IMUTrial(sfile)
            switch nargin 
                case 0
                    return;
                case 1
                    if isnumeric(sfile)
                        obj(sfile) = IMUTrial();
                    else
                        obj = loadTrialData(sfile);
                    end                    
            end
        end
        
        function figh = plot_IMUTrial(obj,Names)
            if isempty(Names)
                Names = 'Right Tibia';
            end
            Idxs = ~cellfun(@isempty,regexp(Names,obj.IMUNames));
            IMU_parse = copy(obj.IMUs(Idxs));
            IMU_parse.label = [IMU_parse.label, ' (',obj.config,' T',num2str(obj.trialNum),')'];
            figh = plot_data(IMU_parse,'agqn');
        end
    end
end

function obj = loadTrialData(sfile)
    sID = sfile{1};
    obj = IMUTrial(sfile{2});
    IMUs = OpalIMUData(sfile{3});
    loadCalFile(IMUs,sfile{5});
    timestamps = sfile{4};
    for n = 1:length(obj)   
        obj(n).subject = sID(1:2);
        obj(n).config = sID(3:4);
        obj(n).trialNum = n;
        obj(n).strIdx = timestamps(n,1);
        obj(n).endIdx = timestamps(n,2); 
        obj(n).IMUs = cutOpalIMU(IMUs,obj(n).strIdx-128,obj(n).endIdx+2*128);
        obj(n).time = obj(n).IMUs(1).time;
        obj(n).sampleRate = obj(n).IMUs(1).sampleRate;
        obj(n).trialLength = obj(n).time(end);
        obj(n).numSamples = length(obj(n).time);
        for s = 1:length(obj(n).IMUs)
            obj(n).IMUNames{s} = obj(n).IMUs(s).label;
        end
    end
    fprintf('Subject %s, Config %s successfully loaded\n',obj(1).subject(2),obj(1).config);
end