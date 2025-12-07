<?php
namespace Stackored\CLI;

class Logger
{
	public static function info(string $msg): void
	{
		echo "[INFO] $msg\n";
	}

	public static function success(string $msg): void
	{
		echo "[OK] $msg\n";
	}

	public static function error(string $msg): void
	{
		echo "[ERROR] $msg\n";
	}
}
