function y=autoregfiltinpart(sampfrq,cutoff,sign)
% function y=autoregfiltin part_ok(sampfrq,cutoff,signal)
% 
% this function filters the given discontinuous (with NaN's) signal at the refered cutoff frequency.
% Sampfrq must be given.
% very close to autoregfilt_ok

y = sign;

IsNotNaN = find(isfinite(sign));
[pos,n] = group(IsNotNaN,1.5,25);
for kk = 1:n,
    y(IsNotNaN(pos(2*kk-1)):IsNotNaN(pos(2*kk))) = autoregfilt(sampfrq,cutoff,sign(IsNotNaN(pos(2*kk-1)):IsNotNaN(pos(2*kk))));
end;
