close all
meas = csvread('meas.csv');
numSteps = size(meas,2)-4;

figure;
hold on

markers = ['r','^', 'o', 'square'];
colors = [188 39 49
          54 134 160
          129 190 161]/255;

s2c0= [];
s2c1= [];
s2c2= [];

s3c0= [];
s3c1= [];
s3c2= [];

s4c0= [];
s4c1= [];
s4c2= [];



for k = 1:numSteps
    for n = 1:size(meas,1)
        trial = meas(n,3);
        subject = meas(n,1);
        condition = meas(n,2)+1;
        if meas(n,k+4)~= 0
            if subject == 2
               if condition == 1
                   s2c0 = [s2c0, meas(n,k+4)];
               elseif condition == 2
                   s2c1 = [s2c1, meas(n,k+4)];
               elseif condition == 3
                   s2c2 = [s2c2, meas(n,k+4)];
               end
            elseif subject == 3
               if condition == 1
                   s3c0 = [s3c0, meas(n,k+4)];
               elseif condition == 2
                   s3c1 = [s3c1, meas(n,k+4)];
               elseif condition == 3
                   s3c2 = [s3c2, meas(n,k+4)];
               end
            elseif subject == 4
               if condition == 1
                   s4c0 = [s4c0, meas(n,k+4)];
               elseif condition == 2
                   s4c1 = [s4c1, meas(n,k+4)];
               elseif condition == 3
                   s4c2 = [s4c2, meas(n,k+4)];
               end
            end
            plot(trial, meas(n,k+4),'Marker', markers(subject),'MarkerFaceColor',colors(condition,:),'MarkerSize', 10)
        	ylim([0,5])
        end
        
    end
end






step = 0.25;
bins = 0:step:1;
nbins = length(bins);
figure;

allConditions = {s2c0
                 s2c1
                 s2c2
                 s3c0
                 s3c1
                 s3c2
                 s4c0
                 s4c1
                 s4c2};
             
             
redseq = ["#383661", "#393862", "#3b3a63", "#3c3c64", "#3e3e65", "#3f4166", "#404368", "#424569", "#43476a", "#44496b", "#464b6c", "#474e6d", "#48506e", "#4a526f", "#4b5470", "#4c5671", "#4e5972", "#4f5b74", "#505d75", "#515f76", "#536177", "#546478", "#556679", "#56687a", "#586b7b", "#596d7c", "#5a6f7d", "#5b717e", "#5d747f", "#5e7681", "#5f7882", "#607b83", "#617d84", "#637f85", "#648286", "#658487", "#668688", "#678989", "#698b8a", "#6a8d8b", "#6b908c", "#6c928e", "#6d948f", "#6f9790", "#709991", "#719c92", "#729e93", "#73a194", "#74a395", "#76a596", "#77a897", "#78aa98", "#79ad99", "#7aaf9b", "#7bb29c", "#7cb49d", "#7eb79e", "#7fb99f", "#80bca0", "#81bea1"];
redseq = hex2rgb(char(flip(redseq)'));

%redseq = redseq(1:100,:);
redseq(1,:) = [1, 1, 1];

allVals = [];

for i = 1:length(allConditions)
    iBins = histcounts(allConditions{i}, bins);
    
    for b = 1:length(iBins)
        allVals=[allVals, iBins(b)];

    end
end

redseq = redseq(length(redseq)-max(allVals):end,:);
redseq(1,:) = [1, 1, 1];

offset=0;
for i = 1:length(allConditions)
    iBins = histcounts(allConditions{i}, bins);
    if i == 4 || i ==7
        disp(i)
        offset = offset+1;
    end
    ii = i+offset;
    
    for b = 1:length(iBins)
        patch([0+ii,0+ii,1+ii,1+ii],[step*(b-1),step*b,step*b,step*(b-1)],redseq((iBins(b)+1),:),'EdgeColor', 'none')

    end
end
set(gca,'xticklabel',[])
ylim([0,2.75])
colormap(redseq)
c=colorbar('eastoutside','Ticks',[0,0.25,0.5,0.75,1],'AxisLocation','out',...
         'TickLabels',{num2str(0,'%i'),num2str(round(0.25*60),'%i'),num2str(round(0.5*60),'%i'),num2str(round(0.75*60),'%i'),num2str(60,'%i')});
%c.Label.String = 'Counts of heel lift';

function [ rgb ] = hex2rgb(hex,range)
% hex2rgb converts hex color values to rgb arrays on the range 0 to 1. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% SYNTAX:
% rgb = hex2rgb(hex) returns rgb color values in an n x 3 array. Values are
%                    scaled from 0 to 1 by default. 
%                    
% rgb = hex2rgb(hex,256) returns RGB values scaled from 0 to 255. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% EXAMPLES: 
% 
% myrgbvalue = hex2rgb('#334D66')
%    = 0.2000    0.3020    0.4000
% 
% 
% myrgbvalue = hex2rgb('334D66')  % <-the # sign is optional 
%    = 0.2000    0.3020    0.4000
% 
%
% myRGBvalue = hex2rgb('#334D66',256)
%    = 51    77   102
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myrgbvalues = hex2rgb(myhexvalues)
%    =   0.2000    0.3020    0.4000
%        0.5020    0.6000    0.7020
%        0.8000    0.6000    0.2000
%        0.2000    0.2000    0.9020
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myRGBvalues = hex2rgb(myhexvalues,256)
%    =   51    77   102
%       128   153   179
%       204   153    51
%        51    51   230
% 
% HexValsAsACharacterArray = {'#334D66';'#8099B3';'#CC9933';'#3333E6'}; 
% rgbvals = hex2rgb(HexValsAsACharacterArray)
% 
% * * * * * * * * * * * * * * * * * * * * 
% Chad A. Greene, April 2014
%
% Updated August 2014: Functionality remains exactly the same, but it's a
% little more efficient and more robust. Thanks to Stephen Cobeldick for
% the improvement tips. In this update, the documentation now shows that
% the range may be set to 256. This is more intuitive than the previous
% style, which scaled values from 0 to 255 with range set to 255.  Now you
% can enter 256 or 255 for the range, and the answer will be the same--rgb
% values scaled from 0 to 255. Function now also accepts character arrays
% as input. 
% 
% * * * * * * * * * * * * * * * * * * * * 
% See also rgb2hex, dec2hex, hex2num, and ColorSpec. 
% 
%% Input checks:
assert(nargin>0&nargin<3,'hex2rgb function must have one or two inputs.') 
if nargin==2
    assert(isscalar(range)==1,'Range must be a scalar, either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end
%% Tweak inputs if necessary: 
if iscell(hex)
    assert(isvector(hex)==1,'Unexpected dimensions of input hex values.')
    
    % In case cell array elements are separated by a comma instead of a
    % semicolon, reshape hex:
    if isrow(hex)
        hex = hex'; 
    end
    
    % If input is cell, convert to matrix: 
    hex = cell2mat(hex);
end
if strcmpi(hex(1,1),'#')
    hex(:,1) = [];
end
if nargin == 1
    range = 1; 
end
%% Convert from hex to rgb: 
switch range
    case 1
        rgb = reshape(sscanf(hex.','%2x'),3,[]).'/255;
    case {255,256}
        rgb = reshape(sscanf(hex.','%2x'),3,[]).';
    
    otherwise
        error('Range must be either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end
end
