#!/bin/bash
set -euo pipefail

R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
C='\033[0;36m'
W='\033[1;37m'
B='\033[0;34m'
N='\033[0m'

KALI_FS="${HOME}/kali-fs"
LOG_FILE="${HOME}/kali-setup.log"
LOCK_FILE="${HOME}/.kali-setup.lock"
ROOTFS_URL_BASE="https://kali.download/nethunter-images/current/rootfs"
ROOTFS_URL_FALLBACK="https://old.kali.org/nethunter-images/kali-2024.2/rootfs"

trap 'handle_exit $?' EXIT
trap 'echo -e "\n${R}[!] Interruption — etat sauvegarde${N}"; exit 130' INT TERM

handle_exit() {
    local code=$1
    rm -f "${LOCK_FILE}"
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
    echo -e "║             Creator: KYAEV               ║"
    echo -e "╚══════════════════════════════════════════╝${N}"
    echo ""
}

intro_animation() {
    clear
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
    echo -e "${R}╔══════════════════════════════════════════╗"
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
    echo -e "\n${R}╚══════════════════════════════════════════╝${N}"
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
        read -r -t 0.1 _ 2>/dev/null || true
        ((i++)) || true
    done
    wait "$pid"
    local exit_code=$?
    if [ "$exit_code" -eq 0 ]; then
        printf "\r${G}  [✓] %s${N}\n" "$label"
    else
        printf "\r${R}  [✗] %s (erreur $exit_code)${N}\n" "$label"
    fi
    return "$exit_code"
}

check_internet() {
    if curl -I --connect-timeout 10 --max-time 15 https://kali.download > /dev/null 2>&1; then
        echo -e "${G}[✓] Connexion OK${N}"
        log "Internet OK"
    else
        die "Pas de connexion internet"
    fi
}

check_arch() {
    local raw
    raw="$(uname -m)"
    case "$raw" in
        aarch64|armv8l|armv8b) KARCH="arm64" ;;
        armv7l|armv7b|armhf)   KARCH="armhf" ;;
        x86_64)                 KARCH="amd64" ;;
        i686|i386)              KARCH="i386"  ;;
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
        log "check_space: df a echoue"
        return 0
    fi
    if [ "$free_kb" -lt 6000000 ]; then
        die "Espace insuffisant: $(( free_kb / 1024 )) MB libres, 6 GB requis"
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
        read -r -p "$(echo -e "${C}Choix [1-3]: ${N}")" choice
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
    local expected_sha=""
    echo -e "${Y}[→] Verification SHA256...${N}"

    local fname
    fname="$(basename "$file")"
    for sum_url in         "${ROOTFS_URL_BASE}/SHA256SUMS"         "${ROOTFS_URL_FALLBACK}/SHA256SUMS"         "${ROOTFS_URL}.sha256sum"         "${ROOTFS_URL_FB}.sha256sum"; do
        expected_sha="$(curl -fsSL --max-time 10 "$sum_url" 2>/dev/null | grep "$fname" | awk '{print $1}')"
        [ -n "$expected_sha" ] && break
    done

    if [ -z "$expected_sha" ]; then
        echo -e "${Y}[!] SHA256 indisponible — verification ignoree${N}"
        log "SHA256: fichier sum introuvable"
        return 0
    fi

    local actual_sha
    actual_sha="$(sha256sum "$file" | awk '{print $1}')"
    if [ "$expected_sha" = "$actual_sha" ]; then
        echo -e "${G}[✓] SHA256 OK${N}"
        log "SHA256 valide: $actual_sha"
    else
        rm -f "$file"
        die "SHA256 invalide — fichier corrompu ou altere"
    fi
}

install_deps() {
    echo -e "${Y}[→] Installation des dependances...${N}"
    (pkg install -y proot wget curl tar xz-utils 2>&1 | tee -a "${LOG_FILE}" > /dev/null) &
    real_progress $! "Installation dependances" || die "Echec installation dependances"
    echo -e "${G}[✓] Dependances OK${N}"
}

update_termux() {
    local conf
    read -r -p "$(echo -e "${C}[?] Mettre a jour Termux avant installation ? (oui/non): ${N}")" conf
    if [ "${conf}" != "oui" ]; then
        echo -e "${Y}[!] Mise a jour Termux ignoree${N}"
        log "Mise a jour Termux: ignoree par l'utilisateur"
        return 0
    fi
    echo -e "${Y}[→] Mise a jour Termux...${N}"
    (pkg update -y && pkg upgrade -y) >> "${LOG_FILE}" 2>&1 &
    real_progress $! "Mise a jour Termux" || echo -e "${Y}[!] Mise a jour Termux partielle — on continue${N}"
}

run_kali() {
    need_cmd proot
    exec proot \
        --link2symlink \
        -0 \
        -r "${KALI_FS}" \
        -b /dev \
        -b /proc \
        -b /sys \
        -b "${HOME}" \
        -w /root \
        /usr/bin/env -i \
            HOME=/root \
            TERM="${TERM:-xterm-256color}" \
            LANG=C.UTF-8 \
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/bash --login
}

run_kali_cmd() {
    local cmd="$1"
    proot \
        --link2symlink \
        -0 \
        -r "${KALI_FS}" \
        -b /dev -b /proc -b /sys -b "${HOME}" \
        -w /root \
        /usr/bin/env -i \
            HOME=/root TERM=xterm-256color LANG=C.UTF-8 \
            DEBIAN_FRONTEND=noninteractive \
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/bash --login -c "$cmd" >> "${LOG_FILE}" 2>&1
    return $?
}

create_launcher() {
    local launcher="${PREFIX}/bin/kali"
    local kali_fs_path="${KALI_FS}"
    cat > "${launcher}" << LAUNCHER
#!/bin/bash
KALI_FS="${kali_fs_path}"
if [ ! -d "\${KALI_FS}" ]; then
    echo "Erreur: kali-fs introuvable dans \${KALI_FS}"
    exit 1
fi
exec proot \\
    --link2symlink -0 \\
    -r "\${KALI_FS}" \\
    -b /dev -b /proc -b /sys -b "\${HOME}" \\
    -w /root \\
    /usr/bin/env -i \\
        HOME=/root TERM="\${TERM:-xterm-256color}" LANG=C.UTF-8 \\
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \\
    /bin/bash --login
LAUNCHER
    chmod 700 "${launcher}"
    log "Launcher cree: $launcher"
}

install_kali_setup() {
    local setup_dest="${PREFIX}/bin/kali-setup"
    local src=""

    # Si le script a ete sauvegarde dans un vrai fichier
    if [ -f "$0" ] && [ "$0" != "bash" ] && [ "$0" != "/proc/self/fd/0" ]; then
        src="$0"
    fi

    if [ -n "$src" ]; then
        if cp "$src" "${setup_dest}" 2>/dev/null; then
            chmod 700 "${setup_dest}"
            log "kali-setup copie depuis $src"
        else
            echo -e "${Y}[!] Impossible de copier kali-setup${N}"
            log "kali-setup: copie echouee"
        fi
    else
        echo -e "${Y}[!] Script execute via pipe — kali-setup non installe automatiquement${N}"
        echo -e "${Y}    Telechargez-le manuellement: curl -sL <url> -o \${PREFIX}/bin/kali-setup && chmod 700 \${PREFIX}/bin/kali-setup${N}"
        log "kali-setup: script execute via pipe, copie impossible"
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
        ((i++)) || true
    done < <(find "${snap_dir}" -name "snap-*.tar.gz" -print0 | sort -z)
    echo ""
    local choice
    read -r -p "$(echo -e "${C}Numero de snapshot: ${N}")" choice
    if [ -z "${snaps[$((choice-1))]+x}" ]; then
        echo -e "${R}[-] Choix invalide${N}"; sleep 2; return
    fi
    local selected="${snaps[$((choice-1))]}"

    echo -e "${Y}[→] Verification integrite de l'archive...${N}"
    if ! tar -tzf "${selected}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi

    local conf
    read -r -p "$(echo -e "${R}[!] Cette action ecrase kali-fs. Continuer ? (oui/non): ${N}")" conf
    [ "${conf}" = "oui" ] || { echo -e "${Y}[!] Annule${N}"; sleep 1; return; }

    echo -e "${Y}[→] Restauration de $(basename "$selected")...${N}"
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
    echo -e "${G}[✓] Backup OK: $backup${N}"
    log "Backup: $backup"
    sleep 2
}

restore_kali() {
    local backup_file
    read -r -p "$(echo -e "${C}Chemin du backup: ${N}")" backup_file
    if [ ! -f "${backup_file}" ]; then
        echo -e "${R}[-] Fichier introuvable: ${backup_file}${N}"
        sleep 2; return
    fi

    echo -e "${Y}[→] Verification integrite de l'archive...${N}"
    if ! tar -tzf "${backup_file}" > /dev/null 2>&1; then
        die "Archive corrompue — restauration annulee"
    fi

    local conf
    read -r -p "$(echo -e "${R}[!] Cette action ecrase kali-fs. Continuer ? (oui/non): ${N}")" conf
    [ "${conf}" = "oui" ] || { echo -e "${Y}[!] Annule${N}"; sleep 1; return; }

    echo -e "${Y}[→] Restauration...${N}"
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
    echo -e "${Y}[→] Installation outils de base...${N}"
    run_kali_cmd "apt update -y && apt install -y nmap hydra sqlmap aircrack-ng curl wget git python3 python3-pip" &
    real_progress $! "Outils de base" || die "Echec installation outils — voir ${LOG_FILE}"

    echo -e "${Y}[→] Tentative installation metasploit-framework (optionnel)...${N}"
    if run_kali_cmd "apt install -y metasploit-framework" 2>/dev/null; then
        echo -e "${G}[✓] Metasploit installe${N}"
        log "Metasploit installe"
    else
        echo -e "${Y}[!] Metasploit indisponible sur ce rootfs — ignore${N}"
        log "Metasploit: package introuvable"
    fi

    echo -e "${G}[✓] Outils installes${N}"
    log "Outils supplementaires installes"
    sleep 2
}

uninstall_kali() {
    show_banner
    local conf
    read -r -p "$(echo -e "${R}[!] Confirmer la desinstallation ? (oui/non): ${N}")" conf
    if [ "${conf}" = "oui" ]; then
        rm -rf "${KALI_FS}"
        rm -f "${PREFIX}/bin/kali" "${PREFIX}/bin/kali-setup"
        echo -e "${G}[✓] Kali desinstalle${N}"
        log "Kali desinstalle"
        sleep 2
        show_banner
        menu_install
    fi
}

is_installed() {
    [ -f "${KALI_FS}/bin/bash" ] || \
    [ -f "${KALI_FS}/usr/bin/bash" ] || \
    [ -f "${KALI_FS}/bin/sh" ]
}

menu_post() {
    local choice
    while true; do
        show_banner
        echo -e "${R}╔══════════════════════════════════════════╗"
        echo -e "║            MENU PRINCIPAL                ║"
        echo -e "╚══════════════════════════════════════════╝${N}"
        echo -e "${C}[1]${W} Lancer Kali Linux"
        echo -e "${C}[2]${W} Mettre a jour Kali"
        echo -e "${C}[3]${W} Installer outils supplementaires"
        echo -e "${C}[4]${W} Backup"
        echo -e "${C}[5]${W} Restaurer backup"
        echo -e "${C}[6]${W} Snapshot"
        echo -e "${C}[7]${W} Restaurer snapshot"
        echo -e "${C}[8]${W} Desinstaller Kali"
        echo -e "${C}[9]${W} Quitter"
        echo ""
        read -r -p "$(echo -e "${C}[?] Choix: ${N}")" choice
        case "$choice" in
            1) run_kali ;;
            2) update_kali ;;
            3) install_tools ;;
            4) backup_kali ;;
            5) restore_kali ;;
            6) snapshot ;;
            7) restore_snapshot ;;
            8) uninstall_kali ;;
            9) echo -e "${R}[!] Bye!${N}"; log "Quitte"; exit 0 ;;
            *) echo -e "${R}[-] Invalide${N}"; sleep 1 ;;
        esac
    done
}

menu_install() {
    local choice
    while true; do
        show_banner
        echo -e "${R}╔══════════════════════════════════════════╗"
        echo -e "║          MENU INSTALLATION               ║"
        echo -e "╚══════════════════════════════════════════╝${N}"
        echo -e "${C}[1]${W} Installation automatique complete"
        echo -e "${C}[2]${W} Quitter"
        echo ""
        read -r -p "$(echo -e "${C}[?] Choix: ${N}")" choice
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

    if [ -f "${LOCK_FILE}" ]; then
        die "Installation deja en cours (lock: ${LOCK_FILE})"
    fi
    touch "${LOCK_FILE}"

    check_internet
    check_arch
    check_space
    choose_rootfs
    update_termux
    install_deps

    local rootfs_dest="${HOME}/${ROOTFS_FILE}"

    echo -e "${Y}[→] Verification disponibilite du rootfs...${N}"
    local active_url=""
    if curl -fsI --max-time 15 "${ROOTFS_URL}" > /dev/null 2>&1; then
        active_url="${ROOTFS_URL}"
    elif curl -fsI --max-time 15 "${ROOTFS_URL_FB}" > /dev/null 2>&1; then
        active_url="${ROOTFS_URL_FB}"
        echo -e "${Y}[!] Miroir principal indisponible — utilisation du miroir de secours${N}"
    else
        die "Rootfs introuvable: ${ROOTFS_FILE} absent des deux miroirs"
    fi
    echo -e "${G}[✓] Rootfs disponible${N}"

    if [ -f "${rootfs_dest}" ]; then
        echo -e "${Y}[!] Archive deja presente — verification integrite${N}"
        verify_sha256 "${rootfs_dest}"
    else
        echo -e "${Y}[→] Telechargement ${ROOTFS_FILE}...${N}"
        log "Telechargement: $active_url"
        if ! curl -fL --progress-bar "${active_url}" -o "${rootfs_dest}"; then
            rm -f "${rootfs_dest}"
            die "Echec du telechargement"
        fi
        verify_sha256 "${rootfs_dest}"
    fi

    echo -e "${Y}[→] Extraction du rootfs...${N}"
    mkdir -p "${KALI_FS}"

    (proot \
        --link2symlink \
        /usr/bin/env tar \
        -xJf "${rootfs_dest}" \
        --warning=no-unknown-keyword \
        --strip-components=1 \
        -C "${KALI_FS}" 2>/dev/null) &
    local tar_pid=$!
    real_progress $tar_pid "Extraction rootfs"
    local tar_exit=$?

    rm -f "${rootfs_dest}"

    if [ "$tar_exit" -ne 0 ] || ! is_installed; then
        echo -e "${R}[!] Extraction echouee — nettoyage...${N}"
        rm -rf "${KALI_FS}"
        die "Extraction echouee — kali-fs nettoye"
    fi

    echo -e "${G}[✓] Rootfs extrait${N}"
    log "Rootfs extrait"

    echo -e "${Y}[→] Configuration initiale Kali...${N}"
    run_kali_cmd "apt update -y && apt install -y curl wget git python3" &
    real_progress $! "Config initiale" || echo -e "${Y}[!] Config initiale partielle — on continue${N}"

    create_launcher
    install_kali_setup

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

intro_animation
install_kali_setup

if is_installed; then
    echo -e "${G}[✓] Kali Linux detecte${N}"
    log "Kali detecte dans $KALI_FS"
    sleep 1
    menu_post
else
    log "Kali non installe"
    menu_install
fi
