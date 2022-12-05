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
  USERNAME=`kdialog --inputbox "Geben Sie den zu löschenden User ein :"`
  if [ `grep "^${USERNAME}:" /etc/passwd | cut -d : -f 1 -` ]; then
    kdialog --yesno "Soll das Heimatverzeichnis auch gelöscht werden?"
    OK=`echo $?`
    if [ $OK ]; then
      kdialog --msgbox "userdel -r $USERNAME"
    else
      kdialog --msgbox "userdel $USERNAME"
    fi
  else
    kdialog --error "Sorry, diesen Benutzer gibt es nicht..."
  fi
}
##
# Fügt eine Gruppe hinzu 
function add_group(){
  GRUPPE=`kdialog --inputbox "Namen der Gruppe, die angelegt werden soll:"`
  if [ `grep "^${GRUPPE}:" /etc/group` ]; then
    kdialog --error "Fehler: Gruppe gibt es schon!"
  else
    kdialog --msgbox "Gruppe wurde erfolgreich angelegt!"
  fi
}
##
# Löscht eine vorhanden Gruppe
function del_group(){
  STRING="";
  for I in $(cat /etc/group); do 
    GRUPPE=$(echo $I | cut -d : -f 1);
    GID=$(echo $I | cut -d : -f 3); 
    if [ "$GID" -ge "1000" ]; then 
      STRING="${STRING} \"$GID\" \"$GRUPPE\" \"$GID\" ";
    fi;
  done;
  #GRUPPE=`kdialog --checklist "Gruppen zum löschen auswählen" `;
  GRUPPE=`kdialog --inputbox "Welche Gruppe soll gelöscht werden?"`
  if [ `grep "^${GRUPPE}:" /etc/group` ]; then
    # Gruppenid auslesen
    GID=`cat /etc/group | grep ^${GRUPPE}: | cut -d : -f 3 -`
    if [ `grep -c "^\w*:x:\w*:${GID}:" /etc/passwd ` ]; then
      TEXT="Folgenden Benutzer gibt es noch in dieser Gruppe :"
      for I in `grep "^\w*:x:\w*:${GID}:" /etc/passwd | cut -d : -f 1 -`; do
        USERS=${USERS}"+>  "${I}"\n"
      done
      kdialog --error "$TEXT\n\n$USERS"
    else
      kdialog --msgbox "Gruppe wurde erfolgreich gelöscht!"
    fi
  else
    kdialog --error "Fehler: Gruppe gibt es nicht!"
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

#######      MAIN     ####################
function main(){
  if [ "$1" == "" ]; then
    AKTION=`kdialog --menu "Willkommen zu YEP" "ua" "Neuen User anlegen" "ul" "Vorhandenen User löschen" "ga" "Neue Gruppe anlegen" "gl" "Vorhandene Gruppe löschen" "q" "Programm verlassen"`
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
    kdialog --error "Usage: yep <ua|ul|ga|gl> (Parameter optional)"
  fi
}

main $1

