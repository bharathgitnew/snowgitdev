function Read-AribaRequestFilters {
    [cmdletbinding()]
    param(
		[parameter(Mandatory = $false,
        HelpMessage = "-Realm *****")]
		[string]$Realm,
		[parameter(Mandatory = $false,
        HelpMessage = "-DocumentType *****")]
		[string]$DocumentType
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
        Write-Host "Realm            : $($Realm)";
        Write-Host "DocumentType     : $($DocumentType)";

        # $AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";
        # $AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
		# $DocumentJobs = $AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType.Jobs;

        # foreach ($JobId in ($DocumentJobs.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
		# 	Write-Verbose "Calculating JobId = $($JobId.Name)";

		# 	switch ($JobObject.Value.Status)
		# 	{
		# 		pending    { $a=1  }
		# 		Inprogress { $a=1 }
		# 		completed  { $a=1 }
		# 		expired    { $a=1 }
		# 		default    { Throw "Unknown Status of Job id #$($JobId.Name) - Status $($JobObject.Value.Status)" }
		# 	}

		# }

		$ReturnObject = @{};

        $null = $ReturnObject.Add('updatedDateFrom','2021-01-25T00:00:01Z');
        $null = $ReturnObject.Add('updatedDateTo','2021-01-26T00:00:00Z');

		return $ReturnObject;
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
