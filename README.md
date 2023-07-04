# fedora-38-install
# Installation
After creating the USB stick, you should follow the following steps:

Disable Secure Boot and enable virtualization in the BIOS (if not already enabled).
Boot from the USB stick with the live ISO.
Select the system language, keyboard layout, and time zone.
When selecting the storage on which the system should be installed, choose the hard drive and check the option below:

![Pasted image 20230628094356](https://github.com/shm0rt/fedora-38-install/assets/126892002/dee10fb9-03ca-414f-a30b-ed4947bf93c3)

After following these steps, you will be redirected to the next page. Here, you can choose whether you want to encrypt the hard drive and which file system you want to use. Since I want to use [*Timeshift*](https://github.com/linuxmint/timeshift), I recommend using the btrfs file system as it provides faster restoration.

> Note:
> If you want to encrypt the drive, please consider the following:
> - The keyboard layout will remain as American during password entry.
> - You will need to enter the password every time you start the system.

![Pasted image 20230628100419](https://github.com/shm0rt/fedora-38-install/assets/126892002/ab56518f-92b4-4116-b682-1301b5a1f3d1)

Click on the highlighted text as shown in the image to perform automatic partitioning. In order for Timeshift to read the file system correctly, two folders should be renamed:

Rename the root folder to @
Rename the home folder to @home
To rename the folder, follow these steps:

1. Click on the respective folder.
2. Enter the correct name in the bottom right corner.
3. Click on the "Apply Settings" button.

After you have completed everything, it should look similar to this:
![Screenshot from 2023-06-28 10-51-59](https://github.com/shm0rt/fedora-38-install/assets/126892002/f3339497-db48-4d90-ba04-989c29e30b0e)

---
# After the Installation
## Dark Mode
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'        # Legacy apps
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'      # new apps
```

---
## Renaming Device Name
Replace <device-name> with the new name of your device. For example:
```bash
hostnamectl set-hostname <device-name>
```

---

## Configuring dnf
To speed up the system, edit the dnf.conf file. The following changes have been made:
- Faster installation (_fastest_mirror_, _max_parallel_downloads_)
- Always Yes (_defaultyes_)

The _defaultyes_ option allows you to confirm input with Yes by pressing the ENTER key. For example, instead of typing ```sudo apt-get update -y```, you can simply enter ```sudo apt-get update``` and confirm it by pressing the ENTER key.

Ändern Sie den File wie folgend:
- Öffnen Sie den Terminal und geben Sie dies hinein: `sudo nano /etc/dnf/dnf.conf` 
- Kopieren Sie den Text und ersetzen Sie ihn durch den folgenden Text:
To make the changes, follow these steps:

Open the terminal and enter the command: `sudo nano /etc/dnf/dnf.conf`
Copy the text below and replace the existing text in the file:

```bash
[main] 
gpgcheck=1 
installonly_limit=3 
clean_requirements_on_remove=True 
best=False 
skip_if_unavailable=True 
fastestmirror=1 
max_parallel_downloads=10 
deltarpm=true
defaultyes=True
```

After replacing the text, save the file by pressing `Ctrl + X`, then `Y` to confirm, and Enter to exit the nano editor.

> Note:
> The `fastestmirror=1` plugin can sometimes be counterproductive. Use it at your own discretion. If you encounter slow download speeds, set it to fastestmirror=0. Many users have reported better download speeds when the plugin is enabled. Therefore, it is enabled by default.

---
## Nvidia Drivers
By installing the Nvidia drivers, you gain access to:

Graphics acceleration
CUDA support
Multi-monitor support
You can choose from the following driver options:

Nouveau (Open-Source)
Cuda (proprietary)
RPM Fusion (proprietary)

The difference between the mentioned driver options lies in their source, licensing, and included features. Nouveau is an open-source driver developed by the Linux community and provides basic graphics card support. The CUDA driver is a proprietary driver by Nvidia specifically designed for CUDA computations, leveraging the parallel computing power of Nvidia GPUs. RPM Fusion offers proprietary Nvidia drivers as part of its software repository for RPM-based Linux distributions, providing users access to the latest driver versions.

### Cuda
Add the repository:
```bash
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
```

Install the dependencies:
```bash
sudo dnf install -y kernel-headers kernel-devel tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms
```

Install the drivers:
```bash
sudo dnf module install -y nvidia-driver:latest-dkms
```

### RPM Fusion

RPM Fusion provides access to non-free software packages that are not available in the official Fedora repositories due to legal or licensing reasons. This includes proprietary drivers, multimedia playback codecs, certain applications, and extensions. To install and enable RPM Fusion, follow these steps:

```bash
# Install RPM Fusion for Fedora 38
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-37.noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-37.noarch.rpm

# Enable the RPM Fusion repositories
sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-nonfree
```
---
## Appstream Metadaten
[AppStream](https://www.freedesktop.org/wiki/Distributions/AppStream/) verwendet ein XML-basiertes Datenformat, um Metadaten für Anwendungen zu definieren. Diese Metadaten umfassen Informationen wie Anwendungsnamen, Beschreibungen, Kategorien, Lizenzen, Entwicklerdetails, Abhängigkeiten, unterstützte Sprachen und mehr. Die Metadaten dienen dazu, Benutzern umfassende Informationen über verfügbare Anwendungen bereitzustellen.

Um den App-Stream-Metadaten auf den neuesten Stand zu bringen, geben Sie folgendes in den Terminal ein:
```bash
sudo dnf groupupdate core
```
 
---
## Update 
Um dein System zu _aktualisieren_:
- ```sudo dnf update -y```

Um dein System zu _upgraden_:
- ```sudo dnf upgrade -y```

Um Änderungen anzuwenden, neue Module zu laden und alte Module zu entladen:
- ```sudo reboot```

**_Oneliner:_**
```bash
sudo dnf update -y && sudo dnf upgrade -y && sudo reboot
```

---
## Firmware ([fwupd](https://wiki.archlinux.org/title/Fwupd))

Wenn Ihr System Firmware-Update durch lvfs unterstützt, updaten Sie ihr Gerät mithilfe wie folgt:
- Den Firmware-Update Dienst herunterladen:
```sudo dnf install fwupd```

- Den fwupd.service starten und beim Start ausführen:
```sudo systemctl start fwupd```
```sudo systemctl enable fwupd```

- Um alle Geräte anzuzeigen, die von fwupd erkennt worden sind:
```sudo fwupdmgr get-devices```

- Um die neusten Metadaten herunterzuladen:
```sudo fwupdmgr refresh --force```

- Zur Auflistung der verfügbaren Updates für alle Geräte auf dem System:
```sudo fwupdmgr get-updates```

- Um alle Updates zu installieren:
```sudo fwupdmgr update```

**_Oneliner:_**
```bash
sudo dnf install fwupd && sudo systemctl start fwupd && sudo systemctl enable fwupd && sudo fwupdmgr get-devices && sudo fwupdmgr refresh --force && sudo fwupdmgr get-updates && sudo fwupdmgr update
```

---

## Media Codecs
Installieren Sie folgende Module um korrekte Multimedia Playback zu erhalten:
```bash
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
sudo dnf groupupdate multimedia sound-and-video
# Nur für Chrome-Benutzer
# sudo dnf swap chromium chromium-freeworld --allowerasing
sudo dnf install ffmpeg-libs
```

### Weitere Verbesserungs-Möglichkeiten
- [Video I/O hardware acceleration, Video Decoding with VA-API ](https://github.com/opencv/opencv/wiki/Video-IO-hardware-acceleration)
- [OpenH264 für Firefox](https://docs.fedoraproject.org/de/quick-docs/openh264/)
---

## Update Flatpak
Fedora 38 kommt mit Flatpak schon vorinstalliert, aber nicht aktiviert. Fügen Sie folgende Befehle aus, um flathub repo zu aktivieren und flatpak auf den neusten Stand bringen:
```bash
flatpak remote-delete flathub
flatpak remote-delete fedora
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update
```
---

## Tools
- Für komprimierte Files (7z, rar):
```sudo dnf install -y unzip p7zip p7zip-plugins unrar```
- Für GNOME:
```sudo dnf install -y gnome-tweaks gnome-network-displays```
- Für Fedora:
 ```sudo dnf install -y packageKit timeshift grub-customizer dconf-editor```
 - Von Flatpak:
 ```sudo flatpak install -y com.mattjakeman.ExtensionManager com.github.tchx84.Flatseal```
---

## Thema [Optional]
### Icons und Zeiger
- [Oxygen-Cursors](https://github.com/wo2ni/Oxygen-Cursors)
- [Papirus Icon Theme]](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)

### Thema in Flatpaks nutzen
* `sudo flatpak override --filesystem=$HOME/.themes`
* `sudo flatpak override --env=GTK_THEME=my-theme` 

---

## Weitere:
- [Install-Script](/fedora_install.sh)




