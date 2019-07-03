%% Final data extraction function for the specific pre-registered analyses. 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function operates on the filtered data files and computes parameters
%such as PEpred, Txt, and Txe for each trial and saves those in a separate
%analysis matrix. This function also saves a masterAnalysisParams file
%containing all values for all subjects and sessions. 

clear

origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set to where analysis code is found
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Filtered'; %Set to where filtered data is found
savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams'; %Assign a new analysis param folder
cd(loadPath)
matList = what; matList = matList.mat;

%Initialize parameters of interest to store for all subjects
PE_pred_sacc_clear_all =[];
PE_pred_smooth_clear_all = [];
Txe_sacc_clear_all = [];
Txe_smooth_clear_all = [];
Txe_sacc_blurred_all = [];
Txe_smooth_blurred_all = [];
Txt_sacc_clear_all =[];
Txt_smooth_clear_all = [];
Txt_sacc_blurred_all =[];
Txt_smooth_blurred_all = [];
wrongdir = [];
goodsac = [];
VS_all = [];
PS_all = [];
RT_sacc_clear_all = [];
data_clear_all = [];
data_blurred_all = [];
smooth_data_blurred_all=[]; 
smooth_data_clear_all=[];
PE_sacc_clear_all = [];
PE_smooth_clear_all = [];
RS_smooth_clear_all=[];
RS_sacc_clear_all=[];
PE_pred_sacc_blurred_all = [];
PE_pred_smooth_blurred_all = [];
PE_sacc_blurred_all = [];
RS_sacc_blurred_all = [];
PE_smooth_blurred_all=[];
RS_smooth_blurred_all=[];
RT_sacc_blurred_all = [];

%Here we use the 7th filtered iteration, i.e. remove all flags except
%trials where some saccades where present -200ms from step
for i = 1:length(matList)
    %% Load file from filetered folder
    load(string(matList(i)));
    
    %% Record the subject and conditon 
    subjectID = string(data_for_condition(1,1));
    condition = string(data_for_condition(1,6));
    
    %% Extend the all-trial matrices
    VS = filtered_data{7}(:, 10);
    PS = filtered_data{7}(:,8);
    PS_smooth = smooth_trials(:,8);
    VS_smooth = smooth_trials(:,10);
    VS_all = [VS_all; filtered_data{7}(:,10)];
    PS_all = [PS_all; PS];
    
    %Calculate continuous PE_pred for all trials in file
    PE_pred = filtered_PE{7} + filtered_RS{7}.*0.15;

    PE_pred_smooth = PE_smooth + RS_smooth.*0.15;
    
    
    
    RT = filtered_data{7}(:,14);
    PE_sacc = filtered_data{7}(:,20);
    RS_sacc = filtered_data{7}(:, 21);
    switch condition
        case '0'
            PE_pred_sacc_clear_all = [PE_pred_sacc_clear_all; PE_pred];
            PE_pred_smooth_clear_all = [PE_pred_smooth_clear_all; PE_pred_smooth];
            PE_sacc_clear_all = [PE_sacc_clear_all;filtered_PE{7}];
            RS_sacc_clear_all = [RS_sacc_clear_all;filtered_RS{7}];
            PE_smooth_clear_all=[PE_smooth_clear_all;PE_smooth];
            RS_smooth_clear_all=[RS_smooth_clear_all;RS_smooth];
            RT_sacc_clear_all = [RT_sacc_clear_all; RT];
            Txe_sacc_clear_all = [Txe_sacc_clear_all; [PE_sacc, RS_sacc]];
            Txt_sacc_clear_all = [Txt_sacc_clear_all; [PS, VS]];
            Txe_smooth_clear_all = [Txe_smooth_clear_all; PE_smooth; RS_smooth];
            Txt_smooth_clear_all = [Txt_smooth_clear_all; [PS_smooth, VS_smooth]];
        case '1'
            PE_pred_sacc_blurred_all = [PE_pred_sacc_blurred_all; PE_pred];
            PE_pred_smooth_blurred_all = [PE_pred_smooth_blurred_all; PE_pred_smooth];
            PE_sacc_blurred_all = [PE_sacc_blurred_all;filtered_PE{7}];
            RS_sacc_blurred_all = [RS_sacc_blurred_all;filtered_RS{7}];
            PE_smooth_blurred_all=[PE_smooth_blurred_all;PE_smooth];
            RS_smooth_blurred_all=[RS_smooth_blurred_all;RS_smooth];
            RT_sacc_blurred_all = [RT_sacc_blurred_all; RT];
            Txe_sacc_blurred_all = [Txe_sacc_blurred_all; [PE_sacc, RS_sacc]];
            Txe_smooth_blurred_all = [Txe_smooth_blurred_all; PE_smooth; RS_smooth];
            Txt_sacc_blurred_all = [Txt_sacc_blurred_all; [PS, VS]];
            Txt_smooth_blurred_all = [Txt_smooth_blurred_all; [PS_smooth, VS_smooth]];
    end
    
    %Show the total number of saccade trials flagged as wrong direction
    %saccades
    wrongdir = [wrongdir; filtered_data{3}(find(filtered_data{3}(:,30)==1),14)];
    
    %Reaction time of all visually approved saccadic trials
    goodsac = [goodsac; filtered_data{3}(find(filtered_data{3}(:,30)==0),14)];
    
    %unique trial numbers
    trials = filtered_data{7}(:,5);
    
    %% Single subject parameters
    %Following code is to extract data matrix for each individual subject
    %for within subject analysis
    
    % Extract PE_pred estimate before the saccade of interest, averaged
    % over 50ms or up to the second target step if reaction time is small
    
    %Note, index 505 is the moment of target step.
    for j = 1:size(PE_pred,1)
        
        %Cut off at 125 so you don't sample PEpred before the target stpe
        if RT(j) < 125
            sacInd = 505; %ind of second target step in the PEpred matrix. 
            window = RT(j) - 100;
            s = round(sacInd);
            if window > 0
                e = round(sacInd + window);
            else
                e = round(sacInd + 1);
            end
        else
        sacInd = RT(j) + 505 - 100; %index of -100ms from saccade in the PE /RS matrix
        s = round(sacInd - 25);
        e = round(sacInd +25);
        end
        data(j,1) = RT(j); % RT for saccade trials
        data(j,2) = mean(PE_pred(j,[s:e])); % Pe pred for saccade trials
        data(j,3) = (-PS(j)/VS(j))*1000; %Txt for saccade trials
        if isnan(data(j,3)) %incase both PS and VS are zero, avoid returning NaN
            data(j,3) = 0;
        end
        if RT(j) <=100
            pe = filtered_PE{7}(j,505);
            rs = nanmean(filtered_RS{7}(j,505:550));
            data(j,4) = (-filtered_data{7}(j,20)/filtered_data{7}(j,21))*1000; %Txe for saccade trials
            if isnan(data(j,4))
                data(j,4) = 0;
            end
        else
            pe=filtered_data{7}(j,20);
            rs=filtered_data{7}(j,21);
            data(j,4) = (-pe/rs)*1000; %Txe for saccade trials
        end
        data(j,5) = VS(j); %target velocity step
        data(j,[6:10]) = filtered_data{7}(j,[6:10]); %trial information %refer to CSExtract
        data(j,11) = filtered_data{7}(j,5); %Unique trial id
        data(j,12) = mean(PE_pred(j,505:505+50)); %PEpred averaged over 50ms from step
        data(j,13) = filtered_data{7}(j,17) - filtered_data{7}(j,16); %saccade amplitude
        data(j,14) = pe; %PE-100ms
        data(j,15) = rs;%RS - 100ms
        if abs(data(j,12)) <=5
            data(j,16) = 1;
        else
            data(j,16)=0;
        end
        data(j,17) = -filtered_PE{7}(j,505)/mean(filtered_RS{7}(j,505:550))*1000; %Txe at target step
        
        
    end
    smooth_data(:,1) = nan(size(smooth_trials,2),1);
    smooth_data(:,2) = mean(PE_pred_smooth(:,505:905),2); %PEpred averaged over entire trial
    smooth_data(:,3) = -PS_smooth./VS_smooth * 1000; %Txt for smooth trials
    smooth_data(:,4) = -mean(PE_smooth(:,505:905)./RS_smooth(:,505:905),2)*1000; %Txe for smooth trials averaged over ramp
    smooth_data(:,5) = VS_smooth(:); %Velocity step of smooth trials
    smooth_data(:,[6:10]) = smooth_trials(:,[6:10]); %Trial info from extract file
    smooth_data(:,11) = smooth_trials(:,5); % Unique trial ID
    smooth_data(:,12) = mean(PE_pred_smooth(:,505:505+50),2); %PEpred averaged over 50ms from step.
    smooth_data(:,[13:14]) = nan(size(smooth_trials,2),4); %filler columns to match size of data variable
    smooth_data(find(abs(smooth_data(:,12))<=5),16)=1; %Flag for small PEpred for later analysis
    smooth_data(:,17) = -PE_smooth(:,505)./mean(RS_smooth(:,505:550),2)*1000; %Txe at step
    switch condition
        case '0'
            data_clear_all = [data_clear_all; data];
            smooth_data_clear_all= [smooth_data_clear_all; smooth_data];
        case '1'
            data_blurred_all = [data_blurred_all; data];
            smooth_data_blurred_all= [smooth_data_blurred_all; smooth_data];
    end
    filename = strcat('S',subjectID,'C',condition,'analysisParams');
    cd(savePath)
    save(filename, 'data', 'smooth_data', 'PE_pred', 'PE_pred_smooth','PE_sacc','RS_sacc','trials','subjectID', 'condition','filtered_PE{7}','PE_smooth','filtered_RS{7}','RS_smooth')
    clear('data', 'smooth_data', 'PE_pred', 'PE_pred_smooth','PE_sacc','RS_sacc','trials','subjectID', 'condition')
    cd(loadPath)
end
cd(savePath)
save('MasterAnalysisParams', 'PE_pred_sacc_clear_all','PE_pred_smooth_clear_all','Txe_sacc_clear_all','Txe_smooth_clear_all','Txt_sacc_clear_all','Txt_smooth_clear_all',...
    'Txe_sacc_blurred_all','Txe_smooth_blurred_all','Txt_sacc_blurred_all','Txt_smooth_blurred_all','wrongdir','goodsac','PS_all','VS_all','RT_sacc_clear_all','RT_sacc_blurred_all','data_clear_all','smooth_data_clear_all','data_blurred_all','smooth_data_blurred_all','PE_sacc_clear_all','PE_smooth_clear_all','RS_sacc_clear_all','RS_smooth_clear_all',...
    'PE_sacc_blurred_all','PE_smooth_blurred_all','RS_sacc_blurred_all','RS_smooth_blurred_all','PE_pred_sacc_blurred_all','PE_pred_smooth_blurred_all')
cd(loadPath)