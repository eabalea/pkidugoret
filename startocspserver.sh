#! /bin/sh

openssl ocsp -index database/IRAN01/index.txt -CA database/IRAN01/cacert.pem -rsigner database/IRAN01/cacert.pem -rkey database/IRAN01/private/cakey.pem -port 1234
