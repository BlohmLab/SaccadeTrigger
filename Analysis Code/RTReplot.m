%% This function should be called from reactionTimeExplorer, replots reaction time trends for PEpred bins 

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This reaction time analysis interface reproduces Figure 9 and 10 using the RTReplot function but the
%user can now interact with the graph by changing where the input is
%sampled from, whether to sort by absolute VS or not, and how far to
%extrapolate into the future.

%For reference, the paper used an extrapolation time of 150ms (0.15) and
%sampled at step for reaction time plots. 

origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';

clear('PE_pred_sacc_clear_all','PE_pred_sacc_blurred_all')

edges = [-inf -20:2:20 inf];
edges2 = [-inf 10:10:40 inf];
bins_param1 = length(edges)-1;
PE_pred_sacc_clear_all = PE_sacc_clear_all + RS_sacc_clear_all.*dt;
PE_pred_sacc_blurred_all = PE_sacc_blurred_all + dt*RS_sacc_blurred_all;

delay=100;
switch sampledAt
    case 1
        switch param
            case 1
                PE_pred_sacc_clear_all = PE_sacc_clear_all + dt*RS_sacc_clear_all;
                PE_pred_sacc_blurred_all = PE_sacc_blurred_all + dt*RS_sacc_blurred_all;
                x_clear = [data_clear_all(:,1), mean(PE_pred_sacc_clear_all(:,step_ind:step_ind+50),2),data_clear_all(:,10)];
                x_blurred = [data_blurred_all(:,1), mean(PE_pred_sacc_blurred_all(:,step_ind:step_ind+50),2),data_blurred_all(:,10)];
            case 2
                x_clear = [data_clear_all(:,1),mean(PE_sacc_clear_all(:,step_ind:step_ind+50),2),data_clear_all(:,10)];
                x_blurred = [data_blurred_all(:,1),mean(PE_sacc_blurred_all(:,step_ind:step_ind+50),2),data_blurred_all(:,10)];
        end
    case 2
        s_clear(RT_sacc_clear_all<125,1) = step_ind;
        e_clear(RT_sacc_clear_all<125,1) = round(step_ind+25);
        s_clear(RT_sacc_clear_all>=125,1) = round(step_ind + RT_sacc_clear_all(RT_sacc_clear_all>=125)-delay-25);
        e_clear(RT_sacc_clear_all>=125,1) = round(step_ind + RT_sacc_clear_all(RT_sacc_clear_all>=125)-delay+25);
        
        s_blurred(RT_sacc_blurred_all<125,1) = step_ind;
        e_blurred(RT_sacc_blurred_all<125,1) = round(step_ind+25);
        s_blurred(RT_sacc_blurred_all>=125,1) = round(step_ind + RT_sacc_blurred_all(RT_sacc_blurred_all>=125)-delay-25);
        e_blurred(RT_sacc_blurred_all>=125,1) = round(step_ind + RT_sacc_blurred_all(RT_sacc_blurred_all>=125)-delay+25);
        switch param
            case 1
                d1 = PE_pred_sacc_clear_all;
                d2 = PE_pred_sacc_blurred_all;
            case 2
                d1 = PE_sacc_clear_all;
                d2 = PE_sacc_blurred_all;
        end
        x_clear =[];
        x_blurred =[];
                for i=1:length(RT_sacc_clear_all)
                    x_clear = [x_clear;RT_sacc_clear_all(i),mean(d1(i,[s_clear(i):e_clear(i)]),2),data_clear_all(i,10)];
                end
                for j=1:length(RT_sacc_blurred_all)
                    x_blurred = [x_blurred;RT_sacc_blurred_all(j),mean(d2(j,[s_blurred(j):e_blurred(j)]),2),data_blurred_all(j,10)];
                end
        end
                


if abs_param2 ==1
    edges2 = [-inf 10:10:40 inf];
    x_clear_ind = discretize(abs(x_clear(:,3)), edges2);
    x_blurred_ind = discretize(abs(x_blurred(:,3)), edges2);
else
    edges2 = [-inf -40:10:40 inf];
    x_clear_ind = discretize(x_clear(:,3), edges2);
    x_blurred_ind = discretize(x_blurred(:,3), edges2);
end




bins_param2 = length(edges2)-1;
plot_cell_clear = cell(bins_param2,3);
plot_cell_blurred = cell(bins_param2,3);
for i = 1:bins_param2
    plot_cell_clear{i,1} = x_clear(find(x_clear_ind==i),:);
    plot_cell_clear{i,2} = discretize(plot_cell_clear{i,1}(:,2), edges);
    plot_cell_blurred{i,1} = x_blurred(find(x_blurred_ind==i),:);
    plot_cell_blurred{i,2} = discretize(plot_cell_blurred{i,1}(:,2), edges);
    for j = 1:bins_param1
        plot_cell_clear{i,3}(1,j) = mean(plot_cell_clear{i,1}(find(plot_cell_clear{i,2}==j),1));
        plot_cell_clear{i,3}(2,j) = std(plot_cell_clear{i,1}(find(plot_cell_clear{i,2}==j),1));
        plot_cell_blurred{i,3}(1,j) = mean(plot_cell_blurred{i,1}(find(plot_cell_blurred{i,2}==j),1));
        plot_cell_blurred{i,3}(2,j) = std(plot_cell_blurred{i,1}(find(plot_cell_blurred{i,2}==j),1));
    end
end


hold on
bins2plot = [1:bins_param2];
N = length(bins2plot);
cd(origPath)
C = linspecer(N,'sequential');
axes(ax(1))
cla
for i=1:N
    hold on
    plot(edges(1:end-1), plot_cell_clear{bins2plot(i),3}(1,:),'o-','color',C(i,:),'LineWidth',2);
    ylim([0,400])
end

axes(ax(2))
cla
for i=1:N 
    hold on
    plot(edges(1:end-1), plot_cell_blurred{bins2plot(i),3}(1,:),'o-','color',C(i,:),'LineWidth',2);
    ylim([0,400])
 end
