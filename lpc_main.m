%% LPC Main Script
%  Siham Elmali
%  Johns Hopkins University
%  Audio Signal Processing : Project 2
%  November 17, 2016
close all; clear all;
%% Part 1 - Encode 10 provided speech segments
% Declare and define globals and other constants
global ACORR_OFFSET
global CLIP_RATIO
global FRAME_TIME
global NOISE_POWER
global ORDER_VOICED
global ORDER_UNVOICED
global OVERLAP
global NOISE_GATE
global VOICE_THRESH
global MAX_PITCH

ACORR_OFFSET = 15;      % Lag offset for autocorrelation processing
CLIP_RATIO = .6;       % Center clipping ratio (of max amplitude)
FRAME_TIME = .015;      % Frame duration
NOISE_POWER = -12;      % Noise power for unvoiced speech base
ORDER_VOICED = 16;      % Filter for voiced frames
ORDER_UNVOICED = 10;    % Filter order for unvoiced frames (reduced)
OVERLAP = 40;           % Overlap between frames
NOISE_GATE = .00001;    % Noise gate for silence thresholding
VOICE_THRESH = 0.35;    % Threshold for voiced frame detection
MAX_PITCH = 450;        % Maximum accepted fundamental frequency
NUM_FILES = 10;         % Number of files to iterate over

% Pre-allocate memory for data
speech = cell(NUM_FILES, 1);
fs = cell(NUM_FILES, 1);
speech_encoded = cell(NUM_FILES, 1);
speech_synth = cell(NUM_FILES, 1);
% Iterate over files and process
for k = 1:NUM_FILES
    
    % Load speech segment audio
    file = ['Sample',num2str(k),'.wav']; 
    [speech{k}, fs{k}] = audioread(file);

    % Encode each speech segment
    speech_encoded{k} = lpc_encoder(speech{k}, fs{k});

    % Synthesize each speech segment
    speech_synth{k} = lpc_decoder(speech_encoded{k}, fs{k});
    
    % Write synthesized audio to file
    audiowrite(['Sample' num2str(k) '_received.wav'], ...
        speech_synth{k}, fs{k});
    
end

%% Analyize results
% Plot comparison
for k = 1: NUM_FILES
   figure (k)
    subplot(2,1,1);
    plot((1:length(speech{k}))/fs{k}, speech{k});
    title(['Original Audio for Sample'  num2str(k)] );
    xlabel('time (s)');
    ylabel('amplitude');

    subplot(2,1,2);
    plot((1:length(speech_synth{k}))/fs{k},speech_synth{k});
    title(['Synthesized Audio for Sample'  num2str(k)] );
    xlabel('time (s)');
    ylabel('amplitude');
end

%% Part 2 - Perform same process on recorded sentence
% Declare globals for this specific sentence

ACORR_OFFSET = 15;      % Lag offset for autocorrelation processing
CLIP_RATIO = .60;       % Center clipping ratio (of max amplitude)
FRAME_TIME = .02;      % Frame duration
NOISE_POWER = -12;      % Noise power for unvoiced speech base
ORDER_VOICED = 16;      % Filter for voiced frames
ORDER_UNVOICED = 10;    % Filter order for unvoiced frames (reduced)
NOISE_GATE = .00001;    % Noise gate for silence thresholding
VOICE_THRESH = 0.35;    % Threshold for voiced frame detection
MAX_PITCH = 450;        % Maximum accepted fundamental frequency
OVERLAP = 40;           % Number overlapped samples

% Load speech segment audio
[speech_2, fs_2] = audioread('Sentence.wav');

% Encode each speech segment
speech_encoded_2 = lpc_encoder(speech_2, fs_2);

% Synthesize each speech segment
speech_synth_2 = lpc_decoder(speech_encoded_2, fs_2);

% Write synthesized audio to file
audiowrite('Sentence_received.wav', speech_synth_2, fs_2);

%% Analyze results
% Plot comparison
figure 
    subplot(2,1,1);
    plot((1:length(speech_2))/fs_2, speech_2);
    title('Original Sentence');
    xlabel('time (s)');
    ylabel('amplitude');
    subplot(2,1,2);
    plot((1:length(speech_synth_2))/fs_2, speech_synth_2);
    title('Synthesized Sentence');
    xlabel('time (s)');
    ylabel('amplitude');
    
%% plot of the filter coeffs and the sythesized signal for the sentence
% Setup
frame_num = 73;
ts_2 = 1/fs_2;
frame_size = FRAME_TIME / ts_2;
frame_start = (frame_num-1)*frame_size + 1;

% Get LPC transfer function and PSD of corresponding frame
[h, w1] = freqz(1, speech_encoded_2.coeffs{frame_num});
[pxx, w2] = periodogram(speech_synth_2(frame_start : frame_start + frame_size - 1));

figure();
plot(w1, 20*log10(abs(h)), 'r');
hold on;
plot(w2, 20*log10(pxx)+95);
title('the LPC transfer function and synth audio for recorded speech');