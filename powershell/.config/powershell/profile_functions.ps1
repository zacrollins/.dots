# ----------
# FUNCTIONS
# ----------

function Start-Komorebi {
    & komorebic.exe start --await-configuration
}

function Stop-Komorebi {
    if (!(Test-Path -Path "$( $ENV:ProgramFiles )/komorebi/bin/komorebic.exe")) {
        throw 'Komorebi is not installed. Please install Komorebi before running this function.'
    }
    if (Get-Process | Where-Object { $_.Name -eq 'komorebi' }) {
        komorebic restore-windows
        komorebic retile
        komorebic stop
    }
    Start-Sleep 3
    Get-Process | Where-Object { $_.Name -eq 'komorebi' } | Stop-Process

    $whkd = Get-Process whkd -ErrorAction SilentlyContinue
    if ($whkd) {
        $whkd | Stop-Process
    }
    $pythonYasb = Get-Process python -ErrorAction SilentlyContinue
    if ($pythonYasb) {
        $pythonYasb | Stop-Process
    }
}


function Get-MyPublicIp {
    Invoke-RestMethod -Uri 'http://ipinfo.io/json' | Select-Object -ExpandProperty 'ip'
}

# Function to remove old ps module versions
function Remove-OldModules {
    $Latest = Get-InstalledModule
    foreach ($module in $Latest) {
        Write-Verbose -Message "Uninstalling old versions of $($module.Name) [latest is $( $module.Version)]" -Verbose
        Get-InstalledModule -Name $module.Name -AllVersions | Where-Object { $_.Version -ne $module.Version } | Uninstall-Module -Verbose
    }
}

# base64 encode and decode
Function ConvertFrom-Base64($base64) {
    return [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($base64))
}

Function ConvertTo-Base64($plain) {
    return [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plain))
}

# Useful shortcuts for traversing directories
function BackOne { Set-Location .. }
function BackTwo { Set-Location ../.. }

# Compute file hashes - useful for checking successful downloads
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# -------------------
#region Git Functions
# -------------------

function GitStatus {
    git status
}

function GitLogPretty {
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all
}

function Get-Branch {
    git rev-parse --abbrev-ref HEAD
}

function Get-Origin {
    (git config remote.origin.url) -replace '\.git$'
}

#endregion
