###################################################################
# PROJECT ENV TEMPLATE
###################################################################

APP_NAME="{{ PROJECT_NAME }}"
APP_DOMAIN="{{ PROJECT_DOMAIN }}"
APP_PHP_VERSION="{{ PROJECT_PHP | default(DEFAULT_PHP_VERSION) }}"
APP_WEBSERVER="{{ PROJECT_WEBSERVER | default(DEFAULT_WEBSERVER) }}"
APP_DOCROOT="{{ PROJECT_DOCROOT | default(DEFAULT_DOCUMENT_ROOT) }}"

# Override allowed services
USE_MYSQL="{{ PROJECT_USE_MYSQL }}"
USE_REDIS="{{ PROJECT_USE_REDIS }}"
USE_RABBITMQ="{{ PROJECT_USE_RABBITMQ }}"
USE_ELASTICSEARCH="{{ PROJECT_USE_ELASTICSEARCH }}"

# Override PHP extensions
PHP_EXTENSIONS="{{ PROJECT_PHP_EXTENSIONS | default('pdo,mbstring,openssl,json') }}"
