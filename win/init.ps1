
# Safe
$INIT_EXECUTION_POLICY = Get-ExecutionPolicy -list

# Set execution policy for current user to bypass only for this script
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass



# Set execution policy back to original
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $INIT_EXECUTION_POLICY.ExecutionPolicy[3]