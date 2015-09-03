% close all; clear; clc;
%% Read experiment file
[y, Fs] = audioread('Terran_ScannerSweep.m4a');
Player = audioplayer(y, Fs);
play(Player);
experimentFile = bfopen(filePath);    % Choose experiment file
imageSequence = experimentFile{1};  % Save images to imageSequence variable
% %% Image registration
maxCorr = zeros(length(imageSequence),2);
shifts = zeros(length(imageSequence),2);
[imgRow,imgCol] = size(imageSequence{1,1});
imgFFT1 = fft2(imageSequence{1,1},imgRow*2-1,imgCol*2-1);
regSequence = cell(length(imageSequence),1);
h = waitbar(0,'Please wait...','Name','Loading Bar','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0);
sampleNo = sampleNames{bb};
mkdir(sprintf('Experiment %s',sampleNo)); %makes a folder to store everything in
[y2, Fs2] = audioread('C:\Users\Public\Music\Sample Music\Sleep Away.mp3');
Player2 = audioplayer(y2, Fs2);
play(Player2);
for CellCount = 1:length(imageSequence)
    if getappdata(h,'canceling')
        break
    end
    img = imageSequence{CellCount,1};
    imgFFT = fft2(img,imgRow*2-1,imgCol*2-1);
    corr = fftshift(ifft2(imgFFT.*conj(imgFFT1)));
    [maxRowVal,maxRowInd] = max(corr);
    [maxColVal,maxColInd] = max(maxRowVal);
    maxCorr(CellCount,:) = [maxRowInd(1),maxColInd];
    shifts(CellCount,:) = [maxRowInd(1)-imgRow,maxColInd-imgCol];
    horShift = shifts(CellCount,2);
    verShift = shifts(CellCount,1);
    tform = affine2d([1,0,0;0,1,0;horShift,verShift,1]);
    regSequence{CellCount,1} = imwarp(img,tform);
    Percentage = CellCount / length(imageSequence);
    waitbar(Percentage,h,sprintf('%d%% Complete',round(Percentage*100)));
end
delete(h)
%% Automatically Trace Cells, Draw ROI's if necessary
stop(Player2)
[y3, Fs3] = audioread('SC2_uiBNetToast.m4a');
Player3 = audioplayer(y3, Fs3);
play(Player3);
firstImage = regSequence{1};  % First image in experiment
fullMask = zeros(size(firstImage));
imshow(imadjust(firstImage)) % Optimizes contrast and shows image.
BW = im2bw(imadjust(firstImage)); % Convert image to binary
BW2 = bwareafilt(BW, [200 2000]); %Filters the traced polygons by the
% pixel range that is provided
%
dim = size(BW); %Acquires dimensions of image
Column = round(dim(2)/2); %Finds a column in the middle of the image
Row = min(find(BW(:,Column))); %Finds a pixel of interest in a row that
% interesects the previous column
%
% Prompt = msgbox('Select a point on the outside of a cell.',...
%     'Cell Tracing','help');
% uiwait(Prompt,5);
% [Row,Column] = ginput(1);
Row = round(Row);
Column = round(Column);
% This solves an issue where the program won't automatically find a cell to
% start tracing
Boundary = bwtraceboundary(BW2,[Row Column],'W',8,Inf,'counterclockwise');
% This is the trace program, goes west to begin searching for
% adjacent pixels and continues counterclockwise.
% Inf tells the function to for an unlimited amount of pixels
% until it returns to the beginning.
hold on
BW_filled = imfill(BW2,'holes'); % Function fills in cells so that there are
% no cells in cells
Boundaries = bwboundaries(BW_filled); % Stores all of the traced cells
% in variable 'boundaries'
for k=1:length(Boundaries)
    b = Boundaries{k};
    plot(b(:,2),b(:,1),'g','LineWidth',1.5); % Plots all traced cells
end
%
saveas(gcf,[sprintf('Experiment %s',sampleNo),filesep,sprintf('Image of Traced Cells')],'fig')
[l,w] = size(firstImage);
for z=1:length(Boundaries)
    bx = Boundaries{z}(:,1); % Stores all of the x coordinates of pixels
    by = Boundaries{z}(:,2); % Stores all of the y coordinates of pixels
    BW3 = poly2mask(bx,by,l,w); % Converts traced shape into a mask
    fullMask = fullMask + BW3; % Adds current mask into a total mask
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
cc = bwconncomp(fullMask,8);
ccFixed = cc.PixelIdxList(cellfun('length',cc.PixelIdxList)>10);
IntensityAvg = cell(length(ccFixed));
img1 = double(regSequence{1}).*double(fullMask);
for CellCount = 1:size(regSequence,1)
    cellsOnly = double(regSequence{CellCount}).*double(fullMask);  % Get intensity from cell
    for b = 1:length(ccFixed)
        normal = mean(img1(ccFixed{b}));
        IntensityAvg{CellCount,b} = mean(cellsOnly(ccFixed{b}))/normal;
    end
end
%% Plot each line and save the plot and peak count, width, height, relative height, and time. 
close all
time = 0.5:0.5:length(regSequence)/2;
intensityPeaks = cell(size(IntensityAvg,2),1);
for CellCount = 1:size(IntensityAvg,2)
    Intensity = IntensityAvg(:,CellCount);
    Intensity = cell2mat(Intensity); % Converts cell array into a matrix
    Intensity = sgolayfilt(Intensity,4,41); % Smoothing function
    % 4=quartic function, 41=pixel length of smoothing
    Derivative = gradient(Intensity); % Find derivative of the line
    Derivative = sgolayfilt(Derivative,7,41); % Filters the derivative
    Signs = sign(Derivative); % Outputs +1 or -1 to indicate sign of derivative values
    % This loop will run through the signs variable looking for points
    % where the derivative will switch from positive to negative or
    % vice-versa indicating a peak or a trough. The height and location in
    % time will be stored for each peak and trough.
    TroughHeight = zeros(1,length(Signs)-1);
    Troughlocation = zeros(1,length(Signs)-1);
    PeakLocation = zeros(1,length(Signs)-1);
    MinMax = zeros(1,length(Signs)-1);
    %
    for Counter = 1:length(Signs)-1
        MinMax(Counter) = Signs(Counter)==Signs(Counter+1);
        if MinMax(Counter)==0
            if Signs(Counter)<Signs(Counter+1)
                Troughlocation(Counter)=2;
                PeakLocation(Counter)=0;
                TroughHeight(Counter)=Intensity(Counter);
                MinMax(Counter)=1;
            else
                Troughlocation(Counter)=0;
                PeakLocation(Counter)=2;
                TroughHeight(Counter)=0;
            end
        else
            Troughlocation(Counter)=0;
            PeakLocation(Counter)=0;
            TroughHeight(Counter)=0;
        end
        TroughLocate = find(Troughlocation==2);
        PeakLocate = find(PeakLocation==2);
    end
    %
    PeakTime = PeakLocate/2; % Peaks in time
    PeakCount = length(PeakTime);
    PeakHeight = Intensity(PeakLocate(1:PeakCount));
    TroughTime = TroughLocate/2;
    TroughCount = length(TroughTime);
    TroughHeight(TroughHeight==0) = [];
    TotalPeakHeight = PeakHeight;
    TotalPeakCount = PeakCount;
    TotalPeakTime = PeakTime;
    % Peak Selection (removes from lowest trough)
    % This loop will run through all of the peaks and set them equal to
    % zero if they are within Lim1 of the lowest adjacent trough.
    Counter2=1;
    Lim1 = 0.01;
    while Counter2 <= PeakCount
        if TroughTime(1) <= PeakTime(1)
            if TroughCount > PeakCount
                if PeakHeight(Counter2) < min(TroughHeight(Counter2), TroughHeight(Counter2+1))+ Lim1
                    PeakHeight(Counter2)=0;
                    Counter2=Counter2+1;
                else
                    Counter2=Counter2+1;
                end
            else
                if Counter2 == PeakCount
                    if PeakHeight(Counter2) < TroughHeight(Counter2)+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                else
                    if PeakHeight(Counter2) < min(TroughHeight(Counter2), TroughHeight(Counter2+1))+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                end
            end
        else
            if TroughCount < PeakCount
                if Counter2 == 1
                    if PeakHeight(Counter2) < TroughHeight(Counter2)+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                elseif Counter2 == PeakCount
                    if PeakHeight(Counter2) < TroughHeight(Counter2-1)+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                else
                    if PeakHeight(Counter2) < min(TroughHeight(Counter2), TroughHeight(Counter2-1))+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                end
            else
                if Counter2 == 1
                    if PeakHeight(Counter2) < TroughHeight(Counter2)+ Lim1 
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                else
                    if PeakHeight(Counter2) < min(TroughHeight(Counter2), TroughHeight(Counter2-1))+ Lim1
                        PeakHeight(Counter2)=0;
                        Counter2=Counter2+1;
                    else
                        Counter2=Counter2+1;
                    end
                end
            end
        end
    end             
    % Second Peak Selection (removes from highest trough)
    % This loop will run through all of the peaks and set them equal to
    % zero if they are within Lim2 of the highest adjacent trough.
        Counter3=1;
        Lim2 = 0.005;
    while Counter3 <= PeakCount
        if TroughTime(1) <= PeakTime(1)
            if TroughCount > PeakCount
                if PeakHeight(Counter3) < max(TroughHeight(Counter3), TroughHeight(Counter3+1))+ Lim2
                    PeakHeight(Counter3)=0;
                    Counter3=Counter3+1;
                else
                    Counter3=Counter3+1;
                end
            else
                if Counter3 == PeakCount
                    if PeakHeight(Counter3) < TroughHeight(Counter3)+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                else
                    if PeakHeight(Counter3) < max(TroughHeight(Counter3), TroughHeight(Counter3+1))+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                end
            end
        else
            if TroughCount < PeakCount
                if Counter3 == 1
                    if PeakHeight(Counter3) < TroughHeight(Counter3)+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                elseif Counter3 == PeakCount
                    if PeakHeight(Counter3) < TroughHeight(Counter3-1)+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                else
                    if PeakHeight(Counter3) < max(TroughHeight(Counter3), TroughHeight(Counter3-1))+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                end
            else
                if Counter3 == 1
                    if PeakHeight(Counter3) < TroughHeight(Counter3)+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                else
                    if PeakHeight(Counter3) < max(TroughHeight(Counter3), TroughHeight(Counter3-1))+ Lim2
                        PeakHeight(Counter3)=0;
                        Counter3=Counter3+1;
                    else
                        Counter3=Counter3+1;
                    end
                end
            end
        end
    end 
%     % Calculate width of each peak
%     % This will measure the distance between the adjacent troughs for each
%     % peak or it will measure the distance to the nearest trough if the
%     % peak is the farthest point on either side.
    CounterWidth=1;
    PeakWidth = zeros(1,PeakCount);
    while CounterWidth <= PeakCount
        if TroughTime(1) <= PeakTime(1)
            if CounterWidth == PeakCount
                if length(TroughTime)<=length(PeakTime)
                    PeakWidth(CounterWidth) = PeakTime(CounterWidth) - TroughTime(CounterWidth);
                    CounterWidth = CounterWidth+1;
                else
                    PeakWidth(CounterWidth) = TroughTime(CounterWidth+1) - TroughTime(CounterWidth);
                    CounterWidth = CounterWidth+1;
                end
            else
                PeakWidth(CounterWidth) = TroughTime(CounterWidth+1) - TroughTime(CounterWidth);
                    CounterWidth = CounterWidth+1;
            end
        else
            if CounterWidth == PeakCount
                if length(TroughTime)<=length(PeakTime)
                    PeakWidth(CounterWidth) = PeakTime(CounterWidth) - TroughTime(CounterWidth-1);
                    CounterWidth = CounterWidth+1;
                else
                    PeakWidth(CounterWidth) = PeakTime(CounterWidth) - TroughTime(CounterWidth-1);
                    CounterWidth = CounterWidth+1;
                end
            elseif CounterWidth == 1
                PeakWidth(CounterWidth) = TroughTime(CounterWidth) - PeakTime(CounterWidth);
                    CounterWidth = CounterWidth+1;
            else
                PeakWidth(CounterWidth) = TroughTime(CounterWidth) - TroughTime(CounterWidth-1);
                    CounterWidth = CounterWidth+1;
            end
        end
    end
    PeakWidth(PeakCount+1:end) = [];
%     % Calculate relative height of each peak
%     % This will measure the height between the minimum adjacent troughs for each
%     % peak or it will measure the height between the peak and nearest trough if the
%     % peak is the farthest point on either side.
    CounterHeight=1;
    RelativePeakHeight = zeros(1,PeakCount);
    while CounterHeight <= PeakCount
        if TroughTime(1) <= PeakTime(1)
            if CounterHeight == PeakCount
                if TroughCount <= PeakCount
                    RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - TroughHeight(CounterHeight);
                    CounterHeight = CounterHeight+1;
                else
                    RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - min(TroughHeight(CounterHeight),TroughHeight(CounterHeight+1));
                    CounterHeight = CounterHeight+1;
                end
            else
                RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - min(TroughHeight(CounterHeight),TroughHeight(CounterHeight+1));
                CounterHeight = CounterHeight+1;
            end
        else
            if CounterHeight==1
                RelativePeakHeight(CounterHeight)= PeakHeight(1)-TroughHeight(1);
                CounterHeight=CounterHeight+1;
            elseif CounterHeight == PeakCount
                if PeakCount <= TroughCount
                    RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - min(TroughHeight(CounterHeight),TroughHeight(CounterHeight-1));
                    CounterHeight = CounterHeight+1;
                else
                    RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - TroughHeight(CounterHeight-1);
                    CounterHeight = CounterHeight+1;
                end
            else
                RelativePeakHeight(CounterHeight) = PeakHeight(CounterHeight) - min(TroughHeight(CounterHeight),TroughHeight(CounterHeight-1));
                CounterHeight = CounterHeight+1;  
            end
        end
    end
    %   This will go through variable LocalPeaks and will remove any of the
    %   peaks that were set to zero by the peak selection loops.
    TotalPeakWidth = PeakWidth(1:end);
    LocalPeaks = find(PeakHeight==0);
    LocalPeakCount = length(LocalPeaks);
    LocalPeakTime = PeakTime(LocalPeaks(1:end));
    LocalPeakWidth = PeakWidth(LocalPeaks(1:end));
    LocalPeakHeight = TotalPeakHeight(LocalPeaks(1:end));
    PeakHeight(LocalPeaks(1:end))= [];
    PeakTime(LocalPeaks(1:end)) = [];
    PeakWidth(LocalPeaks(1:end)) = [];
    RelativePeakHeight(LocalPeaks(1:end)) = [];
    PeakCount = length(PeakTime);
    PeakT = PeakTime';
    PeakW = PeakWidth';
    PeakR = RelativePeakHeight';
    PeakNumber = 1:1:PeakCount;
    PeakNumber = PeakNumber';
    PeakTable = table(PeakNumber,PeakT,PeakHeight,PeakW,PeakR,...
        'VariableNames',{'Number' 'Time' 'Height' 'Width' 'RelativeHeight'});
    %   Stores all of the variables for each cell that was traced.
    if CellCount == 1
        AllPeakHeights = cell(1,size(IntensityAvg,2));
        AllPeakTimes = cell(1,size(IntensityAvg,2));
        AllPeakCount = cell(1,size(IntensityAvg,2));
        AllPeakWidths = cell(1,size(IntensityAvg,2));
        AllPeakRelativeHeights = cell(1,size(IntensityAvg,2));
        AllPeakTable = cell(1,size(IntensityAvg,2));
        AllRemovedPeakHeights = cell(1,size(IntensityAvg,2));
        AllRemovedPeakTimes = cell(1,size(IntensityAvg,2));
        AllRemovedPeakCount = cell(1,size(IntensityAvg,2));
        AllRemovedPeakWidths = cell(1,size(IntensityAvg,2));
        AllTotalPeakHeights = cell(1,size(IntensityAvg,2));
        AllTotalPeakTimes = cell(1,size(IntensityAvg,2));
        AllTotalPeakCount = cell(1,size(IntensityAvg,2));
        AllTotalPeakWidths = cell(1,size(IntensityAvg,2));
    end
    AllPeakHeights{CellCount} = PeakHeight;
    AllPeakTimes{CellCount} = PeakTime;
    AllPeakCount{CellCount} = PeakCount;
    AllPeakWidths{CellCount} = PeakWidth;
    AllPeakTable{CellCount} = PeakTable;
    AllPeakRelativeHeights{CellCount} = RelativePeakHeight;
    AllRemovedPeakHeights{CellCount} = LocalPeakHeight;
    AllRemovedPeakTimes{CellCount} = LocalPeakTime;
    AllRemovedPeakCount{CellCount} = LocalPeakCount;
    AllRemovedPeakWidths{CellCount} = LocalPeakWidth;
    AllTotalPeakHeights{CellCount} = TotalPeakHeight;
    AllTotalPeakTimes{CellCount} = TotalPeakTime;
    AllTotalPeakCount{CellCount} = TotalPeakCount;
    AllTotalPeakWidths{CellCount} = TotalPeakWidth;
    figure
    plot(time,Intensity,'b',PeakTime,PeakHeight,'ro')
    xlim([0 600])
    xlabel('Time (s)')
    ylabel('Normalized Intensity')
    title(sprintf('Intensity vs. Time for Cell %d',CellCount))
    % Can label points on plot, but makes it hard to read
%         for loops = 1:(length(PeakTime))
%             labelstr = sprintf('(%.3g, %.4g)',PeakTime(loops),PeakHeight(loops));
%             text(PeakTime(loops)+5, PeakHeight(loops)+.005, labelstr,...
%                 'FontSize',6,'FontWeight','Bold');
%         end
    saveas(gcf,[sprintf('Experiment %s',sampleNo),filesep,sprintf('Plot for Cell %d',CellCount)],'fig')
    close all
end
time = 0.5:0.5:length(regSequence)/2;
%% Plot everything and save plot
close all
figure
hold on
lineName = cell(size(IntensityAvg,2));
for CellCount = 1:size(IntensityAvg,2)
    Intensity = IntensityAvg(:,CellCount);
    Intensity = cell2mat(Intensity);
    Intensity =sgolayfilt(Intensity,5,41);
    plot(time,Intensity,'color',rand(1,3),'DisplayName',['Cell Number ',num2str(CellCount)])
end
legend(gca,'show','Location','eastoutside')
xlabel('Time (s)')
ylabel('Normalized Intensity')
title('Intensity vs. Time for All Cells')
saveas(gcf,[sprintf('Experiment %s',sampleNo),filesep,sprintf('Plot for All Cells')],'fig')
close all
%% Save
save(sampleNo,'time','IntensityAvg','filePath',...
    'AllPeakCount','AllPeakHeights','AllPeakTimes',...
    'AllPeakWidths','AllPeakRelativeHeights','AllPeakTable','fullMask')
movefile(sprintf('%s.mat',sampleNo),sprintf('Experiment %s',sampleNo));