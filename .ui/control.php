<?php
###################################################################
# Stackored UI - Service Control API
# Start/Stop individual services
###################################################################

// Load shared libraries
require_once __DIR__ . '/lib/response.php';
require_once __DIR__ . '/lib/logger.php';

setCorsHeaders();
handlePreflight();

// Start request tracking
$startTime = microtime(true);
Logger::logRequest('/control.php', 'POST', $_POST);

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method not allowed', 405);
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);
$service = $input['service'] ?? '';
$action = $input['action'] ?? '';

// Validate input
if (empty($service) || empty($action)) {
    jsonError('Missing service or action parameter', 400);
}

// Validate action
if (!in_array($action, ['start', 'stop', 'restart'])) {
    jsonError('Invalid action. Must be start, stop, or restart', 400);
}

// Sanitize service name (only allow alphanumeric and dash)
if (!preg_match('/^[a-z0-9-]+$/', $service)) {
    jsonError('Invalid service name', 400);
}

// Build docker command
// Project containers don't have 'stackored-' prefix, only services do
if (strpos($service, 'project') === 0) {
    // Project container (e.g., project1-web, project1-php)
    $containerName = $service;
} else {
    // Stackored service (e.g., mysql, redis)
    $containerName = 'stackored-' . $service;
}

// Execute docker command directly (more reliable than docker compose)
if ($action === 'start') {
    $command = sprintf('docker start %s 2>&1', escapeshellarg($containerName));
} elseif ($action === 'stop') {
    $command = sprintf('docker stop %s 2>&1', escapeshellarg($containerName));
} elseif ($action === 'restart') {
    $command = sprintf('docker restart %s 2>&1', escapeshellarg($containerName));
}

$output = [];
$returnCode = 0;
exec($command, $output, $returnCode);

// Log Docker command execution
Logger::logDockerCommand($command, $returnCode, $output);

if ($returnCode === 0) {
    $duration = microtime(true) - $startTime;
    Logger::logResponse('/control.php', 200, $duration);
    Logger::info("Service {$action} successful", ['service' => $service]);
    
    jsonSuccess([
        'message' => ucfirst($action) . ' command executed successfully',
        'service' => $service,
        'action' => $action
    ]);
} else {
    $duration = microtime(true) - $startTime;
    Logger::logResponse('/control.php', 500, $duration);
    Logger::error("Service {$action} failed", [
        'service' => $service,
        'action' => $action,
        'error' => implode("\n", $output)
    ]);
    
    jsonError('Failed to execute command: ' . implode("\n", $output), 500);
}
