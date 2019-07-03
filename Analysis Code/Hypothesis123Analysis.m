%% Analysis for pre-registered hypotheses 1, 2, and 3 regarding the effects of PEpred and Txt on trigger times
%%plotDistribution produces Figure 11 and 12 depending on which param the
%%user chooses.

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function loads the analysis params for each subject and condition and
%discretizes the DataStruct into bin sizes chosen by the user. For the published
%paper, we used +5 and -5 as the edges. The user can also input the
%parameter to discretize.

%The one and two-way ANOVA were computed on SPSS using the 'med' and 'quartile' variables. To do so, the resulting
%matrices from this analysis code were copied over to SPSS. 

clear 
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\DataStruct Collection\AnalysisParams'; %Set to where analysis params are found
savePath = 'C:\Users\omri\Desktop\Saccade Trigger\DataStruct Collection\Analysis 1'; %Set to a folder where you would like to save the current DataStruct analysis
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\DataStruct Collection\Experiment Code'; %set to where analysis code is found

cd(loadPath)
matList = what; matList = matList.mat;
conditions{1} = matList(contains(matList,'C0'));
conditions{2} = matList(contains(matList,'C1'));

%Param list and related edges used in analysis
% 1: Reaction (Trigger) time
% 12: PEpred at target step, edges = [5, -5] (Pre registerd hypotheses 1 and 3)
% 3: Txt, edges [0 400] (Pre registered hypotheses 2 and 3)
% 17: Txe, at target step, edges = [0,400]

%Other params
% 2: PEpred 100ms before saccade
% 4: Txe 100ms before saccade
% 5: VS 

param = 12; 
edges = [-5 5];
bins2plot = [1,2,3];
cd(origPath);
%Use 'med' and 'quarties' for ANOVA
[meanRT, sigmas, quartiles, med, numTrials, DataStruct, subjectorder] = discretizeBins(edges, param, conditions,loadPath);
cd(origPath);

save('Tables.mat');

%% Uncomment below code to plot single and collapsed subject distributions or bar plots

%cd(origPath);
%DistPlot('PE_p_r_e_d',DataStruct, subjectorder, edges, bins2plot, savePath)
%centred_bins = [-10,0,10]; %uncommented for PEpred
%centered_bins = [-1, 0, 1]; %uncomment for Txt/Txe
%cd(origPath)
%plot_medRT(param,edges,med(:,bins2plot,:),quartile(:,bins2plot,:),numTrials(:,bins2plot,:),centred_bins,subjectorder, savePath);

