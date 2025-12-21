# PowerShell-Skript für AV1-Encoding mit ffmpeg (HDR-fähig, optional Testmodus, AAC-Audio)

$ErrorActionPreference = "Stop"

$OUT_DIR = "av1_out"
if (-not (Test-Path $OUT_DIR)) {
    New-Item -ItemType Directory -Path $OUT_DIR | Out-Null
}

# Video-Parameter
$THREADS = 24
$CRF = 32
$SVT_PRESET = 4
$AOM_CPU_USED = 6

# Testmodus: nur die ersten 10 Minuten encodieren
$TESTMODE = $false
$TEST_DURATION = 600   # Sekunden (600 = 10 Minuten)

# Audio-Einstellungen
$REENCODE_AUDIO = $true   # true = AAC neu encodieren, false = copy
$AAC_BITRATE = "512k"     # ausreichend hoch für Mehrkanal

# Videodateien im aktuellen Ordner
$exts = "*.mp4","*.mkv","*.mov","*.avi","*.webm","*.flv","*.m4v","*.mpg","*.mpeg","*.ts","*.m2ts"
$FILES = foreach ($ext in $exts) { Get-ChildItem -File $ext }

if ($FILES.Count -eq 0) {
    Write-Host "Keine Videodateien im aktuellen Ordner gefunden."
    exit 0
}

# Encoder-Erkennung
$encoders = & ffmpeg -hide_banner -encoders 2>$null
if ($encoders -match "libsvtav1") {
    $VENC = "libsvtav1"
} elseif ($encoders -match "libaom-av1") {
    $VENC = "libaom-av1"
} else {
    Write-Host "Kein AV1-Encoder gefunden (weder libsvtav1 noch libaom-av1)."
    exit 1
}

Write-Host "Benutze Video-Encoder: $VENC"
Write-Host "Threads: $THREADS"

foreach ($file in $FILES) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $out = Join-Path $OUT_DIR "$base.av1.mkv"

    if (Test-Path $out) {
        Write-Host "Überspringe (existiert): $out"
        continue
    }

    Write-Host "Analyse: $($file.Name)"

    # HDR-Metadaten auslesen
    $ffprobeStream = & ffprobe -v error -select_streams v:0 -show_entries stream=color_primaries,color_transfer,color_space -of default=noprint_wrappers=1 $file.FullName
    $colorPrimaries = ($ffprobeStream | Where-Object { $_ -like "color_primaries*" }) -replace "color_primaries=", ""
    $colorTrc       = ($ffprobeStream | Where-Object { $_ -like "color_transfer*" }) -replace "color_transfer=", ""
    $colorSpace     = ($ffprobeStream | Where-Object { $_ -like "color_space*" }) -replace "color_space=", ""

    # Side Data für HDR (Mastering Display + Content Light Level)
    $ffprobeSide = & ffprobe -v error -select_streams v:0 -show_entries stream=side_data_list -of default=noprint_wrappers=1:nokey=1 $file.FullName
    $masterDisplay = ($ffprobeSide | Where-Object { $_ -like "*Mastering display metadata*" }) -replace "Mastering display metadata: ", ""
    $contentLight  = ($ffprobeSide | Where-Object { $_ -like "*Content light level*" }) -replace "Content light level: ", ""

    Write-Host "Encode: $($file.Name) -> $out"
    Write-Host "HDR Info: Primaries=$colorPrimaries, TRC=$colorTrc, Space=$colorSpace"
    if ($masterDisplay) { Write-Host "Master Display: $masterDisplay" }
    if ($contentLight)  { Write-Host "Content Light: $contentLight" }

    # Audio-Optionen
   if ($REENCODE_AUDIO) {
    $audioArgs = @("-c:a", "aac", "-b:a", $AAC_BITRATE)
} else {
    $audioArgs = @("-c:a", "copy")
}

$commonArgs = @(
    "-map", "0",
    "-c:s", "copy",
    "-color_primaries", $colorPrimaries,
    "-color_trc", $colorTrc,
    "-colorspace", $colorSpace
)

if ($masterDisplay) { $commonArgs += @("-master_display", $masterDisplay) }
if ($contentLight)  { $commonArgs += @("-content_light", $contentLight) }
if ($TESTMODE)      { $commonArgs += @("-t", $TEST_DURATION) }

# Jetzt Audio-Args anhängen
$commonArgs = $audioArgs + $commonArgs

    if ($VENC -eq "libsvtav1") {
        & ffmpeg -hide_banner -y -i $file.FullName `
            -c:v libsvtav1 -crf $CRF -preset $SVT_PRESET -threads $THREADS `
            $commonArgs `
            $out
    } else {
        & ffmpeg -hide_banner -y -i $file.FullName `
            -c:v libaom-av1 -crf $CRF -b:v 0 -cpu-used $AOM_CPU_USED -row-mt 1 -threads $THREADS `
            $commonArgs `
            $out
    }
}

Write-Host "Fertig. Ausgabe in: $OUT_DIR/"
