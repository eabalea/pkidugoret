#! /bin/sh

if [ -z $1 ]; then
  echo "I need a .pem file to work with."
  exit
fi

if [ `grep -c "BEGIN X509 CRL" $1` -gt 0 ]; then
  echo "File contains a CRL"
  HASH=`openssl crl -hash -noout -inform PEM -in "$1"`
  echo "Hash is: $HASH"

  for i in `seq 0 10`; do
    if [ ! -f $HASH.r$i ]; then
      ln -s "$1" $HASH.r$i
      break
    else
      echo "Link $HASH.r$i is already used"
    fi
  done
else
  if [ ` grep -c "BEGIN CERTIFICATE" $1` -gt 0 ]; then
    echo "File contains a certificate"
    HASH=`openssl x509 -hash -noout -inform PEM -in "$1"`
    echo "Hash is: $HASH"

    for i in `seq 0 10`; do
      if [ ! -f $HASH.$i ]; then
        ln -s "$1" $HASH.$i
        break
      else
        echo "Link $HASH.$i is already used"
      fi
    done
  else
    echo "That file doesn't contain a CRL or a certificate."
  fi
fi

