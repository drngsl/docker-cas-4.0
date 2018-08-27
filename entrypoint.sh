#!/bin/bash

casPropFile="/usr/local/tomcat/webapps/cas/WEB-INF/cas.properties"

updateConf() {
    key=$1
    value=$2
    file=$3
    sed -i "s#\(^${key}[\t]*=\)\(.*$\)#\1${value}#g" "${file}"
}

# set access protocol for CAS
useHttps=`echo "${CAS_USE_HTTPS:-false}" | tr '[A-Z]' '[a-z]'`
if [ "$useHttps"x == "false"x ]; then
    echo "not use https"
    updateConf "http.requireSecure" false "${casPropFile}"
    updateConf "http.cookieSecure" false "${casPropFile}"
    updateConf "cas.registerServiceEnabled" false "${casPropFile}"
elif [ "$useHttps"x == "true"x ]; then
    echo "use https"
    updateConf "http.requireSecure" true "${casPropFile}"
    updateConf "http.cookieSecure" true "${casPropFile}"
    updateConf "cas.registerServiceEnabled" true "${casPropFile}"
else
    echo "invalid ENV CAS_USE_HTTPS=${useHttps}"
    exit 1
fi

# set backend for CAS
enabledBackend=('default' 'ldap')
for a in ${enabledBackend[@]}
do
   echo $a
done
backend="${CAS_BACKEND:-default}"
backendExisted=`echo ${enabledBackend[*]} | awk -v v="$backend" '{for (i=1;i<=NF;i++) a[$i]}END{if (v in a) print "exist";else print "not exist"}'`
if [ "$backendExisted"x != "exist"x ]; then
    echo "unsupported backend $backend"
    exit 2
fi
updateConf backend $backend "$casPropFile"

if [ "$backend"x == "ldap"x ]; then
    echo "use ldap as backend"
    ldapUrl=${LDAP_URL:-ldap://DRNGSL.LOCAL:389}
    ldapDomain=${LDAP_DOMAIN:-drngsl.local}
    ldapBaseDn=${LDAP_BASEDN:-ou=UserOU,dc=DRNGSL,dc=LOCAL}
    updateConf "ldap.url" "$ldapUrl" "${casPropFile}"
    updateConf "ldap.domain" "$ldapDomain" "${casPropFile}"
    updateConf "ldap.baseDn" "$ldapBaseDn" "${casPropFile}"
    ldapIp=${LDAP_IP}
    if [[ "$ldapIp"x != ""x && `grep "$ldapDomain" /etc/hosts | wc -l` -eq 0 ]]; then
        echo "$ldapIp $ldapDomain" >> /etc/hosts
    fi
fi

# start tomcat
bash /usr/local/tomcat/bin/startup.sh

while [ true ];
do
    sleep 60
done

