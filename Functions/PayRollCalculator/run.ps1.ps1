# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"


try
{
    Connect-AzAccount -Identity -Subscription sub-mq01-azcst-01
}catch {
    Write-Host "Error connecting to Azure using fun app identity. $_.Exception"
    throw $_.Exception
}



# --- Functions ---

function Get-GrossSalary {
    param([double]$basePay)
    # Dummy allowance logic
    $hra = $basePay * 0.20
    $bonus = $basePay * 0.10
    return [math]::Round($basePay + $hra + $bonus, 2)
}

function Get-Deductions {
    param([double]$grossPay)
    # Dummy deductions
    $pf = $grossPay * 0.12
    $tax = 500
    return [math]::Round($pf + $tax, 2)
}


$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[$currentTime] Payroll calculation function started."

# Read base pay from environment variable
$basePayStr = $env:BASE_PAY
if (-not $basePayStr) {
    Write-Host "ERROR: Environment variable 'BASE_PAY' not set."
    exit 1
}
$basePay = [double]$basePayStr

# Employee name 
$employeeName = $env:EMPLOYEE_NAME
if (-not $employeeName) { $employeeName = "TestUser" }

# Calculate salary
$gross = Get-GrossSalary -basePay $basePay
$deductions = Get-Deductions -grossPay $gross
$net = $gross - $deductions

Write-Host "Employee: $employeeName"
Write-Host "  Gross: ₹$gross | Deductions: ₹$deductions | Net Salary: ₹$net"

Write-Host "Payroll function completed."


