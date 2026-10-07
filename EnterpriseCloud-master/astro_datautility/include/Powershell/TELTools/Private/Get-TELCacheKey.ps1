function Get-TELCacheKey{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-SourceName ****")]
		[string]$SourceName,

        [parameter(Mandatory = $false,
        HelpMessage = "-DataSetName ****")]
		[string]$DataSetName,

        [parameter(Mandatory = $false,
        HelpMessage = "-CacheDataSet ****")]
		[string]$UseCache
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
		Write-Verbose "... Initialize Function";
        Write-Debug "Value of SourceName : $($SourceName)";
        Write-Debug "Value of DataSetName : $($DataSetName)";
        Write-Debug "Value of UseCache : $($UseCache)";
		[string]$ReturnValue = $null;
        [bool]$UseCacheDecision = ($UseCache -eq "Yes");
        Write-Debug "Value of UseCacheDecision : $($UseCacheDecision)";

        Write-Verbose "... Calculate Key";
        if($UseCacheDecision){
            Write-Debug "Calculating Key";
            $ReturnValue = "$($SourceName).$($DataSetName)";
            Write-Debug "Calculated as $($ReturnValue)";
        }

        Write-Debug "Statistics: UseCache = $($UseCacheDecision)";
        Write-Debug "Statistics: CacheKey = $($ReturnValue)";
        $FunctionStatisticsDataSet.Add('UseCache',$UseCacheDecision);
        $FunctionStatisticsDataSet.Add('CacheKey',$ReturnValue);

        Write-Verbose "... Returning Key $($ReturnValue)";
		return $ReturnValue;
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
	<#
        .SYNOPSIS
        Creates a TEL CacheKey for the source/dataset combination.

        .DESCRIPTION
        Creates a TEL CacheKey for the source/dataset combination.  The CacheKey is created from the combination and returned.

        .PARAMETER SourceName
        Specifies the source system name.

		.PARAMETER DataSetName
        Specifies the dataset name.

		.PARAMETER UseCache
        Specifies If DataSet should be Cached or not.  Values "Yes" and "No".

        .INPUTS
        None. You cannot pipe objects to this Set-TELCacheKey.

        .OUTPUTS
		PSCredential. Set-TELCacheKey returns a string based on source/dataset combination.

        .EXAMPLE
        C:\PS> Set-TELCacheKey -SourceName "<<SourceName>>" -DataSetName "<<DataSetName>>" -UseCache "<<UseCache>>"
		"<<SourceName>>.<<DataSetName>>"

        .LINK
        Write-DataSetToFile
    #>
}