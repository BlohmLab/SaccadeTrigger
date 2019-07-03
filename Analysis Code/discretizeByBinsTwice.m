%% Subdivides the data two-fold according to two user provided parameter and edges such as PEpred/Txt by VS

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function iterates over analysis param files and discretizes data
%based on twp user provided parameter such as PEpred/Txt by VS and calculates
%the mean, median, SD, and quartile for the trigger times of each subject.
%Returns tables for those values as well as a DataStruct for plotting
%purposes.
function [meanRT, sigmas, quartiles, med, numTrials, Data, subjectorder] = discretizeByBinsTwice(edges, edges2, param1, param2, conditions,loadPath) 
    subjectorder = [];
    edges = [-inf, edges,inf];
    edges2 = [-inf, edges2, inf];
    dim = (length(edges)-1) * (length(edges2)-1);
    meanRT = zeros(15, dim,2);
    sigmas = zeros(15,dim,2);
    quartiles = zeros(15,dim,2);
    med= zeros(15,dim,2);
    numTrials = zeros(15,dim,2);
    Data = cell(15,2);
for k = 1:2
    list = conditions{k};
for i = 1:length(list)
    cd(loadPath)
    load(string(list(i)))
    sNum = str2num(char(subjectID));
    
    Data{i,k}.bins1 = discretize(data(:,param1),edges);
    if param2 == 5
        Data{i,k}.bins2 = discretize(abs(data(:,param2)),edges2);
    else
        Data{i,k}.bins2 = discretize(data(:,param2),edges2);
    end
    
    Data{i,k}.data = data;
    b = max(Data{i,k}.bins2);
    for j = 1:max(Data{i,k}.bins1)
        for m=1:b
            ind = find(Data{i,k}.bins1==j);
            ind2 = find(Data{i,k}.bins2==m);
            int = intersect(ind, ind2);
            numTrials(i,m+(j-1)*b,k) = length(int);
            meanRT(i,m+(j-1)*b,k) = mean(data(int,1));
            sigmas(i,m+(j-1)*b,k) = std(data(int,1));
            quartiles(i,m+(j-1)*b,k) = iqr(data(int,1));
            med(i,m+(j-1)*b,k) = median(data(int,1));
        end
     end
    subjectorder = [subjectorder, subjectID];
end
end
end

