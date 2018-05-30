classdef OccultationCalc
    
    properties
        %Boolean Properties for initializing occultatation calculations
        OccultBoolNoWrist
        OccultBoolWithWrist
        NoOccultFunctionality
        
        %Organizing indexing
        IndexArray
        
        %Actual occulation calculation properties
        DistKneeToHip
        rkhave
        DistKneeToThigh
        rktave
        DistThighToHip
        rthave
        AngleAtHip
        aahave
        AngleAtKnee
        aakave
        AngleAtThigh
        aatave
        DistHipToWrist
        
        
    end
    
    methods
        
        %Primary Occultation Function - This initializes the boolean
        %values that will be used to determine if / what kind of occulation
        %calculations will occur.
        function obj = OccultationCalc(initializer)
            if initializer == 3
                obj.OccultBoolNoWrist = 1;
                obj.OccultBoolWithWrist = 0;
                obj.NoOccultFunctionality = 0;
                
            elseif initializer == 4
                obj.OccultBoolWithWrist = 1;
                obj.OccultBoolNoWrist = 0;
                obj.NoOccultFunctionality = 0;
                
            else
                obj.NoOccultFunctionality = 1;
                obj.OccultBoolWithWrist = 0;
                obj.OccultBoolNoWrist = 0;
            end
            
            obj.IndexArray = 0;
        end
        
        
        %This method intitialized the HipKneeThighCalc
        %This is primarily for storing averages (e.g. distances) between
        %three markers.  It can be easily updated to include 4 marker
        %information.  Currently it is a bit messy, and i may wish to
        %just implement this stuff in the class marker (unlikely)
        function obj = KneeHipThighCalc(obj,knee,hip,thigh,wrist)
            %test to see what types of inputs exist
            %if we have knee,hip,thigh,wrist set wrist to hip intial dist.
            if nargin == 5
                obj.DistHipToWrist = double(marker.MarkerDist(hip,wrist));
            else
                obj.DistHipToWrist = 0;
            end
            
            %Now deal with calculating initial geometry
            if nargin >= 4
                if marker.ismarker(knee) && marker.ismarker(hip) && marker.ismarker(thigh)
                    %distance vectors (xyz frame)
                    obj.DistKneeToHip = double(marker.MarkerDist(knee,hip));
                    obj.rkhave = obj.DistKneeToHip;
                    obj.DistKneeToThigh = double(marker.MarkerDist(knee,thigh));
                    obj.rktave = obj.DistKneeToThigh;
                    obj.DistThighToHip = double(marker.MarkerDist(hip,thigh));
                    obj.rthave = obj.DistThighToHip;
                    
                    %Angles
                    [obj.AngleAtHip,obj.AngleAtKnee,obj.AngleAtThigh] = marker.MarkerAngles(knee,hip,thigh);
                    obj.aahave = obj.AngleAtHip;
                    obj.aakave = obj.AngleAtKnee;
                    obj.aatave = obj.AngleAtThigh;
                end
            else
                %raise error for not three marker inputs
                error('input object, and 3 or 4 markers, the forth marker would be the wrist marker with the knee, hip, thigh as the first three in that order')
            end
        end
        
        %sets the index array for the wrist,hip,thigh,knee in that order
        %will be set to something other than zero only if there exists
        %hip, thigh, knee, or hip,thigh,knee,and wrist
        function obj = SetIndexArray(obj,indexarray)
            obj.IndexArray = indexarray;
        end
        
        
        %this function generates that averges, for the vectors connecting
        %the points in their respective frames.  It also generates
        %the average values for the internal angles.
        %it stores those values.  Change averages by modifying the
        %variables: "numavgVEC" and "numavgANGLE"
        %That is, it appends the knee,hip,thigh data.  Again this is
        %messy and probably wont be necessary if i decide to implement
        %everything in marker class
        function obj = addData(obj,knee,hip,thigh)
            len = length(obj.DistKneeToHip);
            numavgVEC = 5;
            numavgANGLE = 3;
            obj.DistKneeToHip(len+1,1) = double(marker.MarkerDist(knee,hip));
            obj.DistKneeToThigh(len+1,1) = double(marker.MarkerDist(knee,thigh));
            obj.DistThighToHip(len+1,1) = double(marker.MarkerDist(hip,thigh));
            
            [obj.AngleAtHip(len+1,1),obj.AngleAtKnee(len+1,1),obj.AngleAtThigh(len+1,1)] = marker.MarkerAngles(knee,hip,thigh);
            
            if len < numavgVEC-1 %<-- Set up for 5 points of averaging right now
                %average the distances of the vectors (xyz frames)
                obj.rkhave = mean(obj.DistKneeToHip(:,1));
                obj.rktave = mean(obj.DistKneeToThigh(:,1));
                obj.rthave = mean(obj.DistThighToHip(:,1));
                
                %average angles *** currently using last angle no avrg ***
                obj.aakave = obj.AngleAtKnee(len+1,1);
                obj.aahave = obj.AngleAtHip(len+1,1);
                obj.aatave = obj.AngleAtThigh(len+1,1);
            else
                %Average distances of vectors (last 5 points)
                obj.rkhave = mean(obj.DistKneeToHip(end-(numavgVEC-1):end,1));
                obj.rktave = mean(obj.DistKneeToThigh(end-(numavgVEC-1):end,1));
                obj.rthave = mean(obj.DistThighToHip(end-(numavgVEC-1):end,1));
                
                %average angles *** currently using last angle no avrg ***
                obj.aakave = obj.AngleAtKnee(end-(numavgANGLE-1),1);
                obj.aahave = obj.AngleAtHip(end-(numavgANGLE-1),1);
                obj.aatave = obj.AngleAtThigh(end-(numavgANGLE-1),1);
                
            end
        end
        
        %reassigns the DistHipToWrist value
        function obj = JustHipToWrist(obj,dist)
            obj.DistHipToWrist = dist;
        end
        
        
        
        %==============================================================
        %OCCULTATION CALCULATIONS:
        %==============================================================
        function [outputmarker] = Occultcalc(occdata,whereisj,markerarray,vidheight)
            %So, Needed information:
            % - magnitudes of each xy vector
            % - internal angles of triangle
            % - past knee, hip, thigh data
            % - Averages Angles and Magnitudes
            % - Initial Geometry - Calculate signs for rot angle equation
            % - descision on which one to look at
            % - Calculation of necessary rotation angle
            % - Final mean of two rotation angle calculations
            h = vidheight;
            %identify the locations within mymark where knee, thigh, and hip are
            j = whereisj;
            for i = 1:length(markerarray)
                if markerarray(i).jointnum == 6
                    knee = i;
                elseif markerarray(i).jointnum == 5
                    thigh = i;
                elseif markerarray(i).jointnum == 4
                    hip = i;
                end
            end
            
            %make it easier to type this stuff in.
            %Can use a find function later if necessary and replace the simplified
            %pieces.
            rkh = occdata.rkhave;
            rkt = occdata.rktave;
            rht = occdata.rthave;
            aah= occdata.aahave;
            aak = occdata.aakave;
            aat = occdata.aatave;
            
            %gets last coordinate information (flips reference frame)
            %re-flips later for output (easier to do vector thinking with
            %the frame origin at lower left corner)
            hx = markerarray(hip).lastxcoord;
            hy = h - markerarray(hip).lastycoord;
            tx = markerarray(thigh).lastxcoord;
            ty = h - markerarray(thigh).lastycoord;
            kx = markerarray(knee).lastxcoord;
            ky = h - markerarray(knee).lastycoord;
            
            
            %NOTE TO SELF, NEED TO SET UP A WAY TO IDENTIFY THE INITIAL GEOMETRY TO
            %DECIDE WHICH ROTATION ANGLE TO USE - DO THIS!
            %---------------------------- KNEE ----------------------------
            if markerarray(j).jointnum == 6
                %run knee calc....
                theta = acos( (tx-hx) / rht); %<--- NEED DESCISION HERE!!!!
                
                %Hip to Knee
                rhij = [hx;hy];
                rotangle1 = pi/2 - theta + aah;
                ROTmat1 = [cos(rotangle1), -sin(rotangle1); sin(rotangle1), cos(rotangle1)];
                rkij1 = (rhij - ROTmat1 * (rkh*[0;1])).' ;
                
                %Thigh to knee
                rtij = [tx;ty];
                rotangle2 = -pi/2 -(theta) - aat;
                ROTmat2 = [cos(rotangle2), -sin(rotangle2); sin(rotangle2), cos(rotangle2)];
                rkij2 = (rtij - ROTmat2 * (rkt*[0;1])).' ;
                
                %Average the results, store as marker for output
                x = [rkij1(1);rkij2(1)];
                y = [rkij1(2);rkij2(2)];
                x = mean(x);
                y = mean(y);
                y = h - y;
                outputmarker = marker(x, y);
                
                %---------------------------- THIGH ----------------------------
            elseif markerarray(j).jointnum == 5
                %run thigh calc...
                theta = acos( (kx - hx) / rkh ); %<--- figure this out
                
                %Knee to Thigh
                rkij = [kx;ky];
                rotangle1 = -theta  - pi/2 + aak;
                ROTmat1 = [cos(rotangle1), -sin(rotangle1); sin(rotangle1), cos(rotangle1)];
                rtij1 = (rkij - ROTmat1 * (rkt*[0;1])).' ;
                
                %hip to thigh
                rhij = [hx;hy];
                rotangle2 = pi/2 -(theta) -aah;
                ROTmat2 = [cos(rotangle2), -sin(rotangle2); sin(rotangle2), cos(rotangle2)];
                rtij2 = (rhij - ROTmat2 * (rht*[0;1])).' ;
                
                %average the results, store as amarker for output
                x = [rtij1(1);rtij2(1)];
                y = [rtij1(2);rtij2(2)];
                x = mean(x);
                y = mean(y);
                y = h - y;
                outputmarker = marker(x, y);
                
                %---------------------------- Hip -----------------------------
            elseif markerarray(j).jointnum == 4
                %run hip calc...
                theta = acos( (kx -tx) / rkt );
                
                %Knee to hip
                rkij = [kx;ky];
                rotangle1 = -(theta) -pi/2 - aak;
                ROTmat1 = [cos(rotangle1), -sin(rotangle1); sin(rotangle1), cos(rotangle1)];
                rhij1 = (rkij - ROTmat1 * (rkh*[0;1])).' ;
                
                %Thigh to hip
                rtij = [tx;ty];
                rotangle2 =  pi -(theta) + aat;
                ROTmat2 = [cos(rotangle2), -sin(rotangle2); sin(rotangle2), cos(rotangle2)];
                rhij2 = (rtij - ROTmat2 * (rht*[1;0])).' ;
                
                %average the results, store as amarker for output
                x = [rhij1(1);rhij2(1)];
                y = [rhij1(2);rhij2(2)];
                x = mean(x);
                y = mean(y);
                y = h - y;
                outputmarker = marker(x, y);
                
                
            else
                error('Something when wrong with occultation calculation')    
            end
            
        end
        %==============================================================
        
        
    end
end