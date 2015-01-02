pkidugoret
==========

OpenSSL scripts to run a small PKI

Create a ROOT CA
================
createrootca.sh script need's a subject string openssl-ed style. 
Creating a root CA named TEST for the country France with subject o = TEST, OU = PURPOSE, CN = ONLY, createrootca.sh should be launched with the following arguments :
```shell
./createrootca.sh -c TEST -C FR -s "/O=TEST /OU=PURPOSE /CN=ONLY"
```

Create a SUB CA
===============
createasubca.sh script need's a subject string openssl-ed style.
Creating a SUB CA named SUBTEST1 issued by TEST with the subject o = TEST, OU = TEST , CN = TESTSUB1, createasubca.sh should be launched with the following arguments :
```shell
./createsubca.sh -i TEST -c SUBTEST1 -s "/O=TEST /OU=TEST /CN=TESTSUB1"
```

Create a user
=============
createuser.sh script need's a subject string openssl-ed style.
Creating a user called usertest, issued by the SUBTEST1 CA with the subject o = TEST, OU = TEST , CN = usertest1, createuser.sh should be launched with the following arguments :
```shell
./createuser.sh -i usertest -c SUBTEST1 -s "/O=TEST /OU=TEST /CN=usertest1"
```

Revoke au user
==============
Usertest1 was a bad guys or maybe you screwed somewhere, you need to revoke the certificate, revokeuser.sh should be launched nervously with the following arguments :
```shell
./revokeuser.sh -i usertest -c SUBTEST1
```

Create a CRL
============
You want the entire world to know that usertest1 was a ~~n~~ ~~asshole~~ bad guys, you need to create a CRL for the SUB CA called SUBTEST1 for a validity period of 7 days, createcrl.sh should be launched with the following arguments :
```shell
./createcrl.sh -c SUBTEST1 -d 7
```

TODO
====
- Finish README
- Make tests
- Frontend ?
- Buy C41 chemicals for color analog negatives

pkidugoret
==========
Even it's easy, it's not clean
<pre>
      --.__.--
    ___\(0_0)/
~~/     (OO)
  \  __  /
   `='`='=
</pre>
