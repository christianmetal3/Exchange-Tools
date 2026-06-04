# Check PowerShell Version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Error: PowerShell 7 or higher is required to run this script." -ForegroundColor Red
    Write-Host "Current version: $($PSVersionTable.PSVersion.ToString())" -ForegroundColor Yellow
    Write-Host "Please run the script using Powershell 7 to install it go to https://github.com/PowerShell/PowerShell/releases/download/v7.6.2/PowerShell-7.6.2-win-x64.msi" -ForegroundColor White
    return
}

# Check Exchange Online Management Module
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Error: The 'ExchangeOnlineManagement' module is not installed." -ForegroundColor Red
    Write-Host "Please install it by running the following command in an elevated PowerShell session:" -ForegroundColor Yellow
    Write-Host "    Install-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor White
    return
}

#Banner
Clear-Host

# Minimalist Administrative UI Header
$TopBorder = "┌" + ("─" * 68) + "┐"
$BotBorder = "└" + ("─" * 68) + "┘"

Write-Host $TopBorder -ForegroundColor Gray
Write-Host "│ " -NoNewline -ForegroundColor Gray
Write-Host "EXCHANGE Tools" -ForegroundColor White -NoNewline
Write-Host (" " * 52)  "│" -ForegroundColor Gray

Write-Host "│ " -NoNewline -ForegroundColor Gray
Write-Host "MODULE: Internal Mailbox Forwarding Management Tool" -ForegroundColor Cyan -NoNewline
Write-Host (" " * 15)  "│" -ForegroundColor Gray
Write-Host $BotBorder -ForegroundColor Gray

# Compact Metadata Block
Write-Host "  [Scope]       " -NoNewline -ForegroundColor DarkGray
Write-Host "Tenant-Wide Internal Forwarding Audit & Remediation" -ForegroundColor Gray
Write-Host "  [Security]    " -NoNewline -ForegroundColor DarkGray
Write-Host "Requires Exchange Administrator Credentials" -ForegroundColor Gray
Write-Host ("─" * 70) -ForegroundColor DarkGray
Write-Host ""
# End of banner

# The administrator is prompted to enter their admin credentials.
$Creds = Read-Host -Prompt "Please enter your admin account email"
#connect to the exchange server
Connect-ExchangeOnline -UserPrincipalName $Creds -ShowBanner:$false 
# Prompts for a user to check
$User = Read-Host -Prompt "Please enter the users name of the recipient to check. example first.last name"
$RecipientIdentity = (Get-Recipient $User).Identity 
Write-Host "Searching for mailboxes forwarding to $RecipientIdentity..." -ForegroundColor Green
$Mailboxes = @(Get-Mailbox -ResultSize unlimited | Where-Object { $_.ForwardingAddress -eq $RecipientIdentity })

if ($Mailboxes.Count -eq 0) {
    Write-Host "No mailboxes found forwarding to $RecipientIdentity." -ForegroundColor Yellow
}
else {
    Write-Host "`nFound the following mailboxes forwarding to $RecipientIdentity :" -ForegroundColor Cyan
    $Mailboxes | Select-Object Name, Alias, ForwardingAddress | Format-Table -AutoSize

    Write-Host "`nSelect an option to proceed:" -ForegroundColor Cyan
    Write-Host "1) Interactively decide to unforward each mailbox"
    Write-Host "2) Unforward ALL of the above mailboxes"
    Write-Host "3) Exit (keep forwarding settings unchanged)"
    
    $Choice = Read-Host -Prompt "Enter choice (1, 2, or 3)"

    switch ($Choice) {
        "1" {
            foreach ($Mailbox in $Mailboxes) {
                $Confirm = Read-Host -Prompt "Unforward mailbox '$($Mailbox.Name)' ($($Mailbox.UserPrincipalName))? (Y/N)"
                if ($Confirm -eq "Y" -or $Confirm -eq "y") {
                    Write-Host "Removing forwarding to $RecipientIdentity for $($Mailbox.Name)..." -ForegroundColor Yellow
                    Set-Mailbox -Identity $Mailbox.UserPrincipalName -ForwardingAddress $null
                    Write-Host "Successfully unforwarded." -ForegroundColor Green
                }
                else {
                    Write-Host "Skipped $($Mailbox.Name)." -ForegroundColor Gray
                }
            }
        }
        "2" {
            $ConfirmAll = Read-Host -Prompt "Are you sure you want to unforward ALL $($Mailboxes.Count) mailboxes? (Y/N)"
            if ($ConfirmAll -eq "Y" -or $ConfirmAll -eq "y") {
                foreach ($Mailbox in $Mailboxes) {
                    Write-Host "Removing forwarding to $RecipientIdentity for $($Mailbox.Name)..." -ForegroundColor Yellow
                    Set-Mailbox -Identity $Mailbox.UserPrincipalName -ForwardingAddress $null
                    Write-Host "Successfully unforwarded." -ForegroundColor Green
                }
            }
            else {
                Write-Host "Operation cancelled." -ForegroundColor Gray
            }
        }
        "3" {
            Write-Host "Exiting without making changes." -ForegroundColor Gray
        }
        default {
            Write-Host "Invalid choice. Exiting without making changes." -ForegroundColor Red
        }
    }
}
