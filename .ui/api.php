<?php
###################################################################
# Stackored UI - Services API
# Returns services from core/templates/modules with .env status
###################################################################

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Base directory - works both in Docker and locally
if (is_dir('/app/core/templates/modules')) {
    $baseDir = '/app';
} else {
    // Running locally
    $baseDir = dirname(__DIR__);
}

$modulesDir = $baseDir . '/core/templates/modules';
$envFile = $baseDir . '/.env';

// Function to get value from .env file
function getEnvValue($key, $default = '')
{
    global $envFile;

    if (!file_exists($envFile)) {
        return $default;
    }

    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        // Skip comments
        if (strpos(trim($line), '#') === 0) {
            continue;
        }

        // Parse key=value
        if (strpos($line, '=') !== false) {
            list($envKey, $envValue) = explode('=', $line, 2);
            if (trim($envKey) === $key) {
                // Remove quotes
                $envValue = trim($envValue);
                $envValue = trim($envValue, '"\'');
                return $envValue;
            }
        }
    }

    return $default;
}

// Function to check if container is running
function isContainerRunning($containerName)
{
    $output = shell_exec("docker inspect -f '{{.State.Running}}' " . escapeshellarg($containerName) . " 2>/dev/null");
    return $output !== null && trim($output) === 'true';
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
        $containerName = 'stackored-' . $serviceName;
        $running = isContainerRunning($containerName);

        // Build URL if exists
        $fullUrl = '';
        if (!empty($url)) {
            $tldSuffix = getEnvValue('DEFAULT_TLD_SUFFIX', 'stackored.loc');
            $sslEnable = getEnvValue('SSL_ENABLE', 'true') === 'true';
            $protocol = $sslEnable ? 'https' : 'http';
            $fullUrl = $protocol . '://' . $url . '.' . $tldSuffix;
        }

        // Capitalize first letter for display name
        $serviceDisplayName = ucfirst($serviceName);

        $services[] = [
            'name' => $serviceDisplayName,
            'enabled' => $enabled,
            'running' => $running,
            'version' => $version,
            'port' => $port,
            'url' => $fullUrl,
        ];
    }
}

// Sort services alphabetically
usort($services, function ($a, $b) {
    return strcmp($a['name'], $b['name']);
});

// Output JSON
echo json_encode([
    'success' => true,
    'services' => $services,
], JSON_PRETTY_PRINT);
