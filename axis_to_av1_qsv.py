# axis_to_av1_qsv.py
# Erstellt mit Windsurf IDE / KI-Assistent
# Windows, benötigt FFmpeg im PATH mit 'av1_qsv' Unterstützung (z.B. Gyan.dev Full/Essentials)
# Start: python axis_to_av1_qsv.py

import subprocess
import shutil
import sys
from pathlib import Path

# =========================
# Konfiguration (Variablen)
# =========================
CAMERA_IP = "192.168.178.XXX"
HTTP_USER = ""   # HTTP-Auth Benutzername (leer = keine Auth)
HTTP_PASS = ""   # HTTP-Auth Passwort (leer = keine Auth)

# Stream-Typ: "mjpeg" oder "rtsp"
STREAM_TYPE = "mjpeg"  # MJPEG über HTTP (funktioniert!)

# MJPEG-Konfiguration
MJPEG_PATH = "/mjpg/video.mjpg?camera=1&timestamp=1759351172727"  # AXIS MJPEG-Stream (funktionierende URL)

# RTSP-Konfiguration (falls STREAM_TYPE = "rtsp")
RTSP_PATH = "/axis-media/media.amp?streamprofile=profile_1"  # AXIS RTSP H.264
USE_TCP = True  # TCP für RTSP

OUTPUT_DIR = r".\records"
FILENAME_PATTERN = "%Y-%m-%d-%H-%M.mp4"  # YYYY-MM-DD-HH-MM.mp4
SEGMENT_SECONDS = 3600  # 1 Stunde

OVERWRITE_OUTPUT = True
LOGLEVEL = "info"

# Intel QSV
USE_HW_DECODE = False  # Für MJPEG nicht nötig (kein H.264)
AV1_GLOBAL_QUALITY = 24       # kleiner = bessere Qualität, größere Datei (typisch 16-30)
AV1_PRESET = 7                # höher = langsamer/besser (1=schneller)
LOOK_AHEAD = True
KEYINT = 240                  # Keyframe-Intervall (Sekundär, hilft beim Seeking)

# Debug-Modus
DEBUG = True  # Setze auf False für weniger Output

# =========================

def debug_print(msg):
    """Gibt Debug-Meldungen aus, wenn DEBUG aktiviert ist."""
    if DEBUG:
        print(f"[DEBUG] {msg}", flush=True)

def ensure_ffmpeg():
    """Prüft FFmpeg-Installation und Unterstützung für av1_qsv."""
    debug_print("Prüfe FFmpeg-Installation...")
    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        sys.exit("❌ FFmpeg nicht gefunden. Bitte FFmpeg installieren und in PATH eintragen.")
    
    debug_print(f"FFmpeg gefunden: {ffmpeg}")
    
    # Prüfe FFmpeg-Version
    try:
        version_out = subprocess.check_output(
            [ffmpeg, "-version"],
            text=True, encoding="utf-8", stderr=subprocess.STDOUT
        )
        first_line = version_out.split('\n')[0]
        debug_print(f"FFmpeg Version: {first_line}")
    except Exception as e:
        debug_print(f"Konnte FFmpeg-Version nicht ermitteln: {e}")
    
    # Prüfe av1_qsv Encoder
    try:
        out = subprocess.check_output(
            [ffmpeg, "-hide_banner", "-v", "quiet", "-encoders"],
            text=True, encoding="utf-8"
        )
        if "av1_qsv" not in out:
            sys.exit("❌ FFmpeg unterstützt 'av1_qsv' nicht. Bitte ein FFmpeg-Build mit QSV/oneVPL nutzen.")
        debug_print("✓ av1_qsv Encoder verfügbar")
    except Exception as e:
        sys.exit(f"❌ FFmpeg-Abfrage fehlgeschlagen: {e}")
    
    # Prüfe h264_qsv Decoder (optional)
    if USE_HW_DECODE:
        try:
            dec_out = subprocess.check_output(
                [ffmpeg, "-hide_banner", "-v", "quiet", "-decoders"],
                text=True, encoding="utf-8"
            )
            if "h264_qsv" in dec_out:
                debug_print("✓ h264_qsv Decoder verfügbar")
            else:
                debug_print("⚠ h264_qsv Decoder nicht verfügbar, falle auf Software-Decode zurück")
        except Exception as e:
            debug_print(f"Konnte Decoder nicht prüfen: {e}")
    
    return ffmpeg

def test_stream_connection(stream_url: str, ffmpeg_path: str, is_rtsp: bool = False) -> bool:
    """Testet die Stream-Verbindung mit ffprobe."""
    stream_type = "RTSP" if is_rtsp else "HTTP/MJPEG"
    debug_print(f"Teste {stream_type}-Verbindung...")
    
    # Versuche ffprobe zu finden
    ffprobe = shutil.which("ffprobe")
    if not ffprobe:
        # Versuche ffprobe im gleichen Verzeichnis wie ffmpeg
        ffmpeg_dir = Path(ffmpeg_path).parent
        ffprobe_candidate = ffmpeg_dir / "ffprobe.exe"
        if ffprobe_candidate.exists():
            ffprobe = str(ffprobe_candidate)
        else:
            debug_print("⚠ ffprobe nicht gefunden, überspringe Verbindungstest")
            return True
    
    try:
        # Baue ffprobe-Befehl
        cmd = [ffprobe, "-v", "error"]
        
        if is_rtsp:
            cmd += ["-rtsp_transport", "tcp"]
        
        cmd += ["-i", stream_url, "-show_entries", "stream=codec_type,width,height,codec_name",
                "-of", "default=noprint_wrappers=1"]
        
        # Teste Stream mit ffprobe (max 10s Timeout)
        result = subprocess.run(
            cmd,
            capture_output=True, text=True, timeout=10, encoding="utf-8"
        )
        
        if result.returncode == 0:
            debug_print(f"✓ {stream_type}-Verbindung erfolgreich")
            if result.stdout:
                debug_print(f"Stream-Info:\n{result.stdout}")
            return True
        else:
            print(f"❌ {stream_type}-Verbindung fehlgeschlagen:")
            if result.stderr:
                print(result.stderr)
            return False
    except subprocess.TimeoutExpired:
        print(f"❌ {stream_type}-Verbindungstest Timeout (>10s)")
        return False
    except Exception as e:
        debug_print(f"⚠ {stream_type}-Test fehlgeschlagen: {e}")
        return True  # Fahre trotzdem fort

def build_stream_url() -> tuple[str, bool]:
    """Baut die Stream-URL aus den Konfigurationsvariablen.
    
    Returns:
        tuple: (url, is_rtsp)
    """
    if STREAM_TYPE.lower() == "mjpeg":
        # HTTP/MJPEG Stream
        if HTTP_USER and HTTP_PASS:
            auth = f"{HTTP_USER}:{HTTP_PASS}@"
            debug_print(f"Verwende HTTP-Authentifizierung (User: {HTTP_USER})")
        else:
            auth = ""
            debug_print("Verwende HTTP ohne Authentifizierung")
        
        url = f"http://{auth}{CAMERA_IP}{MJPEG_PATH}"
        is_rtsp = False
        
        # Zeige URL ohne Passwort im Debug
        if HTTP_PASS:
            safe_url = url.replace(HTTP_PASS, "***")
            debug_print(f"MJPEG-URL: {safe_url}")
        else:
            debug_print(f"MJPEG-URL: {url}")
    else:
        # RTSP Stream
        if HTTP_USER and HTTP_PASS:
            auth = f"{HTTP_USER}:{HTTP_PASS}@"
            debug_print(f"Verwende RTSP-Authentifizierung (User: {HTTP_USER})")
        else:
            auth = ""
            debug_print("Verwende RTSP ohne Authentifizierung")
        
        url = f"rtsp://{auth}{CAMERA_IP}{RTSP_PATH}"
        is_rtsp = True
        
        if HTTP_PASS:
            safe_url = url.replace(HTTP_PASS, "***")
            debug_print(f"RTSP-URL: {safe_url}")
        else:
            debug_print(f"RTSP-URL: {url}")
    
    return url, is_rtsp

def build_ffmpeg_cmd(ffmpeg_path: str, stream_url: str, out_pattern: str, is_rtsp: bool):
    """Baut den FFmpeg-Befehl mit allen Parametern."""
    debug_print("Baue FFmpeg-Befehl...")
    
    cmd = [
        ffmpeg_path,
        "-hide_banner",
        "-loglevel", LOGLEVEL,
        "-y" if OVERWRITE_OUTPUT else "-n",
    ]

    # Eingabeoptionen (müssen vor -i stehen)
    if is_rtsp and USE_TCP:
        cmd += ["-rtsp_transport", "tcp"]
        debug_print("Verwende TCP für RTSP-Transport")
    
    if not is_rtsp:
        # MJPEG-spezifische Optionen für Live-Stream
        cmd += [
            "-f", "mjpeg",  # Explizit MJPEG-Format
            "-use_wallclock_as_timestamps", "1",  # Verwende Systemzeit als Timestamps
        ]
        debug_print("MJPEG-Modus: Live-Stream-Optionen aktiviert")
    
    cmd += [
        "-fflags", "+genpts",
    ]
    
    # Hardware-Decode nur für H.264 (RTSP), nicht für MJPEG
    if USE_HW_DECODE and is_rtsp:
        cmd += ["-hwaccel", "qsv", "-c:v", "h264_qsv"]
        debug_print("Hardware-Decode (h264_qsv) aktiviert")
    elif not is_rtsp:
        debug_print("MJPEG-Decode: Software (MJPEG hat keine QSV-Unterstützung)")

    cmd += ["-i", stream_url]

    # Nur Video, kein Audio
    cmd += ["-map", "0:v:0", "-an"]
    debug_print("Nur Video, Audio deaktiviert")

    # AV1 (Intel QSV) Encode
    cmd += ["-c:v", "av1_qsv", "-global_quality", str(AV1_GLOBAL_QUALITY), "-preset", str(AV1_PRESET)]
    debug_print(f"AV1 QSV Encode: Quality={AV1_GLOBAL_QUALITY}, Preset={AV1_PRESET}")
    
    if LOOK_AHEAD:
        cmd += ["-look_ahead", "1"]
        debug_print("Look-ahead aktiviert")
    if KEYINT:
        cmd += ["-g", str(KEYINT)]
        debug_print(f"Keyframe-Intervall: {KEYINT}")

    # Exakte 1h-Schnittpunkte als Keyframes
    cmd += ["-force_key_frames", f"expr:gte(t,n_forced*{SEGMENT_SECONDS})"]
    debug_print(f"Segmentierung: {SEGMENT_SECONDS}s ({SEGMENT_SECONDS//3600}h)")

    # Container + Segmentierung
    cmd += [
        "-movflags", "+faststart",
        "-f", "segment",
        "-segment_time", str(SEGMENT_SECONDS),
        "-reset_timestamps", "1",
        "-strftime", "1",
        out_pattern,
    ]
    debug_print(f"Ausgabemuster: {out_pattern}")
    return cmd

def main():
    print("="*60)
    print("AXIS H.264 → AV1 (Intel QSV) Recorder")
    print("="*60)
    
    # 1. FFmpeg prüfen
    ffmpeg_path = ensure_ffmpeg()
    
    # 2. Ausgabeverzeichnis erstellen
    debug_print(f"Erstelle Ausgabeverzeichnis: {OUTPUT_DIR}")
    try:
        Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
        debug_print("✓ Ausgabeverzeichnis bereit")
    except Exception as e:
        sys.exit(f"❌ Konnte Ausgabeverzeichnis nicht erstellen: {e}")
    
    # 3. Stream-URL bauen
    stream_url, is_rtsp = build_stream_url()
    stream_type = "RTSP" if is_rtsp else "MJPEG"
    debug_print(f"Stream-Typ: {stream_type}")
    
    # 4. Stream-Verbindung testen
    if DEBUG:
        if not test_stream_connection(stream_url, ffmpeg_path, is_rtsp):
            print(f"\n⚠ {stream_type}-Verbindungstest fehlgeschlagen!")
            print("Mögliche Ursachen:")
            if is_rtsp:
                print("  - Falsche IP-Adresse oder RTSP-Pfad")
                print("  - Authentifizierung erforderlich (HTTP_USER/HTTP_PASS setzen)")
                print("  - Kamera nicht erreichbar")
                print("  - Firewall blockiert Port 554")
            else:
                print("  - Falsche IP-Adresse oder MJPEG-Pfad")
                print("  - Authentifizierung erforderlich (HTTP_USER/HTTP_PASS setzen)")
                print("  - Kamera nicht erreichbar")
                print("  - Firewall blockiert Port 80")
            response = input("\nTrotzdem fortfahren? (j/n): ")
            if response.lower() not in ['j', 'y', 'ja', 'yes']:
                sys.exit("Abgebrochen durch Benutzer.")
    
    # 5. FFmpeg-Befehl bauen
    out_pattern = str(Path(OUTPUT_DIR) / FILENAME_PATTERN)
    cmd = build_ffmpeg_cmd(ffmpeg_path, stream_url, out_pattern, is_rtsp)
    
    # 6. Befehl anzeigen
    print("\n" + "="*60)
    print("FFmpeg-Befehl:")
    print("="*60)
    # Zeige Befehl ohne Passwort
    safe_cmd = [c.replace(HTTP_PASS, "***") if HTTP_PASS and HTTP_PASS in c else c for c in cmd]
    print(" ".join(map(str, safe_cmd)))
    print("="*60 + "\n")
    
    # 7. Starten
    print("Starte Aufnahme... (Strg+C zum Beenden)\n")
    
    try:
        # Läuft bis Abbruch (Ctrl+C) oder Fehler
        result = subprocess.run(cmd, check=False)
        if result.returncode != 0:
            print(f"\n❌ FFmpeg beendet mit Fehlercode: {result.returncode}")
            sys.exit(result.returncode)
    except KeyboardInterrupt:
        print("\n✓ Beendet durch Benutzer.")
    except Exception as e:
        print(f"\n❌ Fehler beim Ausführen von FFmpeg: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
