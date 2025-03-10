#!/bin/bash
# make with copilot.microsoft.com

# System aktualisieren und notwendige Pakete installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip python3-dev build-essential wget

# Funktion: CUDA-Toolkit aus dem NVIDIA-Repository installieren
install_cuda_from_nvidia() {
    echo "CUDA-Toolkit aus dem NVIDIA-Repository wird installiert..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    echo "deb [signed-by=/usr/share/keyrings/cuda-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/ /" | sudo tee /etc/apt/sources.list.d/cuda.list
    sudo apt update
    sudo apt install -y cuda
    # Umgebungsvariablen konfigurieren
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    source ~/.bashrc
}

# NVIDIA CUDA-Toolkit installieren, falls nicht über Standardquellen verfügbar
if ! sudo apt install -y nvidia-cuda-toolkit; then
    echo "CUDA-Toolkit nicht in den Standardquellen verfügbar. Installation wird aus dem NVIDIA-Repository versucht..."
    install_cuda_from_nvidia
fi

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
