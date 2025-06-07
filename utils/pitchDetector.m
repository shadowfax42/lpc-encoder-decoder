function [ pitches ] = pitchDetector( speech, fs )
%% PITCHDETECTOR: Get pitch vector for input timeseries signal
% Divide the input signal into frames of the specified length and
% calculate the pitch for each frame. Pitch value 0 indicates that the
% frame is either silent or unvoiced
%% setup 
% Declare globals
global ACORR_OFFSET
global CLIP_RATIO
global FRAME_TIME
global OVERLAP
global NOISE_GATE
global VOICE_THRESH
global MAX_PITCH

% Compute frame size (in samples)
ts = 1/fs;
FRAME_SIZE = FRAME_TIME / ts;



% Get number of frames from padded signal
NUM_FRAMES = length(speech) / FRAME_SIZE;

% Add extra zeros for overlapping
speech = [speech; zeros(OVERLAP, 1)];

% Pre-allocate memory
pitches = zeros(NUM_FRAMES, 1,'single');

% Iterate over frames
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
           pitches(k) = 0;
           
        else 
            % Check fundamental frequency
            if 1 / period > MAX_PITCH
                % Too high to be realistic; store 0
                pitches(k) = 0;
                
            else
                % Reasonable; store pitch
                pitches(k) = 1 / period;
             
            end
        end
    else
        % Frame is silent
        pitches(k) = 0;
    end
 
    
end

end % Function
