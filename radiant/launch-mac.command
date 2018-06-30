#!/bin/bash

## script to start Radiant and Rstudio
## script requires correct permissions to execute
## if you put the script on your Desktop, running the
## command below from a terminal should work
## then double-click to start the container

## chmod 755 ~/Desktop/launch-mac.command

clear
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "--------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  echo "https://download.docker.com/mac/stable/Docker.dmg"
  echo "--------------------------------------------------------------------"
  read
else

  ## kill running containers
  running=$(docker ps -q)
  if [ "${running}" != "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Stopping running containers"
    echo "--------------------------------------------------------------------"
    docker kill ${running}
  fi

  available=$(docker images -q vnijs/radiant)
  if [ "${available}" == "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Downloading the radiant computing container"
    echo "--------------------------------------------------------------------"
    docker pull vnijs/radiant
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting radiant computing container"
  echo "--------------------------------------------------------------------"

  docker run -d -p 80:80 -p 8787:8787 -p 8888:8888 -v ~:/home/rstudio vnijs/radiant

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  find ~/.rstudio/sessions/active/*/session-persistent-state -type f | xargs sed -i '' -e 's/abend="1"/abend="0"/'

  echo "--------------------------------------------------------------------"
  echo "Press (1) to show Radiant, followed by [ENTER]:"
  echo "Press (2) to show Rstudio, followed by [ENTER]:"
  echo "Press (3) to update the radiant container, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read startup

  if [ "${startup}" == "3" ]; then
    running=$(docker ps -q)
    echo "--------------------------------------------------------------------"
    echo "Updating the radiant computing container"
    docker kill ${running}
    docker pull vnijs/radiant
    echo "--------------------------------------------------------------------"
    docker run -d -p 80:80 -p 8787:8787 -p 8888:8888 -v ~:/home/rstudio vnijs/radiant
    echo "--------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "--------------------------------------------------------------------"
    read startup
  fi

  echo "--------------------------------------------------------------------"
  if [ "${startup}" == "1" ]; then
    touch ~/.Rprofile
    if ! grep -q 'radiant.report = TRUE' ~/.Rprofile; then
      echo "Your setup does not allow report generation in Report > Rmd"
      echo "or Report > R. Would you like to add relevant code to .Rprofile?"
      echo "Press y or n, followed by [ENTER]:"
      echo
      read allow_report

      if [ "${allow_report}" == "y" ]; then
        printf '\noptions(radiant.maxRequestSize = -1)\noptions(radiant.report = TRUE)' >> ~/.Rprofile
      fi
    fi
    echo "Starting Radiant in the default browser"
    open http://localhost
  elif [ "${startup}" == "2" ]; then
    echo "Starting Rstudio in the default browser"
    open http://localhost:8787
  fi
  echo "--------------------------------------------------------------------"

  echo "--------------------------------------------------------------------"
  echo "Press q to stop the docker process, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read quit

  if [ "${quit}" == "q" ]; then
    running=$(docker ps -q)
    docker kill ${running}
  else
    echo "--------------------------------------------------------------------"
    echo "The radiant computing container is still running"
    echo "Use the command below to stop the service"
    echo "docker kill $(docker ps -q)"
    echo "--------------------------------------------------------------------"
    read
  fi
fi