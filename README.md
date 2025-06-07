# LPC Vocoder – Audio Signal Compression & Synthesis

This project implements a speech codec using **Linear Predictive Coding (LPC)** with a focus on audio compression and synthesis. It was developed as part of a graduate-level audio signal processing course at Johns Hopkins University.

## 🎯 Project Overview

The project performs:
- LPC analysis and encoding of speech signals
- Pitch and voicing detection using Modified Autocorrelation (MACF)
- Synthesis using LPC filter, glottal pulse models, and voiced/unvoiced detection

## 📁 Structure

- `lpc_main.m`: Main pipeline for loading audio, encoding, decoding, and output.
- `lpc_encoder.m`: LPC coefficient extraction, pitch detection, voicing classification.
- `lpc_decoder.m`: Speech reconstruction using glottal pulse models or white noise.
- `lpc_rosenberg.m`: Generates glottal pulses based on the Rosenberg model.
- `results/`: Includes plots comparing original and synthesized signals.
- `audio_samples/`: All .wav files used for input/output testing.

## ⚙️ Parameters

Adjustable via global variables in `lpc_main.m`:
- `CLIP_RATIO = 0.60`
- `ORDER_VOICED = 20`
- `VOICE_THRESH = 0.35`
- `MAX_PITCH = 450` (adjusted for female pitch range)

## 📊 Example Output

Plots of the original vs synthesized audio demonstrate intelligibility and the LPC filter envelope tracking the signal formants.

## 🔧 Requirements

Requires MATLAB. Audio toolbox recommended.

## 📝 License

MIT License (you can change this to another if you prefer).
