%% Saccade Trigger Experiment Task

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's Universty, Kingston, Ontario, Canada
                        %Psychtoolbox tutorials

%%This code runs a double step-ramp task (de Brouwer 2002)  generated using
%%Psychtoolbox. Data collection is done through the Eyelink Psychtoolbox
%%package and thus requires that an eyelink PC and eye tracker be connected
%%to the host PC that is running this task. Current eyelink commands are compatible with Eyelink
%%1000. 

%%To run this experiement, simply press "Run" on Matlab and a dialogue box
%%will prompt user input. Ensure the EDF file name is 8 characters or
%%less otherwise data will not be saved. To run a clear target, the
%%condition box should be set to 0. For a blurred target (Gaussian blur), change the value
%%to 1. 

%%Note:

%%Task code requires the following dependcies:
    %%Psychtoolbox
    %%Psychtoolbox Eyelink
    %%generateTrial.m in Matlab path


%% Environment Set-up Prior to First Recording

%Close any open psychtoolbox windows
sca

%Clear all workspace variables
clear all; 
clearvars; 

%turn off unnecessary warnings
warning off all 


%Set Psychtoolbox preferences
Screen('Preferences', 'SkipSyncTest', 1)

%minimize Psychtoolbox warnings
oldLevel = Screen('Preference', 'VisualDebugLevel', 1);
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);

%dialogue box

%Current experimental structure includes 10 sessions, with 10 blocks in
%each session and 50 trials in each block. Sessions alternate between
%condition 0 and condition 1 (clear and blurred target). 

%EDF filename is concatenated using the file name, session # and block #.
%All together the name should consist of 8 characters or less. 
prompt = {'Tracker EDF file name:', 'Subject ID:', 'Session #', 'Block #', '# of trials', 'Condition'};
dlg_title = 'input';                              
num_lines = 1;                                                   
default_ans = {'CS_BC', '3', '2', '0', '50','0'}; %Set for each session default answers. (Usually name, ID, Session, Condition)
input_cluster = inputdlg(prompt, dlg_title, num_lines, default_ans);

%Creates edfFile name 
edf_file = strcat(input_cluster{1}, input_cluster{3}, input_cluster{4}); 

%Convert all string inputs to numbers for use in functions.
subject_id = str2num(input_cluster{2});
block_number = str2num(input_cluster{4}); 
num_trials = str2num(input_cluster{5});
session_number = str2num(input_cluster{3});
condition = str2num(input_cluster{6}); % 0 clear dot condition, 1 blurred dot condition
time = clock;

%Matlab file name includes EDF file and date/time of recording. 
file_name = sprintf( '%s_%d_%02d_%02d_%02dh%02dm.mat', edf_file, time(1), time(2), time(3), time(4), time(5)); 

% Set path to save the data and matlab files. 
path_name = 'C:\Users\blohm\Desktop\Experiment DataBackup-blohm\Omri\Data'; 


%% 
%Screen Setup
    PsychDefaultSetup(2);
    rand('seed', sum(100*clock)); %seed the rand function
    screens = Screen('Screens'); %Obtain number of screens present
    screen_number = max(screens); %Use latest screen
    
    %Distance from position of participant's eye to the middle of the screen
    screen_width = 52; %cm 
    
    %Screen paramters (ViewPixx, 120Hz)
    dist_to_screen = 47;%cm 
    screen_height = 29.5; %cm
try    
    %Set screen variables
    black = BlackIndex(screen_number);
    grey = white/2;
    Screen('Preference', 'SkipSyncTests', 2);
    [window, windowRect] = PsychImaging('OpenWindow', screen_number, 0.9); %Background color is 0.9 (not quite white)
    frame_rate = round(FrameRate(window));
    flip_interval = Screen('GetFlipInterval', window);
    [x_pixels, y_pixels] = Screen('WindowSize', window);
    [x_center, y_center] = RectCenter(windowRect);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %smooth edges of stimulus display
    
    %The following is a calculation to obtain the pixels per degrees of viewing angle and
    %pixels per centimeters on the screen for each dimension. 
    
    window_x_degrees = atan2(screen_width/2, dist_to_screen)*2*180/pi; 
    ppdx = x_pixels/window_x_degrees; %calculate pixels per degrees on the X axis
    ppcmx = x_pixels/screen_width;
    window_y_degrees = atan2(screen_height/2, dist_to_screen)*2*180/pi; %degrees
    ppdy = y_pixels/window_y_degrees;
    ppcmy = y_pixels/screen_height;
    
  
    %% Set up Target Parameters
    dot_colour = black;
    dot_size = 10;
    
    %blurred target setup
    
    %We use a gabor patch with low spatial frequency and high phase to
    %obtain a Gaussian blur. The following parameters create a blur with
    %a set size that creates significant position errors during pursuit
    %tracking. 
    if condition == 1
        blur_size = y_pixels;
        sigma = blur_size/20; 
        orientation =0;
        contrast = 0.5;
        aspectRatio = 1;
        phase = 10000;
        rect = [0 0 blur_size blur_size];
        blur_pos = zeros(4,1);
        freq = 0.001;
        background_offset = [1 1 1 1];
        disable_norm = 1;
        preContrast_multiplier =1;
        gabor_tex = CreateProceduralGabor(window, blur_size, blur_size, [], ...
             background_offset, disable_norm, preContrast_multiplier);
        propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
    end
    

        

   %% Generate target trajectory matrices and frame information for entire block of trials
    
   %Empty parameters to compile the variables for each trial
   
    %Paratrial holds information on initial trial parameters for all trials
    para_trial = zeros(5, num_trials); %(1) starting position (2) first position step size (3) first velocity magnitude (4) second step size (5) second velocity magnitude
    
    %exp_array is a cell since trials are of different lengths. This
    %variable holds the pixel positions for target trajectory, velocity information for each frame,
    %and an empty array for event timing capture for each trial. 
    exp_array = cell(num_trials,1); %holds pixel positions and timing for each trial
    
    %frameInfos holds the frame number in which events occured such as
    %fixation, steps, and ramps. This  will be used to send event markeres
    %to Eyelink.
    frame_infos = zeros(6,num_trials); %holds frame number correpsonding to events for each trial
    n_frames = zeros(1,num_trials);
    
    
    %Loop to generate trial information for all trials in block
    
    %Note:
        %All trialMatrix pixel values are zero-centred. This means that
        %when drawing to screen, we add the xCenter pixel value to make all
        %pixel values relative to the center of the screen. 
        
     for aTrial = 1: num_trials
        [initial_condition, trial_matrix, frame_info] = makeTrial3(dist_to_screen, frame_rate,ppcmx); %function that returns all the necessary target parameters/locations.
        
        %Fill in empty variables with new information
        frame_infos(:,aTrial) = frame_info;
        n_frames(1,aTrial) = sum(frame_info);
        para_trial(:, aTrial) = initial_condition; %records initial condition for each trial
        
        %Due to randomization of several initial trial parameters, some
        %target positions end up off screen. To deal with this, we check if
        %any pixel positions are off screen before adding trial to the
        %exp_array variable. If a trial goes off screen, we regenerate a
        %new trial until target trajectory is within the screen.
        while isempty(exp_array{aTrial})
            bad_trial = (x_center + trial_matrix(:,2)) > x_pixels | (x_center + trial_matrix(:,2)) < 0; %Filters out trials where target goes off screen 
            if sum(bad_trial)  > 0
                [initial_condition, trial_matrix, frame_info] = generateTrial(dist_to_screen, frame_rate,ppcmx); %Generate new trial
                
                %Edit in new trial parameters and frameinfo
                para_trial(:, aTrial) = initial_condition; 
                frame_infos(:,aTrial) = frame_info; 
                continue
            %If trial is good, proceed to add to exp_array    
            else
                exp_array{aTrial} = trial_matrix; %cell array with numTrials cells where each cell contains a matrix...
                                                 %containing trials,
                                                 %timeslots, and velocity
                                                 %Matrix
                                               
            end
        end
    end
    
    
    
    %% Eyelink Code Block
    % Eyelink initialization and configuration
    
    if Eyelink('initialize','PsychEyelinkDispatchCallback'),
        fprintf('Eyelink failed init');
        Screen('CloseAll');
        return
    end
	
    HideCursor;
    el = EyelinkInitDefaults(window);
    % tell the Eyelink Host the coordinate space
    if Eyelink('IsConnected') ~= el.notconnected,
        Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', 0, 0, windowRect(RectRight), windowRect(RectBottom));
    end
    Eyelink('Command','calibration_type = HV9');
    %EyeLink('Command','read_ioport %d',hex2dec('379'));
    Eyelink('Command','write_ioport %d %d',hex2dec('37A'), 0);
    Eyelink('Command','write_ioport %d %d',hex2dec('378'), 0);
    Eyelink('Command','file_event_filter = LEFT,RIGHT, FIXATION, BLINK, MESSAGE, BUTTON, SACCADE, INPUT');%sets which events will be written to the EDF file.
    Eyelink('Command','link_event_filter = LEFT,RIGHT, FIXATION, BLINK, MESSAGE, BUTTON, SACCADE, INPUT');%sets which types of events will be sent through link
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % configure eyelink to send raw data
    status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,BUTTON,HMARKER');
    if status~=0
        disp('link_sample_data error')
    end
        status=Eyelink('command','inputword_is_window = ON');
    if status~=0
        disp('inputword_is_window error')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(edf_file)
        edf_file = 'data';
    end
    Eyelink('openfile', edf_file);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Calibrate the eye tracker
    
    el.backgroundcolour = 204;
    el.foregroundcolour = 0;
    el.window = window;
    status = Eyelink('isconnected');
    if status == 0 %if not connected
        Eyelink('closefile');
        Eyelink('shutdown');
        
        Screen('CloseAll');
        ShowCursor;
        % restore Screen preferce settings.
        Screen('Preference', 'VisualDebugLevel', oldLevel);
        Screen('Preference', 'SuppressAllWarnings', oldEnableFlag);
        return;
    end
    
    el.callback = '';
    error = EyelinkDoTrackerSetup(el, el.ENTER_KEY); % This calls the calibration,error: Screen( 'FillRect',  el.window, el.backgroundcolour );	% clear_cal_display()
    
    
    if error ~= 0, fprintf('eye tracker setup error = %d\n',error);end
    %%%end calibration%%%%%
    
    
    %Set Background color
    Eyelink('command','draw_filled_box %d %d %d %d %d',windowRect(RectLeft),windowRect(RectTop),windowRect(RectRight),windowRect(RectBottom),0);
    
    Screen('FillRect',window,204,windowRect);
    Screen('Flip',window);
    Eyelink('StartRecording');
    %%%%%%%%%%%%%%%%
    eye_used = Eyelink('EyeAvailable');
    
    switch eye_used
        case el.BINOCULAR
            error('tracker indicates binocular');
        case el.LEFT_EYE
            error('tracker indicates left eye');
        case el.RIGHT_EYE
            disp('tracker indicates right eye')
        case -1
            error('eyeavailable returned -1');
        otherwise
            error('unexpected result from eyeavailable');
    end
    eyeIndex = el.RIGHT_EYE & eye_used;
    
  
%% Task loop 

%For each trial, we obtain the necessary trajectory and draw it to the
%screen frame by frame using the psychtoolbox. The trial is also displayed
%in the command window for experimenters to track task progression. Eyelink
%events markers are sent using the frame_infos matrix. 

%The task is self paced, meaning participants must focus on the initial
%position of the target, than press any keyboard button to begin the trial.
%Instruct participants to only press the keyboard when absolutly sure they
%are focusing on the target as this information can be used for offline
%calibration accuracy check. 

%Note:
    %For the blurred condition, the initial fixation prior to keyboard press is
    %a clear target. Once a key is pressed, the target becomes blurred.


	Eyelink('command','draw_text %d %d %d %d',windowRect(RectRight)-100, windowRect(RectBottom)-100, 10, aTrial);
    
    %Trial loop within a block
    for aTrial = 1:num_trials
        disp(aTrial); %For experimenter to track progress
        
        %Draw starting position of target and flip the screen (i.e. draw to
        %the screen)
        Screen('DrawDots', window, [x_center + exp_array{aTrial}(1,2), y_center], dot_size, dot_colour, [], 2); 
        Screen('Flip', window);
        
        if KbStrokeWait %Instruct participant to press keyboard to begin trial only once they are fixated on the target
            expStart = GetSecs; %Beginning of trial timing marker, used for offline analysis
            
            Eyelink('Command','write_ioport %d %d',hex2dec('378'), 3);
            
            %Target trajectory loop within a trial
            for frame = 1:length(exp_array{aTrial}) %i.e. number of frames
                
                %If block for different task conditions
                 if condition == 0
                      Screen('DrawDots', window, [x_center + exp_array{aTrial}(frame,2), y_center], dot_size, dot_colour, [], 2);
                      Screen('Flip', window);
                      
                      %records time of each frame draw
                      exp_array{aTrial}(frame,1) = GetSecs - expStart; 
                elseif condition == 1
                    %Gaussian blur is drawn in the centre of a white rectangle that
                    %is not visible on the screen as the background is also
                    %white
                     blur_pos(:,1) = CenterRectOnPointd(rect,x_center+exp_array{aTrial}(frame,2), y_center);
                     Screen('DrawTexture', window, gabor_tex, [], blur_pos, orientation, [], [], [], [],...
                    kPsychDontDoRotation, propertiesMat');
                     Screen('Flip',window);
                     
                     %records time of each frame draw
                     exp_array{aTrial}(frame,1) = GetSecs - expStart; 
                 end
                 
                %If block to determine when to send event marker to eyelink for
                %fixation, steps, ramps. 
                if frame == frame_infos(1,aTrial)
                    Eyelink('message','fixation');
                elseif frame == frame_infos(2,aTrial)
                    Eyelink('message','step');
                elseif frame == frame_infos(3,aTrial)
                    Eyelink('message', 'ramp1');
                elseif frame == frame_infos(4,aTrial)
                    Eyelink('message', 'step2');
                elseif frame == frame_infos(5,aTrial)
                    Eyelink('message', 'ramp2');
                elseif frame == frame_infos(6,aTrial)
                    Eyelink('message','fixation2');
                end
            end
        end
        Eyelink('message','trialEnd');
        Eyelink('command','draw_text %d %d %d %d',windowRect(RectRight)-100, windowRect(RectBottom)-100, 0, aTrial);
        Eyelink('Command','write_ioport %d %d',hex2dec('378'), 0);
    end
           
	Eyelink('StopRecording');
	Eyelink('command', 'set_idle_mode');
	WaitSecs(0.5);
	Eyelink('CloseFile');

    %% "Thank you" screen  and reset screen params

    Screen('FillRect',window,204,windowRect);
    Screen('Flip',window);
    
    
    Screen('TextStyle',window,1);% 0=plain, 1=bold, 2=italics, 3=1&2,  4=underlined, 5=4&1,6=4&2, 7=4&3. rem(?,8)
    [oldFontName,oldFontNumber]=Screen(window,'TextFont','Tahoma');
    Screen('TextSize',window,58);
    ttext='Thank you for your participation!';
                
    tsize=Screen('TextBounds', window, ttext);twidth=tsize(3);
    Screen('DrawText',window,ttext,x_center-(twidth/2),y_center-60,black);
    ttext='Please rest now.';
    
    tsize=Screen('TextBounds', window, ttext);twidth=tsize(3);
    Screen('DrawText',window,ttext,x_center-(twidth/2),y_center+60, black);
    Screen('TextSize',window,40);
    Screen('flip',window);
                             
    pause(2);
    
    % restore Screen preferce settings.
    Screen('CLoseAll')
    ShowCursor;
    Screen('Preference', 'VisualDebugLevel', oldLevel);
    Screen('Preference', 'SuppressAllWarnings', oldEnableFlag);
    
    
    %% Save block parameters to the matlab file
    save([path_name '/' file_name], 'num_trials', 'edf_file', 'subject_id', 'block_number','session_number','condition', 'dist_to_screen', 'screen_width', 'screen_height', 'x_pixels', 'y_pixels', 'ppdy'...
    ,'x_center','x_pixels','y_pixels', 'frame_rate','ppdx','ppdy','ppcmx','ppcmy', 'y_center', 'dot_colour', 'dot_size', 'flip_interval',... %name and specs
                                'frame_infos', 'n_frames' , 'para_trial',... %parameters
                                'exp_array'); %target location and time for each trial 
    
        
catch me    
     % restore Screen preference settings.
    Screen('CloseAll')
    ShowCursor;
    Screen('Preference', 'VisualDebugLevel', oldLevel);
    Screen('Preference', 'SuppressAllWarnings', oldEnableFlag);
    rethrow(me);
    end
    
                             

%% download eyelink data file
try
    fprintf('Receiving data file ''%s''\n',edf_file);
    %  status = Eyelink('ReceiveFile');
    status=Eyelink('ReceiveFile', edf_file ,path_name,1);
    if status > 0
        fprintf('ReceiveFile status %d\n ', status);
    end
    if 2 == exist(edf_file, 'file')
        fprintf('Data file ''%s'' can be found in '' %s\n',edf_file, pwd);
    end
catch Me
    fprintf('Problem receiving data file ''%s''\n',edf_file);
    Eyelink('ShutDown');
end
Eyelink('ShutDown');   
