#!/bin/sh
yum install -y httpd
service httpd start
chkconfig httpd on
echo "<html><h1>Hello World!! $(hostname)</h2></html>" > /var/www/html/index.html
