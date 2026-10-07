function Write-TELDataSet {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-SourceName ****")]
        [string]$SourceName,

        [parameter(Mandatory = $false,
        HelpMessage = "-DataSetName ****")]
		[string]$DataSetName,

		[parameter(Mandatory = $false,
        HelpMessage = "-DataSet ****")]
        $DataSetData
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
#		$FolderLocation = Get-TELOutputDirectory  -SourceName $SourceName -DataSetName $DataSetName;
        $OutputInformation = Get-TELOutputInformation -SourceName $SourceName -DataSetName $DataSetName;
        $FolderLocation = $OutputInformation["Folder"];
		Write-Debug $FolderLocation
		Write-Verbose "... Testing Output folders existance";
		If(!(test-path $FolderLocation))
		{
			throw "Directory '$($FolderLocation)' is required to exist in oder to export data.  See DSC Configuration.";
		}

		Write-Verbose "... Write to File";
		if(!($DataSetData)) {
			Write-Verbose "No Data provided.  Trying Get-TELItem";
			$DataSetData = Get-TELItem -SourceName $SourceName -DataSetName $DataSetName;
        }
		if($DataSetData) {
#            try {
                $FileName = $OutputInformation["FileName"];
                $JsonDepth = $OutputInformation["JSonDepth"];
                $SplitRowCount = $OutputInformation["SplitRowCount"];
                $SplitRowScheme = $OutputInformation["SplitRowScheme"];
                Write-DataSetToFile -FileName $FileName -DataSet $DataSetData -JSonDepth $JsonDepth -SplitRowScheme $SplitRowScheme -SplitRowCount $SplitRowCount ;
            # }
            # catch {Write-Host " **** Write-DataSetToFile does not exist... No execution data will be saved." }
        }else {
            Write-Host 'No Data to Write.'
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