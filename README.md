# whisper

Local, multilingual, real-time speech-to-text using Whisper (`faster-whisper`) served through
[WhisperLiveKit](https://pypi.org/project/whisperlivekit/). Speak into the browser mic and see text live.

## Setup (Windows)

```powershell
python -m venv venv
venv\Scripts\python.exe -m pip install faster-whisper sounddevice numpy nvidia-cublas-cu12 nvidia-cudnn-cu12 whisperlivekit
```

The first run downloads the model (large-v3 is ~3 GB).

## Run the live server

```powershell
.\start_server.ps1                          # large-v3 on GPU (int8_float16), language auto-detect
.\start_server.ps1 -Language hi             # force Hindi
.\start_server.ps1 -Model large-v3-turbo    # faster, slightly less accurate
.\start_server.ps1 -Device cpu -CpuThreads 8   # run on CPU (int8)
```

Then open http://localhost:8000 and allow the microphone.

## Files

- `start_server.ps1` - starts the server (device, model, language options).
- `run_wlk.py` - launcher that forces faster-whisper device/compute type (WhisperLiveKit hardcodes `auto`).
- `realtime.py` - standalone terminal mic transcription script (no browser).

## Notes

- `--pcm-input` is used so FFmpeg is not required.
- `--backend-policy localagreement` is used because the default `simulstreaming` policy hit a recursion bug with
  faster-whisper's encoder output in WhisperLiveKit 0.2.26.
- Whisper accuracy on Hindi/Hinglish is well below English; auto language detection can pick the wrong language
  in live streaming. Use `-Language hi` for Hindi speech.
- A single model runs on either GPU or CPU, not both at once.
