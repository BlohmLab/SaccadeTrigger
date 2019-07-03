%% Analysis for pre-registered hypotheses4 regarding the effects of VS and Txt on trigger times

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function loads the analysis params for each subject and condition and
%discretizes the DataStruct into bin sizes chosen by the user. For the published
%paper, we used +5 and -5 as the edges. The user can also input the
%parameter to discretize.

%The two-way ANOVA were computed on SPSS using the 'med' and 'quartile' variables. To do so, the resulting
%matrices from this analysis code were copied over to SPSS. 

clear 
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams';
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';
cd(loadPath)
matList1 = what; matList1 = matList1.mat;
conditions{1} = matList1(contains(matList1,'C0'));
conditions{2} = matList1(contains(matList1,'C1'));
subjectorder = [];
param1 = 3;
param2 = 5;

%Param list and related edges used in analysis
% 1: Reaction (Trigger) time
% 12: PEpred at target step, edges = [5, -5] (Pre registerd hypotheses 1 and 3)
% 3: Txt, edges [0 400] (Pre registered hypotheses 2 and 3)
% 17: Txe, at target step, edges = [0,400]
% 2: PEpred 100ms before saccade
% 4: Txe 100ms before saccade
% 5: VS 

switch param1
    case 12
        edges = [-5 5];
        bins2plot_1 = [1,2,3];
    case 3
        edges = [0, 400];
        bins2plot_1 = [1,2,3];
    case 4
        edges = [0, 400];
        bins2plot_1 = [1,2,3];
end
switch param2
    case 12
        edges2 = [=5 5];
        bins2plot_2 = [1,2,3];
    case 5
        edges2 = [10:10:40];
        bins2plot_2 = [1,3,5];
end
bins_param1 = size(edges,2)+1;
bins_param2 = size(edges2,2)+1;


cd(origPath)
[meanRT, sigmas, quartile, med, numTrials, DataStruct, subjectorder] = discretizeBinsTwice(edges,edges2,param1, param2, conditions,loadPath);



y = zeros(length(bins2plot_1), length(bins2plot_2),2);
e = zeros(length(bins2plot_1), length(bins2plot_2),2);
x = [];
w = [];
for k=1:2
    for i=bins2plot_1
        x =[x ;mean(med(:,bins2plot_2+(i-1)*bins_param2,k),1)];
        w = [w ;mean(quartile(:,bins2plot_2+(i-1)*bins_param2,k),1)];
    end
    y(:,:,k) = x;
    e(:,:,k) = w;
    x = [];
    w = [];
 end
f = figure('units','normalized','outerposition',[0,0,1,1]);
legendtxt = {'VS0-10','VS20-30','VS40-50'};
switch param1
    case 12
        labels = {'<-7.5', '-2.5<PEpred<2.5','>7.5'};
        x_label='PEpred';
    case 3
        labels = {'<0','0-400','>400'};
        x_label='Txt';
    case 4
        labels = {'<0','0-400','>400'};
        x_label='Txe';
end
switch param2
    case 5
        legendtxt = {'VS0-10','VS20-30','VS40-50'};
    case 12
        legendtxt = {'LargeNegPE_p_r_e_d','SmallPE_p_r_e_d','LargePosPE_p_r_e_d'};
end

ngroups = size(y, 1);
nbars = size(y, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
subplot(2,1,1)

h = bar(1:length(bins2plot_1),y(:,:,1),'BarWidth',1);
xlabel(x_label)
legend(legendtxt)
set(gca,'xticklabel',labels)
hold on
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, y(:,i,1), e(:,i,1), 'k', 'linestyle', 'none');
end

hold off

ylabel('Median Reaction Time (ms)')

title('Clear')
subplot(2,1,2)

h2 = bar(1:length(bins2plot_1),y(:,:,2), 'BarWidth',1);
set(gca,'xticklabel',labels)
xlabel(x_label)
legend(legendtxt)
hold on
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, y(:,i,2), e(:,i,2), 'k', 'linestyle', 'none');
end
hold off

ylabel('Median Reaction Time (ms)')

title('Blurred')


