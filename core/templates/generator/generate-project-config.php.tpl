<?php
/*******************************************************************
 * STACKORED GENERATE PROJECT CONFIG TEMPLATE
 * Merges stackored.json + overrides into a final config.
 ******************************************************************/

$projectsPath = __DIR__ . '/../../projects';
$outputPath   = __DIR__ . '/../../generated/config';

if (!is_dir($outputPath)) mkdir($outputPath, 0777, true);

$projects = array_filter(scandir($projectsPath), fn($p) =>
$p !== '.' && $p !== '..' && is_dir("$projectsPath/$p")
);

foreach ($projects as $project) {

$baseConfigFile = "$projectsPath/$project/stackored.json";
$overrideDir    = "$projectsPath/$project/.stackored";

if (!file_exists($baseConfigFile)) continue;

$config = json_decode(file_get_contents($baseConfigFile), true);
if (!$config) continue;

// Override varsa uygula
if (is_dir($overrideDir)) {
foreach (glob("$overrideDir/*.json") as $file) {
$override = json_decode(file_get_contents($file), true);
if ($override) {
$config = array_replace_recursive($config, $override);
}
}
}

file_put_contents(
"$outputPath/$project-config.json",
json_encode($config, JSON_PRETTY_PRINT)
);
}

echo \"[OK] Project config files generated.\\n\";
