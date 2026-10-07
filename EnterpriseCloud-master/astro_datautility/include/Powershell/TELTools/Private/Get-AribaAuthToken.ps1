function Get-AribaAuthToken {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-Realm *****")]
		[string]$Realm
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
		Write-Verbose "... Get Token from Ariba System";
        Write-Verbose "... ... Value of Realm : $($Realm)";

		$OAuthURL = $script:ConfigurationData.Ariba.OAuthURL;
		$RequestParameters = '';
		$RequestHeaders = @{};
		$RequestBody = @{};

		Write-Verbose "... ... Assigning Headers";
		$RequestHeaders.Add('Authorization',"Basic $($script:ConfigurationData.Ariba.Realms.$Realm.Base64Encoded)")
		Write-Verbose "... ... Assigning Body";
        $RequestBody.Add('grant_type','openapi_2lo');

		Write-Verbose "... ... Executing Call";
        $ResultObject = Invoke-TELRestMethod -Method POST -RestURL $OAuthURL -ContentType "application/x-www-form-urlencoded" -HeaderHash $RequestHeaders -BodyHash $RequestBody;
#        $result = Invoke-RestMethod -Method Post -ContentType application/x-www-form-urlencoded -Uri $OAuthURL -Headers $RequestHeaders -Body $RequestBody
		Write-Verbose "... ... Interpreting Results";
        $AccessToken = $ResultObject.access_token
        Write-Verbose "... ... AccessToken - $AccessToken"
        return $AccessToken;
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
