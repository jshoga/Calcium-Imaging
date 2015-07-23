close all; clear; clc;

%% Read experiment file
experimentFile = bfopen;    % Choose experiment file
imageSequence = experimentFile{1};  % Save images to imageSequence variable
% % %% Image registration
% regSequence = cell(length(imageSequence),1);
% regSequence{1,1} = imageSequence{1,1};
% for a = 1:length(imageSequence)-1
%     img1 = imageSequence{a,1};
%     img2 = imageSequence{a+1,1};
%     imshowpair(img1,img2)
%     [optimizer,metric] = imregconfig('monomodal');
%     close
%     img2new = imregister(img2,img1,'rigid',optimizer,metric);
%     regSequence{a+1,1} = img2new;
% end

% %% Image registration
maxCorr = zeros(length(imageSequence),2);
shifts = zeros(length(imageSequence),2);
[imgRow,imgCol] = size(imageSequence{1,1});
imgFFT1 = fft2(imageSequence{1,1},imgRow*2-1,imgCol*2-1);
regSequence = cell(length(imageSequence),1);
for a = 1:length(imageSequence)
    img = imageSequence{a,1};
    imgFFT = fft2(img,imgRow*2-1,imgCol*2-1);
    corr = fftshift(ifft2(imgFFT.*conj(imgFFT1)));
    [maxRowVal,maxRowInd] = max(corr);
    [maxColVal,maxColInd] = max(maxRowVal);
    maxCorr(a,:) = [maxRowInd(1),maxColInd];
    shifts(a,:) = [maxRowInd(1)-imgRow,maxColInd-imgCol];
    horShift = shifts(a,2);
    verShift = shifts(a,1);
    tform = affine2d([1,0,0;0,1,0;horShift,verShift,1]);
    regSequence{a,1} = imwarp(img,tform);
end

%% Draw ROIs around cells
firstImage = regSequence{1};  % First image in experiment
%firstImage = double(firstImage); % Convert from 16-bit to floating point
imshow(imadjust(firstImage))   % Display first image
drawROIcheck = 'Yes';  % Initialize condition for while loop
fullMask = zeros(size(firstImage));
cnt = 1;
while strcmp(drawROIcheck,'Yes') == 1
    h = imfreehand;
    bw = createMask(h);
    drawROIcheck = questdlg('Would you like to circle another cell?', ...
        'Checking...','Yes','No','Yes');
    fullMask = fullMask + bw;
    cnt = cnt + 1;
end

% %% Automatically generate mask of cells
% firstImage = regSequence{1};  % First image in experiment
% contrastAdjustedImage = imadjust(firstImage);
% thresh = multithresh(contrastAdjustedImage);
% segI = imquantize(contrastAdjustedImage,thresh);
% bw = imfill(segI);
% se = strel('disk',5);
% bw2 = imopen(bw,se);
% fullMask = im2bw(bw2,1);

%% Get normalized average intensity in each image of each cell ROI
cc = bwconncomp(fullMask,8);
ccFixed = cc.PixelIdxList(cellfun('length',cc.PixelIdxList)>10);
intensityAvg = cell(length(ccFixed));
img1 = double(regSequence{1}).*double(fullMask);
for a = 1:size(regSequence,1)
    cellsOnly = double(regSequence{a}).*double(fullMask);  % Get intensity from cell
    for b = 1:length(ccFixed)
        normal = mean(img1(ccFixed{b}));
        intensityAvg{a,b} = mean(cellsOnly(ccFixed{b}))/normal;
    end
end
%% Plot each line & select onset, max, and resolution of each peak
time = 0.5:0.5:length(regSequence)/2;
intensityPeaks = cell(size(intensityAvg,2),1);
figure
for a = 1:size(intensityAvg,2)
    intensity = intensityAvg(:,a);
    intensity = cell2mat(intensity);
    plot(time,intensity,'color',rand(1,3),'DisplayName',['Cell Number ',num2str(a)])
    legend(gca,'show','Location','northoutside')
    [x,y] = ginput;
    intensityPeaks{a} = [x,y];
end

%%
time = 0.5:0.5:length(regSequence)/2;

%% Plot everything
close all
figure
hold on
lineName = cell(size(intensityAvg,2));
for a = 1:size(intensityAvg,2)
    intensity = intensityAvg(:,a);
    intensity = cell2mat(intensity);
    plot(time,intensity,'color',rand(1,3),'DisplayName',['Cell Number ',num2str(a)])
end
legend(gca,'show','Location','eastoutside')

% The noise is so small, everything is signal! 
% noiseMin = min(intensity(1:30));
% noiseMax = max(intensity(1:30));
% noiseRange = noiseMax - noiseMin;
% activationThreshold = 5*noiseRange;
% plot(time,activationThreshold)

xlabel('Time (s)')
ylabel('Normalized Intensity')

filepath = imageSequence{1,2};
backslashIndex = find(filepath == '\');
sampleNo = filepath(backslashIndex(3)+1:backslashIndex(4)-1);

title(sampleNo)

%%
save(sampleNo,'time','intensityAvg','filepath','intensityPeaks','fullMask')

% %% compile... edit title... define s = {s1,s2,s3,etc.} where sX =
% % intensityAvg after load('X.mat')
% timeEnd = min(cellfun('length',s));
% time = 0.5:0.5:timeEnd/2;
% activationThreshold = 2*ones(size(time));
% 
% figure
% plot(time,activationThreshold)
% hold on
% for a = 1:length(s)
%     for b = 1:size(s{a},2)
%         plot(time,cell2mat(s{a}(1:timeEnd,b)),'color',rand(1,3))
%     end
% end
% xlabel('Time (s)')
% ylabel('Normalized Intensity')
% title('Group 4')

% q = cell2mat(intensityAvg);
% r = mean(q,2)';
% s = std(q,0,1)';
% errorbar(time,r,s)