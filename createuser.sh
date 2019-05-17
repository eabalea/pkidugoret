#! /bin/sh

createenduser() {
  getopt -T > /dev/null
  if [ $? -eq 4 ]; then
    # GNU enhanced getopt is available
    TEMP=`getopt --option i:c:s:t:e:k:d:p:a:h --long issuer:,ca:,subject:,keytype:,ecurve:,keysize:,days:,profile:,passphrase:,help --name "$0" -- "$@"`
  else
    # Original getopt is available (no long option names, no whitespace, no sorting)
    echo "long option and whitespace are not supported with this version of getopt"
    TEMP=`getopt i:c:s:t:e:k:d:p:a:h "$@"`
  fi
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
      -a|--passphrase) PASSPHRASE="$2"; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--id <id>"
		 echo "  -c|--ca <ca>"
		 echo "  -s|--subject <subject>"
		 echo " (-t|--keytype <algo>)     # default rsa (dsa,ec)"
		 echo " (-e|--ecurve <curvename>) # default prime256v1"
		 echo " (-k|--key <keysize>)      # default 2048"
		 echo " (-d|--days <days>)        # default 30"
		 echo " (-p|--profile <profile>)  # default v3_user"
		 echo " (-a|--passphrase <pwd>)   # default 69866640"
		 shift
		 exit 1
		 ;;
      --) shift; break;;
      *) echo "internal error"; exit 1;;
    esac
  done

  if [ -z "$CA" ]; then
    echo "CA identifier is missing."
    exit 1
  fi

  if [ ! -f conf/$CA.cnf ]; then
    echo "CA configuration file is missing."
    exit 1
  fi

  if [ -z "$ID" ]; then
    echo "User identifier is missing."
    exit 1
  fi

  if [ -z "$SUBJECTDN" ]; then
    echo "User subject name is missing."
    exit 1
  fi

  case $KEYTYPE in
    rsa|dsa|ec) ;;
    *) echo "Wrong key type."; exit 1;;
  esac

  echo "====="
  echo "Creating end-user $ID, named $SUBJECTDN, issued by CA $CA"
  echo "Generating user private key"
  case $KEYTYPE in
    rsa) openssl genrsa -out users/$CA-$ID.key $KEYSIZE
         ;;
    dsa) openssl dsaparam -genkey -out users/$CA-$ID.key $KEYSIZE
         ;;
    ec) openssl ecparam -genkey -name $ECURVE -out users/$CA-$ID.key
        ;;
  esac
  echo "Generating user certificate request" && openssl req -utf8 -new -config conf/$CA.cnf -key users/$CA-$ID.key -batch -out users/$CA-$ID.req -subj "$SUBJECTDN"
  SECRETKEY=`od -t x1 -A n database/$CA/private/secretkey | sed 's/ //g' | tr 'a-f' 'A-F'`
  COUNTER=`cat database/$CA/counter`
  echo `expr $COUNTER + 1` > database/$CA/counter
  SERIAL=`echo -n $COUNTER | openssl enc -e -K $SECRETKEY -iv 00000000000000000000000000000000 -aes-128-cbc | od -t x1 -A n | sed 's/ //g' | tr 'a-f' 'A-F'`
  echo $SERIAL > database/$CA/serial
  echo "Creating user certificate" && openssl ca -utf8 -multivalue-rdn -config conf/$CA.cnf -in users/$CA-$ID.req -days $DAYS -out users/$CA-$ID.crt -extensions $PROFILE -batch
  echo "Creating PKCS#12 object" && openssl pkcs12 -export -in users/$CA-$ID.crt -inkey users/$CA-$ID.key -password "pass:$PASSPHRASE" -out users/$CA-$ID.p12 -CApath store -chain
  echo "Deleting certificate request" && rm users/$CA-$ID.req
  echo "====="
}

createenduser "$@"
