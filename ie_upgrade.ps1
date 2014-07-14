# Internet Explorer 11 Check and Upgrade
# Author: John Patrick McCarthy
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
# Date: 14th July, 2014
# Version 1.0
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27 ; I Corinthians 15:1-4
#----------------------------------------------------------------
# Domain
$domain="example"
# Username
$user="user"
# List of Machines to check
$comp = "list", "of", "computers"
# Stores your credentials in a variable
$cred = Get-credential -credential $domain\$user
# Session used to connect to the machines stored in the $comp variable
$check = New-Pssession -cn $comp -credential $cred -authentication Credssp
# Checks for the installed version of Internet Explorer
$outdated=Invoke-command -Session $check -Scriptblock {
	# Latest version
	$latest="11.00.9600.16428"
	# Installed version
	$version_IE = (gci "C:\Program Files\Internet Explorer\iexplore.exe").versioninfo.productversion
	# Resets the $needed variable
	$needed=@()
	# If statement to get a list of machines needing an INternet Explorer upgrade
	if ($version_IE -lt $latest){
		# Stores machines computername in the $needed variable
		$needed += gc env:computername
	}
}

# Session used to connect to the machines that need an Internet Explorer upgrade
$upgrade = New-Pssession -cn $outdated -credential $cred -authentication Credssp
# Copies over the needed files
Invoke-command -Session $upgrade -Scriptblock {
	# Path where your Internet Explorer executable and batch file is located
	$path="\\path\to\files"
	# Path to copy and store Internet Explorer files to
	$store="C:\Temp"
	Function copy_files{
		# Set content of batch file
		Set-Content $path\ie11.bat "start /wait c:\temp\IE11.exe /quiet /update-no /norestart"
		# Copies over the Internet Explorer Installation media
		Copy-item $path\ie11.exe -destination $store\ie11.exe
		# Copies over the batch file
		Copy-item $path\ie11.bat -destination $store\ie11.bat
	}
	Function run_upgrade{
		# Runs the Internet Explorer upgrade
		$store\IE11.bat
	}
	Function remove_files{
		# Removes the Internet Explorer executable file
		Remove-item $store\ie11.exe
		# Removes the batch file
		Remove-item $store\ie11.bat
	}
}
Invoke-command -Session $upgrade -Scriptblock {copy_files}
Invoke-command -Session $upgrade -Scriptblock {run_upgrade}
Invoke-command -Session $upgrade -Scriptblock {remove_files}
