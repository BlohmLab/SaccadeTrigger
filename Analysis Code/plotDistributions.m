%% Plots trigger time distributions for double-step ramp data divided by a user provided parameter and edges

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function uses the DataStruct from discretizeByBins to plot single
%subejct and collapsed reaction time distributions. Function automatically
%creates a directory to save figures to. 

function plotDistributions(param, DataStruct, subjectorder,edges,bins2plot,savePath)
time = string(timeofday(datetime));
time = strrep(time, ':','-');
newDir = strcat('DistPlot', date, '-',time);
newDir = char(newDir);
cd(savePath)
mkdir(newDir);
switch param
    case 12
        x_label = 'Predicted Position Error Bins';
        for i=1:3
        text{i} = strcat(num2str(edges(i)), '<PEpred<', num2str(edges(i+1)));
        end
        param_str = 'PEpred';
    case 3
        x_label = 'Txt Bins'
        for i=1:3
        text{i} = strcat(num2str(edges(i)), '<Txt<', num2str(edges(i+1)));
        end
        param_str = 'Txt';
end
bins = [0:10:400]; %Trigger time bin sizes
edges = [-inf edges inf];
for i = 1:length(DataStruct)
    f = figure('units','normalized','outerposition',[0,0,1,1]);
    subjectID = subjectorder(i);
    figureTitle = strcat('Subject ', subjectID, ' Reaction Time Distirbutions for -',param_str,' Bins');
    filename = strcat('Subject', subjectID, 'RTdistributions.jpg');
    suptitle(figureTitle)
    for j=bins2plot
        subplot(2,length(bins2plot),find(bins2plot(:)==j))
        hold on
        title(text{i})
        histogram(DataStruct{i,1}.data(find(DataStruct{i,1}.bins==j),1),bins)
        xlabel('Reaction Time (ms)')
        hold off
    end
    for j=bins2plot
        subplot(2,length(bins2plot),find(bins2plot(:)==j)+3)
        hold on
        title(text{i})
        histogram(DataStruct{i,2}.data(find(DataStruct{i,2}.bins==j),1),bins)
        xlabel('Reaction Time (ms)')
        hold off
    end
    subplot(2,length(bins2plot),1)
    ylabel('Clear Condition')
    subplot(2,length(bins2plot),4)
    ylabel('Blurred Condition')
    cd(newDir)
    saveas(f,filename)
    close(f)
    cd(savePath)
end

%% Collapsed distribution code

C = linspecer(10,'Sequential');
bin1 = [];
bin2 = [];
bin3 = [];
bin4 = [];
bin5 = [];
bin6 = [];

for i = 1:length(DataStruct)
    bin1 = [bin1; DataStruct{i,1}.data(DataStruct{i,1}.bins==bins2plot(1),1)];
    bin2 = [bin2; DataStruct{i,1}.data(DataStruct{i,1}.bins==bins2plot(2),1)];
    bin3 = [bin3; DataStruct{i,1}.data(DataStruct{i,1}.bins==bins2plot(3),1)];
    bin4 = [bin4; DataStruct{i,2}.data(DataStruct{i,2}.bins==bins2plot(1),1)];
    bin5 = [bin5; DataStruct{i,2}.data(DataStruct{i,2}.bins==bins2plot(2),1)];
    bin6 = [bin6; DataStruct{i,2}.data(DataStruct{i,2}.bins==bins2plot(3),1)];
end
f2 = figure('units','normalized','outerposition',[0,0,1,1]);
all_bins = {bin1, bin2, bin3, bin4, bin5, bin6};
suptitle('Collapsed Distribution of RT vs Txt bins')
for j=1:length(bins2plot)
        subplot(2,length(bins2plot),j)
        hold on
        if j==1
            ylabel('# Trials')
        end
        histogram(all_bins{j},bins,'FaceColor',C(2,:))
        xlabel('Reaction Time (ms)')
        xlim([80,400])
        if j==1
            ylim([0,1750])
        else
        ylim([0,1500])
        end
        ylabel('# Trials')
        set(gca,'FontSize',20);
set(gca,'FontWeight','Bold')
        hold off
end


for k=1:length(bins2plot)
        subplot(2,length(bins2plot),k+3)
        hold on
        if k==1
            text = strcat(param_str, ' < ', num2str(edges(bins2plot(k)+1)));
            ylabel('# Trials')
        elseif k==2
            text = strcat(num2str(edges(bins2plot(k))), ' < ',param_str, ' < ', num2str(edges(bins2plot(k)+1)));
        elseif k==3
            text = strcat(num2str(edges(bins2plot(k))),' < ',param_str);
        end
        histogram(all_bins{k+3},bins,'FaceColor',C(9,:))
        xlim([80,400])
        ylim([0,1500])
        set(gca,'FontSize',20);
        xlabel({'\fontsize{17} Reaction Time (ms)',strcat('\fontsize{25} ',text)})%s',text)})
        set(gca,'FontWeight','Bold')
        hold off
end

cd(newDir)
saveas(f2, 'Collapsed Distribution.jpg')
close(f2)
