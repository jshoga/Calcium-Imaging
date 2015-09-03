close all; clear; clc;
%% Read experiment file
[path,file] = uigetfile;
filepath = [file,path];
experimentFile = bfopen(filepath);  % Choose experiment file
imageSequence = experimentFile{1};  % Save images to imageSequence variable
regSequence = imageSequence;
%% Read in images then trace cells in first image
% First image in experiment
firstImage = regSequence{1};
% Initialize mask to be same size as images in experiment
fullMask = zeros(size(firstImage));
% Optimizes contrast and shows image.
imshow(imadjust(firstImage))
% Convert grayscale image to binary image
BW = im2bw(imadjust(firstImage));
% Filters the traced polygons such that traced regions containing the
% number of pixels between the pixel range provided are kept, and objects
% outside of the provided range are excluded.
BW2 = bwareafilt(BW, [200 2000]);
% Get image dimensions
dim = size(BW);
%%
% Find the first (could be any) nonzero pixel in the mask BW. The object in
% which this pixel resides will be the first object traced by the trace
% program (next line of code).
[nonzeroRow,nonzeroCol] = find(BW,1);
% This is the trace program, goes east to begin searching for adjacent
% pixels and continues counterclockwise. Inf tells the function to for an 
% unlimited amount of pixels until it returns to the beginning.
Boundary = bwtraceboundary(...
            BW2,[nonzeroRow,nonzeroCol],'E',8,Inf,'counterclockwise');
hold on
% Fill in cells so that there are no cells in cells
BW_filled = imfill(BW2,'holes');
% Store all of the traced cells in variable 'boundaries'
Boundaries = bwboundaries(BW_filled);
for k = 1:length(Boundaries)
    cellNo = Boundaries{k};
    % Plot all traced cells
    plot(cellNo(:,2),cellNo(:,1),'g','LineWidth',1.5);
end
[l,w] = size(firstImage);   % WHAT ARE THISSSS????!!
for z=1:length(Boundaries)
    % Store all pixel x coordinates
    bx = Boundaries{z}(:,1);
    % Store all pixel y coordinates
    by = Boundaries{z}(:,2);
    % Convert traced shape into a mask
    BW3 = poly2mask(bx,by,l,w);
    % Add current mask into a total mask
    fullMask = fullMask + BW3;
end
% Allow the user to circle additional cells if required
% DrawROIcheck = questdlg('Would you like to circle another cell?', ...
%     'Checking...','Yes','No','Yes');
% cnt = 1;
% while strcmp(DrawROIcheck,'Yes') == 1
%     h = imfreehand;
%     bw = createMask(h);
%     DrawROIcheck = questdlg('Would you like to circle another cell?', ...
%         'Checking...','Yes','No','Yes');
%     fullMask = fullMask + bw;
%     cnt = cnt + 1;
% end
%% Get normalized average intensity in each image of each cell ROI
% Find connected components (objects, i.e. cells) in mask
cc = bwconncomp(fullMask,8);
% Find objects greater than 10 pixels in size
ccFixed = cc.PixelIdxList(cellfun('length',cc.PixelIdxList)>10);
% Initialize intensityAvg variable to have a number of rows equal to the
% number of cells in the image series, and a number of columns equal to the
% number of images in the image series.
intensityAvg = zeros(length(ccFixed),length(regSequence));
% Apply the mask to the first image in the series for use in the following
% loop.
img1 = double(regSequence{1}).*double(fullMask);
% Get the average intensity in each cell, in each image, normalized to the
% intensity of each respective cell in the first image
for img = 1:size(regSequence,1)
    % Apply mask to image currently being iterated through
    cellsOnly = double(regSequence{img}).*double(fullMask);
    for cellNo = 1:length(ccFixed)
        % Get the mean intensity value of the cell currently being iterated
        % through from the first image so that the intensity in this cell
        % for the rest of the images can be normalized to the initial
        % intensity
        normal = mean(img1(ccFixed{cellNo}));
        intensityAvg(cellNo,img) = mean(cellsOnly(ccFixed{cellNo}))/normal;
    end
end