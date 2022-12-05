#!/bin/bash
clear

##
# Fügt einen User hinzu
function add_user(){
  echo -n "|  Geben Sie den Usernamen ein : "
  read USERNAME
  if [ `grep "^${USERNAME}:" /etc/passwd | cut -d : -f 1 -` ]; then
    echo "|  Sorry, diesen Benutzer gibt es schon..."
    exit 2
  else
    echo -n "|  Bitte geben Sie die Gruppenzugehörigkeit an : "
    read GRUPPE
    if [ ! `grep "^${GRUPPE}:" /etc/group` ]; then
      echo "|  Die Gruppe ${GRUPPE} gibt es noch nicht."
      echo -n "|  Gruppe \"${GRUPPE}\" wird angelegt!"
      echo "groupadd $GRUPPE"
      echo " ... done"
    fi
    echo "|  Geben Sie ein Kommentar für diesen User ein."
    echo -n "|  : "
    read KOMM
    PASS1="x";PASS2="y"
    until [ ${PASS1} == ${PASS2} ]; do 
      echo "|  Passwort eingeben: "
      read -s PASS1 
      echo "|  Passwort eingeben wiederholen: "
      read -s PASS2
      if [ ${PASS1} != ${PASS2} ]; then
        echo "|  Passwörter nicht gleich... wiederholen..."
      fi
    done
    echo "|  Wollen Sie den User $USER in der Gruppe $GRUPPE"
    echo -n "|  wirklich anlegen (j/n): "
    read OK
    if [ `echo $OK | grep -i ^j$` ]; then
      echo "useradd -m -g $GRUPPE -c \"$KOMM\" $USERNAME"
      echo "echo -e "${PASS1}\n${PASS1}" | passwd $USERNAME > /dev/null 2>&1"
    else
      exit 3
    fi
  fi
}
##
# Löscht einen vorhandenen User
function del_user(){
  echo -n "|  Geben Sie den zu löschenden User ein : "
  read USERNAME
  if [ `grep -c "^${USERNAME}:" /etc/passwd ` == 1 ]; then
    echo -n "|  Soll das Heimatverzeichnis auch gelöscht werden (j/n): "
    read OK
    if [ `echo $OK | grep -i ^j$` ]; then
      echo "userdel -r $USERNAME"
    else
      echo "userdel $USERNAME"
    fi
  else
    echo "|  Sorry, diesen Benutzer gibt es nicht..."
    exit 4
  fi
}
##
# Fügt eine Gruppe hinzu 
function add_group(){
  echo -n "|  Namen der Gruppe, die angelegt werden soll: "
  read GRUPPE
  echo -n "|  Testen, ob es diese Gruppe gibt: "
  if [ `grep "^${GRUPPE}:" /etc/group` ]; then
    echo "Fehler: Gruppe gibt es schon!"
    exit 8
  else
    echo "ok!"
    echo "|  groupadd $GRUPPE"
    exit 0
  fi
}
##
# Löscht eine vorhanden Gruppe
function del_group(){
  echo -n "|  Welche Gruppe soll gelöscht werden? "
  read GRUPPE
  echo -n "|  Testen, ob es diese Gruppe gibt: "
  if [ `grep "^${GRUPPE}:" /etc/group` ]; then
    echo "ok!"
    # Gruppenid auslesen
    GID=`cat /etc/group | grep ^${GRUPPE}: | cut -d : -f 3 -`
    echo "|  Testen, ob es noch User in dieser Gruppe gibt: "
    if [ `grep -c "^\w*:x:\w*:${GID}:" /etc/passwd ` ]; then
      echo "|  Folgenden Benutzer gibt es noch in dieser Gruppe :"
      for I in `grep "^\w*:x:\w*:${GID}:" /etc/passwd | cut -d : -f 1 -`; do
        echo "|  -> $I"
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
##
# Die Funktion übernimmt die Flusssteuerung der Eingabe
function steuerung(){
  case "$AKTION" in
      ua|UA|uA|Ua)
        add_user
        ;;
      ul|UL|uL|Ul)
        del_user
	;;
      ga|GA|Ga|gA)
        add_group
	;;
      gl|GL|Gl|gL)
        del_group
	;;
  esac
  sleep 1
}

echo "|--------------------------------------------------|"
echo "|  Willkommen zur User- und Gruppenverwaltung      |"
echo "|                                                  |"
echo "|  \ \/ / |   _|  |    \                           |"
echo "|   \  /  |  _|   |   _/                           |"
echo "|   / /   | |__   |  |                             |"
echo "|  /_/    |____|  |__|                             |"
echo "|--------------------------------------------------|"

#######      MAIN     ####################
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
# Testen, ob die Eingabe OK war
if [ `echo $AKTION | egrep -s ^[uUgG][aAlL]$` ];then
  steuerung
elif [ "$AKTION" == "q" ];then
  echo "bye"
  exit 0
else
  echo "Usage: yep <ua|ul|ga|gl> (Parameter optional)"
  exit 1
fi



