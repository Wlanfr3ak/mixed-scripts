#!/bin/bash
# make with copilot.microsoft.com

# System aktualisieren und notwendige Pakete installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip python3-dev build-essential

# NVIDIA CUDA-Toolkit installieren (falls nicht bereits vorhanden)
if ! dpkg-query -l | grep cuda; then
    echo "CUDA-Toolkit wird installiert..."
    sudo apt install -y nvidia-cuda-toolkit
fi

# Virtuelle Umgebung erstellen
python3 -m venv myenv
source myenv/bin/activate

# Paketinstallation sicherstellen
pip install --upgrade pip
pip install sympy torch torchvision torchaudio

# CUDA-Verfügbarkeit testen
python3 -c "import torch; print('CUDA verfügbar:', torch.cuda.is_available())"

# Hinweis beenden
echo "Installation abgeschlossen! Die virtuelle Umgebung befindet sich im Ordner 'myenv'."
