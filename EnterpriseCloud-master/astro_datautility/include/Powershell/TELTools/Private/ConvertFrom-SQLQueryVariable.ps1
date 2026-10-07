function ConvertFrom-SQLQueryVariable {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "DataSet Configuration")]
		$DataSetConfiguration,

        [parameter(Mandatory = $false,
        HelpMessage = "DataSet Configuration")]
		$DataSetName,

        [parameter(Mandatory = $false,
        HelpMessage = "Parameter Value")]
		$ParameterValue
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
		Write-Verbose "... Initialize Function";
        if($DataSetConfiguration.RuntimeConfiguration){
            Write-Verbose('Fetch Last Entry');
            $RuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\$($DataSetName).json";
            $RuntimeConfigurationExists = Test-Path $RuntimeConfigurationDataSourceLocation -PathType Leaf;
            if($RuntimeConfigurationExists) {
                $RuntimeConfigurationData = Get-Content -Path $RuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
            } else {
                $RuntimeConfigurationData =  @{};
            }
            If(!$($RuntimeConfigurationData.LastRowData))
            {
                switch ($DataSetConfiguration.RuntimeConfiguration.ConfigurationType){
                    "DateTimeUTC" { $RuntimeConfigurationData['LastRowData'] = "01/01/1900 00:00:00" }
                    "DateUTC" { $RuntimeConfigurationData['LastRowData'] = "01/01/1900" }
                    "DateTimeCST" { $RuntimeConfigurationData['LastRowData'] = "01/01/1900 00:00:00" }
                    "DateCST" { $RuntimeConfigurationData['LastRowData'] = "01/01/1900" }
                }

                #$RuntimeEntryValue = New-Object -TypeName PSCustomObject;

                # switch ($DataSetConfiguration.RuntimeConfiguration.ConfigurationType){
                #     "DateTimeCST" { $RuntimeEntryValue | Add-Member -Type NoteProperty -Name "LastRowData" -Value "01/01/1900 00:00:00" }
                #     "DateCST" { $RuntimeEntryValue | Add-Member -Type NoteProperty -Name "LastRowData" -Value "01/01/1900" }
                # }
                #$RuntimeConfigurationData | Add-Member -Type NoteProperty -Name 'LastRowData' -Value $RuntimeEntryValue;
            }

            $InternalLastRowData = $RuntimeConfigurationData.LastRowData;
            $ReturnObject =  $ParameterValue -replace '<<LastRowData>>', $InternalLastRowData;
            switch ($DataSetConfiguration.RuntimeConfiguration.ConfigurationType){
                "DateTimeUTC" { $RuntimeConfigurationData.LastRowData = (Get-Date).ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss"); }
                "DateUTC" { $RuntimeConfigurationData.LastRowData = (Get-Date).ToUniversalTime().ToString("MM/dd/yyyy"); }
                "DateTimeCST" { $RuntimeConfigurationData.LastRowData = Get-Date -Format "MM/dd/yyyy HH:mm:ss"; }
                "DateCST" { $RuntimeConfigurationData.LastRowData = Get-Date -Format "MM/dd/yyyy"; }
            }
            Write-Verbose("Write Last Entry");
            $RuntimeConfigurationData | ConvertTo-Json -depth 2 | Out-File $RuntimeConfigurationDataSourceLocation;

        }else{
            $ReturnObject = $ParameterValue;
        }
        Write-Verbose($ReturnObject);
		return $ReturnObject;
    }
    end
    {
        Write-Verbose "... $($MyInvocation.MyCommand) Ending"
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 3
        $FunctionDataSet = $DataSetToWriteJSon | ConvertFrom-Json;
		try {Write-TELLogFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $FunctionDataSet -JSonDepth 10;}
		catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        Write-Verbose "$($MyInvocation.MyCommand) Ended";
    }
}