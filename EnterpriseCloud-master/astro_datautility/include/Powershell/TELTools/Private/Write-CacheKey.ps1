function Write-CacheKey {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Key,

        [Parameter(Mandatory = $false)]
        $Value,

        [Parameter(Mandatory = $false)]
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
        if($null -eq $Value -and $null -ne $DefaultValueScriptBlock){
            $Value = &$DefaultValueScriptBlock;
        }
        if($null -eq $Value) {
            return;
        }
        $cache = Get-Variable -Name $script:CacheVariableName -Scope Global;
        $cache.Value[$Key] = $Value;
        Write-Host "  -- Key ($Key) data added to cache";
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