function Get-TELKeyVaultKey {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-SourceName ****")]
		[string]$SourceName,

        [parameter(Mandatory = $false,
        HelpMessage = "-DataSetName ****")]
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
        Write-Verbose "... Get Password";
        [secureString]$SecurePassword = $null;
        $SourcePassword = $script:ConfigurationData.$SourceName.Securables.Password;
        $DataSetPassword = $script:ConfigurationData.$SourceName.DataSets.$DataSetName.Securables.Password;
        $SourcePasswordName = $script:ConfigurationData.$SourceName.Securables.PasswordName;
        $DataSetPasswordName = $script:ConfigurationData.$SourceName.DataSets.$DataSetName.Securables.PasswordName;
        Write-Verbose "SourcePassword = $($SourcePassword)";
        Write-Verbose "DataSetPassword = $($DataSetPassword)";
        Write-Verbose "SourcePasswordName = $($SourcePasswordName)";
        Write-Verbose "DataSetPasswordName = $($DataSetPasswordName)";
        Write-Verbose "... Test Password";
        if($SourcePasswordName){
            $SecurePassword = Get-AzureKeyVaultKey -KeyName $SourcePasswordName
        }elseif ($DataSetPasswordName) {
            $SecurePassword = Get-AzureKeyVaultKey -KeyName $DataSetPasswordName;
        }elseif ($SourcePassword) {
            throw "Use Key Vault For PasswordName."
            #$SecurePassword = ConvertTo-SecureString $SourcePassword -AsPlainText -Force;
        }elseif ($DataSetPassword) {
            throw "Use Key Vault For PasswordName."
            #$SecurePassword = ConvertTo-SecureString $DataSetPassword -AsPlainText -Force;
        }else {
            throw "No PasswordName Found."
        }
        return $SecurePassword;
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