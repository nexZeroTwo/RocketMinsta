<?php

// This is a very simple IP2C server implemented as a PHP script to use with RocketMinsta
// 
// Usage:
//     http://example.com/ip2c.php?ip=1.2.3.4

if(isset($_GET["ip"]) && filter_var($_GET["ip"], FILTER_VALIDATE_IP))
{
	$ip = $_GET["ip"];

	if(! $country = geoip_country_code_by_name($ip))
		$country = "--";

	echo $country, ' ', htmlspecialchars($ip);
}

// NOTE: *never* have this file end with an extra empty line, php outputs everything outside of its tag as-is and this breaks ip2c as of the time of writing.

?>
