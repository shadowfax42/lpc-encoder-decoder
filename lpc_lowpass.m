function Hd = lpc_lowpass
%LPC_LOWPASS Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.0 and the DSP System Toolbox 9.2.
% Generated on: 16-Nov-2016 23:14:45

% Butterworth Lowpass filter designed using FDESIGN.LOWPASS.

% All frequency values are in kHz.
Fs = 16;  % Sampling Frequency

Fpass = 0.75;        % Passband Frequency
Fstop = 1;           % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 80;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);

% [EOF]
