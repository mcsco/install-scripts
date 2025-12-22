#!/bin/sh
#

# Configure dnf
printf "%s" "
fastestmirror=True
max_parallel_downloads=10
countme=False
" | sudo tee -a /etc/dnf/dnf.conf

# Setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
# For dnf5
sudo dnf group upgrade core -y
# For dnf4
# sudo dnf groupupdate core -y

# Updating system
sudo dnf upgrade -y

#Setting umask to 077
# No one except wheel user and root get read/write files
umask 077
sudo sed -i 's/umask 022/umask 077/g' /etc/bashrc

# Debloat Fedora KDE
sudo dnf remove -y anaconda* \
	atmel-firmware libertas-usb8388-firmware abrt* open-vm-tools nano nano-default-editor sos cyrus-sasl-plain spice-vdagent adcli realmd vpnc xorg-x11-drv-vmware \
	hyperv* virtualbox-guest-additions qemu-guest-agent kmines kpat akregator kamoso konversation kmahjongg kmouth kcharselect libreoffice-core* kwrite

# Run Updates
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates -y
sudo fwupdmgr update -y

# Setup Flathub beta and third party packages
sudo fedora-third-party enable
sudo fedora-third-party refresh
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Hardware codecs with Intel
sudo dnf install intel-media-driver
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld

# Hardware codecs with AMD (mesa)
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# 32-bit compatibility (for steam or alikes)
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686

# Flatpaks
flatpak install -y flathub com.transmissionbt.Transmission org.libreoffice.LibreOffice com.github.tchx84.Flatseal com.github.finefindus.eyedropper org.kde.krita \
	net.davidotek.pupgui2 com.heroicgameslauncher.hgl com.valvesoftware.Steam org.freedesktop.Platform.VulkanLayer.MangoHud com.obsproject.Studio com.usebottles.bottles \
	com.obsproject.Studio.Plugin.OBSVkCapture org.pipewire.Helvum org.freedesktop.Platform.VulkanLayer.OBSVkCapture org.freedesktop.Platform.VulkanLayer.gamescope \
	org.prismlauncher.PrismLauncher com.discordapp.Discord org.freedesktop.Platform.ffmpeg-full net.lutris.Lutris org.localsend.localsend_app

# Additional Packages
sudo dnf install -y ansible git steam-devices neovim sqlite3 zsh zsh-autosuggestions zsh-syntax-highlighting setroubleshoot ffmpeg compat-ffmpeg4 akmod-v4l2loopback yt-dlp \
	@virtualization guestfs-tools distrobox podman kdevelop plasma-nm kontact korganizer gamemode kate vlc vlc-plugin-pipewire --best --allowerasing

# Even more Packages
sudo dnf install -y discord obs-studio obs-studio-plugin-vaapi obs-studio-plugin-vkcapture

# Development Tools
sudo dnf group install -y "C Development Tools and Libraries" "Development Tools"

# Brave Browser
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

# Mullvad VPN
sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf install mullvad-vpn

# EW
sudo dnf install python3-pyqt6 libsecp256k1 python3-cryptography python3-setuptools python3-pip

# Multi Media
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video

# Initialize Virtualization
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"

# Remove Firewalld's Default Rules
sudo firewall-cmd --permanent --remove-port=1025-65535/udp
sudo firewall-cmd --permanent --remove-port=1025-65535/tcp
sudo firewall-cmd --permanent --remove-service=mdns
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --remove-service=samba-client
sudo firewall-cmd --reload

# Add LocalSend Default Port
sudo firewall-cmd --add-port=53317/udp
sudo firewall-cmd --add-port=53317/tcp

# Asus Linux Laptop Support
sudo dnf copr enable lukenukem/asus-linux
sudo dnf update -y
sudo dnf install -y asusctl supergfxctl
sudo dnf update --refresh
sudo systemctl enable supergfxd.service
sudo dnf install -y asusctl-rog-gui

# Make the Home folder private
# Privatizing the home folder creates problems with virt-manager
# accessing ISOs from your home directory. Store images in /var/lib/libvirt/images
chmod 700 /home/"$(whoami)"

echo "Make sure to reboot your system!"
