%% Exploratory analysis for producing Figures 7 and 8 phase plots for all trials. 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function creates a phase plot of PE by RS using the
%masterAnalysisParams file which contains data from all
%trials,subjects,sessions. The user can choose between plotting several
%different behaviours and also how many random example trials to plot

loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams'; %Set to where analysis params are found
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';%Set to where analysis code is found
savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Analysis 5'; %Set a save path

cd(loadPath)
matList1 = what; matList1 = matList1.mat;
file = matList1(contains(matList1,'Master'));
file = file{1};

%Takes a while as its a big file
load(string(file))

condition = 0; %0-clear, 1-blurred
behaviour = 0; %0-sacc, 1-smooth
x_axis = 0; %0-PE, 1-PEpred

%Choose number of random example trials to plot
num_trials = 1;
cd(origPath);
C = linspecer(num_trials,'qualitative');
step_ind = 505;

%For smooth trials, users can downsample for a cleaner figure
dsn = 2; %downsample nth sample. 
switch condition
    case 0 %clear condition only
        switch behaviour
            case 0 %sacc trials only
                switch x_axis
                    case 0 %PE
                        x = Txe_sacc_clear_all(:,1);
                        y = Txe_sacc_clear_all(:,2);
                        rt = RT_sacc_clear_all;
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = data_clear_all(trial_ind, 11);
                        m = PE_sacc_clear_all;
                        n = RS_sacc_clear_all;
                    case 1 %PEpred
                        x = data_clear_all(:,2);
                        y = Txe_sacc_clear_all(:,2);
                        rt = RT_sacc_clear_all;
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = data_clear_all(trial_ind, 11);
                        m = PE_pred_sacc_clear_all;
                        n = RS_sacc_clear_all;
                end
            case 1 %smooth trials only
                switch x_axis
                    case 0 %PE 
                        x=downsample(PE_smooth_clear_all(:,step_ind:step_ind+400)',dsn)';
                        y=downsample(RS_smooth_clear_all(:,step_ind:step_ind+400)',dsn)';
                        m = Txe_sacc_clear_all(:,1);
                        n = Txe_sacc_clear_all(:,2);
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = smooth_data_clear_all(trial_ind, 11);
                    case 1 %PEpred
                        x=downsample(PE_pred_smooth_clear_all(:,step_ind:step_ind+400)',dsn)';
                        y=downsample(RS_smooth_clear_all(:,step_ind:step_ind+400)',dsn)';
                        m = data_clear_all(:,2);
                        n = Txe_sacc_clear_all(:,2);
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = smooth_data_clear_all(trial_ind, 11);
                end
                
           end
    case 1 %blurred condition only
        switch behaviour
            case 0 %sacc trials only
                switch x_axis
                    case 0 %PE
                        x=Txe_sacc_blurred_all(:,1);
                        y=Txe_sacc_blurred_all(:,2);
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = data_blurred_all(trial_ind, 11);
                        disp(trial_ind);
                        m=PE_sacc_blurred_all;
                        n=RS_sacc_blurred_all;
                        rt = RT_sacc_blurred_all;
                    case 1 %PEpred
                        x=data_blurred_all(:,2);
                        y=Txe_sacc_blurred_all(:,2);
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = data_blurred_all(trial_ind, 11);
                        m=PE_pred_sacc_blurred_all;
                        n=RS_sacc_blurred_all;
                        rt = RT_sacc_blurred_all;
                end
            case 1 %smooth trials only
                switch x_axis
                    case 0 %PE
                        x=downsample(PE_smooth_blurred_all(:,step_ind:step_ind+400)',dsn)';
                        y=downsample(RS_smooth_blurred_all(:,step_ind:step_ind+400)',dsn)';
                        m = Txe_sacc_blurred_all(:,1);
                        n = Txe_sacc_blurred_all(:,2);
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = smooth_data_blurred_all(trial_ind, 5);
                    case 1 %PEpred
                        x=downsample(PE_pred_smooth_blurred_all(:,step_ind:step_ind+400)',dsn)';
                        y=downsample(RS_smooth_blurred_all(:,step_ind:step_ind+400)',dsn)';
                        m = PE_sacc_blurred_all;
                        n = RS_sacc_blurred_all;
                        trial_ind = randi(size(x,1),[1,num_trials]);
                        trial_ids = smooth_data_blurred_all(trial_ind, 5);
                end
                
        end
end


f = figure('units','normalized','outerposition',[0,0,1,1]);
orient(f,'landscape')
hold on

%When plotting smooth trials, users should replace line 126 with line 125 to plot only a
%subset of trials, since the number of samples for smooth trials is much
%higher and the figure looks incomprehensible if all trials are plotted

%plot(x(600:800,:),y(600:800,:),'.','Color',[0.2 0.2 0.2 0.2],'MarkerSize',5)
plot(x,y,'.','Color',[0.2 0.2 0.2 0.2],'MarkerSize',5)
plot([-20,20],[0,0],'-k')
plot([0,0],[-80,80],'-k')

%% example trials used in the paper
%trial_ids = [1256.30 1053.33 7107.23 1365.20] %1053.33]% 960.30 1580.10 1256.30]; %clear trial examples
%trial_ids = [1359.10 420.16 1355.32 1578.46]; %blurred trial examples
%trial_ids = [562.429999999999999];%smooth clear
%trial_ids = [2106.47]; %smooth blurred
%num_trials = length(trial_ids);
%%

C = linspecer(num_trials,'qualitative');
trial_ind=[];
for i=1:num_trials
trial_ind(i) = find(data_clear_all(:,11) == trial_ids(i));
end
switch behaviour
    case 0
        for i = 1:num_trials
            plot(m(trial_ind(i),step_ind:step_ind-100+rt(trial_ind(i))), n(trial_ind(i),step_ind:step_ind-100+rt(trial_ind(i))),'o','Color',C(i,:),'MarkerFaceColor',C(i,:))
            plot(m(trial_ind(i),step_ind-100+rt(trial_ind(i))), n(trial_ind(i),step_ind-100+rt(trial_ind(i))),'ok','MarkerSize',15,'MarkerFaceColor',C(i,:))
            plot(m(trial_ind(i),step_ind-100+rt(trial_ind(i))), n(trial_ind(i),step_ind-100+rt(trial_ind(i))),'ok','Color',C(i,:),'MarkerSize',10,'MarkerFaceColor','k')

        end
    case 1 
        for i = 1:num_trials
            plot(x(trial_ind(i),1:end), y(trial_ind(i),1:end),'o','Color',C(i,:),'MarkerFaceColor',C(i,:))
            plot(x(trial_ind(i),end), y(trial_ind(i),end),'ok','MarkerSize',15,'MarkerFaceColor',C(i,:))
            plot(x(trial_ind(i),end), y(trial_ind(i),end),'ok','Color',C(i,:),'MarkerSize',10,'MarkerFaceColor','k')
        end
end
ylim([-80, 80])
xlim([-20, 20])
           
xlabel('Position Error (deg)');
ylabel('Retinal Slip (deg/s)');
set(gca,'FontSize',30);
set(gca,'FontWeight','Bold')
%Uncomment to see the same random trials plotted on a position time-graph.
%Its important user has organized the labeled data files according to the
%instructions in the readme for the following function to work
%appropriatley and find the correct trial to plot


%plotTrial(trial_ids)

  
