%% Generate Trial for Double Step Ramp Task

%Author: Omri Nachmani
%Affiliation: Blohm Lab, Queen's Universty, Kingston, Ontario, Canada

% This function generates a target trajectory matrix of pixel positions for a double step ramp task (de Brouwer 2002)
% This function is called within the SaccadeTrigger.m file. 

%Arguments:
    %dist_to_screen: Required for accurate degree of visual field estimation
    %frame_rate: to calculate trajectory durations and necessary frames
    %ppcmx: conversion ratio from cm to pixels.
    

%Output:
    %trialMatrix:
       %time_matrix: empty, filled in when task is running
       %trajectory_pixels: used to draw pixels to appropriate location on the screen
       %trajectory_deg: used for analysis and plotting offline
       %velocity: Velocity of target during each frame. Magnitude of
                  %velocities during the steps is set to the preceeding velocities. 
                  
function [initial_condition, trial_matrix, frame_info] = generateTrial(dist_to_screen, frame_rate, ppcmx)

%% set initial target motion parameters
%Each trial can start 20 degrees left or right of center of screen.
%Initial step direction is always away from screen and its magnitude
%depends on the position ramp (velocity step) that follows. 


initial_params = [20 20 20 -20 -20 -20;
                  6 4 2 -2 -4 -6;
                  -30 -20 -10 10 20 30];

% randomizes one of the above conditions
initial_condition = initial_params(:, randi(6)); 

%Second velocity step is completely random on a continous scale from -50 to
%50 and also determines the size of step 2.
VS_2 = randi([-50 50],1,1); 

%if block ensures that the target crossing time for second step (PS_2) is within
%1s (-1<Txt<1)

if abs(VS_2) >= 20;
    PS_2 = randi([-20 20],1,1);
elseif abs(VS_2) <= 10;  
    PS_2 = randi([-10 10],1,1);
elseif 10<abs(VS_2)<20
    PS_2 = randi([-abs(VS_2) abs(VS_2)],1,1);
end
initial_condition(4) = PS_2;
initial_condition(5) = VS_2 + initial_condition(3);

%% Set duration of each target motion 

%Duration of each part of the trajectory is randomized within a certain
%range.
dur_ramp_1 = randi([600,800],1);%ms
dur_ramp_2 = randi([500,700],1);%ms
dur_fix_1 = randi([200, 600],1);%ms
dur_fix_2 = 1000; %ms

%Convert duration in ms to number of frames according to the frame rate/1000 to convert from s to ms,
n_fix_1_frames = floor((dur_fix_1)*frame_rate/1000);
n_fix_2_frames = floor((dur_fix_2)*frame_rate/1000);
n_ramp_1_frames = floor((dur_ramp_1)*frame_rate/1000);
n_ramp_2_frames = floor((dur_ramp_2)*frame_rate/1000);

%Create a frame info variable containing the event markets for fixation,
%steps, and ramps
event1 = 1; %fixation starts
event2 = n_fix_1_frames + 1; %First stpe occurs
event3 = n_fix_1_frames + 2; %Ramp starts immediately after first step
event4 = n_fix_1_frames+ 1 + n_ramp_1_frames + 1; %Second stap occurs after first ramp
event5 = n_fix_1_frames + 1 + n_ramp_1_frames + 2; %Second ramp after second step
event6 = n_fix_1_frames + 1 + n_ramp_1_frames + 1 + n_ramp_2_frames + 1; %Second fixation after second ramp
frame_info = [event1 event2 event3 event4 event5 event6];

%Here I creat a position and time matrix for the entire trial by creating smaller
%matrices for each section of the trail and adding them all at the end. Not very efficient but it works

%Note:
    %Matrix is created in degrees first, then converted to cm on the plane
    %of the screen using trigonometry, and then to pixels using the ppcmx
    %conversion. 
    
    
%fill a matrix the length of first fixation with the initial position of
%the target
fix_matrix = nan(1, n_fix_1_frames);
fix_matrix(1:n_fix_1_frames) = initial_condition(1);

%Position after first step is initial position plus step size (i.e. 20 + 2=22 degrees)
step_1 = initial_condition(1) + initial_condition(2);

%log last position of target
x_location = step_1

%Using previously logged x_location, fill in ramp 1 variables using the
%velocity (deg/s) for the duration of the ramp up to the final location.
ramp_1_matrix = nan(1,n_ramp_1_frames);
ramp_1_matrix(1:n_ramp_1_frames) = (x_location+initial_condition(3)/frame_rate:(initial_condition(3)/frame_rate):(x_location + (initial_condition(3)*n_ramp_1_frames/frame_rate)));

%re-log the last location of the target
x_location = (x_location + (initial_condition(3)*n_ramp_1_frames/frame_rate));

%Add the second step to the last target location
step_2 = x_location + initial_condition(4);

%relog last location
x_location = step_2;

ramp_2_matrix = nan(1,n_ramp_2_frames);
%Sometimes the velocity step cancels out the initial velocity and the
%resulting velocity is 0. When this occurs, I fill the second ramp matrix
%with the last location of the target
if initial_condition(5)==0
    ramp_2_matrix(1:n_ramp_2_frames) = ones(n_ramp_2_frames,1)*x_location;
    x_location = x_location;
else
    ramp_2_matrix(1:n_ramp_2_frames) = (x_location+ initial_condition(5)/frame_rate:(initial_condition(5)/frame_rate):(x_location + (initial_condition(5)*n_ramp_2_frames/frame_rate)));
    
    %Log the last location of the target
    x_location = (x_location + (initial_condition(5)*n_ramp_2_frames/frame_rate));
end

%Target stays at its last location for 1s before the next trial begins
fix_2_matrix = nan(1, n_fix_2_frames);
fix_2_matrix(1:n_fix_2_frames) = x_location;

%Concatenate the entire motion trajectory into one matrix
motion_matrix_deg = [fix_matrix step_1 ramp_1_matrix step_2 ramp_2_matrix fix_2_matrix]';

%Convert to cm on the plane of the screen using trig
motion_matrix_cm = tan(motion_matrix_deg.*pi/180)*dist_to_screen;

%Convert to pixels using the ppcmx conversion factor
motion_matrix_pixels = motion_matrix_cm .* ppcmx;

%Create time matrix that is the length of the target trajectory in frames
time_matrix = zeros(length(motion_matrix_pixels),1);

%Create a velocity matrix containing the velocity of the target in each
%frame
v_matrix = [zeros(1,n_fix_1_frames) ones(1,n_ramp_1_frames+1)*initial_condition(3) ones(1,n_ramp_2_frames+1)*initial_condition(5) zeros(1,n_fix_2_frames)]';

%Package all relevant matrices together
trial_matrix = [time_matrix motion_matrix_pixels motion_matrix_deg v_matrix];

