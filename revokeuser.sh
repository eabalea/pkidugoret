#! /bin/sh

revokeenduser() {
  TEMP=`getopt -o i:c:h --long id:,ca:,help -n 'revokeuser.sh' -- "$@"`

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|--id) ID=$2; shift 2;;
      -c|--ca) CA=$2; shift 2;;
      -h|--help) echo "Options:"
                 echo "  -i|--id <id>"
		 echo "  -c|--ca <ca>"
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

  if [ -z "$ID" ]; then
    echo "User identifier is missing."
    exit 1
  fi

  echo "====="
  echo "Revoking user $ID, issued by CA $CA"
  openssl ca -utf8 -config conf/$CA.cnf -revoke users/$CA-$ID.crt
  echo "====="
}

revokeenduser "$@"
