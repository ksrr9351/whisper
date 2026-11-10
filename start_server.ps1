# WhisperLiveKit live server - multilingual (faster-whisper, GPU)
# Run from YOUR OWN PowerShell:   cd D:\whisperai ; .\start_server.ps1
# Examples:
#   .\start_server.ps1 -Language hi            (force Hindi - recommended for Hindi speech)
#   .\start_server.ps1 -Model large-v3-turbo   (faster, a bit less accurate)
#   .\start_server.ps1 -Compute float16        (more VRAM; large-v3 may not fit 6 GB)
#   .\start_server.ps1 -Device cpu -CpuThreads 8   (CPU only, slow with large-v3)
param(
    [string]$Model = "large-v3",
    [string]$Language = "auto",
    [string]$Compute = "",          # default: int8_float16 on GPU, int8 on CPU
    [string]$Device = "cuda",
    [int]$CpuThreads = 0,           # CPU mode only; 0 = library default
    [int]$Port = 8000,
    [switch]$Diarization
)

$root = $PSScriptRoot
$py = Join-Path $root "venv\Scripts\python.exe"

# Make pip-installed CUDA libs (cuBLAS / cuDNN) visible to ctranslate2
Get-ChildItem (Join-Path $root "venv\Lib\site-packages\nvidia") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $bin = Join-Path $_.FullName "bin"
    if (Test-Path $bin) { $env:PATH = "$bin;$env:PATH" }
}

if (-not $Compute) { $Compute = if ($Device -eq "cpu") { "int8" } else { "int8_float16" } }
if ($Device -eq "cpu" -and $Compute -like "*float16*") {
    Write-Host "float16 CPU par support nahi hota, int8 use kar raha hoon."
    $Compute = "int8"
}

$env:WLK_DEVICE = $Device
$env:WLK_COMPUTE = $Compute
$env:WLK_CPU_THREADS = $CpuThreads

$a = @("--model", $Model, "--language", $Language, "--backend", "faster-whisper",
       "--backend-policy", "localagreement", "--port", $Port, "--pcm-input")
if ($Diarization) { $a += "--diarization" }

Write-Host "Starting WhisperLiveKit: model=$Model language=$Language device=$Device compute=$Compute port=$Port"
Write-Host "Pehli baar large-v3 (~3 GB) download hoga. Phir browser: http://localhost:$Port`n"

& $py (Join-Path $root "run_wlk.py") @a
