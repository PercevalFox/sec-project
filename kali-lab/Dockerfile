FROM kalilinux/kali-rolling

RUN apt update && apt install -y \
    nmap \
    nikto \
    metasploit-framework \
    gobuster \
    && apt clean

CMD ["/bin/bash"]
