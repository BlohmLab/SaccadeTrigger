%% Exploratory analysis for producing Figures 9 and 10 for behavioural trends of trigger times based on PEpred and Txe. 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function operates on the filtered data files and computes parameters
%such as PEpred, Txt, and Txe for each trial and saves those in a separate
%analysis matrix. This function also saves a masterAnalysisParams file
%containing all values for all subjects and sessions. 

clear 
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams'; %Set to where analysis params are found
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set to where analysis code is found
cd(loadPath)
matList = what; matList = matList.mat;
conditions{1} = matList(contains(matList,'C0'));
conditions{2} = matList(contains(matList,'C1'));
x = [];
%Choose which plot to create 
% reactiontime or proportion
plot_type = 'reactiontime';
%Param list and related edges used in analysis
% 1: Reaction (Trigger) time
% 12: PEpred at target step, edges = [5, -5] (Pre registerd hypotheses 1 and 3)
% 3: Txt, edges [0 400] (Pre registered hypotheses 2 and 3)
% 17: Txe, at target step, edges = [0,400]
% 2: PEpred 100ms before saccade
% 4: Txe 100ms before saccade
% 5: VS 
param1=12;
param2=5;

%Choose whether to take the absolute of Param2 or not, 0=not abs, 1=abs
abs_param2 = 1;
for k = 1:2
    list = conditions{k};
for i = 1:length(list)
    if k==1
    cd(loadPath)
    load(string(list(i)))
    if strcmp(plot_type,'reactiontime') %Reaction time data does not include smooth trials
        x = [x; data(:,[1, param1,param2,7,11])];
    elseif strcmp(plot_type,'proportion') %Proportion data includes smooth and saccade trials
        x = [x; ones(length(data(:,1)),1), data(:,[param1,param2,1])];
        x = [x; zeros(length(smooth_data(:,2)),1), smooth_data(:,[param1,param2]),zeros(length(smooth_data),1)];
    end
    end
end
end

if param1 == 12
    edges = [-inf -20:2:20 inf];
elseif param1 == 3 | param1 ==4
    edges = [-inf -400:40:600 inf];
else
    edges = [-inf -20:2:20 inf];
end
bins_param1 = length(edges)-1;
if abs_param2 ==1
    edges2 = [-inf 10:10:40 inf];
    x_ind = discretize(abs(x(:,3)), edges2);
else
    edges2 = [-inf -40:10:40 inf];
    x_ind = discretize(x(:,3), edges2);
end


bins_param2 = length(edges2)-1;
plot_cell = cell(bins_param2,3);
trial_ids = cell(bins_param2,bins_param1);
for i = 1:bins_param2
    plot_cell{i,1} = x(find(x_ind==i),:);
    plot_cell{i,2} = discretize(plot_cell{i,1}(:,2), edges);
    for j = 1:bins_param1
        plot_cell{i,3}(1,j) = mean(plot_cell{i,1}(find(plot_cell{i,2}==j),1));
        plot_cell{i,3}(2,j) = std(plot_cell{i,1}(find(plot_cell{i,2}==j),1));
    end
end

figure
hold on
bins2plot = [1:bins_param2];
N = length(bins2plot);
cd(origPath)
C = linspecer(N,'sequential');
for i=1:N
    plot(edges(1:end-1), plot_cell{bins2plot(i),3}(1,:),'o-','color',C(i,:),'LineWidth',2);
    
end
 for i=1:N
 errorbar(edges(1:end-1),plot_cell{bins2plot(i),3}(1,:),[], plot_cell{bins2plot(i),3}(2,:),'-','color',C(i,:),'LineWidth',2);
 end
if param1 == 3
    xlabel('T_x_t')
elseif param1 ==4
    xlabel('T_x_e')
elseif param1 ==12
    xlabel('PE_p_r_e_d')
end
ylabel('Saccade Reaction Time (ms)')
if strcmp(plot_type, 'proportion')
    ylim([0,1])
end
if strcmp(plot_type, 'reactiontime')
    ylim([0,400])
end
if abs_param2 == 1
    if bins_param2 == 5
        legend('VS0-10','VS10-20','VS20-30','VS30-40','VS40-50')
    elseif bins_param2 == 10
        legend('VS0-5','VS5-10','VS10-15','VS15-20','VS20-25','VS25-30','VS30-35','VS35-40','VS40-45','VS45-50')
    end
elseif abs_param2 == 0
    if bins_param2 == 10
        legend('VS-50-40','VS-40-30','VS-30-20','VS-20-10','VS-10-0','VS0-10','VS10-20','VS20-30','VS30-40','VS40-50') 
    end
end
set(gca,'FontSize',20)
set(gca,'FontWeight','Bold')

cd(origPath)
