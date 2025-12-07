<?php
namespace Stackored\CLI;

class FileSystem
{
	public static function write(string $path, string $content): void
	{
		$dir = dirname($path);
		if (!is_dir($dir)) mkdir($dir, 0777, true);

		file_put_contents($path, $content);
	}

	public static function read(string $path): string
	{
		if (!file_exists($path)) {
			throw new \Exception("File not found: $path");
		}
		return file_get_contents($path);
	}

	public static function exists(string $path): bool
	{
		return file_exists($path);
	}

	public static function listDirectories(string $path): array
	{
		if (!is_dir($path)) return [];

		return array_filter(scandir($path), function ($item) use ($path) {
			return $item !== '.' && $item !== '..' && is_dir("$path/$item");
		});
	}

	public static function listFiles(string $path, string $pattern = '*'): array
	{
		return glob("$path/$pattern") ?: [];
	}
}
