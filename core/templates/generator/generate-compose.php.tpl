<?php
/*******************************************************************
 * STACKORED DYNAMIC COMPOSE GENERATOR
 * Builds docker-compose.dynamic.yml from enabled modules.
 ******************************************************************/

$envFile = __DIR__ . '/../../../.env';
$templatesRoot = __DIR__ . '/../..';
$output = __DIR__ . '/../../../docker-compose.dynamic.yml';

if (!file_exists($envFile)) {
    die("Missing .env file.\n");
}

$env = [];
foreach (file($envFile, FILE_IGNORE_NEW_LINES) as $line) {
    if (strpos($line, '=') !== false) {
        [$k, $v] = explode('=', $line, 2);
        $env[trim($k)] = trim($v);
    }
}

$sections = [];

/*******************************************************************
 * Helper to include a template based on ENABLE flags
 ******************************************************************/
function includeIfEnabled($name, $envKey, $templatePath) {
    global $env, $sections;

    if (!isset($env[$envKey]) || strtolower($env[$envKey]) !== 'true') return;

    if (file_exists($templatePath)) {
        $sections[] = file_get_contents($templatePath);
    }
}

/*******************************************************************
 * INCLUDE CORE MODULES
 ******************************************************************/
includeIfEnabled('php', 'ENABLE_PHP',        "$templatesRoot/templates/php/docker-compose.php.tpl");
includeIfEnabled('nginx', 'ENABLE_NGINX',    "$templatesRoot/templates/nginx/docker-compose.nginx.tpl");
includeIfEnabled('httpd', 'ENABLE_HTTPD',    "$templatesRoot/templates/httpd/docker-compose.httpd.tpl");

includeIfEnabled('mysql', 'ENABLE_MYSQL',    "$templatesRoot/templates/database/mysql/docker-compose.mysql.tpl");
includeIfEnabled('postgres', 'ENABLE_POSTGRES', "$templatesRoot/templates/database/postgres/docker-compose.postgres.tpl");
includeIfEnabled('mongo', 'ENABLE_MONGO',    "$templatesRoot/templates/database/mongo/docker-compose.mongo.tpl");

includeIfEnabled('redis', 'ENABLE_REDIS',    "$templatesRoot/templates/cache/redis/docker-compose.redis.tpl");
includeIfEnabled('memcached', 'ENABLE_MEMCACHED', "$templatesRoot/templates/cache/memcached/docker-compose.memcached.tpl");

includeIfEnabled('rabbitmq', 'ENABLE_RABBITMQ', "$templatesRoot/templates/messaging/rabbitmq/docker-compose.rabbitmq.tpl");
includeIfEnabled('nats', 'ENABLE_NATS', "$templatesRoot/templates/messaging/nats/docker-compose.nats.tpl");
includeIfEnabled('kafka', 'ENABLE_KAFKA', "$templatesRoot/templates/messaging/kafka/docker-compose.kafka.tpl");

includeIfEnabled('meilisearch', 'ENABLE_MEILISEARCH', "$templatesRoot/templates/search/meilisearch/docker-compose.meilisearch.tpl");
includeIfEnabled('elasticsearch', 'ENABLE_ELASTICSEARCH', "$templatesRoot/templates/search/elasticsearch/docker-compose.elasticsearch.tpl");
includeIfEnabled('solr', 'ENABLE_SOLR', "$templatesRoot/templates/search/solr/docker-compose.solr.tpl");

includeIfEnabled('mailhog', 'ENABLE_MAILHOG', "$templatesRoot/templates/utils/mailhog/docker-compose.mailhog.tpl");
includeIfEnabled('ngrok', 'ENABLE_NGROK', "$templatesRoot/templates/utils/ngrok/docker-compose.ngrok.tpl");
includeIfEnabled('netdata', 'ENABLE_NETDATA', "$templatesRoot/templates/utils/netdata/docker-compose.netdata.tpl");
includeIfEnabled('selenium', 'ENABLE_SELENIUM', "$templatesRoot/templates/utils/selenium/docker-compose.selenium.tpl");

includeIfEnabled('python', 'ENABLE_PYTHON', "$templatesRoot/templates/languages/python/docker-compose.python.tpl");
includeIfEnabled('golang', 'ENABLE_GOLANG', "$templatesRoot/templates/languages/golang/docker-compose.golang.tpl");
includeIfEnabled('ruby', 'ENABLE_RUBY', "$templatesRoot/templates/languages/ruby/docker-compose.ruby.tpl");
includeIfEnabled('rust', 'ENABLE_RUST', "$templatesRoot/templates/languages/rust/docker-compose.rust.tpl");

/*******************************************************************
 * WRITE FINAL COMPOSE FILE
 ******************************************************************/
$finalYaml = implode("\n\n", $sections);
file_put_contents($output, $finalYaml);

echo \"[OK] docker-compose.dynamic.yml generated.\\n\";
