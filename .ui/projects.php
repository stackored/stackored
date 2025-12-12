<?php
###################################################################
# Stackored UI - Projects API
# Returns projects from projects directory with stackored.json
###################################################################

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Base directory - works both in Docker and locally
if (is_dir('/app/projects')) {
    $baseDir = '/app';
} else {
    // Running locally
    $baseDir = dirname(__DIR__);
}

$projectsDir = $baseDir . '/projects';
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

// Function to get project logs
function getProjectLogs($projectName, $webserver, $baseDir) {
    $logsDir = $baseDir . '/logs/projects/' . $projectName;
    
    // Determine container log paths based on webserver type
    $webLogBase = '/var/log/nginx'; // default
    if ($webserver === 'apache') {
        $webLogBase = '/var/log/apache2';
    } elseif ($webserver === 'caddy') {
        $webLogBase = '/var/log/caddy';
    } elseif ($webserver === 'ferron') {
        $webLogBase = '/var/log/ferron';
    }
    
    // PHP container logs
    $phpLogBase = '/var/log/' . $projectName;
    
    // Check if logs directory exists
    if (!is_dir($logsDir)) {
        return null;
    }
    
    $logs = [];
    
    // Check for web access log (nginx/apache)
    $webAccessLog = $logsDir . '/access.log';
    if (file_exists($webAccessLog)) {
        $logs['web_access'] = [
            'container_path' => $webLogBase . '/access.log',
            'host_path' => 'logs/projects/' . $projectName . '/access.log'
        ];
    }
    
    // Check for web error log
    $webErrorLog = $logsDir . '/error.log';
    if (file_exists($webErrorLog)) {
        $logs['web_error'] = [
            'container_path' => $webLogBase . '/error.log',
            'host_path' => 'logs/projects/' . $projectName . '/error.log'
        ];
    }
    
    // Check for PHP error log
    $phpErrorLog = $logsDir . '/php-error.log';
    if (file_exists($phpErrorLog)) {
        $logs['php_error'] = [
            'container_path' => $phpLogBase . '/php-error.log',
            'host_path' => 'logs/projects/' . $projectName . '/php-error.log'
        ];
    }
    
    return !empty($logs) ? $logs : null;
}

// Function to check project configuration
function getProjectConfiguration($projectPath, $webserver) {
    $stackoredDir = $projectPath . '/.stackored';
    
    // Check if .stackored directory exists
    if (!is_dir($stackoredDir)) {
        return [
            'type' => 'default',
            'has_custom' => false,
            'files' => []
        ];
    }
    
    $configFiles = [];
    
    // Check for common config files based on webserver type
    $possibleConfigs = [
        'nginx' => ['nginx.conf', 'default.conf'],
        'apache' => ['apache.conf', 'httpd.conf'],
        'caddy' => ['Caddyfile'],
        'ferron' => ['ferron.yaml', 'ferron.conf']
    ];
    
    // Check webserver-specific configs
    if (isset($possibleConfigs[$webserver])) {
        foreach ($possibleConfigs[$webserver] as $configFile) {
            if (file_exists($stackoredDir . '/' . $configFile)) {
                $configFiles[] = $configFile;
            }
        }
    }
    
    // Check for PHP configs
    if (file_exists($stackoredDir . '/php.ini')) {
        $configFiles[] = 'php.ini';
    }
    if (file_exists($stackoredDir . '/php-fpm.conf')) {
        $configFiles[] = 'php-fpm.conf';
    }
    
    return [
        'type' => !empty($configFiles) ? 'custom' : 'default',
        'has_custom' => !empty($configFiles),
        'files' => $configFiles
    ];
}

$projects = [];

try {
    // Check if projects directory exists
    if (!is_dir($projectsDir)) {
        echo json_encode([
            'success' => false,
            'message' => 'Projects directory not found',
            'projects' => []
        ]);
        exit;
    }

    // Scan projects directory
    $directories = array_diff(scandir($projectsDir), ['.', '..']);
    
    foreach ($directories as $dir) {
        $projectPath = $projectsDir . '/' . $dir;
        
        // Skip if not a directory
        if (!is_dir($projectPath)) {
            continue;
        }
        
        $configFile = $projectPath . '/stackored.json';
        
        // Check if stackored.json exists
        if (!file_exists($configFile)) {
            // Add project with minimal info if config is missing
            $projects[] = [
                'name' => $dir,
                'domain' => null,
                'php' => null,
                'webserver' => null,
                'document_root' => null,
                'error' => 'Configuration file not found'
            ];
            continue;
        }
        
        // Read and parse stackored.json
        $configContent = file_get_contents($configFile);
        $config = json_decode($configContent, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            // Add project with error info if JSON is invalid
            $projects[] = [
                'name' => $dir,
                'domain' => null,
                'php' => null,
                'webserver' => null,
                'document_root' => null,
                'error' => 'Invalid JSON: ' . json_last_error_msg()
            ];
            continue;
        }
        
        // Check container status for this project
        $projectName = $config['name'] ?? $dir;
        $webContainer = $projectName . '-web';
        $phpContainer = $projectName . '-php';
        
        // Check if containers are running
        $webRunning = false;
        $phpRunning = false;
        
        $webOutput = [];
        $webReturnCode = 0;
        exec(sprintf('docker inspect -f "{{.State.Running}}" %s 2>/dev/null', escapeshellarg($webContainer)), $webOutput, $webReturnCode);
        if ($webReturnCode === 0 && isset($webOutput[0]) && $webOutput[0] === 'true') {
            $webRunning = true;
        }
        
        $phpOutput = [];
        $phpReturnCode = 0;
        exec(sprintf('docker inspect -f "{{.State.Running}}" %s 2>/dev/null', escapeshellarg($phpContainer)), $phpOutput, $phpReturnCode);
        if ($phpReturnCode === 0 && isset($phpOutput[0]) && $phpOutput[0] === 'true') {
            $phpRunning = true;
        }
        
        // Project is considered running if both containers are running
        $running = $webRunning && $phpRunning;
        
        // Check if domain is configured in DNS/hosts
        $domain = $config['domain'] ?? null;
        $dnsConfigured = isDomainConfigured($domain);
        
        // Get SSL status from environment
        $sslEnabled = getEnvValue('SSL_ENABLE', 'true') === 'true';
        
        // Build URLs
        $urls = [
            'https' => $domain ? 'https://' . $domain : null,
            'http' => $domain ? 'http://' . $domain : null,
            'primary' => $domain ? ($sslEnabled ? 'https://' . $domain : 'http://' . $domain) : null
        ];
        
        // Get port mappings for containers
        $webPorts = [];
        $phpPorts = [];
        if ($webRunning) {
            $webPorts = getContainerPorts($webContainer);
        }
        if ($phpRunning) {
            $phpPorts = getContainerPorts($phpContainer);
        }
        
        // Get project logs
        $webserver = $config['webserver'] ?? 'nginx';
        $logs = getProjectLogs($projectName, $webserver, $baseDir);
        
        // Get project configuration info
        $configuration = getProjectConfiguration($projectPath, $webserver);
        
        // Merge port information from web container to main ports object
        $ports = $webRunning ? $webPorts : [];
        
        // Build project path info
        $projectPathInfo = [
            'container_path' => '/var/www/html',
            'host_path' => str_replace($baseDir . '/', '', $projectPath)
        ];
        
        // Add project with full configuration
        // Support multiple runtime languages: php, nodejs, python, ruby, golang
        $projects[] = [
            'name' => $projectName,
            'domain' => $domain,
            'dns_configured' => $dnsConfigured,
            'ssl_enabled' => $sslEnabled,
            'urls' => $urls,
            'php' => $config['php'] ?? null,
            'nodejs' => $config['nodejs'] ?? null,
            'python' => $config['python'] ?? null,
            'ruby' => $config['ruby'] ?? null,
            'golang' => $config['golang'] ?? null,
            'webserver' => $config['webserver'] ?? null,
            'document_root' => $config['document_root'] ?? null,
            'running' => $running,
            'ports' => $ports,
            'logs' => $logs,
            'configuration' => $configuration,
            'project_path' => $projectPathInfo,
            'containers' => [
                'web' => array_merge([
                    'name' => $webContainer,
                    'running' => $webRunning
                ], $webPorts),
                'php' => array_merge([
                    'name' => $phpContainer,
                    'running' => $phpRunning
                ], $phpPorts)
            ],
            'error' => null
        ];
    }
    
    // Sort projects by name
    usort($projects, function($a, $b) {
        return strcmp($a['name'], $b['name']);
    });
    
    echo json_encode([
        'success' => true,
        'projects' => $projects,
        'count' => count($projects)
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage(),
        'projects' => []
    ]);
}
