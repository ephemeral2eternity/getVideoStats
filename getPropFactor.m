%% Get the propagation factor for all I, P, B frames.
% getPropFactor.m
% chenw@cmu.edu

%% Logistics
clear all;
close all;
clc;
% symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
% vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Compute the propagation factor.
% The video frame info.
vidName = 'brave';
load(['./Mat/' vidName '-stat.mat']);
propFactor = zeros(size(vidInfo.data));

% Load the info needed
frmTyp = vidInfo.textdata(:, 2);
frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data .* 8 ./ 1024;
frmNo = vidInfo.playSeq;


%% I Frame Sizes
IFrm = strcmp(frmTyp, 'I');
IFrmSz = frmSz(IFrm);
IFrmIndex = frmNo(IFrm);
vidLen = length(frmTyp);
IFrmIdxShift = [IFrmIndex(2 : end); vidLen + 1];
propFactor(IFrm) = IFrmIdxShift - IFrmIndex + 1;


%% P Frame Sizes
PFrm = strcmp(frmTyp, 'P');
PFrmSz = frmSz(PFrm);
PFrmIndex = frmNo(PFrm);
PFrmIdxShift = [PFrmIndex(2 : end); vidLen + 1];
propFactor(PFrm) = PFrmIdxShift - PFrmIndex;

%% B Frame Sizes
BFrm = strcmp(frmTyp, 'B');
BFrmSz = frmSz(BFrm);
propFactor(BFrm) = 1;


f = figure(1);
hold on;
plot(propFactor, symbols{1}, 'LineWidth', 2); xlabel('Frame No.', 'fontsize', 12); ylabel('The propagation factor (The number of frames impacted).', 'fontsize', 12); title(vidName, 'fontsize', 12);
hold off;
print(f, '-dpng', '-painters', '-r100', ['.\data\' vidNames '-propFactor.png']);

f = figure(2);
hold on;
plot(frmSz, symbols{2}, 'LineWidth', 2); xlabel('Frame No.', 'fontsize', 12); ylabel('The frame size (kb).', 'fontsize', 12);title(vidName, 'fontsize', 12);
hold off;
print(f, '-dpng', '-painters', '-r100', ['.\data\' vidNames '-frmSz.png']);

importanceIdx = 0.5*frmSz ./ max(frmSz) + 0.5*propFactor ./ max(propFactor);
f = figure(3);
hold on;
plot(importanceIdx, symbols{3}, 'LineWidth', 2); xlabel('Frame No.', 'fontsize', 12); ylabel('The Importance Index 1.', 'fontsize', 12);title(vidName, 'fontsize', 12);
hold off;

save(['.\Mat\' vidName '-ImpIdx.mat'], 'importanceIdx');

xBin = [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.5 1];
n = hist(importanceIdx, xBin);
figure(4), bar(xBin, n, 'hist');
cumHist = cumsum(n);
figure(5), plot(xBin, cumHist./ max(cumHist), '-b', 'LineWidth', 2); 
xlabel('Importance Index', 'fontsize', 12); 
ylabel('CDF', 'fontsize', 12);
title(vidName, 'fontsize', 12);