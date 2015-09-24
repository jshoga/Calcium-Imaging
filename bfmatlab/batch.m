clear; close all; clc;

%% Initialize Experiment class for each experiment
% folder = uigetdir;
folder = 'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging';
foldersInFolder = dir(folder);
foldersOfInterest = foldersInFolder(3:end-8);

exp = cell(105,1);
for f = 1:length(foldersOfInterest)
    folderPath = [folder,'\',foldersOfInterest(f).name];
    sampleFolders = dir(folderPath);
    sampleFolders = sampleFolders(3:end);
    for s = 1:length(sampleFolders)
        samplePath = [folderPath,'\',sampleFolders(s).name,'\',...
            'Experiment.czi'];
        expNo = str2double(sampleFolders(s).name);
        exp = Experiment(samplePath);
        fileName = sprintf('Experiment_%03d',expNo);
        filePath = [folder,'\','Experiments\',fileName];
        save(filePath,'exp')
        clear exp
    end
end

%% Analyze each Cell in each Experiment
clear; clc;

expFolderPath = ...
    'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Experiments';
for e = 1:105
    expWorkspacePath = [expFolderPath,'\Experiment_',sprintf('%03d',e)];
    load(expWorkspacePath)
    for c = 1:exp.numCells
        cells = Cell(exp.images,exp.mask,c);
        if isempty(dir(['R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
                sprintf('%03d',exp.expNo)]))
            mkdir(['R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
                sprintf('%03d',exp.expNo)])
        end
        cellPath = [...
            'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells\ExpNo',...
            sprintf('%03d',exp.expNo),'\CellNo',sprintf('%02d',c)];
        save(cellPath,'cells')
        clear cells
    end
end

%% Collate data from each Cell
clear; clc;

cellsFolderPath = ...
    'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Cells';

wksHeader1 = {'','',...
    'Spontaneous','','','','','','','','','','',...
    'Treatment','','','','','','','','','','',...
    'Ionomycin','','','','','','','','','',''};
wksHeader2 = {'','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','',...
    'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall',''};
wksHeader3 = {'Experiment No.','Cell No.',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD',...
    '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD'};
wksHeaderFinal = cat(1,wksHeader1,wksHeader2,wksHeader3);

count = 1;
cellInfo = cell(1);
expObjectPath = 'R:\Dropbox\PriceLab_Resources\Projects\Optogenetics\CalciumImaging\Experiments';
for e = 1:l05
    expWorkspacePath = [expFolderPath,'\Experiment_',sprintf('%03d',e)];
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
    end
end