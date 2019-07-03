% --------------------------------------------------------------------    
% Get eyelink message and offset time
function [mestimes mes]=getELmes(M, s)
% M     raw edf structure
% s     a cell array of strings to search for in the messages
% mestimes  an array of the times the messages occured (adjusted by offset if necessary).
% mes an array of the actual messages
    strInd=[];
    if ~iscell(s)
        s={s};
    end
    for i=1:length(s)
        strInd=[strInd; strcellmatch(M.messages, s{i})];  
    end

    mestimes=M.mestimes(strInd);
    mes=M.messages(strInd, :);
    
    % finds the offset times that must be subtracted from the mestimes
    for i=1:size(mes, 1)
        offset=sscanf(mes(i,:), '%f');
        if ~isempty(offset)
            mestimes(i)=mestimes(i)-offset;
        end
    end