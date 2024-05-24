# --------
# ALIASES
# --------

# git
New-Alias 'g' -Value 'git'
New-Alias 'gs' -Value 'GitStatus'

# change azure context quickly
Set-Alias -Name gazc Get-AzContext
Set-Alias -Name sazc Select-AzContext

# neovim alias
Set-Alias -Name vi nvim

# K8s
New-Alias -Name 'k' -Value 'kubectl'

if (!(Get-Module PSKubeContext -ListAvailable)) {
    Find-Module PSKubeContext | Install-Module
}
Import-Module PSKubeContext

Set-Alias kubens -Value Select-KubeNamespace
Set-Alias kubectx -Value Select-KubeContext
Register-PSKubeContextComplete

# jq
# Set-Alias jq -Value 'jq-win64'

# argocd
Set-Alias argocd -Value 'argocd-windows-amd64'

# code insiders
New-Alias -Name code -Value 'code-insiders'

# general
New-Alias -Name '..' -Value 'BackOne'
New-Alias -Name '...' -Value 'BackTwo'
New-Alias -Name clip -Value Set-Clipboard