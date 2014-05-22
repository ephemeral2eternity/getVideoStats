%% Estimate the minimum bandwidth for I, P, B frames.
% estIPBbw.m
% chenw@cmu.edu

% %% Logistics
% clear all;
% close all;
% clc;
% symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
% vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Processing the video
function estIPBbw(vidName)
    % The video frame info.
    % vidName = 'brave';
    load(['./Mat/' vidName '-stat.mat']);

    % Load the info needed
    frmTyp = vidInfo.textdata(:, 2);
    frmTS = vidInfo.textdata(:, 4);
    frmSz = vidInfo.data .* 8 ./ 1024;
    frmNo = vidInfo.playSeq;


    %% I Frame Sizes
    IFrmInd = strcmp(frmTyp, 'I');
    IFrmSz = frmSz(IFrmInd);
    IFrmNo = frmNo(IFrmInd);

    %% P Frame Sizes
    PFrmInd = strcmp(frmTyp, 'P');
    PFrmSz = frmSz(PFrmInd);
    PFrmNo = frmNo(PFrmInd);

    %% B Frame Sizes
    BFrmInd = strcmp(frmTyp, 'B');
    BFrmSz = frmSz(BFrmInd);
    BFrmNo = frmNo(BFrmInd);

    %% Estimate the minimum bandwidth
    % The start delay
    D = 2;

    %% Count the required bandwidth for I, P, B respectively
    % Process for I frames
    C_I = zeros(length(IFrmSz), 1);
    for i = 1 : length(IFrmSz)
        C_I(i) = sum(IFrmSz(1 : i)) ./ ((D + IFrmNo(i).*0.04) .* 1024);
    end

    [sortCI, IX_FrmI] = sort(C_I, 'descend');
    sortPlaySeqI = frmNo(IX_FrmI);
    save(['./Mat/' vidName '-sortBW-I.mat'], 'IX_FrmI', 'sortCI', 'sortPlaySeqI');

    % Process for P frames
    C_P = zeros(length(PFrmSz), 1);
    for i = 1 : length(PFrmSz)
        C_P(i) = sum(PFrmSz(1 : i)) ./ ((D + PFrmNo(i).*0.04) .* 1024);
    end

    [sortCP, IX_FrmP] = sort(C_P, 'descend');
    sortPlaySeqP = frmNo(IX_FrmP);
    save(['./Mat/' vidName '-sortBW-P.mat'], 'IX_FrmP', 'sortCP', 'sortPlaySeqP');

    % Process for B frames
    C_B = zeros(length(BFrmSz), 1);
    for i = 1 : length(BFrmSz)
        C_B(i) = sum(BFrmSz(1 : i)) ./ ((D + BFrmNo(i).*0.04) .* 1024);
    end

    [sortCB, IX_FrmB] = sort(C_B, 'descend');
    sortPlaySeqB = frmNo(IX_FrmB);
    save(['./Mat/' vidName '-sortBW-B.mat'], 'IX_FrmB', 'sortCB', 'sortPlaySeqB', 'frmTyp');

    disp(['The bandwidth capacity needed for video ' vidName ' of I frmaes is ' num2str(sortCI(1)) ' Mbps']);
    disp(['The bandwidth capacity needed for video ' vidName ' of P frames is ' num2str(sortCP(1)) ' Mbps']);
    disp(['The bandwidth capacity needed for video ' vidName ' of B frames is ' num2str(sortCB(1)) ' Mbps']);

end
