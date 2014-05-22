%% Compute the displaying sequence according to the decoding sequence and
% frame types.
% compPBNo.m
% chenw@cmu.edu

%% Logistics
clear all;
close all;
clc;
symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Processing the video
% The video frame info.
vidName = 'simpsons';
vidInfo = load(['./Mat/' vidName '.mat']);

% Load the info needed
frmTyp = vidInfo.textdata(:, 2);
frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data .* 8 ./ 1024;

%% Compute the playback sequence according to the decoding sequence.
PBNo = zeros(length(frmTyp), 1);
if (strcmp(frmTyp(1), 'I') == 1)
    PBNo(1) = 1;
else
    error('The video is incomplete because the first frame is not Intra-encoded frame!');
end
i = 2;
while (i <= length(frmTyp))
    if (strcmp(frmTyp(i), 'I') == 1) || (strcmp(frmTyp(i), 'P') == 1)
        j = i + 1;
        s = i;
        d = i;      % Displaying No.
        while (j <= length(frmTyp))
            if (strcmp(frmTyp(j), 'B') == 1)
                PBNo(j) = d;
                d = d + 1;
                j = j + 1;
            else
                break;
            end
        end
        PBNo(s) = d;
    end
    i = i + 1;
end

vidInfo.playSeq = PBNo;
save(['./Mat/' vidName '-stat.mat'], 'vidInfo');