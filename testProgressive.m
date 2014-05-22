%% Test progressive downloading method.
% testProgessive.m
% chenw@cmu.edu

%% Logistics
clear all;
close all;
clc;
symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Compute the propagation factor.
% The video frame info.
vidName = 'brave';
load(['./Mat/' vidName '-stat.mat']);
load(['./Mat/' vidName '-bitrates.mat']);
load(['./Mat/' vidName '-ImpIdx.mat']);
frmRate = 25;
chunkLen = 2;
bufSz = 6;

% Load the info needed
frmTyp = vidInfo.textdata(:, 2);
frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data .* 8 ./ (1024^2);
frmNo = (1 : length(frmSz))';

if mod(length(frmSz), frmRate) ~= 0
    frmSz = [frmSz; zeros(frmRate*chunkLen - mod(length(frmSz), frmRate*chunkLen), 1)];
    frmNo = [frmNo; zeros(frmRate*chunkLen - mod(length(frmNo), frmRate*chunkLen), 1)];
end
frmSzArry = reshape(frmSz, frmRate*chunkLen, length(frmSz)/(frmRate*chunkLen));
frmNoArry = reshape(frmNo, frmRate*chunkLen, length(frmNo)/(frmRate*chunkLen));

%% Construct the estimated available bandwidth
expNo = 1;
totalTime = 200;
chunkNo = totalTime ./ chunkLen;
availBW = zeros(chunkNo, 1);
ind = 1:chunkNo;
lowIdx = (mod(ind, 10) <= 5) & (mod(ind, 10) > 0);
highIdx = ~lowIdx;
availBW(lowIdx) = 5;
availBW(highIdx) = 5;
% f = figure(1); hold on;
% plot(2.*(1 : chunkNo), availBW, symbols{1});
% plot(frmBitrate, symbols{2});
% xlabel('The time (secs)');
% ylabel('The available bandwidth (Mbps)');
% axis([0 length(frmSz)./frmRate 0 max(frmBitrate)]);
% legend('The available bandwidth', 'The actual bitrate');
% hold off;
% print(f, '-dpng', '-painters', '-r100', ['./exp/' vidName num2str(expNo) '.png']);


%% Emulate the progressive downloading according to the available bandwidth
% Get the 5 sec buffer filled as fast as possible
bufEvents = []; 
state = 'Buffering';
T = 1 ./ frmRate;

TS = 0;     % The Time Stamp will be got based on the start playing timestamp
i = 1;      % Download Chunk Index
curFrm = 0;     % The frame that is played now
downloadLen = 0;    % The time period that is used to download the chunk.
bufferingTime = 0;
while i <= size(frmNoArry, 2)
    if strcmp(state, 'Buffering')
        for j = i : i + bufSz/chunkLen - 1
            bw = availBW(floor(TS./chunkLen) + 1);
            datSz = frmSzArry(:, j);
            TS = TS + sum(datSz) ./ bw;
            bufferingTime = bufferingTime + sum(datSz) ./ bw;
        end
        state = 'Steady';
        i = i + bufSz/chunkLen;
        curBufSz = bufSz;
        
        bufEvents = [bufEvents; curFrm bufferingTime];
        disp(['======= The player is buffering with period ' num2str(bufferingTime) ' at frame ' ...
            num2str(curFrm) '!!!! ======']);
    elseif strcmp(state, 'Steady')
        curFrm = curFrm + floor(max(chunkLen, downloadLen) * frmRate);
        estBW = availBW(floor(TS./chunkLen) + 1);
        downloadLen = sum(frmSzArry(:, i)) ./ estBW;
            
        % Update the playback frame index and the downloading time for 
        % the new chunk
        if (downloadLen <= curBufSz)
            curBufSz = curBufSz - downloadLen + chunkLen;
            state = 'Steady';
        elseif (downloadLen > curBufSz)
            curBufSz = 0;
            state = 'Buffering';
        end

        i = i + 1;
        % The end of state changing session
    end
    % The end of video sending session
end

save(['./exp/' vidName '-progressive-' num2str(expNo) '.mat'], 'bufEvents');

%% Plot buffering events
f2 = figure(2);
bufPlot = zeros(length(frmNo), 1);
bufPlot(bufEvents(:, 1) + 1) = bufEvents(:, 2);
stem((1 : length(bufPlot))./frmRate, bufPlot, 'k-', 'Marker','none');
xlabel('The time (secs)');
ylabel('The freezing period (secs)');
hold on;
hold off;
print(f2, '-dpng', '-painters', '-r100', ['./exp/' vidName '-progressive-bufEvents-' num2str(expNo) '.png']);
