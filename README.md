Let's encrypt免费SSL证书签发指南

准备工作：
1、准备需要签发证书的域名列表，如：
    DNS:xxxx.xxxx.com,DNS:yyyy.yyyy.cn,DNS:zzzz.zzzz.io
	不支持泛域名
	
2、将所有域名的公网DNS解析，解析到本地公网IP

3、本地Nginx准备对应domain的challenge目录
server {
    listen 80 default_server;
    server_name yoursite.com;

    location /.well-known/acme-challenge/ {
        alias /var/www/challenges/;  # your challenges dir
        try_files $uri =404;
    }
}

4、更改脚本内DOMAINS和CHALLENGE_DIR变量，执行脚本