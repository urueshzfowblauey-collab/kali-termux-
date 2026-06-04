<div align="center">

```
██╗  ██╗ █████╗ ██╗     ██╗    ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
██║ ██╔╝██╔══██╗██║     ██║    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
█████╔╝ ███████║██║     ██║       ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
██╔═██╗ ██╔══██║██║     ██║       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
██║  ██╗██║  ██║███████╗██║       ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
```

**Kali Linux sur Android via Termux — sans root**

![Shell](https://img.shields.io/badge/Shell-Bash-red?style=flat-square&logo=gnubash)
![Platform](https://img.shields.io/badge/Platform-Termux%20%2F%20Android-black?style=flat-square&logo=android)
![Arch](https://img.shields.io/badge/Arch-arm64%20%7C%20armhf%20%7C%20amd64-red?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-grey?style=flat-square)

</div>

---

## À propos

**kali-termux** est un script Bash permettant d'installer, gérer et lancer Kali Linux dans Termux via `proot`, sans root, directement sur Android.

Il propose un gestionnaire complet avec menu interactif : installation automatique, outils de sécurité, backup/snapshot, mise à jour automatique du script, et plus encore.

---

## Installation rapide

```bash
curl -fsSL https://raw.githubusercontent.com/urueshzfowblauey-collab/kali-termux-/main/kali-setup.sh -o kali-setup.sh
chmod +x kali-setup.sh
bash kali-setup.sh
```

> Voir le [tutoriel complet](INSTALL.md) pour les détails étape par étape.

---

## Fonctionnalités

- **Installation automatique** — détection d'architecture, téléchargement, vérification SHA256, extraction
- **3 types de rootfs** — Nano (~200 MB), Minimal (~140 MB), Full (~2 GB)
- **Miroir de secours** — bascule automatiquement si le miroir principal est indisponible
- **Outils de sécurité** — nmap, hydra, sqlmap, aircrack-ng, Metasploit, Burp Suite, Hashcat, John...
- **Backup & Snapshot** — sauvegarde et restauration complète de l'environnement
- **Mise à jour automatique** — le script se met à jour lui-même depuis GitHub
- **Protection par mot de passe** — accès au menu sécurisé par hash SHA256 + salt
- **Thèmes** — Red, Blue, Green, Purple
- **Bilingue** — Français / English
- **Logs** — toutes les opérations tracées dans `~/kali-setup.log`

---

## Compatibilité

| Architecture | Statut |
|---|---|
| `arm64` / `aarch64` | ✅ Supporté |
| `armhf` / `armv7` | ✅ Supporté |
| `amd64` / `x86_64` | ✅ Supporté |
| `i386` | ✅ Supporté |

**Android 8.0+** requis. Testé avec Termux (F-Droid).

---

## Outils disponibles

```
nmap · hydra · sqlmap · aircrack-ng · git · python3
burpsuite · tshark · john · hashcat · metasploit-framework
```

> Wireshark GUI non fonctionnel dans proot — `tshark` (CLI) est installé à la place.  
> Metasploit fonctionne mais `msfdb` n'est pas disponible (PostgreSQL/systemd non supportés dans proot).

---

## Utilisation

```bash
kali          # lancer Kali directement
kali-setup    # ouvrir le gestionnaire complet
```

---

## Structure des fichiers

```
~/
├── kali-fs/              # Rootfs Kali Linux
├── kali-setup.log        # Logs
├── kali-snapshots/       # Snapshots
├── .kali-setup.conf      # Configuration (thème, langue, mot de passe)
└── .kali-setup.lock      # Verrou anti-instance-multiple

$PREFIX/bin/
├── kali                  # Launcher rapide
└── kali-setup            # Script gestionnaire
```

---

## Auteur

Créé par **kyaev**

---

## Avertissement

Ce projet est destiné à un usage éducatif et à des fins de test en sécurité informatique sur des systèmes dont vous êtes propriétaire ou pour lesquels vous avez une autorisation explicite. Toute utilisation contraire aux lois en vigueur est sous l'entière responsabilité de l'utilisateur.
