<?php
namespace Stackored\CLI;

class ComposeBuilder
{
	protected array $env;
	protected string $templatesRoot;

	public function __construct(array $env, string $templatesRoot)
	{
		$this->env = $env;
		$this->templatesRoot = $templatesRoot;
	}

	protected function enabled(string $key): bool
	{
		return isset($this->env[$key]) && strtolower($this->env[$key]) === 'true';
	}

	protected function includeTemplate(string $envKey, string $templatePath): ?string
	{
		if (!$this->enabled($envKey))
			return null;
		if (!file_exists($templatePath))
			return null;

		return TemplateEngine::render(FileSystem::read($templatePath), $this->env);
	}

	public function build(): string
	{
		$servicesContent = "";
		$volumesContent = "";

		// Detect if Unified Tools should be enabled
		if ($this->enabled('ADMINER_ENABLE') || $this->enabled('PHPMYADMIN_ENABLE')) {
			$this->env['TOOLS_CONTAINER_ENABLE'] = 'true';
		}

		$map = [
			'ENABLE_NGINX' => 'web/nginx/docker-compose.nginx.tpl',
			'ENABLE_HTTPD' => 'web/httpd/docker-compose.httpd.tpl',
			'ENABLE_PHP' => 'php/docker-compose.php.tpl',

			// Databases
			'MYSQL_ENABLE' => 'database/mysql/docker-compose.mysql.tpl',
			'MARIADB_ENABLE' => 'database/mariadb/docker-compose.mariadb.tpl',
			'POSTGRES_ENABLE' => 'database/postgres/docker-compose.postgres.tpl',
			'MONGO_ENABLE' => 'database/mongo/docker-compose.mongo.tpl',
			'PERCONA_ENABLE' => 'database/percona/docker-compose.percona.tpl',
			'CASSANDRA_ENABLE' => 'database/cassandra/docker-compose.cassandra.tpl',
			'COUCHDB_ENABLE' => 'database/couchdb/docker-compose.couchdb.tpl',
			'COUCHBASE_ENABLE' => 'database/couchbase/docker-compose.couchbase.tpl',

			// Caching
			'REDIS_ENABLE' => 'cache/redis/docker-compose.redis.tpl',
			'MEMCACHED_ENABLE' => 'cache/memcached/docker-compose.memcached.tpl',

			// Message Queues
			'RABBITMQ_ENABLE' => 'messaging/rabbitmq/docker-compose.rabbitmq.tpl',
			'NATS_ENABLE' => 'messaging/nats/docker-compose.nats.tpl',
			'KAFKA_ENABLE' => 'messaging/kafka/docker-compose.kafka.tpl',
			'KAFBAT_ENABLE' => 'messaging/kafbat/docker-compose.kafbat.tpl',
			'ACTIVEMQ_ENABLE' => 'messaging/activemq/docker-compose.activemq.tpl',

			// Search & Analytics
			'ELASTICSEARCH_ENABLE' => 'search/elasticsearch/docker-compose.elasticsearch.tpl',
			'MEILISEARCH_ENABLE' => 'search/meilisearch/docker-compose.meilisearch.tpl',
			'SOLR_ENABLE' => 'search/solr/docker-compose.solr.tpl',

			// Monitoring & Observability
			'SONARQUBE_ENABLE' => 'qa/sonarqube/docker-compose.sonarqube.tpl',
			'GRAFANA_ENABLE' => 'monitoring/grafana/docker-compose.grafana.tpl',
			'KIBANA_ENABLE' => 'monitoring/kibana/docker-compose.kibana.tpl',
			'LOGSTASH_ENABLE' => 'monitoring/logstash/docker-compose.logstash.tpl',
			'SENTRY_ENABLE' => 'qa/sentry/docker-compose.sentry.tpl',
			'BLACKFIRE_ENABLE' => 'qa/blackfire/docker-compose.blackfire.tpl',
			'NETDATA_ENABLE' => 'utils/netdata/docker-compose.netdata.tpl',

			// Language Runtimes
			'ENABLE_NODE' => 'languages/node/docker-compose.node.tpl',
			'ENABLE_PYTHON' => 'languages/python/docker-compose.python.tpl',
			'ENABLE_GOLANG' => 'languages/golang/docker-compose.golang.tpl',
			'ENABLE_RUBY' => 'languages/ruby/docker-compose.ruby.tpl',
			'ENABLE_RUST' => 'languages/rust/docker-compose.rust.tpl',

			// Application Servers & Proxies
			'TOMCAT_ENABLE' => 'appserver/tomcat/docker-compose.tomcat.tpl',
			'KONG_ENABLE' => 'appserver/kong/docker-compose.kong.tpl',

			// UNIFIED TOOLS (Replace individual UIs)
			'TOOLS_CONTAINER_ENABLE' => 'ui/tools/docker-compose.tools.tpl',

			// Development Tools
			'MAILHOG_ENABLE' => 'utils/mailhog/docker-compose.mailhog.tpl',
			'NGROK_ENABLE' => 'utils/ngrok/docker-compose.ngrok.tpl',
			'SELENIUM_ENABLE' => 'utils/selenium/docker-compose.selenium.tpl',
			'COMPOSER_ENABLE' => 'tools/composer/docker-compose.composer.tpl',
		];

		foreach ($map as $envKey => $template) {
			$content = $this->includeTemplate($envKey, $this->templatesRoot . '/' . $template);
			if (!$content)
				continue;

			// PRE-FIX: Indent service-level volumes that are wrongly at start of line.
			// Service volumes have list items starting with '-' OR comment lines starting with '#'.
			$content = preg_replace_callback('/^volumes:\s*\n(?:(?:\s*#.*\n)*\s*- .*\n)+/m', function ($matches) {
				return preg_replace('/^/m', '    ', $matches[0]);
			}, $content);

			// Extract services block
			if (preg_match('/services:(.*)/s', $content, $matches)) {
				$block = $matches[1];

				// If there is a top-level volumes block (start of line), stop there
				if (preg_match('/^volumes:/m', $block, $vMatches, PREG_OFFSET_CAPTURE)) {
					$block = substr($block, 0, $vMatches[0][1]);
				}

				// REPAIR: Fix common indentation issues in templates
				// 1. Indent known service properties to 4 spaces if they are at the start of the line
				$keys = 'ports|networks|depends_on|command|environment|image|container_name|restart|build|working_dir|user|healthcheck|cap_add|devices|deploy|logging';
				$block = preg_replace("/^($keys):/m", "    $1:", $block);

				// 2. Indent list items to 4 spaces if they are at the start of the line
				$block = preg_replace('/^(- .*)/m', "    $1", $block);

				// TRAEFIK: Inject labels for UI services
				$block = $this->injectTraefikLabels($envKey, $block);

				$servicesContent .= $block . "\n";
			}

			// Extract volumes block
			if (preg_match('/^volumes:(.*)/sm', $content, $matches)) {
				$volumesContent .= $matches[1] . "\n";
			}
		}

		$final = "services:\n" . $servicesContent;

		if (trim($volumesContent)) {
			$final .= "\nvolumes:\n" . $volumesContent;
		}

		return $final;
	}

	protected function injectTraefikLabels(string $envKey, string $block): string
	{
		$labels = [];
		$suffix = $this->env['DEFAULT_TLD_SUFFIX'] ?? 'loc';
		$sslEnabled = ($this->env['TRAEFIK_ENABLE_SSL'] ?? 'false') === 'true';
		$entrypoint = $sslEnabled ? 'websecure' : 'web';

		// Handle Unified Tools Container
		if ($envKey === 'TOOLS_CONTAINER_ENABLE') {
			$tools = [
				'adminer' => ['port' => 80, 'url_var' => 'ADMINER_URL'],
				'phpmyadmin' => ['port' => 80, 'url_var' => 'PHPMYADMIN_URL'],
				'phppgadmin' => ['port' => 80, 'url_var' => 'PHPPGADMIN_URL'],
				'phpmongo' => ['port' => 80, 'url_var' => 'PHPMONGO_URL'],
				'phpmemcachedadmin' => ['port' => 80, 'url_var' => 'MEMCACHED_URL'],
				'opcache' => ['port' => 80, 'url_var' => 'OPCACHE_URL'],
			];

			$labels[] = "      - \"traefik.enable=true\"";
			// Define a single service for this container since all tools are on port 80
			$labels[] = "      - \"traefik.http.services.tools.loadbalancer.server.port=80\"";

			foreach ($tools as $tool => $config) {
				$urlVar = $config['url_var'];
				$customUrl = $this->env[$urlVar] ?? $tool;
				$host = "{$customUrl}.{$suffix}";
				$labels[] = "      - \"traefik.http.routers.{$tool}.rule=Host(`{$host}`)\"";
				$labels[] = "      - \"traefik.http.routers.{$tool}.service=tools\"";
				$labels[] = "      - \"traefik.http.routers.{$tool}.entrypoints={$entrypoint}\"";

				if ($sslEnabled) {
					$labels[] = "      - \"traefik.http.routers.{$tool}.tls=true\"";
				}
			}
		}
		// Handle Legacy/Standalone UI Tools
		else {
			$uiMap = [
				'RABBITMQ_ENABLE' => ['service' => 'rabbitmq', 'port' => 15672, 'url_var' => 'RABBITMQ_URL'],
				'MAILHOG_ENABLE' => ['service' => 'mailhog', 'port' => 8025, 'url_var' => 'MAILHOG_URL'],
				'KIBANA_ENABLE' => ['service' => 'kibana', 'port' => 5601, 'url_var' => 'KIBANA_URL'],
				'GRAFANA_ENABLE' => ['service' => 'grafana', 'port' => 3000, 'url_var' => 'GRAFANA_URL'],
				'SONARQUBE_ENABLE' => ['service' => 'sonarqube', 'port' => 9000, 'url_var' => 'SONARQUBE_URL'],
				'SENTRY_ENABLE' => ['service' => 'sentry', 'port' => 9000, 'url_var' => 'SENTRY_URL'],
				'MEILISEARCH_ENABLE' => ['service' => 'meilisearch', 'port' => 7700, 'url_var' => 'MEILISEARCH_URL'],
				'TOMCAT_ENABLE' => ['service' => 'tomcat', 'port' => 8080, 'url_var' => 'TOMCAT_URL'],
				'KONG_ENABLE' => ['service' => 'kong', 'port' => 8001, 'url_var' => 'KONG_ADMIN_URL'],
				'NETDATA_ENABLE' => ['service' => 'netdata', 'port' => 19999, 'url_var' => 'NETDATA_URL'],
				'KAFBAT_ENABLE' => ['service' => 'kafbat-ui', 'port' => 8080, 'url_var' => 'KAFBAT_URL'],
				'ACTIVEMQ_ENABLE' => ['service' => 'activemq', 'port' => 8161, 'url_var' => 'ACTIVEMQ_URL'],
				'TRAEFIK_ENABLE' => ['service' => 'traefik', 'port' => 8080, 'url_var' => 'TRAEFIK_URL'],
			];

			if (isset($uiMap[$envKey])) {
				$serviceName = $uiMap[$envKey]['service'];
				$internalPort = $uiMap[$envKey]['port'];
				$urlVar = $uiMap[$envKey]['url_var'];
				$customUrl = $this->env[$urlVar] ?? $serviceName;
				$host = "{$customUrl}.{$suffix}";

				$labels[] = "      - \"traefik.enable=true\"";
				$labels[] = "      - \"traefik.http.routers.{$serviceName}.rule=Host(`{$host}`)\"";
				$labels[] = "      - \"traefik.http.routers.{$serviceName}.service={$serviceName}\"";
				$labels[] = "      - \"traefik.http.routers.{$serviceName}.entrypoints={$entrypoint}\"";
				$labels[] = "      - \"traefik.http.services.{$serviceName}.loadbalancer.server.port={$internalPort}\"";

				if ($sslEnabled) {
					$labels[] = "      - \"traefik.http.routers.{$serviceName}.tls=true\"";
				}
			}
		}

		if (empty($labels)) {
			return $block;
		}

		// Inject labels
		if (preg_match('/^\s*labels:\s*/m', $block)) {
			$block = preg_replace('/(^\s*labels:\s*\n)/m', "$1" . implode("\n", $labels) . "\n", $block);
		} else {
			$block .= "\n    labels:\n" . implode("\n", $labels) . "\n";
		}

		return $block;
	}
}
