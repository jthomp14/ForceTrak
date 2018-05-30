function [markerpos1,markerpos2,markerarray1,markerarray2] = BoxMainTrack2Vid(output1,output2)

%% 00 Video Structures
% f0 = 'vidname';
% f1 = 'vid';
% f2 = 'bthr';
% f3 = 'tframe';
% f4 = 'sframe';
% f5 = 'refdist';
% f6 = 'rowcut';
% f7 = 'colcut';
% f8 = 'vidnum';
% f9 = 'eframe';
% f10 = 'mframe';
% f11 = 'rmat';
% f12 = 'centThr';
% f13 = 'rmvSize';
% f14 = 'nummark';
% f15 = 'ref1';
% f16 = 'refang';
% f17 = 'pxtom';
% Svid1 = struct(f0,[],f1,[],f2,[],f3,[],f4,[],f5,[],f6,[],f7,[],f8,[],....
%     f9,[],f10,[],f11,[],f12,[],f13,[],f14,[],f15,[],f16,[],f17,[]);
% Svid2 = struct(f0,[],f1,[],f2,[],f3,[],f4,[],f5,[],f6,[],f7,[],f8,[],....
%     f9,[],f10,[],f11,[],f12,[],f13,[],f14,[],f15,[],f16,[],f17,[]);

markerarray1 = output1.markerarray;
markerarray2 = output2.markerarray;

OccultationData1 = output1.OccultationData;
OccultationData2 = output2.OccultationData;

markerclicks1 = output1.markerclicks1;
markerclicks2 = output2.markerclicks2;

boxDist = output1.boxDist;

%% Video 1

%Name of video1
vidname1 = output1.vidname1;

%Starting Frame
sframe = output1.sframe;

%Total Frames
tframe = output1.tframe;

%Number of Markers
nummark = output1.nummark;


%------------ May not be necessary ------------
hipindex = output1.hipindex;
thighindex = output1.thighindex;
length_Thigh_Hip1 = output1.length_Thigh_Hip1;
length_Thigh_Hip2 = output2.length_Thigh_Hip2;
%----------------------------------------------

%% Assigning Values to Structure
Svid1.vid = VideoReader(vidname1);
Svid1.vidname = vidname1;
Svid1.sframe = sframe;
Svid1.tframe = tframe;
Svid1.nummark = nummark;
Svid1.vidnum = 1;
Svid1.rot_num = output1.rot_num;


%------------ May not be necessary ------------
Svid1.hipindex = hipindex;
Svid1.thighindex = thighindex;
Svid1.length_Thigh_Hip = length_Thigh_Hip1;
Svid1.jointschosen = output1.jointschosen;
%----------------------------------------------


%------------ May not be necessary ------------
unitvecthresh = output1.unitvecthresh;
%----------------------------------------------


hsvthresh = output1.hsvthresh;
pxtom1 = output1.pxtom;
refang1 = output1.refang;
ref11 = output1.refp1;


%% Video 2 - Inputs that can be configured from trackGUI.m

%Name of video1
vidname2 = output2.vidname2;

%Starting Frame
sFrame = output2.sframe;

%Total Frames
tFrame = output2.tframe;

%Number of Markers
nummark = output2.nummark;

%% Assigning Values to Structure
Svid2.vid = VideoReader(vidname2);
Svid2.vidname = vidname2;
Svid2.sframe = sframe;
Svid2.nummark = nummark;
Svid2.vidnum = 2;
Svid2.rot_num = output1.rot_num;

Svid2.hipindex = hipindex;
Svid2.thighindex = thighindex;
Svid2.length_Thigh_Hip = length_Thigh_Hip2;
Svid2.jointschosen = output2.jointschosen;

%total frames determined from video 1
Svid2.tframe = Svid1.tframe;

%Reference distance [m]
refdist = output1.refdist; %Unused

hsvthresh = output2.hsvthresh;


unitvecthresh = output2.unitvecthresh;
pxtom2 = output2.pxtom;
refang2 = output2.refang;
ref12 = output2.refp1;

%% Reference distances
% [pxtom1, ref11, refang1] = pixtometers(Svid1.vid, Svid1.sframe, refdist,1);
% [pxtom2, ref12, refang2] = pixtometers(Svid2.vid, Svid2.sframe, refdist,2);

Svid1.pxtom = pxtom1;
Svid1.ref1 = ref11;
Svid1.refang = refang1;

Svid2.pxtom = pxtom2;
Svid2.ref1 = ref12;
Svid2.refang = refang2;

%------------ May not be necessary ------------
Svid1.unitvecthresh = unitvecthresh;
%----------------------------------------------

Svid1.hsvthresh = hsvthresh;
Svid2.hsvthresh = hsvthresh;
Svid2.unitvecthresh = unitvecthresh;
%% Synching
%Frames per second
fps = Svid1.vid.FrameRate; %<--- Consider fixing this!            <-------------------- FIX THIS!! CONSIDER THIS WHILE TESTING!
%NOTE: when reading in slow-mo video - the matlab reader thinks the
%Frame rate is 30 <--- which is true for the first few seconds of the
%video, for some reason, iPhone 7/8 take the first few seconds at a
%normal rate, then reduce to slowmotion - so this video reader
%functionality should not be trusted --> Thus, I've incorporated a slection
%box into the GUI to deal with this...

Svid2.sframe = vidsync(Svid1.sframe,Svid1.vidname,Svid2.vidname,fps);


%%  Tracking
% [markerpos1] = boxtracking(Svid1,0,markerclicks,boxDist);
% [markerpos2] = boxtracking(Svid2,0,markerclicks,boxDist);

[markerpos1,markerarray1] = boxtracking_dualsorted(Svid1,0,markerclicks1,boxDist,markerarray1,OccultationData1);
[markerpos2,markerarray2] = boxtracking_dualsorted(Svid2,0,markerclicks2,boxDist,markerarray2,OccultationData2);


%% Reordering Markers Based off User Input <------- (Not Necessary?)
% for i=1:length(Svid1.Click2Mark(:,1))
%     mark2click = Svid1.Click2Mark(i,:);
%     
%     switchMark1(:,:,i) = markerpos1(:,:,mark2click(1));
% end
% markerpos1 = switchMark1;
% 
% for i=1:length(Svid2.Click2Mark(:,1))
%     mark2click = Svid2.Click2Mark(i,:);
%     
%     switchMark2(:,:,i) = markerpos2(:,:,mark2click(1));
% end
% markerpos2 = switchMark2;



%% Write Position Data to excel file
%This writes the position data to excel.
%This was done given xlswrite does not work on MAC versions of MATLAB
%Thus, this will work for both MAC and WINDOWS

a = 1;
%Delete files if they already exist:
fid = 'MarkerPosData_Vid1.xlsx';
delete(fid);
fid = 'MarkerPosData_Vid2.xlsx';
delete(fid);
%Write position data to excel files
for i = 1:length(markerarray1)
    %Assign Headers into table for writing
        T1(1,a) = {strcat(markerarray1(i).markername, '-x')};
        T1(1,a+1) = {strcat(markerarray1(i).markername, '-y')};
        T2(1,a) = {strcat(markerarray2(i).markername, '-x')};
        T2(1,a+1) = {strcat(markerarray2(i).markername, '-y')};
    %Assign coordinates into table for writing
    for j = 1:length(markerarray1(1).coordinates)
        T1{j+1,a} = markerarray1(i).coordinates(j,1);
        T1{j+1,a+1} = markerarray1(i).coordinates(j,2);
        T2{j+1,a} = markerarray2(i).coordinates(j,1);
        T2{j+1,a+1} = markerarray2(i).coordinates(j,2);
    end
    a = a+2;
end

T1 = table(T1);
fid = 'MarkerPosData_Vid1.xlsx';
writetable(T1,fid,'Sheet',1,'WriteVariableNames',false)

T2 = table(T2);
fid = 'MarkerPosData_Vid2.xlsx';
writetable(T2,fid,'Sheet',1,'WriteVariableNames',false)
 
% for i = 1:Svid1.tframe
%     
%     title('Combined Position Data')
%      xlim([0 refdist])
%      ylim([0 refdist*2])
%      axis square
%     hold on
%     for j = 1:nummark
%         plot(markerpos1(i,2,j),markerpos1(i,1,j),'ob','MarkerSize',15)
%         plot(markerpos2(i,2,j),markerpos2(i,1,j),'og','MarkerSize',15)
%     end
%     
%     drawnow
%     clf
%     
% end


%  %% Write Video of data <------ DELETE THIS, THIS IS FOR TESTING
% %open video writer to write video of markers
% vidobj = VideoWriter('MarkerPosData2_Videos.avi');
% open(vidobj);
% Vid_Plot_Handle = figure ;hold on; box on; grid on;
% set(gca,'nextplot','replacechildren');
% %a == number of frames that were run
% [a,~,c] = size(markerpos1);
% colorv1 = rand(c,3);
% colorv2 = rand(c,3);
% for i = 1:a
%     str = sprintf('%.0f',i);
%     for j = 1:c
%          plot(markerpos1(i,1,j),markerpos1(i,2,j),'.','Color',colorv1(j,:),'MarkerSize',20); hold on 
%          text(markerpos1(i,1,j),markerpos1(i,2,j),str)
%     end
%     title('Visualizing marker position')
%     xlabel('X-Position')
%     ylabel('Y-Position')
%     axis square
%     currframe = getframe(gcf);
%     writeVideo(vidobj,currframe)
%              
% end
% 
% for i = 1:a
%     str = sprintf('%.0f',i);
%     for j = 1:c
%          plot(markerpos2(i,1,j),markerpos2(i,2,j),'o','Color',colorv2(j,:),'MarkerSize',8); hold on 
%          text(markerpos2(i,1,j),markerpos2(i,2,j),str)
%     end
%     title('Visualizing marker position')
%     xlabel('X-Position')
%     ylabel('Y-Position')
%     axis square
%     currframe = getframe(gcf);
%     writeVideo(vidobj,currframe) 
%             
% end
% close(Vid_Plot_Handle)
% 
% %NOT SURE WHAT THIS IS?????
% %Copy_of_power_calc(markerpos1,markerpos2);


end