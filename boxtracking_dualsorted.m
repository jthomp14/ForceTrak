function [markerpos,markerarray] = boxtracking_dualsorted(Svid,vTog,markerclicks,boxDist,markerarray,OccultationData)

counter = 0;
time = 0;

%Thinking iteration variable (used only if plotting on GUI is disabled)
thinking_iter = 0;

%assignment of initial clicks
for i=1:length(markerclicks(:,1))
    clicks(:,:,i) = markerclicks(i,:);
end


% app.im(:,:,ii) = fliplr(app.im(:,:,ii));

%-------------------------------------------------------------------------
%% Occulation Setup/initializing information
%initialize holder variable for occultation implications

%*********************************************************
%*********************************************************
%PLANS FOR WRIST OCCULTATION:
%   - Test for determining if box of wrist is within box for hip
%       - This needs to consider hip location + box and some
%           Threshold for wrist location
%Wrist goes first
%When it's hip's turn - then i can determine distance
%OR know distance based on previous frame distance
%   - If this distance is "x" length away then initialize hip occultation
%   - Ok!
%NEED TO DEAL WITH THE EVENT THAT THE SYSTEM SEES THE HIP
%MARKER IN THE BOX WITH THE WRIST MARKER AS ITS TRYING
%TO CALCULATE THE WRIST MARKER
%MAYHAPS SKIP WRIST AND COME BACK TO WRIST AFTER SCRUBBING
%HIP INFORMATION???
%*********************************************************
%*********************************************************

%Set up easy indexing for code
if OccultationData.OccultBoolWithWrist == 1
    wrist = OccultationData.IndexArray(1);
    hip = OccultationData.IndexArray(2);
    thigh = OccultationData.IndexArray(3);
    knee = OccultationData.IndexArray(4);
    OccultBool = 1;
elseif OccultationData.OccultBoolNoWrist == 1
    hip = OccultationData.IndexArray(1);
    thigh = OccultationData.IndexArray(2);
    knee = OccultationData.IndexArray(3);
    OccultBool = 1;
else
    OccultBool = 0;
end

holder = 0;
whereisj = 0;
skip1frame = 0;
iter = 0;
skipcount = 0;
%-------------------------------------------------------------------------


%% 1 - Video Properties
vid = Svid.vid;
sframe = Svid.sframe;
tframe = Svid.tframe;
vidnum = Svid.vidnum;
nummark = Svid.nummark;
jointschosen = Svid.jointschosen;

ref1 = Svid.ref1;
refang = Svid.refang;
pxtom = Svid.pxtom;
hsvthresh = Svid.hsvthresh;
unitvecthresh = Svid.unitvecthresh;
rot_num = Svid.rot_num;
jointschosen = Svid.jointschosen;

%fig = figure('Position',[0 0 2000 1600]); %Creating verification figure to show tracking
box = [];

% %---------------------------------------
% %DELETE THIS<----- only for testing
% im = read(vid,i+sframe-1);
% im = rot90(im,rot_num);
%     if vidnum == 2 %second video auto flipped here
%         for ii = 1:3
%             im(:,:,ii) = fliplr(im(:,:,ii));
%         end
%     end
% imshow(im);
% %---------------------------------------

% Looping through each frame
for i = 1:tframe
    %Reading Frame, cropping and rotate if needed
    tic
    im = read(vid,i+sframe-1);
    im = rot90(im,rot_num);
    
    if vidnum == 2 %second video auto flipped here
        for ii = 1:3
            im(:,:,ii) = fliplr(im(:,:,ii));
        end
    end
    
    %Saving cropped/object removed image for plotting
    pic = im;
    imgaus = imgaussfilt(im,2); %<---- <><><> internal matlab function look up
    
    %Deal with Wrist/Hip Box Occulation possibility
    if i>1 && OccultationData.OccultBoolWithWrist == 1
        
        %Determine distance between wrist and hip last frame
        HipToWristDist = double(marker.MarkerDist(mymark(hip).lastmarker,mymark(wrist).lastmarker));
        OccultationData = JustHipToWrist(OccultationData,dist);
        
        %Determine the boolean for the wrist and hip occultation
        %if engaged(1) we will be calculating hip marker on this 'i'th frame
        if HipToWristDist <= 70
            HipWristBool = 1; %<-- wrist and hip too close
        else
            HipWristBool = 0; %<-- Wrist and hip good
        end
    else
        HipWristBool = 0; %<-- No wrist/hip combo selected
    end
    

    
    
    
    %% Search in each box for a marker
    for j = 1:length(markerclicks(:,1)) %markerclicks should be = #markers
        
        %Frame counter <----------------------------- delete this
        %fprintf('i = %.0f,  j = %.0f\n',i,j)
        
        %set up boxes for searching for the marker:
        if i < 3 %Framenum 1 and 2 boxposition is the same
            %assign box row and column
            row1 = markerclicks(j,1) - boxDist;
            row2 = markerclicks(j,1) + boxDist;
            column1 = markerclicks(j,2) - boxDist;
            column2 = markerclicks(j,2) + boxDist;
            x(j) = markerclicks(j,2); %Column
            y(j) = markerclicks(j,1); %Row
            boxcenter = [markerclicks(j,1),markerclicks(j,2)];   
        elseif i == 3
            %Assigns box (code looks identical to the else below???
            v2 = markcent(j,:,i-1) - markcent(j,:,i-2); %Velocity (position difference)
            boxcenter = markcent(j,:,i-1) + v2; %Only using first velocity to predict next location
            v1 = v2;
            
            %For plotting
            x(j) = boxcenter(1,2); %column
            y(j) = boxcenter(1,1); %row
            
            %Creating Box
            row1 = boxcenter(1,1) - boxDist;
            row2 = boxcenter(1,1) + boxDist;
            column1 = boxcenter(1,2) - boxDist;
            column2 = boxcenter(1,2) + boxDist;     
        else
            %Propogate box out
            v2 = markcent(j,:,i-1) - markcent(j,:,i-2); %Velocity (position difference)
            boxcenter = markcent(j,:,i-1) + v2; % + (.05)*(v2 - v1); %Predicting next location of marker and placing a box there
            v1 = v2; %Storing (now old) velocity to compute acceleration
            
            %For plotting
            x(j) = boxcenter(1,2); %column = x pos
            y(j) = boxcenter(1,1); %row = y pos
            
            %Creating Box
            row1 = boxcenter(1,1) - boxDist; %Top row
            row2 = boxcenter(1,1) + boxDist; %Bottom row
            column1 = boxcenter(1,2) - boxDist; %left column
            column2 = boxcenter(1,2) + boxDist; %right column  
        end
        
        % Indices must be positive real integers
        if row1 < 1
            row1 = 1;
        elseif row2 < 1
            row2 = 1;
        elseif column1 < 1
            column1 = 1;
        elseif column2 < 1
            column2 = 1;
        end
        
        % Propagating the next threshold values out based off how they are changing
        if i < 6
            propagated_point = hsvthresh(j,:,1);
        else
            propagated_point = [mean( hsvthresh(j,1,(i-5):(i-1)) ) mean( hsvthresh(j,2,(i-5):(i-1)) ) mean( hsvthresh(j,3,(i-5):(i-1)) )];
        end
        
        % Looking in the box to find marker
        box = imgaus(round(row1):round(row2),round(column1):round(column2),:);
        
        %NOTE - When bin returns all zeros we have Occultation
        %bin size is 61 x 61
        bin = improc.im2hsv(box,propagated_point(1) - .15, propagated_point(1) + .15, propagated_point(2) - .15, propagated_point(2) + .15, propagated_point(3) - .15, propagated_point(3) + .15);
        
        
        %--------------------------------------------------------
        %this little bit deals with skipping frames to get HSV values
        %It only works if the original setup of the system returns
        %a hit on any(any(bin)) <--- not sure if this is making any
        %difference, but preliminary test implied it was...
        numskips = 2;
        if any(any(bin)) && j == whereisj && skipcount <= numskips
            skip1frame = 1;
            skipcount = skipcount+1;
            fprintf('skipcount = %.0f\n',skipcount)
        elseif j == whereisj
            skipcount = 0;
            skip1frame = 0;
        end
        %--------------------------------------------------------
        

        %% To Occult or Not To Occult - That is the question:
        %*******************************************************
            %*******************************************************
            %OCCULTATION FIX IDEA
            %When the bin matrix returns zeros (i.e. it's not finding any
            %marker hsv data - Also an issue when coming back from OCTN),
            % - skip the threshold bit below and the centroid bit below
            % - initialize a holder variable and prescribe a set of
            %       ones to the very center of the bin box
            % - proceed to the next marker (j iteration)
            % - once done iterating through all the markers
            %       in (i) index the algorithm jumps out of the
            %       (j) for loop and stores the centroid information
            %       in "markcent(:,:,i) = cent;"
            %       So include an if statement referencing the holder
            %       variable that initiates calculations...
            % - initialize the calculation function to run the calculation
            %       on the index (j) where the holder value was located
            %       and calculate the anticipated centroid value
            %       Using the occultation function
            % - Store this value in markcent(:,:,i) = cent;
            % - proceed on to reloop through the process
            %*******************************************************
        %*******************************************************
        
        
        %-------------------------------------------------------------
        %Wrist Occultation is a possibility / wrist and hip too close
        %This tells system when to skip centroid calculations for hip
        %but it allows calculation of the wrist (need to do testing here)
        if HipWristBool && j == hip && holder ~= 1
            
            %Holder variable tells the system occulation has occurred
            holder = 1;
            
            %iter counts the number of iterations of consecutive occulation
            iter = iter+1;
            if iter == 1
                %hsvhold = hsvthresh(j,:,i-1);
                hsvhold = [mean( hsvthresh(j,1,(i-5):(i-1)) ) mean( hsvthresh(j,2,(i-5):(i-1)) ) mean( hsvthresh(j,3,(i-5):(i-1)) )];
            end
            
            %set the hsv threshold
            hsvthresh(j,:,i) = hsvhold;
            
            %holds onto the index that is occulting (in this case its hip
            %only - wrist not written to deal with thigh or knee
            %occultations at this point).
            whereisj = j;
            
            %store information as needed
            markerarray(j) = addmarker(markerarray(j),marker(0,0));
            markerarray(j) = storeoccultframes(markerarray(j), i, iter);
            fprintf('OCCULTATION IS OCCURING on %s\n',markerarray(j).markername)
            fprintf('Consecutive Occultation Occurance: #%.0f\n',iter)
            skipcount = 3;
        %-------------------------------------------------------------
         
        
        
        %-------------------------------------------------------------    
        %This is the case where no occulation is occuring:    
        elseif any(any(bin)) && skip1frame == 0
  
            [boxcent] = improc.getcentroidsmod(bin);
            
            %Finding the average threshold values for the marker in the box
            ind = find(bin == 1);
            siz = size(bin);
            [I,J] = ind2sub(siz,ind);
            hsvim = rgb2hsv(box);
            
            avgH = hsvim(I,J,1);
            avgH = mean(avgH(:));
            
            avgS = hsvim(I,J,2);
            avgS = mean(avgS(:));
            
            avgV = hsvim(I,J,3);
            avgV = mean(avgV(:));
            
            hsvthresh(j,:,i) = [avgH avgS avgV];
            
            
            %If more than 1 marker is found, use the one closest to the center
            %of the box
            %Noise issues are slight, but noticable for occultation calcs
            if length(boxcent(:,1)) > 1
                [closest2centerofbox] = improc.centCorr([boxcent(:,1) + row1, boxcent(:,2) + column1],boxcenter,40);
                cent(j,1) = closest2centerofbox(1,1);%<-- y coord
                cent(j,2) = closest2centerofbox(1,2);%<-- x coord
            else
                cent(j,:) = boxcent + [row1 column1];
            end
            
            %ADD THE Centroid data to marker class
            markercent = marker(cent(j,2),cent(j,1)); %<-- verify y,x
            markerarray(j) = addmarker(markerarray(j),markercent);
        %-------------------------------------------------------------
        
        
        
        
        %-------------------------------------------------------------
        %This is the case for when occulation is occuring that is not
        %associated with the wrist marker and hip marker conflict situation
        elseif holder ~= 1 
            
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            %DO IF STATEMENTS TO RULE OUT OCCULTATION OF JOINTS OTHER THAN
            %KNEE HIP THIGH - THUS THROW ERROR...
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            %leave hsvthresh where it was (do not update)
            holder = 1;
            iter = iter+1;
            if iter == 1
                %hsvhold = hsvthresh(j,:,i-1);
                hsvhold = [mean( hsvthresh(j,1,(i-5):(i-1)) ) mean( hsvthresh(j,2,(i-5):(i-1)) ) mean( hsvthresh(j,3,(i-5):(i-1)) )];
            end
            hsvthresh(j,:,i) = hsvhold;
            whereisj = j;
            markerarray(j) = addmarker(markerarray(j),marker(0,0));
            markerarray(j) = storeoccultframes(markerarray(j), i, iter);
            fprintf('OCCULTATION IS OCCURING on %s\n',markerarray(j).markername)
            fprintf('Consecutive Occultation Occurance: #%.0f\n',iter)
            
            if skip1frame == 1
                skip1frame = 0;
            end
            
            %Tester - HSV Values - looking at affect of shadows:
            imgaus2 = imgaus;
        %-------------------------------------------------------------
            
            
            
        %-------------------------------------------------------------
        %This is an error that is raised if occultation is occuring on
        %more than two markers on the same frame.  There is no way of
        %calculating the markers with two unkown markers at this time
        %or if there is occultation, and not enough markers selected to
        %deal with it.
        elseif holder == 1
            error('Two points are experiencing occultation in the same frame')
        else
            error('Occultation is likely occuring.  To deal with this, Hip, Knee, Thigh must be selected markers.  If hip, knee, and thigh are slected, then the system is having trouble picking up one of the other markers.')
        end
        %-------------------------------------------------------------
        
    end
    
    
    
    
    
    %% Storing Found Centroids for later
    %*******************************************************
    %*******************************************************
    
    %This is the case where no occultation occurred during the last frame
    if holder ~= 1  && OccultBool == 0
        markcent(:,:,i) = cent;
        %fprintf('One or more markers: Hip, knee, and thigh, not selected\n') %<---------- DELETE THIS, in place currently for testing
    elseif holder ~=1
        markcent(:,:,i) = cent;
        
        %Stores occultation occurance for analysis of functionality
        %this whole bit is really unnecessary for the final version of this
        if iter > 0
            markerarray(whereisj) = OCToccurance(markerarray(whereisj));
        end
        
        iter = 0; %<--- deals with how many occulation frames have occured
        whereisj = 0;
        
        %add necessary coords to averages
        OccultationData = addData(OccultationData,markerarray(knee).lastmarker,markerarray(hip).lastmarker,markerarray(thigh).lastmarker);
        
    else
       %Calculate position funciton...
       occulmarker = Occultcalc(OccultationData,whereisj,markerarray,vid.Height); %<-- issue
       markerarray(whereisj) = reassign(markerarray(whereisj),occulmarker.xcoord,occulmarker.ycoord); %addmarker(markerarray(whereisj),occulmarker);
       cent(whereisj,:) = [occulmarker.ycoord,occulmarker.xcoord];
       
       markcent(:,:,i) = cent;  %[ycoord, xcoord]
       holder = 0;
       
       %----------------------------------------------------
       %Tester - HSV Values - looking at affect of shadows:
       %----------------------------------------------------
       %For plotting
       xc = markerarray(whereisj).lastxcoord; %column = x pos
       yc = markerarray(whereisj).lastycoord; %row = y pos
       boxcenter2 = [yc,xc];
       boxDist2 = 5;
       %Creating Box
       row1 = boxcenter2(1,1) - boxDist2;
       row2 = boxcenter2(1,1) + boxDist2;
       column1 = boxcenter2(1,2) - boxDist2;
       column2 = boxcenter2(1,2) + boxDist2;
%        if skipcount >= 2
%            %getting image box for values
%            boxc = imgaus2(round(row1):round(row2),round(column1):round(column2),:);
%            %convert to hsv to analyze
%            ochsv = rgb2hsv(boxc);
%            binc = improc.im2hsv(boxc,propagated_point(1) - .15, propagated_point(1) + .15, propagated_point(2) - .15, propagated_point(2) + .15, propagated_point(3) - .15, propagated_point(3) + .15);
%            [boxcent] = improc.getcentroidsmod(binc);
%            ind = find(binc == 1);
%            siz = size(binc);
%            [I,J] = ind2sub(siz,ind);
%            hsvim = rgb2hsv(boxc);
%            
%            avgH = hsvim(I,J,1);
%            avgH = mean(avgH(:));
%            
%            avgS = hsvim(I,J,2);
%            avgS = mean(avgS(:));
%            
%            avgV = hsvim(I,J,3);
%            avgV = mean(avgV(:));
%            
%            hsvthresh(whereisj,:,i) = [avgH avgS avgV];
%        end
       %----------------------------------------------------
                      
    end
    %*******************************************************
    %*******************************************************
    
    %% Shows Video Verification
     hsv = rgb2hsv(im);     % Hide THIS IS FOR TESTING
     imshow(hsv);
    
    [m,n,p] = size(markcent);
    for k=1:m
        hold on
        plot(markcent(k,2,i),markcent(k,1,i),'yo','MarkerSize',10,'LineWidth',1.5)
        
        line([x(k)-boxDist,x(k)-boxDist],[y(k)+boxDist,y(k)-boxDist],'LineWidth',2,'Color','y');
        line([x(k)+boxDist,x(k)+boxDist],[y(k)+boxDist,y(k)-boxDist],'LineWidth',2,'Color','y');
        line([x(k)-boxDist,x(k)+boxDist],[y(k)-boxDist,y(k)-boxDist],'LineWidth',2,'Color','y');
        line([x(k)-boxDist,x(k)+boxDist],[y(k)+boxDist,y(k)+boxDist],'LineWidth',2,'Color','y');

        if iter ~= 0 && k == whereisj 
            line([column1,column2],[row1,row2],'LineWidth',2,'color','y')
            line([column2,column1],[row1,row2],'LineWidth',2,'color','y')
        end
    end
    
    drawnow

%     %Display thinking status when the plotting is commented out
%     if thinking_iter >= 35
%         disp('Thinking...')
%         thinking_iter = 0;
%     else
%         thinking_iter = thinking_iter + 1;
%     end
        
    x = []; %Reset values
    y = []; %Reset values
    
    time = time + toc;
end

avg = time/i

%% 7 - Setting Marker Origin, Adjusting for Frame Cropping, Converting from Pixels to Meters
%Inputs: markcent, colcut, rowcut, nummark, tframe
%Outputs: markerpos

%markcent = [#markers, [y,x], frames of x,y coords]

siz = size(im);                 %size of image
cmat = [1 1; siz(1) siz(2)];    %?????? <-------------- why?
rowcut = cmat(:,1);             %???? [1;siz(1)]? <---- Why?
colcut = cmat(:,2);             %???? [1,siz(2)]? <---- Why?

%Figure out what this adjustment is doing and why its doing it...
%It seems like it does nothing... 
for j=1:nummark
    markcentadj(j,2,:) = markcent(j,2,:) + (colcut(1)-1);
    markcentadj(j,1,:) = markcent(j,1,:) + (rowcut(1)-1);
end


%Setting Marker Origin to left-most reference marker
%ref1 [x,y] of the reference marker position (click 1)
%what if this makes marker positions negative? <------ Think About This
for i=1:tframe
    for j=1:nummark
        markerpos(i,1,j) = markcentadj(j,2,i) - ref1(1); %x
        markerpos(i,2,j) = -markcentadj(j,1,i) + ref1(2); %y
    end
end

%Rotating
%refang == 
for i=1:tframe
    for j=1:nummark
        markerpos(i,:,j) = markerpos(i,:,j)*[cos(-refang), -sin(-refang);
            sin(-refang), cos(-refang)];
    end
end

%Converting from pixels to meters
markerpos = markerpos/pxtom;

%---------------------------------------------------------------------
%Combining the change in reference frame and rotation of frame
%And dealing with pixel-to-meter
for j = 1:length(markerarray)
    markerarray(j).coordinates(:,1) = markerarray(j).coordinates(:,1) - ref1(1);
    markerarray(j).coordinates(:,2) = -markerarray(j).coordinates(:,2) + ref1(2);
    markerarray(j).coordinates(:,:) = (markerarray(j).coordinates(:,:)*[cos(-refang), -sin(-refang);
            sin(-refang), cos(-refang)])/pxtom;
end

%delete first coordinate on markerarrays
%This was determined to be necessary after viewing some data
%The system's centroid seems MUCH MUCH more consistent than the
%user input of the centroid
for i = 1:length(markerarray)
    markerarray(i) = deletefirstcoord(markerarray(i));
end

%---------------------------------------------------------------------

% BELOW IS: Not needed if powercalc is running on markerarray.
% %Removing all thigh marker data, don't want it to be included in
% %rigid link calculations
% if exist('thighindex','var') == 1
%     markerpos(:,:,thighindex) = [];
% end

%close(fig) <---- with running the figure in the app, this is not needed
end


