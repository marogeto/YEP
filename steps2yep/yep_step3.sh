#!/bin/bash
# Skript : yeeep
# Version: 2
# Author : Martin Rösner
# Email  : roesner@elektronikschule.de
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.

clear



function delgroup(){
  echo -n "| Welche Gruppe soll gelöscht werden? "
  read GRUPPE
  ERG=$(grep ^$GRUPPE /etc/group)
  if [ "$ERG" == "" ]; then
    echo "|  Gruppe $GRUPPE existiert nicht"
    exit 9
  else
    GID=$(echo $ERG | cut -d : -f 3)
    ANZ=$(grep -c ^[a-zA-Z0-9]*:x:[0-9]*:${GID}: /etc/passwd)
    if [ "$ANZ" == "0" ]; then
      echo "Gruppe $GRUPPE kann gelöscht werden"
      echo "groupdel $GRUPPE"
    else
      echo "| Es sind noch folgende User in der Gruppe $GRUPPE vorhanden:"
      grep ^[a-zA-Z0-9]*:x:[0-9]*:${GID}: /etc/passwd | cut -d : -f 1 
    fi
  fi
}



# Löscht eine vorhanden Gruppe
function delgroupkom(){
  echo -n "| Welche Gruppe soll gelöscht werden? "
  read GRUPPE
  echo -n "| Testen, ob es diese Gruppe gibt: "
  if [ `grep "^${GRUPPE}:" /etc/group` ]; then
    echo "ok!"
    # Gruppenid auslesen
    GID=$(cat /etc/group | grep ^${GRUPPE}: | cut -d : -f 3)
    echo "| Testen, ob es noch User in dieser Gruppe gibt: "
    if [ `grep -c "^\w*:x:\w*:${GID}:" /etc/passwd ` ]; then
      echo "| Folgenden Benutzer gibt es noch in dieser Gruppe :"
      for I in `grep "^\w*:x:\w*:${GID}:" /etc/passwd | cut -d : -f 1`; do
      echo "| -> $I"
      done
      exit 6
    else
      echo "groupdel $GRUPPE"
    fi
  else
    echo "Fehler: Gruppe gibt es nicht!"
    exit 7
  fi
}

function adduser(){
  echo -n "|  User eingeben: "
  read USER
  if [[ `grep ^${USER}: /etc/passwd ` ]]; then
    echo "|  User existiert schon!"
    exit 4
  else
    echo -n "|  Gruppe eingeben: "
    read GRUPPE
    if [ `grep ^${GRUPPE}: /etc/group ` ]; then
      echo "|  Gruppe existiert!"
    else 
      echo "|  Gruppe wird angelegt!" 
      echo "groupadd $GRUPPE"
    fi 
    echo -n "|  Bitte Kommentar eingeben: "
    read KOMM
    HEIM="J"
    echo -n "|  Soll ein Heimatverzeichnis angelegt werden (n/J): "
    read HEIM
    if [ $( echo $HEIM | grep -i ^n$ ) ]; then
      HEIM=""
    else
      HEIM="-m"
    fi
    # Eingabe der Passwörter
    PASS1="x";PASS2="y"
    until [ ${PASS1} == ${PASS2} ]; do
      echo "| Passwort eingeben: "
      read -s PASS1
      echo "| Passwort wiederholen: "
      read -s PASS2
      if [ ${PASS1} != ${PASS2} ]; then
        echo "| Passwörter nicht gleich... wiederholen..."
      fi
    done

    OK="N"
    echo -n "|  Soll der User \"${USER}\" in der Gruppe \"${GRUPPE}\" mit dem Kommentar \"${KOMM}\" angelegt werden (j/N): "
    read OK
    if [ $( echo $OK | grep -i ^j$) ]; then
      echo "useradd -c \"$KOMM\" -g ${GRUPPE} ${HEIM} $USER "
      # Passwort setzen
      echo "echo -e "${PASS1}\n${PASS1}" | passwd $USER > /dev/null
2>&1"
    else
      echo "|  User ${USER} wird nicht angelegt "
      exit 5
    fi
  fi
}


function deluser(){
  echo -n "|  User eingeben: "
  read USER
  if [[ `grep ^${USER}: /etc/passwd ` ]]; then
    echo "|  User existiert!"
    echo -n "|  Soll das Heimatverzeichnis mitgelöscht werden? [J/n]"
    read OK
    if (( "$OK" == "n" )) || (( "$OK" == "N" )); then
      echo "userdel $USER"
    else
      echo "userdel -r $USER"
    fi
  else 
    echo "|  User existiert nicht!"
    echo "|  Programm wird verlassen!" 
    exit 3
  fi
  exit 0
}


function addgroup(){
  echo -n "|  Gruppe eingeben: "
  read GRUPPE
  if [ `grep ^${GRUPPE}: /etc/group ` ]; then
    echo "|  Gruppe existiert!"
    exit 2
  else 
    echo "|  Gruppe wird angelegt!" 
    echo "groupadd $GRUPPE"
  fi
  exit 0
}

echo "|--------------------------------------------------|"
echo "|  Willkommen zur User- und Gruppenverwaltung      |"
echo "|      ___.__.   ____   ____   ____   ______       |"
echo "|     <   |  | _/ __ \_/ __ \_/ __ \  \____ \      |"
echo "|      \___  | \  ___/\  ___/\  ___/  |  |_> >     |"
echo "|      / ____|  \___  >\___  >\___  > |   __/      |"
echo "|      \/           \/     \/     \/  |__|         |"
echo "|                                                  |"
if [ "$1" == "" ];then
  echo "|  Was möchten Sie tun:                            |"
  echo "|    > User anlegen  ---->  Tastenkombi:  ua       |"
  echo "|    > User löschen  ---->  Tastenkombi:  ul       |"
  echo "|    > Gruppe anlegen  -->  Tastenkombi:  ga       |"
  echo "|    > Gruppe löschen  -->  Tastenkombi:  gl       |"
  echo "|    > Programm exit  --->  Tastenkombi:  q        |" 
  echo -n "|    < Eingabe: " 
  read AKTION
else
  AKTION=$1
fi
echo "|--------------------------------------------------|"

case "$AKTION" in
  ua|UA|uA|Ua)
    adduser
    ;;
  ul|UL|uL|Ul)
    deluser
    ;;
  ga|GA|Ga|gA)
    addgroup
    ;;
  gl|GL|Gl|gL)
    delgroup
    ;;
  q|Q)
    echo "ByeBye"
    exit 0
    ;;
  *)
    echo "Usage: yeeep [ua|ul|ga|gl]"
    exit 1
    ;;
esac
exit 0
