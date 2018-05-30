%% Detects saccades for the analysis interface 

%Authors: Blohm Lab Members, Queen's University, Kingston, Ontario, Canada

%This function uses eye acceleration threshold to detect saccades and
%returns the timing of saccade onset and offset. It also returns interpolated 
%velocity traces without saccades i.e. the velocity profile had the saccade 
%not occured. This function is called by the LoadData.m function. 
function [sacc eyeXvws eyeYvws eyeVvws] = detectSaccades(D, trn)
%% detect saccades (acceleration threshold: 750deg/s2)

%Find all instances in the acceleration profile where acceleration exceeds
%threshold
inst = find(D{trn}.eyeVa >= 750); 

%Group these instances into distinct saccades
%pos stores the onset and offest of each saccade group that was found
[pos,n] = group(inst,round(0.030*D{1}.sfr1),round(0.030*D{1}.sfr1));
 
temp = inst(pos);

%Create a sacc matrix to store all onset offset values
sacc = zeros(round(length(temp)/2),2);
for i = 1:round(length(temp)/2)
    
  %saccade onset  
  sacc(i,1) =  temp(2*i-1);
  
  %saccade offset
  sacc(i,2) =  temp(2*i);  
end

%% remove saccades from velocity trace

%Number of velocity measures
nvm = length(D{trn}.eyeXv);

%Xvws = X-direction Velocity Without Saccades
eyeXvws = D{trn}.eyeXv;
eyeYvws = D{trn}.eyeYv;

for i=1:round(length(temp)/2),
    
    % index of saccade onset
    begi = round(max(temp(i*2-1)-round(0.025*D{1}.sfr1),1));
    
    % index of saccade end
    endi = round(min(temp(i*2)+round(0.025*D{1}.sfr1),nvm));
    
    %duration of saccade
    d = endi-begi;	
    
    %velocity 24 ms before
    yaX = D{trn}.eyeXv(begi); 
    
     %velocity 24 ms after
    ybX = D{trn}.eyeXv(endi);
    
    %velocity 24 ms before
    yaY = D{trn}.eyeYv(begi);   
    
    %velocity 24 ms after
    ybY = D{trn}.eyeYv(endi);
    
    %linear interpolation
    eyeXvws(begi:endi)=(yaX+(0:d)*(ybX-yaX)/d)'; 
    
     %linear interpolation 
    eyeYvws(begi:endi)=(yaY+(0:d)*(ybY-yaY)/d)';         
end
eyeVvws = sqrt(eyeXvws.^2 + eyeYvws.^2);

