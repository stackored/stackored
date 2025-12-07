###################################################################
# STACKORED APACHE DEFAULT CONFIG
###################################################################

ServerTokens Prod
ServerSignature Off
TraceEnable Off

KeepAlive On
MaxKeepAliveRequests 200
KeepAliveTimeout 5

# Enable necessary modules
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule headers_module modules/mod_headers.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule expires_module modules/mod_expires.so
LoadModule mime_module modules/mod_mime.so
LoadModule alias_module modules/mod_alias.so
LoadModule dir_module modules/mod_dir.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule status_module modules/mod_status.so

# Document root placeholder for catch-all
DocumentRoot /var/www/html

# Global security rules
<Directory />
AllowOverride none
Require all denied
</Directory>

<Directory "/var/www">
Options FollowSymLinks
AllowOverride All
Require all granted
</Directory>

# Prevent serving sensitive files
<FilesMatch "\.(env|git|ht|log|yml|yaml)$">
Require all denied
</FilesMatch>

# Compression
AddOutputFilterByType DEFLATE text/plain text/html text/css application/javascript application/json text/xml application/xml

# Logging
ErrorLog /proc/self/fd/2
CustomLog /proc/self/fd/1 combined

# Include dynamically generated vhosts
IncludeOptional /usr/local/apache2/conf/vhosts/vhost-*.conf
