#!/bin/bash
set -euo pipefail

KALI_FS="${HOME}/kali-fs"

run() {
    local linker="${KALI_FS}/lib/ld-linux-aarch64.so.1"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib/ld-linux-armhf.so.3"
    [ ! -f "$linker" ] && linker="${KALI_FS}/lib64/ld-linux-x86-64.so.2"
    local lname="$(basename "$linker")"
    env -i LD_PRELOAD="" proot \
        --link2symlink -0 \
        -r "${KALI_FS}" \
        -b /dev -b /proc -b /sys -b "${HOME}" \
        -w /root \
        "/lib/${lname}" /bin/bash --login -c \
        "export HOME=/root TERM=xterm-256color LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; $1" 2>/dev/null
}

run "apt update -y && apt upgrade -y"
run "apt install -y curl wget git python3 python3-pip net-tools dnsutils"
run "apt install -y nano vim tmux screen"
run "apt install -y build-essential libssl-dev libffi-dev"
run "pip3 install requests beautifulsoup4 scapy"
run "echo 'export PATH=\$PATH:/usr/local/bin' >> /root/.bashrc"
run "echo 'export TERM=xterm-256color' >> /root/.bashrc"
run "echo 'alias ll=\"ls -la\"' >> /root/.bashrc"
run "echo 'alias cls=\"clear\"' >> /root/.bashrc"
run "apt autoremove -y && apt clean"
