% getYUV.m WCC-2008-07-09
% *****************************************************
% Only supports 4 : 2 : 0 formats.
% SQCIF : 128 ¡Á 96 
% QCIF : 144 X 176
% CIF : 288 X 352
% 4CIF : 576 X 720
% 16CIF : 1408 ¡Á 1152 
% *****************************************************
function [fid, vInfo] = getYUV(videoName, vType, width, height);

% clear all;
% close all;
% videoName = 'H:\video\sch.yuv';
% vInfo.type = 'T420';
% ind = 100;

% Get postfix of the videoName
len = size(videoName, 2);
i = findstr('.', videoName);
vPostfix = videoName(i+1 : len);

%------------------------------------------------------------
% OPTIONAL ARGS:

if (exist('vType') ~= 1)
    vInfo.type = 'T420';
else
    vInfo.type = vType;
end


if (exist('width') ~= 1) || (exist('height') ~= 1)
    switch vPostfix
        case 'sqcif' 
            vInfo.height = 96, vInfo.width = 128;
        case 'qcif' 
            vInfo.height = 144, vInfo.width = 176;
        case 'cif'
            vInfo.height = 288, vInfo.width = 352;
        case '4cif'
            vInfo.height = 476, vInfo.width = 720;
        case '16cif'
            vInfo.height = 1152, vInfo.width = 1408;
        otherwise
            disp('The function does not support the input video format, please give width and height.')
            vInfo.width = 0;
            vInfo.height = 0;
    end
else
    vInfo.width = width;
    vInfo.height = height;
end

fid = fopen(videoName, 'r');








