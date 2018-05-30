function  [markerpos1,markerpos2,markerarray1,markerarray2] = BoxMainTrackOneVid(output1)

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
markerarray1 = output1.markerarray;
OccultationData = output1.OccultationData;
markerclicks1 = output1.markerclicks1;
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

hsvthresh = output1.hsvthresh;
unitvecthresh = output1.unitvecthresh;
pxtom1 = output1.pxtom;
refang1 = output1.refang;
ref11 = output1.refp1;
jointschosen = output1.jointschosen;

%% Assigning Values to Structure
Svid1.vid = VideoReader(vidname1);
Svid1.vidname = vidname1;
Svid1.sframe = sframe;
Svid1.tframe = tframe;
Svid1.nummark = nummark;
Svid1.vidnum = 1;
Svid1.rot_num = output1.rot_num;
Svid1.jointschosen = jointschosen;

Svid1.pxtom = pxtom1;
Svid1.ref1 = ref11;
Svid1.refang = refang1;

Svid1.hsvthresh = hsvthresh;
Svid1.unitvecthresh = unitvecthresh;


%% Synching
%Frames per second
fps = Svid1.vid.FrameRate; %<------- this seems unneccessary for 1 video?
%NOTE: when reading in slow-mo video - the matlab reader thinks the
%Frame rate is 30 <--- which is true for the first few seconds of the
%video, for some reason, iPhone 7/8 take the first few seconds at a
%normal rate, then reduce to slowmotion - so this video reader
%functionality should not be trusted --> Thus, I've incorporated a slection
%box into the GUI to deal with this...


%%  Tracking
[markerpos1,markerarray1] = boxtracking_dualsorted(Svid1,0,markerclicks1,boxDist,markerarray1,OccultationData);
markerpos2 = markerpos1;
markerarray2 = markerarray1;

%% Reordering Markers Based off User Input
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
 


% %OLD CODE FOR markerpos writing to excel
% %Write to CSV File with Headers (mac lacks ability with xlswrite)
% a = 1:3:100;
% for i=1:length(markerpos1(1,1,:))
%     markerpositionstored(:,a(i):a(i)+1,1) = markerpos1(:,:,i);
%     markerpositionstored(:,a(i):a(i)+1,2) = markerpos2(:,:,i);
% end
% 
% xlswrite('markerpos1_2.xls',markerpositionstored(:,:,1),1);
% xlswrite('markerpos2_2.xls',markerpositionstored(:,:,2),2);
% %save('markerpos.mat','markerpos1');


%  %% Write Video of data <------ DELETE THIS, THIS IS FOR TESTING
% %open video writer to write video of markers
% vidobj = VideoWriter('MarkerPosData_Vid1.avi');
% open(vidobj);
% figure ;hold on; box on; grid on;
% set(gca,'nextplot','replacechildren');
% %a is number of frames that were run
% colorv1 = rand(length(markerarray1),3);
% colorv2 = rand(length(markerarray1),3);
% for i = 1:(length(markerarray1(1).coordinates)-1)
%     str = sprintf('%.0f',i);
%     for j = 1:length(markerarray1)
%          plot(markerpos1(i,1,j),markerpos1(i,2,j),'.','Color',colorv1(j,:),'MarkerSize',18); hold on 
%          text(markerpos1(i,1,j),markerpos1(i,2,j),str)
%          plot(markerarray1(j).coordinates(i,1),markerarray1(j).coordinates(i,2),'o','Color',colorv2(j,:)); hold on
%     end
%     title('Visualizing marker position')
%     xlabel('X-Position (m)')
%     ylabel('Y-Position (m)')
%     legend('markerpos data', 'markerarray data')
%     axis square
%     currframe = getframe(gcf);
%     writeVideo(vidobj,currframe)
% end

%power_calc_spline(markerpos1,markerpos1); <---- a relic from a previous version?

end














