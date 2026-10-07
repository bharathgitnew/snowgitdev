function Start-AribaProcess2{
	[CmdletBinding()]
	param()
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
		Write-Host "Fetching ... Requesting Ariba Job Status"      	    -ForegroundColor Cyan;
			Request-AribaJobsStatus;
		Write-Host "Fetching ... Requesting Ariba Job Files"      		-ForegroundColor Cyan;
			Request-AribaJobFiles;
		Write-Host "Fetching ... Set Ariba Last Completed Information"	-ForegroundColor Cyan;
			Set-AribaLastCompleted;
	}
    end
    {
        Write-Verbose "... $($MyInvocation.MyCommand) Ending";
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 3
        $FunctionDataSet = $DataSetToWriteJSon | ConvertFrom-Json;
		try {Write-TELLogFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $FunctionDataSet -JSonDepth 10;}
		catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        Write-Verbose "... $($MyInvocation.MyCommand) Ended";
	}
}