classdef Cell < Experiment
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
    end
    methods
        function obj = Cell(filepath,images,mask,cellNo)
            obj@Experiment(filepath,images,mask);
            
            img1 = double(obj.images{1}(obj.cells{cellNo}));
            normal = mean(img1);
            intensityAvg = zeros(length(obj.images),1);
            for img = 1:length(obj.images)
                cellOnly = double(obj.images{img}(obj.cells{cellNo}));
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
            
            obj.spontaneousPeaks = find(obj.peakTime < 120);
            obj.treatmentPeaks = find(obj.peakTime >= 120);
            
            obj.intensity = intensityAvg;
        end
    end
end
