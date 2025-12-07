<?php
namespace Stackored\CLI;

class ProjectLoader
{
	public static function loadProjects(string $projectsDir): array
	{
		$projects = FileSystem::listDirectories($projectsDir);
		$output = [];

		foreach ($projects as $project) {
			$baseConfig = "$projectsDir/$project/stackored.json";
			if (!file_exists($baseConfig)) continue;

			$config = json_decode(file_get_contents($baseConfig), true);
			if (!$config) continue;

			// Override sistemi
			$overrideDir = "$projectsDir/$project/.stackored";
			if (is_dir($overrideDir)) {
				foreach (FileSystem::listFiles($overrideDir, '*.json') as $file) {
					$override = json_decode(file_get_contents($file), true);
					if ($override) {
						$config = array_replace_recursive($config, $override);
					}
				}
			}

			$output[$project] = $config;
		}

		return $output;
	}
}
