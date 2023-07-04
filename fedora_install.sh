#! /bin/bash

main () {
  echo ' _______         _                      _                        _ _  '
  echo '(_______)       | |                    (_)             _        | | | '
  echo ' _____ _____  __| | ___   ____ _____    _ ____   ___ _| |_ _____| | | '
  echo '|  ___) ___ |/ _  |/ _ \ / ___|____ |  | |  _ \ /___|_   _|____ | | | '
  echo '| |   | ____( (_| | |_| | |   / ___ |  | | | | |___ | | |_/ ___ | | | '
  echo '|_|   |_____)\____|\___/|_|   \_____|  |_|_| |_(___/   \__)_____|\_)_)'
  echo ''
  echo '------------------------------   Setup   ------------------------------'
  echo 'Options:'
  echo ''
  echo ' 69:	Auto-install'                                                     # no need to edit Files themselve + Make Fancy
  echo '  1:	Dark Mode'                                                        #
  echo '  2:	Delete unused Apps'                                               #
  echo '  3:	Set Hostname & Import Files'                                      # choose your own hostname
  echo '  4:	Update, Upgrade, FirmwareUpdate'                                  # check if fwupd already installed
  echo '  5:	Install Nvidia Cuda Drivers + Disable Wayland'                    # AMD?
  echo '  6:	Install Virt, virt-tools'                                         # Nvidia/AMD?
  echo '  7:	Install Apps'                                                     # Option to Check and Uncheck Apps + Flatpak
  echo '  8:	Install Media Codecs'                                             # Check all Media Codecs
  echo '  9:	Install Video Acceleration Tools'                                 # Check all Tools
  echo '  10:   Improve Battery Life'                                             #
  echo '  11:	Install Themes + Icons'                                           #
  echo '  12:	Install Terminal-tools'                                           #
  echo ' *13:	Turn off Windows-shadows'                                         # In work (+ need to see speedup Kernel option)
  echo ' 0:	Reboot'                                                           #
  echo ''
  echo '###################### all * marked are optional ######################'
  echo '-----------------------------------------------------------------------'
  read -p 'Enter a number: ' Input

  case $Input in
    69)
      DarkMode
      DeleteApps
      Hostname-Import
      Update+Upgrade,FirmwareUpdate
      NvidiaGPU
      Virt
      Apps
      MediaCodecs
      VideoAcceleration
      BatteryLife
      Themes-Icons
      Terminal
      Reboot
      ;;
    1)
      DarkMode
      again;;
    2)
      DeleteApps
      again;;
    3)
      Hostname-Import
      again;;
    4)
      Update+Upgrade,FirmwareUpdate
      again;;
    5)
      NvidiaGPU
      again;;
    6)
      Virt
      again;;
    7)
      Apps
      again;;
    8)
      MediaCodecs
      again;;
    9)
      VideoAcceleration
      again;;
    10)
      BatteryLife
      again;;
    11)
      Themes-Icons
      again;;
    12)
      Terminal
      again;;
    0)
      Reboot
      again;;
    *)
      echo 'Wrong input'
      sleep 1
      main;;
  esac

  
}
again () {
  echo 'Done..'
  sleep 2
  main
}

Hostname-Import () {
  # set hostname
  hostnamectl set-hostname your-pc-name
  # manual config setup
  echo 'Please import manually dnf.conf + networkmanager into etc/'
  read
  sudo dnf install gedit gjs -y
}
Update+Upgrade,FirmwareUpdate () {
  # update, upgrade
  sudo dnf update -y && sudo dnf upgrade -y
  # install krenel modules for vmware
  kernel-devel-$(uname -r) kernel-headers
  # firmware update
  sudo dnf install fwupd && sudo systemctl start fwupd && sudo systemctl enable fwupd && sudo fwupdmgr get-devices && sudo fwupdmgr refresh --force && sudo fwupdmgr get-updates && sudo fwupdmgr update
}
NvidiaGPU () {
  # install GPU-Driver (Nvidia)
  sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
  sudo dnf install -y kernel-headers kernel-devel tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms
  sudo dnf module install -y nvidia-driver:latest-dkms
  }
  MediaCodecs () {
  # install Media Codecs
  sudo dnf groupupdate multimedia --setop='install_weak_deps=False' --exclude=PackageKit-gstreamer-plugin 
  sudo dnf groupupdate sound-and-video
  sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg -y
  sudo dnf install -y lame\* --exclude=lame-devel -y -y
  sudo dnf group upgrade --with-optional Multimedia
  sudo dnf install intel-media-driver -y -y
}
Virt () {
  # install and configure virtualisation + virt-manager
  sudo dnf install @virtualization virt-manager -y
  sudo systemctl start libvirtd
  sudo systemctl enable libvirtd
  echo 'Please edit following:'
  echo 'Around Line 85:         unix_sock_group = "libvirt" '
  echo 'Around Line 108:        unix_sock_rw_perms = "0770" '
  sudo gedit /etc/libvirt/libvirtd.conf
  read
  sudo usermod -aG libvirt $USER
  sudo usermod -aG kvm $USER
  echo 'run following: sudo newgrp libvirt'
  read
  sudo systemctl restart libvirtd.service
  modprobe -r kvm_intel
  modprobe kvm_intel nested=1
  echo "options kvm-intel nested=1" | tee /etc/modprobe.d/kvm-intel.conf
}
Apps () {
  # install apps
  sudo dnf install firefox \
  timeshift \
  unzip \
  p7zip \
  p7zip-plugins \
  unrar \
  PackageKit \
  gnome-network-displays -y
  
  # flatpak
  flatpak remote-delete flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo flatpak install flathub com.brave.Browser \
  de.shorsh.discord-screenaudio \
  com.mattjakeman.ExtensionManager \
  com.github.tchx84.Flatseal \
  com.nextcloud.desktopclient.nextcloud \
  flathub org.onlyoffice.desktopeditors \
  flathub com.vixalien.sticky \
  com.github.IsmaelMartinez.teams_for_linux \
  flathub org.telegram.desktop \
  com.transmissionbt.Transmission \
  app.drey.Warp \
  com.github.eneshecan.WhatsAppForLinux \
  com.github.maoschanz.drawing \
  com.obsproject.Studio \
  com.spotify.Client \
  com.jgraph.drawio.desktop -y -y -y -y -y -y -y
  # VS_Code
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  dnf check-update
  sudo dnf install code -y
}
Terminal () {
  # install terminal tools (manual .bashrc import)
  sudo dnf install micro xclip xsel exa bat neofetch htop -y
  cd /home/$USER
  git clone https://github.com/aristocratos/bashtop.git
  cd bashtop
  sudo make install
  sudo dnf copr enable elxreno/preload -y && sudo dnf install preload -y
  cd ..
  if [ which neofetch 2>/dev/null ];then
    sudo dnf install micro xclip xsel exa doas bat neofetch htop -y
  fi
}
VMWare-Workstation () {
  echo 'attention:  you need to login as the user and become the root to install this Software'
  # Links for installing propiratary software
  echo 'VmWare Wokstation       https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html'
}
Themes-Icons () {
  sudo dnf install gnome-tweaks \
  grub-customizer \
  dconf-editor \
  papirus-icon-theme.noarch \
  oxygen-cursor-themes.noarch -y
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' # Papirus Mode
  wget -qO- https://git.io/papirus-folders-install | env PREFIX=$HOME/.local sh
  papirus-folders -C blue --theme Papirus-Dark
}
BatteryLife () {
  sudo dnf install tlp tlp-rdw -y
  systemctl mask power-profiles-deamon
  sudo dnf install powertop -y
}
VideoAcceleration () {
  # ffmpeg ffmpeg-libs intel-media-driver
  sudo dnf install libva libva-utils xorg-x11-drv-intel intel-media-va-driver-non-free libva-drm2 libva-x11-2 -y
  sudo dnf config-manager --set-enabled fedora-cisco-openh264 -y
  sudo dnf install gstreamer1-plugin-openh264 mozilla-openh264 -y -y -y
  echo 'please enable the OpenH264 in Firefox settings'
  read
}
DarkMode ()  {
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' # Legacy apps
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' # new apps
}
DeleteApps ()  {
  sudo dnf rm libreoffice* \
  gnome-text-editor \
  gnome-boxes -y
}
Reboot ()  {
  sudo reboot
}
main



## awk
## cp
## cat
