function Remove-FileIngestionDrive
{
    Param(
        [Parameter(Mandatory = $true,
        HelpMessage = "-DriveName is required.")]
        [string]$DriveName
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
		$DebugString = ' - Removing Drive ['+$DriveName+']'
		Write-Debug $DebugString
		Remove-PSDrive -Name $DriveName -Force
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