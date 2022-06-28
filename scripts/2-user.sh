#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
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

Installing AUR Softwares
"
source $HOME/SaikouOS/configs/setup.conf

  cd ~
  mkdir "/home/$USERNAME/.cache"
  touch "/home/$USERNAME/.cache/zshhistory"
  git clone "https://github.com/ChrisTitusTech/zsh"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  ln -s "~/zsh/.zshrc" ~/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/SaikouOS/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/SaikouOS/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    cp -r ~/SaikouOS/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/SaikouOS/configs/kde.knsv
    sleep 1
    konsave -a kde
  elif [[ $DESKTOP_ENV == "openbox" ]]; then
    cd ~
    git clone https://github.com/stojshic/dotfiles-openbox
    ./dotfiles-openbox/install-titus.sh
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
