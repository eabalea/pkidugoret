#! /bin/sh

updatedb() {
  TEMP=`getopt -o c:d:h --long ca:,days:,help -n 'updatedb.sh' -- "$@"`
  DAYS=30

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -c|--ca) CA=$2; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -h|--help) echo "Options:"
		 echo "  -c|--ca <ca>"
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

  echo "====="
  echo "Mise à jour de la base de données de l'AC $CA"
  openssl ca -config conf/$CA.cnf -updatedb
  echo "====="
}

updatedb "$@"
