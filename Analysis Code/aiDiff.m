function df = aiDiff(delta,win,signal)

% function df = derive(delta,signal)
%   delta = 1/sfr;
%   win = time window (e.g. 0.01s)
%	Estimates the first order derivative of SIGNAL
%
q = round(win/delta);
denom = 2 * delta * sum((1:q).^2);

df = [];
df = conv((-q:q),signal)/denom;
df = -df(q+1:length(df)-q);

return;
