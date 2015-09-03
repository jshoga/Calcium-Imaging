close all; clear; clc;

%% Read experiment file
experimentFile = bfopen;    % Choose experiment file
imageSequence = experimentFile{1};  % Save images to imageSequence variable

%% Image registration
regSequence = cell(length(imageSequence),1);
regSequence{1,1} = imageSequence{1,1};
for a = 1:length(imageSequence)-1
    ptThresh = 0.00000000001;
    ptQuality = 0.00000000001;
    pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'MinQuality',ptQuality);
    pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'MinQuality',ptQuality);

    % Display corners found in images A and B.
    figure; imshow(imgA,[]); hold on;
    plot(pointsA);
    title('Corners in A');

    figure; imshow(imgB,[]); hold on;
    plot(pointsB);
    title('Corners in B');
end

%% Draw ROIs around cells
firstImage = regSequence{1};  % First image in experiment
firstImage = double(firstImage); % Convert from 16-bit to floating point
% Set lowest value in image to 0
firstImage = firstImage-min(min(firstImage));
% Set highest value in image to 2^16 ( = 65535)
firstImage = firstImage*65535/max(max(firstImage));
imshow(firstImage,[])   % Display first image
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

%% Get normalized average intensity in each image of each cell ROI
cc = regionprops(fullMask);
intensityAvg = cell(length(cc.PixelIdxList));
for a = 1:size(regSequence,1)
    cellsOnly = double(regSequence{a}).*double(fullMask);  % Get intensity from cell
    for b = 1:length(cc.PixelIdxList)
        normal = mean(cellsOnly(cc.PixelIdxList{1,b}));
        intensityAvg{a,b} = mean(cellsOnly(cc.PixelIdxList{b}))/normal;
    end
end