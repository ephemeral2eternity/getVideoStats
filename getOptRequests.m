%% Optimizing the requests of video chunks according to estimated available
%% bandwidth
% getOptRequests.m
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
dropTh = 0.1;
bufSz = 6;

% Load the info needed
frmTyp = vidInfo.textdata(:, 2);
frmTS = vidInfo.textdata(:, 4);
frmSz = vidInfo.data .* 8 ./ (1024^2);
frmNo = (1 : length(frmSz))';

if mod(length(frmSz), frmRate) ~= 0
    frmSz = [frmSz; zeros(frmRate*chunkLen - mod(length(frmSz), frmRate*chunkLen), 1)];
    frmNo = [frmNo; zeros(frmRate*chunkLen - mod(length(frmNo), frmRate*chunkLen), 1)];
    frmII = [importanceIdx; zeros(frmRate*chunkLen - mod(length(importanceIdx), frmRate*chunkLen), 1)];
end
frmSzArry = reshape(frmSz, frmRate*chunkLen, length(frmSz)/(frmRate*chunkLen));
frmNoArry = reshape(frmNo, frmRate*chunkLen, length(frmNo)/(frmRate*chunkLen));
frmIIArry = reshape(frmII, frmRate*chunkLen, length(frmII)/(frmRate*chunkLen));

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
f = figure(1); hold on;
plot(2.*(1 : chunkNo), availBW, symbols{1});
plot(frmBitrate, symbols{2});
xlabel('The time (secs)');
ylabel('The available bandwidth (Mbps)');
axis([0 length(frmSz)./frmRate 0 max(frmBitrate)]);
legend('The available bandwidth', 'The actual bitrate');
hold off;
print(f, '-dpng', '-painters', '-r100', ['./exp/' vidName num2str(expNo) '.png']);


%% Emulate the streaming according to the available bandwidth
% Get the 5 sec buffer filled as fast as possible
bufEvents = [];
dropEvents = []; 
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
        elapsedTS = max(chunkLen, downloadLen);
        TS = TS + elapsedTS;
        
        if curFrm > (i - 1)*chunkLen*frmRate
            bufferingTime = - curBufSz;
            curBufSz = 0;
            state = 'Buffering';
            bufEvents = [bufEvents; curFrm bufferingTime];
            % disp('======= The player is buffering !!!! ======')
        else
            estBW = availBW(floor(TS./chunkLen) + 1);
            expectTS = (frmNoArry(:, i) - curFrm) .* T;
            reqBW = cumsum(frmSzArry(:, i)) ./ expectTS;
            max_req_bw = max(reqBW);
            
            if max_req_bw < estBW
                state = 'Steady';
                downloadLen = sum(frmSzArry(:, i)) ./ estBW;
                % disp(['All the frames in chunk ', num2str(i), ' can be downloaded ', ...
                %    'before buffer running out with time ', num2str(downloadLen)]);
            else
                % Algorithm to select frames
                % disp(['The frame dropping algorithm will be run for chunk ', num2str(i)]);
                curII = frmIIArry(:, i);
                curFrmSz = frmSzArry(:, i);
                
                [sortII, sortFrmIdx] = sort(curII, 'ascend');
                reqBW = cumsum(curFrmSz) ./ expectTS;
                [max_req_bw, maxIdx] = max(reqBW);
                dropCandidate = sortFrmIdx(sortFrmIdx <= maxIdx);
                
                while (~isempty(dropCandidate)) && (curII(dropCandidate(1)) < dropTh)
                    dropFrm = dropCandidate(1);
                    curFrmSz(dropFrm) = 0;
                    sortFrmIdx(sortFrmIdx == dropFrm) = 1000;
                    reqBW = cumsum(curFrmSz) ./ expectTS;
                    [max_req_bw, maxIdx] = max(reqBW);
                    if max_req_bw < estBW
                        break;
                    end
                    dropCandidate = sortFrmIdx(sortFrmIdx <= maxIdx);
                    dropFrmInd = dropFrm + (i - 1)*chunkLen*frmRate;
                    
                    dropEvents = [dropEvents; dropFrmInd frmSz(dropFrmInd) frmII(dropFrmInd)];
                    disp(['Frame ' num2str(dropFrm + (i - 1)*chunkLen*frmRate) ...
                        ' with II ' num2str(curII(dropFrm)) ' has been dropped!']);
                end
                
                downloadLen = sum(curFrmSz) ./ estBW;
                % The end of frames sending session.   
            end
            
            % Update the playback frame index and the downloading time for 
            % the new chunk
            if (downloadLen <= chunkLen)
                curFrm = curFrm + chunkLen * frmRate;
                % disp(['The chunk ', num2str(i), ' download time is less than 2s']);
            elseif (downloadLen > chunkLen)
                curBufSz = curBufSz - downloadLen + chunkLen;
                curFrm = curFrm + floor(downloadLen * frmRate);
                % disp(['The chunk ', num2str(i), ' download time is greater than 2s']);
            end
            
            i = i + 1;
            % The end of state changing session
        end
        % The end of state judging session
    end
    % The end of video sending session
end

save(['./exp/' vidName '-' num2str(expNo) '.mat'], 'bufEvents', 'dropEvents');

%% Plot buffering events
f2 = figure(2);
bufPlot = zeros(length(frmNo), 1);
bufPlot(bufEvents(:, 1) + 1) = bufEvents(:, 2);
stem((1 : length(bufPlot))./frmRate, bufPlot, 'k-', 'Marker','none');
xlabel('The time (secs)');
ylabel('The freezing period (secs)');
hold on;
hold off;
print(f2, '-dpng', '-painters', '-r100', ['./exp/' vidName '-bufEvents-' num2str(expNo) '.png']);

%% Plot dropping events
f3 = figure(3);
dropPlot = zeros(length(frmNo), 1);
dropPlot(dropEvents(:, 1)) = dropEvents(:, 3);
stem((1 : length(dropPlot))./frmRate, dropPlot, 'b-', 'Marker','none');
xlabel('The time (secs)');
ylabel('The importance index of dropped frame');
hold on;
hold off;
print(f3, '-dpng', '-painters', '-r100', ['./exp/' vidName '-dropEvents-' num2str(expNo) '.png']);