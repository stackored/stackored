<?php
###################################################################
# Stackored UI - System Control API
# Execute system-wide commands: up, down, restart
###################################################################

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Increase execution time for stopping many containers
set_time_limit(120);

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);
$command = $input['command'] ?? '';

// Validate input
if (empty($command)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Missing command parameter']);
    exit;
}

// Validate command
if (!in_array($command, ['up', 'down', 'restart'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid command. Must be up, down, or restart']);
    exit;
}

// Get all stackored and project containers
$output = [];
$returnCode = 0;

// Get list of all stackored containers
exec('docker ps -a --filter "name=stackored-" --format "{{.Names}}"', $stackoredContainers, $returnCode);

if ($returnCode !== 0) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to get container list'
    ]);
    exit;
}

// Get list of all project containers (project*-web and project*-php)
exec('docker ps -a --filter "name=project" --format "{{.Names}}"', $projectContainers, $returnCode);

// Combine both lists
$containerList = array_merge($stackoredContainers, $projectContainers ?? []);

if (empty($containerList)) {
    echo json_encode([
        'success' => true,
        'message' => 'No stackored containers found',
        'command' => $command,
        'affected_containers' => 0,
        'containers' => []
    ]);
    exit;
}

// Exclude UI and Traefik from down and restart commands to keep UI accessible
if ($command === 'down' || $command === 'restart') {
    $containerList = array_filter($containerList, function($container) {
        return !in_array($container, ['stackored-ui', 'stackored-traefik']);
    });
    
    if (empty($containerList)) {
        echo json_encode([
            'success' => true,
            'message' => 'All containers ' . ($command === 'down' ? 'stopped' : 'restarted') . ' (UI and Traefik kept running)',
            'command' => $command,
            'affected_containers' => 0,
            'containers' => [],
            'note' => 'stackored-ui and stackored-traefik are kept running to maintain UI access'
        ]);
        exit;
    }
}

// Build docker command based on action - execute all containers at once for speed
$containerNames = implode(' ', array_map('escapeshellarg', $containerList));

if ($command === 'up') {
    $dockerCmd = "docker start {$containerNames} 2>&1";
} elseif ($command === 'down') {
    $dockerCmd = "docker stop {$containerNames} 2>&1";
} elseif ($command === 'restart') {
    $dockerCmd = "docker restart {$containerNames} 2>&1";
}

$output = [];
$returnCode = 0;
exec($dockerCmd, $output, $returnCode);

// Return results
if ($returnCode === 0) {
    echo json_encode([
        'success' => true,
        'message' => ucfirst($command) . ' command executed successfully on all containers',
        'command' => $command,
        'affected_containers' => count($containerList),
        'containers' => $containerList
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to execute ' . $command . ' command',
        'command' => $command,
        'error' => implode("\n", $output)
    ]);
}
