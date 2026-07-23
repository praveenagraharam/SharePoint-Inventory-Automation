# ============================
# SharePoint File Type Summary Script (Hybrid: App-Only Cert + Interactive)
# Author: Praveen Agraharam Ramakrishnan
# ============================
 
$ClientId     = "Add the Client ID"
$TenantId     = "Add the Tenant ID"
$Thumbprint   = "Add the Thumbprint"
 
$InputFile    = "C:\temp\Praveen\URL.txt" # Compile site entries into a single list and save them as URL.txt in the designated input path #
 
$InventoryPath = "C:\temp\Praveen\SP_AllSites_FileInventory.csv"
$SummaryPath   = "C:\temp\Praveen\SP_AllSites_FileTypeSummary.csv"
$ErrorLog      = "C:\temp\Praveen\SP_SiteErrors.log"
 
# =====================================
# Certificate and Thumbprint Validation
# =====================================
 
 
$certCheck = Get-ChildItem -Path "Cert:\CurrentUser\My\$Thumbprint" -ErrorAction SilentlyContinue
if (-not $certCheck) {
    $certCheck = Get-ChildItem -Path "Cert:\LocalMachine\My\$Thumbprint" -ErrorAction SilentlyContinue
}
if (-not $certCheck) {
    throw "No certificate with thumbprint '$Thumbprint' was found in Cert:\CurrentUser\My or Cert:\LocalMachine\My on this machine. Confirm the certificate was generated/installed here and the thumbprint is correct."
}
Write-Host "Certificate found: $($certCheck.Subject) (expires $($certCheck.NotAfter))" -ForegroundColor Green
 
# Track whether we have already done an interactive login
$Global:InteractiveConnected = $false
 
function Connect-AppOnly {
    param(
        [string]$SiteUrl
    )
 
    Write-Host "  [Auth] Trying app-only (certificate) for: $SiteUrl"
 
    Connect-PnPOnline -Url $SiteUrl `
        -ClientId $ClientId `
        -Thumbprint $Thumbprint `
        -Tenant $TenantId
}
 
function Connect-Interactive {
    param(
        [string]$SiteUrl
    )
 
    if (-not $Global:InteractiveConnected) {
        Write-Host "  [Auth] First interactive login for: $SiteUrl"
        Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive
        $Global:InteractiveConnected = $true
    }
    else {
        Write-Host "  [Auth] Reusing interactive session for: $SiteUrl"
        Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive
    }
}
 
function Get-LibraryItems {
    param(
        [string]$SiteUrl
    )
 
    $libraries = Get-PnPList | Where-Object {
        $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false
    }
 
    foreach ($lib in $libraries) {
 
        Write-Host "    Scanning library: $($lib.Title)"
 
        $items = Get-PnPListItem -List $lib.Title -PageSize 2000 -Fields `
            "FileLeafRef","FileRef","Editor","Modified","File_x0020_Size"
 
        foreach ($item in $items) {
            if ($item.FileSystemObjectType -eq "File") {
 
                $file = $item.FieldValues
 
                [PSCustomObject]@{
                    SiteUrl        = $SiteUrl
                    Library        = $lib.Title
                    FileName       = $file.FileLeafRef
                    FileType       = ($file.FileLeafRef.Split('.')[-1]).ToLower()
                    FilePath       = $file.FileRef
                    ModifiedBy     = $file.Editor.LookupValue
                    Modified       = $file.Modified
                    FileSizeMB     = [math]::Round(($file.File_x0020_Size / 1MB), 2)
                    AuthMode       = $null   # we'll set this outside
                }
            }
        }
    }
}
 
# ============================
# Unified Site Count
# ============================
 
$AllSites = Get-Content $InputFile | Where-Object { $_ -match "^https" }
$AllSites = $AllSites | Sort-Object -Unique
 
Write-Host "Total sites found: $($AllSites.Count)"
 
# ============================
# Inventory Collection
# ============================
 
$FileInventory = @()
 
foreach ($SiteUrl in $AllSites) {
 
    Write-Host "`nConnecting (Hybrid): $SiteUrl"
 
    $authMode = $null
 
    # 1. Try app-only (certificate) first
    try {
        Connect-AppOnly -SiteUrl $SiteUrl
        $authMode = "AppOnly"
        Write-Host "  [Auth] App-only succeeded for: $SiteUrl" -ForegroundColor Green
    }
    catch {
        $msg = "APP-ONLY FAILED: $SiteUrl - $($_.Exception.Message)"
        Write-Host "  [Auth] $msg" -ForegroundColor Yellow
        Add-Content -Path $ErrorLog -Value $msg
 
        # 2. Fallback to interactive
        try {
            Connect-Interactive -SiteUrl $SiteUrl
            $authMode = "Interactive"
            Write-Host "  [Auth] Interactive succeeded for: $SiteUrl" -ForegroundColor Cyan
        }
        catch {
            $msg2 = "INTERACTIVE FAILED: $SiteUrl - $($_.Exception.Message)"
            Write-Host "  [Auth] $msg2" -ForegroundColor Red
            Add-Content -Path $ErrorLog -Value $msg2
            continue
        }
    }
 
    # 3. Once connected (either mode), scan libraries
    try {
        $items = Get-LibraryItems -SiteUrl $SiteUrl
 
        foreach ($i in $items) {
            $i.AuthMode = $authMode
            $FileInventory += $i
        }
    }
    catch {
        $msg = "FAILED TO SCAN: $SiteUrl - $($_.Exception.Message)"
        Write-Host $msg -ForegroundColor Red
        Add-Content -Path $ErrorLog -Value $msg
        continue
    }
}
 
# ============================
# Report Summary
# ============================
 
$FileTypeSummary = $FileInventory |
    Group-Object -Property FileType |
    Sort-Object Count -Descending |
    Select-Object Name, Count
 
$FileInventory | Export-Csv -Path $InventoryPath -NoTypeInformation
$FileTypeSummary | Export-Csv -Path $SummaryPath -NoTypeInformation
 
Write-Host "`nInventory saved to:"
Write-Host $InventoryPath
Write-Host $SummaryPath
 
Write-Host "`nErrors logged to:"
Write-Host $ErrorLog
