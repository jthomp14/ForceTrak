%TESTING - developing a solution to occultation.
%START with triangulation of three points:

%% Initialize three points representing hip, thigh, and knee
%in a cartesian coordinate system setup (imagine the video as the
%coordinate system)

classdef marker
    
    properties
        coordinates             %Returns double class 1x2 vector
        xcoord                  %Returns class double
        ycoord                  %Returns class double
        markername              %Returns string - class char
        markerselected          %Returns logical 0,1 - class double
        jointnum                %Returns number - class double
        jointindex              %Returns joint index in joints chosen
        numofoccultations       %Stores the number of times occultations occured
        storedoccultframes      %Stores frames that are occulting as array
        velxy
        accelxy
        
        %Returns double class 1x2 vector initally
        lastmarker              %After adding marker changes to class marker        
        secondlastmarker        %Returns class marker
        lastxcoord              %Returns double
        lastycoord              %Returns double
        secondlastxcoord        %Double
        secondlastycoord        %Double
                    
    end
    
    
    
    %*******************************************************
    methods
        
        %This method intializes the properties of a marker.
        %Example call to create an object of the class marker is:
        %object = marker(xnum,ynum);
        %NOTE when calling coordinates (if one wants both x,y)
        %you must type: marker.coordinates(i,:) where i = the ith row
        %this only applies if indexing the coordinates to get them in
        %the matlab array/matrix form.
        function obj = marker(x,y)
            if nargin == 2
                if isnumeric(x) && isnumeric(y)
                    obj.xcoord = double(x);
                    obj.ycoord = double(y);
                    obj.coordinates = double([x,y]);
                    obj.lastmarker = double([x,y]);
                    obj.lastxcoord = double(x);
                    obj.lastycoord = double(y);
                    obj.markername = 'none';
                    obj.markerselected = 0;
                    obj.jointnum = 0;
                    %obj.secondlastmarker = marker(0,0);
                    obj.storedoccultframes = zeros(1,30);
                    obj.numofoccultations = 0;
                else
                    error('Values for x,y must be numeric')
                end
            end
        end
    
        
        %sets the index REMEMBER WHAT THIS IS!!!!!!!<------------------
        function self = SetIndex(self,indexnum)
            self.jointindex = indexnum;
        end
        
        %sets the property for the associated marker (or joint) name
        %This is more for me just knowing what is what when analyzing
        %the functionality of the thing, it could be integrated
        %with ForceTrak to simplify dealing with which marker is what
        function self = SetMarkerName(self,namestr)
            if ischar(namestr)
                self.markername = namestr;
            else
                error('The name must be a string input')
            end
        end
        
        
        %This function uses the code in ForceTrak already (in ForceTrak
        %the check boxes get a 1 or 0 if selected or not), this sets
        %a value (1 or 0) to the marker to determine if it has been
        %intialized, again purely a possible avenue for integration
        %of class marker into Forcetrak totally
        function self = valueselected(self,value)
            self.markerselected = value;
        end
        
        
        %similar to above (valueselected method) this works with
        %ForceTrak to associate a numerical value to the joint/marker
        %in ForceTrak he uses numerical references... something i'd
        %like to get away from if implementing this class throughout
        %the ForceTrak Software
        function self = pickjointnum(self,value)
            self.jointnum = value;
        end
        
        
        %This function allows for reassignment of the coordinates
        %it is primarily devised to deal with intializing a marker
        %at the coordinates (0,0), and then reassinging that intial
        %coordinate with the input from the user in ForceTrak when
        %they intially seclect the marker position on the first frame
        function self = reassign(self,x,y)
            self.lastmarker = marker(x,y);
            self.coordinates(end,:) = [x,y];
            self.xcoord(end) = x;
            self.ycoord(end) = y;
            self.lastxcoord = x;
            self.lastycoord = y;
            
        end
        
        
        %This appends / adds coordinates (creating a [xrow,2col]
        %double array in Matlab).  The idea is to continue storing
        %the (x,y) position data as ForceTrak iterates and gets
        %the coordinates of markers frame by frame
        %NOTE: when a coordinate is added, the last coordinate
        %information and marker(stored as a marker) is saved as well
        %consider making this a static function
        function self = addcoord(self,x,y)
            %adds a second to last marker if there are more than 1 set
            %of coordinates already in the marker
            if length(self.xcoord) == 1
                self.secondlastmarker = marker(self.lastxcoord,self.lastycoord);
            else
                self.secondlastmarker = self.lastmarker;
            end
            
            self.secondlastxcoord = self.lastxcoord;
            self.secondlastycoord = self.lastycoord;
            
            %Sets up lastmarker, and adds new coordinate information
            self.coordinates = [self.coordinates; x,y];
            self.xcoord = [self.xcoord;x];
            self.ycoord = [self.ycoord;y];
            self.lastmarker = marker(x,y);
            self.lastxcoord = double(x);
            self.lastycoord = double(y);
   
        end
        
        
        %little easier to just add a marker (see directy above)
        function self = addmarker(self,marker)
            self = addcoord(self,marker.xcoord,marker.ycoord);
        end
        
        
        %This deletes the first coordinate - not sure why i put this
        %in, but perhaps it can be be useful later on
        %infact <--- i found a use for it afterall!
        function self = deletefirstcoord(self)
            self.coordinates(1,:) = [];
            self.xcoord(1) = [];
            self.ycoord(1) = [];
        end
        
        %this function indexs into the marker to pull out
        %a marker position.  i.e., if there are 40 stored
        %coordinates inside the marker, this returns a marker
        %that is in position 32 if you call: object = indexer(marker,32)
        function  obj = indexer(self,indexnum)
            x = self.xcoord(indexnum);
            y = self.ycoord(indexnum);
            obj = marker(x,y);
            obj.markername = self.markername;
            obj.markerselected = self.markerselected;
            obj.jointnum = self.jointnum;
        end
       
        %This function iterates the number of times occultation has
        %occurred.  it creates the body of occultation frame matrix
        %note that matrix is an nx30 matrix of zeros until frames are
        %plugged into it.
        function self = OCToccurance(self)
            self.numofoccultations = self.numofoccultations + 1;
            self.storedoccultframes(end+1,:) = zeros(1,30);
        end
        
        %This function stores the frames that are occulting
        %it feeds in the frame and stores it in the marker data
        function self = storeoccultframes(self, framenum, iter)
            if self.numofoccultations == 0
                self.numofoccultations = 1;
                self.storedoccultframes(1,:) = zeros(1,30);
            end
            %stores the frame in nx30 matrix where unused columns are
            %left as zeros (thirty is arbitrary, and can be changed)
            %but i need some way of keeping the dimensions consistent.
            %each rows coorelates with an occultation occurance, and
            %each column stores the frame for which occultation occured
            %idea <-- to use for smoothing out final results using
            %regression or some other data smoothing tool
            self.storedoccultframes(self.numofoccultations,iter) = framenum;
        end
        
        %This method defines addition for indiviual markers
        %It needs further work to deal with multiple coordinates
        %currently it assumes there exists only one set of 
        %(x,y) coordinates stored in the marker
        function r = plus(marker1,marker2)
            x1 = marker1.xcoord;
            x2 = marker2.xcoord;
            y1 = marker1.ycoord;
            y2 = marker2.ycoord;
            r = marker(x1+x2,y1+y2);
            
        end

        %This adds velocity and acceleration coordinates
        %May not be used, but the windowing spline function
        %was written to return 1st and 2nd order derivatives
        %so that data is being stored in the marker properties
        %as of May19th, 2018 (may change, and may foreget to 
        %update this comment)
        function self = VelAccel(self,vxy,axy)
            self.velxy = vxy;
            self.accelxy = axy;
        end
       
%         %Function that deals with estimating point location during
%         %occultation (currently tested with hip and knee occulation)
%         %It yeilds two solutions currently, futher work needs to be done
%         %to deal with slecetion of the correct solution
%         %NOTE: MUST deal with imaginary solution possibility
%         %Think on where this is coming from....
%         function [coord1,coord2] = estimateposition(a2, c2, distAB, distCB)
%             ax2 = a2.xcoord;
%             ay2 = a2.ycoord;
%             cx2 = c2.xcoord;
%             cy2 = c2.ycoord;
%             rab = distAB;
%             rcb = distCB;
%             syms bx2 by2
%             rab2 = sqrt((bx2 - ax2)^2 + (by2 - ay2)^2);
%             rcb2 = sqrt((bx2 - cx2)^2 + (by2 - cy2)^2);
%             [bx2, by2] = solve( rab == rab2, rcb == rcb2,bx2,by2);
%             bx2 = double(bx2);
%             by2 = double(by2);
%             
%             %test1 = HipKneeThighCalc(marker(bx2(1),by2(1)),a2,c2);
%             %test2 = HipKneeThighCalc(marker(bx2(2),by2(2)),a2,c2);
%             
%             %Below is the algebraic calculation, for implementation
%             %The below code is likely much more efficient that the
%             %above code.  The above code can be manipulated such
%             %that it yeilds the algebraic solution below
% %             bx2 = [ (a2.xcoord^2*a2.ycoord + a2.ycoord*c2.xcoord^2 + a2.xcoord^2*c2.ycoord - a2.ycoord*c2.ycoord^2 - a2.ycoord^2*c2.ycoord + c2.xcoord^2*c2.ycoord - a2.ycoord*distAB^2 + a2.ycoord*distCB^2 + c2.ycoord*distAB^2 - c2.ycoord*distCB^2 + a2.ycoord^3 + c2.ycoord^3 + a2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - c2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - 2*a2.xcoord*a2.ycoord*c2.xcoord - 2*a2.xcoord*c2.xcoord*c2.ycoord)/(2*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2));
% %                 (a2.xcoord^2*a2.ycoord + a2.ycoord*c2.xcoord^2 + a2.xcoord^2*c2.ycoord - a2.ycoord*c2.ycoord^2 - a2.ycoord^2*c2.ycoord + c2.xcoord^2*c2.ycoord - a2.ycoord*distAB^2 + a2.ycoord*distCB^2 + c2.ycoord*distAB^2 - c2.ycoord*distCB^2 + a2.ycoord^3 + c2.ycoord^3 - a2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) + c2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - 2*a2.xcoord*a2.ycoord*c2.xcoord - 2*a2.xcoord*c2.xcoord*c2.ycoord)/(2*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2))];
% %
% %             by2 = [ (a2.xcoord^2 + a2.ycoord^2 - c2.xcoord^2 - c2.ycoord^2 - distAB^2 + distCB^2)/(2*(a2.xcoord - c2.xcoord)) - ((a2.ycoord - c2.ycoord)*(a2.xcoord^2*a2.ycoord + a2.ycoord*c2.xcoord^2 + a2.xcoord^2*c2.ycoord - a2.ycoord*c2.ycoord^2 - a2.ycoord^2*c2.ycoord + c2.xcoord^2*c2.ycoord - a2.ycoord*distAB^2 + a2.ycoord*distCB^2 + c2.ycoord*distAB^2 - c2.ycoord*distCB^2 + a2.ycoord^3 + c2.ycoord^3 + a2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - c2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - 2*a2.xcoord*a2.ycoord*c2.xcoord - 2*a2.xcoord*c2.xcoord*c2.ycoord))/(2*(a2.xcoord - c2.xcoord)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2));
% %                 (a2.xcoord^2 + a2.ycoord^2 - c2.xcoord^2 - c2.ycoord^2 - distAB^2 + distCB^2)/(2*(a2.xcoord - c2.xcoord)) - ((a2.ycoord - c2.ycoord)*(a2.xcoord^2*a2.ycoord + a2.ycoord*c2.xcoord^2 + a2.xcoord^2*c2.ycoord - a2.ycoord*c2.ycoord^2 - a2.ycoord^2*c2.ycoord + c2.xcoord^2*c2.ycoord - a2.ycoord*distAB^2 + a2.ycoord*distCB^2 + c2.ycoord*distAB^2 - c2.ycoord*distCB^2 + a2.ycoord^3 + c2.ycoord^3 - a2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) + c2.xcoord*((- a2.xcoord^2 + 2*a2.xcoord*c2.xcoord - a2.ycoord^2 + 2*a2.ycoord*c2.ycoord - c2.xcoord^2 - c2.ycoord^2 + distAB^2 + 2*distAB*distCB + distCB^2)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2 - distAB^2 + 2*distAB*distCB - distCB^2))^(1/2) - 2*a2.xcoord*a2.ycoord*c2.xcoord - 2*a2.xcoord*c2.xcoord*c2.ycoord))/(2*(a2.xcoord - c2.xcoord)*(a2.xcoord^2 - 2*a2.xcoord*c2.xcoord + a2.ycoord^2 - 2*a2.ycoord*c2.ycoord + c2.xcoord^2 + c2.ycoord^2))];
%             coord1 = marker(bx2(1),by2(1));
%             coord2 = marker(bx2(2),by2(2));
%         end
%         
%         %2nd attempt at estimating position
%         function [marker] = estimateposition2(markerA, markerB,hipkneethigh)
%             %i know the location of markerA, markerB, and the initial
%             %distances AB, AC, BC where C is the marker i'm trying
%             %to calculate.  If i take the change in position of lastmarker
%             %and secondlastmarker into consideration can i smooth out
%             %the data from the original estimateposition??
%             %consider only the knee:
%             %suppose we fix the hip on secondlast marker
%             %I can generate a rectanglish shape between all four points
%             %Knowing the distance between hip1 and hip2, as the distance
%             %gets smaller and smaller this indicates pure rotation
%             %thus, the thigh1 to thigh2 experiences only rotational
%             %movement.  This extends to then that the knee will viturally
%             %only experience rotational movement, at the same change in
%             %angle as the thigh.  As the distance from hip1 to hip1
%             %grows this indicates both rotation and displacement
%             %thus, perhaps i find a coorelation betwen the distance
%             %from hip1 to hip2 and build a tight frame where the solution
%             %to estimateposition should be, thus resolving the need
%             %for a 4th reference point
%             
%             
%         end
            
    end
    %*******************************************************
    
    
    
    
    
    
    

    
    %*******************************************************
    methods (Static)
        
        %This generates the distance between two markers
        %it will only work for either a marker that has 1 coordinate
        %pair stored, or it will work if the "lastmarker" method is
        %used as the input into this funtion
        function r = MarkerDist(marker1,marker2)
            r = double(sqrt( (marker1.xcoord - marker2.xcoord)^2 + (marker1.ycoord - marker2.ycoord)^2));
        end
        
        
        %This is not being used currently, but in the event
        %the angles are needed in the future it calculates them between
        %three markers
        function [alpha,beta,gamma] = MarkerAngles(marker1,marker2,marker3)
            %coordA = knee
            %coordB = hip
            %coordC = thigh
            a = marker.MarkerDist(marker1,marker3);
            b = marker.MarkerDist(marker2,marker3);
            c = marker.MarkerDist(marker1,marker2);
            %alpha = angle between BC & AB
            %beta = angle between AC & AB
            %gamma = angle between AC * BC
            
            %law cosines
            %a^2 = b^2 + c^2 - 2bccos(alpha)
            alpha = acos( (a^2 - (b^2 + c^2)) / (-2*b*c) );
            beta = acos( (b^2 - (a^2 + c^2)) / (-2*a*c) );
            gamma = pi - alpha - beta;
        end
        
        %This works like python's "isnum(x)" function, and returns
        %The logical 1 if what is fed in is a marker and the logical
        %0 if what is fed in is not a marker.  Just something nice to have
        function logicReturn = ismarker(marker)
            logicReturn = 1;
            try
                marker.xcoord;
            catch
                logicReturn = 0;
            end
        end
        
        %Thinking about the rotation angle between (for now) just the
        %Hip and thigh:
        function [theta] = rotangl(marker1,marker2)
            theta1 = atan( (marker2.secondlastxcoord - marker1.secondlastxcoord)/(marker2.secondlastycoord -marker1.secondlastycoord));
            theta2 = atan( (marker2.lastxcoord - marker1.lastxcoord)/(marker2.lastycoord -marker1.lastycoord));
            theta = theta2 - theta1;
        end

        
        
    end % end methods (Static)
end %end classdef