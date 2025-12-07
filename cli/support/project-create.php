#!/usr/bin/env php
<?php

require __DIR__ . '/../lib/EnvLoader.php';
require __DIR__ . '/../lib/FileSystem.php';
require __DIR__ . '/../lib/Logger.php';

use Stackored\CLI\EnvLoader;
use Stackored\CLI\FileSystem;
use Stackored\CLI\Logger;

$root = realpath(__DIR__ . '/../../..');
$projectsDir = $root . '/projects';

if (!is_dir($projectsDir)) {
	mkdir($projectsDir, 0777, true);
}

$args = $argv;
array_shift($args); // script adı

$projectName = $args[0] ?? null;

if (!$projectName) {
	Logger::error("Proje adı eksik. Kullanım: stackored project create <project-name>");
	exit(1);
}

if (!preg_match('/^[a-zA-Z0-9_\-]+$/', $projectName)) {
	Logger::error("Geçersiz proje adı. Sadece harf, rakam, '-' ve '_' kullanılabilir.");
	exit(1);
}

$projectPath = $projectsDir . '/' . $projectName;

if (file_exists($projectPath)) {
	Logger::error("Bu isimde bir proje zaten mevcut: $projectName");
	exit(1);
}

// Env varsa oku (PHP varsayılan versiyon vb. için)
$env = [];
$envFile = $root . '/.env';
if (file_exists($envFile)) {
	$env = EnvLoader::load($envFile);
}

// Mevcut projelerden kullanılan PHP portlarını bul
$usedPorts = [];
foreach (scandir($projectsDir) as $p) {
	if ($p === '.' || $p === '..') continue;
	$cfg = $projectsDir . '/' . $p . '/stackored.json';
	if (file_exists($cfg)) {
		$json = json_decode(file_get_contents($cfg), true);
		if (isset($json['php']['port'])) {
			$usedPorts[] = (int)$json['php']['port'];
		}
	}
}

$defaultBasePort = 9000;
$phpPort = $defaultBasePort;

if (!empty($usedPorts)) {
	$phpPort = max($usedPorts) + 1;
}

// Varsayılan PHP ve web server seçimi env'den
$defaultPhpVersion = $env['PHP_DEFAULT_VERSION'] ?? '8.2';
$defaultWebServer  = $env['WEB_DEFAULT_SERVER'] ?? 'nginx';

// Proje dizinlerini oluştur
mkdir($projectPath, 0777, true);
mkdir($projectPath . '/public', 0777, true);
mkdir($projectPath . '/.stackored', 0777, true);

// Varsayılan stackored.json içeriği
$stackoredConfig = [
	'name'   => $projectName,
	'domain' => $projectName . '.loc',
	'php'    => [
		'version' => $defaultPhpVersion,
		'port'    => $phpPort,
	],
	'web'    => [
		'server'  => $defaultWebServer, // nginx | httpd
		'docroot' => 'public',
	],
	'database' => [
		'default' => 'mysql',
	],
];

// stackored.json yaz
FileSystem::write(
	$projectPath . '/stackored.json',
	json_encode($stackoredConfig, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
);

// Basit index.php
$indexPhp = <<<PHP
<?php
echo "Hello from Stackored project: {$projectName}\\n";
PHP;

FileSystem::write($projectPath . '/public/index.php', $indexPhp);

// Boş override klasörü (ileride kullanmak için)
FileSystem::write($projectPath . '/.stackored/.gitkeep', '');

Logger::success("Yeni proje oluşturuldu: $projectName");
Logger::info("Dizin: $projectPath");
Logger::info("Domain: {$stackoredConfig['domain']}");
Logger::info("PHP Version: {$stackoredConfig['php']['version']} Port: {$stackoredConfig['php']['port']}");

exit(0);
