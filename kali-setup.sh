cat > $PREFIX/bin/kali-setup << 'EOF'
#!/bin/bash
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
C='\033[0;36m'
W='\033[1;37m'
N='\033[0m'

show_banner() {
clear
echo -e "${G}"
echo "⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀"
echo -e "${N}"
echo -e "${R}╔══════════════════════════════════════════╗"
echo -e "║           KALI LINUX - TERMUX            ║"
echo -e "║         Creator: KYAEV                   ║"
echo -e "╚══════════════════════════════════════════╝${N}"
echo ""
}

progress_bar() {
    local duration=$1 width=38
    echo -ne "${Y}  ["
    for ((i=0;i<=width;i++)); do
        sleep $(echo "scale=3; $duration/$width" | bc)
        echo -ne "█"
    done
    echo -e "]${N}"
}

check_internet() {
    echo -ne "${Y}[→] Connexion internet...${N}"
    ping -c 1 8.8.8.8 &>/dev/null && echo -e "${G} OK${N}" || { echo -e "${R} OFFLINE${N}"; exit 1; }
}

check_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        aarch64) KARCH="arm64" ;;
        armv7l)  KARCH="armhf" ;;
        x86_64)  KARCH="amd64" ;;
        *) echo -e "${R}[-] Architecture non supportée${N}"; exit 1 ;;
    esac
    echo -e "${G}[✓] Architecture: $ARCH${N}"
}

check_space() {
    FREE=$(df /data | awk 'NR==2{print $4}')
    [ "$FREE" -lt 4000000 ] && { echo -e "${R}[-] Espace insuffisant (4GB requis)${N}"; exit 1; }
    echo -e "${G}[✓] Espace OK: $(df -h /data | awk 'NR==2{print $4}')${N}"
}

update_kali() {
    show_banner
    echo -e "${Y}[→] Mise à jour Kali...${N}"
    proot-distro login kali -- bash -c "apt update -y && apt upgrade -y && apt autoremove -y"
    echo -e "${G}[✓] Kali à jour${N}"
    sleep 2
    menu_post
}

backup_kali() {
    show_banner
    BACKUP="$HOME/kali-backup-$(date +%Y%m%d).tar.gz"
    echo -e "${Y}[→] Backup vers $BACKUP...${N}"
    progress_bar 4
    proot-distro backup kali --output "$BACKUP" 2>/dev/null
    echo -e "${G}[✓] Backup OK${N}"
    sleep 2
    menu_post
}

restore_kali() {
    show_banner
    echo -ne "${C}[?] Chemin du backup: ${N}"
    read BACKUP_FILE
    if [ -f "$BACKUP_FILE" ]; then
        progress_bar 4
        proot-distro restore "$BACKUP_FILE"
        echo -e "${G}[✓] Restauration OK${N}"
    else
        echo -e "${R}[-] Fichier introuvable${N}"
    fi
    sleep 2
    menu_post
}

uninstall_kali() {
    show_banner
    echo -ne "${R}[!] Confirmer désinstallation ? (o/n): ${N}"
    read CONF
    if [ "$CONF" = "o" ]; then
        proot-distro remove kali
        rm -f $PREFIX/bin/kali
        echo -e "${G}[✓] Désinstallé${N}"
    fi
    sleep 2
    menu_post
}

menu_post() {
    show_banner
    echo -e "${R}╔══════════════════════════════════════════╗"
    echo -e "║            MENU PRINCIPAL                ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo -e "${C}[1]${W} Lancer Kali Linux"
    echo -e "${C}[2]${W} Mettre à jour Kali"
    echo -e "${C}[3]${W} Installer outils supplémentaires"
    echo -e "${C}[4]${W} Lancer VNC"
    echo -e "${C}[5]${W} Backup Kali"
    echo -e "${C}[6]${W} Restaurer Kali"
    echo -e "${C}[7]${W} Désinstaller Kali"
    echo -e "${C}[8]${W} Quitter"
    echo ""
    echo -ne "${C}[?] Choix: ${N}"
    read CHOIX
    case "$CHOIX" in
        1) proot-distro login kali ;;
        2) update_kali ;;
        3) show_banner
           echo -e "${Y}[→] Installation outils...${N}"
           proot-distro login kali -- bash -c "apt install -y nmap metasploit-framework hydra sqlmap aircrack-ng"
           sleep 2; menu_post ;;
        4) proot-distro login kali -- bash -c "start-vnc" ;;
        5) backup_kali ;;
        6) restore_kali ;;
        7) uninstall_kali ;;
        8) echo -e "${R}[!] Bye!${N}"; exit 0 ;;
        *) echo -e "${R}[-] Invalide${N}"; sleep 1; menu_post ;;
    esac
}

auto_install() {
    show_banner
    echo -e "${G}[✓] Installation automatique...${N}\n"
    check_internet
    check_arch
    check_space

    echo -e "${Y}[→] Mise à jour Termux...${N}"
    pkg update -y &>/dev/null && pkg upgrade -y &>/dev/null
    echo -e "${G}[✓] Termux à jour${N}"

    echo -e "${Y}[→] Installation dépendances...${N}"
    pkg install proot-distro wget curl tar bc -y &>/dev/null
    echo -e "${G}[✓] Dépendances OK${N}"

    echo -e "${Y}[→] Téléchargement Kali Linux...${N}"
    progress_bar 5
    proot-distro install kali --override-distro kali

    if ! proot-distro list | grep -q kali; then
        echo -e "${R}[-] Échec proot-distro, tentative manuelle...${N}"
        pkg install proot tar wget -y &>/dev/null
        wget -q --show-progress "https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz" -O kali.tar.xz
        mkdir -p $HOME/kali-fs
        proot --link2symlink tar -xJf kali.tar.xz -C $HOME/kali-fs
        rm kali.tar.xz
        echo 'proot --link2symlink -0 -r $HOME/kali-fs -b /dev -b /proc -b /sys -b $HOME /usr/bin/env -i HOME=/root TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login' > $PREFIX/bin/kali
        chmod +x $PREFIX/bin/kali
        echo -e "${G}[✓] Kali installé manuellement${N}"
    else
        echo 'proot-distro login kali' > $PREFIX/bin/kali
        chmod +x $PREFIX/bin/kali
        echo -e "${G}[✓] Raccourci créé${N}"

        echo -e "${Y}[→] Outils de base...${N}"
        progress_bar 3
        proot-distro login kali -- bash -c "apt update -y &>/dev/null && apt install -y nmap netcat-openbsd curl wget git python3 python3-pip hydra sqlmap &>/dev/null"
        echo -e "${G}[✓] Outils OK${N}"

        echo -e "${Y}[→] Configuration VNC...${N}"
        pkg install tigervnc -y &>/dev/null
        proot-distro login kali -- bash -c "apt install -y xfce4 xfce4-goodies dbus-x11 &>/dev/null
echo '#!/bin/bash
Xvnc :1 -geometry 1280x720 -depth 24 &
sleep 1
startxfce4 &' > /usr/local/bin/start-vnc
chmod +x /usr/local/bin/start-vnc"
        echo -e "${G}[✓] VNC OK${N}"
    fi

    show_banner
    echo -e "${G}╔══════════════════════════════════════════╗"
    echo -e "║       INSTALLATION TERMINÉE !            ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo -e "${W}  Lance Kali:          ${G}kali${N}"
    echo -e "${W}  Ce menu:             ${G}kali-setup${N}"
    echo -e "${W}  VNC dans Kali:       ${G}start-vnc${N}"
    sleep 3
    menu_post
}

show_banner
if proot-distro list 2>/dev/null | grep -q kali || [ -f "$HOME/kali-fs/bin/bash" ]; then
    echo -e "${G}[✓] Kali Linux détecté${N}"
    sleep 1
    menu_post
else
    echo -e "${R}╔══════════════════════════════════════════╗"
    echo -e "║          MENU INSTALLATION               ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo -e "${C}[1]${W} Installation automatique complète"
    echo -e "${C}[2]${W} Quitter"
    echo ""
    echo -ne "${C}[?] Choix: ${N}"
    read CHOIX
    case "$CHOIX" in
        1) auto_install ;;
        2) echo -e "${R}[!] Bye!${N}"; exit 0 ;;
        *) echo -e "${R}[-] Invalide${N}" ;;
    esac
fi
EOF
chmod +x $PREFIX/bin/kali-setup && kali-setup
