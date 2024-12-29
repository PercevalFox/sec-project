#!/bin/bash

echo "=== Nettoyage des ressources Docker inutilisées ==="

# Liste des images à conserver
declare -a KEEP_IMAGES=(
    "scanner-securite"
    "ctf-environnement"
    "kali-lab"
    "docker.elastic.co/elasticsearch/elasticsearch:8.9.2"
    "docker.elastic.co/logstash/logstash:8.9.2"
    "docker.elastic.co/kibana/kibana:8.9.2"
)

# Étape 1 : Supprimer les conteneurs terminés (Exited ou Created mais jamais démarrés)
echo "=== Suppression des conteneurs terminés ==="
docker ps -a --filter "status=exited" --filter "status=created" -q | while read -r container_id; do
    echo "Suppression du conteneur : $container_id"
    docker rm "$container_id"
done

# Étape 2 : Identifier les IDs des images à conserver
echo "=== Préservation des images nécessaires ==="
KEEP_IMAGE_IDS=()
for image in "${KEEP_IMAGES[@]}"; do
    image_id=$(docker images --filter=reference="$image" --format "{{.ID}}")
    if [ -n "$image_id" ]; then
        KEEP_IMAGE_IDS+=("$image_id")
        echo "Image préservée : $image ($image_id)"
    else
        echo "Image non trouvée ou inutilisée : $image"
    fi
done

# Étape 3 : Supprimer les images inutilisées sauf celles à conserver
echo "=== Suppression des images inutilisées ==="
docker images -q | while read -r image_id; do
    if [[ ! " ${KEEP_IMAGE_IDS[*]} " =~ " $image_id " ]]; then
        echo "Suppression de l'image : $image_id"
        docker rmi "$image_id" -f
    else
        echo "Conservation de l'image : $image_id"
    fi
done

# Étape 4 : Nettoyer les volumes inutilisés
echo "=== Nettoyage des volumes non utilisés ==="
docker volume prune -f

# Étape 5 : Nettoyer les réseaux inutilisés
echo "=== Nettoyage des réseaux non utilisés ==="
docker network prune -f

echo "=== Nettoyage terminé ==="
