#!/bin/bash
# Skript : yeeep
# Version: 1
# Author : Martin Rösner
# Email  : roesner@elektronikschule.de
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.


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
  echo "|--------------------------------------------------|"
  echo -n "|  Eingabe: " 
  read AKTION
else
  AKTION=$1
fi

if [ -n $(echo $AKTION | grep ^[uUgG][aAlL]$) ];then
  echo $AKTION
elif [ "$AKTION" == "q" ];then
  echo "bye"
  exit 0
else
  echo "Usage: yep <ua|ul|ga|gl> (Parameter optional)"
  exit 1
fi

exit 0
