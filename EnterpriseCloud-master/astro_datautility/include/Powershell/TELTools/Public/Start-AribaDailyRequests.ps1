function Start-AribaDailyRequests{
	[CmdletBinding()]
	param()
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
		$AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";
		$AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
		foreach ($CurrentRealm in ($AribaRuntimeConfigurationData.Realms.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
			foreach ($CurrentDocumentType in ($CurrentRealm.Value.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
				if(-not $CurrentDocumentType.Value.Active){continue;}
				[datetime]$StartDate = $CurrentDocumentType.Value.LastSuccessfulEndDate;
				[datetime]$EndDate = Get-Date -format "yyyy-MM-dd";
				$JobList = $CurrentDocumentType.Value.Jobs;
				foreach ($CurrentJob in ($JobList.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
					# if($CurrentJob.value.status -eq 'expired'){

					# }
					$DateField = $CurrentJob.value.filter.updatedDateTo;
					# $DateField = [datetime]::parseexact($CurrentJob.value.filter.updatedDateTo,"yyyy-MM-ddTHH:mm:ss",$null);
					if($DateField -gt $StartDate) {$StartDate = $DateField;}
				}
				$DaysBehind = New-TimeSpan -Start $StartDate -End $EndDate;
				if($DaysBehind.Days -eq 0){continue;}
				if($DaysBehind.Days -gt 7){
					$EndDate = $StartDate.AddDays(7);
				}
				if($DaysBehind.Days -gt 30){
					$EndDate = $StartDate.AddDays(30);
				}
				$JobObject = @{};
				$FilterObject = @{};
				$FilterObject.Add("updatedDateFrom",$StartDate.ToString("yyyy-MM-ddTHH:mm:ss"));
				$FilterObject.Add("updatedDateTo"  ,$EndDate.ToString("yyyy-MM-ddTHH:mm:ss"));
				$JobObject.Add("filter"  ,$FilterObject);
				$JobObject.Add("Status"  ,"Requesting");
				$JobObject.Add("files"   ,@());
				$JobName = "JobName_$($CurrentDate.ToString("yyyyMMddHHmmss"))";
				Write-Host "Adding $($CurrentRealm.Name).$($CurrentDOcumentType.Name) -> $($StartDate) thru $($EndDate)"
				$AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs | Add-Member -MemberType NoteProperty -Name $JobName -Value $JobObject;
				$AribaRuntimeConfigurationData | ConvertTo-JSON -Depth 10 | Out-File $AribaRuntimeConfigurationDataSourceLocation -Encoding UTF8;
			}
		}
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