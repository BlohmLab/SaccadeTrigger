%% Interactive analysis plotter to observe effects of changing analysis parameters such as dt, sampling point etc 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This reaction time analysis interface reproduces Figure 9 and 10 using the RTReplot function but the
%user can now interact with the graph by changing where the input is
%sampled from, whether to sort by absolute VS or not, and how far to
%extrapolate into the future.

%For reference, the paper used an extrapolation time of 150ms (0.15) and
%sampled at step for reaction time plots. 

loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams'; %Set to where analysis params are found
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set to where analysis code is found


f = figure('Name','Reaction Time Interactive Interface','Units','normalized','Position',[.01 .01 .98 .94],'toolbar','none','NumberTitle','off');

ax(1) = axes('Units','normalized','Position',[.05 .9-1*.32 .6 .4]);
ax(2) = axes('Units','normalized','Position',[.05 .75-2*.32 .6 .4]);

dt = 0.2;
param = 1; %PEpred=1 , PE=2
sampledAt = 2;%Step = 1, PreSacc = 2
step_ind = 505;
abs_param2 = 0;
cd(origPath)
RTReplot

h.PEpredDt = uicontrol('Style','text','String','PEpred Extrapolation Time Constant','Visible','on',...
    'units','normalized','Position', [0.65 0.15 0.1 0.025]);
h.edit = uicontrol('Style','edit','Visible','on',...
    'units','normalized','Position', [0.75 0.15 0.025 0.025]);
h.go = uicontrol('Style','pushbutton','String','Refresh','Visible','on',...
    'units','normalized','Position', [0.775 0.15 0.025 0.025], 'Callback',...
    'dt=str2num(get(h.edit,''String''));RTReplot');
h.ParamChoice = uicontrol('Style', 'pushbutton', 'String', 'PEpred','Visible','on',...
    'units','normalized','Position', [0.70 0.2 0.05 0.025], 'Callback', 'param=1;RTReplot');
h.ParamChoice2 = uicontrol('Style', 'pushbutton', 'String', 'PE','Visible','on',...
    'units','normalized','Position', [0.75 0.2 0.05 0.025], 'Callback', 'param=2;RTReplot');
h.Abs = uicontrol('Style', 'pushbutton', 'String', 'abs(VS)','Visible','on',...
    'units','normalized','Position', [0.70 0.25 0.05 0.025], 'Callback', 'abs_param2=1;RTReplot');
h.NotAbs = uicontrol('Style', 'pushbutton', 'String', 'VS','Visible','on',...
    'units','normalized','Position', [0.75 0.25 0.05 0.025], 'Callback', 'abs_param2=0;RTReplot');
h.SampledAt1 = uicontrol('Style','pushbutton','String','At Step','Visible','on',...
    'units','normalized','Position', [0.80 0.3 0.05 0.025], 'Callback', 'sampledAt=1;RTReplot');
h.SampledAt2 = uicontrol('Style','pushbutton','String','At SaccOnset - SensoryDelay','Visible','on',...
    'units','normalized','Position', [0.70 0.3 0.1 0.025], 'Callback', 'sampledAt=2;RTReplot');