<?php
/**
 * Cache Clear Endpoint
 * 
 * Clears all cached data - useful for development and testing
 */

require_once __DIR__ . '/lib/cache.php';
require_once __DIR__ . '/lib/response.php';
require_once __DIR__ . '/lib/logger.php';

setCorsHeaders();

// Clear cache
Cache::clear();

// Log the action
Logger::info('Cache cleared manually');

// Return stats
jsonSuccess([
    'message' => 'Cache cleared successfully',
    'stats' => Cache::stats()
]);
