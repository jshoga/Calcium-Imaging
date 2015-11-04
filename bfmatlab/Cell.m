classdef Cell
    properties
        cellNo      % which cell in the experiment it is
        numPeaks    % number of peaks
        peakHeight  % vector of all peak heights
        peakTime    % vector of all peak times
        peakProm    % vector of all peak prominences
        peakWidth   % vector of all peak widths
        peakRise    % vector of all peak rise times
        peakFall    % vector of all peak fall times
        spontaneousPeaks    % peaks that occur before treatment
        treatmentPeaks      % peaks that occur after treatment
        intensity   % vector of intensity values
        isActive    % boolean 1 if cell responds to treatment, else 0
    end
    methods
        function obj = Cell(images,mask,cellNumber)
            % Find connected components (objects, i.e. cells) in mask
            cc = bwconncomp(mask,8);
            % Find objects greater than 10 pixels in size
            cells = ...
                cc.PixelIdxList(cellfun('length',cc.PixelIdxList)>10);
            
            img1 = double(images{1}(cells{cellNumber}));
            normal = mean(img1);
            intensityAvg = zeros(length(images),1);
            for img = 1:length(images)
                cellOnly = double(images{img}(cells{cellNumber}));
                intensityAvg(img) = mean(cellOnly)/normal;
            end
            intensityAvgSmoothe = sgolayfilt(intensityAvg,7,41);
            sampleFrequency = 1;
            
            stdDev = std(intensityAvgSmoothe(1:120));
            lim = stdDev*3;
            
            [obj.peakHeight,obj.peakTime,obj.peakWidth,obj.peakProm] = ...
                findpeaks(intensityAvgSmoothe,sampleFrequency, ...
                'MinPeakProminence',lim);
            
            peakStart = zeros(size(obj.peakHeight));
            peakEnd = zeros(size(obj.peakHeight));
            for a = 1:length(obj.peakHeight)
                pX = obj.peakTime(a);
                % Peak half-prominence height
                pY = obj.peakHeight(a) - obj.peakProm(a)/2;
                peakStart(a) = ...
                    pX + 1 - find(flip(intensityAvgSmoothe(1:pX)) <= pY,1);
                obj.peakRise(a) = ...
                    obj.peakTime(a) - peakStart(a);
                peakEnd(a) = ...
                    pX - 2 + find(intensityAvgSmoothe(pX:end) <= pY,1);
                obj.peakFall(a) = peakEnd(a) - obj.peakTime(a);
            end
            
            obj.cellNo = cellNumber;
            obj.spontaneousPeaks = find(obj.peakTime < 120);
            obj.treatmentPeaks = find(obj.peakTime >= 120);
            if length(obj.treatmentPeaks) > length(obj.spontaneousPeaks)
                obj.isActive = 1;
            else
                obj.isActive = 0;
            end
            obj.numPeaks = length(obj.treatmentPeaks);
            obj.intensity = intensityAvg;
        end
    end
end