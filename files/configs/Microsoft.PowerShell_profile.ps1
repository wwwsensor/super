<#
.SYNOPSIS
  Makes PowerShell more Unix-like. Must be in $profile.
.NOTES
  Author : José María Rodríguez @sensor @ssnice @ss
  WWW    : https://gitlab.com/ssnice/super
#>

## PWSH SPECIFIC #############
# Preferences
$ProgressPreference = "SilentlyContinue"
$ConfirmPreference = "None"
# Elevation status
$admin = $(net session >$null 2>&1;$?)
# Modules
Import-Module cd-extras, gsudoModule, $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 2>$null
##############################

## FUNCTIONS #################
function testcmd { if (Get-Command $args[0] 2>$null) { return $true } else { return $false } }
function which { Get-Command $args 2>$null | Select-Object -ExpandProperty Definition }
function touch { foreach ($file in $args) { "" | Out-File $file -Encoding ASCII } }
function path { $env:path -split ";" }
function epr { e $profile }
function rpr { . $profile }
##############################

## ALIASES ###################
sal ch choco
# Sudo
if (testcmd gsudo) { sal sudo gsudo; sal doas gsudo }
else {
  echo "Get gsudo for a proper experience: sudo choco install -y gsudo"
  function sudo { saps powershell -Verb RunAs -ArgumentList "-NoExit -c $args" }; sal doas sudo
}
# ls
function l   { lsd     $args 2>$null }
function la  { lsd -A  $args 2>$null }
function ll  { lsd -l  $args 2>$null }
function lla { lsd -lA $args 2>$null }
# Git
sal g git
function gco  { git commit -m $args }
function gr   { git restore $args }
function gs   { git status $args }
function gcl  { git clone $args }
function gd   { git diff $args }
function gini { git init $args }
function gpu  { git push $args }
function ga   { git add $args }
##############################

## APPEARANCE ################
# Window title in Unix convention
$Host.UI.RawUI.WindowTitle = "PWSH {0}" -f $PSVersionTable.PSVersion.ToString()
# Prompt
function prompt {
  if ($admin) { "" + (pwd) + " # " }
  else { "" + (pwd) + " $ " }
}
##############################

## BINDS #####################
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit # Ctrl-d to exit
##############################

## PERSONAL ##################
$TERMINAL = "C:\Program Files\Alacritty\alacritty.exe"
$EDITOR = "notepad"
sal e $EDITOR
# . "$HOME\.config\pwsh.ps1"  # Extend file
