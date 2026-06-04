#!/bin/bash
set -euo pipefail

KALI_FS="${HOME}/kali-fs"
LOG_FILE="${HOME}/kali-setup.log"
LOCK_FILE="${HOME}/.kali-setup.lock"
CONFIG_FILE="${HOME}/.kali-setup.conf"
ROOTFS_URL_BASE="https://kali.download/nethunter-images/current/rootfs"
ROOTFS_URL_FALLBACK="https://old.kali.org/nethunter-images/kali-2024.2/rootfs"
SCRIPT_URL="https://raw.githubusercontent.com/urueshzfowblauey-collab/kali-termux-/main/kali-setup.sh"

THEME="red"
LANG_CODE="fr"
KALI_PASSWORD_HASH=""
KALI_PASSWORD_SALT=""

apply_theme() {
    case "${THEME}" in
        red)
            R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
            C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;31m'
            ;;
        blue)
            R='\033[0;34m'; G='\033[0;36m'; Y='\033[0;33m'
            C='\033[0;34m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;34m'
            ;;
        green)
            R='\033[0;32m'; G='\033[0;32m'; Y='\033[0;33m'
            C='\033[0;32m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;32m'
            ;;
        purple)
            R='\033[0;35m'; G='\033[0;35m'; Y='\033[0;33m'
            C='\033[0;35m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;35m'
            ;;
        *)
            R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
            C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;31m'
            ;;
    esac
}

load_config() {
    if [ -f "${CONFIG_FILE}" ]; then
        local line key value
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue
            if [[ "$line" =~ ^([A-Z_]+)=\"([^\"]*)\"$ ]]; then
                key="${BASH_REMATCH[1]}"
                value="${BASH_REMATCH[2]}"
                case "$key" in
                    THEME)               THEME="$value" ;;
                    LANG_CODE)           LANG_CODE="$value" ;;
                    KALI_PASSWORD_HASH)  KALI_PASSWORD_HASH="$value" ;;
                    KALI_PASSWORD_SALT)  KALI_PASSWORD_SALT="$value" ;;
                esac
            fi
        done < "${CONFIG_FILE}"
    fi
    apply_theme
}

save_config() {
    cat > "${CONFIG_FILE}" << EOF
THEME="${THEME}"
LANG_CODE="${LANG_CODE}"
KALI_PASSWORD_HASH="${KALI_PASSWORD_HASH}"
KALI_PASSWORD_SALT="${KALI_PASSWORD_SALT}"
EOF
    chmod 600 "${CONFIG_FILE}"
}

t() {
    local key="$1"
    if [ "${LANG_CODE}" = "en" ]; then
        case "$key" in
            menu_main)    echo "MAIN MENU" ;;
            menu_install) echo "INSTALLATION MENU" ;;
            menu_settings)echo "SETTINGS" ;;
            launch)       echo "Launch Kali Linux" ;;
            update_kali)  echo "Update Kali" ;;
            tools)        echo "Install additional tools" ;;
            backup)       echo "Backup" ;;
            restore_bk)   echo "Restore backup" ;;
            snapshot)     echo "Snapshot" ;;
            restore_sn)   echo "Restore snapshot" ;;
            uninstall)    echo "Uninstall Kali" ;;
            settings)     echo "Settings" ;;
            stats)        echo "System statistics" ;;
            clean)        echo "Clean apt cache" ;;
            self_update)  echo "Update this script" ;;
            quit)         echo "Quit" ;;
            auto_install) echo "Full automatic installation" ;;
            theme)        echo "Change theme" ;;
            lang)         echo "Change language" ;;
            passwd)       echo "Change password" ;;
            back)         echo "Back" ;;
        esac
    else
        case "$key" in
            menu_main)    echo "MENU PRINCIPAL" ;;
            menu_install) echo "MENU INSTALLATION" ;;
            menu_settings)echo "PARAMETRES" ;;
            launch)       echo "Lancer Kali Linux" ;;
            update_kali)  echo "Mettre a jour Kali" ;;
            tools)        echo "Installer outils supplementaires" ;;
            backup)       echo "Backup" ;;
            restore_bk)   echo "Restaurer backup" ;;
            snapshot)     echo "Snapshot" ;;
            restore_sn)   echo "Restaurer snapshot" ;;
            uninstall)    echo "Desinstaller Kali" ;;
            settings)     echo "Parametres" ;;
            stats)        echo "Statistiques systeme" ;;
            clean)        echo "Nettoyer le cache apt" ;;
            self_update)  echo "Mettre a jour ce script" ;;
            quit)         echo "Quitter" ;;
            auto_install) echo "Installation automatique complete" ;;
            theme)        echo "Changer le theme" ;;
            lang)         echo "Changer la langue" ;;
            passwd)       echo "Changer le mot de passe" ;;
            back)         echo "Retour" ;;
        esac
    fi
}

exec 3</dev/tty

acquire_lock() {
    if ! command -v flock > /dev/null 2>&1; then
        if [ -f "${LOCK_FILE}" ]; then
            local pid
            pid="$(cat "${LOCK_FILE}" 2>/dev/null || echo "")"
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                die "Une instance est deja en cours (PID $pid)"
            fi
        fi
        echo $$ > "${LOCK_FILE}"
        return 0
    fi
    exec 9>"${LOCK_FILE}"
    if ! flock -n 9; then
        die "Une instance est deja en cours"
    fi
    echo $$ >&9
}

trap 'handle_exit $?' EXIT
trap 'echo -e "\n${R}[!] Interruption${N}"; exit 130' INT TERM

handle_exit() {
    local code=$1
    rm -f "${LOCK_FILE}" 2>/dev/null || true
    if [ "$code" -ne 0 ] && [ "$code" -ne 130 ]; then
        echo -e "${R}[!] Erreur (code $code) — voir ${LOG_FILE}${N}"
    fi
}

log() { echo "[$(date '+%H:%M:%S')] $*" >> "${LOG_FILE}"; }

die() { echo -e "${R}[-] $*${N}" | tee -a "${LOG_FILE}"; exit 1; }

need_cmd() {
    for cmd in "$@"; do
        command -v "$cmd" > /dev/null 2>&1 || die "Commande manquante: $cmd — pkg install $cmd"
    done
}

need_cmd_hash() {
    if command -v sha256sum > /dev/null 2>&1; then
        echo "sha256sum"
    elif command -v shasum > /dev/null 2>&1; then
        echo "shasum -a 256"
    else
        die "sha256sum ou shasum introuvable — pkg install coreutils"
    fi
}

do_sha256() {
    local file="$1"
    local cmd
    cmd="$(need_cmd_hash)"
    $cmd "$file" | awk '{print $1}'
}

gen_salt() {
    if command -v openssl > /dev/null 2>&1; then
        openssl rand -hex 16
    else
        head -c 32 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n' | head -c 32
    fi
}

hash_password() {
    local password="$1"
    local salt="$2"
    local cmd
    cmd="$(need_cmd_hash)"
    printf '%s%s' "$salt" "$password" | $cmd | awk '{print $1}'
}

check_password() {
    if [ -z "${KALI_PASSWORD_HASH}" ]; then return 0; fi
    local attempts=0
    while [ "$attempts" -lt 3 ]; do
        read -r -s -p "$(echo -e "${C}[?] Mot de passe: ${N}")" input <&3
        echo ""
        local input_hash
        input_hash="$(hash_password "$input" "$KALI_PASSWORD_SALT")"
        if [ "$input_hash" = "$KALI_PASSWORD_HASH" ]; then
            return 0
        fi
        attempts=$((attempts + 1))
        echo -e "${R}[-] Mot de passe incorrect ($attempts/3)${N}"
    done
    die "Trop de tentatives"
}

set_password() {
    read -r -s -p "$(echo -e "${C}[?] Nouveau mot de passe (vide = desactiver): ${N}")" pw1 <&3
    echo ""
    if [ -z "$pw1" ]; then
        KALI_PASSWORD_HASH=""
        KALI_PASSWORD_SALT=""
        save_config
        echo -e "${G}[✓] Mot de passe desactive${N}"
        log "Mot de passe desactive"
        sleep 1; return
    fi
    read -r -s -p "$(echo -e "${C}[?] Confirmer le mot de passe: ${N}")" pw2 <&3
    echo ""
    if [ "$pw1" != "$pw2" ]; then
        echo -e "${R}[-] Les mots de passe ne correspondent pas${N}"
        sleep 1; return
    fi
    local salt
    salt="$(gen_salt)"
    local hash
    hash="$(hash_password "$pw1" "$salt")"
    KALI_PASSWORD_HASH="$hash"
    KALI_PASSWORD_SALT="$salt"
    save_config
    echo -e "${G}[✓] Mot de passe defini${N}"
    log "Mot de passe mis a jour"
    sleep 1
}

show_banner() {
    clear
    echo -e "${G}"
    cat << 'EOF'
⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀
EOF
    echo -e "${N}"
    echo -e "${ACCENT}╔══════════════════════════════════════════╗"
    echo -e "║           KALI LINUX - TERMUX            ║"
    echo -e "║             Creator: KYAEV               ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo ""
}

intro_animation() {
    local frames=(
        "⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀"
        "⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀"
        "⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀"
        "⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀"
        "⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀"
    )
    clear
    echo -e "${G}"
    for line in "${frames[@]}"; do
        echo "$line"
        sleep 0.05
    done
    echo -e "${N}"
    sleep 0.3
    echo -e "${ACCENT}╔══════════════════════════════════════════╗"
    local title="  KALI LINUX - TERMUX  "
    local by="    Creator: KYAEV      "
    for ((i=0; i<${#title}; i++)); do
        printf "${W}%s" "${title:$i:1}"
        sleep 0.03
    done
    echo ""
    for ((i=0; i<${#by}; i++)); do
        printf "${C}%s" "${by:$i:1}"
        sleep 0.02
    done
    echo -e "\n${ACCENT}╚══════════════════════════════════════════╝${N}"
    sleep 0.5
}

real_progress() {
    local pid=$1
    local label="${2:-Chargement}"
    local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        local c="${chars:$((i % ${#chars})):1}"
        printf "\r${Y}  %s %s ...${N}" "$c" "$label"
        sleep 0.1
        i=$((i + 1))
    done
    wait "$pid" 2>/dev/null
    local exit_code=$?
    [ "$exit_code" -eq 127 ] && exit_code=0
    if [ "$exit_code" -eq 0 ]; then
        printf "\r${G}  [✓] %s${N}\n" "$label"
    else
        printf "\r${R}  [✗] %s (erreur $exit_code)${N}\n" "$label"
    fi
    return "$exit_code"
}

check_internet() {
    local urls="https://google.com https://1.1.1.1 https://cloudflare.com"
    for url in $urls; do
        if curl -sf --connect-timeout 8 --max-time 12 "$url" > /dev/null 2>&1; then
            echo -e "${G}[✓] Connexion OK${N}"
            log "Internet OK via $url"
            return 0
        fi
    done
    die "Pas de connexion internet"
}

check_arch() {
    local raw
    raw="$(uname -m)"
    case "$raw" in
        aarch64|armv8l|armv8b|aarch64_be|arm64|arm64-v8a) KARCH="arm64" ;;
        armv7l|armv7b|armhf|armv7-a|armv8-a)              KARCH="armhf" ;;
        x86_64|amd64)                                       KARCH="amd64" ;;
        i686|i386|i486|i586)                                KARCH="i386"  ;;
        *) die "Architecture non supportee: $raw" ;;
    esac
    echo -e "${G}[✓] Architecture: $raw → $KARCH${N}"
    log "Architecture: $raw ($KARCH)"
    export KARCH
}

check_space() {
    local free_kb
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')"
    if [ -z "$free_kb" ]; then
        echo -e "${Y}[!] Impossible de verifier l'espace — on continue${N}"
        return 0
    fi
    local required_kb=8000000
    if [ "${ROOTFS_TYPE:-nano}" = "full" ]; then
        required_kb=12000000
    fi
    if [ "$free_kb" -lt "$required_kb" ]; then
        die "Espace insuffisant: $(( free_kb / 1024 )) MB libres, $(( required_kb / 1024 )) MB requis"
    fi
    echo -e "${G}[✓] Espace OK: $(( free_kb / 1024 )) MB libres${N}"
    log "Espace: $free_kb KB libres"
}

choose_rootfs() {
    show_banner
    echo -e "${C}[?] Choisir le type de rootfs:${N}"
    echo -e "${C}[1]${W} Nano    (~200 MB)"
    echo -e "${C}[2]${W} Minimal (~140 MB)"
    echo -e "${C}[3]${W} Full    (~2 GB)"
    echo ""
    local choice
    while true; do
        read -r -p "$(echo -e "${C}Choix [1-3]: ${N}")" choice <&3
        case "$choice" in
            1) ROOTFS_TYPE="nano";    break ;;
            2) ROOTFS_TYPE="minimal"; break ;;
            3) ROOTFS_TYPE="full";    break ;;
            *) echo -e "${R}Choix invalide${N}" ;;
        esac
    done
    ROOTFS_FILE="kalifs-${KARCH}-${ROOTFS_TYPE}.tar.xz"
    ROOTFS_URL="${ROOTFS_URL_BASE}/${ROOTFS_FILE}"
    ROOTFS_URL_FB="${ROOTFS_URL_FALLBACK}/${ROOTFS_FILE}"
    log "Rootfs choisi: $ROOTFS_TYPE ($ROOTFS_FILE)"
}

verify_sha256() {
    local file="$1"
    local fname
    fname="$(basename "$file")"
    echo -e "${Y}[→] Verification SHA256...${N}"
    local expected_sha=""
    local sums_content
    for sum_url in \
        "${ROOTFS_URL_BASE}/SHA256SUMS" \
        "${ROOTFS_URL_FALLBACK}/SHA256SUMS"; do
        sums_content="$(curl -fsSL --max-time 15 "$sum_url" 2>/dev/null || true)"
        if [ -n "$sums_content" ]; then
            expected_sha="$(printf '%s' "$sums_content" | awk -v f="$fname" '$2==f{print $1}' || true)"
            [ -n "$expected_sha" ] && break
        fi
    done
    if [ -z "$expected_sha" ]; then
        echo -e "${Y}[!] SHA256 indisponible — verification ignoree${N}"
        log "SHA256 non verifie pour $fname"
        return 0
    fi
    local actual_sha
    actual_sha="$(do_sha256 "$file")"
    if [ "$expected_sha" = "$actual_sha" ]; then
        echo -e "${G}[✓] SHA256 OK${N}"
        log "SHA256 valide: $actual_sha"
    else
        rm -f "$file"
        die "SHA256 invalide — fichier corrompu ou altere"
    fi
}

update_termux() {
    local conf
    read -r -p "$(echo -e "${C}[?] Mettre a jour Termux avant installation ? (oui/non): ${N}")" conf <&3
    if [ "${conf}" != "oui" ]; then
        log "Mise a jour Termux: ignoree"
        return 0
    fi
    echo -e "${Y}[→] Mise a jour Termux...${N}"
    (pkg update -y && pkg upgrade -y) >> "${LOG_FILE}" 2>&1 &
    real_progress $! "Mise a jour Termux" || echo -e "${Y}[!] Mise a jour Termux partielle — on continue${N}"
}

install_deps() {
    echo -e "${Y}[→] Installation des dependances...${N}"
    (pkg install -y proot wget curl tar xz-utils 2>&1 | tee -a "${LOG_FILE}" > /dev/null) &
    real_progress $! "Installation dependances" || die "Echec installation dependances"
}

run_kali() {
    need_cmd proot
    local linker="${KALI_FS}/lib/ld-linux-aarch64.so.1"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib/ld-linux-armhf.so.3"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib64/ld-linux-x86-64.so.2"
    [ ! -f "$linker" ] && die "Dynamic linker introuvable dans kali-fs"
    exec env -i LD_PRELOAD="" proot \
        --link2symlink \
        -0 \
        -r "${KALI_FS}" \
        -b /dev \
        -b /proc \
        -b /sys \
        -b "${HOME}" \
        -w /root \
        /lib/ld-linux-aarch64.so.1 /bin/bash --login
}

run_kali_cmd() {
    local cmd="$1"
    local linker="${KALI_FS}/lib/ld-linux-aarch64.so.1"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib/ld-linux-armhf.so.3"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib64/ld-linux-x86-64.so.2"
    [ ! -f "$linker" ] && { log "Dynamic linker introuvable"; return 1; }
    local lname
    lname="$(basename "$linker")"
    env -i LD_PRELOAD="" proot \
        --link2symlink \
        -0 \
        -r "${KALI_FS}" \
        -b /dev -b /proc -b /sys -b "${HOME}" \
        -w /root \
        "/lib/${lname}" /bin/bash --login -c "export HOME=/root TERM=xterm-256color LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; $cmd" >> "${LOG_FILE}" 2>&1
    return $?
}

create_launcher() {
    if [ -z "${PREFIX:-}" ]; then
        echo -e "${Y}[!] PREFIX non defini — launcher non cree${N}"
        log "PREFIX non defini — launcher ignore"
        return 0
    fi
    local launcher="${PREFIX}/bin/kali"
    local kali_fs_path="${KALI_FS}"
    cat > "${launcher}" << LAUNCHER
#!/bin/bash
KALI_FS="${kali_fs_path}"
if [ ! -d "\${KALI_FS}" ]; then
    echo "Erreur: kali-fs introuvable dans \${KALI_FS}"
    exit 1
fi
exec env -i LD_PRELOAD="" proot \\
    --link2symlink -0 \\
    -r "\${KALI_FS}" \\
    -b /dev -b /proc -b /sys -b "\${HOME}" \\
    -w /root \\
    /lib/ld-linux-aarch64.so.1 /bin/bash --login
LAUNCHER
    chmod 700 "${launcher}"
    log "Launcher cree: $launcher"
}

install_kali_setup() {
    if [ -z "${PREFIX:-}" ]; then return 0; fi
    local setup_dest="${PREFIX}/bin/kali-setup"
    local src=""
    if [ -f "$0" ] && [ "$0" != "bash" ] && [ "$0" != "/proc/self/fd/0" ]; then
        src="$0"
    fi
    if [ -n "$src" ]; then
        if cp "$src" "${setup_dest}" 2>/dev/null; then
            chmod 700 "${setup_dest}"
            log "kali-setup copie depuis $src"
        fi
    fi
}

snapshot() {
    local snap_dir="${HOME}/kali-snapshots"
    mkdir -p "${snap_dir}"
    local snap_file="${snap_dir}/snap-$(date '+%Y%m%d-%H%M%S').tar.gz"
    echo -e "${Y}[→] Creation snapshot...${N}"
    (tar -czf "${snap_file}" \
        --exclude="${KALI_FS}/var/cache/apt" \
        --exclude="${KALI_FS}/tmp" \
        --exclude="${KALI_FS}/var/log" \
        -C "${HOME}" kali-fs --ignore-failed-read 2>/dev/null) &
    real_progress $! "Snapshot" || die "Snapshot echoue"
    echo -e "${G}[✓] Snapshot: ${snap_file}${N}"
    log "Snapshot: $snap_file"
    sleep 2
}

restore_snapshot() {
    local snap_dir="${HOME}/kali-snapshots"
    if [ ! -d "${snap_dir}" ] || [ -z "$(ls -A "${snap_dir}" 2>/dev/null)" ]; then
        echo -e "${R}[-] Aucun snapshot disponible${N}"
        sleep 2; return
    fi
    echo -e "${C}Snapshots disponibles:${N}"
    local i=1
    local snaps=()
    while IFS= read -r -d '' f; do
        snaps+=("$f")
        echo -e "${C}[$i]${W} $(basename "$f")"
        i=$((i + 1))
    done < <(find "${snap_dir}" -name "snap-*.tar.gz" -print0 | sort -z)
    echo ""
    local choice
    read -r -p "$(echo -e "${C}Numero de snapshot: ${N}")" choice <&3
    if [ -z "${snaps[$((choice-1))]+x}" ]; then
        echo -e "${R}[-] Choix invalide${N}"; sleep 2; return
    fi
    local selected="${snaps[$((choice-1))]}"
    if ! tar -tzf "${selected}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi
    local conf
    read -r -p "$(echo -e "${R}[!] Cette action ecrase kali-fs. Continuer ? (oui/non): ${N}")" conf <&3
    [ "${conf}" = "oui" ] || { echo -e "${Y}[!] Annule${N}"; sleep 1; return; }
    echo -e "${Y}[→] Suppression de l'ancien kali-fs...${N}"
    rm -rf "${KALI_FS}"
    (tar -xzf "${selected}" -C "${HOME}" 2>/dev/null) &
    real_progress $! "Restauration snapshot" || die "Restauration echouee"
    echo -e "${G}[✓] Restauration OK${N}"
    log "Snapshot restaure: $selected"
    sleep 2
}

backup_kali() {
    local free_kb
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')" || free_kb=0
    local kali_size
    kali_size="$(du -sk "${KALI_FS}" 2>/dev/null | awk '{print $1}')" || kali_size=0
    if [ "$free_kb" -lt "$kali_size" ]; then
        die "Espace insuffisant pour le backup"
    fi
    local backup="${HOME}/kali-backup-$(date '+%Y%m%d-%H%M%S').tar.gz"
    echo -e "${Y}[→] Backup vers $backup...${N}"
    (tar -czf "${backup}" \
        --exclude="${KALI_FS}/var/cache/apt" \
        --exclude="${KALI_FS}/tmp" \
        --exclude="${KALI_FS}/var/log" \
        -C "${HOME}" kali-fs --ignore-failed-read 2>/dev/null) &
    real_progress $! "Backup" || die "Backup echoue"
    echo -e "${G}[✓] Backup: $backup${N}"
    log "Backup: $backup"
    sleep 2
}

restore_kali() {
    local backup_file
    read -r -p "$(echo -e "${C}Chemin du backup: ${N}")" backup_file <&3
    if [ ! -f "${backup_file}" ]; then
        echo -e "${R}[-] Fichier introuvable: ${backup_file}${N}"
        sleep 2; return
    fi
    if ! tar -tzf "${backup_file}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi
    local conf
    read -r -p "$(echo -e "${R}[!] Cette action ecrase kali-fs. Continuer ? (oui/non): ${N}")" conf <&3
    [ "${conf}" = "oui" ] || { echo -e "${Y}[!] Annule${N}"; sleep 1; return; }
    echo -e "${Y}[→] Suppression de l'ancien kali-fs...${N}"
    rm -rf "${KALI_FS}"
    (tar -xzf "${backup_file}" -C "${HOME}" 2>/dev/null) &
    real_progress $! "Restauration" || die "Restauration echouee"
    echo -e "${G}[✓] Restauration OK${N}"
    log "Restaure depuis: $backup_file"
    sleep 2
}

update_kali() {
    show_banner
    echo -e "${Y}[→] Mise a jour Kali...${N}"
    run_kali_cmd "apt update -y && apt upgrade -y && apt autoremove -y" &
    real_progress $! "Mise a jour Kali" || die "Mise a jour Kali echouee — voir ${LOG_FILE}"
    echo -e "${G}[✓] Kali a jour${N}"
    log "Kali mis a jour"
    sleep 2
}

install_tools() {
    show_banner
    echo -e "${C}[?] Choisir les outils a installer:${N}"
    echo -e "${C}[1]${W} Outils de base (nmap hydra sqlmap aircrack-ng git python3)"
    echo -e "${C}[2]${W} Burp Suite"
    echo -e "${C}[3]${W} Wireshark (tshark uniquement — proot limite)"
    echo -e "${C}[4]${W} John the Ripper"
    echo -e "${C}[5]${W} Hashcat"
    echo -e "${C}[6]${W} Metasploit Framework (sans msfdb — PostgreSQL limite dans proot)"
    echo -e "${C}[7]${W} Tout installer"
    echo -e "${C}[8]${W} $(t back)"
    echo ""
    local choice
    read -r -p "$(echo -e "${C}Choix: ${N}")" choice <&3
    case "$choice" in
        1)
            run_kali_cmd "apt update -y && apt install -y nmap hydra sqlmap aircrack-ng curl wget git python3 python3-pip" &
            real_progress $! "Outils de base" || echo -e "${Y}[!] Partiel${N}"
            ;;
        2)
            run_kali_cmd "apt update -y && apt install -y burpsuite" &
            real_progress $! "Burp Suite" || echo -e "${Y}[!] Burp Suite indisponible${N}"
            ;;
        3)
            run_kali_cmd "apt update -y && apt install -y tshark" &
            real_progress $! "tshark" || echo -e "${Y}[!] tshark indisponible${N}"
            echo -e "${Y}[!] Wireshark GUI non fonctionnel dans proot — tshark installe${N}"
            ;;
        4)
            run_kali_cmd "apt update -y && apt install -y john" &
            real_progress $! "John the Ripper" || echo -e "${Y}[!] John indisponible${N}"
            ;;
        5)
            run_kali_cmd "apt update -y && apt install -y hashcat" &
            real_progress $! "Hashcat" || echo -e "${Y}[!] Hashcat indisponible${N}"
            ;;
        6)
            run_kali_cmd "apt update -y && apt install -y metasploit-framework" &
            real_progress $! "Metasploit" || echo -e "${Y}[!] Metasploit indisponible${N}"
            echo -e "${Y}[!] msfdb non initialise — PostgreSQL/systemd non supportes dans proot${N}"
            ;;
        7)
            run_kali_cmd "apt update -y && apt install -y nmap hydra sqlmap aircrack-ng curl wget git python3 python3-pip burpsuite tshark john hashcat" &
            real_progress $! "Tous les outils" || echo -e "${Y}[!] Certains outils indisponibles${N}"
            run_kali_cmd "apt install -y metasploit-framework" &
            real_progress $! "Metasploit" || echo -e "${Y}[!] Metasploit indisponible${N}"
            echo -e "${Y}[!] msfdb non initialise — PostgreSQL/systemd non supportes dans proot${N}"
            ;;
        8) return ;;
        *) echo -e "${R}[-] Invalide${N}"; sleep 1; return ;;
    esac
    echo -e "${G}[✓] Termine${N}"
    log "Outils installes: choix $choice"
    sleep 2
}

show_stats() {
    show_banner
    echo -e "${C}╔══════════════════════════════════════════╗"
    echo -e "║         STATISTIQUES SYSTEME             ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo ""
    local free_kb total_kb used_kb
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')" || free_kb=0
    total_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $2}')" || total_kb=0
    used_kb=$((total_kb - free_kb))
    echo -e "${W}Stockage:${N}"
    echo -e "  Total  : $(( total_kb / 1024 )) MB"
    echo -e "  Utilise: $(( used_kb / 1024 )) MB"
    echo -e "  Libre  : $(( free_kb / 1024 )) MB"
    echo ""
    if [ -d "${KALI_FS}" ]; then
        local kali_size
        kali_size="$(du -sh "${KALI_FS}" 2>/dev/null | awk '{print $1}')" || kali_size="?"
        echo -e "${W}Taille kali-fs:${N} ${kali_size}"
    fi
    echo ""
    local snap_count=0
    if [ -d "${HOME}/kali-snapshots" ]; then
        snap_count="$(find "${HOME}/kali-snapshots" -name "snap-*.tar.gz" 2>/dev/null | wc -l)"
    fi
    echo -e "${W}Snapshots:${N} ${snap_count}"
    echo ""
    echo -e "${W}Architecture:${N} $(uname -m)"
    echo -e "${W}Kernel:${N} $(uname -r)"
    echo -e "${W}Theme:${N} ${THEME}"
    echo -e "${W}Langue:${N} ${LANG_CODE}"
    echo ""
    read -r -p "$(echo -e "${C}[Entree pour continuer]${N}")" _ <&3
}

clean_cache() {
    show_banner
    echo -e "${Y}[→] Nettoyage du cache apt dans Kali...${N}"
    run_kali_cmd "apt clean && apt autoremove -y" &
    real_progress $! "Nettoyage cache" || echo -e "${Y}[!] Nettoyage partiel${N}"
    echo -e "${G}[✓] Cache nettoye${N}"
    log "Cache apt nettoye"
    sleep 2
}

self_update() {
    show_banner
    echo -e "${Y}[→] Verification de la mise a jour du script...${N}"
    local tmp_file
    tmp_file="$(mktemp "${HOME}/.kali-setup-new.XXXXXX")"
    if curl -fsSL --max-time 30 "${SCRIPT_URL}" -o "${tmp_file}" 2>/dev/null; then
        local tmp_size
        tmp_size="$(wc -c < "$tmp_file" 2>/dev/null || echo 0)"
        if [ "$tmp_size" -lt 1000 ]; then
            echo -e "${R}[-] Fichier telecharge trop petit — mise a jour annulee${N}"
            rm -f "$tmp_file"
            sleep 2; return
        fi
        if ! bash -n "$tmp_file" 2>/dev/null; then
            echo -e "${R}[-] Fichier telecharge invalide (erreur syntaxe) — mise a jour annulee${N}"
            rm -f "$tmp_file"
            sleep 2; return
        fi
        local new_hash old_hash
        new_hash="$(do_sha256 "$tmp_file")"
        old_hash="$(do_sha256 "$0" 2>/dev/null)" || old_hash=""
        if [ "$new_hash" = "$old_hash" ]; then
            echo -e "${G}[✓] Script deja a jour${N}"
            rm -f "$tmp_file"
        else
            mv "$tmp_file" "$0"
            chmod 700 "$0"
            if [ -n "${PREFIX:-}" ]; then
                cp "$0" "${PREFIX}/bin/kali-setup" 2>/dev/null || true
            fi
            echo -e "${G}[✓] Script mis a jour — relancez kali-setup${N}"
            log "Script auto-mis a jour"
            sleep 2
            exec "$0"
        fi
    else
        echo -e "${R}[-] Impossible de joindre le serveur${N}"
        rm -f "$tmp_file"
    fi
    sleep 2
}

menu_settings() {
    local choice
    while true; do
        show_banner
        echo -e "${ACCENT}╔══════════════════════════════════════════╗"
        echo -e "║           $(t menu_settings)                ║"
        echo -e "╚══════════════════════════════════════════╝${N}"
        echo -e "${C}[1]${W} $(t theme) [actuel: ${THEME}]"
        echo -e "${C}[2]${W} $(t lang) [actuel: ${LANG_CODE}]"
        echo -e "${C}[3]${W} $(t passwd)"
        echo -e "${C}[4]${W} $(t back)"
        echo ""
        read -r -p "$(echo -e "${C}[?] Choix: ${N}")" choice <&3
        case "$choice" in
            1) menu_theme ;;
            2) menu_lang ;;
            3) set_password ;;
            4) return ;;
            *) echo -e "${R}[-] Invalide${N}"; sleep 1 ;;
        esac
    done
}

menu_theme() {
    show_banner
    echo -e "${C}[?] Choisir un theme:${N}"
    echo -e "${C}[1]${W} Red   (defaut)"
    echo -e "${C}[2]${W} Blue"
    echo -e "${C}[3]${W} Green"
    echo -e "${C}[4]${W} Purple"
    echo ""
    local choice
    read -r -p "$(echo -e "${C}Choix [1-4]: ${N}")" choice <&3
    case "$choice" in
        1) THEME="red" ;;
        2) THEME="blue" ;;
        3) THEME="green" ;;
        4) THEME="purple" ;;
        *) echo -e "${R}[-] Invalide${N}"; sleep 1; return ;;
    esac
    apply_theme
    save_config
    echo -e "${G}[✓] Theme: ${THEME}${N}"
    log "Theme: $THEME"
    sleep 1
}

menu_lang() {
    show_banner
    echo -e "${C}[?] Choisir la langue / Choose language:${N}"
    echo -e "${C}[1]${W} Francais"
    echo -e "${C}[2]${W} English"
    echo ""
    local choice
    read -r -p "$(echo -e "${C}Choix [1-2]: ${N}")" choice <&3
    case "$choice" in
        1) LANG_CODE="fr" ;;
        2) LANG_CODE="en" ;;
        *) echo -e "${R}[-] Invalide${N}"; sleep 1; return ;;
    esac
    save_config
    echo -e "${G}[✓] Langue: ${LANG_CODE}${N}"
    log "Langue: $LANG_CODE"
    sleep 1
}

uninstall_kali() {
    show_banner
    local conf
    read -r -p "$(echo -e "${R}[!] Confirmer la desinstallation ? (oui/non): ${N}")" conf <&3
    if [ "${conf}" = "oui" ]; then
        rm -rf "${KALI_FS}"
        if [ -n "${PREFIX:-}" ]; then
            rm -f "${PREFIX}/bin/kali" "${PREFIX}/bin/kali-setup"
        fi
        echo -e "${G}[✓] Kali desinstalle${N}"
        log "Kali desinstalle"
        sleep 2
        exec "$0"
    fi
}

is_installed() {
    [ -f "${KALI_FS}/bin/bash" ] || \
    [ -f "${KALI_FS}/usr/bin/bash" ] || \
    [ -f "${KALI_FS}/bin/sh" ]
}

verify_rootfs_integrity() {
    if [ ! -f "${KALI_FS}/etc/os-release" ]; then
        rm -rf "${KALI_FS}"
        die "Extraction incomplete — /etc/os-release absent, kali-fs supprime"
    fi
    if ! grep -qi "kali" "${KALI_FS}/etc/os-release" 2>/dev/null; then
        rm -rf "${KALI_FS}"
        die "os-release ne correspond pas a Kali Linux, kali-fs supprime"
    fi
    if [ ! -d "${KALI_FS}/etc" ] || [ ! -d "${KALI_FS}/usr" ] || [ ! -d "${KALI_FS}/var" ]; then
        rm -rf "${KALI_FS}"
        die "Structure rootfs incomplete, kali-fs supprime"
    fi
}

menu_post() {
    local choice
    while true; do
        show_banner
        echo -e "${ACCENT}╔══════════════════════════════════════════╗"
        echo -e "║        $(t menu_main)                 ║"
        echo -e "╚══════════════════════════════════════════╝${N}"
        echo -e "${C}[1]${W}  $(t launch)"
        echo -e "${C}[2]${W}  $(t update_kali)"
        echo -e "${C}[3]${W}  $(t tools)"
        echo -e "${C}[4]${W}  $(t backup)"
        echo -e "${C}[5]${W}  $(t restore_bk)"
        echo -e "${C}[6]${W}  $(t snapshot)"
        echo -e "${C}[7]${W}  $(t restore_sn)"
        echo -e "${C}[8]${W}  $(t stats)"
        echo -e "${C}[9]${W}  $(t clean)"
        echo -e "${C}[10]${W} $(t self_update)"
        echo -e "${C}[11]${W} $(t settings)"
        echo -e "${C}[12]${W} $(t uninstall)"
        echo -e "${C}[13]${W} $(t quit)"
        echo ""
        read -r -p "$(echo -e "${C}[?] Choix: ${N}")" choice <&3
        case "$choice" in
            1)  run_kali ;;
            2)  update_kali ;;
            3)  install_tools ;;
            4)  backup_kali ;;
            5)  restore_kali ;;
            6)  snapshot ;;
            7)  restore_snapshot ;;
            8)  show_stats ;;
            9)  clean_cache ;;
            10) self_update ;;
            11) menu_settings ;;
            12) uninstall_kali ;;
            13) echo -e "${R}[!] Bye!${N}"; log "Quitte"; exit 0 ;;
            *)  echo -e "${R}[-] Invalide${N}"; sleep 1 ;;
        esac
    done
}

menu_install() {
    local choice
    while true; do
        show_banner
        echo -e "${ACCENT}╔══════════════════════════════════════════╗"
        echo -e "║       $(t menu_install)              ║"
        echo -e "╚══════════════════════════════════════════╝${N}"
        echo -e "${C}[1]${W} $(t auto_install)"
        echo -e "${C}[2]${W} $(t quit)"
        echo ""
        read -r -p "$(echo -e "${C}[?] Choix: ${N}")" choice <&3
        case "$choice" in
            1) auto_install; break ;;
            2) echo -e "${R}[!] Bye!${N}"; exit 0 ;;
            *) echo -e "${R}[-] Invalide${N}"; sleep 1 ;;
        esac
    done
}

auto_install() {
    show_banner
    echo -e "${G}[→] Installation automatique${N}\n"
    log "=== Installation demarree ==="

    acquire_lock

    check_internet
    check_arch
    choose_rootfs
    check_space
    update_termux
    install_deps

    if [ -d "${KALI_FS}" ]; then
        echo -e "${Y}[!] Un dossier kali-fs existe deja.${N}"
        local conf
        read -r -p "$(echo -e "${R}[?] Supprimer et reinstaller ? (oui/non): ${N}")" conf <&3
        if [ "${conf}" != "oui" ]; then
            echo -e "${Y}[!] Installation annulee${N}"
            sleep 1; return
        fi
        rm -rf "${KALI_FS}"
        log "kali-fs existant supprime avant reinstallation"
    fi

    local rootfs_dest="${HOME}/${ROOTFS_FILE}"

    echo -e "${Y}[→] Verification disponibilite du rootfs...${N}"
    local active_url=""
    echo -e "${Y}[→] Recherche du miroir disponible...${N}"
    local sums_main sums_fb
    sums_main="$(curl -fsSL --max-time 15 "${ROOTFS_URL_BASE}/SHA256SUMS" 2>/dev/null | grep -c "${ROOTFS_FILE}" || true)"
    sums_fb="$(curl -fsSL --max-time 15 "${ROOTFS_URL_FALLBACK}/SHA256SUMS" 2>/dev/null | grep -c "${ROOTFS_FILE}" || true)"
    if [ "${sums_main}" -gt 0 ] 2>/dev/null; then
        active_url="${ROOTFS_URL}"
    elif [ "${sums_fb}" -gt 0 ] 2>/dev/null; then
        active_url="${ROOTFS_URL_FB}"
        echo -e "${Y}[!] Miroir principal indisponible — miroir de secours utilise${N}"
    else
        active_url="${ROOTFS_URL_FB}"
        echo -e "${Y}[!] SHA256SUMS inaccessible — tentative sur miroir de secours${N}"
    fi
    echo -e "${G}[✓] Miroir selectionne${N}"

    if [ -f "${rootfs_dest}" ]; then
        echo -e "${Y}[!] Archive deja presente — verification integrite${N}"
        verify_sha256 "${rootfs_dest}"
    else
        echo -e "${Y}[→] Telechargement ${ROOTFS_FILE}...${N}"
        log "Telechargement: $active_url"
        if ! curl -fL -C - --progress-bar "${active_url}" -o "${rootfs_dest}"; then
            rm -f "${rootfs_dest}"
            die "Echec du telechargement"
        fi
        verify_sha256 "${rootfs_dest}"
    fi

    echo -e "${Y}[→] Extraction du rootfs...${N}"
    mkdir -p "${KALI_FS}"
    tar \
        -xJf "${rootfs_dest}" \
        --warning=no-unknown-keyword \
        --strip-components=1 \
        -C "${KALI_FS}" 2>/dev/null &
    local tar_pid=$!
    real_progress $tar_pid "Extraction rootfs" || true
    wait $tar_pid 2>/dev/null
    local tar_exit=$?
    [ "$tar_exit" -eq 2 ] && tar_exit=0

    rm -f "${rootfs_dest}"

    if [ "$tar_exit" -ne 0 ] || ! is_installed; then
        rm -rf "${KALI_FS}"
        die "Extraction echouee — kali-fs nettoye"
    fi

    verify_rootfs_integrity

    echo -e "${G}[✓] Rootfs extrait et valide${N}"
    log "Rootfs extrait"

    echo -e "${Y}[→] Configuration initiale Kali...${N}"
    run_kali_cmd "apt update -y && apt install -y curl wget git python3" &
    real_progress $! "Config initiale" || echo -e "${Y}[!] Config initiale partielle — on continue${N}"

    create_launcher
    install_kali_setup

    echo -e "${G}[→] Configuration du mot de passe de protection${N}"
    set_password

    show_banner
    echo -e "${G}╔══════════════════════════════════════════╗"
    echo -e "║         INSTALLATION TERMINEE !          ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo -e "${W}  Lancer Kali:   ${G}kali${N}"
    echo -e "${W}  Ce menu:       ${G}kali-setup${N}"
    echo -e "${W}  Logs:          ${G}${LOG_FILE}${N}"
    log "=== Installation terminee ==="
    sleep 3
}

touch "${LOG_FILE}"
log "=== kali-setup demarre ==="
rm -f "${LOCK_FILE}" 2>/dev/null || true

load_config
intro_animation
check_password

if is_installed; then
    echo -e "${G}[✓] Kali Linux detecte${N}"
    log "Kali detecte dans $KALI_FS"
    sleep 1
    menu_post
else
    log "Kali non installe"
    menu_install
fi
