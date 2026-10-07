function Invoke-DataRequest{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
		[scriptblock]$Command,

        [parameter(Mandatory = $false)]
		[string]$CacheKey
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
        Write-Verbose "  -- Evaluating CacheKey :$($CacheKey)"
        $InternalDataSet = @();
		if($CacheKey){
			Write-Verbose "  -- Checking Cache for $($CacheKey)"
			$InternalDataSet = Read-CacheKey -Key $CacheKey;
			if($null -eq $InternalDataSet)
			{
				$InternalDataSet = Read-CacheKey -Key $CacheKey -DefaultValueScriptBlock $Command ;
                $RetrievalLocation = "source loaded into cache";
			}
			else{
                $RetrievalLocation = "cache";
			}
		}
		else {
            Write-Verbose "  -- Going to source for data";
			$InternalDataSet = &$Command;
			$RetrievalLocation = "source";
		}
        Write-Host "  -- $($InternalDataSet.Count) Rows Retrieved from $($RetrievalLocation).";
		return $InternalDataSet;
    }
    end
    {
        Write-Verbose "... $($MyInvocation.MyCommand) Ending"
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 3
        $FunctionDataSet = $DataSetToWriteJSon | ConvertFrom-Json;
		try {Write-TELLogFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $FunctionDataSet -JSonDepth 10;}
		catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        Write-Verbose "$($MyInvocation.MyCommand) Ended";
	}
}