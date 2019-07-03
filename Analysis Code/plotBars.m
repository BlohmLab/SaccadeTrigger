%% Plots trigger time bar plots for double-step ramp data divided by a user provided parameter and edges

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function uses the med and quartile matrices from discretizeByBins to plot single
%subejct and collapsed reaction time bar plots. Function automatically
%creates a directory to save figures to. 

function plotBars(param,edges, med, quartiles,numTrials,bins,subjectorder, savePath)
time = string(timeofday(datetime));
time = strrep(time, ':','-');
newDir = strcat('MedBarPlot', date, '-',time);
newDir = char(newDir);
cd(savePath)
mkdir(newDir);
switch param
    case 12
        x_label = 'Predicted Position Error Bins';
        for i=1:3
        text{i} = strcat(num2str(edges(i)), '<PEpred<', num2str(edges(i+1)));
        end
    case 3
        x_label = 'Txt Bins'
        for i=1:3
        text{i} = strcat(num2str(edges(i)), '<Txt<', num2str(edges(i+1)));
        end
end
 for i=1:15
    subjectID = subjectorder(i);
    f = figure('units','normalized','outerposition',[0,0,1,1]);
    figureTitle = strcat('Subject ', subjectID, ' Median Reaction Time vs Predicted Position Error');
    filename = strcat('Subject', subjectID, 'MedBars.jpg');
    suptitle(figureTitle)
    subplot(2,1,1) 
    hB = bar(bins,med(i,:,1));
    hold on
    errorbar(bins,med(i,:,1),quartile(i,:,1),'.k','LineWidth',2);
    hold off
    hT = [];
    ylabel('Reaction time average (ms)')
    xlabel(x_label)
    title('Mean Reaction Times Clear Condition')
    for j = 1:length(hB.XData)
        hT=[hT text(hB.XData(j),hB.YData(j),strcat('#',num2str(numTrials(i,j,1))),...
                          'VerticalAlignment','bottom','horizontalalign','center')];
    end
    subplot(2,1,2)
    hB2 = bar(bins,med(i,:,2));
    hold on
    errorbar(bins,med(i,:,2),quartile(i,:,2),'.k','LineWidth',2);
    hold off
    hT2 = [];
    for j = 1:length(hB2.XData)
        hT2=[hT2 text(hB2.XData(j),hB2.YData(j),strcat('#',num2str(numTrials(i,j,2))),...
                          'VerticalAlignment','bottom','horizontalalign','center')];
    end
    ylabel('Reaction time average (ms)')
    xlabel(x_label)
    title('Median Reaction Times Blurred Condition')
    cd(newDir)
    saveas(f,filename)
    close(f)
    cd(savePath)
 


 end
    f = figure('units','normalized','outerposition',[0,0,1,1]);
    suptitle(strcat('Collapsed Reaction Time Averages vs ', x_label))
    subplot(2,1,1)
    hB3 = bar(bins,mean(med(:,:,1)));
    hold on
    errorbar(bins,mean(med(:,:,1)),mean(quartiles(:,:,1)),'.k','LineWidth',2);
    hold off
    hT3 = [];
    for j = 1:length(hB3.XData)
        hT3=[hT3 text(hB3.XData(j),hB3.YData(j),strcat('#',num2str(sum(numTrials(:,j,1)))),...
                          'VerticalAlignment','bottom','horizontalalign','right')];
    end
    ylabel('Reaction time median (ms)')
    title('Clear Condition')
    xlabel(x_label)
    ylim([0,450])
    set(gca,'FontSize',15)
    set(gca,'xticklabel',text)
    subplot(2,1,2)
    
    hB4 = bar(bins,mean(med(:,:,2)));
    hold on
    errorbar(bins,mean(med(:,:,2)),mean(quartiles(:,:,2)),'.k','LineWidth',2);
    hold off
    hT4 = [];
    for j = 1:length(hB4.XData)
        hT4=[hT4 text(hB4.XData(j),hB4.YData(j),strcat('#',num2str(sum(numTrials(:,j,2)))),...
                          'VerticalAlignment','bottom','horizontalalign','right')];
    end
    ylabel('Reaction time median (ms)')
    title('Blurred Condition')
    xlabel(x_label)
    ylim([0,450])
    set(gca,'FontSize',15)
    set(gca,'xticklabel',text)
    cd(newDir)
    saveas(f, 'CollapsedMedianRTBar.jpg')
    close(f)
end


