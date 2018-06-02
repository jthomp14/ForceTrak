classdef Segments
    %Explain what this does <------------------------- DO THIS!
    %NOTE: Nomenclature:
    %    - ROG = Radius of Gyration
    %    - CM = Center of mass
    %        - rCM = Position of CM
    %        - vCM = Velocity of CM
    %        - aCM = Acceleration of CM
    %    - I = Moment of intertia
    %        - Icm = moment of interia aoubt CM
    %        - Id  = moment of intertia about distal end
    %        - Ip  = moment of intertia about proximal end
    %    - theta = the rotation of segment relative to a fixed end
    %        - thetad = distal end fixed
    %        - thetap = proximal end fixed
    %    - omega = angular velocity
    %    - alpha = angular acceleration
    
    properties
        name
        mass
        rCM
        vCM
        aCM
        omegad
        omegap
        alphad
        alphap
        thetad
        thetap
        Icm
        Id
        Ip
        length
        massfrac
        distalcoords
        proximalcoords
        JointNum
        
    end%end properties
    
    
    
    methods
        
        %GIVE DETAILED EXPLANATION ON THIS!
        function obj = Segments(tstep, BodyWeight, massfrac, coordsdistal, distalCM, coordsproximal, distalROG, proximalROG, CofGROG)
            if nargin == 0
                %Do nothing
                
            else %assign properties
                obj.mass = BodyWeight*massfrac;
                obj.massfrac = massfrac;
                
                
                %Conduct analyis for SINGLE JOINT (not a segment) 
                %   - This is for the case of the shoulder for example
                if nargin == 5
                    %Assign Coordinates (distal is taken as default for
                    %segments that do not have multiple points
                    %i.e. shoulder
                    obj.mass = 0;
                    obj.distalcoords = coordsdistal;
                    obj.Icm = 0;
                    obj.Id = 0;
                    obj.Ip = 0;
                    
                    
                    %Calcuilate length, CM, I, proximal coord
                    [a,~] = size(coordsdistal);
                    for i = 1:a
                        obj.length(i) = nan;
                        obj.rCM(i,:) = coordsdistal(i,:);
                        obj.proximalcoords(i,:) = [0,0];
                    end
                    
                    %SEGMENT WITH TWO MARKERS
                elseif nargin == 9
                    %Assign Coordinates
                    obj.distalcoords = coordsdistal;
                    obj.proximalcoords = coordsproximal;
                    
                    %Calculate length, CM, I
                    [a,~] = size(coordsdistal);
                    for i = 1:a
                        
                        %calculate length
                        obj.length(i) = sqrt( (coordsproximal(i,1)-coordsdistal(i,1))^2 + (coordsproximal(i,2) - coordsdistal(i,2))^2 );
                        
                        %Calculate x-coordinate of center of mass - each frame
                        obj.rCM(i,1) = coordsdistal(i,1) - distalCM*(coordsdistal(i,1) - coordsproximal(i,1));
                        
                        %Calculate y-coordinate of center of mass - each frame
                        obj.rCM(i,2) = coordsdistal(i,2) - distalCM*(coordsdistal(i,2) - coordsproximal(i,2));
                        
                        %Calculate I (consider point of rotation for each
                        %segment to be the distal joint (i.e. hip for the
                        %thigh not the knee, etc...)
                        %I = Icm + mx^2
                        %   - x = dist between cm and cent of rotation (distal)
                        %   - m = mass of segment
                        %   - Icm = moment of intertia about CM
                        %       - Icm = m*ROG^2
                        %NOTE:
                        %   - Chose to calculate these with table instead of
                        %     parallel axis theorem
                        obj.Icm(i) = obj.mass*(obj.length(i)*CofGROG)^2;
                        obj.Id(i) = obj.mass*(obj.length(i)*distalROG)^2;
                        obj.Ip(i) = obj.mass*(obj.length(i)*proximalROG)^2;
                        
                        %Caclulate the angle of rotation (theta)
                        %Chosing this method for now vs. Vx = omega*Rx
                        %Can revisit this and see which one makes more sense
                        thetad(i,1) = atan2((coordsproximal(i,2) - coordsdistal(i,2)),(coordsproximal(i,1) - coordsdistal(i,1)));
                        thetap(i,1) = atan2((coordsdistal(i,2) - coordsproximal(i,2)),(coordsdistal(i,1) - coordsproximal(i,1)));
                        
                        
                        %------------------------------------------------------
                        %CONSIDER THE CASE FOR 3 MARKER SEGMENT(I.E. WHOLE LEG)
                        %   - Perhaps talk to Dr. T first for some insight
                        %     on this...
                        %This consideration is probably not necessary,
                        %I can only think of a few cases when someone may
                        %want that, and it can be integrated in later if need.
                        %------------------------------------------------------
                        
                        
                        
                    end
                    %function[cdat,d_cdat,dd_cdat] = WindowSpline(tbar,xbar,polyorder)  
                    %Using the above function to smooth out the data with a
                    %polyorder that can be changed (3 seems nice)
                    %Consider Angular Velocity and Acceleration:
                    %   - Distal:       omegad, alphad
                    %   - Proximal:     omegap, alphap
                    polyorder = 4;
                    t = (0:tstep:(a-1)*tstep)'; 
                    
                    %X and Y Coordinates of smoothed position with Velocity
                    %and Acceleration
                    [obj.rCM(:,1), obj.vCM(:,1), obj.aCM(:,1)] = WindowSpline(t, obj.rCM(:,1), polyorder);
                    [obj.rCM(:,2), obj.vCM(:,2), obj.aCM(:,2)] = WindowSpline(t, obj.rCM(:,2), polyorder);
                    
                    %Angular information
                    [obj.thetad, obj.omegad, obj.alphad] = WindowSpline(t,thetad,polyorder);
                    [obj.thetad, obj.omegad, obj.alphad] = WindowSpline(t,thetad,polyorder);
                    
                                  
%                     %USING THE CENTRAL FINITE DIFFERENT METHOD:
%                     obj.thetad = thetad;
%                     obj.thetap = thetap;
%                     omegad = zeros(a,2);
%                     omegap = zeros(a,2);
%                     alphap = zeros(a,2);
%                     alphad = zeros(a,2);
%                     %Central Finite Difference:
%                     for framenum = 2:a-1
%                         alphad(framenum,:) = (thetad(framenum+1) - 2*thetad(framenum) + thetad(framenum-1))/tstep^2;
%                         alphap(framenum,:) = (thetad(framenum+1) - 2*thetad(framenum) + thetad(framenum-1))/tstep^2;
%                         omegad(framenum,:) = (thetad(framenum+1) - thetad(framenum-1))/(2*tstep);
%                         omegap(framenum,:) = (thetap(framenum+1) - thetap(framenum-1))/(2*tstep);
%                     end
%                     %Assign class properties
%                     obj.omegad = omegad;
%                     obj.omegap = omegap;
%                     obj.alphap = alphap;
%                     obj.alphad = alphad;
                    
                end
                
                %Consider Velocity and Acceleration of CM: vCM and aCM
                vCM = zeros(a,2);
                aCM = zeros(a,2);
                %Central finite difference:
                for framenum = 2:a-1
                    aCM(framenum,:) = (obj.rCM(framenum+1,:) - 2*obj.rCM(framenum,:) + obj.rCM(framenum-1,:))/tstep^2;
                    vCM(framenum,:) = (obj.rCM(framenum+1,:) - obj.rCM(framenum-1,:))/(2*tstep);
                end
                %Assign class properties
                obj.aCM = aCM;
                obj.vCM = vCM;
                
                
                
                %---------------------------------------------------------
                %From here we need to decide what to do with Calculating
                %   power/energy/moments/forces on segments and joints...
                %Also, need to figure out the angular velocity and
                %   angular acceleration <--- if this is working or should
                %   Be revamped
                %finally, Need to figure out what to do about noise
                %   getting some really ugly results from the
                %   differentiation
                %---------------------------------------------------------
            end
            
        end
    end
end


