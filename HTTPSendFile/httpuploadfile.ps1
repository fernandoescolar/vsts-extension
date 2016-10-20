[CmdletBinding()]
param
(
    [String] [Parameter(Mandatory = $true)]
	$src,
	[String] [Parameter(Mandatory = $true)]
	$url,
	[String]
	$usr,
	[String]
	$pwd,
	[String]
	$dmn
)

$wc = New-Object System.Net.WebClient

if ($usr)
{
    if ($pwd)
    {
        if ($dmn)
        {
            $wc.Credentials = New-Object System.Net.NetworkCredential($usr, $pwd, $dmn)
        }
        else
        {
            $wc.Credentials = New-Object System.Net.NetworkCredential($usr, $pwd)
        }
    }
}

$wc.UploadFile($url, $src)