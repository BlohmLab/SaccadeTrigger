
function plotSingleTrial(trial_id)

origPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Experiment Code';%Set to where analysis code is found
dataPath = 'C:\Users\omri\Desktop\Saccade Trigger\Data Collection\Loaded'; %set to where loaded raw data is found
C = linspecer(length(trial_id),'qualitative');
figure
for k = 1:length(trial_id)
    t = num2str(trial_id(k));

    c = strsplit(t,'.');

    trial_num = c{2};
    if trial_num(1) == 0
        trial_num = str2num(trial_num(2));
    elseif length(trial_num) == 1
        trial_num = str2num(trial_num) * 10;
    else
        trial_num = str2num(trial_num);
    end
    s = c{1};
    if length(s) == 3
        subject_id = s(1);
        block_id = s(2:end);
    elseif length(s) == 4
        if str2num(s(2)) ~= 0
            if str2num(s(2:end)) > 109
                subject_id = s(1:2);
                block_id = s(3:end);
            else
                subject_id = s(1);
                block_id = s(2:end);
            end
        else
            subject_id = s(1:2);
            block_id = s(3:end);
        end
    elseif length(s) == 5
        subject_id = s(1:2);
        block_id = s(3:end);
    end
        

    subject_id = str2num(subject_id);
    block_id = str2num(block_id);
    cd(dataPath)
    files = dir;
    directoryNames = {files([files.isdir]).name};
    directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}));

    for i =1:length(directoryNames)
        ind = regexp(directoryNames{i},'\d');
        num = str2num(directoryNames{i}(ind));
        if ~isempty(num) & num == subject_id
            cd(directoryNames{i})
        end
    end

    matList1 = what; matList1 = matList1.mat;

    for i =1:length(matList1)
        ind = regexp(matList1{i},'\d');
        num = str2num(matList1{i}(ind));
        if num == block_id
            load(matList1{i})
            break
        end
    end


    tStep1 = D{trial_num}.tStep1 - D{trial_num}.tFixation;
    tRamp1 = D{trial_num}.tRamp1 - D{trial_num}.tFixation;
    tStep2 = D{trial_num}.tStep2 - D{trial_num}.tFixation;
    tRamp2 = D{trial_num}.tRamp2 - D{trial_num}.tFixation;
    tTrialEnd = D{trial_num}.tTrialEnd - D{trial_num}.tFixation;


    if mod(k,2) == 0
    subplot(2,1,1)
    else
        subplot(2,1,2)
    end
    
    hold on
    plot(D{trial_num}.t, D{trial_num}.eyeX,'Color',C(k,:),'LineWidth',1.5); %plot of eye position in X
    plot(D{trial_num}.tScreen, D{trial_num}.target_x','--k','LineWidth',2);%plot of target position in X
    plot([0 length(D{trial_num}.eyeX)], [0 0],'k');
    for iSacc =  1:size(D{trial_num}.sacc,1)
        plot(D{trial_num}.t(D{trial_num}.sacc(iSacc,1):D{trial_num}.sacc(iSacc,2)), (D{trial_num}.eyeX(D{trial_num}.sacc(iSacc,1):D{trial_num}.sacc(iSacc,2))),'Color',C(k,:),'LineWidth',4);
    end
    %legend('X-Position Eye', 'X-Position Target', 'X-Position without sacc');%, 'X without sacc');
    xlim([0 length(D{trial_num}.eyeX)])
    ylim([-30 30]);
    ylabel('Position (deg)')
    xlabel('Time (ms)')
    set(gca,'FontSize',10)
    set(gca,'FontWeight','Bold')
    
%     subplot(2,2,k)
%     hold on; %hold all previous axes
%     plot(D{trial_num}.t, D{trial_num}.eyeXv,'r'); %plot of eye velocity in X
%     plot(D{trial_num}.tScreen , D{trial_num}.target_v,'g'); %plot of target velocity in X
%     plot(D{trial_num}.t, D{trial_num}.eyeXvws,'r'); 				%eye velocity without saccade in vectorial ????
%     plot([0 length(D{trial_num}.eyeXv)], [0 0],'k');
%     plot(tStep1*[1 1],[-50 50],'b');
%     plot(tStep2*[1 1],[-50 50],'b');


    %plot saccade
%     for iSacc =  1:size(D{trial_num}.sacc,1)
%         plot(D{trial_num}.t(D{trial_num}.sacc(iSacc,1):D{trial_num}.sacc(iSacc,2)), D{trial_num}.eyeXv(D{trial_num}.sacc(iSacc,1):D{trial_num}.sacc(iSacc,2)),'-r','LineWidth',3);
% 
%     end
%     %legend('X-Velocity Eye', 'X-Velocity Target', 'X-Velocity Target without sacc', 'V without sacc');
%     xlim([0 length(D{trial_num}.eyeXv)])
%     ylim([-80 80]);
    
% h.targetStart = uicontrol('Style','text','String','Starting Position','Visible','off','units','normalized','Position', [0.90 0.25 0.05 0.025]);
% h.valtargetStart = uicontrol('Style','text','String',[num2str(D{trial_num}.target_start) ' degrees'],'Visible','off','units','normalized','Position', [0.95 0.25 0.05 0.025]);
% h.Step1 = uicontrol('Style','text','String','Step 1','Visible','off','units','normalized','Position', [0.90 0.225 0.05 0.025]);
% h.valStep1 = uicontrol('Style','text','String',[num2str(D{trial_num}.target_s1) ' degrees'],'Visible','off','units','normalized','Position', [0.95 0.225 0.05 0.025]);
% h.Ramp1 = uicontrol('Style','text','String','Velocity 1','Visible',' off','units','normalized','Position', [0.90 0.2 0.05 0.025]);
% h.valRamp1 = uicontrol('Style','text','String',[num2str(D{trial_num}.target_v1) ' degrees/s'],'Visible','off','units','normalized','Position', [0.95 0.2 0.05 0.025]);
% h.Step2 = uicontrol('Style','text','String','Step 2','Visible',' off','units','normalized','Position', [0.90 0.17 0.05 0.025]);
% h.valStep2 = uicontrol('Style','text','String',[num2str(D{trial_num}.target_s2) ' degrees'],'Visible','off','units','normalized','Position', [0.95 0.17 0.05 0.025]);
% h.Ramp2 = uicontrol('Style','text','String','Velocity 2','Visible','off','units','normalized','Position', [0.90 0.15 0.05 0.025]);
% h.valRamp2 = uicontrol('Style','text','String',[num2str(D{trial_num}.target_v2) ' degrees/s'],'Visible','off','units','normalized','Position', [0.95 0.15 0.05 0.025]);
% h.Duration = uicontrol('Style','text','String','Trial Duration','Visible','off','units','normalized','Position', [0.90 0.1 0.05 0.025]);
% h.valDuration = uicontrol('Style','text','String',[num2str(D{trial_num}.tScreen(end)/1000) ' s'],'Visible','off','units','normalized','Position', [0.95 0.10 0.05 0.025]);

%plot center line
plot(-D{1}.screenWidth/2/D{1}.ppdx:0.5:D{1}.screenWidth/2/D{1}.ppdx,0,'k');
plot(0,-D{1}.screenHeight/2/D{1}.ppdy:0.5:D{1}.screenHeight/2/D{1}.ppdy,'k');


% finalize
%  sstr = fieldnames(h);
%  for i = 1:length(sstr)
%      set(eval(['h.' sstr{i}]),'visible','on')
%  end
%  
 end

cd(origPath)