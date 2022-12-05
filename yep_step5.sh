#!/bin/bash
clear

##
# Fügt einen User hinzu
function add_user(){
  echo -n "|  Geben Sie den Usernamen ein : "
  read USERNAME
  if [ `grep "^${USERNAME}:" /etc/passwd | cut -d : -f 1 -` ]; then
    echo "|  Sorry, diesen Benutzer gibt es schon..."
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
    echo "|  Wollen Sie den User $USER in der Gruppe $GRUPPE"
    echo -n "|  wirklich anlegen (j/n): "
    read OK
    if [ `echo $OK | grep -i ^j$` ]; then
      echo "useradd -m -g $GRUPPE -c \"$KOMM\" $USERNAME"
    fi
  fi
}
##
# Löscht einen vorhandenen User
function del_user(){
  echo -n "|  Geben Sie den zu löschenden User ein : "
  read USERNAME
  if [ `grep "^${USERNAME}:" /etc/passwd | cut -d : -f 1 -` ]; then
    echo -n "|  Soll das Heimatverzeichnis auch gelöscht werden (j/n): "
    read OK
    if [ `echo $OK | grep -i ^j$` ]; then
      echo "userdel -r $USERNAME"
    else
      echo "userdel $USERNAME"
    fi
  else
    echo "|  Sorry, diesen Benutzer gibt es nicht..."
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
  else
    echo "ok!"
    echo "|  groupadd $GRUPPE"
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
    else
      echo "groupdel $GRUPPE"
    fi
  else
    echo "Fehler: Gruppe gibt es nicht!"
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
  clear
  main
}

echo "|--------------------------------------------------|"
echo "|  \ \/ / |   _|  |    \                           |"
echo "|   \  /  |  _|   |   _/                           |"
echo "|   / /   | |__   |  |                             |"
echo "|  /_/    |____|  |__|                             |"
echo "|--------------------------------------------------|"

#######      MAIN     ####################
function main(){
  if [ "$1" == "" ]; then
    echo "|--------------------------------------------------|"
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
    echo "|  bye bye ;-)"
    exit 0
  else
    echo "|  Usage: yep <ua|ul|ga|gl> (Parameter optional)"
    main
  fi
}

main $1

