<#
.SYNOPSIS
    Shows a quick summary of this computer.

.DESCRIPTION
    Practice script #1 in my PowerShell learning journey.
    Collects basic system details: computer name, OS, uptime,
    current user, CPU, memory, and disk space.

.EXAMPLE
    .\Get-SystemInfo.ps1
#>

# Get operating system and hardware details using CIM (the modern replacement for WMI)
$os  = Get-CimInstance -ClassName Win32_OperatingSystem
$cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

# Uptime = now minus the last time the computer booted
$uptime = (Get-Date) - $os.LastBootUpTime

# Build a custom object so the output is clean and easy to read
$info = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    CurrentUser  = $env:USERNAME
    OS           = $os.Caption
    OSVersion    = $os.Version
    LastBoot     = $os.LastBootUpTime
    Uptime       = "{0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    CPU          = $cpu.Name
    TotalRAM_GB  = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    FreeRAM_GB   = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
}

Write-Host "`n=== System Summary ===" -ForegroundColor Cyan
$info | Format-List

# Show free space on each local drive
Write-Host "=== Disk Space ===" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{Name = "Size_GB"; Expression = { [math]::Round($_.Size / 1GB, 2) }},
        @{Name = "Free_GB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) }} |
    Format-Table -AutoSize
