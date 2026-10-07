function Get-TELCredential {
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
		Write-Verbose "... Initialize Function";
		[PSCredential]$ReturnValue = $null;

        Write-Verbose "... Get Username";
        $SourceUsername = $script:ConfigurationData.$SourceName.Securables.UserName;
        $DataSetUsername = $script:ConfigurationData.$SourceName.DataSets.$DataSetName.Securables.UserName;
        Write-Debug "SourceUserName = $($SourceUserName)";
        Write-Debug "DataSetUsername = $($DataSetUsername)";
        Write-Verbose "... Test Username";
        if($SourceUsername){
            $SecureUserName = $SourceUsername;
        }elseif ($DataSetUserName) {
            $SecureUserName = $DataSetUserName;
        }else {
            Write-Verbose "    -- Can Not find Username";
			return $ReturnValue;
        }

        Write-Verbose "... Get Password";
        $SecurePassword = Get-TELKeyVaultKey -SourceName $SourceName -DataSetName $DataSetName;

        Write-Debug "SecureUserName = $($SecureUserName)";
        Write-Debug "SecurePassword = **********";
		$FunctionStatisticsDataSet.Add('SecureUserName',$SecureUserName);
        $FunctionStatisticsDataSet.Add('SecurePassword',"********");

		Write-Verbose "... Create Credential";
		$ReturnValue = New-Object System.Management.Automation.PSCredential ($SecureUserName, $SecurePassword);

		$FunctionStatisticsDataSet.Add('CredentialCreated',$true);
		return $ReturnValue;
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
        Creates a TEL Credential for the source/dataset combination.

        .DESCRIPTION
        Creates a TEL Credential for the source/dataset combination.  Retrieves Username and Password.  The Credential is created from the combination and returned.

        .PARAMETER SourceName
        Specifies the source system name.

		.PARAMETER DataSetName
        Specifies the dataset name.

        .INPUTS
        None. You cannot pipe objects to this Set-TELCredential.

        .OUTPUTS
		PSCredential. Get-TELCredential returns a credential based on retrieved Username and Password.

        .EXAMPLE
        C:\PS> $TELCredential = Get-TELCredential -SourceName "<<SourceName>>" -DataSetName "<<DataSetName>>"
		<<Credential>>

        .LINK
        TEL Modified Version of Online version: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential

        .LINK
        Write-DataSetToFile
    #>
}