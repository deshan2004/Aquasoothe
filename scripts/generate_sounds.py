import os
import wave
import math
import struct
import random

SAMPLE_RATE = 44100
DURATION = 5  # 5-second seamless loop for each sound

def clamp(v, min_v=-1.0, max_v=1.0):
    return max(min_v, min(max_v, v))

def write_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        # Apply smooth 10ms crossfade between start and end for seamless loop
        fade_samples = int(SAMPLE_RATE * 0.05)
        num_samples = len(samples)
        looped_samples = list(samples)
        
        for i in range(fade_samples):
            alpha = i / float(fade_samples)
            looped_samples[i] = (1 - alpha) * samples[num_samples - fade_samples + i] + alpha * samples[i]

        packed = bytearray()
        for s in looped_samples:
            s_clamped = clamp(s)
            val = int(s_clamped * 32767.0)
            packed.extend(struct.pack('<h', val))
        
        wav_file.writeframes(packed)
    print(f"Generated: {filename} ({len(samples)} samples)")

def generate_pink_noise(duration):
    num_samples = int(SAMPLE_RATE * duration)
    b = [0.0] * 7
    samples = []
    for _ in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        b[0] = 0.99886 * b[0] + white * 0.0555179
        b[1] = 0.99332 * b[1] + white * 0.0750759
        b[2] = 0.96900 * b[2] + white * 0.1538520
        b[3] = 0.86650 * b[3] + white * 0.3104856
        b[4] = 0.55000 * b[4] + white * 0.5329522
        b[5] = -0.7616 * b[5] - white * 0.0168980
        pink = b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6] + white * 0.5362
        b[6] = white * 0.115926
        samples.append(pink * 0.1)
    return samples

def generate_brown_noise(duration):
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    last = 0.0
    for _ in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        last = (last + (0.02 * white)) / 1.02
        samples.append(last * 2.5)
    return samples

def generate_ocean_waves(duration):
    pink = generate_pink_noise(duration)
    brown = generate_brown_noise(duration)
    num_samples = len(pink)
    samples = []
    for i in range(num_samples):
        t = i / float(SAMPLE_RATE)
        # Slow swell envelope ~ 0.15 Hz wave cycle
        wave_env = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.12 * t))
        mix = (pink[i] * 0.6 + brown[i] * 0.4) * wave_env
        samples.append(mix)
    return samples

def generate_waterfall(duration):
    pink = generate_pink_noise(duration)
    brown = generate_brown_noise(duration)
    num_samples = len(pink)
    samples = []
    for i in range(num_samples):
        # Steady rich roar of cascading water
        mix = (pink[i] * 0.5 + brown[i] * 0.7)
        samples.append(mix)
    return samples

def generate_rainfall(duration):
    pink = generate_pink_noise(duration)
    num_samples = len(pink)
    samples = []
    for i in range(num_samples):
        # Rain texture: pink noise background + sporadic drop clicks
        p = pink[i] * 0.5
        if random.random() < 0.001:
            p += random.uniform(0.1, 0.3)
        samples.append(p)
    return samples

def generate_forest(duration):
    pink = generate_pink_noise(duration)
    num_samples = len(pink)
    samples = []
    for i in range(num_samples):
        t = i / float(SAMPLE_RATE)
        breeze = 0.2 + 0.3 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.2 * t))
        p = pink[i] * breeze * 0.4
        # Gentle distant bird tone at ~2.4kHz every 2 seconds
        if 1.0 < (t % 2.5) < 1.15:
            bird = 0.08 * math.sin(2 * math.pi * 2400 * t)
            p += bird
        samples.append(p)
    return samples

def generate_crickets(duration):
    brown = generate_brown_noise(duration)
    num_samples = len(brown)
    samples = []
    for i in range(num_samples):
        t = i / float(SAMPLE_RATE)
        bg = brown[i] * 0.15
        # Cricket chirp bursts every 1.2s with ~4.5kHz modulation
        chirp_cycle = t % 1.2
        if 0.0 < chirp_cycle < 0.18:
            pulse = math.sin(2 * math.pi * 40 * t)
            carrier = math.sin(2 * math.pi * 4500 * t)
            chirp = 0.12 * pulse * carrier
            bg += chirp
        samples.append(bg)
    return samples

def main():
    out_dir = "assets/sounds"
    print("Generating soothing ambient sleep soundscapes...")
    write_wav(f"{out_dir}/waterfall.wav", generate_waterfall(DURATION))
    write_wav(f"{out_dir}/ocean.wav", generate_ocean_waves(DURATION))
    write_wav(f"{out_dir}/rainfall.wav", generate_rainfall(DURATION))
    write_wav(f"{out_dir}/pink_noise.wav", generate_pink_noise(DURATION))
    write_wav(f"{out_dir}/brown_noise.wav", generate_brown_noise(DURATION))
    write_wav(f"{out_dir}/forest.wav", generate_forest(DURATION))
    write_wav(f"{out_dir}/crickets.wav", generate_crickets(DURATION))
    print("All audio files generated successfully!")

if __name__ == "__main__":
    main()
