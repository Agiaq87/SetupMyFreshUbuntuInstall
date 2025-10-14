#!/bin/bash

show_security_menu() {
    log INFO "Opening security and penetration testing tools menu..."
    # Define available software (format: id|name|description)
    local security_items=(
        # Network Analysis & Scanning
        "nmap|Nmap|Network exploration and security auditing"
        "zenmap|Zenmap|GUI for Nmap"
        "wireshark|Wireshark|Network protocol analyzer"
        "tcpdump|tcpdump|Command-line packet analyzer"
        "ettercap|Ettercap|Network security tool for MITM attacks"
        "bettercap|Bettercap|Swiss Army knife for network attacks and monitoring"
        "netcat|Netcat|Networking utility for reading/writing network connections"
        "masscan|Masscan|Fast TCP port scanner"
        "angry-ip-scanner|Angry IP Scanner|Fast network scanner"
        
        # Vulnerability Scanning
        "nikto|Nikto|Web server scanner"
        "openvas|OpenVAS|Vulnerability scanner and manager"
        "lynis|Lynis|Security auditing tool for Unix systems"
        "chkrootkit|chkrootkit|Rootkit detector"
        "rkhunter|rkhunter|Rootkit hunter"
        "clamav|ClamAV|Antivirus engine"
        
        # Web Application Testing
        "burpsuite|Burp Suite Community|Web vulnerability scanner"
        "owasp-zap|OWASP ZAP|Web application security scanner"
        "sqlmap|SQLMap|Automatic SQL injection tool"
        "wpscan|WPScan|WordPress security scanner"
        "dirb|DIRB|Web content scanner"
        "dirbuster|DirBuster|Web application fuzzer"
        "gobuster|Gobuster|Directory/file & DNS busting tool"
        "ffuf|ffuf|Fast web fuzzer"
        "wfuzz|Wfuzz|Web application fuzzer"
        "nikto|Nikto|Web server scanner"
        
        # Password Cracking & Analysis
        "john|John the Ripper|Password cracking tool"
        "hashcat|Hashcat|Advanced password recovery"
        "hydra|Hydra|Network logon cracker"
        "medusa|Medusa|Speedy parallel password cracker"
        "crunch|Crunch|Wordlist generator"
        "cewl|CeWL|Custom wordlist generator"
        
        # Wireless Security
        "aircrack-ng|Aircrack-ng|WiFi security auditing tools suite"
        "reaver|Reaver|WPS brute force attack tool"
        "kismet|Kismet|Wireless network detector and sniffer"
        "wifite|Wifite|Automated wireless attack tool"
        "fern-wifi-cracker|Fern WiFi Cracker|Wireless security auditing"
        
        # Exploitation Frameworks
        "metasploit|Metasploit Framework|Penetration testing framework"
        "armitage|Armitage|GUI for Metasploit"
        "exploitdb|ExploitDB|Archive of exploits and vulnerable software"
        "searchsploit|SearchSploit|ExploitDB search tool"
        
        # Social Engineering
        "set|Social-Engineer Toolkit|Social engineering penetration testing"
        "beef|BeEF|Browser Exploitation Framework"
        
        # Forensics & Analysis
        "autopsy|Autopsy|Digital forensics platform"
        "sleuthkit|The Sleuth Kit|Digital investigation tools"
        "foremost|Foremost|File recovery tool"
        "binwalk|Binwalk|Firmware analysis tool"
        "volatility|Volatility|Memory forensics framework"
        "bulk-extractor|bulk_extractor|Digital forensics tool"
        
        # Reverse Engineering
        "ghidra|Ghidra|Software reverse engineering framework"
        "radare2|Radare2|Reverse engineering framework"
        "cutter|Cutter|GUI for Radare2"
        "ida-free|IDA Free|Disassembler and debugger"
        "gdb|GDB|GNU Debugger"
        "edb|EDB|Cross-platform debugger"
        "hopper|Hopper|Reverse engineering tool"
        
        # Cryptography
        "hashid|HashID|Identify hash types"
        "hash-identifier|Hash Identifier|Identify different types of hashes"
        "steghide|Steghide|Steganography program"
        "stegcracker|StegCracker|Steganography brute-force tool"
        "outguess|OutGuess|Steganographic tool"
        "openssl|OpenSSL|Cryptography toolkit"
        
        # OSINT (Open Source Intelligence)
        "maltego|Maltego|OSINT and forensics application"
        "theharvester|theHarvester|E-mail, subdomain, and people name harvester"
        "recon-ng|Recon-ng|Web reconnaissance framework"
        "sherlock|Sherlock|Hunt down social media accounts"
        "spiderfoot|SpiderFoot|OSINT automation tool"
        "exiftool|ExifTool|Read and write meta information in files"
        
        # Anonymity & Privacy
        "tor-browser|Tor Browser|Anonymous web browser"
        "proxychains|ProxyChains|Redirect connections through proxy servers"
        "macchanger|MAC Changer|Change MAC address"
        "veracrypt|VeraCrypt|Disk encryption software"
        
        # Sniffing & Spoofing
        "arpspoof|ARPSpoof|ARP spoofing tool"
        "dnsspoof|DNSSpoof|DNS spoofing tool"
        "mitmproxy|mitmproxy|Interactive HTTPS proxy"
        "sslsplit|SSLsplit|Transparent SSL/TLS interception"
        
        # Information Gathering
        "whois|WHOIS|Domain information lookup"
        "dnsutils|DNS Utils|DNS utilities (dig, nslookup, etc.)"
        "traceroute|Traceroute|Network diagnostic tool"
        "netdiscover|Netdiscover|Active/passive network address scanner"
        "arp-scan|arp-scan|ARP scanning and fingerprinting tool"
        
        # Reporting Tools
        "dradis|Dradis|Collaboration and reporting platform"
        "faraday|Faraday|Collaborative penetration test IDE"
        "pipal|Pipal|Password analysis tool"
        
        # Mobile Security
        "apktool|APKTool|Tool for reverse engineering Android APK files"
        "androguard|Androguard|Reverse engineering and analysis for Android"
        "mobsf|Mobile Security Framework|Mobile app security testing"
        
        # Additional Security Tools
        "checksec|checksec|Check security properties of executables"
        "pwntools|pwntools|CTF framework and exploit development"
        "pwndbg|pwndbg|GDB plugin for exploit development"
        "gef|GEF|GDB Enhanced Features"
        "yara|YARA|Pattern matching for malware research"
        "snort|Snort|Network intrusion detection system"
        "suricata|Suricata|Network security monitoring engine"
        "fail2ban|Fail2Ban|Ban IPs that show malicious signs"
        "apparmor|AppArmor|Mandatory Access Control framework"
        "selinux|SELinux|Security-Enhanced Linux"
        
        # Virtual Machines for Security Testing
        "kali-linux|Kali Linux VM|Full Kali Linux in virtual machine"
        "parrot-os|Parrot OS VM|Parrot Security OS in virtual machine"

        "wash|Wash|WPS scanner (part of Reaver suite)"
        "pixiewps|PixieWPS|WPS Pixie Dust attack tool"
        "bully|Bully|WPS brute force attack (alternative to Reaver)"
        "mdk4|MDK4|Wireless stress testing and DoS tool"
        "mdk3|MDK3|Wireless stress testing tool (older version)"
        "cowpatty|Cowpatty|WPA-PSK dictionary attack tool"
        "pyrit|Pyrit|GPU-accelerated WPA/WPA2-PSK cracker"
        "hcxdumptool|hcxdumptool|Capture packets for hashcat"
        "hcxtools|hcxtools|Convert captures to hashcat format"
        "eaphammer|EAPHammer|Targeted WPA2-Enterprise attacks"
        "hostapd-wpe|hostapd-wpe|Rogue AP for WPA-Enterprise attacks"
        "fluxion|Fluxion|Automated MITM WPA attack"
        "linset|Linset|Evil twin attack automation"
        "wifi-pumpkin|WiFi-Pumpkin3|Rogue AP framework"
        "mana|MANA Toolkit|Rogue AP attacks"
        "evilginx|Evilginx2|Advanced phishing framework"
        "wifiphisher|Wifiphisher|Automated phishing attacks on WiFi"
        "airgeddon|Airgeddon|Multi-use bash script for WiFi auditing"
        "iw|iw|Wireless configuration tool"
        "wavemon|Wavemon|Wireless network monitor"
        "horst|HORST|Lightweight wireless LAN analyzer"
        "wifi-radar|WiFi Radar|Graphical WiFi connection manager"

        # Long-Range & Directional Antenna Tools
        "wifi-arsenal|WiFi Arsenal|Collection of WiFi tools and scripts"
        "spectools|Spectrum-Tools|Spectrum analyzer for wireless"
        "kismet-logtools|Kismet Log Tools|Tools for analyzing Kismet logs"
        "gqrx|GQRX|Software defined radio receiver"
        "rtl-sdr|RTL-SDR|Software defined radio tools"
        "hackrf|HackRF Tools|HackRF One software tools"

        # GPS & Wardriving
        "gpsd|GPSd|GPS service daemon"
        "gpsd-clients|GPS Clients|GPS client tools (xgps, cgps)"
        "kismet-plugins|Kismet Plugins|Additional Kismet functionality"
        "wigle-wifi|WiGLE WiFi|Wardriving data upload client"

        # Bluetooth Security (bonus per adattatori BT)
        "bluez|BlueZ|Official Linux Bluetooth stack"
        "bluez-tools|BlueZ Tools|Bluetooth utilities"
        "blueman|Blueman|Bluetooth manager GUI"
        "bluehydra|Blue Hydra|Bluetooth device discovery"
        "btscanner|BTScanner|Bluetooth device scanner"
        "spooftooph|SpoofTooph|Bluetooth spoofing tool"
        "redfang|RedFang|Hidden Bluetooth device finder"
        "bluesnarfer|BlueSnarfer|Bluetooth attack tool"
        "obexftp|ObexFTP|File transfer over Bluetooth"

        # RFID/NFC Tools (se hai anche lettori NFC)
        "libnfc|libnfc|NFC library and tools"
        "mfoc|MFOC|Mifare Classic offline cracker"
        "mfcuk|MFCUK|Mifare Classic universal key recovery"
        "proxmark3|Proxmark3|RFID research toolkit"

        # Additional Network Monitoring
        "arp-watch|arpwatch|Ethernet/IP address monitoring"
        "darkstat|darkstat|Network statistics gatherer"
        "ntopng|ntopng|Network traffic probe and monitor"
        "vnstat|vnStat|Network traffic monitor"
        "iftop|iftop|Display bandwidth usage"
        "nethogs|NetHogs|Network traffic per process"
        "bandwhich|bandwhich|Terminal bandwidth utilization tool"
    )
    
    # Show checklist
    local choices
    choices=$(show_checklist "Security Tools Selection" "Choose security and penetration testing tools to install:" "${security_items[@]}")
    
    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Security tools selection cancelled"
        return
    fi
    
    log INFO "Selected security tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"
    
    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"
        
        case $choice in
            # Network Analysis & Scanning
            "nmap")
                install_package_secure "Nmap" "nmap" "nala" "Network scanner" || log WARN "Nmap installation failed, continuing..."
                ;;
            "zenmap")
                install_package_secure "Zenmap" "zenmap" "nala" "Nmap GUI" || log WARN "Zenmap installation failed, continuing..."
                ;;
            "wireshark")
                install_package_secure "Wireshark" "wireshark" "nala" "Network analyzer" || log WARN "Wireshark installation failed, continuing..."
                # Add user to wireshark group
                sudo usermod -aG wireshark $USER
                log INFO "User added to wireshark group (requires logout to take effect)"
                ;;
            "tcpdump")
                install_package_secure "tcpdump" "tcpdump" "nala" "Packet analyzer" || log WARN "tcpdump installation failed, continuing..."
                ;;
            "ettercap")
                install_package_secure "Ettercap" "ettercap-graphical" "nala" "MITM attack tool" || log WARN "Ettercap installation failed, continuing..."
                ;;
            "bettercap")
                install_package_secure "Bettercap" "bettercap" "nala" "Network attack tool" || log WARN "Bettercap installation failed, continuing..."
                ;;
            "netcat")
                install_package_secure "Netcat" "netcat-openbsd" "nala" "Networking utility" || log WARN "Netcat installation failed, continuing..."
                ;;
            "masscan")
                install_package_secure "Masscan" "masscan" "nala" "Fast port scanner" || log WARN "Masscan installation failed, continuing..."
                ;;
            "angry-ip-scanner")
                log INFO "Installing Angry IP Scanner..."
                local angryip_url=$(curl -s https://api.github.com/repos/angryip/ipscan/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local angryip_deb="/tmp/angryip.deb"
                
                wget -O "$angryip_deb" "$angryip_url" 2>&1 | \
                    zenity --progress --title="Downloading Angry IP Scanner" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$angryip_deb" ]; then
                    install_package_secure "Angry IP Scanner" "$angryip_deb" "nala" "Network scanner" || log WARN "Angry IP Scanner installation failed, continuing..."
                    rm -f "$angryip_deb"
                else
                    log ERROR "Failed to download Angry IP Scanner"
                fi
                ;;
            
            # Vulnerability Scanning
            "nikto")
                install_package_secure "Nikto" "nikto" "nala" "Web server scanner" || log WARN "Nikto installation failed, continuing..."
                ;;
            "openvas")
                show_message "Info" "OpenVAS installation is complex and requires specific setup.\n\nRecommended: Install using Docker:\nsudo docker run -d -p 443:443 --name openvas mikesplain/openvas\n\nOr visit: https://www.openvas.org/"
                ;;
            "lynis")
                install_package_secure "Lynis" "lynis" "nala" "Security auditing tool" || log WARN "Lynis installation failed, continuing..."
                ;;
            "chkrootkit")
                install_package_secure "chkrootkit" "chkrootkit" "nala" "Rootkit detector" || log WARN "chkrootkit installation failed, continuing..."
                ;;
            "rkhunter")
                install_package_secure "rkhunter" "rkhunter" "nala" "Rootkit hunter" || log WARN "rkhunter installation failed, continuing..."
                ;;
            "clamav")
                install_package_secure "ClamAV" "clamav clamav-daemon" "nala" "Antivirus engine" || log WARN "ClamAV installation failed, continuing..."
                sudo freshclam  # Update virus definitions
                ;;
            
            # Web Application Testing
            "burpsuite")
                show_message "Manual Installation" "Burp Suite Community requires manual installation:\n\n1. Visit: https://portswigger.net/burp/communitydownload\n2. Download Linux version\n3. Run the installer script\n\nNote: Free Community edition available."
                xdg-open "https://portswigger.net/burp/communitydownload" 2>/dev/null &
                ;;
            "owasp-zap")
                install_package_secure "OWASP ZAP" "zaproxy" "snap" "Web app scanner" || log WARN "OWASP ZAP installation failed, continuing..."
                ;;
            "sqlmap")
                install_package_secure "SQLMap" "sqlmap" "nala" "SQL injection tool" || log WARN "SQLMap installation failed, continuing..."
                ;;
            "wpscan")
                log INFO "Installing WPScan..."
                sudo gem install wpscan 2>&1 | \
                    zenity --progress --title="Installing WPScan" --text="Installing..." --pulsate --auto-close
                
                if command -v wpscan &> /dev/null; then
                    log INFO "WPScan installed successfully"
                    show_notification "Installation completed" "WPScan installed!"
                else
                    log WARN "WPScan installation failed, continuing..."
                fi
                ;;
            "dirb")
                install_package_secure "DIRB" "dirb" "nala" "Web content scanner" || log WARN "DIRB installation failed, continuing..."
                ;;
            "dirbuster")
                install_package_secure "DirBuster" "dirbuster" "nala" "Web app fuzzer" || log WARN "DirBuster installation failed, continuing..."
                ;;
            "gobuster")
                install_package_secure "Gobuster" "gobuster" "nala" "Directory buster" || log WARN "Gobuster installation failed, continuing..."
                ;;
            "ffuf")
                log INFO "Installing ffuf..."
                sudo wget -O /usr/local/bin/ffuf https://github.com/ffuf/ffuf/releases/latest/download/ffuf_2.1.0_linux_amd64.tar.gz 2>&1 | \
                    zenity --progress --title="Downloading ffuf" --text="Downloading..." --pulsate --auto-close
                sudo chmod +x /usr/local/bin/ffuf
                ;;
            "wfuzz")
                install_package_secure "Wfuzz" "wfuzz" "nala" "Web fuzzer" || log WARN "Wfuzz installation failed, continuing..."
                ;;
            
            # Password Cracking
            "john")
                install_package_secure "John the Ripper" "john" "nala" "Password cracker" || log WARN "John the Ripper installation failed, continuing..."
                ;;
            "hashcat")
                install_package_secure "Hashcat" "hashcat" "nala" "Password recovery" || log WARN "Hashcat installation failed, continuing..."
                ;;
            "hydra")
                install_package_secure "Hydra" "hydra" "nala" "Network logon cracker" || log WARN "Hydra installation failed, continuing..."
                ;;
            "medusa")
                install_package_secure "Medusa" "medusa" "nala" "Password cracker" || log WARN "Medusa installation failed, continuing..."
                ;;
            "crunch")
                install_package_secure "Crunch" "crunch" "nala" "Wordlist generator" || log WARN "Crunch installation failed, continuing..."
                ;;
            "cewl")
                install_package_secure "CeWL" "cewl" "nala" "Wordlist generator" || log WARN "CeWL installation failed, continuing..."
                ;;
            
            # Wireless Security
            "aircrack-ng")
                install_package_secure "Aircrack-ng" "aircrack-ng" "nala" "WiFi security suite" || log WARN "Aircrack-ng installation failed, continuing..."
                ;;
            "reaver")
                install_package_secure "Reaver" "reaver" "nala" "WPS attack tool" || log WARN "Reaver installation failed, continuing..."
                ;;
            "kismet")
                install_package_secure "Kismet" "kismet" "nala" "Wireless detector" || log WARN "Kismet installation failed, continuing..."
                ;;
            "wifite")
                install_package_secure "Wifite" "wifite" "nala" "Automated WiFi attack" || log WARN "Wifite installation failed, continuing..."
                ;;
            "fern-wifi-cracker")
                install_package_secure "Fern WiFi Cracker" "fern-wifi-cracker" "nala" "Wireless auditing" || log WARN "Fern WiFi Cracker installation failed, continuing..."
                ;;
            
            # Exploitation Frameworks
            "metasploit")
                log INFO "Installing Metasploit Framework..."
                curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
                chmod 755 /tmp/msfinstall
                sudo /tmp/msfinstall 2>&1 | \
                    zenity --progress --title="Installing Metasploit" --text="Installing..." --pulsate --auto-close
                
                if command -v msfconsole &> /dev/null; then
                    log INFO "Metasploit installed successfully"
                    show_notification "Installation completed" "Metasploit installed!"
                else
                    log WARN "Metasploit installation failed, continuing..."
                fi
                ;;
            "armitage")
                show_message "Info" "Armitage requires Metasploit to be installed first.\n\nDownload from: http://www.fastandeasyhacking.com/"
                ;;
            "exploitdb")
                install_package_secure "ExploitDB" "exploitdb" "nala" "Exploit archive" || log WARN "ExploitDB installation failed, continuing..."
                ;;
            "searchsploit")
                install_package_secure "SearchSploit" "exploitdb" "nala" "ExploitDB search (included)" || log WARN "SearchSploit installation failed, continuing..."
                ;;
            
            # Social Engineering
            "set")
                log INFO "Installing Social-Engineer Toolkit..."
                git clone https://github.com/trustedsec/social-engineer-toolkit /tmp/setoolkit
                cd /tmp/setoolkit && sudo python3 setup.py install 2>&1 | \
                    zenity --progress --title="Installing SET" --text="Installing..." --pulsate --auto-close
                
                if command -v setoolkit &> /dev/null; then
                    log INFO "SET installed successfully"
                    show_notification "Installation completed" "SET installed!"
                else
                    log WARN "SET installation failed, continuing..."
                fi
                ;;
            "beef")
                show_message "Info" "BeEF installation requires Ruby and specific setup.\n\nVisit: https://github.com/beefproject/beef\n\nRecommended: Use Docker installation"
                ;;
            
            # Forensics
            "autopsy")
                install_package_secure "Autopsy" "autopsy" "nala" "Digital forensics" || log WARN "Autopsy installation failed, continuing..."
                ;;
            "sleuthkit")
                install_package_secure "The Sleuth Kit" "sleuthkit" "nala" "Digital investigation" || log WARN "Sleuth Kit installation failed, continuing..."
                ;;
            "foremost")
                install_package_secure "Foremost" "foremost" "nala" "File recovery" || log WARN "Foremost installation failed, continuing..."
                ;;
            "binwalk")
                install_package_secure "Binwalk" "binwalk" "nala" "Firmware analysis" || log WARN "Binwalk installation failed, continuing..."
                ;;
            "volatility")
                install_package_secure "Volatility" "volatility3" "nala" "Memory forensics" || log WARN "Volatility installation failed, continuing..."
                ;;
            "bulk-extractor")
                install_package_secure "bulk_extractor" "bulk-extractor" "nala" "Digital forensics tool" || log WARN "bulk_extractor installation failed, continuing..."
                ;;
            
            # Reverse Engineering
            "ghidra")
                log INFO "Installing Ghidra..."
                show_message "Manual Installation" "Ghidra requires manual installation:\n\n1. Visit: https://ghidra-sre.org/\n2. Download latest release\n3. Extract and run ghidraRun\n\nNote: Requires Java JDK 17+"
                xdg-open "https://ghidra-sre.org/" 2>/dev/null &
                ;;
            "radare2")
                install_package_secure "Radare2" "radare2" "nala" "Reverse engineering" || log WARN "Radare2 installation failed, continuing..."
                ;;
            "cutter")
                install_package_secure "Cutter" "cutter" "snap" "Radare2 GUI" || log WARN "Cutter installation failed, continuing..."
                ;;
            "ida-free")
                show_message "Manual Installation" "IDA Free requires manual download:\n\n1. Visit: https://hex-rays.com/ida-free/\n2. Download Linux version\n3. Follow installation instructions\n\nNote: Free version available"
                xdg-open "https://hex-rays.com/ida-free/" 2>/dev/null &
                ;;
            "gdb")
                install_package_secure "GDB" "gdb" "nala" "GNU Debugger" || log WARN "GDB installation failed, continuing..."
                ;;
            "edb")
                install_package_secure "EDB" "edb-debugger" "nala" "Cross-platform debugger" || log WARN "EDB installation failed, continuing..."
                ;;
            "hopper")
                show_message "Manual Installation" "Hopper requires manual download:\n\n1. Visit: https://www.hopperapp.com/\n2. Download Linux version\n\nNote: Commercial software with demo version"
                xdg-open "https://www.hopperapp.com/" 2>/dev/null &
                ;;
            
            # Cryptography
            "hashid")
                log INFO "Installing HashID..."
                sudo pip3 install hashid 2>&1 | \
                    zenity --progress --title="Installing HashID" --text="Installing..." --pulsate --auto-close
                ;;
            "hash-identifier")
                install_package_secure "Hash Identifier" "hash-identifier" "nala" "Hash identification" || log WARN "Hash Identifier installation failed, continuing..."
                ;;
            "steghide")
                install_package_secure "Steghide" "steghide" "nala" "Steganography tool" || log WARN "Steghide installation failed, continuing..."
                ;;
            "stegcracker")
                log INFO "Installing StegCracker..."
                sudo pip3 install stegcracker 2>&1 | \
                    zenity --progress --title="Installing StegCracker" --text="Installing..." --pulsate --auto-close
                ;;
            "outguess")
                install_package_secure "OutGuess" "outguess" "nala" "Steganography tool" || log WARN "OutGuess installation failed, continuing..."
                ;;
            "openssl")
                install_package_secure "OpenSSL" "openssl" "nala" "Cryptography toolkit" || log WARN "OpenSSL installation failed, continuing..."
                ;;
            
            # OSINT
            "maltego")
                show_message "Manual Installation" "Maltego requires manual installation:\n\n1. Visit: https://www.maltego.com/downloads/\n2. Download Community Edition\n3. Follow installation instructions\n\nNote: Free Community edition available"
                xdg-open "https://www.maltego.com/downloads/" 2>/dev/null &
                ;;
            "theharvester")
                install_package_secure "theHarvester" "theharvester" "nala" "Information gathering" || log WARN "theHarvester installation failed, continuing..."
                ;;
            "recon-ng")
                install_package_secure "Recon-ng" "recon-ng" "nala" "Web reconnaissance" || log WARN "Recon-ng installation failed, continuing..."
                ;;
            "sherlock")
                log INFO "Installing Sherlock..."
                git clone https://github.com/sherlock-project/sherlock.git /tmp/sherlock
                cd /tmp/sherlock && sudo python3 -m pip install -r requirements.txt 2>&1 | \
                    zenity --progress --title="Installing Sherlock" --text="Installing..." --pulsate --auto-close
                sudo cp /tmp/sherlock/sherlock.py /usr/local/bin/sherlock
                sudo chmod +x /usr/local/bin/sherlock
                ;;
            "spiderfoot")
                log INFO "Installing SpiderFoot..."
                show_message "Info" "SpiderFoot is best installed via Docker or pip:\n\nDocker: docker run -p 5001:5001 spiderfoot/spiderfoot\nPip: pip3 install spiderfoot\n\nVisit: https://www.spiderfoot.net/"
                ;;
            "exiftool")
                install_package_secure "ExifTool" "libimage-exiftool-perl" "nala" "Meta information tool" || log WARN "ExifTool installation failed, continuing..."
                ;;
            
            # Anonymity & Privacy
            "tor-browser")
                install_package_secure "Tor Browser" "torbrowser-launcher" "nala" "Anonymous browser" || log WARN "Tor Browser installation failed, continuing..."
                ;;
            "proxychains")
                install_package_secure "ProxyChains" "proxychains4" "nala" "Proxy tool" || log WARN "ProxyChains installation failed, continuing..."
                ;;
            "macchanger")
                install_package_secure "MAC Changer" "macchanger" "nala" "MAC address changer" || log WARN "MAC Changer installation failed, continuing..."
                ;;
            "veracrypt")
                log INFO "Installing VeraCrypt..."
                add_repository "VeraCrypt" \
                    "" \
                    "deb http://ppa.launchpad.net/unit193/encryption/ubuntu $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/veracrypt.list"
                install_package_secure "VeraCrypt" "veracrypt" "nala" "Disk encryption" || log WARN "VeraCrypt installation failed, continuing..."
                ;;
            
            # Sniffing & Spoofing
            "arpspoof")
                install_package_secure "ARPSpoof" "dsniff" "nala" "ARP spoofing (included in dsniff)" || log WARN "ARPSpoof installation failed, continuing..."
                ;;
            "dnsspoof")
                install_package_secure "DNSSpoof" "dsniff" "nala" "DNS spoofing (included in dsniff)" || log WARN "DNSSpoof installation failed, continuing..."
                ;;
            "mitmproxy")
                install_package_secure "mitmproxy" "mitmproxy" "nala" "HTTPS proxy" || log WARN "mitmproxy installation failed, continuing..."
                ;;
            "sslsplit")
                install_package_secure "SSLsplit" "sslsplit" "nala" "SSL/TLS interception" || log WARN "SSLsplit installation failed, continuing..."
                ;;
            
            # Information Gathering
            "whois")
                install_package_secure "WHOIS" "whois" "nala" "Domain lookup" || log WARN "WHOIS installation failed, continuing..."
                ;;
            "dnsutils")
                install_package_secure "DNS Utils" "dnsutils" "nala" "DNS utilities" || log WARN "DNS Utils installation failed, continuing..."
                ;;
            "traceroute")
                install_package_secure "Traceroute" "traceroute" "nala" "Network diagnostic" || log WARN "Traceroute installation failed, continuing..."
                ;;
            "netdiscover")
                install_package_secure "Netdiscover" "netdiscover" "nala" "Network scanner" || log WARN "Netdiscover installation failed, continuing..."
                ;;
            "arp-scan")
                install_package_secure "arp-scan" "arp-scan" "nala" "ARP scanner" || log WARN "arp-scan installation failed, continuing..."
                ;;
            
            # Reporting
            "dradis")
                show_message "Info" "Dradis is best installed via Docker or from source.\n\nVisit: https://dradisframework.com/ce/\n\nDocker: docker pull dradis/dradis-ce"
                ;;
            "faraday")
                show_message "Info" "Faraday requires specific installation.\n\nVisit: https://github.com/infobyte/faraday\n\nRecommended: Use Docker installation"
                ;;
            "pipal")
                log INFO "Installing Pipal..."
                git clone https://github.com/digininja/pipal.git /tmp/pipal
                sudo cp /tmp/pipal/pipal.rb /usr/local/bin/pipal
                sudo chmod +x /usr/local/bin/pipal
                ;;
            
            # Mobile Security
            "apktool")
                install_package_secure "APKTool" "apktool" "nala" "Android reverse engineering" || log WARN "APKTool installation failed, continuing..."
                ;;
            "androguard")
                log INFO "Installing Androguard..."
                sudo pip3 install androguard 2>&1 | \
                    zenity --progress --title="Installing Androguard" --text="Installing..." --pulsate --auto-close
                ;;
            "mobsf")
                show_message "Info" "Mobile Security Framework requires Docker or manual setup.\n\nDocker: docker pull opensecurity/mobile-security-framework-mobsf\n\nVisit: https://github.com/MobSF/Mobile-Security-Framework-MobSF"
                ;;
            
            # Additional Tools
            "checksec")
                install_package_secure "checksec" "checksec" "nala" "Binary security checker" || log WARN "checksec installation failed, continuing..."
                ;;
            "pwntools")
                log INFO "Installing pwntools..."
                sudo pip3 install pwntools 2>&1 | \
                    zenity --progress --title="Installing pwntools" --text="Installing..." --pulsate --auto-close
                ;;
            "pwndbg")
                log INFO "Installing pwndbg..."
                git clone https://github.com/pwndbg/pwndbg /tmp/pwndbg
                cd /tmp/pwndbg && ./setup.sh 2>&1 | \
                    zenity --progress --title="Installing pwndbg" --text="Installing..." --pulsate --auto-close
                
                if [ -f ~/.gdbinit ]; then
                    log INFO "pwndbg installed successfully"
                    show_notification "Installation completed" "pwndbg installed!"
                else
                    log WARN "pwndbg installation failed, continuing..."
                fi
                ;;
            "gef")
                log INFO "Installing GEF..."
                wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
                echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit
                log INFO "GEF installed successfully"
                show_notification "Installation completed" "GEF installed!"
                ;;
            "yara")
                install_package_secure "YARA" "yara" "nala" "Malware pattern matching" || log WARN "YARA installation failed, continuing..."
                ;;
            "snort")
                install_package_secure "Snort" "snort" "nala" "Network IDS" || log WARN "Snort installation failed, continuing..."
                ;;
            "suricata")
                install_package_secure "Suricata" "suricata" "nala" "Network security monitoring" || log WARN "Suricata installation failed, continuing..."
                ;;
            "fail2ban")
                install_package_secure "Fail2Ban" "fail2ban" "nala" "Ban malicious IPs" || log WARN "Fail2Ban installation failed, continuing..."
                ;;
            "apparmor")
                install_package_secure "AppArmor" "apparmor apparmor-utils" "nala" "Mandatory Access Control" || log WARN "AppArmor installation failed, continuing..."
                ;;
            "selinux")
                show_message "Info" "SELinux installation on Ubuntu requires significant configuration.\n\nNot recommended unless you know what you're doing.\n\nVisit: https://wiki.ubuntu.com/SELinux"
                ;;
            
            # Virtual Machines
            "kali-linux")
                show_message "Info" "Kali Linux VM installation:\n\n1. Download Kali Linux VM from: https://www.kali.org/get-kali/\n2. Use VirtualBox or VMware to import\n3. Or use WSL2 on Windows: wsl --install -d kali-linux\n\nAlternatively, use Docker: docker pull kalilinux/kali-rolling"
                xdg-open "https://www.kali.org/get-kali/" 2>/dev/null &
                ;;
            "parrot-os")
                show_message "Info" "Parrot OS VM installation:\n\n1. Download from: https://www.parrotsec.org/download/\n2. Use VirtualBox or VMware to import\n3. Or use Docker: docker pull parrotsec/security\n\nParrot OS is lightweight alternative to Kali Linux"
                xdg-open "https://www.parrotsec.org/download/" 2>/dev/null &
                ;;
            # Advanced Wireless Tools
            "wash")
                install_package_secure "Wash" "reaver" "nala" "WPS scanner (included in Reaver)" || log WARN "Wash installation failed, continuing..."
                ;;
            "pixiewps")
                install_package_secure "PixieWPS" "pixiewps" "nala" "WPS Pixie Dust attack" || log WARN "PixieWPS installation failed, continuing..."
                ;;
            "bully")
                install_package_secure "Bully" "bully" "nala" "WPS brute force" || log WARN "Bully installation failed, continuing..."
                ;;
            "mdk4")
                install_package_secure "MDK4" "mdk4" "nala" "Wireless stress testing" || log WARN "MDK4 installation failed, continuing..."
                ;;
            "mdk3")
                install_package_secure "MDK3" "mdk3" "nala" "Wireless stress testing (old)" || log WARN "MDK3 installation failed, continuing..."
                ;;
            "cowpatty")
                install_package_secure "Cowpatty" "cowpatty" "nala" "WPA-PSK dictionary attack" || log WARN "Cowpatty installation failed, continuing..."
                ;;
            "pyrit")
                log INFO "Installing Pyrit..."
                sudo pip3 install pyrit 2>&1 | \
                    zenity --progress --title="Installing Pyrit" --text="Installing..." --pulsate --auto-close
                
                if command -v pyrit &> /dev/null; then
                    log INFO "Pyrit installed successfully"
                    show_notification "Installation completed" "Pyrit installed!"
                else
                    log WARN "Pyrit installation failed, continuing..."
                fi
                ;;
            "hcxdumptool")
                install_package_secure "hcxdumptool" "hcxdumptool" "nala" "Packet capture for hashcat" || log WARN "hcxdumptool installation failed, continuing..."
                ;;
            "hcxtools")
                install_package_secure "hcxtools" "hcxtools" "nala" "Convert captures to hashcat" || log WARN "hcxtools installation failed, continuing..."
                ;;
            "eaphammer")
                log INFO "Installing EAPHammer..."
                git clone https://github.com/s0lst1c3/eaphammer.git /tmp/eaphammer
                cd /tmp/eaphammer && ./kali-setup 2>&1 | \
                    zenity --progress --title="Installing EAPHammer" --text="Installing..." --pulsate --auto-close
                
                if [ -d /tmp/eaphammer ]; then
                    sudo mv /tmp/eaphammer /opt/eaphammer
                    log INFO "EAPHammer installed in /opt/eaphammer"
                    show_notification "Installation completed" "EAPHammer installed!"
                else
                    log WARN "EAPHammer installation failed, continuing..."
                fi
                ;;
            "hostapd-wpe")
                install_package_secure "hostapd-wpe" "hostapd-wpe" "nala" "Rogue AP for WPA-Enterprise" || log WARN "hostapd-wpe installation failed, continuing..."
                ;;
            "fluxion")
                log INFO "Installing Fluxion..."
                git clone https://github.com/FluxionNetwork/fluxion.git /opt/fluxion
                cd /opt/fluxion && sudo ./fluxion.sh --install 2>&1 | \
                    zenity --progress --title="Installing Fluxion" --text="Installing..." --pulsate --auto-close
                log INFO "Fluxion installed in /opt/fluxion"
                show_notification "Installation completed" "Fluxion installed!"
                ;;
            "linset")
                log INFO "Installing Linset..."
                git clone https://github.com/vk496/linset.git /opt/linset
                log INFO "Linset installed in /opt/linset"
                show_notification "Installation completed" "Linset installed!"
                ;;
            "wifi-pumpkin")
                log INFO "Installing WiFi-Pumpkin3..."
                sudo pip3 install wifipumpkin3 2>&1 | \
                    zenity --progress --title="Installing WiFi-Pumpkin3" --text="Installing..." --pulsate --auto-close
                
                if command -v wifipumpkin3 &> /dev/null; then
                    log INFO "WiFi-Pumpkin3 installed successfully"
                    show_notification "Installation completed" "WiFi-Pumpkin3 installed!"
                else
                    log WARN "WiFi-Pumpkin3 installation failed, continuing..."
                fi
                ;;
            "mana")
                log INFO "Installing MANA Toolkit..."
                show_message "Info" "MANA Toolkit requires manual setup.\n\nVisit: https://github.com/sensepost/mana\n\nRecommended: Clone and follow installation instructions"
                ;;
            "evilginx")
                log INFO "Installing Evilginx2..."
                show_message "Info" "Evilginx2 requires Go and manual setup.\n\nVisit: https://github.com/kgretzky/evilginx2\n\nInstallation:\ngo install github.com/kgretzky/evilginx2@latest"
                ;;
            "wifiphisher")
                log INFO "Installing Wifiphisher..."
                git clone https://github.com/wifiphisher/wifiphisher.git /tmp/wifiphisher
                cd /tmp/wifiphisher && sudo python3 setup.py install 2>&1 | \
                    zenity --progress --title="Installing Wifiphisher" --text="Installing..." --pulsate --auto-close
                
                if command -v wifiphisher &> /dev/null; then
                    log INFO "Wifiphisher installed successfully"
                    show_notification "Installation completed" "Wifiphisher installed!"
                else
                    log WARN "Wifiphisher installation failed, continuing..."
                fi
                ;;
            "airgeddon")
                log INFO "Installing Airgeddon..."
                git clone --depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git /opt/airgeddon
                log INFO "Airgeddon installed in /opt/airgeddon"
                show_message "Info" "Run Airgeddon with:\ncd /opt/airgeddon && sudo bash airgeddon.sh"
                show_notification "Installation completed" "Airgeddon installed!"
                ;;
            "iw")
                install_package_secure "iw" "iw" "nala" "Wireless configuration tool" || log WARN "iw installation failed, continuing..."
                ;;
            "wavemon")
                install_package_secure "Wavemon" "wavemon" "nala" "Wireless monitor" || log WARN "Wavemon installation failed, continuing..."
                ;;
            "horst")
                install_package_secure "HORST" "horst" "nala" "Wireless LAN analyzer" || log WARN "HORST installation failed, continuing..."
                ;;
            "wifi-radar")
                install_package_secure "WiFi Radar" "wifi-radar" "nala" "WiFi connection manager" || log WARN "WiFi Radar installation failed, continuing..."
                ;;
            
            # SDR Tools
            "gqrx")
                install_package_secure "GQRX" "gqrx-sdr" "nala" "SDR receiver" || log WARN "GQRX installation failed, continuing..."
                ;;
            "rtl-sdr")
                install_package_secure "RTL-SDR" "rtl-sdr" "nala" "Software defined radio tools" || log WARN "RTL-SDR installation failed, continuing..."
                ;;
            "hackrf")
                install_package_secure "HackRF Tools" "hackrf" "nala" "HackRF One tools" || log WARN "HackRF installation failed, continuing..."
                ;;
            
            # GPS & Wardriving
            "gpsd")
                install_package_secure "GPSd" "gpsd" "nala" "GPS service daemon" || log WARN "GPSd installation failed, continuing..."
                ;;
            "gpsd-clients")
                install_package_secure "GPS Clients" "gpsd-clients" "nala" "GPS client tools" || log WARN "GPS Clients installation failed, continuing..."
                ;;
            "wigle-wifi")
                show_message "Info" "WiGLE WiFi Wardriving app:\n\nFor Android: Install from Play Store\nFor data upload: Visit https://wigle.net/\n\nKismet can export to WiGLE format"
                ;;
            
            # Bluetooth Security
            "bluez")
                install_package_secure "BlueZ" "bluez" "nala" "Bluetooth stack" || log WARN "BlueZ installation failed, continuing..."
                ;;
            "bluez-tools")
                install_package_secure "BlueZ Tools" "bluez-tools" "nala" "Bluetooth utilities" || log WARN "BlueZ Tools installation failed, continuing..."
                ;;
            "blueman")
                install_package_secure "Blueman" "blueman" "nala" "Bluetooth manager GUI" || log WARN "Blueman installation failed, continuing..."
                ;;
            "bluehydra")
                log INFO "Installing Blue Hydra..."
                git clone https://github.com/pwnieexpress/blue_hydra.git /opt/blue_hydra
                cd /opt/blue_hydra && bundle install 2>&1 | \
                    zenity --progress --title="Installing Blue Hydra" --text="Installing..." --pulsate --auto-close
                log INFO "Blue Hydra installed in /opt/blue_hydra"
                ;;
            "btscanner")
                install_package_secure "BTScanner" "btscanner" "nala" "Bluetooth scanner" || log WARN "BTScanner installation failed, continuing..."
                ;;
            "spooftooph")
                install_package_secure "SpoofTooph" "spooftooph" "nala" "Bluetooth spoofing" || log WARN "SpoofTooph installation failed, continuing..."
                ;;
            "bluesnarfer")
                install_package_secure "BlueSnarfer" "bluesnarfer" "nala" "Bluetooth attack tool" || log WARN "BlueSnarfer installation failed, continuing..."
                ;;
            
            # RFID/NFC
            "libnfc")
                install_package_secure "libnfc" "libnfc-bin libnfc-examples" "nala" "NFC tools" || log WARN "libnfc installation failed, continuing..."
                ;;
            "mfoc")
                install_package_secure "MFOC" "mfoc" "nala" "Mifare Classic cracker" || log WARN "MFOC installation failed, continuing..."
                ;;
            "mfcuk")
                install_package_secure "MFCUK" "mfcuk" "nala" "Mifare Classic key recovery" || log WARN "MFCUK installation failed, continuing..."
                ;;
            "proxmark3")
                show_message "Info" "Proxmark3 requires hardware and specific setup.\n\nVisit: https://github.com/RfidResearchGroup/proxmark3\n\nFollow installation guide for your hardware version"
                ;;
            
            # Network Monitoring
            "arp-watch")
                install_package_secure "arpwatch" "arpwatch" "nala" "Ethernet/IP monitoring" || log WARN "arpwatch installation failed, continuing..."
                ;;
            "darkstat")
                install_package_secure "darkstat" "darkstat" "nala" "Network statistics" || log WARN "darkstat installation failed, continuing..."
                ;;
            "ntopng")
                install_package_secure "ntopng" "ntopng" "nala" "Network traffic monitor" || log WARN "ntopng installation failed, continuing..."
                ;;
            "vnstat")
                install_package_secure "vnStat" "vnstat" "nala" "Network traffic monitor" || log WARN "vnStat installation failed, continuing..."
                ;;
            "iftop")
                install_package_secure "iftop" "iftop" "nala" "Bandwidth usage display" || log WARN "iftop installation failed, continuing..."
                ;;
            "nethogs")
                install_package_secure "NetHogs" "nethogs" "nala" "Per-process bandwidth" || log WARN "NetHogs installation failed, continuing..."
                ;;
            "bandwhich")
                install_package_secure "bandwhich" "bandwhich" "snap" "Terminal bandwidth tool" || log WARN "bandwhich installation failed, continuing..."
                ;;
        esac
    done
    
    show_message "Completed" "Security tools installation completed!\n\nIMPORTANT LEGAL NOTICE\n\nThese tools are for:\n• Educational purposes\n• Authorized penetration testing\n• Security research on YOUR OWN systems\n\nUnauthorized use is ILLEGAL and can result in:\n• Criminal prosecution\n• Civil liability\n• Imprisonment\n\nALWAYS:\n✓ Get written permission before testing\n✓ Work within legal boundaries\n✓ Follow responsible disclosure practices\n✓ Respect privacy and data protection laws\n\nYou are responsible for your actions!"
}