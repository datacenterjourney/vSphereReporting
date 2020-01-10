function Get-VmAverage {
    <#
        .SYNOPSIS
            Get VM average of CPU, Memory, Disk & Network
        .DESCRIPTION
            Exports a CSV list of VM(s) average of the CPU, Memory, Disk & Network of 1 hour samples for specified amount of days
        .EXAMPLE
            Get-VmAverage -txtPath c:\reports\vms.txt -numDays 14 -csvPath c:\reports\VmAverage.csv
        .EXAMPLE
            Get-VmAverage -txtPath ~/Documents/VMs.txt -numDays 30 -csvPath ~/Desktop/reports/AverageVms.csv
        .NOTES
            Created: 01/03/2020 by Manuel Martinez, Version 1.1
            Github: https://www.github.com/datacenterjourney
    #>

    [CmdletBinding()]
    param (
        # Path to txt file with VM names
        [Parameter(Mandatory)]
        [string]
        $txtPath,

        # Number of days to get average for
        [Parameter(Mandatory)]
        [Int32]
        $numDays,

        # Csv file path
        [Parameter(Mandatory)]
        [string]
        $csvPath
    )
    
    begin {
        # Checks to make sure that the file path given has a TXT file and gets those VMs
        $findTxt = Test-Path -Path $txtPath -Include "*.txt"
        if ($findTxt -eq $false) {
            Write-Error -Message "The specified path to txt is incorrect, please verify path of txt and try again"
            break
        } else {
            $vmFile = Get-Content -Path $txtPath
            $vms = Get-VM $vmFile
        }
    }

    process {
        # Get the X day 60 minute interval average of CPU, Memory, Network & Disk and export to CSV
        $vms | Select-Object Name, VMHost, NumCpu, MemoryMB,
        @{N="CPU Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Memory Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Network Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}},
        @{N="Disk Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (Get-Date).AddDays(-$numDays) -IntervalMins 60 | Measure-Object Value -Average).Average),2)}} |
        Export-Csv -Path $csvPath
    }
    
}
