<?php
/**
 * Application Configuration
 * 
 * Core application constants that never change
 * For configurable values, use .env file
 */

return [
    // Runtime paths (calculated at runtime)
    'base_dir' => is_dir('/app') ? '/app' : dirname(dirname(__DIR__)),
    
    // Application constants (never change)
    'container_prefix' => 'stackored-',
    'excluded_containers' => ['stackored-ui', 'stackored-traefik'],
    
    // Directory structure (never change)
    'modules_dir' => 'core/templates/modules',
    'projects_dir' => 'projects',
    'logs_dir' => 'logs',
];
