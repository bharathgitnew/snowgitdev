function New-FileIngestionDrive
{
    Param(
        [Parameter(Mandatory = $true,
        HelpMessage = "-DriveName is required.")]
        [string]$DriveName
        ,
        [Parameter(Mandatory = $true,
        HelpMessage = "-SourceLocation is required.")]
        [string]$SourceLocation
        ,
        [Parameter(Mandatory = $false,
        HelpMessage = "-UserName is required.")]
        [string]$UserName
        ,
        [Parameter(Mandatory = $false,
        HelpMessage = "-Password is required.")]
        [SecureString]$Password
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
		Write-Verbose "Checking Drive Type";
		# if(!(Test-Path $sourceLocation)){
		# 	Write-Verbose '... Location Not found.'
		# 	throw "Source Location ($($sourceLocation)) is not found.";
		# }
		IF (Test-Path ($DriveName+":"))
		{
			$FunctionStatisticsDataSet.Add('Status',"Path Already Exists");
			Write-Verbose "... Path Already Exists";
		}
		elseif($UserName)
		{
			$FunctionStatisticsDataSet.Add('Status',"Creating Drive with Crednetials");
			Write-Verbose "... Creating Drive with Crednetials";
			$cred = New-Object System.Management.Automation.PSCredential ($UserName, $Password)
			New-PSDrive -Name $DriveName -PSProvider "FileSystem" -Root $sourceLocation -Credential $cred  -Scope Global
		}
		elseif($true)
		{
			$FunctionStatisticsDataSet.Add('Status',"Creating Drive");
			Write-Verbose "... Creating Drive without Crednetials";
			New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $sourceLocation -Scope Global
		}
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