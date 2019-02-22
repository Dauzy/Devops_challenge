#!/bin/sh
yum install -y httpd
service httpd start
chkconfig httpd on
echo "<html><h1>Hello World!! from web server $(hostname -i)</h2></html>" > /var/www/html/index.html
