function  [speech_encoded] = lpc_encoder (speech, fs)
% LPC_ENCODER Encode the provided speech segment using LPC
% -------------------------------------------------------------------------
% This function decomposes the input signal into overlapping frames and
% generates parameters required for re-synthesis, including LPC
% coefficients, gain, voicing, and pitch. This data is returned as a single
% struct. Voicing and pitch are determined using the modified
% autocorrelation algorithm.

%% Setup
% Declare globals (defined in lpc_main)
global ACORR_OFFSET
global CLIP_RATIO
global FRAME_TIME
global ORDER_VOICED
global OVERLAP
global NOISE_GATE
global VOICE_THRESH
global MAX_PITCH

% Compute frame size (in samples)
ts = 1/fs;
FRAME_SIZE = FRAME_TIME / ts;

% Zero-pad speech segment for even frame division and overlap space
pad_size = FRAME_SIZE - mod(length(speech), FRAME_SIZE);
speech = [speech; zeros(pad_size, 1)];

% Get number of frames from padded signal
NUM_FRAMES = length(speech) / FRAME_SIZE;

% Add extra zeros for overlapping
speech = [speech; zeros(OVERLAP, 1)];

% Pre-emphasis filter
b_pe = [1 -15/16];
speech = filter(b_pe, 1, speech);

% Create cells for storage
coeffs = cell(NUM_FRAMES, 1);
gains = cell(NUM_FRAMES, 1);
pitches = cell(NUM_FRAMES, 1);
voices = cell(NUM_FRAMES, 1);

%% Iterate over frames
for k = 1:NUM_FRAMES
    
    % Get frame vector with overlap
    overlapped_frame = speech((k-1)*FRAME_SIZE + 1 : ...
        (k)*FRAME_SIZE + OVERLAP);
    OVERLAP_SIZE = FRAME_SIZE + OVERLAP;
    windowed_frame = overlapped_frame .* hanning(OVERLAP_SIZE);
    
    % Low-pass frame (cutoff at approximately 750 Hz)
    filt_lp = lpc_lowpass;
    filtered_frame = filter(filt_lp, windowed_frame);
        
    % Apply noise gate thresholding
    frame_energy = sum(filtered_frame.^2);
    if (sqrt(frame_energy) / OVERLAP_SIZE) > NOISE_GATE

        % Center-clip with threshold determined from max amplitude
        clip_thresh = CLIP_RATIO * max(filtered_frame);
        for n = 1:OVERLAP_SIZE
            if abs(filtered_frame(n)) < clip_thresh
                filtered_frame(n) = 0;
            else
                filtered_frame(n) = 1;
            end;
        end

        % Autocorrelate and compute maximum and pitch
        frame_acorr = autocorr(filtered_frame, OVERLAP_SIZE - 1);

        % Compute maximum and period
        [peak, period] = max(frame_acorr(ACORR_OFFSET + 1 : end));
        period = (period + ACORR_OFFSET) / fs;

        % Threshold fundamental amplitude to determine if voiced
        if peak < VOICE_THRESH * frame_acorr(1);
            % Fundamental is too weak to consider voiced; store 0
            pitches{k} = 0;
            voices{k} = -1;
        else 
            % Check fundamental frequency
            if 1 / period > MAX_PITCH
                % Too high to be realistic; store 0
                pitches{k} = 0;
                voices{k} = -1;
            else
                % Reasonable; store pitch
                pitches{k} = 1 / period;
                voices{k} = 1;
            end
        end
    else
        % Frame is silent
        pitches{k} = 0;
        voices{k} = 0;
    end
    
    % Window non-overlapped frame
    lpc_frame = speech((k-1)*FRAME_SIZE + 1 : (k)*FRAME_SIZE);
    lpc_frame_windowed = lpc_frame .* hamming(FRAME_SIZE);
    
    % Get LPC coefficients and gain
    [coeffs{k}, power] = lpc(lpc_frame_windowed, ORDER_VOICED);
    gains{k} = sqrt(power);
    
end

% Format data into a single struct to return
speech_encoded = struct('coeffs', {coeffs}, ...
                        'gains', {gains},  ...
                        'voices', {voices}, ...
                        'pitches', {pitches});

end % Function
