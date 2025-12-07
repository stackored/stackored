###################################################################
# STACKORED XDEBUG CONFIG TEMPLATE
###################################################################

zend_extension=xdebug.so

[xdebug]
xdebug.mode=debug,develop
xdebug.start_with_request=yes
xdebug.discover_client_host=true
xdebug.client_host={{ XDEBUG_CLIENT_HOST | default('host.docker.internal') }}
xdebug.client_port={{ XDEBUG_CLIENT_PORT | default('9003') }}
xdebug.log=/var/log/php/xdebug.log
