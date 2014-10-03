pkidugoret
==========

OpenSSL scripts to run a small PKI

createrootca.sh script need's a subject string openssl-ed style. Creating a root CA named TEST with subject 
o = TEST, OU = PURPOSE, CN = ONLY createrootca.sh should be lanched with the following arguments :
./createsubca.sh -c TEST -s "/O=TEST /OU=PURPOSE /CN=ONLY"
