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

%% Get I, P, B indexs
idx = 1 : length(frmTyp);
IFrmInd = idx(strcmp(frmTyp, 'I'));
PFrmInd = idx(strcmp(frmTyp, 'P'));
BFrmInd = idx(strcmp(frmTyp, 'B'));


sqzedBW = 5 : 0.1 : 6;
DroppedFrms = zeros(length(sqzedBW), 5);
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
    
    if numel(sortDroppedIdx) ~= 0
        j = sortDroppedIdx(1);
        while(j <= sortDroppedIdx(end))
            if strcmp(frmTyp(j), 'I')
                s = j;
                if (find(IFrmInd == s) + 1 < length(IFrmInd))
                    e = IFrmInd(find(IFrmInd == s) + 1) - 1;
                else
                    e = sortDroppedIdx(end);
                end
                propFactor(s : e) = true;
            elseif strcmp(frmTyp(j), 'P')
                s = j;
                if (find(PFrmInd == s) + 1 < length(PFrmInd))
                    e = PFrmInd(find(PFrmInd == s) + 1) - 1;
                else
                    e = sortDroppedIdx(end);
                end
                propFactor(s : e) = true;
            elseif strcmp(frmTyp(j), 'B')
                e = j;
                propFactor(e) = true;
            end

            f = sortDroppedIdx(sortDroppedIdx > e);
            if numel(f) > 0
                j = f(1);
            else
                j = sortDroppedIdx(end)+1;
            end
            clear f;
        end

        profFactorCoef = sum(propFactor);
        DroppedFrms(i, 5) = profFactorCoef;

        disp(['The propagation factor for bandwidth ' num2str(sqzedBW(i)) ' is ' num2str(profFactorCoef)]);
    else
        DroppedFrms(i, 5) = 0;
        disp(['The propagation factor for bandwidth ' num2str(sqzedBW(i)) ' is 0' ]);
    end
end

figure(1), hold on;
title(['The tradeoff between bandwidth and dropped frames for video ' vidName]);
plot(sqzedBW, DroppedFrms(:, 1), symbols{1});
plot(sqzedBW, DroppedFrms(:, 2), symbols{2});
plot(sqzedBW, DroppedFrms(:, 3), symbols{3});
plot(sqzedBW, DroppedFrms(:, 4), symbols{4});
plot(sqzedBW, DroppedFrms(:, 5), symbols{5});
legend('Total Frames', 'I Frames', 'P Frames', 'B Frames', 'Propagation Factor');
xlabel('The bandwidth (Mbps)', 'fontsize', 12);
ylabel('The number of frames', 'fontsize', 12);
hold off;

%% If we only drops B Frames
vidBW_I = load(['./Mat/' vidName '-sortBW-I.mat']);
vidBW_P = load(['./Mat/' vidName '-sortBW-P.mat']);
vidBW_B = load(['./Mat/' vidName '-sortBW-B.mat']);

sortCB = vidBW_B.sortCB;

BW_I = vidBW_I.sortCI(1);
BW_P = vidBW_P.sortCP(1);

DroppedBFrms = zeros(length(sqzedBW), 1);
for i = 1 : length(sqzedBW)
    BW_B = sqzedBW(i) - BW_I - BW_P;
    profFactorCoef = sum(sortCB > BW_B);
    DroppedBFrms(i) = profFactorCoef;
end

figure(2), hold on;
title(['Propagation Factor Comparison with Prioritizing I, P frames for video ' vidName]);
plot(sqzedBW, DroppedFrms(:, 5), symbols{1});
plot(sqzedBW, DroppedBFrms, symbols{2});
legend('Generic Streaming', 'IPB Streaming with only B Dropping');
xlabel('The bandwidth (Mbps)', 'fontsize', 12);
ylabel('The propagation factor', 'fontsize', 12);
hold off;

