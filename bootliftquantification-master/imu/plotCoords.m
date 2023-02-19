%function plotCoords(subject, config,t,side)
subject = 3;
config = 0;
t = 1;
side = 'r';
close all
% Change default axes fonts.

%(0,'DefaultAxesFontName', 'Helvetica')
%set(0,'DefaultAxesFontSize', 18)


% Change default text fonts.
%set(0,'DefaultTextFontname', 'Helvetica')
%set(0,'DefaultTextFontSize', 18)
set(0,'DefaultLineLineWidth',2)
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
srtib.euler=srtib.eulerFromQuart;

X = zeros(length(hrtib.time),3);
X(:,1) = 1;
Y = zeros(length(hrtib.time),3);
Y(:,2) = 1;
Z = zeros(length(hrtib.time),3);
Z(:,3) = 1;

Xg = quatrotate(hrtib.invquart, X);
Yg = quatrotate(hrtib.invquart, Y);
Zg = quatrotate(hrtib.invquart, Z);

angVert = zeros(1,length(Xg));
for i = 1:length(Xg)
    angVert(i) = rad2deg(atan2(norm(cross(-Z(i,:),Xg(i,:))), dot(-Z(i,:),Xg(i,:))));
end

for i=1:10:length(Xg)-50
    quiver3(0,0,0,Xg(i,1),Xg(i,2),Xg(i,3),'b')
    hold on
    quiver3(0,0,0,Yg(i,1),Yg(i,2),Yg(i,3),'g')
    quiver3(0,0,0,Zg(i,1),Zg(i,2),Zg(i,3),'r')
    quiver3(0,0,0,X(i,1),X(i,2),X(i,3),'b--')
    quiver3(0,0,0,Y(i,1),Y(i,2),Y(i,3),'g--')
    quiver3(0,0,0,Z(i,1),Z(i,2),Z(i,3),'r--')
    hold off
    axis([-1 1 -1 1 -1 1])
    pause(0.1)
end

