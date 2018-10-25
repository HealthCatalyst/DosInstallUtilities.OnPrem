$module = Get-Module -Name "DosInstallUtilities.OnPrem"
$module | Select-Object *

$params = @{
    'Author' = 'Health Catalyst'
    'CompanyName' = 'Health Catalyst'
    'Description' = 'Functions to install onprem'
    'NestedModules' = 'DosInstallUtilities.OnPrem'
    'Path' = ".\DosInstallUtilities.OnPrem.psd1"
}

New-ModuleManifest @params
