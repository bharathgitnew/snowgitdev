function Get-DataSetParameterList {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-DataSet *****")]
		$DataSetConfiguration
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
        $RequiredDataSet =  $DataSetConfiguration.RequiredDataSet;
        if(!($RequiredDataSet)){
            $FinalParameters = $DataSetConfiguration.Parameters;
        }else{
            $InternalParameters = @();
            [boolean]$AddDataPoint = $false;

            Write-Host "---------- Executing Required DataSet -------------------------------------"
            $RetrievedData = Get-TELItem -SourceName $RequiredDataSet.SourceSystem -DataSetName $RequiredDataSet.DataSetName;
            $RequiredDataSetFieldName = $RequiredDataSet.DataSetValueField;
            $RecordCounter = $RetrievedData.Count;
            Write-Host "---------- Executing Required DataSet -------------------------------------"
            $DataPointValueName = $RequiredDataSet.ParameterValueName;
            foreach($DataPoint IN $RetrievedData){
                $RecordCounter -=1;
#               Write-Host "`r$($RecordCounter)" -NoNewLine ;
            #    if(!($DataPoint.DisplayName.StartsWith("SF_"))) {continue;}
                $AddDataPoint = !($RequiredDataSet.LimitationSet);  #False: Limitations on DataSet -- True: No Limits
                if(!($AddDataPoint)) {    # If there ARE limitations
                    foreach($Limitation IN $RequiredDataSet.LimitationSet){
                        $LimitationField = "$($Limitation.LimitField)".Trim();
                        $LimitationValue = "$($Limitation.StartsWithValue)".Trim();
                        if($Limitation.StartsWithValue) {
                            $AddDataPoint = $AddDataPoint -or $DataPoint.$LimitationField.StartsWith($LimitationValue);
                        }
                    }
                }
                if($AddDataPoint){
                    $InternalParameters += [PSCustomObject]@{$DataPointValueName = "$($DataPoint.$RequiredDataSetFieldName)"};
                }
            }
            Write-Host "Row filtering Complete."
            $FinalParameters = $InternalParameters;
        }
        Write-Host $FinalParameters;
        #return $null;
        return ,$FinalParameters;
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
}