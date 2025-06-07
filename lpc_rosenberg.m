function[gn]=lpc_rosenberg(N1,N2,f0,fs)
% LPC_ROSENBERG Generate a Rosenburg glottal pulse
% This function accepts fundamental frequency of the glottal signal and 
% the sampling frequency in hertz as input and returns one period of 
% the rosenberg pulse at the specified frequency.
% 
% Modified from online version found at: 
% http://www.mattmontag.com/projects/speech/rosenberg.m
%
%   N1 - ratio of glottal opening length to total pulse length, 0 to 1
%   N2 - duty cycle of the pulse, from 0 to 1
%   f0 - fundamental frequency
%   fs - sample frequency

T = 1 / f0;                         % period in seconds
pulselength = floor(T * fs);        % length of one period

% Select N1 and N2 for duty cycle
N2 = floor(pulselength * N2);
N1 = floor(N1 * N2);
gn = zeros(1, N2);

% Calculate pulse samples
for n = 1:N1-1
    gn(n) = 0.5*(1-cos(pi*(n-1)/N1));
end
for n = N1:N2
    gn(n) = cos(pi*(n-N1)/(N2-N1)/2);
end
gn = [gn zeros(1, (pulselength-N2))];