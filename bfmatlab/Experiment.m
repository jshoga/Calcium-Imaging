classdef Experiment < handle
    properties
        date
        expNo
        dye
        groupNo 
        treatment
        numCells
        mask
        cells
        images
    end
    methods    
        function obj = Experiment(expFolder,images,mask)
            if nargin == 0
                expFolder = uigetdir;
            end
            if nargin == 0 || nargin == 1
                dateIdx = regexp(expFolder,'2015');
                obj.date = expFolder(dateIdx:dateIdx+9);
                
                % Matlab must have a better way of handling dates
                if strcmp(obj.date,'2015-09-29') || ...
                    strcmp(obj.date,'2015-09-30') || ...
                    strcmp(obj.date,'2015-10-01') || ...
                    strcmp(obj.date,'2015-10-08') || ...
                    strcmp(obj.date,'2015-10-14') || ...
                    strcmp(obj.date,'2015-10-15') || ...
                    strcmp(obj.date,'2015-10-16') || ...
                    strcmp(obj.date,'2015-10-22') || ...
                    strcmp(obj.date,'2015-10-23') || ...
                    strcmp(obj.date,'2015-10-28') || ...
                    strcmp(obj.date,'2015-10-30') || ...
                    strcmp(obj.date,'2015-11-05') || ...
                    strcmp(obj.date,'2015-11-06') || ...
                    strcmp(obj.date,'2015-11-11') || ...
                    strcmp(obj.date,'2015-11-12') || ...
                    strcmp(obj.date,'2015-11-13') || ...
                    strcmp(obj.date,'2015-11-18')
                        prePath = [expFolder,'\PreExposure.czi'];
                        postPath = [expFolder,'\PostExposure.czi'];

                        pre = bfopen(prePath);
                        post = bfopen(postPath);

                        preImages = pre{1}(:,1);
                        postImages = post{1}(:,1);
                        regSequence = [preImages;postImages];
                else
                    path = [expFolder,'\Experiment.czi'];
                    czi = bfopen(path);
                    regSequence = czi{1}(:,1);
                end
                %% Read in images then trace cells in first image
                % First image in experiment
                firstImage = regSequence{1};
                % Initialize mask to be same size as images in experiment
                fullMask = zeros(size(firstImage));
%                 % Optimizes contrast and shows image.
%                 imshow(imadjust(firstImage))
                % Convert grayscale image to binary image
                % Filters the traced polygons such that traced regions
                % containing the number of pixels between the pixel range
                % provided are kept, and objects outside of the provided range 
                % are excluded.
                bw2 = bwareafilt(im2bw(imadjust(firstImage)),[100,1000]);
                % This is the trace program, goes east to begin searching for 
                % adjacent pixels and continues counterclockwise. Inf tells the
                % function to for an unlimited amount of pixels until it 
                % returns to the beginning.
                % Fill in cells so that there are no cells in cells
                % Store all of the traced cells in variable 'boundaries'
                boundaries = bwboundaries(imfill(bw2,'holes'));
                [l,w] = size(firstImage);
                for z = 1:length(boundaries)
                    % Store all pixel x coordinates
                    bx = boundaries{z}(:,2);
                    % Store all pixel y coordinates
                    by = boundaries{z}(:,1);
                    % Convert traced shape into a mask
                    bw3 = poly2mask(bx,by,l,w);
                    % Add current mask into a total mask
                    fullMask = fullMask + bw3;
                end
            elseif nargin == 3
                regSequence = images;
                fullMask = mask;
            else
                error('Error: You need either 0, 1, or 3 inputs')
            end

            % Find connected components (objects, i.e. cells) in mask
            cc = bwconncomp(fullMask,8);
            % Find objects greater than 10 pixels in size
            obj.cells = ...
                cc.PixelIdxList(cellfun('length',cc.PixelIdxList)>10);
            obj.mask = fullMask;
            obj.numCells = length(obj.cells);
            obj.images = regSequence;
            obj.expNo = str2double(expFolder(end-1:end));
            
            if strcmp(obj.date,'2015-09-29') || ...
                    strcmp(obj.date,'2015-09-30') || ...
                    strcmp(obj.date,'2015-10-01')
                obj.dye = 'Fluo-8';
                if obj.expNo == 1 || obj.expNo == 2 || obj.expNo == 3
                    obj.treatment = '10 s';
                    obj.groupNo = 3;
                elseif obj.expNo == 4 || obj.expNo == 5 || obj.expNo == 6
                    obj.treatment = '5 s';
                    obj.groupNo = 2;
                elseif obj.expNo == 7 || obj.expNo == 8 || obj.expNo == 9
                    obj.treatment = '0 s';
                    obj.groupNo = 7;
                elseif obj.expNo == 10
                    obj.treatment = '40 s';
                    obj.groupNo = 5;
                elseif obj.expNo == 11 || obj.expNo == 12 || obj.expNo == 13
                    obj.treatment = '1 s';
                    obj.groupNo = 1;
                end
            elseif strcmp(obj.date,'2015-10-08') || ...
                    strcmp(obj.date,'2015-10-14') || ...
                    strcmp(obj.date,'2015-10-15') || ...
                    strcmp(obj.date,'2015-10-16') || ...
                    strcmp(obj.date,'2015-10-22') || ...
                    strcmp(obj.date,'2015-10-23') || ...
                    strcmp(obj.date,'2015-10-28') || ...
                    strcmp(obj.date,'2015-10-30') || ...
                    strcmp(obj.date,'2015-11-05') || ...
                    strcmp(obj.date,'2015-11-06') || ...
                    strcmp(obj.date,'2015-11-11') || ...
                    strcmp(obj.date,'2015-11-12') || ...
                    strcmp(obj.date,'2015-11-13') || ...
                    strcmp(obj.date,'2015-11-18')
                obj.dye = 'Rhod-2';
                if obj.expNo == 13 || obj.expNo == 14 || obj.expNo == 15
                    obj.treatment = '1 s';
                    obj.groupNo = 1;
                elseif obj.expNo == 7 || obj.expNo == 8 || obj.expNo == 9
                    obj.treatment = '5 s';
                    obj.groupNo = 2;
                elseif obj.expNo == 10 || obj.expNo == 11 || obj.expNo == 12
                    obj.treatment = '10 s';
                    obj.groupNo = 3;
                elseif obj.expNo == 32 || obj.expNo == 33
                    obj.treatment = '20 s';
                    obj.groupNo = 4;
                elseif obj.expNo == 20 || obj.expNo == 24 || obj.expNo == 25 || obj.expNo == 26 || obj.expNo == 30 || obj.expNo == 31
                    obj.treatment = '40 s';
                    obj.groupNo = 5;
                elseif obj.expNo == 16 || obj.expNo == 17 || obj.expNo == 18 || obj.expNo == 19
                    obj.treatment = '60 s';
                    obj.groupNo = 6;
%                 elseif obj.expNo == 
%                     obj.treatment = '0 s';
%                     obj.groupNo = 7;
                elseif obj.expNo == 1 || obj.expNo == 2 || obj.expNo == 3
                    obj.treatment = '0 s - non-transfected';
                    obj.groupNo = 8;
                elseif obj.expNo == 4 || obj.expNo == 5 || obj.expNo == 6
                    obj.treatment = '60 s - non-transfected';
                    obj.groupNo = 9;
                elseif obj.expNo == 34 || obj.expNo == 35
                    obj.treatment = '20 s + GSK205';
                    obj.groupNo = 10;
%                 elseif obj.expNo == 
%                     obj.treatment = '20 s + Xestospongin C';
%                     obj.groupNo = 11;
                elseif obj.expNo == 21 || obj.expNo == 22 || obj.expNo == 23 || obj.expNo == 27 || obj.expNo == 28 || obj.expNo == 29
                    obj.treatment = 'unknown';
                    obj.groupNo = 12;
                end
            else
                obj.dye = 'Cal-590 or Rhod-4';
                obj.treatment = '?';
                obj.groupNo = '?';
            end
        end
        function AddObjects(obj)
            oldMask = obj.mask;
            newMask = zeros(size(oldMask));
            boundaries = bwboundaries(oldMask);
            
            [l,w] = size(oldMask);
            for z = 1:length(boundaries)
                % Store all pixel x coordinates
                bx = boundaries{z}(:,2);
                % Store all pixel y coordinates
                by = boundaries{z}(:,1);
                % Convert traced shape into a mask
                bw3 = poly2mask(bx,by,l,w);
                % Add current mask into a total mask
                newMask = newMask + bw3;
            end
            
            hiContrastImg = imadjust(obj.images{1});
            imshow(hiContrastImg)
            hold on
            for k = 1:length(boundaries)
                cellNo = boundaries{k};
                % Plot all traced cells
                plot(cellNo(:,2),cellNo(:,1),'g','LineWidth',1.5);
            end
            % Allow the user to circle additional cells if required
            DrawROIcheck = ...
                questdlg('Would you like to circle another cell?', ...
                'Checking...','Yes','No','Yes');
            cnt = 1;
            while strcmp(DrawROIcheck,'Yes') == 1
                h = imfreehand;
                bw = createMask(h);
                DrawROIcheck = ...
                    questdlg('Would you like to circle another cell?',...
                    'Checking...','Yes','No','Yes');
                newMask = newMask + bw;
                cnt = cnt + 1;
            end
            obj.mask = newMask;
        end
    end
end
