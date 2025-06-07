function [ speech_synth ] = lpc_decoder(speech_encoded, fs)
% LPC_DECODER Decode and re-synthesize speech using the provided data
% -------------------------------------------------------------------------
% This function uses the provided encoded speech data to re-synthesize
% a speech segment. It generates glottal pulses for voiced frames at the
% appropriate frequency or noise for unvoiced frames, and then filters each
% frame according to the provided LPC coefficients and gain.

%% Setup
% Declare globals (defined in lpc_main)
global FRAME_TIME
global NOISE_POWER
% global ORDER_VOICED

% Compute frame size (in samples) and number of frames
ts = 1/fs;
FRAME_SIZE = FRAME_TIME / ts;
NUM_FRAMES = length(speech_encoded.coeffs);

% Pre-allocate memory for synthesized speech segment
speech_synth = zeros(FRAME_SIZE * (NUM_FRAMES + 1), 1);
zf = [];

%% Iterate over frames
for k = 1:NUM_FRAMES;
   
    % Generate base sound for frame based on voice data
    if speech_encoded.voices{k} == 0
        
        % No speech this frame; leave as zeros
        offset = 0;
        continue;
        
    elseif speech_encoded.voices{k} == -1
        
        % Unvoiced speech; generate white gaussian noise
        offset = 0;
        speech_synth((k-1)*FRAME_SIZE + 1 : k*FRAME_SIZE) = ...
            wgn(FRAME_SIZE, 1, NOISE_POWER);
        
    elseif speech_encoded.voices{k} == 1
        
        % Voiced speech; generate glottal pulse train at given pitch
        glottal_pulse = lpc_rosenberg(.7, .4, speech_encoded.pitches{k}, fs);
        t_train = 1 / speech_encoded.pitches{k};
        IMPULSE_SIZE = floor(t_train / ts);
        
        % Correctly space first pulse relative to previous frame
        if k == 1
            % First frame; start with no offset
            offset = 0;
        end
        % If previous frame was voiced, use offset for first pulse
        speech_synth((k-1)*FRAME_SIZE + 1 + offset : IMPULSE_SIZE : ...
            k*FRAME_SIZE) = 1;
        % Get index of last impulse to align the next frame
        indexes = find(speech_synth((k-1)*FRAME_SIZE + 1 : k*FRAME_SIZE));
        index_last = indexes(end);
        offset_new = index_last - FRAME_SIZE + IMPULSE_SIZE;
        
        % Convolve impulse train with glottal pulse waveform
        speech_synth((k-1)*FRAME_SIZE + 1 + offset : ...
            k*FRAME_SIZE + length(glottal_pulse) - 1) = ...
            conv(glottal_pulse, ...
            speech_synth((k-1) * FRAME_SIZE + 1 + offset: k*FRAME_SIZE));
        
        % Set new offset for next frame
        offset = offset_new;
        
    else
        % Invalid voice
        error('Invalid voice data for frame %d. Must be -1, 0, or 1.', k);
    end
   
    % Filter frame using LPC coefficients and gain
    [speech_synth((k-1)*FRAME_SIZE + 1 : k*FRAME_SIZE), zf] = ...
        filter(speech_encoded.gains{k}, ...
        speech_encoded.coeffs{k}, ...
        speech_synth((k-1)*FRAME_SIZE + 1 : k*FRAME_SIZE), zf);

%     % Scale to full dynamic range
%     speech_synth = speech_synth ./ max(abs(speech_synth));
    
end

end