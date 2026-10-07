function MergeFiles-JSon {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)] [string]$SourceFileDirectory,
        [parameter(Mandatory = $true)] [string]$Pattern,
        [parameter(Mandatory = $true)] [string]$FinalFileName,
        [parameter(Mandatory = $true)] [int]$JSonDepth,
        [switch]$RemoveFiles
    )
    begin
    {
        Write-Verbose "$($MyInvocation.MyCommand) Starting...";
        $FunctionStatisticsDataSet = @{};
        $FunctionStatisticsDataSet.Add('Invocation',$MyInvocation);
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('StartTime',$CurrentDate);
        $CurrentDateFormat = Get-Date -Date $CurrentDate -Format FileDateTimeUniversal;
        $FunctionStatisticsFileName = "$($MyInvocation.MyCommand).Execution.$($CurrentDateFormat).json";
    }
    process
    {
        $FullDataSet = @();
        Write-Verbose "Merging Data";
        Get-ChildItem -Path $SourceFileDirectory -Filter $Pattern | ForEach-Object -Process {$FullDataSet += Get-Content -Path $_.PSPath -Raw | ConvertFrom-Json;}
        Write-Verbose "Writing Final File";
        Write-DataSetToFile -FileName $FinalFileName -DataSet $FullDataSet -JsonDepth $JsonDepth;
        if ($RemoveFiles.IsPresent) {
            Write-Verbose "Removing Original Files";
            Remove-Item -Path $SourceFileDirectory\* -Filter $Pattern -Force -Recurse;
        }
        Write-Verbose "End of Process"
    }
    end
    {
        Write-Verbose "Beginning of End"
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 3
        $FunctionDataSet = $DataSetToWriteJSon | ConvertFrom-Json;
        try {Write-TELLogFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $FunctionDataSet -JSonDepth 10;}
		catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        Write-Verbose "... $($MyInvocation.MyCommand) Ending";
    }
}