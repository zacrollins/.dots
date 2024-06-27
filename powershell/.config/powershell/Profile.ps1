[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# ------
# Setup
# ------

$psDotfilesPath = [System.IO.Path]::Combine("$env:XDG_CONFIG_HOME", 'powershell')

if ( !(Test-Path $psDotfilesPath) ) {
    throw 'Cant find PS Dotfiles directory'
}

# # Create src: psdrive
# if (Test-Path ([System.IO.Path]::Combine("$HOME", 'src'))) {
#     New-PSDrive -Root ~/src -Name src -PSProvider FileSystem > $Null
# }

# # define ps dotfiles path
# $psDotfilesPath = 'src:\zr\dots\dotfiles\powershell'
# if (!(Test-Path $psDotfilesPath)) {
#     throw 'Cant find PS Dotfiles directory'
# }

# -----------------------
# functions and aliases
# -----------------------

. $psDotfilesPath\profile_functions.ps1
. $psDotfilesPath\profile_aliases.ps1

# -------------------------
# Default Parameter Values
# -------------------------

$PSDefaultParameterValues += @{
    'Out-Default:OutVariable'           = 'LastResult'
    'Out-File:Encoding'                 = 'utf8'
    'Export-Csv:NoTypeInformation'      = $true
    'ConvertTo-Csv:NoTypeInformation'   = $true
    'Receive-Job:Keep'                  = $true
    'Install-Module:AllowClobber'       = $true
    'Install-Module:Force'              = $true
    'Install-Module:SkipPublisherCheck' = $true
    'Group-Object:NoElement'            = $true
    'Find-Module:Repository'            = 'PSGallery'
    'Install-Module:Repository'         = 'PSGallery'
}

# ---------------------
#region module imports
# ---------------------

# Completion Predictor
if (!(Get-Module CompletionPredictor -ListAvailable)) {
    Find-Module CompletionPredictor | Install-Module
}
Import-Module CompletionPredictor

# Posh git
if (!(Get-Module posh-git -ListAvailable)) {
    Find-Module posh-git | Install-Module
}
Import-Module posh-git

# terminal Icons
if (!(Get-Module Terminal-Icons -ListAvailable)) {
    Find-Module Terminal-Icons | Install-Module
}
Import-Module Terminal-Icons

#endregion

# ---------------------
# tab completion shims
# ---------------------

. $psDotfilesPath\profile_completion.ps1

# --------------------
#region If on Windows
# --------------------
# Chocolatey profile
if ($PSVersionTable.Platform -ne 'Unix') {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }

    function Test-Administrator {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
        $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
        $IsAdmin = $principal.IsInRole($admin)
        return $IsAdmin
    }

    $IsAdmin = Test-Administrator
}
else {
    # if on mac, add homebrew shell integration
    if ($PSVersionTable.Platform -like '*Darwin*') {
        $(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
    }
    # import unix tab completion
    try {
        Import-PSUnixTabCompletion
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Install-Module Microsoft.PowerShell.UnixTabCompletion -Repository PSGallery -AcceptLicense -Force
        Import-PSUnixTabCompletion
    }
}

#endregion If on Windows


# ----------------
#region PSReadline
# ----------------
# set vi mode
Set-PSReadlineOption -EditMode Vi

# general
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

Set-PSReadLineKeyHandler -Chord Tab -Function Complete

# Menu Complete for tab completion is really nice and gives you parameter information during selection.
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true

# add auto prediction
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 1000

# emacs cursor movements
# Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
# Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
# Set-PSReadLineKeyHandler -Key Ctrl+u -Function RevertLine

# PS FZF
if (!(Get-Module PSFzf -ListAvailable)) {
   Find-PSResource PSFzf | Install-PSResource 
}
Remove-PSReadLineKeyHandler 'Ctrl+r'
Remove-PSReadLineKeyHandler 'Ctrl+t'
Import-Module PSFzf

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

#endregion PSReadline

# ------
# Pyenv
# ------

# pyenv env variables
# $env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win\"
# $env:PYENV_ROOT = "$env:USERPROFILE\.pyenv\pyenv-win\"
# $env:PYENV_HOME = "$env:USERPROFILE\.pyenv\pyenv-win\"

# $currentPath = [System.Environment]::GetEnvironmentVariable('PATH') -split ';'
# $pyenvBinPath = "$env:USERPROFILE\.pyenv\pyenv-win\bin"
# $pyenvShimsPath = "$env:USERPROFILE\.pyenv\pyenv-win\shims"
# $updatedPath = ($currentPath + $pyenvBinPath + $pyenvShimsPath) -join ';'
# [System.Environment]::SetEnvironmentVariable('PATH', $updatedPath, 'Process')

# --------
# Prompt
# --------

# $ENV:STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml"
Invoke-Expression (&starship init powershell)

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\zr.omp.json" | Invoke-Expression
# enable Az in oh my posh
# $env:POSH_AZURE_ENABLED = $true
# use Posh-Git instead of git.exe in oh my posh
# $env:POSH_GIT_ENABLED = $true

# $env:KOMOREBI_CONFIG_HOME = "${env:USERPROFILE}\.config\komorebi"

# $wshell = New-Object -ComObject wscript.shell
