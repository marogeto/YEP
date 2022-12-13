  #!/bin/bash
# Skript : yeeep
# Version: 1
# Author : Martin Rösner
# Email  : roesner@elektronikschule.de
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version

function deluser {
    echo -n "Bitte zu löschenden User eingeben:  ";
    read USER;
    if [ $(grep -ic "^${USER}:" /etc/passwd) == "1" ];
    then
        echo -n "HomeDIR löschen (J/n): "
	read OK;
	if [ "$OK" = "n" ];
	then
	   REM=""
	else
	   REM="-r"
        fi
	echo userdel $REM $USER
	exit 0
    else
	echo "$USER nicht gefunden!"
	exit 1
    fi
}

# saldlasndnasd
function addgroup {
    echo -n "Bitte zu erstellende Gruppe eingeben:  ";
    read GRUPPE;
    if [ $(grep -ic "^${GRUPPE}:" /etc/group) == "1" ];
    then
        echo " Gruppe schon vorhanden!"
	exit 1
    else
        echo groupadd $GRUPPE
	echo "Gruppe $GRUPPE hinzugefügt!"
	exit 0
    fi
}

clear

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
    echo adduser
    ;;
  ul|UL|uL|Ul)
    deluser
    ;;
  ga|GA|Ga|gA)
    addgroup
    ;;
  gl|GL|Gl|gL)
    echo delgroup
    ;;
  q|Q)
    echo "ByeBye"
    exit 0
    ;;
  *)
    echo "Usage: yep.sh [ua|ul|ga|gl]"
    exit 1
    ;;
esac
exit 0
