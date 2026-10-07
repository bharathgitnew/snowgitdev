function Request-AribaJobsStatus{
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
                    if($CurrentJob.Value.status -ne 'pending') {continue;}
                    Write-Host "Checking on Job $($CurrentRealm.Name).$($CurrentDocumentType.Name).$($CurrentJob.Name)";
                    $ReturnObject = Get-AribaJobStatus `
                                            -RealmName $CurrentRealm.Name `
                                            -ApplicationKey $MasterRealmList.$($CurrentRealm.Name).ApplicationKey `
                                            -AribaJobId $CurrentJob.Name;
                    Write-Host "---- $($ReturnObject.status)" -foregroundColor cyan;
                    switch($ReturnObject.status) {
                        error {Write-Host "$($ReturnObject.Message) [$($ReturnObect.Code)]"; continue;}
                        pending {continue;}
                        Inprogress {continue;}
                        expired {
                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name).status  = "expired";
                            $_ = 'writefile';
                        }
                        completedZeroRecords {$_ = "completed"}
                        completed {
                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name).status  = "FilesReady";
                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name).files = $ReturnObject.files;

                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name) | Add-Member -MemberType NoteProperty -Name 'CompletedDatetime' -Value $ReturnObject.completedDate;
                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name) | Add-Member -MemberType NoteProperty -Name 'TotalNumberOfFiles' -Value $ReturnObject.totalNumOfFiles;
                            $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name) | Add-Member -MemberType NoteProperty -Name 'TotalNumberOfRecords' -Value $ReturnObject.totalNumOfRecords;
                            $_ = 'writefile';
                        }
                        writefile {
                            $AribaRuntimeConfigurationData | ConvertTo-JSON -Depth 10 | Out-File $AribaRuntimeConfigurationDataSourceLocation -Encoding UTF8;
                        }
                    }
                    Start-Sleep 0.5;
                }
            }
        }
        # $AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";
		# $AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
		# $APISet = $script:ConfigurationData.Ariba.DataSets;

		# # Rate Limit (Requests): 4/second, 20/minute, 200/hour, 1000/day

		# $RealmSet = $script:ConfigurationData.Ariba.Realms;
        # foreach ($CurrentRealm in ($RealmSet.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
        #     Write-Verbose "... ... Testing $($CurrentRealm.Name) [$($CurrentRealm.Value.RealmName)]) Execution";
        #     IF($($CurrentRealm.Value).Active){
        #         Write-Verbose "... ... ... Executing";
        #         foreach ($APICall in ($APISet.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
		# 			$DocumentJobs = $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Value.RealmName).$($APICall.Value.DocumentType).Jobs;
		# 			foreach ($JobId in ($DocumentJobs.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
		# 				$StatusObject = Get-AribaJobStatus -Realm $CurrentRealm -AribaJobId $JobId.Name;
		# 				Use-AribaJobStatus -Realm $CurrentRealm -StatusObject $StatusObject;

		# 			}
		# 		}

        #     }else{
        #         Write-Verbose "... ... ... Skipping";
        #     }
        # }

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