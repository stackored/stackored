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
		if ($this->enabled('ENABLE_ADMINER') || $this->enabled('ENABLE_PHPMYADMIN')) {
			$this->env['ENABLE_TOOLS_CONTAINER'] = 'true';
		}

		$map = [
			'ENABLE_NGINX' => 'web/nginx/docker-compose.nginx.tpl',
			'ENABLE_HTTPD' => 'web/httpd/docker-compose.httpd.tpl',
			'ENABLE_PHP' => 'php/docker-compose.php.tpl',

			// Databases
			'ENABLE_MYSQL' => 'database/mysql/docker-compose.mysql.tpl',
			'ENABLE_MARIADB' => 'database/mariadb/docker-compose.mariadb.tpl',
			'ENABLE_POSTGRES' => 'database/postgres/docker-compose.postgres.tpl',
			'ENABLE_MONGO' => 'database/mongo/docker-compose.mongo.tpl',
			'ENABLE_PERCONA' => 'database/percona/docker-compose.percona.tpl',
			'ENABLE_CASSANDRA' => 'database/cassandra/docker-compose.cassandra.tpl',
			'ENABLE_COUCHDB' => 'database/couchdb/docker-compose.couchdb.tpl',
			'ENABLE_COUCHBASE' => 'database/couchbase/docker-compose.couchbase.tpl',

			// Caching
			'ENABLE_REDIS' => 'cache/redis/docker-compose.redis.tpl',
			'ENABLE_MEMCACHED' => 'cache/memcached/docker-compose.memcached.tpl',

			// Message Queues
			'ENABLE_RABBITMQ' => 'messaging/rabbitmq/docker-compose.rabbitmq.tpl',
			'ENABLE_NATS' => 'messaging/nats/docker-compose.nats.tpl',
			'ENABLE_KAFKA' => 'messaging/kafka/docker-compose.kafka.tpl',

			// Search & Analytics
			'ENABLE_ELASTICSEARCH' => 'search/elasticsearch/docker-compose.elasticsearch.tpl',
			'ENABLE_MEILISEARCH' => 'search/meilisearch/docker-compose.meilisearch.tpl',
			'ENABLE_SOLR' => 'search/solr/docker-compose.solr.tpl',

			// Monitoring & Observability
			'ENABLE_SONARQUBE' => 'qa/sonarqube/docker-compose.sonarqube.tpl',
			'ENABLE_GRAFANA' => 'monitoring/grafana/docker-compose.grafana.tpl',
			'ENABLE_KIBANA' => 'monitoring/kibana/docker-compose.kibana.tpl',
			'ENABLE_LOGSTASH' => 'monitoring/logstash/docker-compose.logstash.tpl',
			'ENABLE_SENTRY' => 'qa/sentry/docker-compose.sentry.tpl',
			'ENABLE_BLACKFIRE' => 'qa/blackfire/docker-compose.blackfire.tpl',

			// Language Runtimes
			'ENABLE_NODE' => 'languages/node/docker-compose.node.tpl',
			'ENABLE_PYTHON' => 'languages/python/docker-compose.python.tpl',
			'ENABLE_GOLANG' => 'languages/golang/docker-compose.golang.tpl',
			'ENABLE_RUBY' => 'languages/ruby/docker-compose.ruby.tpl',
			'ENABLE_RUST' => 'languages/rust/docker-compose.rust.tpl',

			// Application Servers & Proxies
			'ENABLE_TOMCAT' => 'appserver/tomcat/docker-compose.tomcat.tpl',
			'ENABLE_KONG' => 'appserver/kong/docker-compose.kong.tpl',

			// UNIFIED TOOLS (Replace individual UIs)
			'ENABLE_TOOLS_CONTAINER' => 'ui/tools/docker-compose.tools.tpl',

			// Development Tools
			'ENABLE_MAILHOG' => 'utils/mailhog/docker-compose.mailhog.tpl',
			'ENABLE_NGROK' => 'utils/ngrok/docker-compose.ngrok.tpl',
			'ENABLE_NETDATA' => 'utils/netdata/docker-compose.netdata.tpl',
			'ENABLE_SELENIUM' => 'utils/selenium/docker-compose.selenium.tpl',
			'ENABLE_COMPOSER' => 'tools/composer/docker-compose.composer.tpl',
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
		if ($envKey === 'ENABLE_TOOLS_CONTAINER') {
			$tools = [
				'adminer' => 80,
				'phpmyadmin' => 80,
				'phppgadmin' => 80,
				'phpmongo' => 80,
				'phpmemcachedadmin' => 80,
				'opcache' => 80,
			];

			$labels[] = "      - \"traefik.enable=true\"";
			// Define a single service for this container since all tools are on port 80
			$labels[] = "      - \"traefik.http.services.tools.loadbalancer.server.port=80\"";

			foreach ($tools as $tool => $port) {
				$host = "{$tool}.stackored.{$suffix}";
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
				'ENABLE_RABBITMQ' => ['service' => 'rabbitmq', 'port' => 15672],
				'ENABLE_MAILHOG' => ['service' => 'mailhog', 'port' => 8025],
				'ENABLE_KIBANA' => ['service' => 'kibana', 'port' => 5601],
				'ENABLE_GRAFANA' => ['service' => 'grafana', 'port' => 3000],
				'ENABLE_SONARQUBE' => ['service' => 'sonarqube', 'port' => 9000],
				'ENABLE_TRAEFIK' => ['service' => 'traefik', 'port' => 8080],
			];

			if (isset($uiMap[$envKey])) {
				$serviceName = $uiMap[$envKey]['service'];
				$internalPort = $uiMap[$envKey]['port'];
				$host = "{$serviceName}.stackored.{$suffix}";

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
