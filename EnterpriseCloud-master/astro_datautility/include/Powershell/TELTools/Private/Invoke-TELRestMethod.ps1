function Invoke-TELRestMethod {
    [cmdletbinding()]
    param(
        	[parameter(Mandatory = $true, HelpMessage = "-Method *****   [Required]")]
			[ValidateSet("GET","POST")]
		[string]$Method,

        	[parameter(Mandatory = $true, HelpMessage = "-RestURL ***** [Required]")]
		[string]$RestURL,

			[parameter(Mandatory = $false, HelpMessage = "-ContentType ***** [Required]")]
			[ValidateSet("application/x-www-form-urlencoded","application/json","application/zip")]
		[string]$ContentType,

			[parameter(Mandatory = $false, HelpMessage = "-ParameterHash *****")]
		[hashtable]$ParameterHash,

        	[parameter(Mandatory = $false, HelpMessage = "-RequestHeaders *****")]
		[hashtable]$HeaderHash,

			[parameter(Mandatory = $false, HelpMessage = "-BodyHash *****")]
		[hashtable]$BodyHash,

			[parameter(Mandatory = $false, HelpMessage = "-BodyAsJson")]
		[switch]$BodyAsJson,

        	[parameter(Mandatory = $false, HelpMessage = "-ResponseFile *****")]
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
		Write-Verbose "... Adding Parameters to URL";
		$URLParameters = '';
		foreach($CurrentKey in $ParameterHash.Keys){
			if($URLParameters.Length -eq 0) { $URLParameters += "?"; }else{ $URLParameters += "&"; }
			$URLParameters += "$($CurrentKey)=$($ParameterHash.Item($CurrentKey))";
		}
		$CompleteURL = "$($RestURL)$($URLParameters)";

		Write-Verbose "... Building RestMethod Call";
		Write-Verbose "... ... Base ";
		$InvokeString = "Invoke-RestMethod -Method `$Method -ContentType `$ContentType  -Uri `$CompleteURL";

		Write-Verbose "... ... Header";
		if($HeaderHash.Keys.Count -ne 0){
			$InvokeString += " -Headers `$HeaderHash";
		}

		Write-Verbose "... ... Body";
		if($BodyHash.Keys.Count -ne 0){
			if($BodyAsJson -eq $true){
				$BodyValue = $BodyHash | ConvertTo-Json;
			}else {
				$BodyValue = $BodyHash;
			}
			$InvokeString += " -Body `$BodyValue";
		}

		Write-Verbose "... ... Output";
		if($ResponseFile -ne ""){
            $InvokeString += " -OutFile `$ResponseFile";
        }

		Write-Verbose "... Calling RestMethod";
		try{
			$ResultObject = Invoke-Expression -Command $InvokeString;
		}catch{
			$ExceptionDetail = $_
			switch($ExceptionDetail.Exception.Response.StatusCode.ToString()){
				429 {
					$ResultObject = [PSCustomObject]@{
											Code     = 429
											Message = 'API Rate Limit'
											Status = 'error'
									}
				}
				TooManyRequests {
					$ResultObject = [PSCustomObject]@{
											Code     = 429
											Message = 'API Rate Limit'
											Status = 'error'
									}
				}
				BadRequest {
					$ResultObject = [PSCustomObject]@{
											Code     = 400
											Message = $ExceptionDetail.ErrorDetails
											Status = 'error'
									}
				}
				NotFound {
					$ResultObject = [PSCustomObject]@{
										Code     = 404
										Message = 'View Template Not Found'
										Status = 'error'
									}
				}
				default {
					$ResultObject = [PSCustomObject]@{
												Code     = $ResultObject.Code
												Message = $ResultObject.Message
												Status = 'error'
										}
				}
			}
		}

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
