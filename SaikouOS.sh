#!/bin/bash
#github-action genshdoc
#
# @file SaikouOS
# @brief Entrance script that launches children scripts for each phase of installation.

# Find the name of the folder the scripts are in
set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
set +a
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
-------------------------------------------------------------------------
                Scripts are in directory named SaikouOS
"
    ( bash $SCRIPT_DIR/scripts/startup.sh )|& tee startup.log
      source $CONFIGS_DIR/setup.conf
    ( bash $SCRIPT_DIR/scripts/0-preinstall.sh )|& tee 0-preinstall.log
    ( arch-chroot /mnt $HOME/SaikouOS/scripts/1-setup.sh )|& tee 1-setup.log
    if [[ ! $DESKTOP_ENV == server ]]; then
      ( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/SaikouOS/scripts/2-user.sh )|& tee 2-user.log
    fi
    ( arch-chroot /mnt $HOME/SaikouOS/scripts/3-post-setup.sh )|& tee 3-post-setup.log
    cp -v *.log /mnt/home/$USERNAME

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
-------------------------------------------------------------------------
                Done - Please Eject Install Media and Reboot
"
