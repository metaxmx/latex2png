#!/usr/bin/perl
# #####################################################
# LaTeX 2 PNG Interface
# uses the free texvc script from wikimedia.org
# (c) 2006 by Christian "metax." Simon
# #####################################################

# Include CGI Lib
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use strict;

# Environment constants ######################
# Please change to this fit your server

my $_texpaste_root = '/your/path/to/texpaste'; # Edited by the author
my $_default_tex_code = 'f(x):=x^2';

# End Environment ############################


chdir($_texpaste_root);

# Example LaTeX Code.
my $texcode = $_default_tex_code;

# Pushed some texcode via GET ?
if(param("texcode"))
{ $texcode = param("texcode") }

# HTTP Header
print "Content-Type: text/html;\n\n";

# HTML Header
print <<"HEAD";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="de">
<head>
<meta http-equiv="Content-Type"   content="text/html; charset=utf-8" />
<title>LaTeX to PNG</title>
</head>
<body>
<h1>LaTeX to PNG Converter</h1>
<h2>Einfach LaTeX Code eingeben und Bildadresse des Ergebnis kopieren. Hotlinking erlaubt.</h2>
<form action="index.cgi" method="get">
<textarea name="texcode" rows="10" cols="60">
HEAD

print $texcode;

print <<"MID";
</textarea><br />
<input type="submit" value="Tex2PNG" />
</form><br /><br />
MID

# Run texvc Script (Syntax 'texvc $temporary_folder $save_images_to "$latex_code" $charset')
# Temporary folder and images folder must be writeable by apache/CGI
my $cmdtexcode = $texcode;
$cmdtexcode =~ s/[\n\r]/ /gs;
$cmdtexcode =~ s/\\/\\\\/gs;
$_ = `/usr/local/bin/texvc tmp/ images/ \"$cmdtexcode\" utf-8`;

# Extract hash: look for status code and md5 hash
m/^.([0-9a-f]{32})/s;
my $idm = $1;

# print Result
if(-e "images/$idm.png")
{
	print "Ergebnis: <img src=\"images/$idm.png\" alt=\"PNG Ergebnis\" style=\"margin-left: 2em;\" /><br /><br />\nLink: 
<code>http://www.planet-metax.de/texpaste/images/$idm.png</code><br /><br 
/>\nForum Code: 
<code>[IMG]http://www.planet-metax.de/texpaste/images/$idm.png[/IMG]</code>";
}
else
{
	print "Ergebnis: Fehler! (OUTPUT: $_ )<br />";
	/^S$/ and print "Syntax Error!";
	/^E$/ and print "Lexing Error";
	/^F(.*)$/ and print "Unknown Function &bdquo;$1&ldquo;.";
}

print <<"END";

<address style="font-size: 80%; margin-top: 2em;"><a href="index.txt">(Sourcecode)</a></address>

</body>
</html>

<!-- (c) 2006 by Christian Simon -->
END
