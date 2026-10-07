function Set-AribaLastCompleted{
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
        $AribaFolder = $script:MachineConfiguration.RootFileDirectory+$script:ConfigurationData.Ariba.FileDirectoryExtension;


		$AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";
		$AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
		foreach ($CurrentRealm in ($AribaRuntimeConfigurationData.Realms.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
			foreach ($CurrentDocumentType in ($CurrentRealm.Value.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
                if(-not $CurrentDocumentType.Value.Active){continue;}
                $JobList = $CurrentDocumentType.Value.Jobs;
                $CurrentLastDate = $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).LastSuccessfulEndDate;
                $WhileLoopContinueIndicator = $true;
				while($WhileLoopContinueIndicator){
                    $WhileLoopContinueIndicator = $false;
					foreach ($CurrentJob in ($JobList.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
						if($CurrentJob.value.filter.updatedDateFrom -eq $CurrentLastDate) {
                            if($CurrentJob.value.status -eq 'expired' ) {continue;}
                            if($CurrentJob.value.status -eq 'completed' ){
                                $CurrentLastDate = $CurrentJob.value.filter.updatedDateTo;
                                $CurrentJob | ConvertTo-JSON -Depth 10 | Out-File "$($AribaFolder)AuditLog.$($CurrentRealm.Name).$($CurrentDocumentType.Name).$($CurrentJob.Name).json" -Encoding UTF8;
                                $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.PSObject.properties.remove($CurrentJob.Name);
                                $WhileLoopContinueIndicator = $true;
                            }
                            break;
                        }
                    }
                }
                if($AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).LastSuccessfulEndDate -ne $CurrentLastDate){
                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).LastSuccessfulEndDate = $CurrentLastDate;
                }
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