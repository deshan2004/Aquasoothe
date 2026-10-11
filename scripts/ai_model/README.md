# Complete AI Sound Generation Model Training & Server Setup
# For Aquasoothe Client Project

## Overview
This setup enables training/fine-tuning a custom Text-to-Audio AI model (Meta AudioCraft - AudioGen / MusicGen) and deploying it on a free server (Hugging Face Spaces / FastAPI) to connect with the Aquasoothe Flutter app.

---

### Step 1: Train / Test in Google Colab (Free GPU)
1. Open [Google Colab](https://colab.research.google.com).
2. Set Runtime to **T4 GPU** (Runtime -> Change runtime type -> T4 GPU).
3. Copy the code from `train_audiocraft.py` or run the notebook cells.
4. The script loads the base AudioGen/MusicGen model, runs fine-tuning or conditioned audio generation on relaxation/nature prompts, and exports the model.

---

### Step 2: Deploy Free Backend API (Hugging Face Spaces)
1. Go to [Hugging Face Spaces](https://huggingface.co/spaces) and click **Create new Space**.
2. Space Name: `aquasoothe-sound-ai`
3. SDK: Select **Docker** or **Gradio / FastAPI**.
4. Upload `server_app.py` and `requirements.txt`.
5. Hugging Face gives you a live permanent public URL:
   `https://<your-username>-aquasoothe-sound-ai.hf.space/generate`

---

### Step 3: Connect to Flutter App
1. Open `lib/services/ai_sound_generator_service.dart`.
2. Set `customAiServerUrl` to your live API endpoint.
3. Aquasoothe will send user prompts to your AI server and play the studio-quality generated audio!
