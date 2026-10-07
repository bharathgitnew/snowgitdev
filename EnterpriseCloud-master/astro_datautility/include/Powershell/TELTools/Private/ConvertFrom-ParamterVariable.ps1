function Connect-AzureActiveDirectory {
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
		Write-Verbose "Azure Connection : Connecting";
		$ConnectionConfiguration = $script:ConfigurationData.AzActiveDirectory.ConnectionInformation;
		$Thumbprint = (Get-ChildItem -Path $ConnectionConfiguration.CertPath | Where-Object {$_.Subject -match "CN=$($ConnectionConfiguration.CertSubject)"}).Thumbprint;
        [void](Connect-AzAccount -ApplicationId $($ConnectionConfiguration.ApplicationId) -Tenant $($ConnectionConfiguration.TenantId) -CertificateThumbprint $Thumbprint -Subscription $ConnectionConfiguration.SubscriptionId -ServicePrincipal);
		Write-Host "Azure Connection : Connected" -ForegroundColor Blue;
		Write-Verbose "Azure Connection : Connected";
		return $null;
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
    }
}
