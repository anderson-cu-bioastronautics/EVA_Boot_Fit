close all
meas = csvread('lags.csv');
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
        	ylim([0,0.4])
        end
        
    end
end






step = 0.005;
bins = 0:step:0.4;
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
             
             
redseq = ["#383661", "#3a3862", "#3c3964", "#3e3b65", "#403d67", "#413f68", "#43406a", "#45426b", "#47446d", "#49466e", "#4b4870", "#4d4971", "#4f4b73", "#514d74", "#534f76", "#545177", "#565379", "#58547a", "#5a567c", "#5c587d", "#5e5a7f", "#605c81", "#625e82", "#646084", "#666285", "#686487", "#6a6588", "#6b678a", "#6d698b", "#6f6b8d", "#716d8e", "#736f90", "#757192", "#777393", "#797595", "#7b7796", "#7d7998", "#7f7b99", "#817d9b", "#837f9c", "#85819e", "#8783a0", "#8985a1", "#8b87a3", "#8d89a4", "#8f8ba6", "#918da8", "#938fa9", "#9591ab", "#9793ac", "#9995ae", "#9b97b0", "#9d99b1", "#9f9bb3", "#a19db4", "#a39fb6", "#a5a1b8", "#a7a4b9", "#a9a6bb", "#aba8bc", "#adaabe", "#afacc0", "#b1aec1", "#b3b0c3", "#b5b2c5", "#b7b4c6", "#b9b6c8", "#bbb9c9", "#bdbbcb", "#bfbdcd", "#c2bfce", "#c4c1d0", "#c6c3d2", "#c8c5d3", "#cac8d5", "#cccad7", "#ceccd8", "#d0ceda", "#d2d0dc", "#d4d2dd", "#d6d5df", "#d9d7e1", "#dbd9e2", "#dddbe4", "#dfdde6", "#e1e0e7", "#e3e2e9", "#e5e4eb", "#e7e6ec", "#eae9ee", "#ecebf0", "#eeedf1", "#f0eff3", "#f2f1f5", "#f4f4f7", "#f6f6f8", "#f9f8fa", "#fbfafc", "#fdfdfd", "#ffffff"];
redseq = hex2rgb(char(redseq'));


             
for i = 1:length(allConditions)
    iBins = histcounts(allConditions{i}, bins);


    for b = 1:length(iBins)
        patch([0+i,0+i,1+i,1+i],[step*(b-1),step*b,step*b,step*(b-1)],redseq(100-(iBins(b)*2),:),'EdgeColor', 'none')

    end
end


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
