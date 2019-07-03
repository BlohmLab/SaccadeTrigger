%% Extracts a list of relevant trial parameters from the loaded D data structure. Saves parameters in a param matrix

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%%This function should be called from the drop down menu in the analysis 
%%interface after data has been loaded and manually inspected for bad
%%trials. This function will extract the relevant parameters for future
%%analysis in the saccade trigger study. Function re-saves the **_**D.mat
%%file with param, PE, and RS matrices. 

function param =  CSExtract(D)%;,savePath2)
    origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set path to where analysis functions are found
    savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Loaded'; %Set path to where loaded data is found
for iTrial = 1: D{1}.numTrials
    varName = sprintf('D{%i}',iTrial);
    if ~isfield(eval(varName),'sacc')
        fprintf('Saccade is not completely detected. Please go to trial %i first\n',iTrial);
        save([D{1}.dFilename],'D')
        fprintf('Only D Matrix is saved\n');
        param = []
        
        return
    end
end

%Initialize param matrix.
param = zeros(D{1}.numTrials, 33);
indDot = strfind(D{1}.edfFilename,'.'); 
indBar = strfind(D{1}.edfFilename,'_');

blockID = str2double(D{1}.edfFilename(regexp(D{1}.edfFilename,'\d'))); %returns session+block number 

%PE and RS will be sampled from -0.5s to 1s from the second target step of each trial to standardize the
%matrix size and avoid using cell arrays as they're hard to compile
PE = []; 
RS = []; 

%Iterate through all trials in the D matrix to begin assigning params 1-33.

for iTrial = 1:D{1}.numTrials
%% PE and RS matrix of equal length for all trials centered on target step
    D{iTrial}.eyePE = D{iTrial}.target_x_interp - D{iTrial}.eyeX;           % position error between eye and target position over entire trial
    D{iTrial}.eyeRS = D{iTrial}.target_v_interp - D{iTrial}.eyeXv;          %Retinal slip over entire trial
    PE = [PE; D{iTrial}.eyePE(D{iTrial}.tStep2-500:D{iTrial}.tStep2+1000)];
    RS = [RS; D{iTrial}.eyeRS(D{iTrial}.tStep2-500:D{iTrial}.tStep2+1000)];

%% Subject & trial information
    param(iTrial,1) =  D{1}.subjectID;                                      %1,subject ID
    param(iTrial,2) =  blockID;                                             %2,block ID   
    param(iTrial,4) = iTrial;                                               %4, trial number within session. (skipped 3rd param by mistake)
    if iTrial <=9
        param(iTrial,5) = str2num(strcat(num2str(D{1}.subjectID), num2str(blockID),'.', '0', num2str(iTrial))); %Assigns unique trial ID number to replot later if necessary
    else
        param(iTrial,5) = str2num(strcat(num2str(D{1}.subjectID), num2str(blockID),'.', num2str(iTrial)));
    end
    param(iTrial,6) = D{1}.condition;                                      %5, Condition, 1=blurred, 0 = clear
    param(iTrial,7) = D{iTrial}.target_v1;                                 %7, first ramp velocity
    param(iTrial,8) = D{iTrial}.target_s2;                                 %8, second target step (PS)
    param(iTrial,9) = D{iTrial}.target_v2;                                 %9, second velocity ramp
    param(iTrial,10) = D{iTrial}.target_v2 - D{iTrial}.target_v1;          %10, velocity step (VS)

%% Saccade information

    if isempty(D{iTrial}.sacc) == 0 param(iTrial,11) = size(D{iTrial}.sacc,1); else param(iTrial,11) = 0; end %11, number of total saccades
    
%  first saccade after second step
    
    % find saccade right after the second step
    indSacc = find(D{iTrial}.t(D{iTrial}.sacc(:,1))>D{iTrial}.tStep2);
    otherSacc = find(D{iTrial}.t(D{iTrial}.sacc(:,1))<D{iTrial}.tStep2);
    if isempty(indSacc) == 1  || (D{iTrial}.t(D{iTrial}.sacc(indSacc(1),1)- (D{iTrial}.tStep2))) >= 600
        D{iTrial}.type = 0; %  its a smooth trial
        param(iTrial,12) = 0; %12, number of saccades on second ramp
    elseif isempty(indSacc) == 0
        D{iTrial}.type = 1; %type = 1 saccade trial
        param(iTrial,12) = size(indSacc,2); %12, number of saccades on second ramp
        ind = indSacc(1);
    end
    if isempty(otherSacc) == 0 param(iTrial,13) = size(otherSacc,2); else, param(iTrial,13)= 0; end % number of saccades before target step 2

%% Saccade of interest parameters
    if D{iTrial}.type == 1
        param(iTrial, 14) = D{iTrial}.t(D{iTrial}.sacc(ind,1))- (D{iTrial}.tStep2); %14,  saccade reaction time with respect to the second target step
        param(iTrial,15) =  D{iTrial}.sacc(ind,2) -  D{iTrial}.sacc(ind,1);%15, Duration of saccade to second target step, ms
        param(iTrial,16) = D{iTrial}.eyeX(D{iTrial}.sacc(ind,1)); %16,1st saccade initial x position(degree, center is 0 degree);
        param(iTrial,17) = D{iTrial}.eyeX(D{iTrial}.sacc(ind,2)); %17,1st saccade end x position(degree, center is 0 degree);
        param(iTrial,18) = nanmax(abs(D{iTrial}.eyeXv(D{iTrial}.sacc(ind,1):D{iTrial}.sacc(ind,2))));%18, maximum eye X velocity of 1st saccade(degree, center is 0 degree);
        param(iTrial,19) = D{iTrial}.eyeX(D{iTrial}.sacc(ind,1)-100); %19, fixation 100ms before 1st saccade(degree, center is 0 degree);
        param(iTrial,20) =  D{iTrial}.target_x_interp(D{iTrial}.sacc(ind,1)-100)-param(iTrial,19); %20 Position error 100ms before sacc onset %target-eye
        param(iTrial,21) = D{iTrial}.target_v2 - nanmean(D{iTrial}.eyeXv(D{iTrial}.sacc(ind,1) - 125 : D{iTrial}.sacc(ind,1) - 75));  %21, Retinal slip over 50ms interval centered 100ms before sacc onset
        param(iTrial,22) = D{iTrial}.target_x_interp(D{iTrial}.sacc(ind,1)) - param(iTrial,16); %22,Position error at beginning of saccade
        param(iTrial,23) = D{iTrial}.target_x_interp(D{iTrial}.sacc(ind,2)) - param(iTrial,17);%23, Position error at end of saccade (accuracy)
        param(iTrial,24) = D{iTrial}.target_x_interp(D{iTrial}.tStep2+5) - D{iTrial}.eyeX(D{iTrial}.tStep2);%24, position error at targt step. %Adding +5 to index since interpolation adds values in between sampling difference. 

        
    % If the trial was smooth, assign NaN to parameters that relate to saccades.  
    elseif D{iTrial}.type ==0
        param(iTrial,14:24) = NaN;
    end
    
    % Param 25 records whether trial was visually inspected and was
    % labeled as good or bad
    param(iTrial,25) = D{iTrial}.good;                                      %25,good(0) or bad(1)
    
    %Is there a saccade before the second target step that ends within 200ms of
    %the step
    if isempty(otherSacc) == 1 param(iTrial,26) = 0; param(iTrial,27) = 0; param(iTrial,28) = 0; %26,is saccade between 200-100ms before the step
                                                                           %27, is saccade within 100ms of step
                                                                           %28, is saccade during the step
    else
        timestamp = (D{iTrial}.tStep2 - D{iTrial}.t(D{iTrial}.sacc(otherSacc(end),2)));
        if timestamp > 200 param(iTrial,26)= 0; param(iTrial,27)=0; 
        elseif timestamp < 100 && timestamp > 0 param(iTrial,26) = 0; param(iTrial,27)=1; 
        else param(iTrial, 26) = 1; param(iTrial,27) = 0; end 
        if (D{iTrial}.t(D{iTrial}.sacc(otherSacc(end),1))< D{iTrial}.tStep2 && D{iTrial}.tStep2 < D{iTrial}.t(D{iTrial}.sacc(otherSacc(end),2)))==1 param(iTrial,28) = 1;    
        else param(iTrial,28)=0; end
    end  
    if param(iTrial, 14) < 80 && D{iTrial}.type == 1 param(iTrial,29) = 1; else param(iTrial,29) = 0; end %29, is reaction time faster than 50ms

% Is the saccade made to the first ramp trajectory or the second ramp
% trajectory. I check this by seeing if the distance to the target
% increases or decreases after saccade

%%Extrapolated to saccade end && First and Second ramp position of saccade
%%end > 5deg
    if D{iTrial}.type==1
    y = [D{iTrial}.target_x_interp(D{iTrial}.tStep1), D{iTrial}.target_x_interp(D{iTrial}.tStep2-20)];
    x = [D{iTrial}.tStep1, D{iTrial}.tStep2-20];
    xq = D{iTrial}.sacc(ind,2);
    pred = interp1(x,y,xq,'linear','extrap'); %Extrapolated target ramp 1 target position up to the end of saccade of interest
    extr_PE = pred - D{iTrial}.eyeX(xq); %Saccade position error to extrpolated position
    if (abs(param(iTrial,23)) - abs(extr_PE))>1 && param(iTrial,14)<200 %if the diff between above error and actual sacc error greater than one && if RT less than 200 move on to next step
        if abs(pred-D{iTrial}.target_x_interp(D{iTrial}.sacc(ind,2)))>5, param(iTrial,30) = 1; %if the diff between extrapolated target pos and actual target pos greater than 5
        elseif (abs(param(iTrial,22)) - abs(param(iTrial,23)) > 0) == 1 param(iTrial,30) = 0; %if position error at end of sacc is smaller than beginning of saccade (check direction)
        elseif (abs(param(iTrial,22)) - abs(param(iTrial,23)) < 0) == 1 param(iTrial,30) = 1; %if opposite direction i.e. position error increasing
        else param(iTrial,30)=0;
        end
    else param(iTrial,30)=0;
    end
    if param(iTrial,30) == 1
        if size(D{iTrial}.sacc,1) >= ind+1
        RT = D{iTrial}.t(D{iTrial}.sacc(ind+1,1)) - D{iTrial}.t(D{iTrial}.sacc(ind,2));
        if RT<50
            param(iTrial,33)=1;
        else param(iTrial,33)=0;
        end
        end
    else
        param(iTrial,33) =0;
    end
    end
end

discarded = length(find(param(:,25)==1))
cd(savePath)
save([D{1}.dFilename],'D','param','PE','RS');
fprintf('D Matrix and Extracted Data is saved\n');
cd(origPath)


