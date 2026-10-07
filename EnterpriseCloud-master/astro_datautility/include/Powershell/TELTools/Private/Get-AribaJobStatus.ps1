function Get-AribaJobStatus {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-RealmName ****")]
		[string]$RealmName,

        [parameter(Mandatory = $false,
        HelpMessage = "-ApplicationKey ****")]
		[string]$ApplicationKey,

        [parameter(Mandatory = $false,
        HelpMessage = "-AribaJobId ****")]
		[string]$AribaJobId
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

        $BaseURL = $script:ConfigurationData.Ariba.JobResultsURL;
		$JobURL = "$($BaseURL)/$($AribaJobId)"

        $CallMethod = 'GET';
        $ContentType = 'application/json';
		$RequestParameters = @{};
		$RequestHeaders = @{};
		$RequestBodyFilters = @{};
		$RequestBody = @{};

        Write-Verbose "... ... Assigning Parameters";
        $RequestParameters.Add('realm',$RealmName);
        Write-Verbose "... ... Assigning Headers";
        $RequestHeaders.Add('accept','application/json');
        $RequestHeaders.Add('Authorization','PlaceHolder');
		$RequestHeaders.Add('apiKey',$ApplicationKey);
        $RequestHeaders.Add('content-type','application/json');
        Write-Verbose "... ... Assigning Body";

#       Ariba Rate Limits (Per Realm) : 1/second, 2/minute, 8/hour, 40/day
        $AccessToken = Get-AribaAuthToken -Realm $RealmName;
        $RequestHeaders.Authorization = "Bearer $($AccessToken)";

        $ResultObject = Invoke-TELRestMethod -Method $CallMethod -RestURL $JobURL -ContentType $ContentType -ParameterHash $RequestParameters -HeaderHash $RequestHeaders;
        return $ResultObject;
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
        Write-Verbose "$($MyInvocation.MyCommand) Ended";
    }
}
