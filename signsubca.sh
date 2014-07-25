#! /bin/sh

signsubca() {
  TEMP=`getopt -o i:c:s:d:r:h --long issuer:,ca:,subject:,days:,request:,help -n 'signsubca.sh' -- "$@"`
  KEYSIZE=2048
  DAYS=3650

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|--issuer) ISSUERCA=$2; shift 2;;
      -c|--ca) CA=$2; shift 2;;
      -s|--subject) SUBJECTDN="$2"; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -r|--request) REQUEST=$2; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--issuer <issuerca>"
		 echo "  -c|--ca <ca>"
		 echo "  -s|--subject <subject>"
		 echo "  -r|--request <request file>"
		 echo " (-d|--days <days>)        # default 3650"
		 shift
		 exit 1
		 ;;
      --) shift; break;;
      *) echo "internal error"; exit 1;;
    esac
  done

  if [ -z "$ISSUERCA" ]; then
    echo "Il faut l'identifiant de l'AC émettrice"
    exit 1
  fi

  if [ -z "$CA" ]; then
    echo "Il faut l'identifiant de l'AC"
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
  echo "Création de l'AC fille $CA, ayant pour nom $SUBJECTDN, signée par l'AC $ISSUERCA"
  SECRETKEY=`od -t x1 -A n database/$ISSUERCA/private/secretkey | sed 's/ //g' | tr 'a-f' 'A-F'`
  COUNTER=`cat database/$ISSUERCA/counter`
  echo `expr $COUNTER + 1` > database/$ISSUERCA/counter
  SERIAL=`echo -n $COUNTER | openssl enc -e -K $SECRETKEY -iv 00000000000000000000000000000000 -aes-128-cbc | od -t x1 -A n | sed 's/ //g' | tr 'a-f' 'A-F'`
  echo $SERIAL > database/$ISSUERCA/serial
  #echo "Création du certificat" && openssl ca -utf8 -config conf/$ISSUERCA.cnf -in database/$CA/careq.pem -days $DAYS -out database/$CA/cacert.pem -extensions v3_subca -batch
  echo "Création du certificat" && openssl ca -utf8 -config conf/$ISSUERCA.cnf -in $REQUEST -days $DAYS -out store/$ISSUERCA-$CA.pem -extensions v3_subca -batch
  echo "Mise à jour du store" && cd store && ./hashit.sh $ISSUERCA-$CA.pem
  echo "====="
}

signsubca "$@"
