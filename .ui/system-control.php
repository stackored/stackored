<?php
###################################################################
# Stackored UI - System Control API
# Execute system-wide commands: up, down, restart
###################################################################

// Load shared libraries
require_once __DIR__ . '/lib/response.php';
require_once __DIR__ . '/lib/logger.php';

setCorsHeaders();
handlePreflight();

// Increase execution time for stopping many containers
set_time_limit(120);

// Start request tracking
$startTime = microtime(true);
Logger::logRequest('/system-control.php', 'POST', $_POST);

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method not allowed', 405);
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);
$command = $input['command'] ?? '';

// Validate input
if (empty($command)) {
    jsonError('Missing command parameter', 400);
}

// Validate command
if (!in_array($command, ['up', 'down', 'restart'])) {
    jsonError('Invalid command. Must be up, down, or restart', 400);
}

// Get all stackored and project containers
$output = [];
$returnCode = 0;

// Get list of all stackored containers
exec('docker ps -a --filter "name=stackored-" --format "{{.Names}}"', $stackoredContainers, $returnCode);

if ($returnCode !== 0) {
    jsonError('Failed to get container list', 500);
}

// Get list of all project containers (project*-web and project*-php)
exec('docker ps -a --filter "name=project" --format "{{.Names}}"', $projectContainers, $returnCode);

// Combine both lists
$containerList = array_merge($stackoredContainers, $projectContainers ?? []);

if (empty($containerList)) {
    jsonSuccess([
        'message' => 'No stackored containers found',
        'command' => $command,
        'affected_containers' => 0,
        'containers' => []
    ]);
}

// Exclude UI and Traefik from down and restart commands to keep UI accessible
if ($command === 'down' || $command === 'restart') {
    $containerList = array_filter($containerList, function($container) {
        return !in_array($container, ['stackored-ui', 'stackored-traefik']);
    });
    
    if (empty($containerList)) {
        jsonSuccess([
            'message' => 'All containers ' . ($command === 'down' ? 'stopped' : 'restarted') . ' (UI and Traefik kept running)',
            'command' => $command,
            'affected_containers' => 0,
            'containers' => [],
            'note' => 'stackored-ui and stackored-traefik are kept running to maintain UI access'
        ]);
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

// Log Docker command execution
Logger::logDockerCommand($dockerCmd, $returnCode, $output);

// Return results
if ($returnCode === 0) {
    $duration = microtime(true) - $startTime;
    Logger::logResponse('/system-control.php', 200, $duration);
    Logger::info("System {$command} successful", [
        'affected_containers' => count($containerList)
    ]);
    
    jsonSuccess([
        'message' => ucfirst($command) . ' command executed successfully on all containers',
        'command' => $command,
        'affected_containers' => count($containerList),
        'containers' => $containerList
    ]);
} else {
    $duration = microtime(true) - $startTime;
    Logger::logResponse('/system-control.php', 500, $duration);
    Logger::error("System {$command} failed", [
        'command' => $command,
        'error' => implode("\n", $output)
    ]);
    
    jsonError('Failed to execute ' . $command . ' command: ' . implode("\n", $output), 500);
}
