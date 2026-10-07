function Invoke-AribaJobSubmission{
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
        $StayInRealm = $true;
		foreach ($CurrentRealm in ($AribaRuntimeConfigurationData.Realms.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
            $StayInRealm = $true;
			foreach ($CurrentDocumentType in ($CurrentRealm.Value.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
                if(!$StayInRealm){break;}
                if(-not $CurrentDocumentType.Value.Active){continue;}
                $JobList = $CurrentDocumentType.Value.Jobs;
				foreach ($CurrentJob in ($JobList.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
                    if($CurrentJob.Value.status -ne 'Requesting') {continue;}
                    Write-Host "Requesting job $($CurrentRealm.Name).$($CurrentDocumentType.Name) ";
                    $ReturnObject = Submit-AribaJobRequest `
                                            -RealmName $CurrentRealm.Name `
                                            -ApplicationKey $MasterRealmList.$($CurrentRealm.Name).ApplicationKey `
                                            -ViewName $MasterRealmList.$($CurrentRealm.Name).DataSets.$($CurrentDocumentType.Name).ViewName `
                                            -Filters $CurrentJob.Value.Filter;
                    #Write-Host $ReturnObject;
                    if($ReturnObject.Code){
                        Write-Host "$($CurrentRealm.Name).$($CurrentDocumentType.Name) got a '$($ReturnObject.Message)' error." -ForegroundColor Red;
                        $StayInRealm = $false;
                        break;
                    }
                    Write-Host " --- $($ReturnObject.jobId) Queued";
                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs | Add-Member -MemberType NoteProperty -Name $ReturnObject.jobId -Value $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($CurrentJob.Name);

                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($ReturnObject.jobId).status  = $ReturnObject.status;
#                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($ReturnObject.jobId) | Add-Member -MemberType NoteProperty -Name 'CreatedDatetime' -Value $ReturnObject.createdDate.Replace('Z','');
                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($ReturnObject.jobId) | Add-Member -MemberType NoteProperty -Name 'CreatedDatetime' -Value $ReturnObject.createdDate;
                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.$($ReturnObject.jobId) | Add-Member -MemberType NoteProperty -Name 'viewTemplateName' -Value $ReturnObject.viewTemplateName;

                    $AribaRuntimeConfigurationData.Realms.$($CurrentRealm.Name).$($CurrentDocumentType.Name).Jobs.PSObject.Properties.Remove($CurrentJob.Name);

                    $AribaRuntimeConfigurationData | ConvertTo-JSON -Depth 10 | Out-File $AribaRuntimeConfigurationDataSourceLocation -Encoding UTF8;
                    Start-Sleep -Seconds 2;
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