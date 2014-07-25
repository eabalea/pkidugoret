#! /bin/sh

signenduser() {
  TEMP=`getopt -o i:c:s:d:r:p:h --long id:,ca:,subject:,days:,request:,profile:,help -n 'signenduser.sh' -- "$@"`
  KEYSIZE=2048
  DAYS=30
  PROFILE=v3_user

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|--id) ID=$2; shift 2;;
      -c|--ca) CA=$2; shift 2;;
      -s|--subject) SUBJECTDN="$2"; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -p|--profile) PROFILE=$2; shift 2;;
      -r|--request) REQUEST=$2; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--id <id>"
		 echo "  -c|--ca <ca>"
		 echo "  -r|--request <request file>"
		 echo " (-s|--subject <subject>)"
		 echo " (-d|--days <days>)        # default 30"
		 echo " (-p|--profile <profile>)  # default v3_user"
		 shift
		 exit 1
		 ;;
      --) shift; break;;
      *) echo "internal error"; exit 1;;
    esac
  done

  if [ -z "$CA" ]; then
    echo "Il faut l'identifiant de l'AC"
    exit 1
  fi

  if [ -z "$ID" ]; then
    echo "Il faut un identifiant pour ce certificat"
    exit 1
  fi

  #if [ -z "$SUBJECTDN" ]; then
  #  echo "Il faut nommer le certificat"
  #  exit 1
  #fi

  if [ -z "$REQUEST" ]; then
    echo "Il faut une requête à signer"
    exit 1
  fi

  echo "====="
  echo "Signature du end-user $ID, ayant pour nom $SUBJECTDN, signée par l'AC $CA"
  echo "Recopie de la requête" && openssl req -utf8 -in $REQUEST -out users/$CA-$ID.req
  SECRETKEY=`od -t x1 -A n database/$CA/private/secretkey | sed 's/ //g' | tr 'a-f' 'A-F'`
  COUNTER=`cat database/$CA/counter`
  echo `expr $COUNTER + 1` > database/$CA/counter
  SERIAL=`echo -n $COUNTER | openssl enc -e -K $SECRETKEY -iv 00000000000000000000000000000000 -aes-128-cbc | od -t x1 -A n | sed 's/ //g' | tr 'a-f' 'A-F'`
  echo $SERIAL > database/$CA/serial
  #echo "Création du certificat" && openssl ca -utf8 -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch -subj "$SUBJECTDN"
  echo "Création du certificat" && [ -z "$SUBJECTDN" ] && (openssl ca -utf8 -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch) || (openssl ca -utf8 -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch -subj "$SUBJECTDN")
  #echo "Création du certificat" && openssl ca -utf8 -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch
  echo "Suppression de la requête inutile" && rm users/$CA-$ID.req
  echo "====="
}

signenduser "$@"

