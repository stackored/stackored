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

		Logger::info("Loading projects...");
		$projects = ProjectLoader::loadProjects($this->root . '/projects');

		Logger::info("Generating project configs...");
		$this->generateProjectConfigs($projects);

		Logger::info("Generating traefik routes...");
		$this->generateRoutes($projects);

		Logger::info("Generating dynamic docker-compose...");
		$this->generateDynamicCompose();

		Logger::success("Stackored generation completed.");
	}

	protected function generateProjectConfigs(array $projects): void
	{
		$outputDir = $this->root . '/generated/config';

		foreach ($projects as $name => $config) {
			FileSystem::write(
				"$outputDir/{$name}-config.json",
				json_encode($config, JSON_PRETTY_PRINT)
			);
		}
	}

	protected function generateRoutes(array $projects): void
	{
		$outputDir = $this->root . '/generated/routes';

		foreach ($projects as $name => $config) {
			$domain = $config['domain'] ?? "$name.loc";
			$phpPort = $config['php']['port'] ?? 9000;

			$yaml = [];
			$yaml[] = "http:";
			$yaml[] = "  routers:";
			$yaml[] = "    {$name}-router:";
			$yaml[] = "      rule: \"Host(`$domain`)\"";
			$yaml[] = "      service: {$name}-service";
			$yaml[] = "";
			$yaml[] = "  services:";
			$yaml[] = "    {$name}-service:";
			$yaml[] = "      loadBalancer:";
			$yaml[] = "        servers:";
			$yaml[] = "          - url: \"http://{$name}-php:$phpPort\"";

			FileSystem::write(
				"$outputDir/{$name}-traefik.yml",
				implode("\n", $yaml)
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
