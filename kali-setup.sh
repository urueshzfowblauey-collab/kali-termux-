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
KARCH=""
ROOTFS_TYPE=""
ROOTFS_FILE=""
ROOTFS_URL=""
ROOTFS_URL_FB=""

apply_theme() {
    case "${THEME}" in
        red)
            R='\033[38;2;215;0;0m'; G='\033[38;2;0;220;100m'; Y='\033[38;2;255;215;0m'
            C='\033[38;2;0;200;180m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[38;2;215;0;0m'; DIM='\033[2m'; BOLD='\033[1m'
            ;;
        blue)
            R='\033[0;34m'; G='\033[0;36m'; Y='\033[0;33m'
            C='\033[0;34m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;34m'; DIM='\033[2m'; BOLD='\033[1m'
            ;;
        green)
            R='\033[0;32m'; G='\033[0;32m'; Y='\033[0;33m'
            C='\033[0;32m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;32m'; DIM='\033[2m'; BOLD='\033[1m'
            ;;
        purple)
            R='\033[0;35m'; G='\033[0;35m'; Y='\033[0;33m'
            C='\033[0;35m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[0;35m'; DIM='\033[2m'; BOLD='\033[1m'
            ;;
        *)
            R='\033[38;2;215;0;0m'; G='\033[38;2;0;220;100m'; Y='\033[38;2;255;215;0m'
            C='\033[38;2;0;200;180m'; W='\033[1;37m'; N='\033[0m'
            ACCENT='\033[38;2;215;0;0m'; DIM='\033[2m'; BOLD='\033[1m'
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

log()  { echo "[$(date '+%H:%M:%S')] $*" >> "${LOG_FILE}"; }
die()  { echo -e "${R}[-] $*${N}" | tee -a "${LOG_FILE}"; exit 1; }

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
    [ -z "${KALI_PASSWORD_HASH}" ] && return 0
    local attempts=0 input input_hash
    while [ "$attempts" -lt 3 ]; do
        read -r -s -p "$(echo -e "${C}[?] Mot de passe: ${N}")" input <&3
        echo ""
        input_hash="$(hash_password "$input" "$KALI_PASSWORD_SALT")"
        if [ "$input_hash" = "$KALI_PASSWORD_HASH" ]; then return 0; fi
        attempts=$((attempts + 1))
        echo -e "${R}[-] Mot de passe incorrect ($attempts/3)${N}"
    done
    die "Trop de tentatives"
}

set_password() {
    local pw1 pw2 salt hash
    read -r -s -p "$(echo -e "${C}[?] Nouveau mot de passe (vide = desactiver): ${N}")" pw1 <&3
    echo ""
    if [ -z "$pw1" ]; then
        KALI_PASSWORD_HASH=""
        KALI_PASSWORD_SALT=""
        save_config
        echo -e "${G}[✓] Mot de passe desactive${N}"
        log "Mot de passe desactive"
        sleep 1
        return
    fi
    read -r -s -p "$(echo -e "${C}[?] Confirmer le mot de passe: ${N}")" pw2 <&3
    echo ""
    if [ "$pw1" != "$pw2" ]; then
        echo -e "${R}[-] Les mots de passe ne correspondent pas${N}"
        sleep 1
        return
    fi
    salt="$(gen_salt)"
    hash="$(hash_password "$pw1" "$salt")"
    KALI_PASSWORD_HASH="$hash"
    KALI_PASSWORD_SALT="$salt"
    save_config
    echo -e "${G}[✓] Mot de passe defini${N}"
    log "Mot de passe mis a jour"
    sleep 1
}

print_ascii_color() {
    local DR='\033[38;2;180;0;0m'
    local R1='\033[38;2;215;0;0m'
    local WW='\033[38;2;230;230;230m'
    local NN='\033[0m'
    echo -e "${DR}⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸${WW}⣿⣷⣶⣦⣤⣄⣈⡑${R1}⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀${WW}⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮${R1}⣷⣤⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀${WW}⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯${R1}⣧⡀⠀⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻${R1}⢷⡤⠀⠀⠀${NN}"
    echo -e "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${R1}⠀⠀⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠻⣿⣦⣤⣀⡀${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀${DR}⠀⠀⠀⠀⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠉⠻⣿⣯⡛${DR}⠻⢦⡀⠀⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠙⢿⣆${DR}⠀⠙⢆⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⢻⣆${DR}⠀⠈⢣${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠻⡆${DR}⠀⠈${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⢻⡀${DR}⠀${NN}"
    echo -e "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠃${DR}⠀${NN}"
}

vfx_scanlines() {
    local msgs=(
        "SYS  — Initialisation du noyau ARM"
        "CPU  — Architecture aarch64 detectee"
        "MEM  — Allocation memoire dynamique"
        "FS   — Montage du systeme de fichiers"
        "NET  — Interface reseau operationnelle"
        "SEC  — Module de chiffrement charge"
        "ENV  — Termux environment valide"
        "RDY  — Demarrage de kali-setup"
    )
    local DG='\033[38;2;60;60;60m'
    local DW='\033[38;2;120;120;120m'
    local NN='\033[0m'
    clear
    echo ""
    for msg in "${msgs[@]}"; do
        printf "  ${DG}[${DW}%s${DG}]${NN}\n" "$msg"
        sleep 0.09
    done
    sleep 0.25
}

vfx_glitch_line() {
    local text="$1"
    local color="${2:-$R}"
    local glitch='░▒▓█▀▄▌▐'
    local out=""
    local i=0
    while [ $i -lt ${#text} ]; do
        local c="${text:$i:1}"
        if [ "$c" != " " ] && [ $(( i % 6 )) -eq 0 ]; then
            local gi=$(( i % ${#glitch} ))
            out+="${glitch:$gi:1}"
        else
            out+="$c"
        fi
        i=$(( i + 1 ))
    done
    printf "${color}%s${N}\n" "$out"
    sleep 0.04
    printf "${color}%s${N}\n" "$text"
}

intro_animation() {
    clear
    vfx_scanlines
    clear

    local DR='\033[38;2;100;0;0m'
    local R1='\033[38;2;180;0;0m'
    local WW='\033[38;2;200;200;200m'
    local NN='\033[0m'

    local lines=(
        "${DR}⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${R1}⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${R1}⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${R1}⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸${WW}⣿⣷⣶⣦⣤⣄⣈⡑${R1}⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${R1}⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀${WW}⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮${R1}⣷⣤⠀⠀⠀⠀⠀⠀${NN}"
        "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀${WW}⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯${R1}⣧⡀⠀⠀⠀⠀${NN}"
        "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻${R1}⢷⡤⠀⠀⠀${NN}"
        "${R1}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${R1}⠀⠀⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠻⣿⣦⣤⣀⡀${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀${DR}⠀⠀⠀⠀⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠉⠻⣿⣯⡛${DR}⠻⢦⡀⠀⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠙⢿⣆${DR}⠀⠙⢆⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⢻⣆${DR}⠀⠈⢣${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠻⡆${DR}⠀⠈${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⢻⡀${DR}⠀${NN}"
        "${DR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${WW}⠈⠃${DR}⠀${NN}"
    )

    echo ""
    for line in "${lines[@]}"; do
        echo -e "$line"
        sleep 0.04
    done

    echo ""
    local title="  KALI LINUX — TERMUX"
    for ((i=0; i<${#title}; i++)); do
        printf "${R}${BOLD}%s${N}" "${title:$i:1}"
        sleep 0.025
    done
    echo ""

    local by="  creator kyaev"
    for ((i=0; i<${#by}; i++)); do
        printf "${C}${DIM}%s${N}" "${by:$i:1}"
        sleep 0.018
    done
    echo -e "\n"

    local bar_width=42
    printf "  \033[38;2;60;60;60m┌%s┐\033[0m\n" "$(printf '─%.0s' $(seq 1 $bar_width))"
    printf "  \033[38;2;60;60;60m│\033[0m "
    for ((i=0; i<bar_width-2; i++)); do
        printf "${R}█${N}"
        sleep 0.022
    done
    printf " \033[38;2;60;60;60m│\033[0m\n"
    printf "  \033[38;2;60;60;60m└%s┘\033[0m\n" "$(printf '─%.0s' $(seq 1 $bar_width))"

    sleep 0.4
    vfx_glitch_line "  [ SYSTEME PRET ]" "${R}"
    sleep 0.3
}

show_banner() {
    clear
    echo ""
    print_ascii_color
    echo ""
    echo -e "${ACCENT}${BOLD}  ╔══════════════════════════════════════════╗${N}"
    echo -e "${ACCENT}${BOLD}  ║       KALI LINUX — TERMUX MANAGER       ║${N}"
    echo -e "${ACCENT}${BOLD}  ║          ${C}creator kyaev${ACCENT}                   ║${N}"
    echo -e "${ACCENT}${BOLD}  ╚══════════════════════════════════════════╝${N}"
    echo ""
}

real_progress() {
    local pid=$1
    local label="${2:-Chargement}"
    local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        local c="${chars:$((i % ${#chars})):1}"
        printf "\r  ${Y}%s${N} ${W}%s${N} ..." "$c" "$label"
        sleep 0.09
        i=$((i + 1))
    done
    wait "$pid" 2>/dev/null
    local exit_code=$?
    [ "$exit_code" -eq 127 ] && exit_code=0
    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${G}[✓]${N} ${W}%s${N}          \n" "$label"
    else
        printf "\r  ${R}[✗]${N} ${W}%s${N} (erreur %d)\n" "$label" "$exit_code"
    fi
    return "$exit_code"
}

check_internet() {
    local urls="https://google.com https://1.1.1.1 https://cloudflare.com"
    for url in $urls; do
        if curl -sf --connect-timeout 8 --max-time 12 "$url" > /dev/null 2>&1; then
            echo -e "  ${G}[✓]${N} Connexion internet OK"
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
    echo -e "  ${G}[✓]${N} Architecture: ${W}$raw${N} → ${C}$KARCH${N}"
    log "Architecture: $raw ($KARCH)"
    export KARCH
}

check_space() {
    local free_kb
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')"
    if [ -z "$free_kb" ]; then
        echo -e "  ${Y}[!]${N} Impossible de verifier l'espace — on continue"
        return 0
    fi
    local required_kb=8000000
    if [ "${ROOTFS_TYPE:-nano}" = "full" ]; then required_kb=12000000; fi
    if [ "$free_kb" -lt "$required_kb" ]; then
        die "Espace insuffisant: $(( free_kb / 1024 )) MB libres, $(( required_kb / 1024 )) MB requis"
    fi
    echo -e "  ${G}[✓]${N} Espace OK: ${W}$(( free_kb / 1024 )) MB${N} libres"
    log "Espace: $free_kb KB libres"
}

choose_rootfs() {
    show_banner
    echo -e "  ${C}[?]${N} Choisir le type de rootfs:\n"
    echo -e "  ${R}[1]${N} ${W}Nano    ${Y}(~200 MB)${N}"
    echo -e "  ${R}[2]${N} ${W}Minimal ${Y}(~140 MB)${N}"
    echo -e "  ${R}[3]${N} ${W}Full    ${Y}(~2 GB)${N}"
    echo ""
    local choice
    while true; do
        read -r -p "$(echo -e "  ${C}Choix [1-3] >${N} ")" choice <&3
        case "$choice" in
            1) ROOTFS_TYPE="nano";    break ;;
            2) ROOTFS_TYPE="minimal"; break ;;
            3) ROOTFS_TYPE="full";    break ;;
            *) echo -e "  ${R}[-]${N} Choix invalide" ;;
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
    echo -e "  ${Y}[→]${N} Verification SHA256..."
    local expected_sha="" sums_content
    for sum_url in "${ROOTFS_URL_BASE}/SHA256SUMS" "${ROOTFS_URL_FALLBACK}/SHA256SUMS"; do
        sums_content="$(curl -fsSL --max-time 15 "$sum_url" 2>/dev/null || true)"
        if [ -n "$sums_content" ]; then
            expected_sha="$(printf '%s' "$sums_content" | awk -v f="$fname" '$2==f{print $1}' || true)"
            [ -n "$expected_sha" ] && break
        fi
    done
    if [ -z "$expected_sha" ]; then
        echo -e "  ${Y}[!]${N} SHA256 indisponible — verification ignoree"
        log "SHA256 non verifie pour $fname"
        return 0
    fi
    local actual_sha
    actual_sha="$(do_sha256 "$file")"
    if [ "$expected_sha" = "$actual_sha" ]; then
        echo -e "  ${G}[✓]${N} SHA256 valide"
        log "SHA256 valide: $actual_sha"
    else
        rm -f "$file"
        die "SHA256 invalide — fichier corrompu"
    fi
}

update_termux() {
    local conf
    read -r -p "$(echo -e "  ${C}[?]${N} Mettre a jour Termux avant installation ? ${W}(oui/non)${N}: ")" conf <&3
    if [ "${conf}" != "oui" ]; then
        log "Mise a jour Termux: ignoree"
        return 0
    fi
    echo -e "  ${Y}[→]${N} Mise a jour Termux..."
    (pkg update -y && pkg upgrade -y) >> "${LOG_FILE}" 2>&1 &
    real_progress $! "Mise a jour Termux" || echo -e "  ${Y}[!]${N} Mise a jour partielle — on continue"
}

install_deps() {
    echo -e "  ${Y}[→]${N} Installation des dependances..."
    (pkg install -y proot wget curl tar xz-utils 2>&1 | tee -a "${LOG_FILE}" > /dev/null) &
    real_progress $! "Installation dependances" || die "Echec installation dependances"
}

run_kali() {
    need_cmd proot
    local linker="${KALI_FS}/lib/ld-linux-aarch64.so.1"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib/ld-linux-armhf.so.3"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib64/ld-linux-x86-64.so.2"
    [ ! -f "$linker" ] && die "Dynamic linker introuvable dans kali-fs"
    local lname
    lname="$(basename "$linker")"
    exec env -i LD_PRELOAD="" proot \
        --link2symlink -0 \
        -r "${KALI_FS}" \
        -b /dev -b /proc -b /sys -b "${HOME}" \
        -w /root \
        "/lib/${lname}" /bin/bash --login
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
        --link2symlink -0 \
        -r "${KALI_FS}" \
        -b /dev -b /proc -b /sys -b "${HOME}" \
        -w /root \
        "/lib/${lname}" /bin/bash --login -c \
        "export HOME=/root TERM=xterm-256color LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; $cmd" \
        >> "${LOG_FILE}" 2>&1
    return $?
}

create_launcher() {
    if [ -z "${PREFIX:-}" ]; then
        echo -e "  ${Y}[!]${N} PREFIX non defini — launcher non cree"
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
LINKER="\${KALI_FS}/lib/ld-linux-aarch64.so.1"
[ ! -f "\${LINKER}" ] && LINKER="\${KALI_FS}/lib/ld-linux-armhf.so.3"
[ ! -f "\${LINKER}" ] && LINKER="\${KALI_FS}/lib64/ld-linux-x86-64.so.2"
[ ! -f "\${LINKER}" ] && { echo "Erreur: dynamic linker introuvable"; exit 1; }
LNAME="\$(basename "\${LINKER}")"
exec env -i LD_PRELOAD="" proot \\
    --link2symlink -0 \\
    -r "\${KALI_FS}" \\
    -b /dev -b /proc -b /sys -b "\${HOME}" \\
    -w /root \\
    "/lib/\${LNAME}" /bin/bash --login
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
    echo -e "  ${Y}[→]${N} Creation snapshot..."
    (tar -czf "${snap_file}" \
        --exclude="${KALI_FS}/var/cache/apt" \
        --exclude="${KALI_FS}/tmp" \
        --exclude="${KALI_FS}/var/log" \
        -C "${HOME}" kali-fs --ignore-failed-read 2>/dev/null) &
    real_progress $! "Snapshot" || die "Snapshot echoue"
    echo -e "  ${G}[✓]${N} Snapshot: ${W}${snap_file}${N}"
    log "Snapshot: $snap_file"
    sleep 2
}

restore_snapshot() {
    local snap_dir="${HOME}/kali-snapshots"
    if [ ! -d "${snap_dir}" ] || [ -z "$(ls -A "${snap_dir}" 2>/dev/null)" ]; then
        echo -e "  ${R}[-]${N} Aucun snapshot disponible"
        sleep 2
        return
    fi
    echo -e "  ${C}Snapshots disponibles:${N}"
    local i=1
    local snaps=()
    while IFS= read -r -d '' f; do
        snaps+=("$f")
        echo -e "  ${R}[$i]${N} ${W}$(basename "$f")${N}"
        i=$((i + 1))
    done < <(find "${snap_dir}" -name "snap-*.tar.gz" -print0 | sort -z)
    echo ""
    local choice
    read -r -p "$(echo -e "  ${C}Numero de snapshot >${N} ")" choice <&3
    if [ -z "${snaps[$((choice-1))]+x}" ]; then
        echo -e "  ${R}[-]${N} Choix invalide"
        sleep 2
        return
    fi
    local selected="${snaps[$((choice-1))]}"
    if ! tar -tzf "${selected}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi
    local conf
    read -r -p "$(echo -e "  ${R}[!]${N} Cette action ecrase kali-fs. Continuer ? ${W}(oui/non)${N}: ")" conf <&3
    [ "${conf}" = "oui" ] || { echo -e "  ${Y}[!]${N} Annule"; sleep 1; return; }
    rm -rf "${KALI_FS}"
    (tar -xzf "${selected}" -C "${HOME}" 2>/dev/null) &
    real_progress $! "Restauration snapshot" || die "Restauration echouee"
    echo -e "  ${G}[✓]${N} Restauration OK"
    log "Snapshot restaure: $selected"
    sleep 2
}

backup_kali() {
    local free_kb kali_size
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')" || free_kb=0
    kali_size="$(du -sk "${KALI_FS}" 2>/dev/null | awk '{print $1}')" || kali_size=0
    if [ "$free_kb" -lt "$kali_size" ]; then die "Espace insuffisant pour le backup"; fi
    local backup="${HOME}/kali-backup-$(date '+%Y%m%d-%H%M%S').tar.gz"
    echo -e "  ${Y}[→]${N} Backup vers $backup..."
    (tar -czf "${backup}" \
        --exclude="${KALI_FS}/var/cache/apt" \
        --exclude="${KALI_FS}/tmp" \
        --exclude="${KALI_FS}/var/log" \
        -C "${HOME}" kali-fs --ignore-failed-read 2>/dev/null) &
    real_progress $! "Backup" || die "Backup echoue"
    echo -e "  ${G}[✓]${N} Backup: ${W}${backup}${N}"
    log "Backup: $backup"
    sleep 2
}

restore_kali() {
    local backup_file
    read -r -p "$(echo -e "  ${C}Chemin du backup >${N} ")" backup_file <&3
    if [ ! -f "${backup_file}" ]; then
        echo -e "  ${R}[-]${N} Fichier introuvable: ${backup_file}"
        sleep 2
        return
    fi
    if ! tar -tzf "${backup_file}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi
    local conf
    read -r -p "$(echo -e "  ${R}[!]${N} Cette action ecrase kali-fs. Continuer ? ${W}(oui/non)${N}: ")" conf <&3
    [ "${conf}" = "oui" ] || { echo -e "  ${Y}[!]${N} Annule"; sleep 1; return; }
    rm -rf "${KALI_FS}"
    (tar -xzf "${backup_file}" -C "${HOME}" 2>/dev/null) &
    real_progress $! "Restauration" || die "Restauration echouee"
    echo -e "  ${G}[✓]${N} Restauration OK"
    log "Restaure depuis: $backup_file"
    sleep 2
}

update_kali() {
    show_banner
    echo -e "  ${Y}[→]${N} Mise a jour Kali..."
    run_kali_cmd "apt update -y && apt upgrade -y && apt autoremove -y" &
    real_progress $! "Mise a jour Kali" || die "Mise a jour Kali echouee — voir ${LOG_FILE}"
    echo -e "  ${G}[✓]${N} Kali a jour"
    log "Kali mis a jour"
    sleep 2
}

install_tools() {
    show_banner
    echo -e "  ${C}[?]${N} Choisir les outils a installer:\n"
    echo -e "  ${R}[1]${N}  ${W}Outils de base${N} ${Y}(nmap hydra sqlmap aircrack-ng git python3)${N}"
    echo -e "  ${R}[2]${N}  ${W}Burp Suite${N}"
    echo -e "  ${R}[3]${N}  ${W}Wireshark${N} ${Y}(tshark — proot limite)${N}"
    echo -e "  ${R}[4]${N}  ${W}John the Ripper${N}"
    echo -e "  ${R}[5]${N}  ${W}Hashcat${N}"
    echo -e "  ${R}[6]${N}  ${W}Metasploit Framework${N}"
    echo -e "  ${R}[7]${N}  ${W}Tout installer${N}"
    echo -e "  ${R}[8]${N}  ${W}$(t back)${N}"
    echo ""
    local choice
    read -r -p "$(echo -e "  ${C}Choix >${N} ")" choice <&3
    case "$choice" in
        1)
            run_kali_cmd "apt update -y && apt install -y nmap hydra sqlmap aircrack-ng curl wget git python3 python3-pip" &
            real_progress $! "Outils de base" || echo -e "  ${Y}[!]${N} Partiel"
            ;;
        2)
            run_kali_cmd "apt update -y && apt install -y burpsuite" &
            real_progress $! "Burp Suite" || echo -e "  ${Y}[!]${N} Burp Suite indisponible"
            ;;
        3)
            run_kali_cmd "apt update -y && apt install -y tshark" &
            real_progress $! "tshark" || echo -e "  ${Y}[!]${N} tshark indisponible"
            echo -e "  ${Y}[!]${N} Wireshark GUI non fonctionnel dans proot — tshark installe"
            ;;
        4)
            run_kali_cmd "apt update -y && apt install -y john" &
            real_progress $! "John the Ripper" || echo -e "  ${Y}[!]${N} John indisponible"
            ;;
        5)
            run_kali_cmd "apt update -y && apt install -y hashcat" &
            real_progress $! "Hashcat" || echo -e "  ${Y}[!]${N} Hashcat indisponible"
            ;;
        6)
            run_kali_cmd "apt update -y && apt install -y metasploit-framework" &
            real_progress $! "Metasploit" || echo -e "  ${Y}[!]${N} Metasploit indisponible"
            echo -e "  ${Y}[!]${N} msfdb non initialise — PostgreSQL/systemd non supportes dans proot"
            ;;
        7)
            run_kali_cmd "apt update -y && apt install -y nmap hydra sqlmap aircrack-ng curl wget git python3 python3-pip burpsuite tshark john hashcat" &
            real_progress $! "Tous les outils" || echo -e "  ${Y}[!]${N} Certains outils indisponibles"
            run_kali_cmd "apt install -y metasploit-framework" &
            real_progress $! "Metasploit" || echo -e "  ${Y}[!]${N} Metasploit indisponible"
            ;;
        8) return ;;
        *) echo -e "  ${R}[-]${N} Invalide"; sleep 1; return ;;
    esac
    echo -e "\n  ${G}[✓]${N} Termine"
    log "Outils installes: choix $choice"
    sleep 2
}

show_stats() {
    show_banner
    echo -e "  ${ACCENT}${BOLD}╔══════════════════════════════════════════╗${N}"
    echo -e "  ${ACCENT}${BOLD}║         STATISTIQUES SYSTEME             ║${N}"
    echo -e "  ${ACCENT}${BOLD}╚══════════════════════════════════════════╝${N}\n"
    local free_kb total_kb used_kb
    free_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $4}')" || free_kb=0
    total_kb="$(df "${HOME}" 2>/dev/null | awk 'NR==2{print $2}')" || total_kb=0
    used_kb=$((total_kb - free_kb))
    echo -e "  ${C}Stockage${N}"
    echo -e "   ${Y}Total  :${N}  ${W}$(( total_kb / 1024 )) MB${N}"
    echo -e "   ${Y}Utilise:${N}  ${W}$(( used_kb / 1024 )) MB${N}"
    echo -e "   ${Y}Libre  :${N}  ${G}$(( free_kb / 1024 )) MB${N}\n"
    if [ -d "${KALI_FS}" ]; then
        local kali_size
        kali_size="$(du -sh "${KALI_FS}" 2>/dev/null | awk '{print $1}')" || kali_size="?"
        echo -e "  ${C}Taille kali-fs:${N}  ${W}${kali_size}${N}"
    fi
    local snap_count=0
    if [ -d "${HOME}/kali-snapshots" ]; then
        snap_count="$(find "${HOME}/kali-snapshots" -name "snap-*.tar.gz" 2>/dev/null | wc -l)"
    fi
    echo -e "  ${C}Snapshots:${N}  ${W}${snap_count}${N}\n"
    echo -e "  ${C}Architecture:${N}  ${W}$(uname -m)${N}"
    echo -e "  ${C}Kernel:${N}  ${W}$(uname -r)${N}"
    echo -e "  ${C}Theme:${N}  ${W}${THEME}${N}"
    echo -e "  ${C}Langue:${N}  ${W}${LANG_CODE}${N}\n"
    read -r -p "$(echo -e "  ${C}[ Entree pour continuer ]${N}")" _ <&3
}

clean_cache() {
    show_banner
    echo -e "  ${Y}[→]${N} Nettoyage du cache apt dans Kali..."
    run_kali_cmd "apt clean && apt autoremove -y" &
    real_progress $! "Nettoyage cache" || echo -e "  ${Y}[!]${N} Nettoyage partiel"
    echo -e "  ${G}[✓]${N} Cache nettoye"
    log "Cache apt nettoye"
    sleep 2
}

self_update() {
    show_banner
    echo -e "  ${Y}[→]${N} Verification de la mise a jour du script..."
    local tmp_file
    tmp_file="$(mktemp "${HOME}/.kali-setup-new.XXXXXX")"
    if curl -fsSL --max-time 30 "${SCRIPT_URL}" -o "${tmp_file}" 2>/dev/null; then
        local tmp_size
        tmp_size="$(wc -c < "$tmp_file" 2>/dev/null || echo 0)"
        if [ "$tmp_size" -lt 1000 ]; then
            echo -e "  ${R}[-]${N} Fichier telecharge trop petit — mise a jour annulee"
            rm -f "$tmp_file"
            sleep 2
            return
        fi
        if ! bash -n "$tmp_file" 2>/dev/null; then
            echo -e "  ${R}[-]${N} Fichier invalide (erreur syntaxe) — mise a jour annulee"
            rm -f "$tmp_file"
            sleep 2
            return
        fi
        local new_hash old_hash
        new_hash="$(do_sha256 "$tmp_file")"
        old_hash="$(do_sha256 "$0" 2>/dev/null)" || old_hash=""
        if [ "$new_hash" = "$old_hash" ]; then
            echo -e "  ${G}[✓]${N} Script deja a jour"
            rm -f "$tmp_file"
        else
            mv "$tmp_file" "$0"
            chmod 700 "$0"
            if [ -n "${PREFIX:-}" ]; then
                cp "$0" "${PREFIX}/bin/kali-setup" 2>/dev/null || true
            fi
            echo -e "  ${G}[✓]${N} Script mis a jour — relancez kali-setup"
            log "Script auto-mis a jour"
            sleep 2
            exec "$0"
        fi
    else
        echo -e "  ${R}[-]${N} Impossible de joindre le serveur"
        rm -f "$tmp_file"
    fi
    sleep 2
}

menu_settings() {
    local choice
    while true; do
        show_banner
        echo -e "  ${ACCENT}${BOLD}╔══════════════════════════════════════════╗${N}"
        echo -e "  ${ACCENT}${BOLD}║           $(t menu_settings)                  ║${N}"
        echo -e "  ${ACCENT}${BOLD}╚══════════════════════════════════════════╝${N}\n"
        echo -e "  ${R}[1]${N}  ${W}$(t theme)${N} ${Y}[actuel: ${THEME}]${N}"
        echo -e "  ${R}[2]${N}  ${W}$(t lang)${N} ${Y}[actuel: ${LANG_CODE}]${N}"
        echo -e "  ${R}[3]${N}  ${W}$(t passwd)${N}"
        echo -e "  ${R}[4]${N}  ${W}$(t back)${N}\n"
        read -r -p "$(echo -e "  ${C}[?] Choix >${N} ")" choice <&3
        case "$choice" in
            1) menu_theme ;;
            2) menu_lang ;;
            3) set_password ;;
            4) return ;;
            *) echo -e "  ${R}[-]${N} Invalide"; sleep 1 ;;
        esac
    done
}

menu_theme() {
    show_banner
    echo -e "  ${C}[?]${N} Choisir un theme:\n"
    echo -e "  ${R}[1]${N}  ${W}Red   ${Y}(defaut)${N}"
    echo -e "  ${R}[2]${N}  ${W}Blue${N}"
    echo -e "  ${R}[3]${N}  ${W}Green${N}"
    echo -e "  ${R}[4]${N}  ${W}Purple${N}\n"
    local choice
    read -r -p "$(echo -e "  ${C}Choix [1-4] >${N} ")" choice <&3
    case "$choice" in
        1) THEME="red" ;; 2) THEME="blue" ;; 3) THEME="green" ;; 4) THEME="purple" ;;
        *) echo -e "  ${R}[-]${N} Invalide"; sleep 1; return ;;
    esac
    apply_theme
    save_config
    echo -e "  ${G}[✓]${N} Theme: ${W}${THEME}${N}"
    log "Theme: $THEME"
    sleep 1
}

menu_lang() {
    show_banner
    echo -e "  ${C}[?]${N} Choisir la langue / Choose language:\n"
    echo -e "  ${R}[1]${N}  ${W}Francais${N}"
    echo -e "  ${R}[2]${N}  ${W}English${N}\n"
    local choice
    read -r -p "$(echo -e "  ${C}Choix [1-2] >${N} ")" choice <&3
    case "$choice" in
        1) LANG_CODE="fr" ;; 2) LANG_CODE="en" ;;
        *) echo -e "  ${R}[-]${N} Invalide"; sleep 1; return ;;
    esac
    save_config
    echo -e "  ${G}[✓]${N} Langue: ${W}${LANG_CODE}${N}"
    log "Langue: $LANG_CODE"
    sleep 1
}

uninstall_kali() {
    show_banner
    echo -e "  ${R}[!]${N} ${W}Cette action supprimera definitivement Kali Linux.${N}\n"
    local conf
    read -r -p "$(echo -e "  ${R}Confirmer ? (oui/non) >${N} ")" conf <&3
    if [ "${conf}" = "oui" ]; then
        rm -rf "${KALI_FS}"
        if [ -n "${PREFIX:-}" ]; then
            rm -f "${PREFIX}/bin/kali" "${PREFIX}/bin/kali-setup"
        fi
        echo -e "\n  ${G}[✓]${N} Kali desinstalle"
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
        echo -e "  ${ACCENT}${BOLD}╔══════════════════════════════════════════╗${N}"
        echo -e "  ${ACCENT}${BOLD}║          $(t menu_main)               ║${N}"
        echo -e "  ${ACCENT}${BOLD}╚══════════════════════════════════════════╝${N}\n"
        echo -e "  ${R}[1]${N}   ▶  ${W}$(t launch)${N}"
        echo -e "  ${R}[2]${N}   ⟳  ${W}$(t update_kali)${N}"
        echo -e "  ${R}[3]${N}   ⚙  ${W}$(t tools)${N}"
        echo -e "  ${R}[4]${N}   ↑  ${W}$(t backup)${N}"
        echo -e "  ${R}[5]${N}   ↓  ${W}$(t restore_bk)${N}"
        echo -e "  ${R}[6]${N}   ◈  ${W}$(t snapshot)${N}"
        echo -e "  ${R}[7]${N}   ◉  ${W}$(t restore_sn)${N}"
        echo -e "  ${R}[8]${N}   ≡  ${W}$(t stats)${N}"
        echo -e "  ${R}[9]${N}   ✦  ${W}$(t clean)${N}"
        echo -e "  ${R}[10]${N}  ↺  ${W}$(t self_update)${N}"
        echo -e "  ${R}[11]${N}  ✎  ${W}$(t settings)${N}"
        echo -e "  ${R}[12]${N}  ✖  ${W}$(t uninstall)${N}"
        echo -e "  \033[38;2;80;80;80m[13]  ⏻  $(t quit)${N}\n"
        read -r -p "$(echo -e "  ${C}[?] Choix >${N} ")" choice <&3
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
            13) echo -e "\n  ${R}Bye!${N}\n"; log "Quitte"; exit 0 ;;
            *)  echo -e "  ${R}[-]${N} Invalide"; sleep 1 ;;
        esac
    done
}

menu_install() {
    local choice
    while true; do
        show_banner
        echo -e "  ${ACCENT}${BOLD}╔══════════════════════════════════════════╗${N}"
        echo -e "  ${ACCENT}${BOLD}║       $(t menu_install)              ║${N}"
        echo -e "  ${ACCENT}${BOLD}╚══════════════════════════════════════════╝${N}\n"
        echo -e "  ${R}[1]${N}  ${W}$(t auto_install)${N}"
        echo -e "  ${R}[2]${N}  ${W}$(t quit)${N}\n"
        read -r -p "$(echo -e "  ${C}[?] Choix >${N} ")" choice <&3
        case "$choice" in
            1) auto_install; break ;;
            2) echo -e "\n  ${R}Bye!${N}\n"; exit 0 ;;
            *) echo -e "  ${R}[-]${N} Invalide"; sleep 1 ;;
        esac
    done
}

auto_install() {
    show_banner
    echo -e "  ${G}[→]${N} ${BOLD}Installation automatique${N}\n"
    log "=== Installation demarree ==="

    acquire_lock
    check_internet
    check_arch
    choose_rootfs
    check_space
    update_termux
    install_deps

    if [ -d "${KALI_FS}" ]; then
        echo -e "  ${Y}[!]${N} Un dossier kali-fs existe deja."
        local conf
        read -r -p "$(echo -e "  ${R}[?]${N} Supprimer et reinstaller ? ${W}(oui/non)${N}: ")" conf <&3
        if [ "${conf}" != "oui" ]; then
            echo -e "  ${Y}[!]${N} Installation annulee"
            sleep 1
            return
        fi
        rm -rf "${KALI_FS}"
        log "kali-fs existant supprime avant reinstallation"
    fi

    local rootfs_dest="${HOME}/${ROOTFS_FILE}"
    echo -e "  ${Y}[→]${N} Recherche du miroir disponible..."
    local active_url="" sums_main sums_fb
    sums_main="$(curl -fsSL --max-time 15 "${ROOTFS_URL_BASE}/SHA256SUMS" 2>/dev/null | grep -c "${ROOTFS_FILE}" || true)"
    sums_fb="$(curl -fsSL --max-time 15 "${ROOTFS_URL_FALLBACK}/SHA256SUMS" 2>/dev/null | grep -c "${ROOTFS_FILE}" || true)"
    if [ "${sums_main:-0}" -gt 0 ] 2>/dev/null; then
        active_url="${ROOTFS_URL}"
    elif [ "${sums_fb:-0}" -gt 0 ] 2>/dev/null; then
        active_url="${ROOTFS_URL_FB}"
        echo -e "  ${Y}[!]${N} Miroir principal indisponible — miroir de secours utilise"
    else
        active_url="${ROOTFS_URL_FB}"
        echo -e "  ${Y}[!]${N} SHA256SUMS inaccessible — tentative sur miroir de secours"
    fi
    echo -e "  ${G}[✓]${N} Miroir selectionne"

    if [ -f "${rootfs_dest}" ]; then
        echo -e "  ${Y}[!]${N} Archive deja presente — verification integrite"
        verify_sha256 "${rootfs_dest}"
    else
        echo -e "  ${Y}[→]${N} Telechargement ${ROOTFS_FILE}..."
        log "Telechargement: $active_url"
        if ! curl -fL -C - --progress-bar "${active_url}" -o "${rootfs_dest}"; then
            rm -f "${rootfs_dest}"
            die "Echec du telechargement"
        fi
        verify_sha256 "${rootfs_dest}"
    fi

    echo -e "  ${Y}[→]${N} Extraction du rootfs..."
    mkdir -p "${KALI_FS}"
    local tar_exit=0
    set +e
    tar -xJf "${rootfs_dest}" \
        --warning=no-unknown-keyword \
        --ignore-failed-read \
        --strip-components=1 \
        -C "${KALI_FS}" 2>/dev/null &
    local tar_pid=$!
    while kill -0 "$tar_pid" 2>/dev/null; do
        printf "\r  ${Y}⠋${N} ${W}Extraction rootfs${N} ..."
        sleep 0.09
    done
    wait "$tar_pid" 2>/dev/null
    tar_exit=$?
    set -e
    [ "$tar_exit" -eq 1 ] && tar_exit=0
    [ "$tar_exit" -eq 2 ] && tar_exit=0
    if [ "$tar_exit" -eq 0 ]; then
        printf "\r  ${G}[✓]${N} ${W}Extraction rootfs${N}          \n"
    else
        printf "\r  ${R}[✗]${N} ${W}Extraction rootfs${N} (erreur %d)\n" "$tar_exit"
    fi

    rm -f "${rootfs_dest}"

    if [ "$tar_exit" -ne 0 ] || ! is_installed; then
        rm -rf "${KALI_FS}"
        die "Extraction echouee — kali-fs nettoye"
    fi

    verify_rootfs_integrity
    echo -e "  ${G}[✓]${N} Rootfs extrait et valide"
    log "Rootfs extrait"

    echo -e "  ${Y}[→]${N} Configuration initiale Kali..."
    run_kali_cmd "apt update -y && apt install -y curl wget git python3" &
    real_progress $! "Config initiale" || echo -e "  ${Y}[!]${N} Config initiale partielle — on continue"

    create_launcher
    install_kali_setup

    echo -e "\n  ${G}[→]${N} Configuration du mot de passe de protection"
    set_password

    show_banner
    echo -e "  ${G}${BOLD}╔══════════════════════════════════════════╗${N}"
    echo -e "  ${G}${BOLD}║       INSTALLATION TERMINEE !            ║${N}"
    echo -e "  ${G}${BOLD}╚══════════════════════════════════════════╝${N}\n"
    echo -e "  ${W}Lancer Kali :  ${G}kali${N}"
    echo -e "  ${W}Ce menu     :  ${G}kali-setup${N}"
    echo -e "  ${W}Logs        :  ${G}${LOG_FILE}${N}\n"
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
    echo -e "  ${G}[✓]${N} Kali Linux detecte"
    log "Kali detecte dans $KALI_FS"
    sleep 1
    menu_post
else
    log "Kali non installe"
    menu_install
fi
