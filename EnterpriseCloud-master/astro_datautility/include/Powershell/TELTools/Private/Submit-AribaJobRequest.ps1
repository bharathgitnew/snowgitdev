function Submit-AribaJobRequest{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-RealmName ****")]
		[string]$RealmName,

        [parameter(Mandatory = $false,
        HelpMessage = "-ApplicationKey ****")]
		[string]$ApplicationKey,

        [parameter(Mandatory = $false,
        HelpMessage = "-ViewName ****")]
		[string]$ViewName,

        [parameter(Mandatory = $false,
        HelpMessage = "-Filters ****")]
		$Filters
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

        $BaseURL = $script:ConfigurationData.Ariba.CreateJobURL;
        $CallMethod = 'POST';
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
        $RequestBody.Add('viewTemplateName',$ViewName);
        $RequestBody.Add('filters',"");
        Write-Verbose "... ... ... Filter";

#       Ariba Rate Limits (Per Realm) : 1/second, 2/minute, 8/hour, 40/day
        $RequestBodyFilters = @{};
        foreach ($Currentfilter in ($Filters.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
            Write-Verbose("... ... ... ... CurrentFilter  : $($CurrentFilter)")
            if($CurrentFilter.TypeNameOfValue -eq "System.DateTime") {
                $StringDate = $CurrentFilter.Value.ToString("yyyy-MM-ddT00:00:00Z");
            } else {
                $StringDate = "$($CurrentFilter.Value)Z";
            }
            Write-Verbose("... ... ... ... Created String : $($StringDate)")

            $RequestBodyFilters.Add($CurrentFilter.Name,$StringDate);
        }
        $RequestBody.filters = $RequestBodyFilters;
        $AccessToken = Get-AribaAuthToken -Realm $RealmName;
        $RequestHeaders.Authorization = "Bearer $($AccessToken)";

            $ResultObject = Invoke-TELRestMethod -Method $CallMethod -RestURL $BaseURL -ContentType $ContentType -ParameterHash $RequestParameters -HeaderHash $RequestHeaders -BodyHash $RequestBody -BodyAsJSon;
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
        Write-Verbose "... $($MyInvocation.MyCommand) Ended";
	}
}