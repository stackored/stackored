<?php
###################################################################
# Stackored UI - Services API
# Returns services from core/templates/modules with .env status
###################################################################

// Load shared libraries
require_once __DIR__ . '/lib/config.php';
require_once __DIR__ . '/lib/env.php';
require_once __DIR__ . '/lib/docker.php';
require_once __DIR__ . '/lib/network.php';
require_once __DIR__ . '/lib/response.php';
require_once __DIR__ . '/lib/utils.php';
require_once __DIR__ . '/lib/logger.php';

// Load configuration
Config::load('app');

setCorsHeaders();

// Start request tracking
$startTime = microtime(true);
Logger::logRequest('/api.php', 'GET');

$baseDir = Config::get('base_dir');
$modulesDir = $baseDir . '/' . Config::get('modules_dir');

// Function to get service logs with size information
function getServiceLogs($serviceName, $baseDir) {
    $hostLogPath = $baseDir . '/' . Config::get('logs_dir') . '/' . $serviceName;
    
    // Convention-based log paths with exceptions for non-standard services
    // Most services follow /var/log/{service} pattern
    $logPathExceptions = [
        'activemq' => '/opt/apache-activemq/data',
        'tomcat' => '/usr/local/tomcat/logs',
        'postgres' => '/var/lib/postgresql/data/log',
        'postgresql' => '/var/lib/postgresql/data/log',
    ];
    
    $containerBasePath = $logPathExceptions[strtolower($serviceName)] ?? '/var/log/' . $serviceName;
    
    // Check if log directory exists
    if (!is_dir($hostLogPath)) {
        return null;
    }
    
    // Common log file patterns
    $possibleLogFiles = array_merge(
        [$serviceName . '.log'],
        ['error.log', 'access.log', 'main.log', 'slow.log']
    );
    
    $foundLogFile = null;
    $foundFileName = null;
    foreach ($possibleLogFiles as $fileName) {
        $file = $hostLogPath . '/' . $fileName;
        if (file_exists($file)) {
            $foundLogFile = $file;
            $foundFileName = $fileName;
            break;
        }
    }
    
    if (!$foundLogFile) {
        // Return directory paths if no specific log file found
        return [
            'container_path' => $containerBasePath,
            'host_path' => 'logs/' . $serviceName,
            'size' => null
        ];
    }
    
    // Get file size
    $size = filesize($foundLogFile);
    $sizeFormatted = formatBytes($size);
    
    // Build paths
    $containerPath = $containerBasePath . '/' . $foundFileName;
    $hostPath = 'logs/' . $serviceName . '/' . $foundFileName;
    
    return [
        'container_path' => $containerPath,
        'host_path' => $hostPath,
        'size' => $sizeFormatted
    ];
}

// Scan modules directory
$services = [];

if (is_dir($modulesDir)) {
    $modules = scandir($modulesDir);

    foreach ($modules as $module) {
        if ($module === '.' || $module === '..') {
            continue;
        }

        $modulePath = $modulesDir . '/' . $module;
        if (!is_dir($modulePath)) {
            continue;
        }

        $serviceName = $module;
        $serviceUpper = strtoupper($serviceName);

        // Get service configuration from .env
        $enabled = getEnvValue($serviceUpper . '_ENABLE', 'false') === 'true';
        $version = getEnvValue($serviceUpper . '_VERSION', '');
        $url = getEnvValue($serviceUpper . '_URL', '');
        $port = getEnvValue('HOST_PORT_' . $serviceUpper, '');

        // Check if container is running
        $containerName = Config::get('container_prefix') . $serviceName;
        $running = isContainerRunning($containerName);

        // Build URL if exists
        $fullUrl = '';
        $domain = '';
        $dnsConfigured = false;
        if (!empty($url)) {
            $tldSuffix = getEnvValue('DEFAULT_TLD_SUFFIX', 'stackored.loc');
            $sslEnable = getEnvValue('SSL_ENABLE', 'true') === 'true';
            $protocol = $sslEnable ? 'https' : 'http';
            $domain = $url . '.' . $tldSuffix;
            $fullUrl = $protocol . '://' . $domain;
            $dnsConfigured = isDomainConfigured($domain);
        }

        // Capitalize first letter for display name
        $serviceDisplayName = ucfirst($serviceName);

        // Get port mappings if container is running
        $ports = [];
        if ($running) {
            $ports = getContainerPorts($containerName);
        }
        
        // Get logs
        $logs = getServiceLogs($serviceName, $baseDir);
        
        $services[] = [
            'name' => $serviceName,
            'enabled' => $enabled,
            'running' => $running,
            'version' => $version,
            'port' => $port,
            'url' => $fullUrl,
            'domain' => $domain,
            'dns_configured' => $dnsConfigured,
            'ports' => $ports,
            'logs' => $logs,
        ];
    }
}

// Sort services alphabetically
usort($services, function ($a, $b) {
    return strcmp($a['name'], $b['name']);
});

// Log response
$duration = microtime(true) - $startTime;
Logger::logResponse('/api.php', 200, $duration);
Logger::debug('Services loaded', ['count' => count($services)]);

// Output JSON
jsonSuccess(['services' => $services]);
