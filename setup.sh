#!/bin/bash

yum install httpd php -y

cat <<EOF > /var/www/html/index.php
<?php
echo "<h1><center>Hello! World!</center></h1>"
?>
EOF

systemctl restart httpd.service
systemctl enable httpd.service
