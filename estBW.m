%% Estimate the minimum bandwidth with no freezes.
% estBW.m
% chenw@cmu.edu

% %% Logistics
% clear all;
% close all;
% clc;
% symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
% vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Processing the video
function estBW(vidName)
    % The video frame info.
    % vidName = 'brave';
    load(['./Mat/' vidName '-stat.mat']);

    % Load the info needed
    frmTyp = vidInfo.textdata(:, 2);
    frmSz = vidInfo.data .* 8 ./ 1024;
    frmNo = vidInfo.playSeq;

    %% Estimate the minimum bandwidth
    % The start delay
    D = 2;
    C = zeros(length(frmTyp), 1);
    for i = 1 : length(frmTyp)
        C(i) = sum(frmSz(1 : i)) ./ ((D + frmNo(i).*0.04) .* 1024);
    end

    [sortC, IX] = sort(C, 'descend');
    sortPlaySeq = frmNo(IX);

    save(['./Mat/' vidName '-sortBW.mat'], 'IX', 'sortC', 'sortPlaySeq', 'frmTyp');

    disp(['The bandwidth capacity needed for video ' vidName ' of generic streaming is ' num2str(sortC(1)) ' Mbps']);
end