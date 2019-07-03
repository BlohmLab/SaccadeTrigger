%% Discretize reaction time data by bins according to a user provided parameter and edges

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function iterates over analysis param files and discretizes data
%based on a user provided parameter such as PEpred or Txt and calculates
%the mean, median, SD, and quartile for the trigger times of each subject.
%Returns tables for those values as well as a DataStruct for plotting
%purposes.

function [meanRT, sigmas, quartiles, med, numTrials, DataStruct, subjectorder] = discretizeByBins(edges, param, conditions,loadPath) 
    subjectorder = [];
    edges = [-inf, edges,inf];
    meanRT = zeros(15, length(edges)-1,2);
    sigmas = zeros(15,length(edges)-1,2);
    quartiles = zeros(15,length(edges)-1,2);
    med= zeros(15,length(edges)-1,2);
    numTrials = zeros(15,length(edges)-1,2);
    DataStruct = cell(15,2);
    idx = cell(6,1);
for k = 1:2
    list = conditions{k}; %iterate over task conditions
for i = 1:length(list) %Iterate over subject files
    cd(loadPath)
    load(string(list(i))) %load filtered data
    sNum = str2num(char(subjectID));
    DataStruct{i,k}.bins = discretize(data(:,param),edges); %Discretize based on param and edges
    DataStruct{i,k}.data = data;
    for j = 1:max(DataStruct{i,k}.bins) %Calculate mean, std, iqr, and median
        ind =find(DataStruct{i,k}.bins==j);
        numTrials(i,j,k) = length(ind);
        meanRT(i,j,k) = mean(data(ind,1));
        sigmas(i,j,k) = std(data(ind,1));
        quartiles(i,j,k) = iqr(data(ind,1));
        med(i,j,k) = median(data(ind,1));
     end
    subjectorder = [subjectorder, subjectID];
end
end
end