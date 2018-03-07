#!/bin/bash

##从头签发Let's Encrypt免费SSL证书
DOMAINS="DNS:xx.xx.com,DNS:yy.yy.com"
CHALLENGE_DIR="/var/www/challenges/"

cd $(dirname $0)

##生成Let's Encrypt用户私钥
if [ ! -f account.key ];then
    echo "Create a Let's Encrypt account private key"
    openssl genrsa 4096 > account.key
fi

##生成domain私钥
if [ ! -f domain.key ];then
    echo "Create a domain private key"
    openssl genrsa 4096 > domain.key
fi

##生成openssl配置文件，添加需要签名的domain
OPENSSL_CONF="/etc/ssl/openssl.cnf"
if [ ! -f ${OPENSSL_CONF} ];then
    OPENSSL_CONF="/etc/pki/tls/openssl.cnf"
    if [ ! -f ${OPENSSL_CONF} ];then
        echo "openssl.cnf not found"
        exit 1
    fi
fi
cat ${OPENSSL_CONF} > openssl.cnf
printf "[SAN]\nsubjectAltName=${DOMAINS}" >> openssl.cnf

##生成domain证书签名请求
echo "Create a CSR(certificate signing request) for domains"
openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config openssl.cnf > domain.csr

##准备nginx的challenge目录

##获取acme_tiny.py脚本
wget -O - https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py > acme_tiny.py

##获取签名证书
python acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir ${CHALLENGE_DIR} > ./signed.crt

##获取中间证书
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem

##生成最终使用的证书链
cat signed.crt intermediate.pem > chained.pem
