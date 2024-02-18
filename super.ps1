<#
.SYNOPSIS
  Opinionated companion script for Super, the opinionated custom Windows 10 LTSC 21H2.
.NOTES
  Author : José María Rodríguez @sensor @ssnice @ss
  WWW    : https://gitlab.com/ssnice/super
#>

## VARIABLES #################
# Hide progress bar while executing iwr
$ProgressPreference = "SilentlyContinue"
# Tells if system uses Ryzen
$ryz = $(gin -Property "CsProcessors" | findstr /i ryzen >$null;$?)
# Startup dir
$sdir = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup"
# Variable to make shorter code
$super = "gitlab.com/ssnice/super/-/raw/master/files"
# Elevation status
$admin = $(net session >$null 2>&1;$?)
##############################

## FUNCTIONS #################
function senderr { echo $args;break }
function testcmd { if (Get-Command $args[0] 2>$null) { return $true } else { return $false } }
function getchoco {
  if (!(testcmd choco)) { irm community.chocolatey.org/install.ps1 |iex }
  $features = "allowGlobalConfirmation", "removePackageInformationOnUninstall", "useRememberedArgumentsForUpgrades"
  foreach ($feature in $features) { choco feature enable $feature }
}
function getsw {
  if ($git -eq "y") { choco install -y git --params "/NoShellIntegration /NoGitLfs" }
  if ($cli -eq "y") { choco install -y neovim lsd nerdfont-hack alacritty mingw }
  if ($ryz) { choco install -y amd-ryzen-chipset }
  choco install -y 7zip qview mupdf mpv gsudo vcredist-all
  choco install -y open-shell --params "/StartMenu"
  choco install -y msiafterburner
}
function getpwsh {
  if (!(Get-Module | findstr cd-extras)) { Install-PackageProvider NuGet -Force; Install-Module cd-extras -Force }
  mkdir ~\Documents\WindowsPowerShell
  iwr $super/configs/Microsoft.PowerShell_profile.ps1 -o $profile
}
##############################

## PRIVILEGIES ###############
if (!$admin) { senderr "Must run as Admin" }
Set-ExecutionPolicy RemoteSigned -Force
##############################

## INPUT #####################
echo ""
echo "  y/N"
echo ""
$uac = Read-Host " Ask credentials for elevations?"
$cli = Read-Host " Setup a power user terminal?"
$git = Read-Host " Setup Git?"
echo ""
##############################

## OUTPUT ####################
# Choco
getchoco >$null 2>&1

# Software
getsw >$null 2>&1

# PowerShell
getpwsh >$null 2>&1

# Registry
iwr $super/registry/general.reg -o $env:tmp\general.reg
regedit /s $env:tmp\general.reg
iwr $super/registry/context-menu.reg -o $env:tmp\context-menu.reg
regedit /s $env:tmp\context-menu.reg

# Shit
if (!(testcmd setimer)) { iwr github.com/amitxv/TimerResolution/releases/download/SetTimerResolution-v0.1.3/SetTimerResolution.exe -o $env:windir\setimer.exe } # SetTimerResolution
if (!(testcmd omm))     { iwr download01.logi.com/web/ftp/pub/techsupport/gaming/OnboardMemoryManager_2.0.1639.exe -o $env:windir\omm.exe } # Onboard Memory Manager
if (!(testcmd msleep))  { iwr github.com/amitxv/TimerResolution/releases/download/MeasureSleep-v0.1.7/MeasureSleep.exe -o $env:windir\msleep.exe } # MeasureSleep
if (!(testcmd goip))    { iwr github.com/spddl/GoInterruptPolicy/releases/latest/download/GoInterruptPolicy.exe -o $env:windir\goip.exe } # GoInterruptPolicy

# Startup
mkdir $sdir >$null 2>&1; iwr $super/scripts/startup.cmd -o $sdir\startup.cmd

# Privacy setup
iwr dl5.oo-software.com/files/ooshutup10/OOSU10.exe -o $env:tmp\oosu10.exe
iwr raw.githubusercontent.com/ChrisTitusTech/winutil/main/ooshutup10_winutil_settings.cfg -o $env:tmp\oosu10.cfg
saps $env:tmp\oosu10.exe -ArgumentList "$env:tmp\oosu10.cfg /quiet"

# Security
if ($uac = "y") { iwr $super/registry/askpass.reg -o $env:tmp\askpass.reg; regedit /s $env:tmp\askpass.reg }
##############################
