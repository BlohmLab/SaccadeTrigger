%% Exploratory analysis for producing Figures 13 of early,late, and smooth saccade proportions

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function uses the master analysis params to plot a proportion plot of
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


param = 3; %or 12
switch param
    case 3
        bins = [-inf -450:50:500 inf];
        param_title='T_x_t';
        x_label = {'-500','-400','-300','-200','-100','0','100','200','300','400','500'};
        early_1 = data_clear_all(find(data_clear_all(:,1) < 175 & data_clear_all(:,16)==0),:);
        late_1 = data_clear_all(find(data_clear_all(:,1) > 175 & data_clear_all(:,16)==0),:);
        early_blurred_1 = data_blurred_all(find(data_blurred_all(:,1) < 175 & data_blurred_all(:,16)==0),:);
        late_blurred_1 = data_blurred_all(find(data_blurred_all(:,1) > 175 & data_blurred_all(:,16)==0),:);
        smooth_clear_1 = smooth_data_clear_all(find(smooth_data_clear_all(:,16)==0),:);
        smooth_blurred_1 =smooth_data_blurred_all(find(smooth_data_blurred_all(:,16)==0),:);
        title_1 = 'Large PE_p';
        early_2 = data_clear_all(find(data_clear_all(:,1) < 175 & data_clear_all(:,16)==1),:);
        late_2 = data_clear_all(find(data_clear_all(:,1) > 175 & data_clear_all(:,16)==1),:);
        early_blurred_2 = data_blurred_all(find(data_blurred_all(:,1) < 175 & data_blurred_all(:,16)==1),:);
        late_blurred_2 = data_blurred_all(find(data_blurred_all(:,1) > 175 & data_blurred_all(:,16)==1),:);
        smooth_clear_2 = smooth_data_clear_all(find(smooth_data_clear_all(:,16)==1),:);
        smooth_blurred_2 =smooth_data_blurred_all(find(smooth_data_blurred_all(:,16)==1),:);
        title_2 = 'Small PE_p_r_e_d';
    case 12
        bins = [-inf -18:2:18 inf];
        param_title = 'PE_p_r_e_d';
        x_label = {'-20','-18','-16','-14','-12','-10','-8','-6','-4','-2','0','2','4','6','8','10','12','14','16','18'};
        early_1 = data_clear_all(find(data_clear_all(:,1) < 175 & data_clear_all(:,3)<0),:);
        late_1 = data_clear_all(find(data_clear_all(:,1) > 175 & data_clear_all(:,3)<0),:);
        early_blurred_1 = data_blurred_all(find(data_blurred_all(:,1) < 175 & data_blurred_all(:,3)<0),:);
        late_blurred_1 = data_blurred_all(find(data_blurred_all(:,1) > 175 & data_blurred_all(:,3)<0),:);
        smooth_clear_1 = smooth_data_clear_all(find(smooth_data_clear_all(:,3)<0),:);
        smooth_blurred_1 =smooth_data_blurred_all(find(smooth_data_blurred_all(:,3)<0),:);
        title_1 = 'Negative T_x_t';
        early_2 = data_clear_all(find(data_clear_all(:,1) < 175 & data_clear_all(:,3)>0),:);
        late_2 = data_clear_all(find(data_clear_all(:,1) > 175 & data_clear_all(:,3)>0),:);
        early_blurred_2 = data_blurred_all(find(data_blurred_all(:,1) < 175 & data_blurred_all(:,3)>0),:);
        late_blurred_2 = data_blurred_all(find(data_blurred_all(:,1) > 175 & data_blurred_all(:,3)>0),:);
        smooth_clear_2 = smooth_data_clear_all(find(smooth_data_clear_all(:,3)>0),:);
        smooth_blurred_2 =smooth_data_blurred_all(find(smooth_data_blurred_all(:,3)>0),:);
        title_2 = 'Positive T_x_t';
end

ind_1_early_clear = discretize(early_1(:,param),bins);
ind_1_late_clear = discretize(late_1(:,param),bins);
ind_1_smooth_clear = discretize(smooth_clear_1(:,param),bins);
ind_2_early_clear = discretize(early_2(:,param),bins);
ind_2_late_clear = discretize(late_2(:,param),bins);
ind_2_smooth_clear = discretize(smooth_clear_2(:,param),bins);

ind_1_early_blurred = discretize(early_blurred_1(:,param),bins);
ind_1_late_blurred = discretize(late_blurred_1(:,param),bins);
ind_1_smooth_blurred = discretize(smooth_blurred_1(:,param),bins);
ind_2_early_blurred = discretize(early_blurred_2(:,param),bins);
ind_2_late_blurred = discretize(late_blurred_2(:,param),bins);
ind_2_smooth_blurred = discretize(smooth_blurred_2(:,param),bins);

c = {ind_1_early_clear,ind_1_late_clear,ind_1_smooth_clear,ind_2_early_clear,ind_2_late_clear,ind_2_smooth_clear...
    ;ind_1_early_blurred,ind_1_late_blurred,ind_1_smooth_blurred,ind_2_early_blurred,ind_2_late_blurred,ind_2_smooth_blurred};


for k=1:2
    for i=1:length(bins)-1
        n_1_e = length(find(c{k,1}(:)==i));
        n_1_l = length(find(c{k,2}(:)==i));
        n_1_s = length(find(c{k,3}(:)==i));
        n_2_e = length(find(c{k,4}(:)==i));
        n_2_l = length(find(c{k,5}(:)==i));
        n_2_s = length(find(c{k,6}(:)==i));
        y_1(i,1:3,k) = [n_1_e,n_1_l,n_1_s]./sum([n_1_e,n_1_l,n_1_s])*100;
        y_2(i,1:3,k) = [n_2_e,n_2_l,n_2_s]./sum([n_2_e,n_2_l,n_2_s])*100;
    end
end


f4 = figure;
%suptitle(sprintf('%s Early Late Smooth Proportions', param_title))
subplot(2,2,1)
b1 = bar(y_1(:,:,1),'stacked','BarWidth',1);
D = linspecer(5,'Qualitative');
b1(1).FaceColor = D(1,:);
b1(2).FaceColor = D(2,:);
b1(3).FaceColor = 'y';
xticks(1:2:22)
set(gca,'xticklabel',x_label)
title(title_1)
%legend('Early','Late','Smooth')
ylabel({'\fontsize{20} Clear','\fontsize{12}Proportion %'})
ylim([0,100])
%xlabel(sprintf('%s bins',param_title))
set(gca,'FontSize',15)
set(gca,'FontWeight','Bold')
subplot(2,2,2)
b2 = bar(y_2(:,:,1),'stacked','BarWidth',1);
b2(1).FaceColor = D(1,:);
b2(2).FaceColor = D(2,:);
b2(3).FaceColor = 'y';
xticks(1:2:22)
set(gca,'xticklabel',x_label)
title(title_2)
legend('Early','Late','Smooth')
%ylabel('Proportions %')
ylim([0,100])
%xlabel(sprintf('%s bins',param_title))
set(gca,'FontSize',15)
set(gca,'FontWeight','Bold')
subplot(2,2,3)
b3 = bar(y_1(:,:,2),'stacked','BarWidth',1);
b3(1).FaceColor = D(1,:);
b3(2).FaceColor = D(2,:);
b3(3).FaceColor = 'y';
xticks(1:2:22)
set(gca,'xticklabel',x_label)
%title(title_1)
%legend('Early','Late','Smooth')
ylabel({'\fontsize{20} Blurred','\fontsize{12}Proportion %'})
ylim([0,100])
xlabel(sprintf('%s',param_title))

set(gca,'FontSize',15)
set(gca,'FontWeight','Bold')
subplot(2,2,4)
b4 = bar(y_2(:,:,2),'stacked','BarWidth',1);
b4(1).FaceColor = D(1,:);
b4(2).FaceColor = D(2,:);
b4(3).FaceColor = 'y';
xticks(1:2:22)
set(gca,'xticklabel',x_label)
%title(title_2)
%legend('Early','Late','Smooth')
ylim([0,100])
%ylabel('Proportions %')
xlabel(sprintf('%s',param_title))
set(gca,'FontSize',15)
set(gca,'FontWeight','Bold')