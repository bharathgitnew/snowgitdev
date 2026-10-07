function Remove-TextSection {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true,
        HelpMessage = "-TextLine is required")]
		[string]$TextLine,

        [parameter(HelpMessage = "-Seperator is required")]
		[string]$Seperator,

		[parameter(HelpMessage = "-FirstOccurance is required")]
		[int]$FirstOccurance = 0,

		[parameter(HelpMessage = "-SecondOccurance is required")]
		[int]$SecondOccurance = 0
    )
    begin
    {
        # #$VerbosePreference = "continue";
        # Write-Verbose "$($MyInvocation.MyCommand) Starting...";
        # $FunctionStatisticsDataSet = @{};
        # $FunctionStatisticsDataSet.Add('Invocation',$MyInvocation);
        # $CurrentDate = Get-Date;
        # $FunctionStatisticsDataSet.Add('StartTime',$CurrentDate);
        # $CurrentDateFormat = Get-Date -Date $CurrentDate -Format FileDateTimeUniversal;
        # $FunctionStatisticsFileName = "$($MyInvocation.MyCommand).Execution.$($CurrentDateFormat).json";
    }
    process {
        if (-not $Seperator) { Write-Verbose "   ... No Seperator"; return $TextLine; } else { Write-Verbose "   ... Separator - $($Seperator)"; }
        # if (-not $FirstOccurance -and -not $SecondOccurance) { Write-Verbose "   ... No Occurances"; return $TextLine; }
        if($Seperator -in '|') { $Seperator = "\$($seperator)"; Write-Verbose "   ... New Separator - $($Seperator)"; }
        $SeperatorLocations = [regex]::Matches($TextLine, $Seperator).Index;
        $TotalSeperators = $SeperatorLocations.Length;
        Write-Verbose "   ...$($TotalSeperators) Seperators in string";
        if($TotalSeperators -gt $FirstOccurance -and $FirstOccurance -gt 0) {$FirstSeperatorPosition = $SeperatorLocations[$FirstOccurance-1];} else {$FirstSeperatorPosition = 0;}
        Write-Verbose "   ... First Seperator Postion $($FirstSeperatorPosition)";
        if($TotalSeperators -ge $SecondOccurance -and $SecondOccurance -gt 0) {$SecondSeperatorPosition = $SeperatorLocations[$SecondOccurance-1];} else {$SecondSeperatorPosition = $TextLine.Length;}
        Write-Verbose "   ... Second Seperator Postion $($SecondSeperatorPosition)";
        return $TextLine.SubString(0,$FirstSeperatorPosition+1)+$TextLine.SubString($SecondSeperatorPosition);
    }
    end
    {
        # Write-Verbose "... $($MyInvocation.MyCommand) Ending"
        # $CurrentDate = Get-Date;
        # $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        # $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 5;
        # $FunctionDataSet = $DataSetToWriteJSon | ConvertFrom-Json;
		# try {Write-TELLogFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $FunctionDataSet -JSonDepth 10;}
		# catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        # Write-Verbose "$($MyInvocation.MyCommand) Ended";
    }
}