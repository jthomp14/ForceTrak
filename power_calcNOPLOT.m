function [t,GRFx,GRFy,Power_ext,EnergyInt] = power_calcNOPLOT(markerarray1,markerarray2,Weight,Height,fps)


%************************************************************
%KINETICS ASSUMPTIONS:
%   - CM is fixed - considered point mass
%   - Locations of CM in segment remains fixed during movement
%   - Joints considered ball-and-socket / hinge joints
%   - I (about CM, Proximal or distal joints) constant during movement
%   - Length of segment roughly constant <--- MAY NEED TO CREATE AVERAGE
%           LENGTH VALUE TO DEAL WITH NOISE
%************************************************************


%---------------------------------------------------------
%------------ Headers on AnthroData (Columns) ------------
%---------------------------------------------------------
%(n,1) == Segement Weight / Total Body weight
%(n,2) == Center of Mass / Segment Length - Proximal
%(n,3) == Center of Mass / Segment Length - Distal
%(n,4) == Radius of Gyration / Segment Length - C of G
%(n,5) == Radius of Gyration / Segment Length - Proximal
%(n,6) == Radius of Gyration / Segment Length - Distal
%(n,7) == Density

%---------------------------------------------------------
%-------------- Segment on AnthroData (rows) -------------
%---------------------------------------------------------
%(1,n) == hand: Wrist axis / Knucle II middle finger 
%(2,n) == Forearm: Elbow axis/ulnar styloid
%(3,n) == Upper arm: Glenohumeral axis/elbow axis
%(4,n) == Forearm and hand: Elbow axis/ulnar styloid
%(5,n) == Total arm: Glenohumeral joint/ulnar styloid
%(6,n) == Foot: Lateral malleoulus  / head metatarsal II
%(7,n) == Leg: Femoral condyles / medial malleoulus
%(8,n) == Thigh: Greater trochanter / femoral condyles
%(9,n) == Foot and leg: Femoral condyles / medial malleoulus
%(10,n) = Total leg: Greater trochanter / medial malleolus
%(11,n) = Head and neck: C7-T1 and 1st rib / ear canal
%(12,n) = Shoulder mass: Sternoclavicular joint / glenohumeral axis
%(13,n) = Thorax: C7-T1/T12-L1 and diaphragm
%(14,n) = Abdomen: T12-L1/L4-L5
%(15,n) = Pelvis: L4-L5/greater trochanter
%(16,n) = Thorax and abdomen: C7-T1/L4-L5
%(17,n) = Abdomen and pelvis: T12-L1 / greater trochanter
%(18,n) = Trunk: Greater trochanter / glenohumeral joint
%(19,n) = Trunk head neck: Greater trochanter / glenohumeral joint
%(20,n) = Head, arms, and trunk (HAT): Greater trochanter / glenohumeral joint
%(21,n) = HAT: Greater trochanter / mid rib
%---------------------------------------------------------




%% Read in Data and assign necessary variables

%get Anthropomorphic Data from the table (Winter)
Anthrodata = xlsread('Winter_Table4.1.xlsx');

%Convert weight and height
Weight = Weight*(0.453592);     %kg - (1lb = 0.453592kg)
Height = Height*(0.0254);       %m - (1inch = 0.0254m)

% %Average Body Density: Winter (pg.84) <------------------- not used yet, but may be at some point
% PonderalIndex = Height/Weight^(1/3);
% WholeBodyDensity = 0.69 + 0.9*PonderalIndex;

%Get number of markers (knee, hip, ..., etc.)
%markerarray1 and 2 are arrays of markers where each element in the
%array is a specific marker/joint
%(i.e. markerarray(1) may be shoulder data)
nummark1 = length(markerarray1);
nummark2 = length(markerarray2);

%Initialize other misc. Variables
g = 9.81;                   %m/s^2 [gravity]
tstep = 1/fps;              %time step in sec between frames

%Get number of frames (i.e. number of coordinate pairs for each marker)
frames = length(markerarray1(1).coordinates);
t = (0:tstep:(frames-1)*tstep)';



%% Filter / Spline fit data
%If there are NaN values in position matrix, MUST be replaced with a number
%to be filtered without destroying data after first NaN value
%(filter is dependent on previous value), Ex: NaN + 5 = NaN

% %------- CODE UP FILTER OPTION TO TEST AGAINST SPLINE ---------
% %old filter not not used, code below:
% [markerpos1,markerpos2] = replaceNAN(markerpos1,markerpos2);
%
% %Filter
% [B,A] = butter(2,.07,'low'); % 2nd order low pass filter at 6 hz <-------- [Look into this to discern if this is a better direction to take vs. splinefit]
% %---------------------------------------------------------


% %**********************************************************************
% %Spline Function <---- Consider making this automatically update
% for j=1:nummark1
%     [markerarray1(j).coordinates(:,1),v1x,a1x] = WindowSpline(t,markerarray1(j).coordinates(:,1),3);
%     [markerarray1(j).coordinates(:,2),v1y,a1y] = WindowSpline(t,markerarray1(j).coordinates(:,2),3);
%     %markerarray1(j) = VelAccel([v1x,v1y],[a1x,a1y]); <--- Error: "undefined VelAccel for input arguments type 'double'"
%     %Fix error later...
% end
% 
% for j=1:nummark2
%     [markerarray2(j).coordinates(:,1),v2x,a2x] = WindowSpline(t,markerarray2(j).coordinates(:,1),3);
%     [markerarray2(j).coordinates(:,2),v2y,a2y] = WindowSpline(t,markerarray2(j).coordinates(:,2),3);
%     %markerarray2(j) = VelAccel([v2x,v2y],[a2x,a2y]);
% end



%% Initialize marker coordinates that were selected
%NOTE: THIS PRE-SUPPOSES THAT BOTH VIDEOS HAVE SELECTED THE SAME
%MARKERS - WILL NOT WORK WITHOUT THAT ASSUMPTION  <--- can design it such that we get around this if necessary
JointsChosen = zeros(1,8);

for i = 1:nummark1
    if markerarray1(i).jointnum == 1
        Shoulder1 = markerarray1(i).coordinates;
        Shoulder2 = markerarray2(i).coordinates;
        JointsChosen(1) = 1;
        
    elseif markerarray1(i).jointnum == 2
        Elbow1 = markerarray1(i).coordinates;
        Elbow2 = markerarray2(i).coordinates;
        JointsChosen(2) = 1;
        
    elseif markerarray1(i).jointnum == 3
        Wrist1 = markerarray1(i).coordinates;
        Wrist2 = markerarray2(i).coordinates;
        JointsChosen(3) = 1;
        
    elseif markerarray1(i).jointnum == 4
        Hip1 = markerarray1(i).coordinates;
        Hip2 = markerarray2(i).coordinates;
        JointsChosen(4) = 1;

% %THIGH data is irrelevant to the segment and CM calculations
%     elseif markerarray1(i).jointnum == 5
%         Thigh1 = markerarray1(i).coordinates;
%         Thigh2 = markerarray2(i).coordinates;
%         JointsChosen(5) = 1;

    elseif markerarray1(i).jointnum == 6
        Knee1 = markerarray1(i).coordinates;
        Knee2 = markerarray2(i).coordinates;
        JointsChosen(6) = 1;
        
    elseif markerarray1(i).jointnum == 7
        Ankle1 = markerarray1(i).coordinates;
        Ankle2 = markerarray2(i).coordinates;
        JointsChosen(7) = 1;
        
    elseif markerarray1(i).jointnum == 8
        Foot1 = markerarray1(i).coordinates;
        Foot2 = markerarray2(i).coordinates;
        JointsChosen(8) = 1;
        
    end
end



%% Calculate Mass and CM and ROG - determine available segments
%JointsChosen: [shoulder, elbow, wrist, hip, thigh, knee, ankle, foot]
%                   1       2      3     4     5      6     7      8
%Necessary combinations of markers to make segments:
%lower leg == must have knee and angle
%Thigh == must have knee and hip
%Upper arm == must have shoulder and elbow
%Forearm == must have elbow and wrist
%Shoulder <--- figure this out! (currently running as CM = the Shoulder marker coordinates)
%Foot <--- foot and ankle
%Trunk <--- figure this out!
%Pelvis <--- figure this out!
%Head <--- figure this out!

SegmentsChosen = zeros(1,6);
number_possible_segs = length(SegmentsChosen);
tester1 = 0;
tester2 = 0;

%Shoulder Segment
if JointsChosen(1) == 1
    %Segments(BodyWeight,massfrac,coordsdistal,distalCM,coordsproximal,distalROG,proximalROG,CofGROG)
    %<><><><><> DEAL WITH SHOULDER <><><><><>
    Shoulderseg1 = Segments(tstep, Weight, Anthrodata(12,1), Shoulder1, Anthrodata(12,3));
    Shoulderseg1.name = 'Shoulder1';
    Shoulderseg2 = Segments(tstep, Weight, Anthrodata(12,1), Shoulder2, Anthrodata(12,3));
    Shoulderseg2.name = 'Shoulder2';
    SegmentsChosen(1) = 1;
    if tester1 == 0
        Segarray1(1) = Shoulderseg1;
        tester1 = 1;
    else
        Segarray1(end+1) = Shoulderseg1;
    end
    if tester2 == 0
        Segarray2(1) = Shoulderseg2;
        tester2 = 1;
    else
        Segarray2(end+1) = Shoulderseg2;
    end
end

%Lower Leg Segment
if  JointsChosen(6) == 1 && JointsChosen(7) == 1
    Lowerleg1 = Segments(tstep, Weight, Anthrodata(7,1), Knee1, Anthrodata(7,3), Ankle1, Anthrodata(7,6), Anthrodata(7,5), Anthrodata(7,4));
    Lowerleg1.name = 'Lowerleg1';
    Lowerleg2 = Segments(tstep, Weight, Anthrodata(7,1), Knee2, Anthrodata(7,3), Ankle2, Anthrodata(7,6), Anthrodata(7,5), Anthrodata(7,4));
    Lowerleg2.name = 'Lowerleg2';
    SegmentsChosen(2) = 1;
    if tester1 == 0
        Segarray1(1) = Lowerleg1;
        tester1 = 1;
    else
        Segarray1(end+1) = Lowerleg1;
    end
    if tester2 == 0
        Segarray2(1) = Lowerleg2;
        tester2 = 1;
    else
        Segarray2(end+1) = Lowerleg2;
    end
end

%Thigh Segment
if JointsChosen(6) == 1 && JointsChosen(5) == 1
    Thigh1 = Segments(tstep, Weight, Anthrodata(8,1), Hip1, Anthrodata(8,3), Knee1, Anthrodata(8,6), Anthrodata(8,5), Anthrodata(8,4));
    Thigh1.name = 'Thigh1';
    Thigh2 = Segments(tstep, Weight, Anthrodata(8,1), Hip2, Anthrodata(8,3), Knee2, Anthrodata(8,6), Anthrodata(8,5), Anthrodata(8,4));
    Thigh2.name = 'Thigh2';
    SegmentsChosen(3) = 1;
    if tester1 == 0
        Segarray1(1) = Thigh1;
        tester1 = 1;
    else
        Segarray1(end+1) = Thigh1;
    end
    if tester2 == 0
        Segarray2(1) = Thigh2;
        tester2 = 1;
    else
        Segarray2(end+1) = Thigh2;
    end
end

%Upper Arm Segment
if JointsChosen(1) == 1 && JointsChosen(2) == 1
    Upperarm1 = Segments(tstep, Weight, Anthrodata(3,1), Shoulder1, Anthrodata(3,3), Elbow1, Anthrodata(3,6), Anthrodata(3,5), Anthrodata(3,4));
    Upperarm1.name = 'Upperarm1';
    Upperarm2 = Segments(tstep, Weight, Anthrodata(3,1), Shoulder2, Anthrodata(3,3), Elbow2, Anthrodata(3,6), Anthrodata(3,5), Anthrodata(3,4));
    Upperarm2.name = 'Upperarm2';
    SegmentsChosen(4) = 1;
    if tester1 == 0
        Segarray1(1) = Upperarm1;
        tester1 = 1;
    else
        Segarray1(end+1) = Upperarm1;
    end
    if tester2 == 0
        Segarray2(1) = Upperarm2;
        tester2 = 1;
    else
        Segarray2(end+1) = Upperarm2;
    end
end

%Forearm Arm Segment
if JointsChosen(2) == 1 && JointsChosen(3) == 1
    Forearm1 = Segments(tstep, Weight, Anthrodata(2,1), Elbow1, Anthrodata(2,3), Wrist1, Anthrodata(2,6), Anthrodata(2,5), Anthrodata(2,4));
    Forearm1.name = 'Forearm1';
    Forearm2 = Segments(tstep, Weight, Anthrodata(2,1), Elbow2, Anthrodata(2,3), Wrist2, Anthrodata(2,6), Anthrodata(2,5), Anthrodata(2,4));
    Forearm2.name = 'Forearm2';
    SegmentsChosen(5) = 1;
    if tester1 == 0
        Segarray1(1) = Forearm1;
        tester1 = 1;
    else
        Segarray1(end+1) = Forearm1;
    end
    if tester2 == 0
        Segarray2(1) = Forearm2;
        tester2 = 1;
    else
        Segarray2(end+1) = Forearm2;
    end
end

%Foot Segment
if JointsChosen(7) == 1 && JointsChosen(8) == 1
    Foot1 = Segments(tstep, Weight, Anthrodata(6,1), Ankle1, Anthrodata(6,3), Foot1, Anthrodata(6,6), Anthrodata(6,5), Anthrodata(6,4));
    Foot1.name = 'Foot1';
    Foot2 = Segments(tstep, Weight, Anthrodata(6,1), Ankle2, Anthrodata(6,3), Foot2, Anthrodata(6,6), Anthrodata(6,5), Anthrodata(6,4));
    Foot2.name = 'Foot2';
    SegmentsChosen(6) = 1;
    if tester1 == 0
        Segarray1(1) = Foot1;
        tester1 = 1;
    else
        Segarray1(end+1) = Foot1;
    end
    if tester2 == 0
        Segarray2(1) = Foot2;
        tester2 = 1;
    else
        Segarray2(end+1) = Foot2;
    end
end



%% Calculate Total System CM 
%Determine if a decent approximation of the system CM can be obtained
%without determinations of the trunk mass and CM
%(to John this is questionable) <-------------------- FIGURE THIS OUT AT SOME POINT

%video 1 and 2 CM of system:
%Note: this is general - so it works for both a single video setup and
%      a 2-video setup

%Initialize Variables
Massofsys = 0;
sysCM1 = zeros(frames,2);
sysCM2 = sysCM1;

%Calculate the systems center of mass:
for i = 1:length(Segarray1)
    
    for k = 1:frames
        
        %X coordinate for CM of system
        sysCM1(k,1) = sysCM1(k,1) + Segarray1(i).mass*Segarray1(i).rCM(k,1);
        sysCM2(k,1) = sysCM2(k,1) + Segarray2(i).mass*Segarray1(i).rCM(k,1);
        
        %Y coordinate for CM of system
        sysCM1(k,2) = sysCM1(k,2) + Segarray1(i).mass*Segarray1(i).rCM(k,1);
        sysCM2(k,2) = sysCM2(k,2) + Segarray2(i).mass*Segarray1(i).rCM(k,2);
        
    end
    
    %Total mass of system
    Massofsys = Massofsys + Segarray1(i).mass;
    
end

%Divide by total mass of system
sysCM1 = sysCM1/Massofsys;
sysCM2 = sysCM2/Massofsys;

%Averaging the center of mass from both sides of the body
rCMsys = (sysCM1 + sysCM2)/2;



%% Determine acceleration of Sys with central difference

%Initialize Variables
aCMsys = zeros(frames-2,2);
vCMsys = zeros(frames-2,2);

%Run central finite difference:
for framenum = 2:frames-1
        aCMsys(framenum,:) = (rCMsys(framenum+1,:) - 2*rCMsys(framenum,:) + rCMsys(framenum-1,:))/tstep^2;
        vCMsys(framenum,:) = (rCMsys(framenum+1,:) - rCMsys(framenum-1,:))/(2*tstep);
end


%% Find Ground Force Reactions (GRF) and joint forces <------------------------------- Left off here May 24th
GRFx = Massofsys*aCMsys(:,1);
GRFy = Massofsys*(g+aCMsys(:,2));


%% Compute power
Power_ext = GRFy.*vCMsys(:,2);   %alternate way to compute power (using as a check)


%% Compute energy
EnergyInt(1) = 0; deltat = t(2)-t(1);
for i = 1:length(Power_ext)
    if i > 40
        EnergyInt(i+1) = EnergyInt(i)+Power_ext(i)*deltat;
    else
        EnergyInt(i+1) = EnergyInt(i);
    end
end


%% Time step for plotting results
t = t(1:length(t)-1,1);


% %OLD PLOTTING DATA - PLOTTING WILL TAKE PLACE IN ForceTrak.m for the
% %Verification Tab
% figure(1), clf
% subplot(2,1,1),plot(t(1:end-1),Power_ext)
% grid on
% ylabel('Power (W)')
% hold on, 
% subplot(2,1,2),plot(t(1:end),EnergyInt)
% grid on
% ylabel('Energy (Nm)')
% xlabel('Time (s)')
% 
% 
% figure(2),clf,plot(t(1:end-1),GRFx)
% hold on
% plot(t(1:end-1),GRFy,'g')
% grid on
% xlabel('Time (s)')
% ylabel('GRF (N)')
% legend('GRFx','GRFy')
% ylim([-200 700])

end


