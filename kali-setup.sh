import os
import sys
import time
import subprocess
import threading
import itertools

os.system("clear")

RED     = "\033[38;2;215;0;0m"
DRED    = "\033[38;2;140;0;0m"
WHITE   = "\033[38;2;255;255;255m"
GRAY    = "\033[38;2;160;160;160m"
DGRAY   = "\033[38;2;80;80;80m"
CYAN    = "\033[38;2;0;255;210m"
YELLOW  = "\033[38;2;255;215;0m"
BOLD    = "\033[1m"
DIM     = "\033[2m"
RESET   = "\033[0m"
BLINK   = "\033[5m"
CLEAR   = "\033[2J\033[H"

KALI_ASCII = f"""
{DRED}⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
{RED}⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
{RED}⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
{RED}⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸{WHITE}⣿⣷⣶⣦⣤⣄⣈⡑{RED}⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀
{RED}⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀{WHITE}⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿{WHITE}⣿⣮{RED}⣷⣤⠀⠀⠀⠀⠀⠀
{RED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀{WHITE}⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉{WHITE}⢻⣯{RED}⣧⡀⠀⠀⠀⠀
{RED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻{RED}⢷⡤⠀⠀⠀
{RED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{RED}⠀⠀⠀
{RED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠈⠻⣿⣦⣤⣀⡀{RED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠉⠙⠛⠛⠻⠿⠿{WHITE}⣿⣶⣶⣦⣄⣀{DRED}⠀⠀⠀⠀⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠉⠻⣿⣯⡛{DRED}⠻⢦⡀⠀⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠈⠙⢿⣆{DRED}⠀⠙⢆⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠈⢻⣆{DRED}⠀⠈⢣
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠻⡆{DRED}⠀⠈
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⢻⡀{DRED}⠀
{DRED}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀{WHITE}⠈⠃{DRED}⠀{RESET}"""

def glitch_text(text, color=RED):
    chars = list(text)
    glitch_chars = "█▓▒░▄▀▐▌│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌"
    result = ""
    for i, c in enumerate(chars):
        if c != " " and (i % 7 == 0):
            result += f"{DGRAY}{glitch_chars[i % len(glitch_chars)]}{color}"
        else:
            result += c
    return f"{color}{result}{RESET}"

def vfx_boot():
    os.system("clear")
    lines = [
        f"{DGRAY}[SYS] {GRAY}Initialisation du système...{RESET}",
        f"{DGRAY}[CPU] {GRAY}Architecture ARM détectée{RESET}",
        f"{DGRAY}[MEM] {GRAY}Allocation mémoire en cours...{RESET}",
        f"{DGRAY}[NET] {GRAY}Interface réseau active{RESET}",
        f"{DGRAY}[ENV] {GRAY}Termux environment OK{RESET}",
        f"{DGRAY}[SEC] {GRAY}Chiffrement activé{RESET}",
    ]
    for line in lines:
        print(line)
        time.sleep(0.12)
    time.sleep(0.3)

    os.system("clear")
    full = KALI_ASCII
    for i, char in enumerate(full):
        sys.stdout.write(char)
        sys.stdout.flush()
        if char == "\n":
            time.sleep(0.015)

    time.sleep(0.4)

    title_line = f"\n{BOLD}{RED}  ██╗  ██╗ █████╗ ██╗     ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗{RESET}"
    sub_line   = f"{DIM}{GRAY}            by {CYAN}creator kyaev{RESET}\n"

    for c in title_line:
        sys.stdout.write(c)
        sys.stdout.flush()
        time.sleep(0.004)
    print()
    for c in sub_line:
        sys.stdout.write(c)
        sys.stdout.flush()
        time.sleep(0.004)
    print()

    bar_len = 38
    print(f"  {DGRAY}┌{'─'*bar_len}┐{RESET}")
    sys.stdout.write(f"  {DGRAY}│{RESET} {RED}")
    for i in range(bar_len - 2):
        sys.stdout.write("█")
        sys.stdout.flush()
        time.sleep(0.03)
    sys.stdout.write(f"{RESET} {DGRAY}│{RESET}\n")
    print(f"  {DGRAY}└{'─'*bar_len}┘{RESET}")
    print(f"\n  {GRAY}Chargement terminé.{RESET}")
    time.sleep(0.6)

def spinner_task(msg, stop_event, duration=None):
    frames = ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"]
    start = time.time()
    i = 0
    while not stop_event.is_set():
        sys.stdout.write(f"\r  {RED}{frames[i % len(frames)]}{RESET} {GRAY}{msg}{RESET}   ")
        sys.stdout.flush()
        time.sleep(0.08)
        i += 1
        if duration and (time.time() - start) >= duration:
            break
    sys.stdout.write(f"\r  {CYAN}✔{RESET} {WHITE}{msg}{RESET}          \n")
    sys.stdout.flush()

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return result.returncode == 0

def install_kali():
    os.system("clear")
    print(KALI_ASCII)
    print(f"\n{BOLD}{RED}  [ INSTALLATION KALI LINUX ]{RESET}\n")
    print(f"  {DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}\n")

    steps = [
        ("Mise à jour des paquets",        "pkg update -y && pkg upgrade -y"),
        ("Installation de proot-distro",   "pkg install proot-distro -y"),
        ("Téléchargement de Kali Linux",   "proot-distro install kali"),
        ("Configuration de l'environnement","proot-distro login kali -- apt update -y"),
        ("Installation des outils de base","proot-distro login kali -- apt install -y kali-tools-top10 2>/dev/null || true"),
    ]

    for msg, cmd in steps:
        stop = threading.Event()
        t = threading.Thread(target=spinner_task, args=(msg, stop))
        t.start()
        success = run_cmd(cmd)
        stop.set()
        t.join()
        if not success:
            print(f"  {YELLOW}⚠ {msg} — ignoré (continuer){RESET}")
        time.sleep(0.1)

    print(f"\n  {DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}")
    print(f"\n  {BOLD}{RED}✔ Kali Linux installé avec succès !{RESET}\n")
    input(f"  {DGRAY}[ Appuie sur Entrée pour continuer ]{RESET}")
    main_menu()

def launch_kali():
    os.system("clear")
    print(KALI_ASCII)
    print(f"\n  {BOLD}{RED}[ LANCEMENT KALI LINUX ]{RESET}\n")
    stop = threading.Event()
    t = threading.Thread(target=spinner_task, args=("Démarrage de l'environnement Kali...", stop, 1.5))
    t.start()
    time.sleep(1.5)
    stop.set()
    t.join()
    time.sleep(0.2)
    print(f"\n  {CYAN}Connexion à Kali Linux...{RESET}\n")
    time.sleep(0.5)
    os.system("proot-distro login kali")
    main_menu()

def extra_tools():
    os.system("clear")
    print(KALI_ASCII)
    print(f"\n{BOLD}{RED}  [ TOOLS SUPPLÉMENTAIRES ]{RESET}\n")
    print(f"  {DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}\n")

    tools = [
        ("nmap",       "proot-distro login kali -- apt install -y nmap"),
        ("metasploit", "proot-distro login kali -- apt install -y metasploit-framework"),
        ("sqlmap",     "proot-distro login kali -- apt install -y sqlmap"),
        ("hydra",      "proot-distro login kali -- apt install -y hydra"),
        ("wireshark",  "proot-distro login kali -- apt install -y wireshark"),
    ]

    for i, (name, _) in enumerate(tools, 1):
        print(f"  {RED}[{i}]{RESET} {WHITE}{name}{RESET}")
    print(f"  {DGRAY}[0] Retour{RESET}")
    print(f"\n  {DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}")

    choice = input(f"\n  {GRAY}Choix >{RESET} ").strip()

    if choice == "0":
        main_menu()
        return

    try:
        idx = int(choice) - 1
        if 0 <= idx < len(tools):
            name, cmd = tools[idx]
            stop = threading.Event()
            t = threading.Thread(target=spinner_task, args=(f"Installation de {name}...", stop))
            t.start()
            run_cmd(cmd)
            stop.set()
            t.join()
            print(f"\n  {CYAN}✔ {name} installé.{RESET}")
            time.sleep(1)
    except ValueError:
        pass

    input(f"\n  {DGRAY}[ Entrée pour continuer ]{RESET}")
    extra_tools()

def uninstall_kali():
    os.system("clear")
    print(KALI_ASCII)
    print(f"\n{BOLD}{RED}  [ DÉSINSTALLATION KALI LINUX ]{RESET}\n")
    print(f"  {YELLOW}⚠  Cette action supprimera Kali Linux et toutes ses données.{RESET}")
    confirm = input(f"\n  {GRAY}Confirmer ? (oui/non) >{RESET} ").strip().lower()

    if confirm == "oui":
        stop = threading.Event()
        t = threading.Thread(target=spinner_task, args=("Suppression en cours...", stop, 2.5))
        t.start()
        run_cmd("proot-distro remove kali")
        stop.set()
        t.join()
        print(f"\n  {RED}✔ Kali Linux désinstallé.{RESET}\n")
        time.sleep(1.5)
        sys.exit(0)
    else:
        main_menu()

def main_menu():
    os.system("clear")
    print(KALI_ASCII)
    print(f"{BOLD}{RED}  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄{RESET}")
    print(f"{RED}  █  {WHITE}KALI LINUX — TERMUX MANAGER{RED}                █{RESET}")
    print(f"{RED}  █  {DIM}{GRAY}creator kyaev{RESET}{RED}                              █{RESET}")
    print(f"{BOLD}{RED}  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀{RESET}\n")

    options = [
        ("1", "Lance Kali Linux",         "▶"),
        ("2", "Tools supplémentaires",    "⚙"),
        ("3", "Désinstaller Kali Linux",  "✖"),
        ("0", "Quitter",                  "⏻"),
    ]

    for key, label, icon in options:
        color = RED if key != "0" else DGRAY
        print(f"  {color}[{key}]{RESET}  {icon}  {WHITE if key != '0' else GRAY}{label}{RESET}")

    print(f"\n  {DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}")
    choice = input(f"\n  {GRAY}Choix >{RESET} ").strip()

    if choice == "1":
        launch_kali()
    elif choice == "2":
        extra_tools()
    elif choice == "3":
        uninstall_kali()
    elif choice == "0":
        os.system("clear")
        sys.exit(0)
    else:
        main_menu()

def check_install():
    result = subprocess.run("proot-distro list | grep kali", shell=True,
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return b"kali" in result.stdout

if __name__ == "__main__":
    try:
        vfx_boot()
        if not check_install():
            os.system("clear")
            print(KALI_ASCII)
            print(f"\n  {YELLOW}⚠  Kali Linux n'est pas installé.{RESET}")
            ans = input(f"  {GRAY}Lancer l'installation ? (oui/non) >{RESET} ").strip().lower()
            if ans == "oui":
                install_kali()
            else:
                main_menu()
        else:
            main_menu()
    except KeyboardInterrupt:
        print(f"\n\n  {DGRAY}Fermeture...{RESET}\n")
        sys.exit(0)
