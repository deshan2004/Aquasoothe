"""
Google Colab Training & Fine-Tuning Script for Aquasoothe AI Sound Generator
=============================================================================
Instructions for Google Colab:
1. Open Google Colab: https://colab.research.google.com
2. Change Runtime to GPU: Runtime -> Change runtime type -> Hardware accelerator: T4 GPU
3. Run the cells in this script.
"""

import os
import torch
import torchaudio
import soundfile as sf

print("CUDA Available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("Device Name:", torch.cuda.get_device_name(0))

# -------------------------------------------------------------
# 1. Install Required Dependencies (Run in Colab cell)
# -------------------------------------------------------------
# !pip install -U "torch>=2.1.0" "torchaudio>=2.1.0" audiocraft soundfile

from audiocraft.models import AudioGen, MusicGen
from audiocraft.data.audio import audio_write

# -------------------------------------------------------------
# 2. Load Base Model (AudioGen or MusicGen-small)
# -------------------------------------------------------------
print("\n[+] Loading Base AudioGen Model...")
device = 'cuda' if torch.cuda.is_available() else 'cpu'

# AudioGen specializes in environmental sounds, ambient soundscapes, nature & sound effects
model = AudioGen.get_pretrained('facebook/audiogen-medium')
model.set_generation_params(duration=5.0) # 5 seconds seamless loop

# -------------------------------------------------------------
# 3. Test Base Sound Generation
# -------------------------------------------------------------
prompts = [
    "gentle rain falling softly on window pane with distant thunder",
    "calm ocean waves washing onto sandy beach during sunset",
    "soothing bamboo water fountain with quiet forest birds"
]

print("\n[+] Testing Pre-trained Model with Relaxation Prompts...")
wav = model.generate(prompts)  # Shape: [batch, channels, samples]

os.makedirs("generated_samples", exist_ok=True)
for idx, one_wav in enumerate(wav):
    # Save output 32kHz audio sample
    audio_write(
        f"generated_samples/sample_{idx}",
        one_wav.cpu(),
        model.sample_rate,
        strategy="loudness",
        loudness_compressor=True
    )
    print(f" -> Generated sample_{idx}.wav for: '{prompts[idx]}'")

# -------------------------------------------------------------
# 4. Fine-Tuning on Custom Ambient Dataset (Client Customization)
# -------------------------------------------------------------
"""
To fine-tune on client's specific sound library:
1. Place client .wav sound files in a folder: 'custom_dataset/sounds/'
2. Create a metadata.json or captions.txt with prompt descriptions for each .wav.
3. AudioCraft's Solver handles fine-tuning:
   - Command:
     dora run solver=audiogen/audiogen_base_32khz \
              dataset.train.num_samples=1000 \
              dataset.train.batch_size=4
"""

def prepare_custom_dataset_manifest(audio_dir, output_manifest_json):
    """
    Scans a folder of .wav files and writes a manifest for model fine-tuning.
    """
    import json
    entries = []
    for file in os.listdir(audio_dir):
        if file.endswith('.wav') or file.endswith('.mp3'):
            filepath = os.path.join(audio_dir, file)
            # Use filename without extension as default descriptive prompt
            caption = os.path.splitext(file)[0].replace('_', ' ')
            entries.append({
                "path": filepath,
                "description": f"calm soothing ambient {caption}"
            })
    with open(output_manifest_json, 'w') as f:
        json.dump(entries, f, indent=2)
    print(f"Manifest created with {len(entries)} audio files at {output_manifest_json}")

# -------------------------------------------------------------
# 5. Export Model Checkpoint for Server Deployment
# -------------------------------------------------------------
export_path = "aquasoothe_audiogen_model.pt"
print(f"\n[+] Saving fine-tuned model checkpoint to {export_path}...")
torch.save(model.lm.state_dict(), export_path)
print("Model ready for deployment with server_app.py!")
