#! /bin/sh

signsubca() {
  TEMP=`getopt -o i:c:s:d:r:p:h --long issuer:,ca:,subject:,days:,request:,profile:,help -n 'signsubca.sh' -- "$@"`
  KEYSIZE=2048
  DAYS=3650
  PROFILE=v3_subca

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|--issuer) ISSUERCA=$2; shift 2;;
      -c|--ca) CA=$2; shift 2;;
      -s|--subject) SUBJECTDN="$2"; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -r|--request) REQUEST=$2; shift 2;;
      -p|--profile) PROFILE=$2; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--issuer <issuerca>"
		 echo "  -c|--ca <ca>"
		 echo "  -r|--request <request file>"
		 echo " (-s|--subject <subject>)"
		 echo " (-d|--days <days>)        # default 3650"
		 echo " (-p|--profile <profile>)  # default v3_subca"
		 shift
		 exit 1
		 ;;
      --) shift; break;;
      *) echo "internal error"; exit 1;;
    esac
  done

  if [ -z "$ISSUERCA" ]; then
    echo "Issuing CA identifier is missing."
    exit 1
  fi

  if [ -z "$CA" ]; then
    echo "CA identifier is missing."
    exit 1
  fi

  if [ -z "$REQUEST" ]; then
    echo "Certificate request is missing."
    exit 1
  fi

  echo "====="
  echo "Signing subordinate CA certificate $CA, named $SUBJECTDN, issued by CA $ISSUERCA"
  SECRETKEY=`od -t x1 -A n database/$ISSUERCA/private/secretkey | sed 's/ //g' | tr 'a-f' 'A-F'`
  COUNTER=`cat database/$ISSUERCA/counter`
  echo `expr $COUNTER + 1` > database/$ISSUERCA/counter
  SERIAL=`echo -n $COUNTER | openssl enc -e -K $SECRETKEY -iv 00000000000000000000000000000000 -aes-128-cbc | od -t x1 -A n | sed 's/ //g' | tr 'a-f' 'A-F'`
  echo $SERIAL > database/$ISSUERCA/serial
  echo "Creating certificate" && [ -z "$SUBJECTDN" ] && (openssl ca -utf8 -config conf/$ISSUERCA.cnf -in $REQUEST -days $DAYS -out store/$ISSUERCA-$CA.pem -extensions $PROFILE -batch) || (openssl ca -utf8 -multivalue-rdn -config conf/$ISSUERCA.cnf -in $REQUEST -days $DAYS -out store/$ISSUERCA-$CA.pem -extensions $PROFILE -batch -subj "$SUBJECTDN")
  echo "Updating store" && cd store && ./hashit.sh $ISSUERCA-$CA.pem
  echo "====="
}

signsubca "$@"
