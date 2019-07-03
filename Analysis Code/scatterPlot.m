%% Exploratory analysis for producing Figures 14 of early,late, and smooth saccade proportions

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function uses the master analysis params to plot a a scatterplot 
%early, late, and smooth trials under different PEpred and Txt conditions.
%Code is very hacked together and far from optimally executed, but the
%resulting figures are correct and can be found in the paper. 


loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\AnalysisParams'; %Set to where analysis params are found
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';%Set to where analysis code is found
savePath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Analysis 5'; %Set a save path

cd(loadPath)
matList1 = what; matList1 = matList1.mat;
file = matList1(contains(matList1,'Master'));
file = file{1};

%Takes a while as its a big file
load(string(file))

early = data_clear_all(find(data_clear_all(:,1) < 175),:);
late = data_clear_all(find(data_clear_all(:,1) > 175),:);
smooth = smooth_data_clear_all;

early_blurred = data_blurred_all(find(data_blurred_all(:,1) < 175),:);
late_blurred = data_blurred_all(find(data_blurred_all(:,1) > 175),:);
smooth_blurred =smooth_data_blurred_all;

param1 = 12;
param2 = 3;
D = linspecer(5,'Qualitative');
edges1 = [-inf -20:2:20 inf];
edges2 = [-inf -500:50:500 inf];

ind1_early = discretize(early(:,param1),edges1); %discretize by PEpred bins
ind2_early = discretize(early(:,param2),edges2); %discretize by Txt bins
ind1_late = discretize(late(:,param1),edges1);
ind2_late = discretize(late(:,param2),edges2);
ind1_smooth = discretize(smooth(:,param1),edges1);
ind2_smooth = discretize(smooth(:,param2-1),edges2);

ind1_early_b = discretize(early_blurred(:,param1),edges1);
ind2_early_b = discretize(early_blurred(:,param2),edges2);
ind1_late_b = discretize(late_blurred(:,param1),edges1);
ind2_late_b = discretize(late_blurred(:,param2),edges2);
ind1_smooth_b = discretize(smooth_blurred(:,param1),edges1);
ind2_smooth_b = discretize(smooth_blurred(:,param2-1),edges2);
%figure

n_bin1 = length(edges1)-1;
n_bin2 = length(edges2)-1;
%figure
c_early = 'b';
c_late = 'r';
c_smooth = 'y';

s = [];
e = [];
s_b = [];
l_b = [];
l = [];
for i=1:n_bin1 %iterate by PEpred bins
    for j=1:n_bin2 %iterate by Txt bins
        n_early = length(find(ind1_early == i & ind2_early ==j)); %find all trials belonging to PEpred bin i and Txt bin j
        n_late = length(find(ind1_late == i & ind2_late ==j));
        n_smooth = length(find(ind1_smooth == i & ind2_smooth ==j));
        n_early_b = length(find(ind1_early_b == i & ind2_early_b ==j));
        n_late_b = length(find(ind1_late_b == i & ind2_late_b ==j));
        n_smooth_b = length(find(ind1_smooth_b == i & ind2_smooth_b ==j));
        m = max([n_early, n_late, n_smooth]);
        s(j,i) = n_smooth / (n_smooth + n_late + n_early) * 100; %calculate proportions relative to total trials in that box
        l(j,i) = n_late/ (n_smooth + n_late + n_early) * 100;
        s_b(j,i) = n_smooth_b / (n_smooth_b + n_late_b + n_early_b) * 100;
        l_b(j,i) = n_late_b/ (n_smooth_b + n_late_b + n_early_b) * 100;
        e(j,i) = n_early / (n_smooth + n_late +n_early) *100;
        e_b(j,i) = n_early_b / (n_smooth_b + n_late_b + n_early_b) * 100;

    end
end

%Heat map can only plot proportions for a particular trial type. 
% figure
% subplot(1,2,1)
% trial_type_clear = e % e=early, l=late, s= smooth
% trial_type_blurred = e_b %_b for blurred
% h = heatmap(edges1(1:end-1), edges2(1:end-1),trial_type_clear)
% %h.Colormap = [0 0 1; 1 0 0; 1 1 0];
% title('Clear')
% xlabel('PEpred')
% ylabel('Txt')
% set(gca,'FontSize',15)
% subplot(1,2,2)
% h_b = heatmap(edges1(1:end-1), edges2(1:end-1),trial_type_blurred)
% %h_b.Colormap = [0 0 1; 1 0 0; 1 1 0];
% title('Blurred')
% xlabel('PEpred')
% ylabel('Txt')
% set(gca,'FontSize',15)

%% Previous scatterplot code.
figure
subplot(1,2,1)
hold on
plot(early(:,param1),early(:,param2),'o','MarkerSize',5,'MarkerFaceColor',D(1,:))
ylim([-1000,1000])
plot(late(:,param1),late(:,param2),'or','MarkerSize',5,'MarkerFaceColor',D(2,:))
plot(smooth(:,param1),smooth(:,param2-1),'oy','MarkerSize',5,'MarkerFaceColor','y')
ylabel({'\fontsize{20} Clear','\fontsize{15} T_x_t'})
xlabel('PE_p_r_e_d')
set(gca,'FontSize',20)
set(gca,'FontWeight','Bold')
ylim([-900,900])
xlim([-30,30])

subplot(1,2,2)
hold on
plot(early_blurred(:,param1),early_blurred(:,param2),'o','MarkerSize',5,'MarkerFaceColor',D(1,:))

plot(late_blurred(:,param1),late_blurred(:,param2),'or','MarkerSize',5,'MarkerFaceColor',D(2,:))
plot(smooth_blurred(:,param1),smooth_blurred(:,param2-1),'oy','MarkerSize',5,'MarkerFaceColor','y')
 xlabel('PE_p_r_e_d')
 ylabel({'\fontsize{20} Blurred','\fontsize{15} T_x_t'})

ylim([-900,900])
xlim([-30,30])
set(gca,'FontSize',20)
set(gca,'FontWeight','Bold')