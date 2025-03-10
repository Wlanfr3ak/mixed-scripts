#!/bin/bash
# make with copilot.microsoft.com

# System aktualisieren und notwendige Pakete installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip python3-dev build-essential wget

# es müssen non-free und contrib in die repos dann einfach apt-get update und dann install nvidia-driver ....

sudo apt update && sudo apt install nvidia-detect -y
nvidia-detect
sudo apt install nvidia-driver -y

# Nivida CUDA Toolkit installieren:

# Virtuelle Python-Umgebung erstellen
python3 -m venv myenv
source myenv/bin/activate

# Paketinstallation sicherstellen
pip install --upgrade pip
pip install sympy torch torchvision torchaudio

# CUDA-Verfügbarkeit testen
python3 -c "import torch; print('CUDA verfügbar:', torch.cuda.is_available())"

# Hinweis beenden
echo "Installation abgeschlossen! Die virtuelle Umgebung befindet sich im Ordner 'myenv'."
