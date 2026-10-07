function Use-AribaJobStatus {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-RealmObject *****")]
		$RealmObject,

		[parameter(Mandatory = $false,
        HelpMessage = "-AribaStatusObject *****")]
		$StatusObject
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
        Write-Verbose "... ... Value of Realm : $($RealmObject)";
        Write-Verbose "... ... Value of JobId : $($StatusObject)";

		if($StatusObject.status -in ('pending','Inprogress') ) {
			Write-Host $StatusObject.status;
			return;
		}

		if($StatusObject.status -in ('completed') ) {
			Receive-AribaFiles -RealmObject $RealmObject -StatusObject $StatusObject;
		}

		if($StatusObject.status -in ('expired') ) {
			Write-Host "Write To Log File";
		}

		Write-Host "Remove Job from Active File";

		# switch($ReturnObject.status)
		# pending: return;
		# Inprogress: return;
		# completed: Deal With it, write row to log file, then drop it from the runtime file
		# expired: write row to log file, then drop it from the runtime file

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
