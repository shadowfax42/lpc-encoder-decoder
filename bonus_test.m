%% Test script using the pitch detector and voice detector functions

% Get data from file
file = 'Sample10.wav';                 % Filepath
[speech, fs] = audioread(file);       % Get data and sample rate

global ACORR_OFFSET
global CLIP_RATIO
global FRAME_TIME
global OVERLAP
global NOISE_GATE
global VOICE_THRESH
global MAX_PITCH

ACORR_OFFSET = 15;      % Lag offset for autocorrelation processing
CLIP_RATIO = .60;       % Center clipping ratio (of max amplitude)
FRAME_TIME = .015;      % Frame duration
NOISE_GATE = .00001;    % Noise gate for silence thresholding
VOICE_THRESH = 0.35;    % Threshold for voiced frame detection
MAX_PITCH = 450;        % Maximum accepted fundamental frequency
OVERLAP = 40;  

% Compute frame size (in samples)
ts = 1/fs;
FRAME_SIZE = FRAME_TIME / ts;

% Zero-pad speech segment for even frame division and overlap space
pad_size = FRAME_SIZE - mod(length(speech), FRAME_SIZE);
speech = [speech; zeros(pad_size, 1)];

% Get voicing data
[ voices] = voicingDetector( speech, fs );

% Get pitch data
[ pitches ] = pitchDetector( speech, fs );

% Plot signal voicing, and pitch results
subplot(3,1,1);
plot((1:length(speech))/fs, speech);
xlabel('time(s)');
ylabel('amplitude');
title('Audio for Sample 10');
subplot(3,1,2);
stem(voices);
xlabel('frame');
ylabel('unvoice / silent / voiced');
title('Voices');
subplot(3,1,3);
plot(1:length(pitches), pitches);
xlabel('frame');
ylabel('frequency (Hz)');
title('Pitch');