function Get-AzureKeyVaultKey {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-KeyName *****")]
		[string]$KeyName
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
		Write-Verbose "... Get Password from Azure Key Vault"
        Write-Host "Secure Password from KeyVault" -ForegroundColor Blue;
		[void](Connect-AzureActiveDirectory);
		Write-Verbose "... ...Connected"
		$KeyVaultValue = Get-AzKeyVaultSecret -VaultName $script:ConfigurationData.AzActiveDirectory.VaultInformation.VaultName -Name $KeyName;
		Write-Verbose "... ...Returning"
        return $KeyVaultValue.SecretValue;
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
	<#
        .SYNOPSIS
        Returns a secure password from the configuration file for the source/dataset combination.

        .DESCRIPTION
        Reads a clear text password from the configuration file for the source/dataset combination.  Converts to a secure string. Returns the secure password string.

        .PARAMETER SourceName
        Specifies the source system name.

		.PARAMETER DataSetName
        Specifies the dataset name.

        .INPUTS
        None. You cannot pipe objects to this Get-TELKeyVaultKey.

        .OUTPUTS
		Secure String. Get-TELKeyVaultKey returns a secure string from a clear text configuration file.

        .EXAMPLE
        C:\PS> Get-TELKeyVaultKey -SourceName "<<SourceName>>" -DataSetName "<<DataSetName>>"
		<<Credential>>

        .LINK
        TEL Modified Version of Online version: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential

        .LINK
        Write-DataSetToFile
    #>
}