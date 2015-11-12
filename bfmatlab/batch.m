% Start fresh!
close all; clear; clc;

% All files are stored on my flash drive - the F:\ drive
flashFiles = dir('C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\');

% Search the F:\ drive for folders that are titled as a date, i.e. in 2015.
% These are the folders that contain the experiment files to be analyzed.
dates = {};
for f = 1:length(flashFiles)
    if regexp(flashFiles(f).name,'2015') == 1
        dates{end+1} = ['C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\',flashFiles(f).name];
    end
end

% Go through each folder and all subfolders to find the Experiment folders'
% paths. Each Experiment will contain PreExposure.czi and PostExposure.czi
% experiment files, which are the image sequences that will be analyzed.
expPath = {};
for a = 1:length(dates)
    exps = dir(dates{a});
    date = dates{a}(end-9:end);
    for b = 3:length(exps)
        % Exclude Rhod-2 experiment numbers 7 and 9 - unusable data
        if (strcmp(date,'2015-10-14') && strcmp(exps(b).name,'07')) || ...
                (strcmp(date,'2015-10-14') && strcmp(exps(b).name,'09'))
            expPath = expPath;
        else
            expPath{end+1} = [dates{a},'\',exps(b).name];
        end
    end
end

% Analyze each PreExposure.czi and PostExposure.czi file for each
% experiment. Store results as Experiment objects. Analyze each cell within
% each experiment and store results as Cell objects. Experiments are
% divided into two groups: Fluo-8 and Rhod-2, depending on which [Ca2+]i
% indicator was used.
for a = 1:length(expPath)
    exp = Experiment(expPath{a});
    if strcmp(exp.date,'2015-09-29') || ...
            strcmp(exp.date,'2015-09-30') || ...
            strcmp(exp.date,'2015-10-01')
        expsFolder = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Experiments_Fluo-8';
        cellFolder = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Cells_Fluo-8';
    else
        expsFolder = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Experiments_Rhod-2';
        cellFolder = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Cells_Rhod-2';
    end
    expFileName = ['Experiment_',expPath{a}(end-1:end)];
    expFilePath = [expsFolder,'\',expFileName];
    if isempty(dir(expsFolder))
        mkdir(expsFolder)
    end
    save(expFilePath,'exp')
    
    cells = cell(exp.numCells,1);
    for c = 1:exp.numCells
        cells = Cell(exp.images,exp.mask,c);
        cellPath = [cellFolder,'\ExpNo',expFileName(end-1:end),'\CellNo',sprintf('%02d',c)];
        if isempty(dir([cellFolder,'\ExpNo',expFileName(end-1:end)]))
            mkdir([cellFolder,'\ExpNo',expFileName(end-1:end)])
        end
        save(cellPath,'cells')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % %%
% % cellsFluo8Folder = 'F:\Cells_Fluo-8';
% % expsFluo8Folders = dir(cellsFluo8Folder);
% % for x = 3:length(expsFluo8Folders)
% %     expFolder = [cellsFluo8Folder,'\',expsFluo8Folders(x).name];
% %     cellFiles = dir(expFolder);
% %     figure
% %     for c = 3:length(cellFiles)
% %         cellPath = [expFolder,'\',cellFiles(c).name];
% %         load(cellPath)
% %     end
% % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Collate data from each Cell
% clear; clc;
% 
% cellsFolderPath = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Cells_Fluo-8';
% % cellsFolderPath = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Cells_Rhod-2';
% 
% wksHeader1 = {'','','',...
%     'Spontaneous','','','','','','','','','','',...
%     'Treatment','','','','','','','','','','',''};
% wksHeader2 = {'','','',...
%     'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','', ...
%     'Num. Peaks','Height','','Prominence','','Width','','Rise','','Fall','','IsActive?'};
% wksHeader3 = {'Group No.','Experiment No.','Cell No.',...
%     '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD', ...
%     '','AVG','STD','AVG','STD','AVG','STD','AVG','STD','AVG','STD',''};
% wksHeaderFinal = cat(1,wksHeader1,wksHeader2,wksHeader3);
% 
% numPeaksSpontGroup = cell(9,1);
% heightSpontGroup = cell(9,1);
% promSpontGroup = cell(9,1);
% widthSpontGroup = cell(9,1);
% riseSpontGroup = cell(9,1);
% fallSpontGroup = cell(9,1);
% 
% numPeaksTreatGroup = cell(9,1);
% heightTreatGroup = cell(9,1);
% promTreatGroup = cell(9,1);
% widthTreatGroup = cell(9,1);
% riseTreatGroup = cell(9,1);
% fallTreatGroup = cell(9,1);
% 
% numActive = zeros(9,1);
% numCellsTotal = zeros(9,1);
% 
% count = 1;
% cellInfo = cell(1,26);
% expObjectPath = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Experiments_Fluo-8';
% % expObjectPath = 'C:\Users\Janty\Desktop\ZeissAxioObserverZ1_Microscope_Data\OptogeneticTesting\Experiments_Rhod-2';
% 
% for e = 1:12
%     if e ~= 7 && e ~= 9
%         expWorkspacePath = [expObjectPath,'\Experiment_',sprintf('%02d',e)];
%         load(expWorkspacePath)
%         groupNo = exp.groupNo;
%         expFolderPath = [cellsFolderPath,'\ExpNo',sprintf('%02d',e)];
%         numCells = length(dir(expFolderPath)) - 2;
%         for c = 1:numCells
%             cellPath = [expFolderPath,'\CellNo',sprintf('%02d',c)];
%             load(cellPath)
%             
%             if cells.isActive == 1
%                 numPeaksSpont = length(cells.spontaneousPeaks);
%                 avgHeightSpont = mean(cells.peakHeight(cells.spontaneousPeaks));
%                 stdHeightSpont = std(cells.peakHeight(cells.spontaneousPeaks));
%                 avgPromSpont = mean(cells.peakProm(cells.spontaneousPeaks));
%                 stdPromSpont = std(cells.peakProm(cells.spontaneousPeaks));
%                 avgWidthSpont = mean(cells.peakWidth(cells.spontaneousPeaks));
%                 stdWidthSpont = std(cells.peakWidth(cells.spontaneousPeaks));
%                 avgRiseSpont = mean(cells.peakRise(cells.spontaneousPeaks));
%                 stdRiseSpont = std(cells.peakRise(cells.spontaneousPeaks));
%                 avgFallSpont = mean(cells.peakFall(cells.spontaneousPeaks));
%                 stdFallSpont = std(cells.peakFall(cells.spontaneousPeaks));
% 
%                 numPeaksTreat = length(cells.treatmentPeaks);
%                 avgHeightTreat = mean(cells.peakHeight(cells.treatmentPeaks));
%                 stdHeightTreat = std(cells.peakHeight(cells.treatmentPeaks));
%                 avgPromTreat = mean(cells.peakProm(cells.treatmentPeaks));
%                 stdPromTreat = std(cells.peakProm(cells.treatmentPeaks));
%                 avgWidthTreat = mean(cells.peakWidth(cells.treatmentPeaks));
%                 stdWidthTreat = std(cells.peakWidth(cells.treatmentPeaks));
%                 avgRiseTreat = mean(cells.peakRise(cells.treatmentPeaks));
%                 stdRiseTreat = std(cells.peakRise(cells.treatmentPeaks));
%                 avgFallTreat = mean(cells.peakFall(cells.treatmentPeaks));
%                 stdFallTreat = std(cells.peakFall(cells.treatmentPeaks));
% 
%                 cellInfo(count,:) = {groupNo,e,c,...
%                     numPeaksSpont,avgHeightSpont,stdHeightSpont,...
%                     avgPromSpont,stdPromSpont,avgWidthSpont,stdWidthSpont,...
%                     avgRiseSpont,stdRiseSpont,avgFallSpont,stdFallSpont,...
%                     numPeaksTreat,avgHeightTreat,stdHeightTreat,...
%                     avgPromTreat,stdPromTreat,avgWidthTreat,stdWidthTreat,...
%                     avgRiseTreat,stdRiseTreat,avgFallTreat,stdFallTreat,...
%                     cells.isActive};
%                 count = count + 1;
%             end
% 
%             %% Group analysis
%             g = groupNo;
%             numPeaksSpontGroup{g} = ...
%                 [numPeaksSpontGroup{g},length(cells.spontaneousPeaks)];
%             heightSpontGroup{g} = ...
%                 [heightSpontGroup{g},cells.peakHeight(cells.spontaneousPeaks)'];
%             promSpontGroup{g} = ...
%                 [promSpontGroup{g},cells.peakProm(cells.spontaneousPeaks)'];
%             widthSpontGroup{g} = ...
%                 [widthSpontGroup{g},cells.peakWidth(cells.spontaneousPeaks)'];
%             riseSpontGroup{g} = ...
%                 [riseSpontGroup{g},cells.peakRise(cells.spontaneousPeaks)];
%             fallSpontGroup{g} = ...
%                 [fallSpontGroup{g},cells.peakFall(cells.spontaneousPeaks)];
% 
%             numPeaksTreatGroup{g} = ...
%                 [numPeaksTreatGroup{g},length(cells.treatmentPeaks)];
%             heightTreatGroup{g} = ...
%                 [heightTreatGroup{g},cells.peakHeight(cells.treatmentPeaks)'];
%             promTreatGroup{g} = ...
%                 [promTreatGroup{g},cells.peakProm(cells.treatmentPeaks)'];
%             widthTreatGroup{g} = ...
%                 [widthTreatGroup{g},cells.peakWidth(cells.treatmentPeaks)'];
%             riseTreatGroup{g} = ...
%                 [riseTreatGroup{g},cells.peakRise(cells.treatmentPeaks)];
%             fallTreatGroup{g} = ...
%                 [fallTreatGroup{g},cells.peakFall(cells.treatmentPeaks)];
% 
%             numActive(g) = numActive(g) + cells.isActive;
%         end
%         numCellsTotal(g) = numCellsTotal(g) + numCells;
%     end
% end
% %%
% groupInfo = cell(9,26);
% for g = 1:9        % 9 groups total
%     avgNumPeaksSpontGroup = mean(numPeaksSpontGroup{g});
%     stdNumPeaksSpontGroup = std(numPeaksSpontGroup{g});
%     avgHeightSpontGroup = mean(heightSpontGroup{g});
%     stdHeightSpontGroup = std(heightSpontGroup{g});
%     avgPromSpontGroup = mean(promSpontGroup{g});
%     stdPromSpontGroup = std(promSpontGroup{g});
%     avgWidthSpontGroup = mean(widthSpontGroup{g});
%     stdWidthSpontGroup = std(widthSpontGroup{g});
%     avgRiseSpontGroup = mean(riseSpontGroup{g});
%     stdRiseSpontGroup = std(riseSpontGroup{g});
%     avgFallSpontGroup = mean(fallSpontGroup{g});
%     stdFallSpontGroup = std(fallSpontGroup{g});
% 
%     avgNumPeaksTreatGroup = mean(numPeaksTreatGroup{g});
%     stdNumPeaksTreatGroup = std(numPeaksTreatGroup{g});
%     avgHeightTreatGroup = mean(heightTreatGroup{g});
%     stdHeightTreatGroup = std(heightTreatGroup{g});
%     avgPromTreatGroup = mean(promTreatGroup{g});
%     stdPromTreatGroup = std(promTreatGroup{g});
%     avgWidthTreatGroup = mean(widthTreatGroup{g});
%     stdWidthTreatGroup = std(widthTreatGroup{g});
%     avgRiseTreatGroup = mean(riseTreatGroup{g});
%     stdRiseTreatGroup = std(riseTreatGroup{g});
%     avgFallTreatGroup = mean(fallTreatGroup{g});
%     stdFallTreatGroup = std(fallTreatGroup{g});
%     
%     percentActive = numActive(g)/numCellsTotal(g);
%     
%     groupInfo(g,:) = {g,...
%             avgNumPeaksSpontGroup,stdNumPeaksSpontGroup, ...
%             avgHeightSpontGroup,stdHeightSpontGroup,avgPromSpontGroup,...
%             stdPromSpontGroup,avgWidthSpontGroup,stdWidthSpontGroup,...
%             avgRiseSpontGroup,stdRiseSpontGroup,avgFallSpontGroup,...
%             stdFallSpontGroup,avgNumPeaksTreatGroup,...
%             stdNumPeaksTreatGroup,avgHeightTreatGroup,...
%             stdHeightTreatGroup,avgPromTreatGroup,stdPromTreatGroup,...
%             avgWidthTreatGroup,stdWidthTreatGroup,avgRiseTreatGroup,...
%             stdRiseTreatGroup,avgFallTreatGroup,stdFallTreatGroup,...
%             percentActive};
% end
%     
% save('data.mat','cellInfo','groupInfo')
% 
% % Does it make sense to compare the 2 minute spontaneous signaling to the
% % 12 minute post-treatment signaling? Number of peaks in 12 minutes - even
% % spontaneous ones - would necessarily be greater in a 12 minute period of
% % time than in a 2 minute period of time.