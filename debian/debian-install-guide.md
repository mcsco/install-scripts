# Debian Install Guide

### Upgrade to Unstable/Sid
Edit /etc/apt/sources.list

Change bookworm or w/e to unstable and add contrib and non-free
```
deb http://deb.debian.org/debian/ unstable main contrib non-free non-free-firmware
```
### Update system and reboot
```
sudo apt update && sudo apt full-upgrade -y
sudo reboot
```

### Remove not needed packages
```
sudo apt autoremove
```

### Install firewall
```
sudo apt update && sudo apt install ufw -y
```

### Configure Firewall
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw enable
```

### Install minimal KDE Plasma
```
sudo apt install kde-plasma-desktop
```

### Install Timeshift
```
sudo apt install timeshift
```

### Configure grub-btrfs
```
sudo apt install git build-essential inotify-tools
```
```
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
sudo grub-mkconfig
cd ..
rm -rvf grub-btrfs
```
***Reboot System***

### Install AMD Drivers
```
sudo apt install firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all
```

Add 32-bit support
```
sudo dpkg --add-architecture i386 && sudo apt update
sudo apt install libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
```

### Remove firefox-esr and install firefox
```
sudo apt remove --purge firefox-esr -y
sudo apt install firefox -y
```

### Betterfox Firefox profile
```
git clone https://github.com/yokoffing/Betterfox.git
```

### Install flatpak
```
sudo apt install flatpak plasma-discover-backend-flatpak
```
Enable flathub repo in discorver

### Add Beta repo of flathub **OPTIONAL**
```
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
```

### Flatpaks for KDE Install
```
flatpak install -y flathub com.transmissionbt.Transmission com.github.tchx84.Flatseal com.github.finefindus.eyedropper org.kde.krita net.davidotek.pupgui2 com.heroicgameslauncher.hgl com.valvesoftware.Steam org.freedesktop.Platform.VulkanLayer.MangoHud com.obsproject.Studio com.usebottles.bottles com.obsproject.Studio.Plugin.OBSVkCapture org.pipewire.Helvum org.freedesktop.Platform.VulkanLayer.OBSVkCapture org.freedesktop.Platform.VulkanLayer.gamescope org.prismlauncher.PrismLauncher com.discordapp.Discord org.freedesktop.Platform.ffmpeg-full
```

### Additional Packages
```
sudo apt install -y zram-tools curl git build-essential unzip unrar steam-devices neovim sqlite3 zsh zsh-autosuggestions zsh-syntax-highlighting python3-pip ffmpeg v4l2loopback-dkms yt-dlp distrobox podman nextcloud-desktop dolphin-nextcloud kdevelop plasma-nm kontact korganizer timeshift gamemode dolphin-plugins apparmor apparmor-utils apparmor-profiles apparmor-profiles-extra apparmor-notify pipewire pipewire-audio wireplumber libspa-0.2-bluetooth obs-studio qbittorent ark ripgrep
```

### Config Pipewire
```
systemctl --user start pipewire
systemctl --user --now enable wireplumber.service
systemctl --user restart wireplumber pipewire pipewire-pulse
```
reboot system
```
LANG=C pactl info | grep '^Server Name'
```
If PipeWire is configured properly, this will print "Server Name: PulseAudio (on PipeWire X.X.XX)"

### Config Apparmor
```
sudo usermod -aG adm $USER
sudo cp /usr/share/apparmor/extra-profiles/firefox /etc/apparmor.d/
sudo aa-complain /etc/apparmor.d/firefox
```

### v41sloopback
```
1. installing v4l2loopback-dkms will install the modules on your system (at least: if all goes well), but it will not load the modules for you
2. so you need to manually load the module with something like modprobe v4l2loopack
3. in order for zoom to use the device, you will first have to attach OBS-studio to it.
```

### Install Brave
```
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
```

### Asus Linux Laptop
```
mkdir -vp $HOME/src && cd $HOME/src
git clone https://gitlab.com/asus-linux/asusctl.git
sudo apt install libgtk-3-dev libpango1.0-dev libgdk-pixbuf-2.0-dev libglib2.0-dev cmake libclang-dev libudev-dev libayatana-appindicator3-1
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
make
sudo make install
```
