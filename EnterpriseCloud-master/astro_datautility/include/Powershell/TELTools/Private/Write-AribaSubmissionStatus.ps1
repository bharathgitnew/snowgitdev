function Write-AribaSubmissionStatus {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-RealmName ****")]
        [string]$RealmName,
		[parameter(Mandatory = $false,
        HelpMessage = "-DocumentType *****")]
        [string]$DocumentType,
        [parameter(Mandatory = $false,
        HelpMessage = "-Filters *****")]
        [hashtable]$StatusObject
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
        # $JobOject = ${};
        # $JobObject.Add("Status",$StatusObject.status);
        # foreach ($CurrentFile in $StatusObject.Files.GetEnumerator()) {
        #     $JobObject.Add($CurrentFile,$CurrentFile);
        # }
        # foreach ($Filter in $StatusObject.Filters.GetEnumerator()) {
        #     $JobObject.Add($Filter.Name,$Filter.Value);
        # }



        # $AribaRuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\Ariba.config";



        # $AribaRuntimeConfigurationExists = Test-Path $AribaRuntimeConfigurationDataSourceLocation -PathType Leaf;
        # if($AribaRuntimeConfigurationExists) {
        #     $AribaRuntimeConfigurationData = Get-Content -Path $AribaRuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
        # } else {
        #     $AribaRuntimeConfigurationData =  ("{""Realms"":{}}") | ConvertFrom-Json;
        # }
        # if(!$AribaRuntimeConfigurationData.Realms.$Realm){
        #     $AribaRuntimeConfigurationData.Realms | Add-Member -MemberType NoteProperty -Name $Realm -Value ([PSCustomObject]@{});
        # }
        # if(!$AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType){
        #     $AribaRuntimeConfigurationData.Realms.$Realm | Add-Member -MemberType NoteProperty -Name $DocumentType -Value ([PSCustomObject]@{});
        #     $AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType | Add-Member -MemberType NoteProperty -Name Jobs -Value ([PSCustomObject]@{});
        # }
        # $JobObject = $AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType.Jobs.$JobId;
        # if(!$JobObject){
        #     $AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType.Jobs | Add-Member -MemberType NoteProperty -Name $JobId -Value ([PSCustomObject]@{});
        #     $JobObject = @{};
        #     $JobObject.Add("Status",$Status);
        #     foreach ($Filter in $Filters.GetEnumerator()) {
        #         $JobObject.Add($Filter.Name,$Filter.Value);
        #     }
        # }else{
        #     $JobObject.Status = $Status;
        #     foreach ($Filter in $Filters.GetEnumerator()) {
        #         if($JobObject.$($Filter.Name)){
        #             $JobObject.$($Filter.Name) = $Filter.Value;
        #         }else {
        #             $JobObject.Add($Filter.Name,$Filter.Value);
        #         }
        #     }
        # }
        # $AribaRuntimeConfigurationData.Realms.$Realm.$DocumentType.Jobs.$JobId = $JobObject;

        # $null = Write-DataSetToFile -FileName $AribaRuntimeConfigurationDataSourceLocation -DataSet $AribaRuntimeConfigurationData -JSonDepth 20;
		return;
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
