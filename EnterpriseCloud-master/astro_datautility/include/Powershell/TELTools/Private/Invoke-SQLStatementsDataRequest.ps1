function Invoke-SQLStatementsDataRequest{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true,
        HelpMessage = "-DataSetName is required")]
        [string]$DataSetName
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
        Write-Verbose "   *** Tokyo Electron SQLStatements Loading...";
		Write-Debug "       -- Initializing SQLStatements Folder Location";
		$FolderLocation = $script:MachineConfiguration.RootFileDirectory+ `
						  $script:ConfigurationData.SQLStatements.FileDirectoryExtension;
		If(!(test-path $FolderLocation))
		{
			throw "Directory '$($FolderLocation)' is required to exist.  See DSC Configuration.";
		}

		$FullDataSet = $null
		$DataSetOptions = $script:ConfigurationData.SQLStatements.DataSets.$DataSetName;
		$CacheKey = "SQLStatements.$($DataSetName)";

		Write-Host "  ** Working with $($DataSetName)"

		$fetchInformationSQLStatement = $DataSetOptions.SQLStatement;
		foreach($Parameter in $DataSetOptions.ParameterSets)
		{
			$fetchInformationSQLStatement = $fetchInformationSQLStatement -replace $Parameter.Name, $Parameter.Value;
		}

        # Credentials
        if($DataSetOptions.AuthenticationType -eq "SQLServer"){
            $SourceUserName = $DataSetOptions.UserName;
            $SourcePassword = Get-TELKeyVaultKey -SourceName 'SQLStatements' -DataSetName $DataSetName;
            $SQLServerCredential = New-Object System.Management.Automation.PSCredential ($SourceUserName, $SourcePassword);
            $FullDataSet = Invoke-Sqlcmd -Query $fetchInformationSQLStatement -ServerInstance $DataSetOptions.Server -Database $DataSetOptions.Database -Credential $SQLServerCredential;
        }
        else {
            $FullDataSet = Invoke-Sqlcmd -Query $fetchInformationSQLStatement -ServerInstance $DataSetOptions.Server -Database $DataSetOptions.Database;
        }

		return $FullDataSet;
    }
    end
    {
        Write-Verbose "Beginning of End"
        $CurrentDate = Get-Date;
        $FunctionStatisticsDataSet.Add('EndTime',$CurrentDate);
        $DataSetToWriteJSon = $FunctionStatisticsDataSet | ConvertTo-Json -Depth 3
        $DataSet = $DataSetToWriteJSon | ConvertFrom-Json;
        Write-DataSetToFile -FileName "$($script:MachineConfiguration.ExecutionLogFileDirectory)$($FunctionStatisticsFileName)" -DataSet $DataSet -JSonDepth 10;
        Write-Verbose "... $($MyInvocation.MyCommand) Ending";
    }
}