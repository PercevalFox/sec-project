#!/usr/bin/env bash

echo "Voulez-vous gérer les conteneurs en cours d'exécution (UP) ? [y/n]"
read -r manage_up

if [ "$manage_up" = "y" ]; then
  # liste des conteneurs UP
  running_containers=$(docker ps --format "{{.Names}}")

  if [ -z "$running_containers" ]; then
    echo "Pas de conteneur UP dans Docker."
  else
    echo "Liste des conteneurs UP :"
    docker ps --format "table {{.Names}}\t{{.Status}}"

    for container in $running_containers; do
      echo ""
      echo "Le conteneur '$container' est UP."
      echo "Voulez-vous le down+clean (stop + rm) ? [y/n]"
      read -r action

      if [ "$action" = "y" ]; then
        echo "-> Arrêt et suppression de '$container'..."
        docker stop "$container" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          docker rm "$container" >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "   * '$container' stoppé et supprimé avec succès."
          else
            echo "   * Échec de la suppression de '$container'."
          fi
        else
          echo "   * Échec de l'arrêt de '$container'."
        fi
      else
        echo "-> On laisse '$container' en place."
      fi
    done
  fi

else
  echo "Voulez-vous gérer les conteneurs NON-UP (exited, created, dead, etc.) ? [y/n]"
  read -r manage_down

  if [ "$manage_down" = "y" ]; then
    all_containers=$(docker ps -a --format "{{.Names}}")
    up_containers=$(docker ps --format "{{.Names}}")
    non_up_containers=$(comm -23 <(echo "$all_containers" | sort) <(echo "$up_containers" | sort))

    if [ -z "$non_up_containers" ]; then
      echo "Pas de conteneur NON-UP dans Docker."
    else
      echo "Liste des conteneurs NON-UP :"
      for c in $non_up_containers; do
        docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "$c"
      done

      for container in $non_up_containers; do
        echo ""
        echo "Le conteneur '$container' n'est pas UP."
        echo "Voulez-vous le supprimer ? [y/n]"
        read -r clear_action

        if [ "$clear_action" = "y" ]; then
          echo "-> Suppression de '$container'..."
          docker rm "$container" >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "   * '$container' a été supprimé avec succès."
          else
            echo "   * Échec de la suppression de '$container'."
          fi
        else
          echo "-> On le garde."
        fi
      done
    fi
  else
    echo "Opération terminée."
  fi
fi

echo "Fin du script."
exit 0
