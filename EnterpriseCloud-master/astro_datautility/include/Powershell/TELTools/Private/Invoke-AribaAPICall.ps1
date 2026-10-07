function Invoke-AribaCall {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-Method *****")]
		[string]$Method,
        [parameter(Mandatory = $false,
        HelpMessage = "-BaseURL *****")]
		[string]$BaseURL,
		[parameter(Mandatory = $false,
        HelpMessage = "-RequestParameters *****")]
		[hashtable]$RequestParameters,
        [parameter(Mandatory = $false,
        HelpMessage = "-RequestHeaders *****")]
		[hashtable]$RequestHeaders,
        [parameter(Mandatory = $false,
        HelpMessage = "-RequestBody *****")]
		[hashtable]$RequestBody,
        [parameter(Mandatory = $false,
        HelpMessage = "-ResponseFile *****")]
		[string]$ResponseFile
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
        Write-Host "Method            : $($Method)";
        Write-Host "BaseURL           : $($BaseURL)";
        Write-Host "APICallName       : $($APICallName)";
        Write-Host "RequestParameters : $($RequestParameters)";
        Write-Host "RequestHeaders    : $($RequestHeaders)";
		Write-Host "RequestBody       : $($RequestBody)";
		Write-Host "ResponseFile      : $($ResponseFile)";

		$URLParameters = '';
		foreach ($RequestParameter in $RequestParameters.GetEnumerator()) {
			Write-Host $RequestParameter.Name;
			if($URLParameters.Length -eq 0) { $URLParameters += "?"; }else{ $URLParameters += "&"; }
			$URLParameters += "$($RequestParameter.Name)=$($RequestParameter.Value)";
		}
        $BuiltURL = "$($BaseURL)$($URLParameters)";

        $ContentType = 'application/json';

		$BuiltBody = $RequestBody | ConvertTo-Json;

        $InvokeString = "Invoke-RestMethod -Method `$Method -ContentType `$ContentType  -Uri `$BuiltURL -Headers `$RequestHeaders";
        if($RequestBody.Count -ne 0){
			$InvokeString += " -Body `$BuiltBody";
        }
        if($ResponseFile -ne ""){
#            $ContentType = 'application/zip';
            $InvokeString += " -OutFile `$ResponseFile";
        }

        Write-Host $InvokeString;
        $ResultObject = Invoke-Expression -Command $InvokeString;

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
