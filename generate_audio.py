import os
import wave
import struct
import math

audio_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/audio"
os.makedirs(audio_dir, exist_ok=True)

# Helper to generate synthetic WAV
def generate_beep(filename, freq, duration_ms, volume=0.5, fade=True):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(audio_dir, filename)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for i in range(num_samples):
            envelope = 1.0
            if fade:
                envelope = 1.0 - (i / num_samples)
            value = int(volume * envelope * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename}")

def generate_ambient_drone(filename, base_freq, duration_ms, volume=0.3):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(audio_dir, filename)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for i in range(num_samples):
            # Complex drone with harmonics and LFO
            t = i / sample_rate
            lfo = math.sin(2.0 * math.pi * 0.2 * t) # slow swell
            env = 1.0
            if i < 44100: env = i / 44100 # fade in 1s
            if i > num_samples - 44100: env = (num_samples - i) / 44100 # fade out 1s
            
            # 3 harmonics
            v1 = math.sin(2.0 * math.pi * base_freq * t)
            v2 = 0.5 * math.sin(2.0 * math.pi * (base_freq * 1.5) * t)
            v3 = 0.25 * math.sin(2.0 * math.pi * (base_freq * 2.0) * t)
            
            sample = (v1 + v2 + v3) * volume * env * (0.8 + 0.2 * lfo)
            value = int(sample * 32767.0)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename}")

# Generate Tick (short, high pitch, low volume)
generate_beep("tick.wav", 1500, 50, 0.3)

# Generate Click (very short, medium pitch)
generate_beep("click.wav", 800, 30, 0.5)

# Generate Transition (melodic, slightly longer)
generate_beep("transition.wav", 600, 400, 0.6, fade=True)

# Generate Calm Music Drone (30 seconds looping ambient pad at 220Hz / A3)
generate_ambient_drone("calm_music.wav", 220.0, 10000, 0.2)

print("Audio generation complete.")
