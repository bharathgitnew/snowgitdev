function ConvertFrom-SharepointResultSet {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-DataSet ****")]
		$DataSet
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
		$ReturnObject = @();
		foreach($ChildList in $DataSet){
			$CurrentList = @{};
            $CurrentList["List"] = $ChildList["List"];
            $CurrentData = @{};
            foreach($ChildData in $ChildList["Data"]){
                $CurrentRow = @{};
			    foreach($Key in $ChildData.FieldValues.Keys){
			    	$CurrentRow[$Key] = $ChildData.FieldValues[$Key];
                }
                $CurrentData[$ChildData.Id.ToString()] = $CurrentRow;
            }
            $CurrentList["Data"] = $CurrentData;

			$ReturnObject += $CurrentList;
		}
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