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

$projectsDir = $baseDir . '/projects';
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
        
        // Get port mappings for containers
        $webPorts = [];
        $phpPorts = [];
        if ($webRunning) {
            $webPorts = getContainerPorts($webContainer);
        }
        if ($phpRunning) {
            $phpPorts = getContainerPorts($phpContainer);
        }
        
        // Add project with full configuration
        // Support multiple runtime languages: php, nodejs, python, ruby, golang
        $projects[] = [
            'name' => $projectName,
            'domain' => $domain,
            'dns_configured' => $dnsConfigured,
            'php' => $config['php'] ?? null,
            'nodejs' => $config['nodejs'] ?? null,
            'python' => $config['python'] ?? null,
            'ruby' => $config['ruby'] ?? null,
            'golang' => $config['golang'] ?? null,
            'webserver' => $config['webserver'] ?? null,
            'document_root' => $config['document_root'] ?? null,
            'running' => $running,
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
