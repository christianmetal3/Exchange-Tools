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

Connect-ExchangeOnline -UserPrincipalName $Creds -ShowBanner:$false 

$User = Read-Host -Prompt "Please enter the users name of the recipient to check. example first.last name"
$RecipientIdentity=(Get-Recipient $User).Identity 
Write-Host "Searching for mailboxes forwarding to $RecipientIdentity..." -ForegroundColor Green
Get-Mailbox -ResultSize unlimited | where {$_.ForwardingAddress -eq $RecipientIdentity} | select Name, Alias