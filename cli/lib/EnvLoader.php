<?php
namespace Stackored\CLI;

class EnvLoader
{
	public static function load(string $file): array
	{
		if (!file_exists($file)) {
			throw new \Exception("Env file not found: $file");
		}

		$env = [];
		foreach (file($file, FILE_IGNORE_NEW_LINES) as $line) {
			$line = trim($line);
			if ($line === '' || str_starts_with($line, '#')) continue;

			if (strpos($line, '=') !== false) {
				[$k, $v] = explode('=', $line, 2);
				$env[trim($k)] = trim($v);
			}
		}

		return $env;
	}
}
