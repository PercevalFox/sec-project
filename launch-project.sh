#!/bin/bash

echo "Sélectionnez un projet à lancer :"
echo "1. Scanner de sécurité (Terminal)"
echo "2. Stack ELK (Web - Elasticsearch et Kibana)"
echo "3. Environnement CTF (Web)"
echo "4. Laboratoire Kali (Terminal)"
read -p "Votre choix : " choice

case $choice in
  1)
    # Scanner de sécurité (Terminal)
    docker ps -a | grep "scanner-securite" && docker rm -f "scanner-securite"
    docker run --name scanner-securite -it scanner-securite
    ;;
  2)
    # Stack ELK (Web - Elasticsearch et Kibana)
    cd elk-stack/
    docker-compose up -d
    echo "Elasticsearch est accessible à l'adresse suivante : http://$(hostname -I | awk '{print $1}'):9200"
    echo "Kibana est accessible à l'adresse suivante : http://$(hostname -I | awk '{print $1}'):5601"
    echo "Logstash est accessible à l'adresse suivante : http://$(hostname -I | awk '{print $1}'):5044"
    cd ..
    ;;
  3)
    # Environnement CTF (Web)
    docker ps -a | grep "ctf-environnement" && docker rm -f "ctf-environnement"
    docker run --name ctf-environnement -d -p 8087:8000 ctf-environnement
    echo "CTF est accessible à l'adresse suivante : http://$(hostname -I | awk '{print $1}'):8087"
    ;;
  4)
    # Laboratoire Kali (Terminal)
    docker ps -a | grep "kali-lab" && docker rm -f "kali-lab"
    docker run --name kali-lab -it kali-lab
    ;;
  *)
    echo "Choix invalide."
    ;;
esac
