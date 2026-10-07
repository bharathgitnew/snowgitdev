function Request-AribaJobFiles{
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

        $MasterRealmList = $script:ConfigurationData.Ariba.Realms;


		$AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";
		$AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
		foreach ($CurrentRealm in ($AribaRuntimeConfigurationData.Realms.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
			foreach ($CurrentDocumentType in ($CurrentRealm.Value.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
                if(-not $CurrentDocumentType.Value.Active){continue;}
                $JobList = $CurrentDocumentType.Value.Jobs;
				foreach ($CurrentJob in ($JobList.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
                    if($CurrentJob.Value.status -ne "FilesReady") {continue;}
					$null = Receive-AribaFiles `
                                        -RealmName $CurrentRealm.Name `
										-DocumentType $CurrentDocumentType.Name `
                                        -ApplicationKey $MasterRealmList.$($CurrentRealm.Name).ApplicationKey `
                                        -AribaJobId $CurrentJob.Name `
                                        -files $CurrentJob.Value.files;

                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name).status  = "completed";
                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name) | Add-Member -MemberType NoteProperty -Name 'ProcessedDatetime' -Value $(Get-Date -format "yyyy-MM-ddTHH:mm:ss");
                    $AribaRuntimeConfigurationData | ConvertTo-JSON -Depth 10 | Out-File $AribaRuntimeConfigurationDataSourceLocation -Encoding UTF8;
                }
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