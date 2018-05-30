%% Plotter for Saccade Trigger Task Analysis Interface

%Author: Omri Nachmani
%Contributing authors: Members of the Blohm Lab, Queen's University,
%Kingston, Ontario, Canada

%This function plots target and eye position, velocities, and
%acceleration profiles for each trial on the analysis interface. This
%function is called when the data is loaded at first, and when the user
%switches between trials. This function also displays relevant trial
%parameters, an eye gaze trace, as well as initial and final position
%errors for calibration purposes. 

%Saccades are drawn in bold coloured lines, where each saccade is assigned a
%different colour. The colour of a saccade in a position plot corresponds to
%the colour in the velocity and acceleration plots. 

%Note: Function interfaces with the D data matrix created from the
%LoadData.m function. 

%Dependencies: 

%Set relevant paths for the function
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';
savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Loaded';

if isempty(D) %Error in case data can't be found
    fprintf('Error in Data loading, D is empty.');
    return
end

N = D{1}.numTrials; 
%Reset trn (Trial Number) to be less or equal to the total number of trials
if trn < 1, trn = 1; end
if trn > N, trn = N; end

CSGoodBadToggle;

filestr = D{1}.dFilename(1:end-5);
set(f,'name',['Saccade TriggerAnalysis Interface: ' filestr ',trial #: ' num2str(trn)]);

tStep1 = D{trn}.tStep1 - D{trn}.tFixation;
tRamp1 = D{trn}.tRamp1 - D{trn}.tFixation;
tStep2 = D{trn}.tStep2 - D{trn}.tFixation;
tRamp2 = D{trn}.tRamp2 - D{trn}.tFixation;
tTrialEnd = D{trn}.tTrialEnd - D{trn}.tFixation;


%% Plot eye trace of trial

%Choose axes to draw to
axes(ax(4))

%Clear previous trial
cla 
hold on

%Plot eye x and y position from the first step to the final fixation
plot(D{trn}.eyeX(D{trn}.tStep1:D{trn}.tFixation2), D{trn}.eyeY(D{trn}.tStep1:D{trn}.tFixation2))

%Set limits to be the size of the screen 
set(ax(4),'xlim',[-D{1}.screenWidth/2 D{1}.screenWidth/2],'ylim',[-D{1}.screenHeight/2 D{1}.screenHeight/2]); 

%% %Plot position of eye and target

%Choose axes to draw to
axes(ax(1));

%Clear axes 
cla; 

%hold all previous axes
hold on;

%Plot eye x position with respect to eye tracker time record, in red
plot(D{trn}.t, D{trn}.eyeX,'r'); 

%Plot target x position with respect to screen time record, in black
plot(D{trn}.tScreen, D{trn}.target_x','--k');

%Draw a centre-screen line in black
plot([0 length(D{trn}.eyeX)], [0 0],'k');


%Plot bolded and coloured saccades where saccades occured

%Loop over number of saccades detected
%D sacc field contains a matrix with the onset and offset times of each
%saccade in the trial. 
for iSacc =  1:size(D{trn}.sacc,1)
    plot(D{trn}.t(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2)), (D{trn}.eyeX(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2))),'LineWidth',3);
end

%Add legend
legend('X-Position Eye', 'X-Position Target');
set(ax(1),'xlim',[0 length(D{trn}.eyeX)],'ylim',[-30 30]);
%% plot velocity

%Set up same as before
axes(ax(2));
cla; 
hold on; 

%Plot of eye velocity in X in red
plot(D{trn}.t, D{trn}.eyeXv,'r'); 

%Plot of target velocity in X in green
plot(D{trn}.tScreen , D{trn}.target_v,'g');

%Interpolation of eye velocity without the saccade in red
plot(D{trn}.t, D{trn}.eyeXvws,'r');

%Plot centre 0 line on screen
plot([0 length(D{trn}.eyeXv)], [0 0],'k');

%Mark where steps occured in blue
plot(tStep1*[1 1],[-80 80],'b');
plot(tStep2*[1 1],[-80 80],'b');


%plot saccade
for iSacc =  1:size(D{trn}.sacc,1)
    plot(D{trn}.t(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2)), D{trn}.eyeXv(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2)),'LineWidth',3);
   
end

legend('X-Velocity Eye', 'X-Velocity Target', 'X-Velocity Target without sacc');
set(ax(2),'xlim',[0 length(D{trn}.eyeXv)],'ylim',[-80 80]);
%% Plot acceleration

%Set up plot
axes(ax(3));
cla; 
hold on;

%plot of eye x acceleration, red
plot(D{trn}.t, D{trn}.eyeXa,'r'); 

%plot target acceleration by differentiating twice the target position with
%respect to screen time record, green. 
plot(D{trn}.tScreen(1:end-2), diff(diff((D{trn}.target_x/D{1}.ppdx))./diff(D{trn}.tScreen)),'g'); 

%Draw centre 0 line
plot([0 length(D{trn}.eyeXa)], [0 0],'k');

%Mark where steps occured
plot(tStep1*[1 1],[-5500 5500],'b');
plot(tStep2*[1 1],[-5500 5500],'b');


%plot saccade
for iSacc =  1:size(D{trn}.sacc,1)
    plot(D{trn}.t(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2)), D{trn}.eyeXa(D{trn}.sacc(iSacc,1):D{trn}.sacc(iSacc,2)),'LineWidth',3);
end

legend('X-Acceleration Eye', 'X-Acceleration Target');
set(ax(3),'xlim',[0 length(D{trn}.eyeXa)],'ylim',[-1000 1000]);

%% Display trial parameters

%Parameters to be displayed: 
%Start position error
%End position error
%Target starting position
%Step 1
%Velocity 1
%Step 2
%Velocity 2
%Trial time duration

startError = mean(D{trn}.target_x_interp(D{trn}.tStep1-51:D{trn}.tStep1-10))- mean(D{trn}.eyeX(D{trn}.tStep1-50:D{trn}.tStep1-10));
endError = mean(D{trn}.target_x_interp(D{trn}.tTrialEnd-200:D{trn}.tTrialEnd-150))- mean(D{trn}.eyeX(D{trn}.tTrialEnd-200:D{trn}.tTrialEnd-150));
h.startError = uicontrol('Style','text','String','Start Position Error','Visible','off','units','normalized','Position', [0.82 0.4 0.05 0.025]);
h.valStartError = uicontrol('Style','text','String',[num2str(startError) ' degrees'],'Visible','off','units','normalized','Position', [0.87 0.4 0.05 0.025]);
h.endError = uicontrol('Style','text','String','End Position Error','Visible','off','units','normalized','Position', [0.82 0.375 0.05 0.025]);
h.valendError = uicontrol('Style','text','String',[num2str(endError) ' degrees'],'Visible','off','units','normalized','Position', [0.87 0.375 0.05 0.025]);
h.targetStart = uicontrol('Style','text','String','Starting Position','Visible','off','units','normalized','Position', [0.82 0.25 0.05 0.025]);
h.valtargetStart = uicontrol('Style','text','String',[num2str(D{trn}.target_start) ' degrees'],'Visible','off','units','normalized','Position', [0.87 0.25 0.05 0.025]);
h.Step1 = uicontrol('Style','text','String','Step 1','Visible','off','units','normalized','Position', [0.82 0.225 0.05 0.025]);
h.valStep1 = uicontrol('Style','text','String',[num2str(D{trn}.target_s1) ' degrees'],'Visible','off','units','normalized','Position', [0.87 0.225 0.05 0.025]);
h.Ramp1 = uicontrol('Style','text','String','Velocity 1','Visible',' off','units','normalized','Position', [0.82 0.2 0.05 0.025]);
h.valRamp1 = uicontrol('Style','text','String',[num2str(D{trn}.target_v1) ' degrees/s'],'Visible','off','units','normalized','Position', [0.87 0.2 0.05 0.025]);
h.Step2 = uicontrol('Style','text','String','Step 2','Visible',' off','units','normalized','Position', [0.82 0.17 0.05 0.025]);
h.valStep2 = uicontrol('Style','text','String',[num2str(D{trn}.target_s2) ' degrees'],'Visible','off','units','normalized','Position', [0.87 0.17 0.05 0.025]);
h.Ramp2 = uicontrol('Style','text','String','Velocity 2','Visible','off','units','normalized','Position', [0.82 0.15 0.05 0.025]);
h.valRamp2 = uicontrol('Style','text','String',[num2str(D{trn}.target_v2) ' degrees/s'],'Visible','off','units','normalized','Position', [0.87 0.15 0.05 0.025]);
h.Duration = uicontrol('Style','text','String','Trial Duration','Visible','off','units','normalized','Position', [0.82 0.1 0.05 0.025]);
h.valDuration = uicontrol('Style','text','String',[num2str(D{trn}.tScreen(end)/1000) ' s'],'Visible','off','units','normalized','Position', [0.87 0.10 0.05 0.025]);

%plot center line
plot(-D{1}.screenWidth/2/D{1}.ppdx:0.5:D{1}.screenWidth/2/D{1}.ppdx,0,'k');
plot(0,-D{1}.screenHeight/2/D{1}.ppdy:0.5:D{1}.screenHeight/2/D{1}.ppdy,'k');


% finalize
 sstr = fieldnames(h);
 for i = 1:length(sstr)
     set(eval(['h.' sstr{i}]),'visible','on')
 end
 
 cd(savePath);
 save(D{1}.dFilename,'D');
 cd(origPath);