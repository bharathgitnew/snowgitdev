function Copy-TELItem {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true,
        HelpMessage = "-DataSetName is required")]
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
        #CHCP 65001
        $TemporaryLocation = Get-Location;
        $DataSetConfiguration = $script:ConfigurationData.FetchFiles.DataSets.$DataSetName;
        if($DataSetConfiguration.Status -ne "Active") {
            Write-Host "File to Fetch is not Active.";
            return;
        }
        Write-Host $script:ConfigurationData.FetchFiles.DataSets.$DataSetName.SourceLocation;

        Write-Host "Fetch Target Name"
		$TargetFolderLocation = $script:MachineConfiguration.RootFileDirectory+$DataSetConfiguration.FileDirectoryExtension;
		if(!(test-path $TargetFolderLocation))
		{
			throw "Directory '$($TargetFolderLocation)' is required to exist.  See DSC Configuration.";
		}
        Write-Host "  -- $($TargetFolderLocation)"

        $RuntimeConfigurationDataSourceLocation = $script:MachineConfiguration.RootFileDirectory+"TokyoElectron\Powershell\RuntimeConfig\\$($DataSetName).config";
        $RuntimeConfigurationExists = Test-Path $RuntimeConfigurationDataSourceLocation -PathType Leaf;
        if($RuntimeConfigurationExists) {
            $RuntimeConfigurationData = Get-Content -Path $RuntimeConfigurationDataSourceLocation | ConvertFrom-Json;
        } else {
            $RuntimeConfigurationData =  ("{""LastFileDate"":""01/01/1900""}") | ConvertFrom-Json;
        }
        $ItemLastFileDate = $RuntimeConfigurationData.LastFileDate;
        Write-Host "Date of Last File : $($ItemLastFileDate)"
        $HighestFileDate = $ItemLastFileDate;

        Write-Host "Post Process Check"
        $PostProcessing = $DataSetConfiguration.PostProcessing;
        if($PostProcessing){
            $NewDir = [System.Guid]::NewGuid();
            $PostProcessingDirectory = $script:MachineConfiguration.TemporaryFileDirectory+$NewDir;
            New-Item -type directory -Path $PostProcessingDirectory;
            $CopyToLocation = $PostProcessingDirectory;
        }
        else
        {
            $CopyToLocation = $TargetFolderLocation;
        }

        Write-Host "Setup Source"
        $SourceFolderLocation = $DataSetConfiguration.SourceLocation;
        if($DataSetConfiguration.Securables) {
            Write-Host "Securing";
            $SourceUserName = $DataSetConfiguration.Securables.UserName;
            $SourcePassword = Get-TELKeyVaultKey -SourceName "FetchFiles" -DataSetName $DataSetName;
        }else{
            Write-Host "Unsecured";
        }
        New-FileIngestionDrive -DriveName $DataSetName -SourceLocation $SourceFolderLocation -UserName $SourceUserName -Password $SourcePassword;

        #Create function to test mapped drive

        if(!(Test-Path $DataSetName":\")){
            throw "$($DataSetName) Drive was not created... aborting this feed."
        }
        Write-Host "Source [$($DataSetName)] Drive File Search";
        $FilesToProcess =  Get-ChildItem -Path $DataSetName":\" -Filter $DataSetConfiguration.FilePattern  | Where-Object {$_.LastWriteTime -gt $ItemLastFileDate}
        foreach ($Item in $FilesToProcess)
        {
            Write-Host $Item.PSPath
            Copy-Item -Path $item.PSPath -Destination $CopyToLocation -force #-WhatIf
            if($Item.LastWriteTime -gt $HighestFileDate) {
                $HighestFileDate = $Item.LastWriteTime;
            }
        }
        Write-Host "End Files ..."

        if($PostProcessing){
            Write-Host "Performing Post Processing";
            $FilesToProcess =  Get-ChildItem -Path $CopyToLocation;
            foreach ($Item in $FilesToProcess)
            {
                Write-Host "--- $($Item.PSPath)";
                if($Item.Name -like $PostProcessing.Parameters.NamePattern){
                    Write-Verbose "   --- Processing";
                    $NewFileLines = @();
                    switch ($PostProcessing.Type)
                    {
                        RowFieldRemoval {
                            Write-Verbose "      --- Field Removal";
                            $CounterField = 0;
                            $TextLines  = Get-Content $Item;
                            Write-Host $TextLines.Count;
                            foreach($TextLine in $TextLines) {
                                $CounterField += 1;Write-Host $CounterField;
                                #Write-Verbose '      --- Started Function';
                                $FixedLine = Remove-TextSection $TextLine -Seperator $PostProcessing.Parameters.Bounding -FirstOccurance $PostProcessing.Parameters.Starting -SecondOccurance $PostProcessing.Parameters.Ending;
                                #Write-Verbose '      --- Finished Function';
                                $NewFileLines += $FixedLine ;
                            }
                        }
                        default { Throw "Unknown SplitScheme of file ($SplitRowScheme)" }
                    }
                    $NewFileLines | Out-File $Item
                    Write-Host "   --- Finished";
                }
                else
                {
                    Write-Host "   --- ByPass Post Processing";
                }
                Copy-Item -Path $item.PSPath -Destination $TargetFolderLocation -force #-WhatIf
            }
            Remove-Item -LiteralPath $CopyToLocation -Force -Recurse;
        }

        if($HighestFileDate -gt $ItemLastFileDate)
        {
            Write-Host "Rewriting Config";
            $RuntimeConfigurationData.LastFileDate = $HighestFileDate;
            $RuntimeConfigurationData | ConvertTo-Json -depth 2 | Out-File $RuntimeConfigurationDataSourceLocation;
        }

        Set-Location $TemporaryLocation;
        if(Test-Path "$($DataSetName):"){
            Write-Host "Removing PSDrive $($DataSetName)"
            Remove-PSDrive -Name $DataSetName;
        }



        # $FeedInformationSQLTemplate = "SELECT [SourceLocation],[SourceUserName],[SourcePassword],[FeedPattern],[FeedGroupName],[FeedName],[RemoveFileFromSource],[LastFileReceived] FROM [API].[FetchFeedInformation] WHERE [FileFeedId] = <<FileFeedId>>"
        # $FeedSQLResult = $null

        # #Get feed Information
        # $FeedInformationSQLStatement = $FeedInformationSQLTemplate -replace "<<FileFeedId>>","$FileFeedId"
        # $FeedSQLResult = Invoke-DbaQuery -Query $FeedInformationSQLStatement -SQLInstance $ServerName -Database $DatabaseName

        # $ItemSourceLocation = $FeedSQLResult.ItemArray[0]
        # $ItemUserName = $FeedSQLResult.ItemArray[1]
        # $ItemPassword = ConvertTo-SecureString $FeedSQLResult.ItemArray[2] -AsPlainText -Force
        # $ItemPattern =  $FeedSQLResult.ItemArray[3]
        # $ItemGroupName = $FeedSQLResult.ItemArray[4]
        # $ItemFeedName = $FeedSQLResult.ItemArray[5]
        # $ItemFileRemove = $FeedSQLResult.ItemArray[6]
        # $ItemLastFileDate = $FeedSQLResult.ItemArray[7]

        # #Setup Mapping locations
        # $targetLocation =  $IngestionDirectory+"FileBase\"+$ItemGroupName+"\"+$ItemFeedName+"\"

        # #Create function to test mapped drive
        # New-FileIngestionDrive -DriveName $ItemFeedName -SourceLocation $ItemSourceLocation -UserName $ItemUserName -Password $ItemPassword

        # #Check drive mapping
        # #Start-Transcript -Path $targetLocation$ItemFeedName".log" -Append
        # Write-Host "-----------------------------------------------"
        # Write-Host "Server..."
        # Write-Host $ServerName
        # Write-Host "Database..."
        # Write-Host $DatabaseName
        # Write-Host "EnvironmentType..."
        # Write-Host $EnviornmentType
        # Write-Host "User..."
        # Write-Host $ItemUserName
        # Write-Host "Pass ..."
        # Write-Host $ItemPassword
        # Write-Host "Feed"
        # Write-Host " - Pattern ..."
        # Write-Host $ItemPattern
        # Write-Host " - Group Name ..."
        # Write-Host $ItemGroupName
        # Write-Host " - Folder ..."
        # Write-Host $ItemFeedName
        # Write-Host " - Remove File after Fetch?"
        # Write-Host $ItemFileRemove
        # Write-Host " - LastProcessedFileInformation"
        # Write-Host $ItemLastFileDate

        # Write-Host "Files ..."

        # $items =  Get-ChildItem -Path $ItemFeedName":\" -Filter $ItemPattern  | Where-Object {$_.LastWriteTime -gt $ItemLastFileDate}
        # foreach ($item in $items)
        # {
        #     Write-Host $item.PSPath
        #     Copy-Item -Path $item.PSPath -Destination $targetLocation -force #-WhatIf
        #     IF ($ItemFileRemove -eq "Yes" -and $EnviornmentType -eq 'Production')
        #     {
        #         Remove-Item $item.PSPath
        #         Write-Host '- Removing File'
        #     }
        #     else
        #     {
        #         Write-Host '- Not Removing File'
        #     }
        # }
        # Write-Host "End Files ..."

        # #Stop-Transcript



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