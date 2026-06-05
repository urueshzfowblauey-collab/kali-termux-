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

run "apt update -y"
run "apt install -y nmap"
run "apt install -y hydra"
run "apt install -y sqlmap"
run "apt install -y aircrack-ng"
run "apt install -y hashcat"
run "apt install -y john"
run "apt install -y nikto"
run "apt install -y gobuster"
run "apt install -y exploitdb"
run "apt install -y burpsuite"
run "apt install -y tshark"
run "apt install -y metasploit-framework"
run "apt install -y netcat-traditional"
run "apt install -y dirb"
run "apt install -y wfuzz"
run "apt install -y ffuf"
run "apt install -y masscan"
run "apt install -y whois"
run "apt install -y dnsrecon"
run "apt install -y dnsenum"
run "apt install -y enum4linux"
run "apt install -y smbclient"
run "apt autoremove -y && apt clean"
