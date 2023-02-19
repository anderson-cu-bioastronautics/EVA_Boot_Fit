function processTrials()
for subject = 2:2
    for c = 1:2

            processsubTrials(subject,c)


    end
end
end


function processsubTrials(subject, config)
%Add functions subfolder to Path
subfolders = split(genpath(pwd),';');
for sf = 1:length(subfolders)
    if endsWith(subfolders{sf},'functions')
       addpath(subfolders{sf}) 
    end
end
addpath('Z:\ResearchData\NRI Study Data - Shared\IMU data\Subject '+string(subject))
fname =  strcat('Z:\ResearchData\NRI Study Data - Shared\IMU data\Subject '+string(subject),'\Subject', string(subject), '.mat');
configs = struct2cell(load(fname));

con = configs{config+1};
con{3} = strcat('Z:\ResearchData\NRI Study Data - Shared\IMU data\Subject '+string(subject),'\', con{3});
trials = IMUTrial(con);

for t = 1:length(trials)
    trialData = trials(t);
    trialDataCrop = cell(1,length(trialData.IMUs));
    for i = 1:length(trialData.IMUs)
       trialDataCrop{i} = getIMUData(trialData.IMUs(i)); 
    end
    varName = strcat('S',string(subject),'C',string(config),'T',string(t));
    disp(varName)
    S.(varName) = trialDataCrop;
    saveDir = strcat('Z:\ResearchData\NRI Study Data - Shared\IMU Data Processed\Subject',string(subject),'\','S',string(subject),'C',string(config),'T',string(t),'.mat');
    save(char(saveDir), '-struct', 'S')
    clear S
end
%{
SC = load('Subject3/S3C2.mat');
SC = SC.S3C2;

hrtib = getIMUData(SC.IMUs(4));
srtib = getIMUData(SC.IMUs(6));
hltib = getIMUData(SC.IMUs(8));
sltib = getIMUData(SC.IMUs(10));
%}
end
