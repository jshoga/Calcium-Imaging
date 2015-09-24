% clear; close all; clc;
% 
% %% Initialize Experiment class for each experiment
% % folder = uigetdir;
% folder = 'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging';
% foldersInFolder = dir(folder);
% foldersOfInterest = foldersInFolder(3:end-8);
% 
% exp = cell(105,1);
% for f = 1:length(foldersOfInterest)
%     folderPath = [folder,'\',foldersOfInterest(f).name];
%     sampleFolders = dir(folderPath);
%     sampleFolders = sampleFolders(3:end);
%     for s = 1:length(sampleFolders)
%         samplePath = [folderPath,'\',sampleFolders(s).name,'\',...
%             'Experiment.czi'];
%         expNo = str2double(sampleFolders(s).name);
%         exp = Experiment(samplePath);
%         fileName = sprintf('Experiment_%03d',expNo);
%         filePath = [folder,'\','Experiments\',fileName];
%         save(filePath,'exp')
%         clear exp
%     end
% end
% 
% %% Analyze each Cell in each Experiment
% clear; clc;
% 
% expFolderPath = ...
%     'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Experiments';
% for e = 1:105
%     expWorkspacePath = [expFolderPath,'\Experiment_',sprintf('%03d',e)];
%     load(expWorkspacePath)
%     for c = 1:exp.numCells
%         cells = Cell(exp.images,exp.mask,c);
%         if isempty(dir(['R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
%                 sprintf('%03d',exp.expNo)]))
%             mkdir(['R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
%                 sprintf('%03d',exp.expNo)])
%         end
%         cellPath = [...
%             'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
%             sprintf('%03d',exp.expNo),'\CellNo',sprintf('%02d',c)];
%         save(cellPath,'cells')
%         clear cells
%     end
% end

%% Collate data from each Cell
clear; clc;

cellsFolderPath = ...
    'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells';

wksHeader1 = {'','','',...
    'Spontaneous','','','','','','','','','','',...
    'Treatment','','','','','','','','','','',...
    'Ionomycin','','','','','','','','','',''};
wksHeader2 = {'','','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall',''};
wksHeader3 = {'Group No.','Experiment No.','Cell No.',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD'};
wksHeaderFinal = cat(1,wksHeader1,wksHeader2,wksHeader3);

numPeaksSpontGroup = cell(18,1);
heightSpontGroup = cell(18,1);
promSpontGroup = cell(18,1);
widthSpontGroup = cell(18,1);
riseSpontGroup = cell(18,1);
fallSpontGroup = cell(18,1);

numPeaksTreatGroup = cell(18,1);
heightTreatGroup = cell(18,1);
promTreatGroup = cell(18,1);
widthTreatGroup = cell(18,1);
riseTreatGroup = cell(18,1);
fallTreatGroup = cell(18,1);

numPeaksIonoGroup = cell(18,1);
heightIonoGroup = cell(18,1);
promIonoGroup = cell(18,1);
widthIonoGroup = cell(18,1);
riseIonoGroup = cell(18,1);
fallIonoGroup = cell(18,1);

count = 1;
cellInfo = cell(1,36);
expObjectPath = ...
    'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Experiments';
for e = 1:105
    expWorkspacePath = [expObjectPath,'\Experiment_',sprintf('%03d',e)];
    load(expWorkspacePath)
    groupNo = exp.groupNo;
    expFolderPath = [cellsFolderPath,'\ExpNo',sprintf('%03d',e)];
    numCells = length(dir(expFolderPath)) - 2;
    for c = 1:numCells
        cellPath = [expFolderPath,'\CellNo',sprintf('%02d',c)];
        load(cellPath)
        
        numPeaksSpont = length(cells.spontaneousPeaks);
        avgHeightSpont = mean(cells.peakHeight(cells.spontaneousPeaks));
        stdHeightSpont = std(cells.peakHeight(cells.spontaneousPeaks));
        avgPromSpont = mean(cells.peakProm(cells.spontaneousPeaks));
        stdPromSpont = std(cells.peakProm(cells.spontaneousPeaks));
        avgWidthSpont = mean(cells.peakWidth(cells.spontaneousPeaks));
        stdWidthSpont = std(cells.peakWidth(cells.spontaneousPeaks));
        avgRiseSpont = mean(cells.peakRise(cells.spontaneousPeaks));
        stdRiseSpont = std(cells.peakRise(cells.spontaneousPeaks));
        avgFallSpont = mean(cells.peakFall(cells.spontaneousPeaks));
        stdFallSpont = std(cells.peakFall(cells.spontaneousPeaks));
        
        numPeaksTreat = length(cells.treatmentPeaks);
        avgHeightTreat = mean(cells.peakHeight(cells.treatmentPeaks));
        stdHeightTreat = std(cells.peakHeight(cells.treatmentPeaks));
        avgPromTreat = mean(cells.peakProm(cells.treatmentPeaks));
        stdPromTreat = std(cells.peakProm(cells.treatmentPeaks));
        avgWidthTreat = mean(cells.peakWidth(cells.treatmentPeaks));
        stdWidthTreat = std(cells.peakWidth(cells.treatmentPeaks));
        avgRiseTreat = mean(cells.peakRise(cells.treatmentPeaks));
        stdRiseTreat = std(cells.peakRise(cells.treatmentPeaks));
        avgFallTreat = mean(cells.peakFall(cells.treatmentPeaks));
        stdFallTreat = std(cells.peakFall(cells.treatmentPeaks));
        
        numPeaksIono = length(cells.ionomycinPeaks);
        avgHeightIono = mean(cells.peakHeight(cells.ionomycinPeaks));
        stdHeightIono = std(cells.peakHeight(cells.ionomycinPeaks));
        avgPromIono = mean(cells.peakProm(cells.ionomycinPeaks));
        stdPromIono = std(cells.peakProm(cells.ionomycinPeaks));
        avgWidthIono = mean(cells.peakWidth(cells.ionomycinPeaks));
        stdWidthIono = std(cells.peakWidth(cells.ionomycinPeaks));
        avgRiseIono = mean(cells.peakRise(cells.ionomycinPeaks));
        stdRiseIono = std(cells.peakRise(cells.ionomycinPeaks));
        avgFallIono = mean(cells.peakFall(cells.ionomycinPeaks));
        stdFallIono = std(cells.peakFall(cells.ionomycinPeaks));
        
        cellInfo(count,:) = {groupNo,e,c,...
            numPeaksSpont,avgHeightSpont,stdHeightSpont,...
            avgPromSpont,stdPromSpont,avgWidthSpont,stdWidthSpont,...
            avgRiseSpont,stdRiseSpont,avgFallSpont,stdFallSpont,...
            numPeaksTreat,avgHeightTreat,stdHeightTreat,...
            avgPromTreat,stdPromTreat,avgWidthTreat,stdWidthTreat,...
            avgRiseTreat,stdRiseTreat,avgFallTreat,stdFallTreat,...
            numPeaksIono,avgHeightIono,stdHeightIono,...
            avgPromIono,stdPromIono,avgWidthIono,stdWidthIono,...
            avgRiseIono,stdRiseIono,avgFallIono,stdFallIono};
        count = count + 1;
        
        %% Group analysis
        g = groupNo;
        numPeaksSpontGroup{g} = ...
            [numPeaksSpontGroup{g},length(cells.spontaneousPeaks)];
        heightSpontGroup{g} = ...
            [heightSpontGroup{g},cells.peakHeight(cells.spontaneousPeaks)'];
        promSpontGroup{g} = ...
            [promSpontGroup{g},cells.peakProm(cells.spontaneousPeaks)'];
        widthSpontGroup{g} = ...
            [widthSpontGroup{g},cells.peakWidth(cells.spontaneousPeaks)'];
        riseSpontGroup{g} = ...
            [riseSpontGroup{g},cells.peakRise(cells.spontaneousPeaks)];
        fallSpontGroup{g} = ...
            [fallSpontGroup{g},cells.peakFall(cells.spontaneousPeaks)];

        numPeaksTreatGroup{g} = ...
            [numPeaksTreatGroup{g},length(cells.treatmentPeaks)];
        heightTreatGroup{g} = ...
            [heightTreatGroup{g},cells.peakHeight(cells.treatmentPeaks)'];
        promTreatGroup{g} = ...
            [promTreatGroup{g},cells.peakProm(cells.treatmentPeaks)'];
        widthTreatGroup{g} = ...
            [widthTreatGroup{g},cells.peakWidth(cells.treatmentPeaks)'];
        riseTreatGroup{g} = ...
            [riseTreatGroup{g},cells.peakRise(cells.treatmentPeaks)];
        fallTreatGroup{g} = ...
            [fallTreatGroup{g},cells.peakFall(cells.treatmentPeaks)];

        numPeaksIonoGroup{g} = ...
            [numPeaksIonoGroup{g},length(cells.ionomycinPeaks)];
        heightIonoGroup{g} = ...
            [heightIonoGroup{g},cells.peakHeight(cells.ionomycinPeaks)'];
        promIonoGroup{g} = ...
            [promIonoGroup{g},cells.peakProm(cells.ionomycinPeaks)'];
        widthIonoGroup{g} = ...
            [widthIonoGroup{g},cells.peakWidth(cells.ionomycinPeaks)'];
        riseIonoGroup{g} = ...
            [riseIonoGroup{g},cells.peakRise(cells.ionomycinPeaks)];
        fallIonoGroup{g} = ...
            [fallIonoGroup{g},cells.peakFall(cells.ionomycinPeaks)];
    end
end
%%
groupInfo = cell(18,34);
for g = 1:18        % 18 groups total
    numPeaksSpontGroupTotal = sum(numPeaksSpontGroup{g});
    avgHeightSpontGroup = mean(heightSpontGroup{g});
    stdHeightSpontGroup = std(heightSpontGroup{g});
    avgPromSpontGroup = mean(promSpontGroup{g});
    stdPromSpontGroup = std(promSpontGroup{g});
    avgWidthSpontGroup = mean(widthSpontGroup{g});
    stdWidthSpontGroup = std(widthSpontGroup{g});
    avgRiseSpontGroup = mean(riseSpontGroup{g});
    stdRiseSpontGroup = std(riseSpontGroup{g});
    avgFallSpontGroup = mean(fallSpontGroup{g});
    stdFallSpontGroup = std(fallSpontGroup{g});

    numPeaksTreatGroupTotal = sum(numPeaksTreatGroup{g});
    avgHeightTreatGroup = mean(heightTreatGroup{g});
    stdHeightTreatGroup = std(heightTreatGroup{g});
    avgPromTreatGroup = mean(promTreatGroup{g});
    stdPromTreatGroup = std(promTreatGroup{g});
    avgWidthTreatGroup = mean(widthTreatGroup{g});
    stdWidthTreatGroup = std(widthTreatGroup{g});
    avgRiseTreatGroup = mean(riseTreatGroup{g});
    stdRiseTreatGroup = std(riseTreatGroup{g});
    avgFallTreatGroup = mean(fallTreatGroup{g});
    stdFallTreatGroup = std(fallTreatGroup{g});
    
    numPeaksIonoGroupTotal = sum(numPeaksIonoGroup{g});
    avgHeightIonoGroup = mean(heightIonoGroup{g});
    stdHeightIonoGroup = std(heightIonoGroup{g});
    avgPromIonoGroup = mean(promIonoGroup{g});
    stdPromIonoGroup = std(promIonoGroup{g});
    avgWidthIonoGroup = mean(widthIonoGroup{g});
    stdWidthIonoGroup = std(widthIonoGroup{g});
    avgRiseIonoGroup = mean(riseIonoGroup{g});
    stdRiseIonoGroup = std(riseIonoGroup{g});
    avgFallIonoGroup = mean(fallIonoGroup{g});
    stdFallIonoGroup = std(fallIonoGroup{g});
    
    groupInfo(g,:) = {g,...
            numPeaksSpontGroupTotal,avgHeightSpontGroup,...
            stdHeightSpontGroup,avgPromSpontGroup,stdPromSpontGroup,...
            avgWidthSpontGroup,stdWidthSpontGroup,avgRiseSpontGroup,...
            stdRiseSpontGroup,avgFallSpontGroup,stdFallSpontGroup,...
            numPeaksTreatGroupTotal,avgHeightTreatGroup,...
            stdHeightTreatGroup,avgPromTreatGroup,stdPromTreatGroup,...
            avgWidthTreatGroup,stdWidthTreatGroup,avgRiseTreatGroup,...
            stdRiseTreatGroup,avgFallTreatGroup,stdFallTreatGroup,...
            numPeaksIonoGroupTotal,avgHeightIonoGroup,...
            stdHeightIonoGroup,avgPromIonoGroup,stdPromIonoGroup,...
            avgWidthIonoGroup,stdWidthIonoGroup,avgRiseIonoGroup,...
            stdRiseIonoGroup,avgFallIonoGroup,stdFallIonoGroup};
end
    
save('data.mat','cellInfo','groupInfo')
