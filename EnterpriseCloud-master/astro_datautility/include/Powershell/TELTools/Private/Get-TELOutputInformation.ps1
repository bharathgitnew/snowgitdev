function Get-TELOutputInformation
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true)] [String]$SourceName,
		[Parameter(Mandatory = $true)] [String]$DataSetName,
		[Parameter()]                  [String]$FileNameAddition
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
		$SourceConfiguration = $script:ConfigurationData.$SourceName;
		$DataSetConfiguration = $SourceConfiguration.DataSets.$DataSetName;

		$OutputFileName = "<<Root>><<DataSetLocation>><<FileName>><<FileNameExtension>>.<<ExecutionDate>>.<<Extension>>";
		$Folder = "<<Root>><<DataSetLocation>>";

		$Root = $script:MachineConfiguration.RootFileDirectory;
		Write-Verbose $Root
		$DataSetLocation = if ($SourceConfiguration.FileDirectoryExtension) { $SourceConfiguration.FileDirectoryExtension } else { $DataSetConfiguration.OutputFile.FileDirectoryExtension}
		$FileName = $DataSetConfiguration.OutputFile.FileName;
		$FileNameExtension = "";
		$ExecutionDate = Get-Date -Format FileDateTime;
		$Extension = $DataSetConfiguration.OutputFile.Format;

		$OutputFileName = $OutputFileName `
			-replace "<<Root>>",$Root `
			-replace "<<DataSetLocation>>",$DataSetLocation `
			-replace "<<FileName>>",$FileName `
			-replace "<<FileNameExtension>>",$FileNameExtension `
			-replace "<<ExecutionDate>>",$ExecutionDate `
			-replace "<<Extension>>",$Extension;
		Write-Verbose "    -- OutputFileName -> $($OutputFileName)";

		$Folder = $Folder `
			-replace "<<Root>>",$Root `
			-replace "<<DataSetLocation>>",$DataSetLocation
		Write-Verbose "    -- Folder -> $($Folder)";

		$JsonDepth = $DataSetConfiguration.OutputFile.JsonDepth;
		$SplitRowScheme = if ($DataSetConfiguration.OutputFile.SplitRowScheme) { $DataSetConfiguration.OutputFile.SplitRowScheme } else { 'None' };
		$SplitRowCount = if ($DataSetConfiguration.OutputFile.SplitRowCount) { $DataSetConfiguration.OutputFile.SplitRowCount } else { 0 };

		$ReturnValue = @{"Folder"=$Folder;"FileName"=$OutputFileName;"JSonDepth"=$JsonDepth;"SplitRowScheme"=$SplitRowScheme;"SplitRowCount"=$SplitRowCount}
		$FunctionStatisticsDataSet.Add('Folder',$ReturnValue["Folder"]);
		$FunctionStatisticsDataSet.Add('FileName',$ReturnValue["OutputFileName"]);
		$FunctionStatisticsDataSet.Add('JSonDepth',$ReturnValue["JSonDepth"]);
		$FunctionStatisticsDataSet.Add('SplitRowScheme',$ReturnValue["SplitRowScheme"]);
		$FunctionStatisticsDataSet.Add('SplitRowCount',$ReturnValue["SplitRowCount"]);
		return $ReturnValue;
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