function Read-CacheKey {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Key,

        [Parameter(Mandatory = $false)]
        [ScriptBlock]
        $DefaultValueScriptBlock
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
    process {
        $KeyDateFormat = Get-Date -Format FileDate;
        $CacheKey = "$Key.$KeyDateFormat";

        $cache = Get-Variable -Name $script:CacheVariableName -Scope Global

        if (-not $cache.Value.ContainsKey($CacheKey)) {
            Remove-CacheKeySet -Key $Key;
            if($null -ne $DefaultValueScriptBlock){
                Write-CacheKey -Key $CacheKey -DefaultValueScript $DefaultValueScriptBlock;
            }
        } else {
            Write-Host "  -- Key ($Key) read from cache";
        }
        return $cache.Value[$CacheKey];
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
