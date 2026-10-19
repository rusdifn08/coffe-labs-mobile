import os
import wave
import struct
import math
import random

audio_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/audio"
os.makedirs(audio_dir, exist_ok=True)

def generate_water_sound(filename, duration_ms, volume=0.3):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(audio_dir, filename)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        last_val = 0.0
        for i in range(num_samples):
            white = random.uniform(-1.0, 1.0)
            # Lowpass filter creates a rushing water/river sound from white noise
            val = last_val + 0.05 * (white - last_val)
            last_val = val
            
            # Slow LFO to create a wave/flowing dynamic
            t = i / sample_rate
            lfo = 0.7 + 0.3 * math.sin(2.0 * math.pi * 0.3 * t)
            
            sample = val * volume * lfo * 3.0
            
            if sample > 1.0: sample = 1.0
            if sample < -1.0: sample = -1.0
            
            int_val = int(sample * 32767.0)
            data = struct.pack('<h', int_val)
            wav_file.writeframesraw(data)
    print(f"Generated {filename}")

generate_water_sound("water.wav", 20000, 0.5)
