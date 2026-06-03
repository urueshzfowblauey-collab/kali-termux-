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
echo -e "║           Creator: KYAEV                 ║"
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
    echo -e "${G}[✓] Architecture: $ARCH ($KARCH)${N}"
}

check_space() {
    FREE=$(df /data | awk 'NR==2{print $4}')
    [ "$FREE" -lt 4000000 ] && { echo -e "${R}[-] Espace insuffisant (4GB requis)${N}"; exit 1; }
    echo -e "${G}[✓] Espace OK: $(df -h /data | awk 'NR==2{print $4}')${N}"
}

is_installed() {
    [ -f "$HOME/kali-fs/bin/bash" ] && return 0
    return 1
}

update_kali() {
    show_banner
    echo -e "${Y}[→] Mise à jour Kali...${N}"
    proot --link2symlink -0 -r $HOME/kali-fs \
        -b /dev -b /proc -b /sys -b $HOME \
        /usr/bin/env -i HOME=/root TERM=xterm-256color \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/bash -c "apt update -y && apt upgrade -y && apt autoremove -y"
    echo -e "${G}[✓] Kali à jour${N}"
    sleep 2; menu_post
}

backup_kali() {
    show_banner
    BACKUP="$HOME/kali-backup-$(date +%Y%m%d).tar.gz"
    echo -e "${Y}[→] Backup vers $BACKUP...${N}"
    progress_bar 4
    tar -czf "$BACKUP" -C $HOME kali-fs
    echo -e "${G}[✓] Backup OK: $BACKUP${N}"
    sleep 2; menu_post
}

restore_kali() {
    show_banner
    echo -ne "${C}[?] Chemin du backup: ${N}"
    read BACKUP_FILE
    if [ -f "$BACKUP_FILE" ]; then
        progress_bar 4
        tar -xzf "$BACKUP_FILE" -C $HOME
        echo -e "${G}[✓] Restauration OK${N}"
    else
        echo -e "${R}[-] Fichier introuvable${N}"
    fi
    sleep 2; menu_post
}

uninstall_kali() {
    show_banner
    echo -ne "${R}[!] Confirmer désinstallation ? (o/n): ${N}"
    read CONF
    if [ "$CONF" = "o" ]; then
        rm -rf $HOME/kali-fs
        rm -f $PREFIX/bin/kali
        echo -e "${G}[✓] Kali désinstallé${N}"
        sleep 2
        show_banner
        menu_install
    fi
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
    echo -e "${C}[4]${W} Backup Kali"
    echo -e "${C}[5]${W} Restaurer Kali"
    echo -e "${C}[6]${W} Désinstaller Kali"
    echo -e "${C}[7]${W} Quitter"
    echo ""
    echo -ne "${C}[?] Choix: ${N}"
    read CHOIX
    case "$CHOIX" in
        1) proot --link2symlink -0 -r $HOME/kali-fs \
               -b /dev -b /proc -b /sys -b $HOME \
               /usr/bin/env -i HOME=/root TERM=xterm-256color \
               PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
               /bin/bash --login ;;
        2) update_kali ;;
        3) show_banner
           echo -e "${Y}[→] Installation outils...${N}"
           proot --link2symlink -0 -r $HOME/kali-fs \
               -b /dev -b /proc -b /sys -b $HOME \
               /usr/bin/env -i HOME=/root TERM=xterm-256color \
               PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
               /bin/bash -c "apt install -y nmap metasploit-framework hydra sqlmap aircrack-ng"
           sleep 2; menu_post ;;
        4) backup_kali ;;
        5) restore_kali ;;
        6) uninstall_kali ;;
        7) echo -e "${R}[!] Bye!${N}"; exit 0 ;;
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
    pkg install proot wget curl tar bc -y &>/dev/null
    echo -e "${G}[✓] Dépendances OK${N}"

    echo -e "${Y}[→] Téléchargement Kali Linux ($KARCH)...${N}"
    progress_bar 5
    wget -q --show-progress \
        "https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-${KARCH}.tar.xz" \
        -O $HOME/kali.tar.xz

    echo -e "${Y}[→] Extraction...${N}"
    mkdir -p $HOME/kali-fs
    progress_bar 4
    proot --link2symlink tar -xJf $HOME/kali.tar.xz -C $HOME/kali-fs
    rm -f $HOME/kali.tar.xz
    echo -e "${G}[✓] Kali extrait${N}"

    echo -e "${Y}[→] Création raccourci kali...${N}"
    cat > $PREFIX/bin/kali << 'KALI'
#!/bin/bash
proot --link2symlink -0 -r $HOME/kali-fs \
    -b /dev -b /proc -b /sys -b $HOME \
    /usr/bin/env -i HOME=/root TERM=xterm-256color \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash --login
KALI
    chmod +x $PREFIX/bin/kali
    echo -e "${G}[✓] Raccourci créé${N}"

    echo -e "${Y}[→] Configuration Kali...${N}"
    progress_bar 3
    proot --link2symlink -0 -r $HOME/kali-fs \
        -b /dev -b /proc -b /sys -b $HOME \
        /usr/bin/env -i HOME=/root TERM=xterm-256color \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/bash -c "apt update -y &>/dev/null && apt install -y nmap curl wget git python3 python3-pip &>/dev/null"
    echo -e "${G}[✓] Configuration OK${N}"

    show_banner
    echo -e "${G}╔══════════════════════════════════════════╗"
    echo -e "║       INSTALLATION TERMINÉE !            ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo -e "${W}  Lance Kali:     ${G}kali${N}"
    echo -e "${W}  Ce menu:        ${G}kali-setup${N}"
    sleep 3
    menu_post
}

menu_install() {
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
        *) echo -e "${R}[-] Invalide${N}"; menu_install ;;
    esac
}

show_banner
if is_installed; then
    echo -e "${G}[✓] Kali Linux détecté${N}"
    sleep 1
    menu_post
else
    menu_install
fi
