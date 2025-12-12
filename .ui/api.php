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
    $output = [];
    $returnCode = 0;
    exec("docker inspect -f '{{.State.Running}}' " . escapeshellarg($containerName) . " 2>/dev/null", $output, $returnCode);
    return $returnCode === 0 && isset($output[0]) && trim($output[0]) === 'true';
}

// Function to check if a domain is resolvable (configured in DNS/hosts)
function isDomainConfigured($domain) {
    if (empty($domain)) {
        return false;
    }
    
    // Use gethostbyname to check if domain resolves
    // If it doesn't resolve, it returns the domain name itself
    $ip = gethostbyname($domain);
    
    // If gethostbyname returns the same string, domain is not configured
    // If it returns an IP, domain is configured
    return $ip !== $domain;
}

// Function to get container port mappings and network information
function getContainerPorts($containerName) {
    $result = [
        'ports' => [],
        'ip_address' => null,
        'network' => null,
        'gateway' => null
    ];
    
    // Get port mappings
    $output = [];
    $returnCode = 0;
    exec(sprintf('docker inspect -f \'{{json .NetworkSettings.Ports}}\' %s 2>/dev/null', escapeshellarg($containerName)), $output, $returnCode);
    
    if ($returnCode === 0 && !empty($output[0])) {
        $portData = json_decode($output[0], true);
        if ($portData) {
            foreach ($portData as $dockerPort => $hostBindings) {
                if ($hostBindings === null) {
                    $result['ports'][$dockerPort] = [
                        'docker_port' => rtrim($dockerPort, '/tcp'),
                        'host_ip' => null,
                        'host_port' => null,
                        'exposed' => false
                    ];
                } else {
                    $binding = $hostBindings[0];
                    $result['ports'][$dockerPort] = [
                        'docker_port' => rtrim($dockerPort, '/tcp'),
                        'host_ip' => $binding['HostIp'] === '0.0.0.0' ? '0.0.0.0' : $binding['HostIp'],
                        'host_port' => $binding['HostPort'],
                        'exposed' => true
                    ];
                }
            }
        }
    }
    
    // Get network information
    $output = [];
    exec(sprintf('docker inspect -f \'{{json .NetworkSettings.Networks}}\' %s 2>/dev/null', escapeshellarg($containerName)), $output, $returnCode);
    
    if ($returnCode === 0 && !empty($output[0])) {
        $networks = json_decode($output[0], true);
        if ($networks && is_array($networks)) {
            // Get first network (usually the main one)
            $networkData = reset($networks);
            $networkName = key($networks);
            
            if ($networkData) {
                $result['ip_address'] = $networkData['IPAddress'] ?? null;
                $result['network'] = $networkName;
                $result['gateway'] = $networkData['Gateway'] ?? null;
            }
        }
    }
    
    return $result;
}

// Function to get service logs with size information
function getServiceLogs($serviceName, $baseDir) {
    $hostLogPath = $baseDir . '/logs/' . $serviceName;
    
    // Map service names to their container log paths
    $containerLogPaths = [
        'mysql' => '/var/log/mysql',
        'mariadb' => '/var/log/mysql',
        'postgres' => '/var/lib/postgresql/data/log',
        'postgresql' => '/var/lib/postgresql/data/log',
        'redis' => '/var/log/redis',
        'nginx' => '/var/log/nginx',
        'apache' => '/var/log/apache2',
        'mongodb' => '/var/log/mongodb',
        'mongo' => '/var/log/mongodb',
        'elasticsearch' => '/var/log/elasticsearch',
        'rabbitmq' => '/var/log/rabbitmq',
        'kafka' => '/var/log/kafka',
        'memcached' => '/var/log/memcached',
        'netdata' => '/var/log/netdata',
        'traefik' => '/var/log/traefik',
    ];
    
    $containerBasePath = $containerLogPaths[strtolower($serviceName)] ?? '/var/log/' . $serviceName;
    
    // Check if log directory exists
    if (!is_dir($hostLogPath)) {
        return null;
    }
    
    // Check for common log file patterns
    $possibleLogFiles = [
        $serviceName . '.log',
        'error.log',
        'access.log',
        'main.log',
        'slow.log',
    ];
    
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

// Function to format bytes to human readable format
function formatBytes($bytes, $precision = 2) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    
    for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
        $bytes /= 1024;
    }
    
    return round($bytes, $precision) . ' ' . $units[$i];
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

// Output JSON
echo json_encode([
    'success' => true,
    'services' => $services,
], JSON_PRETTY_PRINT);
