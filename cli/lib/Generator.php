<?php
namespace Stackored\CLI;

class Generator
{
	protected string $root;
	protected array $env;

	public function __construct()
	{
		$this->root = dirname(__DIR__, 2);
	}

	public function run(): void
	{
		Logger::info("Loading environment...");
		$this->env = EnvLoader::load($this->root . '/.env');

		Logger::info("Generating stackored.yml...");
		$this->generateStackoredYml();

		Logger::info("Generating traefik config...");
		$this->generateTraefikConfig();

		Logger::info("Loading projects...");
		$projects = ProjectLoader::loadProjects($this->root . '/projects');

		Logger::info("Generating traefik routes...");
		$this->generateRoutes($projects);

		Logger::info("Generating project containers...");
		$this->generateProjectContainers($projects);

		Logger::info("Generating dynamic docker-compose...");
		$this->generateDynamicCompose();

		Logger::success("Stackored generation completed.");
	}

	protected function generateStackoredYml(): void
	{
		$templatePath = $this->root . '/stackored.yml.tpl';
		$outputPath = $this->root . '/stackored.yml';
		$sslEnabled = ($this->env['TRAEFIK_ENABLE_SSL'] ?? 'false') === 'true';

		// Add helper variable for entrypoint
		$this->env['TRAEFIK_ENTRYPOINT'] = $sslEnabled ? 'websecure' : 'web';

		$content = FileSystem::read($templatePath);

		// Process conditionals
		$content = preg_replace_callback(
			'/\\{\\{ if ([A-Z0-9_]+) == \\'([^\\']+)\\' \\}\\}(.*?)\\{\\{ endif \\}\\}/s',
			function ($matches) {
				$key = $matches[1];
				$value = $matches[2];
				$content = $matches[3];

				if (isset($this->env[$key]) && $this->env[$key] === $value) {
					return $content;
				}
				return '';
			},
			$content
		);

		// Process template variables
		$content = TemplateEngine::render($content, $this->env);

		FileSystem::write($outputPath, $content);
	}

	protected function generateTraefikConfig(): void
	{
		$outputPath = $this->root . '/core/traefik/traefik.yml';
		$sslEnabled = ($this->env['TRAEFIK_ENABLE_SSL'] ?? 'false') === 'true';
		$redirectToHttps = ($this->env['TRAEFIK_REDIRECT_TO_HTTPS'] ?? 'false') === 'true';

		// Build entrypoints section
		$entrypoints = "entryPoints:\n  web:\n    address: \":80\"\n";

		if ($sslEnabled && $redirectToHttps) {
			$entrypoints .= "    http:\n";
			$entrypoints .= "      redirections:\n";
			$entrypoints .= "        entryPoint:\n";
			$entrypoints .= "          to: websecure\n";
			$entrypoints .= "          scheme: https\n";
			$entrypoints .= "          permanent: true\n";
		}

		if ($sslEnabled) {
			$entrypoints .= "\n  websecure:\n    address: \":443\"\n";
		}

		// Read template and replace entrypoints section
		$templatePath = $this->root . '/core/traefik/traefik.yml.tpl';
		$content = FileSystem::read($templatePath);

		// Replace the entrypoints section
		$content = preg_replace(
			'/###################################################################\n# ENTRYPOINTS\n###################################################################\n.*?(?=\n###################################################################)/s',
			"###################################################################\n# ENTRYPOINTS\n###################################################################\n" . $entrypoints,
			$content
		);

		FileSystem::write($outputPath, $content);
	}

	protected function generateRoutes(array $projects): void
	{
		$outputDir = $this->root . '/core/traefik/dynamic';
		$sslEnabled = ($this->env['TRAEFIK_ENABLE_SSL'] ?? 'false') === 'true';
		$entrypoint = $sslEnabled ? 'websecure' : 'web';

		foreach ($projects as $name => $config) {
			$domain = $config['domain'] ?? "$name.loc";

			$yaml = [];
			$yaml[] = "http:";
			$yaml[] = "  routers:";
			$yaml[] = "    {$name}-router:";
			$yaml[] = "      rule: \"Host(`$domain`)\"";
			$yaml[] = "      service: {$name}-service";
			$yaml[] = "      entryPoints:";
			$yaml[] = "        - $entrypoint";

			if ($sslEnabled) {
				$yaml[] = "      tls: true";
			}

			$yaml[] = "";
			$yaml[] = "  services:";
			$yaml[] = "    {$name}-service:";
			$yaml[] = "      loadBalancer:";
			$yaml[] = "        servers:";
			$yaml[] = "          - url: \"http://{$name}-web:80\"";

			FileSystem::write(
				"$outputDir/{$name}.yml",
				implode("\n", $yaml)
			);
		}
	}

	protected function generateProjectContainers(array $projects): void
	{
		$templateDir = $this->root . '/core/templates/project';
		$projectsCompose = [];

		foreach ($projects as $name => $config) {
			$phpVersion = $config['php']['version'] ?? '8.2';
			$documentRoot = $config['document_root'] ?? 'public';
			$webserver = $config['webserver'] ?? 'nginx';
			$network = 'stackored-net';

			// Select template based on webserver type
			if ($webserver === 'apache') {
				$templatePath = $templateDir . '/docker-compose.apache.tpl';
			} else {
				$templatePath = $templateDir . '/docker-compose.project.tpl';
			}

			if (!file_exists($templatePath)) {
				Logger::info("Project template not found: $templatePath");
				continue;
			}

			$vars = [
				'PROJECT_NAME' => $name,
				'PHP_VERSION' => $phpVersion,
				'DOCUMENT_ROOT' => $documentRoot,
				'DOCKER_DEFAULT_NETWORK' => $network,
			];

			$content = TemplateEngine::render(
				FileSystem::read($templatePath),
				$vars
			);

			$projectsCompose[] = $content;
		}

		// Write to a separate file that will be included in dynamic compose
		if (!empty($projectsCompose)) {
			$yaml = "services:\n" . implode("\n", $projectsCompose);
			FileSystem::write(
				$this->root . '/docker-compose.projects.yml',
				$yaml
			);
		}
	}

	protected function generateDynamicCompose(): void
	{
		$builder = new ComposeBuilder(
			$this->env,
			$this->root . '/core/templates'
		);

		$compose = $builder->build();

		FileSystem::write(
			$this->root . '/docker-compose.dynamic.yml',
			$compose
		);
	}
}
