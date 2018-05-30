function [markerpos1,markerpos2] = replaceNAN(markerpos1,markerpos2)

%% MARKERPOS 1

a = [];
for j = 1:length(markerpos1(1,1,:))
    
    %Finding the NaN values and figuring out the last point before a NaN
    %appeared (so we can interpolate)
    
    i = 1;
    indx = 1; %Index value for stored positions and position indices
    while i <= length(markerpos1(:,1,j))
        
        if isnan(markerpos1(i,1,j)) == 1
            
            lastpos(indx,:) = markerpos1(i-1,:,j); %Last position from before lost data 
            a(indx) = i-1; %Starting index of lost marker position
            
            %After we find the last numerical value before NaN's, find the 
            %first value that appears after NaN values (to interpolate)
            while i <= length(markerpos1(:,1,j))
                
                i = i + 1; %Loop until a non-NaN is found
                if ~isnan(markerpos1(i,1,j))
                    newpos(indx,:) = markerpos1(i,:,j); %First new postion data after lost data
                    b(indx) = i;
                    indx = indx + 1;
                    break
                end
                
            end
            
            
            %After this loop completes we now have info about data loss
            %period
            
        end
        
        i = i + 1;
    end
    
    %Putting values in for NaN's
    if ~isempty(a)
        for i = 1:length(a) %How many intervals we lost markers for
            
            ptslost = b(i) - a(i) - 1; %For the ith period, how many points we need values for
            dist = newpos(i,:) - lastpos(i,:);
            for k = 1:ptslost
                markerpos1(a(i)+k,:,j) = lastpos(i,:) + (k/(ptslost+1))*dist;
            end
            
        end
    end
    lastpos = [];
    newpos = [];
    a = [];
    b = [];
        
end



%% MARKERPOS 2
a = [];
indx = 1; %Index value for stored positions and position indices
for j = 1:length(markerpos2(1,1,:))
    
    %Finding the NaN values and figuring out the last point before a NaN
    %appeared (so we can interpolate)
    
    i = 1;
    indx = 1;
    while i <= length(markerpos2(:,1,j))
        
        if isnan(markerpos2(i,1,j)) == 1
            
            lastpos(indx,:) = markerpos2(i-1,:,j); %Last position from before lost data 
            a(indx) = i-1; %Starting index of lost marker position
            
            %After we find the last numerical value before NaN's, find the 
            %first value that appears after NaN values (to interpolate)
            while i <= length(markerpos2(:,1,j))
                
                i = i + 1; %Loop until a non-NaN is found
                if ~isnan(markerpos2(i,1,j))
                    newpos(indx,:) = markerpos2(i,:,j); %First new postion data after lost data
                    b(indx) = i;
                    indx = indx + 1;
                    break
                end
                
            end
            
            
            %After this loop completes we now have info about data loss
            %period
            
        end
        
        i = i + 1;
    end
    
    %Now that we have the indices of the intervals, we can put values in for NaN's
    if ~isempty(a)
        for i = 1:length(a) %How many periods we lost markers for
            
            ptslost = b(i) - a(i) - 1; %For the ith period, how many points we need values for
            dist = newpos(i,:) - lastpos(i,:);
            for k = 1:ptslost
                markerpos2(a(i)+k,:,j) = lastpos(i,:) + (k/(ptslost+1))*dist;
            end
            
        end
    end
    lastpos = [];
    newpos = [];
    a = [];
    b = [];
        
end


end