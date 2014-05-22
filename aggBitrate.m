%% Count aggregate bitrates for N numbers of videos
% aggBitrate.m
% chenw@cmu.edu

clear all;
close all;
clc;

symbols = {'-k', '-xr', '-.b', '-+g', '-+c', '--m', '-og', '-*y', ':k'};
vidNames = {'cloudAtlas', 'hungerGame', 'thor', 'hobbit', 'ted', 'darkKnight', 'skyFall', 'avatar', 'amLegend', 'brave', 'simpsons'};

%% Cound N aggregated bitrates in 1 min.
N = 100;
vidInd = round(rand(1, N) .* 10) + 1;
offSet = round(rand(1, N).*99) + 1;

duration = 60; durLen = 60*25;
totalBitrate = zeros(durLen, 1);
for n = 1 : N
    i = vidInd(n);
    o = offSet(n);
    vidInfo = load([vidNames{i} '.mat']);
    
    bitrateData = vidInfo.data;
    
    if(o + durLen - 1 > length(bitrateData))
        o = length(bitrateData) - durLen;
    end
    totalBitrate = totalBitrate + bitrateData(o:o + durLen - 1).*8./1024;   
end

totBitMat = reshape(totalBitrate, 25, durLen./25);
totBitrate = sum(totBitMat, 1)./1024;

%% Draw the aggregated bitrate
figure(1), hold on;
plot(totBitrate, symbols{1});
xlabel('Time (secs)');
ylabel('Bitrate (Mbps)');
hold off;

mean(totBitrate)
std(totBitrate)