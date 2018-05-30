
classdef ForceTrak < handle
    %CLASS Definition
    
    properties %ALL the properties of this class
        %Important information
        colorconfig
        videonum
        vid1
        vid2
        vidname
        vidname2
        StartFrame
        StartFrame2
        EndFrame
        nummark % number of markers
        markerclicks1
        markerclicks2
        boxDist = 30;
        im
        hsvthresh %Output after boxclicks
        unitvecthresh %Output after boxclicks
        currentvid = 1;
        refdist
        pxtom
        refang
        refp1
        pxtom2
        refang2
        refp12
        rot_num = 0;
        rot_num2 = 0;
        plotdata
        hipindex
        thighindex
        kneeindex
        wristindex
        length_Thigh_Hip1
        length_Thigh_Hip2
        SubjectWeight
        SubjectHeight
        jointschosen1
        jointschosen2
        
        % For Plotting Boxes
        ln % stands for line
        
        %Figure handle
        Figure
        
        % Tab handles
        TabGroup
        WelcomeTab
        ChooseConfigTab
        LoadVideosTab
        ChooseStartFrameTab
        RotateSecondVideoTab
        JointClicksTab
        ReferenceDistanceTab
        VerificationTab
        
        % WelcomeTab UIControls
        TextWelcome
        PushButtonNextConfigTab
        CallbackPushButtonConfigTab
        
        % ChooseConfigTab UIControls
        TextBigOne
        TextChooseConfig
        TextChooseMarkerColor
        ListBoxChooseMarkerColor
        ListBoxChooseVidNum
        TextNumberOfVideos
        PushButtonNextStep1
        axLogoPosition
        
        % LoadVideosTab UIControls
        TextBigTwo
        TextLoadVideo
        PushButtonVideo1
        PushButtonVideo2
        PushButtonNextStep2
        LOADED1
        LOADED2
        TextFramesPerSecond
        ListBoxFramesPerSecond
        FramesPerSecond
        
        % Frame Selection Tab UIControls
        TextBigThree
        TextChooseFrames
        TextStartFrame
        TextEndFrame
        SliderFrameSelection
        axframeselection
        PushButtonChooseStartFrame
        PushButtonNextStep3
        PushButtonRotateVid
        TextCurrentFrame
        
        %RotateSecondVideoTab UI Controls
        TextBigThreeFive
        axrotatevid2
        PushButtonRotateVid2
        PushButtonNextStep35
        
        % JointClicksTab UI Controls
        TextBigFour
        axjointclicks
        checkboxshoulder
        checkboxelbow
        checkboxwrist
        checkboxhip
        checkboxthigh
        checkboxknee
        checkboxankle
        checkboxfoot
        TextChooseMarkers
        PushButtonClickJoints
        SliderBoxSize
        PushButtonProceedVideo2
        PushButtonNextStep4
        PushButtonZoom
        
        % ReferenceDistanceTab UI Controlds
        TextBigFive
        TextChooseReferenceDistance
        EditReferenceDistance
        AxReferenceDistance
        PushButtonReferenceDistance
        PushButtonRunAnalysis
        WeightEntry
        HeightEntry
        
        % Verification Tab
        AxLeftShowVerificationTab
        AxRightShowVerificationTab
        PushButtonSaveGRF
        PushButtonSavePowerEnergy
        
        %*******************************
        %MY PROPS
        %*******************************
        OccultationData
        markerarray
        OccultationData1
        markerarray1
        OccultationData2
        markerarray2
        
    end
    
    
    methods %Methods associated with class
        
        %Constructor (Creates/initializes everything upon startup)
        %This is a method that works on the class ForceTrak
        %This overall bit sets up the UI
        function app = ForceTrak()
            
            %***This bit calls dimensions of main figure
            ss = get(0,'screensize'); %returns vector 3rd element width, 4th element height
            width = round(ss(3)*(2/3));
            height = round(ss(4)*(3/4));
            fromleft = ss(3)/2-width/2; %centers the figure that will be created
            frombottom = ss(4)/2 - height/2; %centers
            
            %Figure Creation - app becomes a "struct"
            app.Figure = figure('Name','ForceTrak','NumberTitle','off','Position',[fromleft,frombottom, .....
                width, height],'menubar','none');
            
            %Tab Group Creation
            %creates a tabgroup component and returns handle
            %Basically creates a container for hosting user interface tabs
            app.TabGroup = uitabgroup(app.Figure,'Position',[0 0 1 1]);
            
            %Tab Creation
            %uitab - creates the individual containers for the tabs
            app.WelcomeTab = uitab(app.TabGroup,'Title','Start');
            app.ChooseConfigTab = uitab(app.TabGroup,'Title','1 - Choose Config');
            app.LoadVideosTab = uitab(app.TabGroup,'Title','2 - Load Videos');
            app.ChooseStartFrameTab = uitab(app.TabGroup,'Title','3 - Choose Frames');
            app.RotateSecondVideoTab = uitab(app.TabGroup,'Title','3.5 - Rotate Second Video');
            app.JointClicksTab = uitab(app.TabGroup,'Title','4 - Click Markers');
            app.ReferenceDistanceTab = uitab(app.TabGroup,'Title','5 - Reference Distance');
            app.VerificationTab = uitab(app.TabGroup,'Title','6 - Verification');
            
            %Deal with Instructions / External Webpage
            %Source:
            %https://undocumentedmatlab.com/blog/hyperlink-text-labels
            %Create and display the text label
            url = 'UCCS.edu';
            strSiteLabel = ['<html>Instructions: <a href="">' url '</a></html>'];
            JavaLabel = javaObjectEDT('javax.swing.JLabel', strSiteLabel);
            [hjLabel,~] = javacomponent(JavaLabel, [20,20,150,20], gcf);
            
            %Modify the mouse cursor when hovering on the label
            hjLabel.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
            
            %Set the label's tooltip
            hjLabel.setToolTipText(['Visit the ' url ' website']);
            
            %Set the mouse-click callback
            set(hjLabel, 'MouseClickedCallback', @(h,e)web(['http://' url], '-browser'))
            
            
            %% Welcome UI Controls
            %'Position',[xposition yposition xlength ylength] <--- origin
           %at bottom left corner
            app.TextWelcome = uicontrol('Parent',app.WelcomeTab,'Style','text','String','Welcome To ForceTrak',...
                'Units','Normalized','Position',[.25 .6 .5 .3],'fontsize',70);
            app.PushButtonNextStep1 = uicontrol('Parent',app.WelcomeTab,'Style','pushbutton','String','Start',...
                'Units','Normalized','Position',[.4 .45 .2 .1],'fontsize',18,'Callback',@app.CallbackPushButtonConfigMainTab);
            app.axLogoPosition = axes('Parent',app.WelcomeTab,'TickLength',[0 0],'XTickLabel',''...
                ,'YTickLabel','','Position',[.1 .1 .8 .2]);
            imshow('uccslogo.jpg','Parent',app.axLogoPosition)
            
            
            %% 1- ChooseConfigTab UI controls
            app.TextBigOne = uicontrol('Parent',app.ChooseConfigTab,'Style','text','String','1',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.TextChooseConfig = uicontrol('Parent',app.ChooseConfigTab,'Style','text','String','Choose Config',...
                'Units','Normalized','Position',[.12 .85 .16 .05],'fontsize',20);
%             app.TextChooseMarkerColor = uicontrol('Parent',app.ChooseConfigTab,'Style','text','String','Choose Marker Color',...
%                 'Units','Normalized','Position',[.1 .6 .3 .1],'fontsize',25);
            %app.ListBoxChooseMarkerColor = uicontrol('Parent',app.ChooseConfigTab,'Style','listbox','String',{'Green','Blue','Red'},...
               % 'Units','Normalized','Position',[.2 .5 .1 .11],'fontsize',18);
            app.TextNumberOfVideos = uicontrol('Parent',app.ChooseConfigTab,'Style','text','String','Choose # of Videos',...
                'Units','Normalized','Position',[.35 .6 .3 .1],'fontsize',25);
            app.ListBoxChooseVidNum = uicontrol('Parent',app.ChooseConfigTab,'Style','listbox','String',{'One','Two'},...
                'Units','Normalized','Position',[.45 .5 .1 .11],'fontsize',18);
            app.PushButtonNextStep1 = uicontrol('Parent',app.ChooseConfigTab,'Style','pushbutton','String','Next Step',...
                'Units','Normalized','Position',[.8 .85 .1 .06],'fontsize',18,'Callback',@app.CallbackPushButtonNextStep1);
            

            %% 2- LoadVideosTab UIControls
            app.TextBigTwo = uicontrol('Parent',app.LoadVideosTab,'Style','text','String','2',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.TextLoadVideo = uicontrol('Parent',app.LoadVideosTab,'Style','text','String','Load Video',...
                'Units','Normalized','Position',[.12 .85 .16 .05],'fontsize',20);
            app.PushButtonVideo1 = uicontrol('Parent',app.LoadVideosTab,'Style','pushbutton','String','Choose Your Video',...
                'Units','Normalized','Position',[.25 .6 .2 .06],'fontsize',18,'Callback',@app.CallbackPushButtonVideo1);
            app.PushButtonVideo2 = uicontrol('Parent',app.LoadVideosTab,'Style','pushbutton','String','Choose Video 2',...
                'Units','Normalized','Position',[.6 .6 .2 .06],'fontsize',18,'Callback',@app.CallbackPushButtonVideo2);
            app.PushButtonNextStep2 = uicontrol('Parent',app.LoadVideosTab,'Style','pushbutton','String','Next Step',...
                'Units','Normalized','Position',[.8 .85 .1 .06],'fontsize',18,'Callback',@app.CallbackPushButtonNextStep2);
            app.LOADED1 = uicontrol('Parent',app.LoadVideosTab,'Style','text','String','LOADED',...
                'Units','Normalized','Position',[.3 .54 .1 .03],'fontsize',12,'BackgroundColor',[0 1 0],'Visible','off');
            app.LOADED2 = uicontrol('Parent',app.LoadVideosTab,'Style','text','String','LOADED',...
                'Units','Normalized','Position',[.65 .54 .1 .03],'fontsize',12,'BackgroundColor',[0 1 0],'Visible','off');
           
            
            app.TextFramesPerSecond = uicontrol('Parent',app.LoadVideosTab,'Style','text','String','Select Video Frame Rate (fps)',...
                'Units','Normalized','Position',[.3 .39 .4 .1],'fontsize',25);
            app.ListBoxFramesPerSecond = uicontrol('Parent',app.LoadVideosTab,'Style','listbox','String',{'120','240'},...
                'Units','Normalized','Position',[.45 .35 .08 .08],'fontsize',18);
            
            %% 3- ChooseStartFrameTab UIControls
            app.TextBigThree = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String','3',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.TextChooseFrames = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String','Choose Frames',...
                'Units','Normalized','Position',[.13 .85 .16 .05],'fontsize',20);
            app.axframeselection = axes('Parent',app.ChooseStartFrameTab,'TickLength',[0 0],'XTickLabel',''...
                ,'YTickLabel','','Position',[.33 0 .4 .9]);
            app.PushButtonChooseStartFrame = uicontrol('Parent',app.ChooseStartFrameTab,'Style','pushbutton','String','Choose Start Frame',...
                'Units','Normalized','Position',[.12 .5 .18 .06],'fontsize',16,'Callback',@app.CallbackPushButtonChooseStartFrame);
            app.SliderFrameSelection = uicontrol('Parent',app.ChooseStartFrameTab,'Style','slider','String','Choose Box Size',...
                'Units','Normalized','Position',[.13 .4 .15 .04],'fontsize',12,'Max',1500,'Min',1,'Value',1,'SliderStep',[1 10],'Callback',@app.CallbackSliderFrameSelection);
            app.TextStartFrame = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String','Start Frame: ~',...
                'Units','Normalized','Position',[.13 .3 .13 .08],'fontsize',14);
            app.TextEndFrame = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String','End Frame : ~',...
                'Units','Normalized','Position',[.13 .25 .13 .08],'fontsize',14);
            app.PushButtonNextStep3 = uicontrol('Parent',app.ChooseStartFrameTab,'Style','pushbutton','String','Next Step',...
                'Units','Normalized','Position',[.8 .85 .1 .06],'fontsize',18,'Callback',@app.CallbackPushButtonNextStep3);
            app.PushButtonRotateVid = uicontrol('Parent',app.ChooseStartFrameTab,'Style','pushbutton','String','Rotate',...
                'Units','Normalized','Position',[.12 .6 .18 .06],'fontsize',18,'Callback',@app.CallbackPushButtonRotateVid);
            app.TextChooseFrames = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String','Choose Frames',...
                'Units','Normalized','Position',[.13 .85 .16 .05],'fontsize',20);
            app.TextCurrentFrame = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String',strcat('Current Frame: ',num2str(app.SliderFrameSelection.Value)),...
                'Units','Normalized','Position',[.13 .45 .16 .03],'fontsize',14);
            
             %% 3.5 - RotateSecondVideoTab UIControls
            app.TextBigThreeFive = uicontrol('Parent',app.RotateSecondVideoTab,'Style','text','String','3.5',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.axrotatevid2 = axes('Parent',app.RotateSecondVideoTab,'TickLength',[0 0],'XTickLabel',''...
                ,'YTickLabel','','Position',[.33 0 .4 .9]);
            app.PushButtonRotateVid2 = uicontrol('Parent',app.RotateSecondVideoTab,'Style','pushbutton','String','Rotate',...
                'Units','Normalized','Position',[.12 .6 .18 .06],'fontsize',18,'Callback',@app.CallbackPushButtonRotateVid2);
            app.PushButtonNextStep35 = uicontrol('Parent',app.RotateSecondVideoTab,'Style','pushbutton','String','Next Step',...
                'Units','Normalized','Position',[.8 .85 .1 .06],'fontsize',18,'Callback',@app.CallbackPushButtonNextStep35);
%             app.TextCurrentFrame = uicontrol('Parent',app.ChooseStartFrameTab,'Style','text','String',strcat('Current Frame: ',num2str(app.SliderFrameSelection.Value)),...
%                 'Units','Normalized','Position',[.13 .45 .16 .03],'fontsize',14);
%             

            
            %% 4- JointClicksTab UI Controls
            app.TextBigFour = uicontrol('Parent',app.JointClicksTab,'Style','text','String','4',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.axjointclicks = axes('Parent',app.JointClicksTab,'TickLength',[0 0],'XTickLabel',''...
                ,'YTickLabel','','Position',[.42 0 .4 .95]);
            app.TextChooseMarkers = uicontrol('Parent',app.JointClicksTab,'Style','text','String','Choose Markers',...
                'Units','Normalized','Position',[.13 .85 .16 .05],'fontsize',20);
            app.checkboxshoulder = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Shoulder',...
                'Units','Normalized','Position',[.13 .8 .15 .04],'fontsize',14);
            app.checkboxelbow = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Elbow',...
                'Units','Normalized','Position',[.13 .76 .15 .04],'fontsize',14);
            app.checkboxwrist = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Wrist',...
                'Units','Normalized','Position',[.13 .72 .15 .04],'fontsize',14);
            app.checkboxhip = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Hip',...
                'Units','Normalized','Position',[.13 .68 .15 .04],'fontsize',14);
            app.checkboxthigh = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Thigh',...
                'Units','Normalized','Position',[.13 .64 .15 .04],'fontsize',14);
            app.checkboxknee = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Knee',...
                'Units','Normalized','Position',[.13 .6 .15 .04],'fontsize',14);
            app.checkboxankle = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Ankle',...
                'Units','Normalized','Position',[.13 .56 .15 .04],'fontsize',14);
            app.checkboxfoot = uicontrol('Parent',app.JointClicksTab,'Style','checkbox','String','Foot',...
                'Units','Normalized','Position',[.13 .52 .15 .04],'fontsize',14);
            app.PushButtonClickJoints = uicontrol('Parent',app.JointClicksTab,'Style','pushbutton','String','Click Joints',...
                'Units','Normalized','Position',[.13 .42 .15 .06],'fontsize',16,'Callback',@app.CallbackPushButtonClickJoints);
            app.SliderBoxSize = uicontrol('Parent',app.JointClicksTab,'Style','slider','String','Choose Box Size',...
                'Units','Normalized','Position',[.13 .36 .15 .04],'fontsize',12,'Min',5,'Max',200,'Value',30,'SliderStep',[1/200 10/200],'Callback',@app.CallbackSliderBoxSize);
            app.PushButtonProceedVideo2 = uicontrol('Parent',app.JointClicksTab,'Style','pushbutton','String','Proceed to Video 2',...
                'Units','Normalized','Position',[.13 .3 .18 .06],'fontsize',16,'Callback',@app.CallbackPushButtonProceedVideo2);
            app.PushButtonNextStep4 = uicontrol('Parent',app.JointClicksTab,'Style','pushbutton','String','Next Step',...
                'Units','Normalized','Position',[.13 .2 .18 .06],'fontsize',16,'Callback',@app.CallbackPushButtonNextStep4);
            
            %% 5 - ReferenceDistanceTab UI Controls
            app.TextBigFive = uicontrol('Parent',app.ReferenceDistanceTab,'Style','text','String','5',...
                'Units','Normalized','Position',[.03 .8 .1 .15],'fontsize',70);
            app.TextChooseReferenceDistance = uicontrol('Parent',app.ReferenceDistanceTab,'Style','text','String','Choose Reference Distance',...
                'Units','Normalized','Position',[.13 .82 .2 .1],'fontsize',20);
            app.AxReferenceDistance = axes('Parent',app.ReferenceDistanceTab,'TickLength',[0 0],'XTickLabel',''...
                ,'YTickLabel','','Position',[.42 0 .4 .95]);
            app.EditReferenceDistance = uicontrol('Parent',app.ReferenceDistanceTab,'Style','edit','String','Enter Reference Distance (m)',...
                'Units','Normalized','Position',[.13 .75 .18 .06],'fontsize',12,'Callback',@app.CallbackEditReferenceDistance);
            app.PushButtonReferenceDistance = uicontrol('Parent',app.ReferenceDistanceTab,'Style','pushbutton','String','Click Reference(1st Video)',...
                'Units','Normalized','Position',[.1 .66 .25 .06],'fontsize',16,'Callback',@app.CallbackPushButtonReferenceDistance);
            app.WeightEntry = uicontrol('Parent',app.ReferenceDistanceTab,'Style','edit','String','Enter Subjects''s Weight (lb)',...
                'Units','Normalized','Position',[.12 .56 .2 .06],'fontsize',12,'Callback',@app.CallbackEditWeight);
            %app.HeightEntry = uicontrol('Parent',app.ReferenceDistanceTab,'Style','edit','String','Enter Subject''s Height (in)',...
            %    'Units','Normalized','Position',[.12 .46 .2 .06],'fontsize',12,'Callback',@app.CallbackEditHeight);
            app.PushButtonRunAnalysis = uicontrol('Parent',app.ReferenceDistanceTab,'Style','pushbutton','String','Run Analysis',...
                'Units','Normalized','Position',[.13 .3 .18 .06],'fontsize',16,'Callback',@app.CallbackPushButtonRunAnalysis);
            
            %% 6 - Verification UI Controls / Objects
             app.AxLeftShowVerificationTab = axes('Parent',app.VerificationTab...
                 ,'Position',[.18 .55 .8 .4]);
             xlabel('Time (s)')
             
             app.AxRightShowVerificationTab = axes('Parent',app.VerificationTab...
                 ,'Position',[.18 .05 .8 .4]);
             xlabel('Time (s)')
             
             app.PushButtonSaveGRF = uicontrol('Parent',app.VerificationTab,'Style','pushbutton','String','Save Forces to .xlsx',...
                'Units','Normalized','Position',[.05 .66 .10 .06],'fontsize',12,'Callback',@app.CallbackPushButtonSaveGRF);
             app.PushButtonSavePowerEnergy = uicontrol('Parent',app.VerificationTab,'Style','pushbutton','String','Save Power &/or Energy',...
                'Units','Normalized','Position',[.05 .46 .10 .06],'fontsize',12,'Callback',@app.CallbackPushButtonSavePowerEnergy);
             
        end
        
        
        %% WelcomeTab Callbacks
        function CallbackPushButtonConfigMainTab(app,~,~)
            app.TabGroup.SelectedTab = app.ChooseConfigTab;
            app.PushButtonNextStep2.Visible = 'off';
            app.PushButtonNextStep3.Visible = 'off'; 
            app.PushButtonNextStep4.Visible = 'off';
            app.PushButtonRunAnalysis.Visible = 'off';
        end
        
        
        %% 1 ChooseConfigTab Callbacks
        %Method on ForceTrak, 
        function CallbackPushButtonNextStep1(app,~,~)
            %app.colorconfig = app.ListBoxChooseMarkerColor.Value;
            app.videonum = app.ListBoxChooseVidNum.Value;
           
            if app.videonum == 1
                app.PushButtonVideo2.Visible = 'off';
                app.PushButtonVideo1.Position = [.4 .6 .2 .06];
                app.LOADED1.Position = [.45 .54 .1 .03];
                app.LOADED1.Visible = 'off';
                app.LOADED2.Visible = 'off';
                app.PushButtonProceedVideo2.Visible = 'off';
                
            elseif app.videonum == 2
                app.PushButtonProceedVideo2.Visible = 'on';
                app.PushButtonVideo2.Visible = 'on';
                app.PushButtonVideo1.Position = [.25 .6 .2 .06];
            end
            
            app.TabGroup.SelectedTab = app.LoadVideosTab;
        end
        
        %% 2 LoadVideo'sTab Callbacks
        function CallbackPushButtonVideo1(app,~,~)
            [vidname, pathname] = uigetfile('*');
            vidname = strcat(pathname,vidname);
            app.vidname = vidname;
            app.vid1 = VideoReader(vidname);
            app.LOADED1.Visible = 'on';
            if app.videonum == 1
                app.PushButtonNextStep2.Visible = 'on';
            end
        end
        
        function CallbackPushButtonVideo2(app,~,~)
            [vidname, pathname] = uigetfile('*');
            vidname = strcat(pathname,vidname);
            app.vidname2 = vidname;
            app.vid2 = VideoReader(vidname);
            app.LOADED2.Visible = 'on';
            app.PushButtonNextStep2.Visible = 'on';
        end
        
        function CallbackPushButtonNextStep2(app,~,~)
            app.SliderFrameSelection.Max = round(app.vid1.NumberOfFrames);
            app.SliderFrameSelection.SliderStep = [1/round((app.vid1.NumberOfFrames-1)) 10/round((app.vid1.NumberOfFrames-1))];
            im = read(app.vid1,1);
            
            imshow(im,'Parent',app.axframeselection)
            app.TabGroup.SelectedTab = app.ChooseStartFrameTab;
            if app.ListBoxFramesPerSecond.Value == 1
                app.FramesPerSecond = 120;
            else
                app.FramesPerSecond = 240;
            end
        end
        
        %% 3 ChooseStartFrameTab Callbacks
        function CallbackSliderFrameSelection(app,~,~)
            %Getting error on one specific video, CANNOT figure out why,
            %The issue is the variable "app.SliderFrameSelection.Value" is
            %not being fed in as a whole number, thust the following two
            %lines of code were added to ensure the value is the right
            %class
            app.SliderFrameSelection.Value = int8(app.SliderFrameSelection.Value);
            %app.SliderFrameSelection.Value = double(app.SliderFrameSelection.Value);
            im = read(app.vid1,app.SliderFrameSelection.Value);
            app.TextCurrentFrame.String = strcat('Current Frame: ',num2str(round(app.SliderFrameSelection.Value)));
            im = rot90(im,app.rot_num);
            imshow(im,'Parent',app.axframeselection)
        end
        
        function CallbackPushButtonRotateVid(app,~,~)
            app.rot_num = app.rot_num + 1;
            im = read(app.vid1,app.SliderFrameSelection.Value);
            im = rot90(im,app.rot_num);
            imshow(im,'Parent',app.axframeselection)
        end
        
        
        function CallbackPushButtonChooseStartFrame(app,~,~)
            if strcmp(app.PushButtonChooseStartFrame.String,'Choose Start Frame') == 1
                app.StartFrame = round(app.SliderFrameSelection.Value);
                app.TextStartFrame.String = strcat('Start Frame:',num2str(app.StartFrame));
                app.PushButtonChooseStartFrame.String = 'Choose End Frame';
            elseif strcmp(app.PushButtonChooseStartFrame.String,'Choose End Frame') == 1
                app.EndFrame = round(app.SliderFrameSelection.Value);
                app.TextEndFrame.String = strcat('End Frame:',num2str(app.EndFrame));
                app.PushButtonChooseStartFrame.String = 'Choose Start Frame';
                app.PushButtonNextStep3.Visible = 'on';
            end
        end
        
        
        function CallbackPushButtonNextStep3(app,~,~)
            if app.videonum==2
                im2 = read(app.vid2,1);
                imshow(im2,'Parent',app.axrotatevid2)
                app.im = read(app.vid1,app.StartFrame);
                app.im = rot90(app.im,app.rot_num);
                imshow(app.im,'Parent',app.axjointclicks)
                app.TabGroup.SelectedTab = app.RotateSecondVideoTab;
            else
                app.im = read(app.vid1,app.StartFrame);
                app.im = rot90(app.im,app.rot_num);
                imshow(app.im,'Parent',app.axjointclicks)
                app.TabGroup.SelectedTab = app.JointClicksTab;
            end
        end

        
        
        %% 3.5 RotateVideo2Tab
        
        function CallbackPushButtonRotateVid2(app,~,~)
             app.rot_num2 = app.rot_num2 + 1;
            im = read(app.vid2,1);
            im = rot90(im,app.rot_num2);
            imshow(im,'Parent',app.axrotatevid2)
        end
        
        
        function CallbackPushButtonNextStep35(app,~,~)
            app.TabGroup.SelectedTab = app.JointClicksTab;
        end
        
        
        %% 4 ClickJointsTab
        %<><><><><>< THIS METHOD IS WHERE I CAN INCORPORATE <><><<><><><><
        %THE INITIAL TRIG CALCULATIONS FOR TRIANGULATING POSITION OF KNEW
        %HIP AND THIGH FOR THE OCCULTATION RESOLUTION
        
        
        function CallbackPushButtonClickJoints(app,~,~)
            
            zoom off
            app.PushButtonZoom.String = 'Zoom: Off';
            
             if app.currentvid == 1
                app.nummark = app.checkboxshoulder.Value + app.checkboxelbow.Value + app.checkboxwrist.Value...
                    + app.checkboxhip.Value + app.checkboxthigh.Value + app.checkboxknee.Value + app.checkboxankle.Value + app.checkboxfoot.Value;
                
                %Contains Logical 1 or 0 (Yes Click this joint, or No do not)
                clickthisjoint = [app.checkboxshoulder.Value app.checkboxelbow.Value app.checkboxwrist.Value...
                    app.checkboxhip.Value app.checkboxthigh.Value app.checkboxknee.Value app.checkboxankle.Value app.checkboxfoot.Value];
                
                
                %Rerturns jointschosen - that is, only the logical 1's
                %associated with click this joint, and the associated joint
                %name in the cell array below
                jointname = {'Shoulder' 'Elbow' 'Wrist' 'Hip' 'Thigh' 'Knee' 'Ankle' 'Foot'};
                
                %***********************************************
                %HELPFUL REFERENCE:
                %***********************************************
                %JOINTS CHOSEN --> will place a [1, 2, 3, 4, 5, 6, 7, 8]
                %Shoulder = 1;
                %Elbow = 2;
                %Wrist = 3;
                %Hip = 4;
                %Thigh = 5;
                %Knee = 6;
                %Ankle = 7;
                %Foot = 8;
                %***********************************************
                
                %Set up marker class shells (will only keep necessary
                %shells for the final markers chosen)
                Shoulder = marker(0,0);
                Shoulder = valueselected(Shoulder,app.checkboxshoulder.Value);
                Shoulder = SetMarkerName(Shoulder,char(jointname(1)));
                Shoulder = pickjointnum(Shoulder,1);
                Elbow = marker(0,0);
                Elbow = valueselected(Elbow,app.checkboxelbow.Value);
                Elbow = SetMarkerName(Elbow,char(jointname(2)));
                Elbow = pickjointnum(Elbow,2);
                Wrist = marker(0,0);
                Wrist = valueselected(Wrist,app.checkboxwrist.Value);
                Wrist = SetMarkerName(Wrist,char(jointname(3)));
                Wrist = pickjointnum(Wrist,3);
                Hip = marker(0,0);
                Hip = valueselected(Hip,app.checkboxhip.Value);
                Hip = SetMarkerName(Hip,char(jointname(4)));
                Hip = pickjointnum(Hip,4);
                Thigh = marker(0,0);
                Thigh = valueselected(Thigh,app.checkboxthigh.Value);
                Thigh = SetMarkerName(Thigh,char(jointname(5)));
                Thigh = pickjointnum(Thigh,5);
                Knee = marker(0,0);
                Knee = valueselected(Knee,app.checkboxknee.Value);
                Knee = SetMarkerName(Knee,char(jointname(6)));
                Knee = pickjointnum(Knee,6);
                Ankle = marker(0,0);
                Ankle = valueselected(Ankle,app.checkboxankle.Value);
                Ankle = SetMarkerName(Ankle,char(jointname(7)));
                Ankle = pickjointnum(Ankle,7);
                Foot = marker(0,0);
                Foot = valueselected(Foot,app.checkboxfoot.Value);
                Foot = SetMarkerName(Foot,char(jointname(8)));
                Foot = pickjointnum(Foot,8);
                
                %This determines which markers are selected
                %and stores them in markerarray1
                %markerarray1 is an array of markers with the
                %joint names, nums, and selections all initialized
                holder = [Shoulder,Elbow,Wrist,Hip,Thigh,Knee,Ankle];
                markerarray1 = [];
                a = 1;
                indexarray = 0;
                for i = 1:length(holder)
                    if holder(i).markerselected == 1
                        markerarray1 = [markerarray1,holder(i)];
                        displayjoint(a) = jointname(i);
                        jointschosen(a) = i;
                        
                        %determine indexing values for occulation
                        if markerarray1(a).jointnum == 3
                            markerarray1(a) = SetIndex(markerarray1(a),a);
                            indexarray = a;
                            app.wristindex = a;
                            wrist = a;
                        elseif markerarray1(a).jointnum == 4
                            markerarray1(a) = SetIndex( markerarray1(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.hipindex = a;
                            hip = a;
                        elseif markerarray1(a).jointnum == 5
                            markerarray1(a) = SetIndex( markerarray1(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.thighindex = a;
                            thigh = a;
                        elseif markerarray1(a).jointnum == 6
                            markerarray1(a) = SetIndex( markerarray1(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.kneeindex = a;
                            knee = a;
                        end
                        
                        a = a + 1;
                    end
                end
                
                
                %determine if occultation will be used for the tracking on
                %this particular video.  Occultation Calculations are 
                %only intialized if the necessary joints are clicked
                if any(find(jointschosen == 3)) && any(find(jointschosen == 4))&&any(find(jointschosen == 5))&& any(find(jointschosen == 6))
                    OccultationData1 = OccultationCalc(4);
                    OccultationData1 = SetIndexArray(OccultationData1,indexarray);
                elseif any(find(jointschosen == 4))&&any(find(jointschosen == 5))&& any(find(jointschosen == 6))
                    OccultationData1 = OccultationCalc(3);
                    OccultationData1 = SetIndexArray(OccultationData1,indexarray);
                else
                    OccultationData1 = OccultationCalc(0);
                end
                
                      
%                 %associating the joints with numerical values (used below)
%                 a = 1;
%                 for i = 1:length(clickthisjoint)
%                     
%                     if clickthisjoint(i) == 1
%                         displayjoint(a) = jointname(i);
%                         jointschosen(a) = i;
%                         a = a + 1;
%                     end
%                 end
                %Defines  the jointchosen object
                app.jointschosen1 = jointschosen;
                
                
                %Sets up first click of marker (no zoom)
                for i = 1:length(markerarray1)
                    str = strcat('Click-',markerarray1(i).markername);
                    totalstr = strcat(str,'-Marker');
                    displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
                        'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
                    
                    [x(i,1),y(i,1)] = ginput(1); %<--- Graphical input from mouse click
                    delete(displaytext)
                end
                
                
                
%                 for i = 1:app.nummark
%                     str = strcat('Click-',displayjoint(i));
%                     totalstr = strcat(str,'-Marker');
%                     displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
%                         'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
%                     
%                     [x(i,1),y(i,1)] = ginput(1); %<--- Graphical input from mouse click
%                     
%                 end
%                 



                %Sets up second click of marker
                for i = 1:length(markerarray1)
                    str = strcat('Precisely Click-',markerarray1(i).markername);
                    totalstr = strcat(str,'-Marker');
                    displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
                        'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);

                    delete(app.axjointclicks)
                    app.axjointclicks = axes('Parent',app.JointClicksTab,'TickLength',[0 0],'XTickLabel',''...
                        ,'YTickLabel','','Position',[.42 0 .4 .95]);

                    % Draws up the "Precise" click box (need to fix out of
                    % bounds search area)
                    imshow(app.im( round((y(i,1)-30)):round((y(i,1)+30)) , round((x(i,1)-30)):round((x(i,1)+30)) , 1:3 ) )
                    [x2(i,1),y2(i,1)] = ginput(1);

                    %Adjust the x,y coordinates to correct frame
                    x2(i,1) = x2(i,1) + (x(i,1)-30); %<--- starting x, y coords
                    y2(i,1) = y2(i,1) + (y(i,1)-30); %<--- starting x, y coords
                    
                    %Finally assign x2,y2 coordinates to first marker in
                    %marker class
                    markerarray1(i) = reassign(markerarray1(i),x2(i,1),y2(i,1));
                end
                
                %Set property
                app.markerarray1 = markerarray1; %<---- initial Marker Data
                
                %THESE VALUES ARE then reassigned into .output1 below
                app.markerclicks1 = [y2,x2]; %<--- Storing Initial Marker Coordinates (y,x)
                
                %Set up initial Occultation Geometry if necessary:
                if OccultationData1.OccultBoolWithWrist == 1
                    OccultationData1 = KneeHipThighCalc(OccultationData1,markerarray1(knee),markerarray1(hip),markerarray1(thigh),markerarray1(wrist));
                elseif OccultationData1.OccultBoolNoWrist == 1
                   OccultationData1 = KneeHipThighCalc(OccultationData1,markerarray1(knee),markerarray1(hip),markerarray1(thigh));
                end
                app.OccultationData1 = OccultationData1;
                
                
%                 for i = 1:app.nummark
% 
%                     str = strcat('Precisely Click-',displayjoint(i));
%                     totalstr = strcat(str,'-Marker');
%                     displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
%                 'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
%                     
%                     delete(app.axjointclicks)
%                     app.axjointclicks = axes('Parent',app.JointClicksTab,'TickLength',[0 0],'XTickLabel',''...
%                 ,'YTickLabel','','Position',[.42 0 .4 .95]);
%                     
%                     % Draws up the "Precise" click box (need to fix out of
%                     % bounds search area)
%                     imshow(app.im( round((y(i,1)-30)):round((y(i,1)+30)) , round((x(i,1)-30)):round((x(i,1)+30)) , 1:3 ) )
%                     [x2(i,1),y2(i,1)] = ginput(1);
%                     
%                     x2(i,1) = x2(i,1) + (x(i,1)-30); %<--- starting x, y coords
%                     y2(i,1) = y2(i,1) + (y(i,1)-30); %<--- starting x, y coords
%                     
%                     %***********************************************
%                     %***********************************************
%                     %***********************************************
%                     %Set up marker initial coordinates
%                     %initialized in the markerarry the actual joints
%                     %that are chosen
%                     %***********************************************
%                     for j = 1:length(markerarray1)
%                         if markerarray1(j).jointnum == jointschosen(i)
%                             markerarray1(j) = reassign(markerarray1(j),x2(i,1),y2(i,1));
%                         end
%                     end
%                     %***********************************************
%                     %***********************************************
%                     %***********************************************
%                     
%                     
%                 end
                
                %***********************************************
                %***********************************************
                %***********************************************
                %Call HipKneeThighCalc intialized data for 
                %occultation and define markerarray1
                %***********************************************
%                 holder = 0;
%                 for j = 1:length(markerarray1)
%                     if isequal(markerarray1(j).markername,'Knee')
%                         Knee = markerarray1(j);
%                         holder = holder + 1;
%                     elseif isequal(markerarray1(j).markername,'Hip')
%                         Hip = markerarray1(j);
%                         holder = holder + 1;       
%                     elseif isequal(markerarray1(j).markername, 'Thigh')
%                         Thigh = markerarray1(j);
%                         holder = holder + 1;
%                     end
%                 end
%                 if holder == 3
%                     app.occultationdata = HipKneeThighCalc(Knee,Hip,Thigh);
%                 end
               
% %****************************************************************
% %****************************************************************
%                 %Calculating distance between hip marker and thigh marker
%                 %jointschosen1 is the list of joints, not sure why '4' and
%                 %'5', but very likely that the joints have been given a
%                 %numeric reference at this point.
%                 app.hipindex = find(app.jointschosen1 == 4);
%                 app.thighindex = find(app.jointschosen1 == 5);
%                 app.kneeindex = find(app.jointschosen1 == 3);
%                 
%                 % Length between (distance formula)
%                 % Logical, that determines whether the hip and thigh have
%                 % been clicked. <><><><> %NOT SURE WHY THIS IS HERE!!!
%                 if isempty(app.hipindex) == 0 && isempty(app.thighindex) == 0
%                     app.length_Thigh_Hip1 = sqrt((app.markerclicks1(app.hipindex,1) - app.markerclicks1(app.thighindex,1))^2 + (app.markerclicks1(app.hipindex,2) - app.markerclicks1(app.thighindex,2))^2 );
%                 end
% %****************************************************************
% %****************************************************************
                
                %app.boxDist == 30 currently
                %this is drawing the blue boxes around the markers on the
                %forcetrak main screen
                boxDist = app.boxDist;
                hold off
                imshow(app.im,'Parent',app.axjointclicks)
                j = 1;
                for i = 1:app.nummark
                    app.ln(i,j) = line([x2(i)-boxDist,x2(i)-boxDist],[y2(i)+boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+1,j) = line([x2(i)+boxDist,x2(i)+boxDist],[y2(i)+boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+2,j) = line([x2(i)-boxDist,x2(i)+boxDist],[y2(i)-boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+3,j) = line([x2(i)-boxDist,x2(i)+boxDist],[y2(i)+boxDist,y2(i)+boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    hold on
                    j = j + 1;
                end
                
                [app.hsvthresh] = improc.returnThreshold(app.im,app.markerclicks1,app.nummark,'all_values');
                %[app.unitvecthresh] = improc.returnThreshold(app.im,app.markerclicks1,app.nummark,'unitvec');
                if app.videonum == 1
                app.PushButtonNextStep4.Visible = 'on';
                end

%-------------------------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------
%EDIT HERE <--- NEED MARKERARRAY2 AND OCCULATIONDATA2 SETUP
%-------------------------------------------------------------------
%-------------------------------------------------------------------
%-------------------------------------------------------------------
            elseif app.currentvid == 2
                   
                %Contains Logical 1 or 0 (Yes Click this joint, or No do not)
                clickthisjoint = [app.checkboxshoulder.Value app.checkboxelbow.Value app.checkboxwrist.Value...
                    app.checkboxhip.Value app.checkboxthigh.Value app.checkboxknee.Value app.checkboxankle.Value app.checkboxfoot.Value];
                
                %Rerturns jointschosen - that is, only the logical 1's
                %associated with click this joint, and the associated joint
                %name in the cell array below
                jointname = {'Shoulder' 'Elbow' 'Wrist' 'Hip' 'Thigh' 'Knee' 'Ankle' 'Foot'};
                
                %***********************************************
                %HELPFUL REFERENCE:
                %***********************************************
                %JOINTS CHOSEN --> will place a [1, 2, 3, 4, 5, 6, 7, 8]
                %Shoulder = 1;
                %Elbow = 2;
                %Wrist = 3;
                %Hip = 4;
                %Thigh = 5;
                %Knee = 6;
                %Ankle = 7;
                %Foot = 8;
                %***********************************************
                
                %Set up marker class shells (will only keep necessary
                %shells for the final markers chosen)
                Shoulder = marker(0,0);
                Shoulder = valueselected(Shoulder,app.checkboxshoulder.Value);
                Shoulder = SetMarkerName(Shoulder,char(jointname(1)));
                Shoulder = pickjointnum(Shoulder,1);
                Elbow = marker(0,0);
                Elbow = valueselected(Elbow,app.checkboxelbow.Value);
                Elbow = SetMarkerName(Elbow,char(jointname(2)));
                Elbow = pickjointnum(Elbow,2);
                Wrist = marker(0,0);
                Wrist = valueselected(Wrist,app.checkboxwrist.Value);
                Wrist = SetMarkerName(Wrist,char(jointname(3)));
                Wrist = pickjointnum(Wrist,3);
                Hip = marker(0,0);
                Hip = valueselected(Hip,app.checkboxhip.Value);
                Hip = SetMarkerName(Hip,char(jointname(4)));
                Hip = pickjointnum(Hip,4);
                Thigh = marker(0,0);
                Thigh = valueselected(Thigh,app.checkboxthigh.Value);
                Thigh = SetMarkerName(Thigh,char(jointname(5)));
                Thigh = pickjointnum(Thigh,5);
                Knee = marker(0,0);
                Knee = valueselected(Knee,app.checkboxknee.Value);
                Knee = SetMarkerName(Knee,char(jointname(6)));
                Knee = pickjointnum(Knee,6);
                Ankle = marker(0,0);
                Ankle = valueselected(Ankle,app.checkboxankle.Value);
                Ankle = SetMarkerName(Ankle,char(jointname(7)));
                Ankle = pickjointnum(Ankle,7);
                Foot = marker(0,0);
                Foot = valueselected(Foot,app.checkboxfoot.Value);
                Foot = SetMarkerName(Foot,char(jointname(8)));
                Foot = pickjointnum(Foot,8);
                
                %This determines which markers are selected
                %and stores them in markerarray1
                %markerarray2 is an array of markers with the
                %joint names, nums, and selections all initialized
                holder = [Shoulder,Elbow,Wrist,Hip,Thigh,Knee,Ankle];
                markerarray2 = [];
                a = 1;
                indexarray = 0;
                for i = 1:length(holder)
                    if holder(i).markerselected == 1
                        markerarray2 = [markerarray2,holder(i)];
                        displayjoint(a) = jointname(i);
                        jointschosen(a) = i;
                        
                        %determine indexing values for occulation
                        if markerarray2(a).jointnum == 3
                            markerarray2(a) = SetIndex(markerarray2(a),a);
                            indexarray = a;
                            app.wristindex = a;
                            wrist = a;
                        elseif markerarray2(a).jointnum == 4
                            markerarray2(a) = SetIndex( markerarray2(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.hipindex = a;
                            hip = a;
                        elseif markerarray2(a).jointnum == 5
                            markerarray2(a) = SetIndex( markerarray2(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.thighindex = a;
                            thigh = a;
                        elseif markerarray2(a).jointnum == 6
                            markerarray2(a) = SetIndex( markerarray2(a),a);
                            if indexarray == 0
                                indexarray = a;
                            else
                                indexarray(end+1) = a;
                            end
                            app.kneeindex = a;
                            knee = a;
                        end
                        
                        a = a + 1;
                    end
                end
                
                
                %determine if occultation will be used for the tracking on
                %this particular video.  Occultation Calculations are 
                %only intialized if the necessary joints are clicked
                if any(find(jointschosen == 3)) && any(find(jointschosen == 4))&&any(find(jointschosen == 5))&& any(find(jointschosen == 6))
                    OccultationData2 = OccultationCalc(4);
                    OccultationData2 = SetIndexArray(OccultationData2,indexarray);
                elseif any(find(jointschosen == 4))&&any(find(jointschosen == 5))&& any(find(jointschosen == 6))
                    OccultationData2 = OccultationCalc(3);
                    OccultationData2 = SetIndexArray(OccultationData2,indexarray);
                else
                    OccultationData2 = OccultationCalc(0);
                end
                
                      
%                 %associating the joints with numerical values (used below)
%                 a = 1;
%                 for i = 1:length(clickthisjoint)
%                     
%                     if clickthisjoint(i) == 1
%                         displayjoint(a) = jointname(i);
%                         jointschosen(a) = i;
%                         a = a + 1;
%                     end
%                 end
                %Defines  the jointchosen object
                app.jointschosen2 = jointschosen;
                
                
                %Sets up first click of marker (no zoom)
                for i = 1:length(markerarray2)
                    str = strcat('Click-',markerarray2(i).markername);
                    totalstr = strcat(str,'-Marker');
                    displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
                        'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
                    
                    [x(i,1),y(i,1)] = ginput(1); %<--- Graphical input from mouse click
                    delete(displaytext)
                end
                
                
                
%                 for i = 1:app.nummark
%                     str = strcat('Click-',displayjoint(i));
%                     totalstr = strcat(str,'-Marker');
%                     displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
%                         'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
%                     
%                     [x(i,1),y(i,1)] = ginput(1); %<--- Graphical input from mouse click
%                     
%                 end
%                 



                %Sets up second click of marker
                for i = 1:length(markerarray2)
                    str = strcat('Precisely Click-',markerarray2(i).markername);
                    totalstr = strcat(str,'-Marker');
                    displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
                        'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);

                    delete(app.axjointclicks)
                    app.axjointclicks = axes('Parent',app.JointClicksTab,'TickLength',[0 0],'XTickLabel',''...
                        ,'YTickLabel','','Position',[.42 0 .4 .95]);

                    % Draws up the "Precise" click box (need to fix out of
                    % bounds search area)
                    imshow(app.im( round((y(i,1)-30)):round((y(i,1)+30)) , round((x(i,1)-30)):round((x(i,1)+30)) , 1:3 ) )
                    [x2(i,1),y2(i,1)] = ginput(1);

                    %Adjust the x,y coordinates to correct frame
                    x2(i,1) = x2(i,1) + (x(i,1)-30); %<--- starting x, y coords
                    y2(i,1) = y2(i,1) + (y(i,1)-30); %<--- starting x, y coords
                    
                    %Finally assign x2,y2 coordinates to first marker in
                    %marker class
                    markerarray2(i) = reassign(markerarray2(i),x2(i,1),y2(i,1));
                end
                
                %Set property
                app.markerarray2 = markerarray2; %<---- initial Marker Data
                
                %THESE VALUES ARE then reassigned into .output1 below
                app.markerclicks2 = [y2,x2]; %<--- Storing Initial Marker Coordinates (y,x)
                
                %Set up initial Occultation Geometry if necessary:
                if OccultationData2.OccultBoolWithWrist == 1
                    OccultationData2 = KneeHipThighCalc(OccultationData2,markerarray2(knee),markerarray2(hip),markerarray2(thigh),markerarray2(wrist));
                elseif OccultationData2.OccultBoolNoWrist == 1
                   OccultationData2 = KneeHipThighCalc(OccultationData2,markerarray2(knee),markerarray2(hip),markerarray2(thigh));
                end
                app.OccultationData2 = OccultationData2;
                
                
%                 for i = 1:app.nummark
% 
%                     str = strcat('Precisely Click-',displayjoint(i));
%                     totalstr = strcat(str,'-Marker');
%                     displaytext = uicontrol('Parent',app.JointClicksTab,'Style','text','String',totalstr,...
%                 'Units','Normalized','Position',[.41 .95 .45 .04],'fontsize',22);
%                     
%                     delete(app.axjointclicks)
%                     app.axjointclicks = axes('Parent',app.JointClicksTab,'TickLength',[0 0],'XTickLabel',''...
%                 ,'YTickLabel','','Position',[.42 0 .4 .95]);
%                     
%                     % Draws up the "Precise" click box (need to fix out of
%                     % bounds search area)
%                     imshow(app.im( round((y(i,1)-30)):round((y(i,1)+30)) , round((x(i,1)-30)):round((x(i,1)+30)) , 1:3 ) )
%                     [x2(i,1),y2(i,1)] = ginput(1);
%                     
%                     x2(i,1) = x2(i,1) + (x(i,1)-30); %<--- starting x, y coords
%                     y2(i,1) = y2(i,1) + (y(i,1)-30); %<--- starting x, y coords
%                     
%                     %***********************************************
%                     %***********************************************
%                     %***********************************************
%                     %Set up marker initial coordinates
%                     %initialized in the markerarry the actual joints
%                     %that are chosen
%                     %***********************************************
%                     for j = 1:length(markerarray1)
%                         if markerarray1(j).jointnum == jointschosen(i)
%                             markerarray1(j) = reassign(markerarray1(j),x2(i,1),y2(i,1));
%                         end
%                     end
%                     %***********************************************
%                     %***********************************************
%                     %***********************************************
%                     
%                     
%                 end
                
                %***********************************************
                %***********************************************
                %***********************************************
                %Call HipKneeThighCalc intialized data for 
                %occultation and define markerarray1
                %***********************************************
%                 holder = 0;
%                 for j = 1:length(markerarray1)
%                     if isequal(markerarray1(j).markername,'Knee')
%                         Knee = markerarray1(j);
%                         holder = holder + 1;
%                     elseif isequal(markerarray1(j).markername,'Hip')
%                         Hip = markerarray1(j);
%                         holder = holder + 1;       
%                     elseif isequal(markerarray1(j).markername, 'Thigh')
%                         Thigh = markerarray1(j);
%                         holder = holder + 1;
%                     end
%                 end
%                 if holder == 3
%                     app.occultationdata = HipKneeThighCalc(Knee,Hip,Thigh);
%                 end
               
% %****************************************************************
% %****************************************************************
%                 %Calculating distance between hip marker and thigh marker
%                 %jointschosen1 is the list of joints, not sure why '4' and
%                 %'5', but very likely that the joints have been given a
%                 %numeric reference at this point.
%                 app.hipindex = find(app.jointschosen1 == 4);
%                 app.thighindex = find(app.jointschosen1 == 5);
%                 app.kneeindex = find(app.jointschosen1 == 3);
%                 
%                 % Length between (distance formula)
%                 % Logical, that determines whether the hip and thigh have
%                 % been clicked. <><><><> %NOT SURE WHY THIS IS HERE!!!
%                 if isempty(app.hipindex) == 0 && isempty(app.thighindex) == 0
%                     app.length_Thigh_Hip1 = sqrt((app.markerclicks1(app.hipindex,1) - app.markerclicks1(app.thighindex,1))^2 + (app.markerclicks1(app.hipindex,2) - app.markerclicks1(app.thighindex,2))^2 );
%                 end
% %****************************************************************
% %****************************************************************
                
                %app.boxDist == 30 currently
                %this is drawing the blue boxes around the markers on the
                %forcetrak main screen
                boxDist = app.boxDist;
                hold off
                imshow(app.im,'Parent',app.axjointclicks)
                j = 1;
                for i = 1:app.nummark
                    app.ln(i,j) = line([x2(i)-boxDist,x2(i)-boxDist],[y2(i)+boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+1,j) = line([x2(i)+boxDist,x2(i)+boxDist],[y2(i)+boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+2,j) = line([x2(i)-boxDist,x2(i)+boxDist],[y2(i)-boxDist,y2(i)-boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    app.ln(i+3,j) = line([x2(i)-boxDist,x2(i)+boxDist],[y2(i)+boxDist,y2(i)+boxDist],'LineWidth',2,'Parent',app.axjointclicks);
                    hold on
                    j = j + 1;
                end
                
                %Make next button visible
                app.PushButtonNextStep4.Visible = 'on';

                                        
            end
            
        end
        
        
        %<><><> boxDist Function used above in
        %CallbackPushButtonClickJoints method <---- seems to be repeated from above 
        function CallbackSliderBoxSize(app,~,~)
            app.boxDist = round(app.SliderBoxSize.Value);
            
            boxDist = app.boxDist;
            x = app.markerclicks1(:,2);
            y = app.markerclicks1(:,1);
            hold off
            imshow(app.im,'Parent',app.axjointclicks)
            j = 1;
            for i = 1:app.nummark
                app.ln(i,j) = line([x(i)-boxDist,x(i)-boxDist],[y(i)+boxDist,y(i)-boxDist],'LineWidth',2);
                app.ln(i+1,j) = line([x(i)+boxDist,x(i)+boxDist],[y(i)+boxDist,y(i)-boxDist],'LineWidth',2);
                app.ln(i+2,j) = line([x(i)-boxDist,x(i)+boxDist],[y(i)-boxDist,y(i)-boxDist],'LineWidth',2);
                app.ln(i+3,j) = line([x(i)-boxDist,x(i)+boxDist],[y(i)+boxDist,y(i)+boxDist],'LineWidth',2);
                j = j + 1;
                hold on
            end
        end
        
        
        function CallbackPushButtonProceedVideo2(app,~,~)
            
            if app.currentvid == 1
                fps = app.vid1.FrameRate;
                app.StartFrame2 = vidsync(app.StartFrame,app.vidname,app.vidname2,fps);
                app.im = read(app.vid2,app.StartFrame2);
                
                app.im = rot90(app.im,app.rot_num2);
                
                for ii=1:3
                    app.im(:,:,ii) = fliplr(app.im(:,:,ii));
                end
                
                imshow(app.im,'Parent',app.axjointclicks)
                app.currentvid = 2;
                app.PushButtonProceedVideo2.String = 'Go to Video 1';
                
            elseif app.currentvid == 2
                app.im = read(app.vid1,app.StartFrame);
                app.im = rot90(app.im,app.rot_num);
                imshow(app.im,'Parent',app.axjointclicks)
                app.currentvid = 1;
                app.PushButtonProceedVideo2.String = 'Go to Video 2';
            end
            
        end
        
        
        function CallbackPushButtonNextStep4(app,~,~)
            app.im = read(app.vid1,app.StartFrame);
            app.im = rot90(app.im,app.rot_num);
            app.currentvid = 1;
            imshow(app.im,'Parent',app.AxReferenceDistance)
            app.TabGroup.SelectedTab = app.ReferenceDistanceTab;
            
        end
        
        
        
        %% ReferenceDistanceTab Callbacks
        
        function CallbackEditReferenceDistance(app,~,~)
            app.refdist = str2double(app.EditReferenceDistance.String);
            app.SubjectHeight = 0;
            app.SubjectWeight = 0;
        end
              
        function CallbackPushButtonReferenceDistance(app,~,~)
            
            if strcmp(app.EditReferenceDistance.String,'Enter Reference Distance (m)') ~= 1
                
                if app.currentvid == 1
                    app.im = read(app.vid1,app.StartFrame);
                    app.im = rot90(app.im,app.rot_num);
                    imshow(app.im,'Parent',app.AxReferenceDistance)
                    hold on
                    title(app.AxReferenceDistance,'Please click on reference markers -- Left to Right','Fontsize',16)
                    [x,y] = ginput(2);
                    dist = sqrt((x(1)-x(2))^2+(y(1)-y(2))^2);
                    app.pxtom = dist/app.refdist;
                    app.refang = atan((y(2)-y(1))/(x(2)-x(1)));
                    app.refp1 = [x(1),y(1)];
                    
                    if app.videonum == 2
                        app.currentvid = 2;
                        app.PushButtonReferenceDistance.String = 'Click 2nd References';
                    end
                    
                    if app.videonum == 1
                    app.PushButtonRunAnalysis.Visible = 'on';
                    end
                    
                elseif app.currentvid == 2
                    
                    app.im = read(app.vid2,app.StartFrame2);
                    app.im = rot90(app.im,app.rot_num2);
                    imshow(app.im,'Parent',app.AxReferenceDistance)
                    for i=1:3
                        app.im(:,:,i) = fliplr(app.im(:,:,i));
                    end
                    
                    imshow(app.im,'Parent',app.AxReferenceDistance)
                    hold on
                    title(app.AxReferenceDistance,'Click on reference markers -- Left to Right','Fontsize',16)
                    [x,y] = ginput(2);
                    dist = sqrt((x(1)-x(2))^2+(y(1)-y(2))^2);
                    app.pxtom2 = dist/app.refdist;
                    app.refang2 = atan((y(2)-y(1))/(x(2)-x(1)));
                    app.refp12 = [x(1),y(1)];
                    
                    app.currentvid = 1;
                    app.PushButtonReferenceDistance.String = 'Click 1st References';
                    app.PushButtonRunAnalysis.Visible = 'on';
                end
            else
                warndlg('Enter a Reference Distance First')
            end
            
        end        
        
        
        function CallbackEditWeight(app,~,~)
            app.SubjectWeight = str2double(app.WeightEntry.String);
        end
        
        function CallbackEditHeight(app,~,~)
            app.SubjectHeight = str2double(app.WeightEntry.String);
        end
%         function CallbackPushButtonRunAnalysis(app,~,~)
%             
% %             if app.videonum == 1
%                 
%                 output1.vidname1 = app.vidname;
%                 output1.sframe = round(app.StartFrame);
%                 tFrame = round(app.EndFrame - output1.sframe + 1);
%                 output1.tframe = tFrame;
%                 output1.nummark = app.nummark;
%                 output1.refdist = app.refdist;
%                 output1.markerclicks1 = app.markerclicks1;
%                 output1.length_Thigh_Hip1 = app.length_Thigh_Hip1;
%                 output1.hipindex = app.hipindex;
%                 output1.thighindex = app.thighindex;
%                 output1.jointschosen = app.jointschosen1;
%                 output1.boxDist = app.boxDist;
%                 
%                 output1.hsvthresh = app.hsvthresh;
%                 output1.unitvecthresh = app.unitvecthresh;
%                 output1.pxtom = app.pxtom;
%                 output1.refang = app.refang;
%                 output1.refp1 = app.refp1;
%                 output1.rot_num = app.rot_num;
%                 output1.markerarray1 = app.markerarray1;
%                 output1.OccultationData = app.OccultationData1;
%                 [markerpos1,markerpos2,markerarray1] = BoxMainTrackOneVid(output1);
%                 
%                
%                 plotdata.markerpos1 = markerpos1;
%                 plotdata.markerpos2 = markerpos2;
%                 app.plotdata = plotdata;
%                 
%               
% %                 app.TabGroup.SelectedTab = app.VerificationTab;
%                 
% %             elseif app.videonum == 2
% %                 
% %                 output1.vidname1 = app.vidname;
% %                 output1.sframe = round(app.StartFrame);
% %                 tFrame = round(app.EndFrame - output1.sframe + 1);
% %                 output1.tframe = tFrame;
% %                 output1.nummark = app.nummark;
% %                 output1.refdist = app.refdist;
% %                 output1.markerclicks1 = app.markerclicks1;
% %                 output1.length_Thigh_Hip1 = app.length_Thigh_Hip1;
% %                 output1.hipindex = app.hipindex;
% %                 output1.thighindex = app.thighindex;
% %                 output1.jointschosen = app.jointschosen1;
% %                 output1.boxDist = app.boxDist;
% %                 
% %                 output1.hsvthresh = app.hsvthresh;
% %                 output1.unitvecthresh = app.unitvecthresh;
% %                 output1.pxtom = app.pxtom;
% %                 output1.refang = app.refang;
% %                 output1.refp1 = app.refp1;
% %                 output1.rot_num = app.rot_num;
% %                 
% %                 output2.vidname2 = app.vidname2;
% %                 output2.sframe = round(app.StartFrame2);
% %                 tFrame = round(app.EndFrame - output2.sframe + 1);
% %                 output2.tframe = tFrame;
% %                 output2.nummark = app.nummark;
% %                 output2.refdist = app.refdist;
% %                 output2.markerclicks2 = app.markerclicks2;
% %                 output2.length_Thigh_Hip2 = app.length_Thigh_Hip2;
% %                 output2.hipindex = app.hipindex;
% %                 output2.thighindex = app.thighindex;
% %                 output2.jointschosen = app.jointschosen2;
% %                 output2.boxDist = app.boxDist;
% %                 
% %                 output2.hsvthresh = app.hsvthresh;
% %                 output2.unitvecthresh = app.unitvecthresh;
% %                 output2.pxtom = app.pxtom2;
% %                 output2.refang = app.refang2;
% %                 output2.refp1 = app.refp12;
% %                 output2.rot_num = app.rot_num2;
% %
% %                 [markerpos1,markerpos2] = BoxMainTrack2Vid(output1,output2);
% %                 
% %                 
% %                 plotdata.markerpos1 = markerpos1;
% %                 plotdata.markerpos2 = markerpos2;
% % 
% %                 app.plotdata = plotdata;
% %                 
% %                
% % %                 app.TabGroup.SelectedTab = app.VerificationTab;
% %                 
% %                 
% %             end
%             
%         end
        
        
  %% Old function with kinetics calculations      
        function CallbackPushButtonRunAnalysis(app,~,~)
             
             app.SubjectHeight = 62; %<----- delete this and re-enable user height entry if deemed necessary
             
             if strcmp(app.EditReferenceDistance.String,'Enter Reference Distance (m)') == 1
                 warndlg('You Must Enter a Reference Distance.','Warning')
                 
             elseif app.SubjectHeight == 0 || app.SubjectWeight == 0
                 %warndlg('You Must Enter Weight and Height.','Warning');
                 warndlg('You Must Enter Subject''s Weight.','Warning');
                 
             elseif app.videonum == 1
                
                output1.vidname1 = app.vidname;
                output1.sframe = round(app.StartFrame);
                tFrame = round(app.EndFrame - output1.sframe + 1);
                output1.tframe = tFrame;
                output1.nummark = app.nummark;
                output1.refdist = app.refdist;
                output1.markerclicks1 = app.markerclicks1;
                output1.length_Thigh_Hip1 = app.length_Thigh_Hip1;
                output1.hipindex = app.hipindex;
                output1.thighindex = app.thighindex;
                output1.jointschosen = app.jointschosen1;
                output1.boxDist = app.boxDist;
                
                output1.hsvthresh = app.hsvthresh;
                output1.unitvecthresh = app.unitvecthresh;
                output1.pxtom = app.pxtom;
                output1.refang = app.refang;
                output1.refp1 = app.refp1;
                output1.rot_num = app.rot_num;
                output1.markerarray = app.markerarray1;
                output1.OccultationData = app.OccultationData1;
                [markerpos1,markerpos2,MarkerClassArray1,MarkerClassArray2] = BoxMainTrackOneVid(output1);

                
                [t,GRFx,GRFy,Power_ext,EnergyInt] = power_calcNOPLOT(MarkerClassArray1,MarkerClassArray2,app.SubjectWeight,app.SubjectHeight,app.FramesPerSecond);
                
                
                plotdata.markerpos1 = markerpos1;
                plotdata.markerpos2 = markerpos2;
                plotdata.t = t;
                plotdata.GRFx = GRFx;
                plotdata.GRFy = GRFy;
                plotdata.Power = Power_ext;
                EnergyInt = EnergyInt(1,1:length(EnergyInt)-1);
                plotdata.Energy = EnergyInt;
                app.plotdata = plotdata;
                
                plot(app.AxLeftShowVerificationTab,app.plotdata.t,app.plotdata.GRFx,app.plotdata.t,app.plotdata.GRFy)
                hold on
                legend(app.AxLeftShowVerificationTab,'GRFx','GRFy')
                title(app.AxLeftShowVerificationTab,'Ground Reaction Forces')
                xlabel(app.AxLeftShowVerificationTab,'Time (s)')
                
                
                if length(EnergyInt) > 40
                    plot(app.AxRightShowVerificationTab,app.plotdata.t,app.plotdata.Power,app.plotdata.t,app.plotdata.Energy)
                    hold on
                    legend(app.AxRightShowVerificationTab,'Power','Energy')
                    title(app.AxRightShowVerificationTab,'Power & Energy')
                    xlabel(app.AxRightShowVerificationTab,'Time (s)')
                else
                    plot(app.AxRightShowVerificationTab,app.plotdata.t,app.plotdata.Power)
                    hold on
                    legend(app.AxRightShowVerificationTab,'Power')
                    title(app.AxRightShowVerificationTab,'Power')
                    xlabel(app.AxRightShowVerificationTab,'Time (s)')
                end
                
                app.TabGroup.SelectedTab = app.VerificationTab;
                 
             elseif app.videonum == 2
                
                output1.vidname1 = app.vidname;
                output1.sframe = round(app.StartFrame);
                tFrame = round(app.EndFrame - output1.sframe + 1);
                output1.tframe = tFrame;
                output1.nummark = app.nummark;
                output1.refdist = app.refdist;
                output1.markerclicks1 = app.markerclicks1;
                output1.length_Thigh_Hip1 = app.length_Thigh_Hip1;
                output1.hipindex = app.hipindex;
                output1.thighindex = app.thighindex;
                output1.jointschosen = app.jointschosen1;
                output1.boxDist = app.boxDist;
                
                output1.hsvthresh = app.hsvthresh;
                output1.unitvecthresh = app.unitvecthresh;
                output1.pxtom = app.pxtom;
                output1.refang = app.refang;
                output1.refp1 = app.refp1;
                output1.rot_num = app.rot_num;
                output1.markerarray = app.markerarray1;
                output1.OccultationData = app.OccultationData1;
                
                output2.vidname2 = app.vidname2;
                output2.sframe = round(app.StartFrame2);
                tFrame = round(app.EndFrame - output2.sframe + 1);
                output2.tframe = tFrame;
                output2.nummark = app.nummark;
                output2.refdist = app.refdist;
                output2.markerclicks2 = app.markerclicks2;
                output2.length_Thigh_Hip2 = app.length_Thigh_Hip2;
                output2.hipindex = app.hipindex;
                output2.thighindex = app.thighindex;
                output2.jointschosen = app.jointschosen2;
                output2.boxDist = app.boxDist;
                
                output2.hsvthresh = app.hsvthresh;
                output2.unitvecthresh = app.unitvecthresh;
                output2.pxtom = app.pxtom2;
                output2.refang = app.refang2;
                output2.refp1 = app.refp12;
                output2.rot_num = app.rot_num2;
                output2.markerarray = app.markerarray2;
                output2.OccultationData = app.OccultationData2;
                
                [markerpos1,markerpos2,MarkerClassArray1,MarkerClassArray2] = BoxMainTrack2Vid(output1,output2);
                
                [t,GRFx,GRFy,Power_ext,EnergyInt] = power_calcNOPLOT(MarkerClassArray1,MarkerClassArray2,app.SubjectWeight,app.SubjectHeight,app.FramesPerSecond);
                
                plotdata.markerpos1 = markerpos1;
                plotdata.markerpos2 = markerpos2;
                plotdata.t = t;
                plotdata.GRFx = GRFx;
                plotdata.GRFy = GRFy;
                plotdata.Power = Power_ext;
                plotdata.Energy = EnergyInt;
                app.plotdata = plotdata;
                
                plot(app.AxLeftShowVerificationTab,app.plotdata.t,app.plotdata.GRFx,app.plotdata.t,app.plotdata.GRFy)
                hold on
                legend(app.AxLeftShowVerificationTab,'GRFx','GRFy')
                title(app.AxLeftShowVerificationTab,'Ground Reaction Forces')
                xlabel(app.AxLeftShowVerificationTab,'Time (s)')
                
                
                if length(EnergyInt) > 40
                    plot(app.AxRightShowVerificationTab,app.plotdata.t,app.plotdata.Power,app.plotdata.t,app.plotdata.EnergyInt)
                    hold on
                    legend(app.AxRightShowVerificationTab,'Power','Energy')
                    title(app.AxRightShowVerificationTab,'Power & Energy')
                    xlabel(app.AxRightShowVerificationTab,'Time (s)')
                else
                    plot(app.AxRightShowVerificationTab,app.plotdata.t,app.plotdata.Power)
                    hold on
                    legend(app.AxRightShowVerificationTab,'Power')
                    title(app.AxRightShowVerificationTab,'Power')
                    xlabel(app.AxRightShowVerificationTab,'Time (s)')
                end
                
                app.TabGroup.SelectedTab = app.VerificationTab;
                
                
            end
            
        end
        
        %% Verification
        function CallbackPushButtonSaveGRF(app,~,~)
            
            [pathname] = uigetdir;
            pathname = strcat(pathname,'/forces.xlsx');
            
            matrix(:,1) = app.plotdata.t;
            matrix(:,2) = app.plotdata.GRFx;
            matrix(:,3) = app.plotdata.GRFy;
            
            xlswrite(pathname,matrix)%Writes as .csv on mac's
            
        end
        
        
        function CallbackPushButtonSavePowerEnergy(app,~,~)
            
            [pathname] = uigetdir;
            pathname = strcat(pathname,'/powerandenergy.xlsx');
            
            matrix(:,1) = app.plotdata.t;
            matrix(:,2) = app.plotdata.Power;
            matrix(:,3) = app.plotdata.Energy;
            
            xlswrite(pathname,matrix)%Writes as .csv on mac's
            
        end
        
    end
    
    
end

