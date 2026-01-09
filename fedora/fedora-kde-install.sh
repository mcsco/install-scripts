#!/bin/sh
#

# Configure dnf
printf "%s" "
fastestmirror=True
max_parallel_downloads=10
countme=False
defaultyes=True
" | sudo tee -a /etc/dnf/dnf.conf

# Setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
# Install app-stream metadata
sudo dnf group upgrade core -y
sudo dnf4 group install core -y
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

# Debloat Fedora Workstation
sudo dnf remove -y anaconda* \
	atmel-firmware brasero-libs libertas-usb8388-firmware abrt* open-vm-tools nano nano-default-editor sos cyrus-sasl-plain spice-vdagent adcli realmd vpnc xorg-x11-drv-vmware gnome-shell-extension-background-logo gnome-maps gnome-clocks totem snapshot decibels loupe gnome-backgrounds \
	hyperv* virtualbox-guest-additions qemu-guest-agent cheese eog evince evince-djvu fedora-bookmarks fedora-chromium-config \
	gnome-boxes gnome-calculator gnome-calendar gnome-characters gnome-classic-session gnome-clock gnome-color-manager \
	gnome-texteditorvince gnome-themes-extra gnome-tour gnome-user-docs gnome-weather gnome-connections gnome-logs gnome-font-viewer \
	gnome-contacts showtime yajl yelp totem libreoffice-core*

# Remove Orphan packages
sudo dnf autoremove -y

# Run Updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-devices # Lists devices with available updates.
sudo fwupdmgr get-updates # Fetches list of available updates.
sudo fwupdmgr update

# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Fedora doesn't enable Flatpak user-home installation by default
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Setup Flathub beta and third party packages
sudo fedora-third-party enable
sudo fedora-third-party refresh
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Hardware codecs with Intel
sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
sudo dnf install libva-intel-driver
# sudo dnf install intel-media-driver -- not required due to above commands

# Hardware codecs with AMD (mesa)
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686

# NVIDIA Drivers
mokutil --sb-state # checks to see if secure boot is enabled
#
sudo dnf install akmod-nvidia
sudo dnf install xorg-x11-drv-nvidia-cuda
# Wait 5 minutes before rebooting to let time for the kernel module to be built
modinfo -F version nvidia # checks to see if the kernel module was built

# Hardware Video Acceleraion for Firefox
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
# After this enable the OpenH264 Plugin in Firefox's settings.

# Remove Default Fedora Firefox Start Page
sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js

# Flatpaks
flatpak install -y flathub org.libreoffice.LibreOffice com.github.tchx84.Flatseal io.github.flattool.Warehouse \
	com.github.finefindus.eyedropper com.obsproject.Studio com.obsproject.Studio.Plugin.OBSVkCapture \
	org.freedesktop.Platform.VulkanLayer.OBSVkCapture com.discordapp.Discord org.freedesktop.Platform.ffmpeg-full \ org.localsend.localsend_app org.keepassxc.KeePassXC

# Gaming Flatpaks
flatpak install -y flathub net.davidotek.pupgui2 com.heroicgameslauncher.hgl com.valvesoftware.Steam \
	org.freedesktop.Platform.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.gamescope \
	org.prismlauncher.PrismLauncher net.lutris.Lutris com.usebottles.bottles

# Workstation/Gnome Flatpaks
flatpak install -y flathub io.bassi.Amberol com.mattjakeman.ExtensionManager org.gnome.gitlab.cheywood.Iotas \
	com.transmissionbt.Transmission org.gnome.Builder org.gnome.Calculator org.gnome.Calendar org.gnome.Characters \
	org.gnome.Contacts org.gnome.font-viewer org.gnome.Loupe org.gnome.Papers org.gnome.World.PikaBackup org.gnome.Showtime \
	com.vscodium.codium

# KDE Flatpaks
org.kde.krita

# Additional Packages KDE
sudo dnf install -y ansible git steam steam-devices neovim sqlite3 zsh zsh-autosuggestions zsh-syntax-highlighting \
	setroubleshoot ffmpeg compat-ffmpeg4 ffmpeg-libs libva libva-utils akmod-v4l2loopback yt-dlp @virtualization \
	guestfs-tools distrobox podman kdevelop plasma-nm kontact korganizer gamemode kate vlc vlc-plugin-pipewire --best --allowerasing

# Additional Packages Gnome/Workstation
sudo dnf install -y ansible git steam steam-devices neovim sqlite3 zsh zsh-autosuggestions zsh-syntax-highlighting \
	setroubleshoot ffmpeg compat-ffmpeg4 ffmpeg-libs libva libva-utils akmod-v4l2loopback yt-dlp \
	@virtualization guestfs-tools distrobox podman gamemode --best --allowerasing

# Even more Packages
sudo dnf install -y discord obs-studio obs-studio-plugin-vaapi obs-studio-plugin-vkcapture

# Development Tools
sudo dnf group install -y "C Development Tools and Libraries" "Development Tools"

# Brave Browser
sudo dnf install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y brave-browser

# Mullvad VPN
sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf install mullvad-vpn

# EW
sudo dnf install python3-pyqt6 libsecp256k1 python3-cryptography python3-setuptools python3-pip

# Multi Media
sudo dnf4 group install multimedia
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group install -y sound-and-video # Installs useful Sound and Video complementary packages.

# Set Hostname
sudo hostnamectl set-hostname **new-hostname**

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
