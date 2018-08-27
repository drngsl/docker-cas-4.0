docker-cas-4.0
==============

###build docker cas-4.0 image
>docker build -t cas4 .

###run samba4

* default
>docker run -d -p 9999:8080 cas4

* ldap
>docker run -d \
     -e CAS_BACKEND=ldap \
     -e LDAP_URL=ldap://DRNGSL.local:389 \
     -e LDAP_DOMAIN=DRNGSL.LOCAL \
     -e LDAP_BASEDN=ou=UserOU,dc=DRNGSL,dc=LOCAL \
     cas4

