# Packs templates and installer.
# NOTE: To create an installer you'll need a NSIS installed,
# and nsis.exe added to PATH.
# Maybe rewrite someday using this https://cakebuild.net.

# Credit: https://alastaircrabtree.com/how-to-find-latest-version-of-msbuild-in-powershell/
Function Find-MsBuild([int] $MaxVersion = 2019)
{
    $agentPath = "$Env:programfiles (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\msbuild.exe"
    $devPath = "$Env:programfiles (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\msbuild.exe"
    $proPath = "$Env:programfiles (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\msbuild.exe"
    $communityPath = "$Env:programfiles (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe"
    $communityPath2019 = "$Env:programfiles (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\msbuild.exe"
    $fallback2015Path = "${Env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe"
    $fallback2013Path = "${Env:ProgramFiles(x86)}\MSBuild\12.0\Bin\MSBuild.exe"
    $fallbackPath = "C:\Windows\Microsoft.NET\Framework\v4.0.30319"
		
    If ((2017 -le $MaxVersion) -And (Test-Path $agentPath)) { return $agentPath } 
    If ((2017 -le $MaxVersion) -And (Test-Path $devPath)) { return $devPath } 
    If ((2017 -le $MaxVersion) -And (Test-Path $proPath)) { return $proPath } 
    If ((2017 -le $MaxVersion) -And (Test-Path $communityPath)) { return $communityPath } 
    If ((2019 -le $MaxVersion) -And (Test-Path $communityPath2019)) { return $communityPath2019 } 
    If ((2015 -le $MaxVersion) -And (Test-Path $fallback2015Path)) { return $fallback2015Path } 
    If ((2013 -le $MaxVersion) -And (Test-Path $fallback2013Path)) { return $fallback2013Path } 
    If (Test-Path $fallbackPath) { return $fallbackPath } 
        
    throw "Yikes - Unable to find msbuild"
}



Add-Type -A System.IO.Compression.FileSystem

$msbuild = Find-MsBuild

$srcLibDir = "$PWD\Monofoxe\bin\Release"
$srcPipelineLibDir = "$PWD\Monofoxe\bin\Pipeline\Release"

$destCommonDir = "$PWD\Templates\CommonFiles"
$destReleaseDir = "$PWD\Release\"
$destLibDir = "$destReleaseDir\RawLibraries"


$desktopGL = "MonofoxeDesktopGL"
$desktopGLTemplate = "$PWD\Templates\$desktopGL\"

$blankDesktopGL = "MonofoxeDesktopGLBlank"
$blankDesktopGLTemplate = "$PWD\Templates\$blankDesktopGL\"

$windows = "MonofoxeWindows"
$windowsTemplate = "$PWD\Templates\$windows\"

$blankWindows = "MonofoxeWindowsBlank"
$blankWindowsTemplate = "$PWD\Templates\$blankWindows\"

$shared = "MonofoxeShared"
$sharedTemplate = "$PWD\Templates\$shared\"


"Building solution $msbuild..."
&$msbuild ("$PWD\Monofoxe\Monofoxe.sln" ,'/verbosity:q','/p:configuration=Debug','/t:Clean,Build') > $null
&$msbuild ("$PWD\Monofoxe\Monofoxe.sln" ,'/verbosity:q','/p:configuration=Release','/t:Clean,Build') > $null


"Cleaning output directory at $destReleaseDir..."
if (Test-Path "$destReleaseDir" -PathType Container)
{
	Remove-Item "$destReleaseDir" -Force -Recurse
}
New-Item -ItemType Directory -Force -Path "$destReleaseDir" > $null



"Copying templates from $desktopGLTemplate..."
Copy-Item -path "$desktopGLTemplate" -Destination "$destReleaseDir" -Recurse -Container
Copy-Item -path "$destCommonDir/*" -Destination "$destReleaseDir$desktopGL" -Recurse -Container

"Copying templates from $blankDesktopGLTemplate..."
Copy-Item -path "$blankDesktopGLTemplate" -Destination "$destReleaseDir" -Recurse -Container

"Copying templates from $windowsTemplate..."
Copy-Item -path "$windowsTemplate" -Destination "$destReleaseDir" -Recurse -Container
Copy-Item -path "$destCommonDir/*" -Destination "$destReleaseDir$windows" -Recurse -Container

"Copying templates from $blankWindowsTemplate..."
Copy-Item -path "$blankWindowsTemplate" -Destination "$destReleaseDir" -Recurse -Container

"Copying templates from $sharedTemplate..."
Copy-Item -path "$sharedTemplate" -Destination "$destReleaseDir" -Recurse -Container
Copy-Item -path "$destCommonDir/*" -Destination "$destReleaseDir$shared" -Recurse -Container



"Copying libraries for templates from $desktopGL..."
# Copying default shader into the content directory.
New-Item -ItemType Directory -Force -Path "$destReleaseDir$desktopGL\Content\Effects\" > $null
Copy-Item -path "$srcLibDir\*" -Filter "*.fx" -Destination "$destReleaseDir$desktopGL\Content\Effects\"
New-Item -ItemType Directory -Force -Path "$destReleaseDir$desktopGL\Content\References\" > $null
Copy-Item -path "$srcPipelineLibDir\*" -Filter "*.dll" -Destination "$destReleaseDir$desktopGL\Content\References\"

"Copying libraries for $blankDesktopGL..."

"Copying libraries for $windows..."
# Copying default shader into the content directory.
New-Item -ItemType Directory -Force -Path "$destReleaseDir$windows\Content\Effects\" > $null
Copy-Item -path "$srcLibDir\*" -Filter "*.fx" -Destination "$destReleaseDir$windows\Content\Effects\"
New-Item -ItemType Directory -Force -Path "$destReleaseDir$windows\Content\References\" > $null
Copy-Item -path "$srcPipelineLibDir\*" -Filter "*.dll" -Destination "$destReleaseDir$windows\Content\References\"

"Copying libraries for $blankWindows..."

"Copying libraries for $shared..."
# Copying default shader into the content directory.
New-Item -ItemType Directory -Force -Path "$destReleaseDir$shared\Content\Effects\" > $null
Copy-Item -path "$srcLibDir\*" -Filter "*.fx" -Destination "$destReleaseDir$shared\Content\Effects\"
New-Item -ItemType Directory -Force -Path "$destReleaseDir$shared\Content\References\" > $null
Copy-Item -path "$srcPipelineLibDir\*" -Filter "*.dll" -Destination "$destReleaseDir$shared\Content\References\"

"Copying raw libraries..."
New-Item -ItemType Directory -Force -Path "$destLibDir" > $null
Copy-Item -path "$srcLibDir\*" -Filter "*.dll" -Destination "$destLibDir"
Copy-Item -path "$srcLibDir\*" -Filter "*.xml" -Destination "$destLibDir"
Copy-Item -path "$srcLibDir\*" -Filter "*.fx" -Destination "$destLibDir"
New-Item -ItemType Directory -Force -Path "$destLibDir\Pipeline\" > $null
Copy-Item -path "$srcPipelineLibDir\*" -Filter "*.dll" -Destination "$destLibDir\Pipeline\"

"Packing templates..."
[IO.Compression.ZipFile]::CreateFromDirectory("$destReleaseDir$desktopGL", "$destReleaseDir$desktopGL.zip")
[IO.Compression.ZipFile]::CreateFromDirectory("$destReleaseDir$blankDesktopGL", "$destReleaseDir$blankDesktopGL.zip")
[IO.Compression.ZipFile]::CreateFromDirectory("$destReleaseDir$windows", "$destReleaseDir$windows.zip")
[IO.Compression.ZipFile]::CreateFromDirectory("$destReleaseDir$blankWindows", "$destReleaseDir$blankWindows.zip")
[IO.Compression.ZipFile]::CreateFromDirectory("$destReleaseDir$shared", "$destReleaseDir$shared.zip")

"Packing raw libraries..."
[IO.Compression.ZipFile]::CreateFromDirectory("$destLibDir", "$destLibDir.zip")

"Making installer..."
&makensis Installer/packInstaller.nsi

"Cleaning..."
#Remove-Item "$destReleaseDir$desktopGL" -Force -Recurse
#Remove-Item "$destReleaseDir$blankDesktopGL" -Force -Recurse
#Remove-Item "$destReleaseDir$windows" -Force -Recurse
#Remove-Item "$destReleaseDir$blankWindows" -Force -Recurse
#Remove-Item "$destReleaseDir$shared" -Force -Recurse
#Remove-Item "$destLibDir" -Force -Recurse

Read-Host -Prompt "Done! Press Enter to exit"



