%% First pass through data to separate data into analysis chunks and remove unwanted data. 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function operates on the master data files for each subject and
%removes all the trials that were manually flagged or flagged by the
%extract file. Function also plots global overview of data from
%participants including how many trials were left after filtering, and what
%proportions of each flag were present. Function saves 2 files per subject,
%one for clear and one for blurred target condition (0 or 1) and an
%additional file containing overall trial numbers.

clear
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set to where analysis code is found
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Master'; %Set to where master data files are found
filtPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Filtered'; %Assign a filtered folder path

%Choose any master file to begin filtering
cd(loadPath)
[file,path] = uigetfile({'*.mat'},'Choose a file to determine master folder path'); %load in mat-file = Trial parameters
cd(path)
matList = what; matList = matList.mat;
global_stats = [];
flags = [25,14,28, 29, 30, 31, 27, 26]; %Good/Bad Trial, smooth trials if 14==NaN, Saccade during step, RT shorter than 50ms, wrong direction, double sacc, -100ms sac, -200ms sacc
filtered_data = {};
filtered_PE = {};
filtered_RS = {};
for subj = 1:length(matList)
    for j=0:1
        filename = [string(matList(subj))];
        load(filename)
        filename=char(filename);
        condition = j+1;
        
        %Separate clear and blurred target conditions
        data_for_condition = masterParams(find(masterParams(:,6) == j),:);
        PE_for_condition = masterPE(find(masterParams(:,6) == j),:);
        RS_for_condition = masterRS(find(masterParams(:,6) == j),:);
        
        %Fill in global stats per subject. 
        global_stats(subj,1,condition) = masterParams(1,1);
    
        global_stats(subj,2,condition) = length(data_for_condition); %total trials
        
        %Smooth trial if no saccade or sacc RT> 400ms
        global_stats(subj,3,condition) = sum(isnan(data_for_condition(:,14)) | data_for_condition(:,14)>400); %number of smooth trials
    
        filtered_data{1} = data_for_condition(data_for_condition(:,25)==0,:);%number of trials visually approved
        filtered_PE{1} = PE_for_condition(data_for_condition(:,25)==0,:);
        filtered_RS{1} = RS_for_condition(data_for_condition(:,25)==0,:);
        global_stats(subj,4,condition) = length(filtered_1); 
        
        ind_sacc = find(isfinite(filtered_data{1}(:,14)) & filtered_data{1}(:,14) < 400);
        filtered_data{2} = filtered_data{1}(ind_sacc,:); %after removing smooth trials
        filtered_PE{2} = filtered_PE{1}(ind_sacc,:);
        filtered_RS{2} = filtered_RS{1}(ind_sacc,:);
        ind_smooth = find(isnan(filtered_data{1}(:,14)) | filtered_data{1}(:,14) >=400);
        smooth_trials = filtered_data{1}(ind_smooth,:);
        PE_smooth = filtered_PE{1}(ind_smooth,:);
        RS_smooth = filtered_RS{1}(ind_smooth,:);
        global_stats(subj,5,condition) = length(filtered_data{2});
    
        global_stats(subj,6,condition) = mean(filtered_data{2}(:,11)); %total saccades
        global_stats(subj,7,condition) = mean(filtered_data{2}(:,12)); %total saccades on 2nd ramp
        global_stats(subj,8,condition) = mean(filtered_data{2}(:,13)); %total saccades on 1st ramp
        
        %I keep every iteration of filtering incase I would like to see how
        %the data changes if i include certain trials. 
        for flag = 3:length(flags)
            filtered_data{flag} = filtered_data{flag-1}(filtered_data{flag-1}(:,28)==0,:);%data after removing flagged trials
            filtered_PE{flag} = filtered_PE{flag-1}(filtered_data{flag-1}(:,28)==0,:);
            filtered_RS{flag} = filtered_RS{flag-1}(filtered_data{flag-1}(:,28)==0,:);
            global_stats(subj,i+6,condition) = length(filtered_data{flag-1});
        end
        cd(filtPath)
        save([filename(1:end-4) '_' num2str(j) '_' 'Filtered.mat'], 'filtered_data', 'filtered_PE', 'filtered_RS',...
            'data_for_condition', 'PE_for_condition', 'RS_for_condition','smooth_trials','PE_smooth','RS_smooth')
        cd(loadPath)
    end
    

end
A= sortrows(global_stats(:,:,1));
B= sortrows(global_stats(:,:,2));
global_stats=cat(3,A,B);
y=zeros(size(global_stats,1),9,2);
for subj = 1:size(global_stats,1)
    for j = 1:2
    y(subj,1,j) = global_stats(subj,end,j);
    y(subj,2:9,j) = abs(diff(global_stats(subj,[2,4,5,9:14],j)));
    end
end
figure
hold on
subplot(2,1,1)

Hbar = bar(y(:,:,1),'stacked');
for subj = 1:size(global_stats,1)
    xlabels{subj} = strcat('Subject ',num2str(global_stats(subj,1,1)));
end
legend('Remaining Saccade Trials','Visually Discarded', 'Smooth Trials', 'Saccades During Step', 'Saccade RT<50', 'Wrong Direction Saccades', 'Double Saccades','Saccades -100','Saccades -200')
set(gca,'xticklabel',xlabels)
ylim([0,2500])
title('Clear Condition')
hold off

hold on
subplot(2,1,2)
Hbar2 = bar(y(:,:,2),'stacked');
set(gca,'xticklabel',xlabels)
legend('Remaining Saccade Trials','Visually Discarded', 'Smooth Trials','Saccades During Step', 'Saccade RT<50', 'Wrong Direction Saccades', 'Double Saccades','Saccades -100','Saccades -200')
title('Blurred Condition')
hold off

cd(loadPath)
save(['SummaryStats.mat'],'global_stats')
cd(origPath)