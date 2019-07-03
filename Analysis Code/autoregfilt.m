function y=autoregfilt(sampfrq,cutoff,signal)

% function y=autoregfilt_ok(sampfrq,cutoff,signal)
% 
% this function filters the given continuous signal at the refered cutoff frequency.
% Sampfrq must be given.

k=round(((sampfrq/cutoff)-1)/2);

[e1,e2]=size(signal);
if e2>e1;
   signal=signal';
end
lo=length(signal);

signal=[zeros(6*k+3,1);signal;zeros(3*k,1)];

arr=(3*k+4):(6*k+3+lo);
temp=-signal(arr-3*k-3)+3*signal(arr-k-2)-3*signal(arr+k-1)+signal(arr+3*k);

A=[1,-3,3,-1];
B=1;
y=filter(B,A,temp);%y(n)=y(n-3)-3*y(n-2)+3*y(n-1)+temp(n);
y=y/((2*k+1)^3);

y=y(end+1-lo:end);
y(1:3*k)=NaN;
y(end-3*k+1:end) = NaN;
if length(y)~= lo,
    y=y(1:lo);
end