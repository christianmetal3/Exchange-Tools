$Creds = Read-Host -Prompt "Please enter your admin account email"
Connect-ExchangeOnline -UserPrincipalName $Creds -ShowBanner:$false 
$User = Read-Host -Prompt "Please enter the users name of the recipient to check. example first.last name"
$RecipientIdentity=(Get-Recipient $User).Identity 
Write-Host "Searching for mailboxes forwarding to $RecipientIdentity..." -ForegroundColor Green
Get-Mailbox -ResultSize unlimited | where {$_.ForwardingAddress -eq $RecipientIdentity} | select Name, Alias 