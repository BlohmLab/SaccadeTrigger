function [D] = CSSaccSet(D)
for ii = 1: D{1}.numTrials

    [D{ii}.sacc, D{ii}.eyeXvws, D{ii}.eyeYvws, D{ii}.eyeVvws] = detectSaccades2(D,ii);
    if ~isempty(D{ii}.sacc),
        
        indSacc = find(D{ii}.t(D{ii}.sacc(:,1))>(D{ii}.tStep2-D{ii}.tFixation));
        
        if ~isempty(indSacc),
            
            D{ii}.saccOn = D{ii}.sacc(indSacc(1),1);
            D{ii}.saccOff = D{ii}.sacc(indSacc(1),2);
            
            if length(indSacc)>1,
                D{ii}.saccOn2 = D{ii}.sacc(indSacc(2),1);
                D{ii}.saccOff2 = D{ii}.sacc(indSacc(2),2);
            else
                D{ii}.saccOn2 = -9999;
                D{ii}.saccOff2 = -9999;
            end
        else
            D{ii}.saccOn = -9999;
            D{ii}.saccOff = -9999;
            D{ii}.saccOn2 = -9999;
            D{ii}.saccOff2 = -9999;
        end
    else
        D{ii}.saccOn = -9999;
        D{ii}.saccOff = -9999;
        D{ii}.saccOn2 = -9999;
        D{ii}.saccOff2 = -9999;
    end
end
fprintf('Saccace Onset and Offset are all set.\n');
