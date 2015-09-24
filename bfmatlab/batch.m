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

