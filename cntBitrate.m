%% Count bitrates for I, P, B frames
% cntBitrate.m
% chenw@cmu.edu

%% Logistics
clear all;
close all;
clc;
symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Processing the video
% The video frame info.
vidName = 'big_buck_bunny';
vidInfo = load(['./Mat/' vidName '.mat']);

% Load the info needed
frmTyp = vidInfo.frm_typ;
% frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data .* 8 ./ 1024;

win_sz = 5;
frm_rate = 25;

%% Count bitrate per second
% Compute the whole bitrate

if (rem(length(frmSz),frm_rate*win_sz) ~= 0)
    wholeFrmSz = [frmSz; zeros(frm_rate*win_sz - rem(length(frmSz),frm_rate*win_sz), 1)];
else
    wholeFrmSz = frmSz;
end
frmSzMat = reshape(wholeFrmSz, frm_rate*win_sz, ceil(length(wholeFrmSz)/(frm_rate*win_sz)));
frmBitrate = sum(frmSzMat, 1)./(1024.*win_sz);

% Compute the I bitrate
IFrmInd = strcmp(frmTyp, 'I');
if (rem(length(IFrmInd),frm_rate*win_sz) ~= 0)
    IFrmInd = [IFrmInd; zeros(frm_rate*win_sz - rem(length(IFrmInd),frm_rate*win_sz), 1)];
end
IFrmSz = wholeFrmSz .* IFrmInd;
IFrmSzMat = reshape(IFrmSz, frm_rate*win_sz, ceil(length(frmSz)/(frm_rate*win_sz)));
Ibitrate = sum(IFrmSzMat, 1)./(1024.*win_sz);

% Compute the P bitrate
PFrmInd = strcmp(frmTyp, 'P');
if (rem(length(PFrmInd),frm_rate*win_sz) ~= 0)
    PFrmInd = [PFrmInd; zeros(frm_rate*win_sz - rem(length(PFrmInd),frm_rate*win_sz), 1)];
end
PFrmSz = wholeFrmSz .* PFrmInd;
PFrmSzMat = reshape(PFrmSz, frm_rate*win_sz, ceil(length(frmSz)/(frm_rate*win_sz)));
Pbitrate = sum(PFrmSzMat, 1)./(1024.*win_sz);

% Compute the P bitrate
BFrmInd = strcmp(frmTyp, 'B');
if (rem(length(BFrmInd),frm_rate*win_sz) ~= 0)
    BFrmInd = [BFrmInd; zeros(frm_rate*win_sz - rem(length(BFrmInd),frm_rate*win_sz), 1)];
end
BFrmSz = wholeFrmSz .* BFrmInd;
BFrmSzMat = reshape(BFrmSz, frm_rate*win_sz, ceil(length(frmSz)/(frm_rate*win_sz)));
Bbitrate = sum(BFrmSzMat, 1)./(1024.*win_sz);

%% Draw the bitrate
f = figure(1); hold on;
plot((1 : length(frmBitrate)).*win_sz, frmBitrate, symbols{1}, 'LineWidth', 2);
plot((1 : length(frmBitrate)).*win_sz, Ibitrate, symbols{2}, 'LineWidth', 2);
plot((1 : length(frmBitrate)).*win_sz, Pbitrate, symbols{3}, 'LineWidth', 2);
plot((1 : length(frmBitrate)).*win_sz, Bbitrate, symbols{4}, 'LineWidth', 2);
xlabel('Time (secs)', 'fontsize', 12);
ylabel('Bitrate (Mbps)', 'fontsize', 12);
legend('Total Bitrate', 'I Bitrate', 'P Bitrate', 'B Bitrate');
plot((1 : length(frmBitrate)).*win_sz, 10, symbols{6}, 'LineWidth', 2);
hold off;

print(f, '-dpng', '-painters', '-r100', ['./data/' vidName '-IPB-bitrate.png']);

save(['./Mat/' vidName '-bitrates.mat'], 'frmBitrate', 'Ibitrate', 'Pbitrate', 'Bbitrate');

disp(['====================== The video ', vidName, '======================']);
disp(['The average total bitrate is ', num2str(mean(frmBitrate))]);
disp(['The standard deviation of the total bitrate is ', num2str(std(frmBitrate))]);
disp(['The average I frame bitrate is ', num2str(mean(Ibitrate))]);
disp(['The standard deviation of I frame bitrate is ', num2str(std(Ibitrate))]);
disp(['The average P frame bitrate is ', num2str(mean(Pbitrate))]);
disp(['The standard deviation of P frame bitrate is ', num2str(std(Pbitrate))]);
disp(['The average B frame bitrate is ', num2str(mean(Bbitrate))]);
disp(['The standard deviation of B frame bitrate is ', num2str(std(Bbitrate))]);



