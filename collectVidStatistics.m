% collectVidStatistics.m
% chenw@cmu.edu

clear all;
close all;
clc;

vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

Ratios = [];
for vidInd = 1 : 11
% The video request arrival rate.
vidInfo = load(['./Mat/' vidNames{vidInd} '.mat']);

% Load the info needed
% frmNum = vidInfo.textdata(:, 1);
frmTyp = vidInfo.textdata(:, 2);
% frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data ./ 1024;


%% I Frame Sizes
IFrmInd = strcmp(frmTyp, 'I');
IFrmSz = frmSz .* IFrmInd;
IFrmIndex = find(IFrmInd == 1);
IFrmIntv = IFrmIndex(2 : end) - IFrmIndex(1 : end - 1);

%% P Frame Sizes
PFrmInd = strcmp(frmTyp, 'P');
PFrmSz = frmSz .* PFrmInd;
PFrmIndex = find(PFrmInd == 1);
PFrmIntv = PFrmIndex(2 : end) - PFrmIndex(1 : end - 1);
% figure(2), hist(PFrmIntv, 10);



%% B Frame Sizes
BFrmInd = strcmp(frmTyp, 'B');
BFrmSz = frmSz .* BFrmInd;
BFrmIndex = find(BFrmInd == 1);
BFrmIntv = BFrmIndex(2 : end) - BFrmIndex(1 : end - 1);
% figure(3), hist(BFrmIntv, 10);

%% Plot and Save Frame Distribution
f = figure(4);
hold on;
title(['The traffic profiles of Movie Clip --- ' vidNames{vidInd}]);
stem(IFrmSz, 'r-', 'Marker','none');
stem(PFrmSz, 'g-', 'Marker','none');
stem(BFrmSz, 'k-', 'Marker','none');
legend('I Frame', 'P Frame', 'B Frame');
xlabel('The index of frames', 'fontsize', 12);
ylabel('The size of frames (KB).', 'fontsize', 12);
axis([0 length(frmSz) 0 500]);
hold off;

%% Save Plotted Images
%print(f, '-dpng', '-r300', ['D:\Dropbox\Research\WeeklyUpdate\20121014\' vidNames{vidInd} '.png']);
print(f, '-dpng', '-painters', '-r100', ['./data/' vidNames{vidInd} '.png']);

%% Compute the statistics of IPB frames
IRatio = sum(IFrmSz)./ sum(frmSz);
PRatio = sum(PFrmSz)./ sum(frmSz);
BRatio = sum(BFrmSz)./ sum(frmSz);

%% Compute the interval statistics of IPB frames
IFrmIntMean = mean(IFrmIntv);
IFrmIntStd = std(IFrmIntv);

PFrmIntMean = mean(PFrmIntv);
PFrmIntStd = std(PFrmIntv);

BFrmIntMean = mean(BFrmIntv);
BFrmIntStd = std(BFrmIntv);


save(['./Mat/' vidNames{vidInd} '-ratio.mat'], 'IRatio', 'PRatio', 'BRatio');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp(['The I frame ratio of video ' vidNames{vidInd} ' is ' num2str(IRatio)]);
disp(['The P frame ratio of video ' vidNames{vidInd} ' is ' num2str(PRatio)]);
disp(['The B frame ratio of video ' vidNames{vidInd} ' is ' num2str(BRatio)]);
% %% For Display
% % disp('===============================================================');
% vidNames{vidInd}
% % IRatio
% % PRatio
% % BRatio
% 
% IFrmIntMean
% IFrmIntStd
% PFrmIntMean
% PFrmIntStd
% BFrmIntMean
% BFrmIntStd

Ratios = [Ratios; IRatio PRatio BRatio];

clear vidInfo;
end