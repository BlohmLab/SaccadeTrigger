%% Analysis interface for Saccade Trigger task. 

% Author: Omri Nachmani
%Contributing authors: Members of Blohm Lab, Queen's University, Kington,
%Ontario, Canada. 

%This program opens the UI interface that handles the data produced by the
%saccade trigger task. The user can load a block of trials, view each
%individual trial and extract a data matrix with desired parameters. Trials
%are visually inspected for calibration and tracking errors. Trials can be
%marked as good or bad whithin the interface. Saccade detection is
%automatic. 

%Dependencies:
% LoadData.m
% Plotter.m
% ExtractData.m
% SaccSet
%GoodBadToggle


clear 
warning off
RectRight = 3;
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Path where relevant functions are found
cd(origPath)
%% create figure
f = figure('Name','Saccade Trigger Analysis Interface','Units','normalized','Position',[.01 .01 .98 .94],'toolbar','none','NumberTitle','off'); %set window title

% create axes
ylabel = {'Eye Gaze X/Y(degree)','Eye velocity X/Y(degree/s)','Eye acceleration X/Y(degree/s^2)' };
for i = 1:3
    ax(i) = axes('Units','normalized','Position',[.05 1.02-i*.32 .6 .28]);
    ylabel(ylabel{i});
end
xlabel('Time (ms)')

ax(4) = axes('Units','normalized','Position',[.70 .70 .25 .28]);
ylabel('Eye Position Y (deg)')
xlabel('Eye Position X (deg)')


%% initialize basic variables
trn = 1; %Trial number tracker
horiB = [0;1];
vertB = [0;1];

%% add dropdown menu items
gm(1) = uimenu('label','Saccade Trigger Analysis Interface');
gm(2) = uimenu(gm(1),'label','Load Trial Block','callback','D=LoadData;trn=1;Plotter');
gm(3) = uimenu(gm(1),'label','Automatic Saccade Onset Marking','callback','D=SaccSet(D);Plotter');
gm(4) = uimenu(gm(1),'label','Save Data-Matrix','callback','param = ExtractData(D);');

cd(origPath)
%% add buttons & controls
h.goToTrial = uicontrol('Style','text','String','Go to trial #','Visible','off',...
    'units','normalized','Position', [0.7 0.25 0.05 0.025]);
h.edit = uicontrol('Style','edit','Visible','off',...
    'units','normalized','Position', [0.75 0.25 0.025 0.025]);
h.go = uicontrol('Style','pushbutton','String','Go','Visible','off',...
    'units','normalized','Position', [0.775 0.25 0.025 0.025], 'Callback',...
    'trn=str2num(get(h.edit,''String''));Plotter');
h.nextTrial = uicontrol('Style', 'pushbutton', 'String', 'Next trial','Visible','off',...
    'units','normalized','Position', [0.75 0.3 0.05 0.025], 'Callback', 'trn=trn+1;Plotter');
h.previousTrial = uicontrol('Style', 'pushbutton', 'String', 'Previous trial','Visible','off',...
    'units','normalized','Position', [0.7 0.3 0.05 0.025], 'Callback', 'trn=trn-1;Plotter');
h.trialGood = uicontrol('Style', 'pushbutton', 'String', 'Trial GOOD', 'foregroundcolor', 'g',...
    'units','normalized','Position', [0.7 0.35 0.05 0.025],'Visible','off',...
    'Callback','D{trn}.good=rem(D{trn}.good+1,2);GoodBadToggle');