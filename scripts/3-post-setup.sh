#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
echo -ne "
-------------------------------------------------------------------------
   SSSSSSSSSSSSSSS                     iiii  kkkkkkkk                                                 OOOOOOOOO        SSSSSSSSSSSSSSS 
 SS:::::::::::::::S                   i::::i k::::::k                                               OO:::::::::OO    SS:::::::::::::::S
S:::::SSSSSS::::::S                    iiii  k::::::k                                             OO:::::::::::::OO S:::::SSSSSS::::::S
S:::::S     SSSSSSS                          k::::::k                                            O:::::::OOO:::::::OS:::::S     SSSSSSS
S:::::S              aaaaaaaaaaaaa   iiiiiii  k:::::k    kkkkkkk ooooooooooo   uuuuuu    uuuuuu  O::::::O   O::::::OS:::::S            
S:::::S              a::::::::::::a  i:::::i  k:::::k   k:::::koo:::::::::::oo u::::u    u::::u  O:::::O     O:::::OS:::::S            
 S::::SSSS           aaaaaaaaa:::::a  i::::i  k:::::k  k:::::ko:::::::::::::::ou::::u    u::::u  O:::::O     O:::::O S::::SSSS         
  SS::::::SSSSS               a::::a  i::::i  k:::::k k:::::k o:::::ooooo:::::ou::::u    u::::u  O:::::O     O:::::O  SS::::::SSSSS    
    SSS::::::::SS      aaaaaaa:::::a  i::::i  k::::::k:::::k  o::::o     o::::ou::::u    u::::u  O:::::O     O:::::O    SSS::::::::SS  
       SSSSSS::::S   aa::::::::::::a  i::::i  k:::::::::::k   o::::o     o::::ou::::u    u::::u  O:::::O     O:::::O       SSSSSS::::S 
            S:::::S a::::aaaa::::::a  i::::i  k:::::::::::k   o::::o     o::::ou::::u    u::::u  O:::::O     O:::::O            S:::::S
            S:::::Sa::::a    a:::::a  i::::i  k::::::k:::::k  o::::o     o::::ou:::::uuuu:::::u  O::::::O   O::::::O            S:::::S
SSSSSSS     S:::::Sa::::a    a:::::a i::::::ik::::::k k:::::k o:::::ooooo:::::ou:::::::::::::::uuO:::::::OOO:::::::OSSSSSSS     S:::::S
S::::::SSSSSS:::::Sa:::::aaaa::::::a i::::::ik::::::k  k:::::ko:::::::::::::::o u:::::::::::::::u OO:::::::::::::OO S::::::SSSSSS:::::S
S:::::::::::::::SS  a::::::::::aa:::ai::::::ik::::::k   k:::::koo:::::::::::oo   uu::::::::uu:::u   OO:::::::::OO   S:::::::::::::::SS 
 SSSSSSSSSSSSSSS     aaaaaaaaaa  aaaaiiiiiiiikkkkkkkk    kkkkkkk ooooooooooo       uuuuuuuu  uuuu     OOOOOOOOO      SSSSSSSSSSSSSSS
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: SaikouOS
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/SaikouOS/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
               Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing CyberRe Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME=CyberRe
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/SaikouOS
cp -a configs${THEME_DIR}/${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    echo [Theme] >>  /etc/sddm.conf
    echo Current=Nordic >> /etc/sddm.conf
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

elif [[ "${DESKTOP_ENV}" == "lxde" ]]; then
  systemctl enable lxdm.service

elif [[ "${DESKTOP_ENV}" == "openbox" ]]; then
  systemctl enable lightdm.service
  if [[ "${INSTALL_TYPE}" == "FULL" ]]; then
    # Set default lightdm-webkit2-greeter theme to Litarvan
    sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = litarvan #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
    # Set default lightdm greeter to lightdm-webkit2-greeter
    sed -i 's/#greeter-session=example.*/greeter-session=lightdm-webkit2-greeter/g' /etc/lightdm/lightdm.conf
  fi

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

if [[ "${FS}" == "luks" || "${FS}" == "btrfs" ]]; then
echo -ne "
-------------------------------------------------------------------------
                    Creating Snapper Config
-------------------------------------------------------------------------
"

SNAPPER_CONF="$HOME/SaikouOS/configs/etc/snapper/configs/root"
mkdir -p /etc/snapper/configs/
cp -rfv ${SNAPPER_CONF} /etc/snapper/configs/

SNAPPER_CONF_D="$HOME/SaikouOS/configs/etc/conf.d/snapper"
mkdir -p /etc/conf.d/
cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/

fi

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Plymouth Boot Splash
-------------------------------------------------------------------------
"
PLYMOUTH_THEMES_DIR="$HOME/SaikouOS/configs/usr/share/plymouth/themes"
PLYMOUTH_THEME="arch-glow" # can grab from config later if we allow selection
mkdir -p /usr/share/plymouth/themes
echo 'Installing Plymouth theme...'
cp -rf ${PLYMOUTH_THEMES_DIR}/${PLYMOUTH_THEME} /usr/share/plymouth/themes
if  [[ $FS == "luks"]]; then
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
  sed -i 's/HOOKS=(base udev \(.*block\) /&plymouth-/' /etc/mkinitcpio.conf # create plymouth-encrypt after block hook
else
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
fi
plymouth-set-default-theme -R arch-glow # sets the theme and runs mkinitcpio
echo 'Plymouth theme installed'

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/SaikouOS
rm -r /home/$USERNAME/SaikouOS

# Replace in the same state
cd $pwd
