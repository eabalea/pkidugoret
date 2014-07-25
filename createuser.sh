#! /bin/sh

createenduser() {
  TEMP=`getopt -o i:c:s:t:e:k:d:p:h --long id:,ca:,subject:,keytype:,ecurve:keysize:,days:,profile:,passphrase:,help -n 'createuser.sh' -- "$@"`
  KEYSIZE=2048
  KEYTYPE=rsa
  ECURVE=prime256v1
  DAYS=30
  PROFILE=v3_user
  PASSPHRASE=69866640

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|--id) ID=$2; shift 2;;
      -c|--ca) CA=$2; shift 2;;
      -s|--subject) SUBJECTDN="$2"; shift 2;;
      -t|--keytype) KEYTYPE=$2; shift 2;;
      -e|--ecurve) ECURVE=$2; shift 2;;
      -k|--keysize) KEYSIZE=$2; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -p|--profile) PROFILE=$2; shift 2;;
      --passphrase) PASSPHRASE="$2"; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--id <id>"
		 echo "  -c|--ca <ca>"
		 echo "  -s|--subject <subject>"
		 echo " (-t|--keytype <algo>)     # default rsa (dsa,ec)"
		 echo " (-e|--ecurve <curvename>) # default prime256v1"
		 echo " (-k|--key <keysize>)      # default 2048"
		 echo " (-d|--days <days>)        # default 30"
		 echo " (-p|--profile <profile>)  # default v3_user"
		 echo " (--passphrase <pwd>)      # default 69866640"
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

  if [ -z "$SUBJECTDN" ]; then
    echo "Il faut nommer le certificat"
    exit 1
  fi

  case $KEYTYPE in
    rsa|dsa|ec) ;;
    *) echo "Mauvais type de clé"; exit 1;;
  esac

  echo "====="
  echo "Création du end-user $ID, ayant pour nom $SUBJECTDN, signée par l'AC $CA"
  echo "Génération de la clé privée"
  case $KEYTYPE in
    rsa) openssl genrsa -out users/$CA-$ID.key $KEYSIZE
         ;;
    dsa) openssl dsaparam -genkey -out users/$CA-$ID.key $KEYSIZE
         ;;
    ec) openssl ecparam -genkey -name $ECURVE -out users/$CA-$ID.key
        ;;
  esac
  echo "Génération de la requête" && openssl req -utf8 -new -config conf/$CA.cnf -key users/$CA-$ID.key -batch -out users/$CA-$ID.req -subj "$SUBJECTDN"
  SECRETKEY=`od -t x1 -A n database/$CA/private/secretkey | sed 's/ //g' | tr 'a-f' 'A-F'`
  COUNTER=`cat database/$CA/counter`
  echo `expr $COUNTER + 1` > database/$CA/counter
  SERIAL=`echo -n $COUNTER | openssl enc -e -K $SECRETKEY -iv 00000000000000000000000000000000 -aes-128-cbc | od -t x1 -A n | sed 's/ //g' | tr 'a-f' 'A-F'`
  echo $SERIAL > database/$CA/serial
  echo "Création du certificat" && openssl ca -utf8 -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch
  echo "Création du PKCS#12" && openssl pkcs12 -export -in users/$CA-$ID.crt -inkey users/$CA-$ID.key -password "pass:$PASSPHRASE" -out users/$CA-$ID.p12 -CApath store -chain
  echo "Suppression de la requête inutile" && rm users/$CA-$ID.req
  echo "====="
}

createenduser "$@"

