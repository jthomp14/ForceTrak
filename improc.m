classdef improc < handle
    %Class includes many image processing functions to be used in tracking
    %applications
    
    
    methods(Static)
        
        
        %Extension of returnThreshold, adds clicking on an open figure with
        % image to get values
        function [thresholds] = getThresh(im,nummark,threshType)
            
            [x,y] = ginput(nummark);
            markerclicks = [y,x];
            
            thresholds = improc.returnThreshold(im,markerclicks,nummark,threshType);
            
        end
        
        function [thresholds] = returnThreshold(im,markerclicks,nummark,threshType)
            
            if strcmp(threshType,'unitvec') == 1
                
                for i = 1:nummark
                    rgb(i,:) = im(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                r = rgb(:,1);
                g = rgb(:,2);
                b = rgb(:,3);
                
                meanR = mean(r);
                meanG = mean(g);
                meanB = mean(b);
                
                unitR = meanR/sqrt(meanR^2 + meanG^2 + meanB^2);
                unitG = meanG/sqrt(meanR^2 + meanG^2 + meanB^2);
                unitB = meanB/sqrt(meanR^2 + meanG^2 + meanB^2);
                
                thresholds = [unitR unitG unitB];
                
            elseif strcmp(threshType,'hsv') == 1
                
                hsvim = rgb2hsv(im);
                for i = 1:nummark
                    hsv(i,:) = hsvim(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                h = hsv(:,1);
                s = hsv(:,2);
                v = hsv(:,3);
                
                meanH = mean(h); 
                % For Pink: Use a lower value of meanH - .04 & upper value
                % of meanH + .06
                
%                 meanS = mean(s);
%                 meanV = mean(v);
%                 sxH = std(h);
%                 sxS = std(s);
%                 sxV = std(v);
%                 
%                 LowerHval = meanH - sxH*tval(2);
%                 HighHval = meanH + sxH*tval(2);
%                 LowerSval = meanS - sxS*tval(1);
%                 HighSval = meanS + sxS*tval(2);
%                 LowerV = meanV - sxV*tval(2);
%                 HighV = meanV + sxV*tval(2);
                
                thresholds = [meanH];
                
            elseif strcmp(threshType,'govrb') == 1
                
                tval = [2.776445105 2.776445105 2.776445105 2.776445105 2.570581836 2.446911851 2.364624252];
                g_ov_brim = double(im(:,:,2))./(double(im(:,:,1)) + double(im(:,:,3)));
                for i = 1:nummark
                    govrb(i,:) = g_ov_brim(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                meanG = mean(govrb);
                sxG = std(govrb);
                LowerGval = meanG - sxG*tval(nummark);
                HighGval = meanG + sxG*tval(nummark);
                thresholds = [LowerGval HighGval];
                
            elseif strcmp(threshType,'bovrg') == 1
                tval = [2.776445105 2.776445105 2.776445105 2.776445105 2.570581836 2.446911851 2.364624252];
                b_ov_rg = double(im(:,:,3))./(double(im(:,:,1)) + double(im(:,:,2)));
                for i = 1:nummark
                    govrb(i,:) = b_ov_rg(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                meanG = mean(govrb);
                sxG = std(govrb);
                LowerGval = meanG - sxG*tval(nummark);
                HighGval = meanG + sxG*tval(nummark);
                thresholds = [LowerGval HighGval];
                
            elseif strcmp(threshType,'rovbg') == 1
                
                tval = [2.776445105 2.776445105 2.776445105 2.776445105 2.570581836 2.446911851 2.364624252];
                r_ov_bg = double(im(:,:,1))./(double(im(:,:,3)) + double(im(:,:,2)));
                for i = 1:nummark
                    govrb(i,:) = r_ov_bg(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                meanG = mean(govrb);
                sxG = std(govrb);
                LowerGval = meanG - sxG*tval(nummark);
                HighGval = meanG + sxG*tval(nummark);
                thresholds = [LowerGval HighGval];
                
            elseif strcmp(threshType,'all_values') == 1
                
                hsvim = rgb2hsv(im);
                for i = 1:nummark
                    thresholds(i,:) = hsvim(round(markerclicks(i,1)),round(markerclicks(i,2)),:);
                end
                
            end
        end
        
        
        %% BINARY IMAGE FUNCTIONS
        function [binary] = unitvec2bin(im,desir_unvec,diffthresh)
            
            im = double(im);
            
            siz = size(im);
            imunvec = zeros(siz);
            imunvec(:,:,1) = im(:,:,1)./sqrt(im(:,:,1).^2 + im(:,:,2).^2 + im(:,:,3).^2);
            imunvec(:,:,2) = im(:,:,2)./sqrt(im(:,:,1).^2 + im(:,:,2).^2 + im(:,:,3).^2);
            imunvec(:,:,3) = im(:,:,3)./sqrt(im(:,:,1).^2 + im(:,:,2).^2 + im(:,:,3).^2);
            
            for i = 1:siz(1)
                for j = 1:siz(2)
                    
                    rootsum = sqrt( (imunvec(i,j,1) - desir_unvec(1))^2 + (imunvec(i,j,2) - desir_unvec(2))^2 + (imunvec(i,j,3) - desir_unvec(3))^2 );
                    
                    if rootsum < diffthresh
                        binary(i,j) = 1;
                    else
                        binary(i,j) = 0;
                    end
                    
                end
            end
            
        end
        
        % Green to Binary conversion (Green Tape)
        function [binary] = grn2bin(im,high_bthr,dropd_thresh,min_bthr,normthresh)
            
            % Uses G/(R + B)
            
            %Inputs:
            
            % " high_bthr "
                % If green content is high, drop the G/(R + B) threshold
                % value
            
            % " dropd_thresh "
                %value that threshold is dropped to if green content is
                %high
                
            % " min_bthr "
                % Green pixel must be above this in order to pass
            
            % " normthresh "
                % Normal G/(B + R) threshold used if pixel is above    
                % " min_bthr " (our normal color ratio used)
            
            
            %Create new G/(R + B) matrix
            g_ov_br = double(im(:,:,2))./(double(im(:,:,1)) + double(im(:,:,3)));
            
            siz = size(g_ov_br);
            binary = zeros(siz(1),siz(2)); %Initialize our binary matrix
            
            %Checking each pixel to see if it meets our conditions
            for i = 1:length(g_ov_br(:,1,1))
                for j = 1:length(g_ov_br(1,:,1))
                    
                    if (im(i,j,2) > high_bthr &&  g_ov_br(i,j) > dropd_thresh) || (g_ov_br(i,j) > normthresh && im(i,j,2) > min_bthr)
                        binary(i,j) = 1;
                    else
                        binary(i,j) = 0;
                    end
                    
                end
            end
            
            
        end
        
        % Red to Binary conversion (Red Taoe)
        function [binary] = red2bin(im,high_bthr,dropd_thresh,min_bthr,normthresh)
            
            %Create new matrix
            r_ov_gb = double(im(:,:,1))./(double(im(:,:,2)) + double(im(:,:,3)));
            
            siz = size(r_ov_gb);
            binary = zeros(siz(1),siz(2)); %Initialize our binary matrix
            
            for i = 1:length(r_ov_gb(:,1,1))
                for j = 1:length(r_ov_gb(1,:,1))
                    
                    if (im(i,j,1) > high_bthr &&  r_ov_gb(i,j) > dropd_thresh) || (r_ov_gb(i,j) > normthresh && im(i,j,1) > min_bthr)
                        binary(i,j) = 1;
                    else
                        binary(i,j) = 0;
                    end
                    
                end
            end
            
            
            
        end
        
        %Filters using B/G+R (Blue Tape)
        function [binary] = blue2bin(im,high_bthr,dropd_thresh,min_bthr,normthresh)
            
            b_ov_gr = double(im(:,:,3))./(double(im(:,:,1)) + double(im(:,:,2)));
            
            siz = size(b_ov_gr);
            binary = zeros(siz(1),siz(2)); %Initialize our binary matrix
            
            %Checking each pixel to see if it meets our conditions
            for i = 1:length(b_ov_gr(:,1,1))
                for j = 1:length(b_ov_gr(1,:,1))
                    
                    if (im(i,j,2) > high_bthr &&  b_ov_gr(i,j) > dropd_thresh) || (b_ov_gr(i,j) > normthresh && im(i,j,2) > min_bthr)
                        binary(i,j) = 1;
                    else
                        binary(i,j) = 0;
                    end
                    
                end
            end
            
        end
        
        %Converts an image to a binary image using HSV thresholding
        function [binary] = im2hsv(im,lowHue,highHue,lowSat,highSat,lowVal,highVal)
            
            hsv = rgb2hsv(im);
            siz = size(im);
            binary = zeros(siz(1),siz(2));
            
            for i = 1:siz(1)
                for j = 1:siz(2)
                    
                    if (hsv(i,j,1) <= highHue && hsv(i,j,1) >= lowHue) && (hsv(i,j,2) <= highSat && hsv(i,j,2) >= lowSat) && (hsv(i,j,3) <= highVal &&  hsv(i,j,3) >= lowVal )
                        binary(i,j) = 1;
                    else
                        binary(i,j) = 0;
                    end
                    
                end
            end
            
            
        end
        
        % Returns average H,S, and V values for every centroid
        
        
        
        %% CORRELATION FUNCTIONS
        %Correlates marker positions from two binary images
        function [bin1cent] = binaryCorr(bin1,bin2,dist_thresh,nummark)
            
            cent1 = improc.getcentroidsmod(bin1);  % Finds all centroids for binary image # 1
            cent2 = improc.getcentroidsmod(bin2);  % "                                    " 2  
            
            % Calculate all combinations of differences
            for i = 1:length(cent1(:,1))
                for j = 1:length(cent2(:,1))
                    distt(j,i) = sqrt( (cent1(i,1) - cent2(j,1))^2 + (cent1(i,2) - cent2(j,2))^2 );
                end
            end
            
            % Filter through distances to find the smallest ones
            [dist6,Ind] = sort(distt(:));
            dist6 = dist6(1:nummark);
            Ind = Ind(1:nummark);
            
            delet = find(dist6 > dist_thresh);
            dist6(delet) = [];
            Ind(delet) = [];
            
            for i = 1:length(dist6)
                [I(i),J(i)] = ind2sub(size(distt),Ind(i));
                 bin1cent(i,:) = cent1(J(i),:);
            end

%             k = 1;
%             for i = 1:length(dist(:,1))
%                 for j = 1:length(dist(1,:))
%                     
%                     if dist(i,j) < dist_thresh
%                        centidx(k,1:2) = [j,i]; 
%                        k = k + 1;
%                     end
%                     
%                 end
%             end

            % Extracting centroids from the minimum distances
%             for i = 1:length(centidx(:,1))
%                 cent1(i,1:2) = cent1(centidx(i,1),:);
%                 cent2(i,1:2) = cent2(centidx(i,2),:);
%             end
            
            
        end
        
        %Version 1
        %Correlates Centroids from binary matrix to the predicted locations
        function [collocatedCents] = centroidCollocation(binCents,predictedLocations,dist_thresh,nummark)
            
            
            for k = 1:length(predictedLocations(:,1))
                
                for i = 1:length(binCents(:,1))
                    distt(i,1) = sqrt( (binCents(i,1) - predictedLocations(k,1))^2 + (binCents(i,2) - predictedLocations(k,2))^2 );
                end
                
                % Filter through distances to find the smallest ones
                [dist6,Ind] = sort(distt(:));
                dist6 = dist6(1);
                Ind = Ind(1);
                
                delet = find(dist6 > dist_thresh);
                dist6(delet) = [];
                Ind(delet) = [];
                
                for i = 1:length(dist6)
                    [I(i),J(i)] = ind2sub(size(distt),Ind(i));
                    collocatedCents(k,:) = binCents(I(i),:);
                end
                
                distt= [];
                
            end
            
        end
        
        %Version 2 
        % if a collocation is made, dont allow it to be made to
        %that centroid again (remove that centroid from the necessary matrix so it cant be used again)
        function [collocatedCents] = centroidCollocationV2(binCents,predictedLocations,dist_thresh,nummark)
            
            for k = 1:length(predictedLocations(:,1))
                
                for i = 1:length(binCents(:,1))
                    distt(i,1) = sqrt( (binCents(i,1) - predictedLocations(k,1))^2 + (binCents(i,2) - predictedLocations(k,2))^2 );
                end
                
                % Filter through distances to find the smallest ones
                [dist6,Ind] = sort(distt(:));
                dist6 = dist6(1);
                Ind = Ind(1);
                
                delet = find(dist6 > dist_thresh);
                dist6(delet) = [];
                Ind(delet) = [];
                
                for i = 1:length(dist6)
                    [I(i),J(i)] = ind2sub(size(distt),Ind(i));
                    collocatedCents(k,:) = binCents(I(i),:);
                    binCents(I(i),:) = [NaN,NaN];
                end
                
                distt= [];
                
            end
            
        end
        
        %Correlates the centroids found in a box to the centroids in the populated centroid list 
        function [cent2remov] = centCorr(centList,boxcentlist,distThresh)
            
            if isempty(centList) == 0 && isempty(boxcentlist) == 0
                
                for i = 1:length(centList(:,1))
                    for j = 1:length(boxcentlist(:,1))
                        distt(j,i) = sqrt( (centList(i,1) - boxcentlist(j,1))^2 + (centList(i,2) - boxcentlist(j,2))^2 );
                    end
                end
                
                % Filter through distances to find the smallest ones
                [dist6,Ind] = sort(distt(:));
                
                if dist6(1) < distThresh
                    dist6 = dist6(1); %Choose the smallest one
                    Ind = Ind(1);
                else
                    cent2remov = [];
                    return
                end
                
                %delet = find(dist6 > 30);
                %dist6(delet) = [];
                %Ind(delet) = [];
                
                for i = 1:length(dist6)
                    [I(i),J(i)] = ind2sub(size(distt),Ind(i));
                    cent2remov(i,:) = centList(J(i),:);
                end
                
            else
                cent2remov = [];
            end
            
        end
        
        
        %% MISC
        function [bin] = filterDiffIm(diffIm,botThresh)
            
            siz = size(diffIm);
            bin = zeros(siz(1),siz(2));
            
             for i = 1:siz(1)
                for j = 1:siz(2)
                    
                    if diffIm(i,j) > botThresh
                        bin(i,j) = 1;
                    else
                        bin(i,j) = 0;
                    end
                    
                end
            end
            
        end
        
        
        %% FIND CENTROIDS
        function [cent] = getcentroids(binary)
            
            %Finding connected pixels brightness binary matrix
            CC = bwconncomp(binary);
            numpixels = cellfun(@numel,CC.PixelIdxList);
            S = regionprops(CC,'Centroid','Area','Eccentricity');
            eccen = cat(1,S.Eccentricity);
            centroids = cat(1,S.Centroid);
            
            centroids = centroids(:,[2,1]); %Flips the 2nd and 1st row (changes matrix from x,y to row,col)
            
            %Eliminating groups of pixels with very small areas
            [idxpix] = find(numpixels < 20);
            centroids(idxpix,:) = [];
            numpixels(idxpix) = [];
            eccen(idxpix) = [];
            
            %Eliminating centroids coming from high eccentricity (pixel groups close to being a line)
            index = find(eccen > .92);
            centroids(index,:) = [];
            
            
            %If there is still more than one centroid, remove duplicate markers that are approximately at the same position
            if length(centroids(:,1)) > 1
                [cent] = removecloseOLD(centroids, numpixels, 15);
            elseif isempty(centroids) == 1
                cent = [];
            else
                cent = centroids;
            end
            
        end
        
        %Get Cent's NOT including Mike's function 'RemoveClose'
        function [cent] = getcentroidsmod(binary)
            
            %Finding connected pixels brightness binary matrix
            CC = bwconncomp(binary);
            numpixels = cellfun(@numel,CC.PixelIdxList);
            S = regionprops(CC,'Centroid','Area','Eccentricity');
            eccen = cat(1,S.Eccentricity);
            centroids = cat(1,S.Centroid);
            
            centroids = centroids(:,[2,1]); %Flips the 2nd and 1st row (changes matrix from x,y to row,col)
            
            %Eliminating groups of pixels with very small areas
            [idxpix] = find(numpixels < 0);
            centroids(idxpix,:) = [];
            numpixels(idxpix) = [];
            eccen(idxpix) = [];
            
            %Eliminating centroids coming from high eccentricity (pixel groups close to being a line)
%             index = find(eccen > .95);
%             centroids(index,:) = [];
            
            cent = centroids;
            
        end
        
        
    end
    
    
end