<?php

require 'healthbook.inc.php';
require_once "home.inc.php";
// about tab is in the library because it is directly invoked by main tab

//**start here
$facebook = new Facebook($appapikey, $appsecret);
$facebook->require_frame();
$user = $facebook->get_loggedin_user(); //require_login();
if ($user!=0)
{
connect_db();
list($mcid,$appliance) = fmcid($user);
if (isset($_REQUEST['o']))
$o = $_REQUEST['o']; //opcode if any
else $o='';
switch ($o)
{
	case 'o': { $item = 'collaborate'; break;}
	case 'f': { $item = 'favorites'; break;}
	case 't': { $item = 'care team'; break;}
	case 'g': { $item = 'care giving'; break;}
	case 'u':{ $item = 'posted healthURLs'; break;}
	case 'w': { $item = 'care wall'; break;}
	case 'x': { $item = 'facebook groups'; break;}
	default : { $item = 'collaborate'; break;}
	
}
// jumping off to outer space
echo home($user,$mcid,FALSE,$facebook,$appliance,$item );
}
else 
{
	// not logged in
	echo  gototopics($facebook,$user);
}
?>