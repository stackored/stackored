<?php
namespace Stackored\CLI;

class TemplateEngine
{
	public static function render(string $template, array $vars): string
	{
		return preg_replace_callback(
			'/\{\{\s*([A-Z0-9_]+)(?:\s*\|\s*default\(\'([^\']+)\'\))?\s*\}\}/',
			function ($matches) use ($vars) {
				$key = $matches[1];
				$default = $matches[2] ?? '';

				// Eğer değişken env içinde varsa onu kullan
				if (isset($vars[$key]) && $vars[$key] !== '') {
					return $vars[$key];
				}

				// Yoksa varsayılan değeri kullan
				return $default;
			},
			$template
		);
	}

	public static function renderFile(string $file, array $vars): string
	{
		$content = FileSystem::read($file);
		return self::render($content, $vars);
	}
}
