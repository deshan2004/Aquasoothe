"""
FastAPI Production Server for Aquasoothe AudioLDM AI
=====================================================
Can be hosted for FREE on:
- Hugging Face Spaces (Docker / Python)
- Koyeb / Render / Railway / Cloud GPU
"""

import io
from contextlib import asynccontextmanager
import torch  # type: ignore
from fastapi import FastAPI, HTTPException, Response  # type: ignore
from fastapi.middleware.cors import CORSMiddleware  # type: ignore
from pydantic import BaseModel  # type: ignore
import scipy.io.wavfile  # type: ignore
import numpy as np  # type: ignore

pipe = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global pipe
    from diffusers import AudioLDMPipeline  # type: ignore
    print("[+] Loading AudioLDM Pipeline into memory...")
    device = "cuda" if torch.cuda.is_available() else ("mps" if torch.backends.mps.is_available() else "cpu")
    dtype = torch.float16 if torch.cuda.is_available() else torch.float32
    pipe = AudioLDMPipeline.from_pretrained("cvssp/audioldm-s-full-v2", torch_dtype=dtype)
    pipe = pipe.to(device)
    print(f"[+] AudioLDM model successfully loaded on {device}!")
    yield

app = FastAPI(
    title="Aquasoothe Sound Generation AI API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class GenerateRequest(BaseModel):
    prompt: str
    duration: float = 5.0

@app.get("/health")
def health_check():
    device = "cuda" if torch.cuda.is_available() else ("mps" if torch.backends.mps.is_available() else "cpu")
    return {
        "status": "healthy",
        "model_loaded": pipe is not None,
        "device": device,
    }

@app.post("/generate")
def generate_audio(request: GenerateRequest):
    global pipe
    if not request.prompt or not request.prompt.strip():
        raise HTTPException(status_code=400, detail="Prompt cannot be empty")

    if pipe is None:
        raise HTTPException(status_code=503, detail="Model is still loading...")

    try:
        duration = max(2.0, min(10.0, request.duration))
        print(f"[+] Generating sound for: '{request.prompt}' (length: {duration}s)")
        
        # AudioLDM diffusion inference (25 steps for quick generation)
        audio = pipe(
            request.prompt,
            num_inference_steps=25,
            audio_length_in_s=duration
        ).audios[0]

        # Convert to 16-bit PCM WAV in memory
        if audio.dtype != np.int16:
            audio = (np.clip(audio, -1.0, 1.0) * 32767).astype(np.int16)

        wav_buffer = io.BytesIO()
        scipy.io.wavfile.write(wav_buffer, rate=16000, data=audio)
        wav_bytes = wav_buffer.getvalue()

        return Response(
            content=wav_bytes,
            media_type="audio/wav",
            headers={
                "Content-Disposition": "attachment; filename=aquasoothe_ai_sound.wav"
            }
        )

    except Exception as e:
        print(f"[!] Generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn  # type: ignore
    uvicorn.run("server_app:app", host="0.0.0.0", port=7860, reload=False)
