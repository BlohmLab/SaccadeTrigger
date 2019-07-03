%% Param matrix compiler for all sessions of one subject

%%Author: Omri Nachmani
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function will iterate through folders and load the params, PE, RS matrices and
%compile them into a masterParams, masterPE, and master RS and save it under the master path which
%a user assgins. Function performs additional checks for double saccades by
%comparing main function to rest of saccades in the current session.

clear
origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code'; %Set path to where experiment code is found
loadPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Loaded'; %Set path to where loaded data is found
master = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Master'; %Assign new master param path where master data will be saved

%% iterate through folders and files in the path to load the param, PE, and RS variables and save one master file per subject folder
cd(loadPath)
files = dir;
directoryNames = {files([files.isdir]).name};
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}));
 for i=1:length(directoryNames)
     cd(directoryNames{i});
     currentPath = pwd;
     matList = what; matList = matList.mat;
     for j = 1:length(matList)
        filename = [string(matList(j))];
        load(filename)
        if exist('masterParams') && exist('masterPE') && exist('masterRS')
            masterParams = [masterParams;param]; % add all params together
            masterPE = [masterPE;PE];
            masterRS=[masterRS;RS];
        else
            masterParams = param;
            masterPE = PE;
            masterRS = RS;
        end 
     end


%This code checks for double saccades and flags them by checking if saccade
%duration is more than 2 standard deviations from the mean. Two methods are
%used here but only one was used for the analysis, see readme. 
    dur = masterParams(:,15);
    amp = abs(masterParams(:,17)-masterParams(:,16));
    muDur = mean(dur);
    rngDur = range(dur);
    sigDur = sqrt(var(dur));
    masterParams(:, 31) = masterParams(:,15)> muDur + 2*sigDur;
    [b,stats] = robustfit(amp,dur);
    pred = b(1) + b(2) * dur;
    res2 = pred-amp;
    res = stats.resid;
    mu2=mean(res2);
    sig2 = sqrt(var(res2));
    pd = fitdist(res,'normal');
    mu = mean(pd);
    sig = sqrt(var(pd));
    ind = find(res>(mu+sig));
    ind2=find(res2>(mu2+sig2));
    masterParams(:,32) =0;
    masterParams(ind2,32) = 1; %Double saccades
    cd(master)
    save([D{1}.dFilename(1:end-7) 'MasterData.mat'],'masterParams', 'masterPE','masterRS')
    clear masterParams
    clear masterPE
    clear masterRS
    cd(loadPath)
end

