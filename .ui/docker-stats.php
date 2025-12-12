<?php
/**
 * Docker Stats API Endpoint
 * Returns real-time Docker container statistics for monitoring
 */

header('Content-Type: application/json');

// Function to execute shell command and return output
function executeCommand($command) {
    $output = [];
    $returnVar = 0;
    exec($command . ' 2>&1', $output, $returnVar);
    return [
        'success' => $returnVar === 0,
        'output' => implode("\n", $output),
        'lines' => $output
    ];
}

// Function to parse Docker stats output
function getDockerStats() {
    // Get stats for all containers with JSON format
    $result = executeCommand('docker stats --no-stream --format "{{json .}}"');
    
    if (!$result['success']) {
        return [
            'success' => false,
            'error' => 'Failed to get Docker stats',
            'details' => $result['output']
        ];
    }
    
    $containers = [];
    $totalCpu = 0;
    $totalMemUsedMB = 0; // Store in MB for better precision
    $containerCount = 0;
    
    // Get system memory info
    $systemMemResult = executeCommand('free -m | grep Mem');
    $systemMemTotal = 16000; // Default 16GB
    if ($systemMemResult['success'] && !empty($systemMemResult['lines'])) {
        $memLine = preg_split('/\s+/', trim($systemMemResult['lines'][0]));
        if (isset($memLine[1])) {
            $systemMemTotal = floatval($memLine[1]); // Total memory in MB
        }
    }
    
    foreach ($result['lines'] as $line) {
        if (empty($line)) continue;
        
        $stat = json_decode($line, true);
        if (!$stat) continue;
        
        // Only process stackored containers
        if (strpos($stat['Name'], 'stackored-') === false && 
            strpos($stat['Name'], 'stackored_') === false) {
            continue;
        }
        
        // Parse CPU percentage
        $cpuPercent = floatval(str_replace('%', '', $stat['CPUPerc']));
        
        // Parse memory (format: "123.4MiB / 1.5GiB")
        $memParts = explode(' / ', $stat['MemUsage']);
        $memUsedBytes = parseMemoryValue($memParts[0] ?? '0');
        $memUsedMB = $memUsedBytes / 1024 / 1024; // Convert to MB
        
        $containers[] = [
            'name' => $stat['Name'],
            'cpu' => $cpuPercent,
            'memory_used_mb' => round($memUsedMB, 2),
            'memory_percent' => floatval(str_replace('%', '', $stat['MemPerc']))
        ];
        
        $totalCpu += $cpuPercent;
        $totalMemUsedMB += $memUsedMB;
        $containerCount++;
    }
    
    // Get disk usage
    $diskStats = getDiskStats();
    
    return [
        'success' => true,
        'timestamp' => time(),
        'containers' => $containers,
        'aggregate' => [
            'cpu_total' => round($totalCpu, 2),
            'cpu_average' => $containerCount > 0 ? round($totalCpu / $containerCount, 2) : 0,
            'memory_used_mb' => round($totalMemUsedMB, 2),
            'memory_used_gb' => round($totalMemUsedMB / 1024, 2),
            'memory_total_mb' => $systemMemTotal,
            'memory_total_gb' => round($systemMemTotal / 1024, 2),
            'memory_percent' => $systemMemTotal > 0 ? round(($totalMemUsedMB / $systemMemTotal) * 100, 2) : 0,
            'container_count' => $containerCount
        ],
        'disk' => $diskStats
    ];
}

// Function to parse memory values (handles MiB, GiB, etc.)
function parseMemoryValue($value) {
    $value = trim($value);
    
    // Check units from longest to shortest to avoid partial matches
    // e.g., "MiB" contains "B", so check "MiB" before "B"
    $units = [
        'TiB' => 1024*1024*1024*1024,
        'GiB' => 1024*1024*1024,
        'MiB' => 1024*1024,
        'KiB' => 1024,
        'TB' => 1000*1000*1000*1000,
        'GB' => 1000*1000*1000,
        'MB' => 1000*1000,
        'KB' => 1000,
        'B' => 1
    ];
    
    foreach ($units as $unit => $multiplier) {
        if (strpos($value, $unit) !== false) {
            return floatval($value) * $multiplier;
        }
    }
    
    return floatval($value);
}

// Function to get disk usage statistics
function getDiskStats() {
    // Get root filesystem disk usage
    $result = executeCommand('df -BG / | tail -1');
    
    if (!$result['success'] || empty($result['lines'])) {
        return [
            'total_gb' => 0,
            'used_gb' => 0,
            'available_gb' => 0,
            'percent' => 0
        ];
    }
    
    // Parse df output: Filesystem Size Used Avail Use% Mounted
    $parts = preg_split('/\s+/', trim($result['lines'][0]));
    
    if (count($parts) < 5) {
        return [
            'total_gb' => 0,
            'used_gb' => 0,
            'available_gb' => 0,
            'percent' => 0
        ];
    }
    
    // Remove 'G' suffix and convert to float
    $totalGB = floatval(str_replace('G', '', $parts[1]));
    $usedGB = floatval(str_replace('G', '', $parts[2]));
    $availableGB = floatval(str_replace('G', '', $parts[3]));
    $percentStr = str_replace('%', '', $parts[4]);
    
    return [
        'total_gb' => $totalGB,
        'used_gb' => $usedGB,
        'available_gb' => $availableGB,
        'percent' => floatval($percentStr)
    ];
}

// Main execution
try {
    $stats = getDockerStats();
    echo json_encode($stats, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
