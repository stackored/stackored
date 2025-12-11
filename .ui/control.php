<?php
###################################################################
# Stackored UI - Service Control API
# Start/Stop individual services
###################################################################

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

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
$service = $input['service'] ?? '';
$action = $input['action'] ?? '';

// Validate input
if (empty($service) || empty($action)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Missing service or action parameter']);
    exit;
}

// Validate action
if (!in_array($action, ['start', 'stop', 'restart'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid action. Must be start, stop, or restart']);
    exit;
}

// Sanitize service name (only allow alphanumeric and dash)
if (!preg_match('/^[a-z0-9-]+$/', $service)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid service name']);
    exit;
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

if ($returnCode === 0) {
    echo json_encode([
        'success' => true,
        'message' => ucfirst($action) . ' command executed successfully',
        'service' => $service,
        'action' => $action
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to execute command',
        'error' => implode("\n", $output)
    ]);
}
