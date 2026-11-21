<#
.SYNOPSIS
    Checks basic Windows 11 system health information.

.DESCRIPTION
    This beginner-friendly script reports:
      1. Whether Windows Defender Firewall is enabled
      2. Free disk space on the C: drive
      3. The five processes using the most RAM
      4. The most recent system boot time

    Results are printed on screen and saved to a text file on the Desktop.
#>

# Stop the script cleanly when a required command cannot run.
$ErrorActionPreference = "Stop"

# Create a timestamp so that every report has a unique filename.
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Save the report on the Desktop. Fall back to the user's profile if needed.
try {
    $ReportDirectory = [Environment]::GetFolderPath("Desktop")
    if ([string]::IsNullOrWhiteSpace($ReportDirectory)) {
        $ReportDirectory = $env:USERPROFILE
    }
}
catch {
    $ReportDirectory = $PSScriptRoot
}

$ReportPath = Join-Path -Path $ReportDirectory -ChildPath "SystemHealthCheck_$Timestamp.txt"

# Collect all report lines in an array so they can be shown and saved together.
$Report = [System.Collections.Generic.List[string]]::new()
$Report.Add("Windows 11 System Health Report")
$Report.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$Report.Add("----------------------------------------")
$Report.Add("")

# 1. Check Windows Defender Firewall for each network profile.
$Report.Add("1. Windows Defender Firewall")

try {
    $FirewallProfiles = Get-NetFirewallProfile

    foreach ($Profile in $FirewallProfiles) {
        $Status = if ($Profile.Enabled) { "Enabled" } else { "DISABLED" }
        $Report.Add("   $($Profile.Name) profile: $Status")
    }

    $DisabledProfiles = @($FirewallProfiles | Where-Object { -not $_.Enabled })
    if ($DisabledProfiles.Count -eq 0) {
        $Report.Add("   Overall: Enabled for all network profiles.")
    }
    else {
        $Report.Add("   Overall: DISABLED on $($DisabledProfiles.Count) profile(s).")
    }
}
catch {
    $Report.Add("   Firewall status could not be checked.")
    $Report.Add("   Error: $($_.Exception.Message)")
}

$Report.Add("")

# 2. Check free disk space on the C: drive.
$Report.Add("2. Free Disk Space (C: Drive)")

try {
    $CDrive = Get-PSDrive -Name "C" -ErrorAction Stop
    $FreeGB = [math]::Round($CDrive.Free / 1GB, 2)
    $UsedGB = [math]::Round($CDrive.Used / 1GB, 2)
    $TotalGB = [math]::Round(($CDrive.Free + $CDrive.Used) / 1GB, 2)

    $Report.Add("   Free: $FreeGB GB")
    $Report.Add("   Used: $UsedGB GB")
    $Report.Add("   Total: $TotalGB GB")
}
catch {
    $Report.Add("   C: drive information could not be checked.")
    $Report.Add("   Error: $($_.Exception.Message)")
}

$Report.Add("")

# 3. Find the five processes with the largest working-set memory usage.
$Report.Add("3. Top 5 Processes Using the Most RAM")

try {
    $TopProcesses = Get-Process |
        Sort-Object -Property WorkingSet64 -Descending |
        Select-Object -First 5

    $Rank = 1
    foreach ($Process in $TopProcesses) {
        $MemoryMB = [math]::Round($Process.WorkingSet64 / 1MB, 2)
        $Report.Add("   $Rank. $($Process.ProcessName) (PID $($Process.Id)): $MemoryMB MB")
        $Rank++
    }
}
catch {
    $Report.Add("   Process information could not be checked.")
    $Report.Add("   Error: $($_.Exception.Message)")
}

$Report.Add("")

# 4. Find the last time Windows started.
$Report.Add("4. Last System Boot Time")

try {
    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $BootTime = $OperatingSystem.LastBootUpTime
    $Report.Add("   $($BootTime.ToString('yyyy-MM-dd HH:mm:ss'))")
}
catch {
    $Report.Add("   System boot time could not be checked.")
    $Report.Add("   Error: $($_.Exception.Message)")
}

$Report.Add("")
$Report.Add("----------------------------------------")
$Report.Add("Report saved to:")
$Report.Add("   $ReportPath")

# Write to the screen and to the text file.
$Report | Tee-Object -FilePath $ReportPath
