<?php
/*******************************************************************
 * STACKORED GENERATE ROUTES TEMPLATE
 * Generates Traefik routing config per project.
 ******************************************************************/

$projectsPath = __DIR__ . '/../../projects';
$outputPath   = __DIR__ . '/../../generated/routes';
if (!is_dir($outputPath)) mkdir($outputPath, 0777, true);

$projects = array_filter(scandir($projectsPath), function ($p) {
    return $p !== '.' && $p !== '..' && is_dir($projectsPath . '/' . $p);
});

foreach ($projects as $project) {

    $configFile = "$projectsPath/$project/stackored.json";
    $overrideFile = "$projectsPath/$project/.stackored/traefik.yml";

    // Override varsa doğrudan onu kullan
    if (file_exists($overrideFile)) {
        copy($overrideFile, "$outputPath/$project-traefik.yml");
        continue;
    }

    if (!file_exists($configFile)) continue;

    $config = json_decode(file_get_contents($configFile), true);
    if (!$config) continue;

    $domain = $config['domain'] ?? "$project.loc";
    $phpPort = $config['php']['port'] ?? 9000;

    $yaml = [];
    $yaml[] = "http:";
    $yaml[] = "  routers:";
    $yaml[] = "    {$project}-router:";
    $yaml[] = "      rule: \"Host(`$domain`)\"";
    $yaml[] = "      service: {$project}-service";
    $yaml[] = "      entryPoints: [\"web\"]";
    $yaml[] = "";
    $yaml[] = "  services:";
    $yaml[] = "    {$project}-service:";
    $yaml[] = "      loadBalancer:";
    $yaml[] = "        servers:";
    $yaml[] = "          - url: \"http://{$project}-php:{$phpPort}\"";

    file_put_contents("$outputPath/$project-traefik.yml", implode("\n", $yaml));
}

echo \"[OK] Traefik route configs generated.\\n\";
