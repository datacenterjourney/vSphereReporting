
function Get-VmAverage {
    <#
        .SYNOPSIS
            Get VM average of CPU, Memory, Disk & Network
        .DESCRIPTION
            Exports a CSV list of VM(s) average of the CPU, Memory, Disk & Network of 1 hour samples for specified amount of days
        .EXAMPLE
            Get-VmAverage -numDays 14 -csvPath c:/reports/VmAverage.csv
        .EXAMPLE
            Get-VmAverage -numDays 30 -csvPath ~/Desktop/reports/AverageVms.csv
        .NOTES
            Created: 01/03/2020 by Manuel Martinez, Version 1.0
            Github: https://www.github.com/datacenterjourney
    #>

    [CmdletBinding()]
    param (
        # Number of days to get average for
        [Parameter(Mandatory)]
        [Int32]
        $numDays,

        # Csv file path
        [Parameter(Mandatory)]
        [string]
        $csvPath
    )
    
    process {
        # Get the X day 60 minute interval average of CPU, Memory, Network & Disk
        Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"} | Select-Object Name, VMHost, NumCpu, MemoryMB,
        @{N="CPU Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Memory Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Network Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Disk Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}} |
        Export-Csv -Path $csvPath
    }
    
}


