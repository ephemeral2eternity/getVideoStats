%% Count how many frames will be dropped when we squeeze the bandwidth 
%% for generic streaming
% cntFrmsDrops.m
% chenw@cmu.edu

%% Logistics
clear all;
close all;
clc;
symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
vidNames = {'cloudAtlas', 'hungerGame', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Select one video to process
vidName = 'brave';
vidBW = load(['./Mat/' vidName '-sortBW.mat']);
reqBW = vidBW.sortC;
sortIX = vidBW.IX;
sortPlaySq = vidBW.sortPlaySeq;
frmTyp = vidBW.frmTyp;

% %% Print out the number of frames to drop, the types of frames to drop, and
% % corresponding bandwidth needed
% for i = 1 : 100
%     disp(['Dropped frame: ' num2str(frmInfo(i, 1)), 'Dropped type: ' frmTyp(frmInfo(i, 1)), 'Given Bandwidth: ', num2str(frmInfo(i, 2))]);
% end

% droppedFrames = 1 : size(frmInfo, 1);
% figure, plot(frmInfo(:, 2), droppedFrames);
sqzedBW = 5 : 0.1 : 6;
DroppedFrms = zeros(length(sqzedBW), 4);
for i = 1 : length(sqzedBW)
    droppedIdx = sortIX(reqBW > sqzedBW(i));
    
    % Count dropped numbers in each type
    droppedTyp = frmTyp(droppedIdx);
    dropppedFrmI = strcmp(droppedTyp, 'I');
    dropppedFrmP = strcmp(droppedTyp, 'P');
    dropppedFrmB = strcmp(droppedTyp, 'B');
    DroppedFrms(i, 1) = length(droppedTyp);
    DroppedFrms(i, 2) = sum(dropppedFrmI);
    DroppedFrms(i, 3) = sum(dropppedFrmP);
    DroppedFrms(i, 4) = sum(dropppedFrmB);
    
    % Count the propagation factor
    propFactor = false(length(frmTyp), 1);
    sortDroppedIdx = sort(droppedIdx, 'ascend');
end


