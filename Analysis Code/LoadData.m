%% Loads a block of trials to the analysis interface

%Author: Omri Nachmani
%Contributing authors: Members of the Blohm Lab, Queen's University,
%Kingston, Ontario, Canada.

%This function loads a block of trials produced by the saccade trigger
%task and then sorts them into a data cell (D). Eye tracking data is
%extracted from an edf file and trial parameters are extracted from the
%.mat file. Function creates a **_**D.mat file. 

%Dependencies:
    %el2matInputEvent


function D = LoadData

try
    clear all;
    origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set path where functions are found
    loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Data'; %Set path to load the task data
    savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Loaded'; %Set path to save loaded data file
    cd(loadPath);
    [filename1,pathname1] = uigetfile({'*.mat'},'Choose mat record file you want to load....'); %load in mat-file = Trial parameters
    cd(pathname1);
    load([pathname1 filename1]);
    firstload = 0;
    
    %If this block of trials has not been loaded before, look for an
    %Eyelink data file (edf) to load
    if ~contains(filename1,'D.mat') == 1
        firstload = 1;
        [filename2,pathname2] = uigetfile({'*.edf'},'Choose Eyelink edf file you want to load....'); %load in edf-file = EyeLink
        cd(origPath);
        try
            [X.sampledata,X.eventdata,X.mestimes,X.messages,X.preamble,X.samplerate,X.numtrials,X.button,X.input]=el2matInputEvent([pathname2 filename2],'fixation','trialEnd');%change eyelink- to mat-file
        catch
            warning(['Error processing file: ' filename2]);
            D=[];
            cd(origPath);
            clear all;
            return
        end

        
        %% Extract timing data from eyelink file
        
        s = {'fixation','step','ramp1','step2','ramp2','fixation2','trialEnd'}; %training xp
        [tFixation, mesFixation]=getELmes(X, s{1}); % tFixation : timestamps (ms) of fixation onset
        [tStep1, mesStep1]=getELmes(X, s{2}); % tStep1: timestamp (ms) of target step
        [tRamp1, mesRamp1]=getELmes(X, s{3}); % tRamp1: timestamp (ms) of target initial movement
        [tStep2, mesStep2]=getELmes(X, s{4}); %tStep2: timestamp (ms) of second step
        [tRamp2, mesRamp2] = getELmes(X, s{5}); %tRamp2: timestamp (ms) of second ramp
        [tFixation2, mesFixation2]=getELmes(X, s{6});%tFixation2: timestamp (ms) of end fixation period
        [tTrialEnd, mesTrialEnd]=getELmes(X, s{7}); % timestamp for end of trial
                
        cd(origPath);
        
        %% Construct Data cell 
        
        %First entry contains global information on block of trials as well
        %as the information for the first trial. The rest of cell entries
        %contain information relevant to that trial. 
        
        % parameter from mat file
        D{1}.dFilename = [filename2(1:end-4) 'D.mat']; % General filename
        D{1}.xpFilename = filename1;	% Mat filename
        D{1}.edfFilename = filename2;	% Edf filename
        D{1}.subjectID = subjectID;
        D{1}.blockNumber = blockNumber;
        D{1}.numTrials = numTrials;
        D{1}.condition = condition; %0 = clear target, 1= blurred target. 
        D{1}.dist2Screen =  dist2Screen; %From centre of screen to chin rest of eyelink mount
        D{1}.screenWidth = screenWidth; 
        D{1}.screenHeight = screenHeight;
        D{1}.xCenter = xCenter;
        D{1}.yCenter = yCenter;
        D{1}.xPixels = xPixels;
        D{1}.yPixels = yPixels;
        D{1}.ppdx = ppdx;
        D{1}.ppdy = ppdy;
        D{1}.ppcmx = ppcmx;
        D{1}.ppcmy = ppcmy;
        D{1}.frameRate = frameRate;
        D{1}.dotSize = dotSize;
        D{1}.dotColour = dotColour;
        D{1}.flipInterval =  flipInterval;
        D{1}.frameInfos = frameInfos;
        D{1}.nFrames = nFrames;
        D{1}.paraTrial = paraTrial; %initial trial parameteres for all trials
        D{1}.exp_array = exp_array; %target trajectories for all trials
       
        %eyelink
        D{1}.message = s ;
        D{1}.cutoff = 50; % cut-off frequency for filter
        D{1}.sfr1 = 1000; % sampling frequency of Eyelink tracker
        D{1}.win = 0.005; % time window (1/2 width) for differentiation
        
        
        %% Collect parameters, target and eye trajectories from each trial
        for iTrial = 1: D{1}.numTrials
            % parameter from mat file
            D{iTrial}.tScreen = (D{1}.exp_array{iTrial}(:,1) - D{1}.exp_array{iTrial}(1,1)) * 1000; % time of target on screen, first frame is the 0s reference point
            D{iTrial}.target_x = D{1}.exp_array{iTrial}(:,3); % target movement data in degrees
            D{iTrial}.target_v = D{1}.exp_array{iTrial}(:,4); % target velocity matrix in degrees
            D{iTrial}.target_v1 = D{1}.paraTrial(3,iTrial); %initial velocity
            D{iTrial}.target_v2 = D{1}.paraTrial(5,iTrial); %second velocity
            D{iTrial}.target_s1 = D{1}.paraTrial(2,iTrial); %initial step
            D{iTrial}.target_s2 = D{1}.paraTrial(4,iTrial); %second step
            D{iTrial}.target_start = D{1}.paraTrial(1,iTrial); %Target start location (left 20 or right 20 degrees)

            %eyelink data
            D{iTrial}.expStart = tFixation(iTrial);
            D{iTrial}.tFixation = tFixation(iTrial) - tFixation(iTrial); %Beginning of fixation is 0s reference
            D{iTrial}.tStep1 = tStep1(iTrial) - tFixation(iTrial);
            D{iTrial}.tRamp1 = tRamp1(iTrial) - tFixation(iTrial);
            D{iTrial}.tStep2 = tStep2(iTrial)- tFixation(iTrial);
            D{iTrial}.tRamp2 = tRamp2(iTrial) - tFixation(iTrial);
            D{iTrial}.tFixation2 = tFixation2(iTrial) - tFixation(iTrial);
            D{iTrial}.tTrialEnd = tTrialEnd(iTrial) - tFixation(iTrial);
            
            indBegin = find(X.sampledata(1,:) >= tFixation(iTrial),1); %Find the beginning of each trial in the sample data X matrix. 
    
            indEnd = find(X.sampledata(1,:) == tTrialEnd(iTrial)-1,1); %Find the end of each trial in the sample data X matrix. 
            D{iTrial}.eyeX = rad2deg(atan((X.sampledata(2,indBegin:indEnd)-D{1}.xCenter)/D{1}.dist2Screen/D{1}.ppcmx));% Extract eye X position in pixels and convert to degrees using trig and information of experimental setup(degree)
            D{iTrial}.eyeY = rad2deg(atan((X.sampledata(3,indBegin:indEnd)-D{1}.yCenter)/D{1}.dist2Screen/D{1}.ppcmy)); % do the same for eye Y position (degree) 
            D{iTrial}.t = (0:length(D{iTrial}.eyeX)-1)/D{1}.sfr1*1000;% time duration of each trial in ms
            D{iTrial}.target_x_interp = interp1(D{iTrial}.tScreen, D{iTrial}.target_x, D{iTrial}.t); %interpolate target trajectory information for position error comparison with eye data. Needed due to different sampling rates
            D{iTrial}.target_v_interp = interp1(D{iTrial}.tScreen, D{iTrial}.target_v, D{iTrial}.t); % do the same for target velocity
                     
            %others parameters
            D{iTrial}.good = 0;
            D{iTrial}.antic = 0;
            D{iTrial}.TF = (D{iTrial}.tTrialEnd-D{iTrial}.tFixation)/D{1}.nFrames(iTrial);
            D{iTrial}.tTarget = [1:D{1}.nFrames(iTrial)]*D{iTrial}.TF;
            
        end
        
        %% filter eyelink signals & differentiate to obtain eye velocity and eye acceleration signals
        for iTrial = 1:numTrials
            
            D{iTrial}.eyeX = autoregfiltinpart(D{1}.sfr1,D{1}.cutoff,D{iTrial}.eyeX);
            D{iTrial}.eyeY = autoregfiltinpart(D{1}.sfr1,D{1}.cutoff,D{iTrial}.eyeY);
            
            D{iTrial}.eyeXv = aiDiff(1/D{1}.sfr1,D{1}.win,D{iTrial}.eyeX);
            D{iTrial}.eyeYv = aiDiff(1/D{1}.sfr1,D{1}.win,D{iTrial}.eyeY);
            D{iTrial}.eyeVv = sqrt(D{iTrial}.eyeXv.^2 + D{iTrial}.eyeYv.^2);
            
            D{iTrial}.eyeXa = aiDiff(1/D{1}.sfr1,D{1}.win,D{iTrial}.eyeXv);
            D{iTrial}.eyeYa = aiDiff(1/D{1}.sfr1,D{1}.win,D{iTrial}.eyeYv);
            D{iTrial}.eyeVa = sqrt(D{iTrial}.eyeXa.^2 + D{iTrial}.eyeYa.^2);
            [D{iTrial}.sacc, D{iTrial}.eyeXvws, D{iTrial}.eyeYvws, D{iTrial}.eyeVvws] = DetectSaccades(D,iTrial);
        end
        cd(savePath);
        save([filename2(1:end-4) 'D.mat'],'D');
        cd(origPath);
    else
        cd(origPath);
    end
catch
    cd(origPath);
    
end
