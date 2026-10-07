function Get-TELItem {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true,
        HelpMessage = "-SourceName is required")]
        [string]$SourceName,

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

        Write-Verbose "       -- Initializing $($SourceName) TELItem";
        $SourceConfiguration  = $script:ConfigurationData.$SourceName;
        if(!($SourceConfiguration))  { $Message = "Invalid Configuration for $($SourceName) as a source."; Write-Verbose "       -- $($Message)"; throw $Message; }
        $DataSetConfiguration = $SourceConfiguration.DataSets.$DataSetName;
        if(!($DataSetConfiguration)) { $Message = "Invalid Configuration for $($DataSetName) as a dataset."; Write-Verbose "       -- $($Message)"; throw $Message; }

        Write-Verbose "       -- Initializing $($SourceName) Powershell Module";
        $ThirdPartyPowershellModule = $SourceConfiguration.ModuleInfo.PowershellModule;
        $ThirdPartyPowershellModuleLocation = $SourceConfiguration.ModuleInfo.ModuleLocation;
        $ImportStatus = Import-ThirdPartyModule -ModuleName $ThirdPartyPowershellModule -ModuleLocation $ThirdPartyPowershellModuleLocation;
        $FunctionStatisticsDataSet.Add('ThirdPartyModuleImport',$ImportStatus);
        switch ($ImportStatus) {
            Success         { Write-Verbose "       -- Imported $($ThirdPartyPowershellModule) Module"; }
            Failure         { $Message = "Failed to import $($ThirdPartyPowershellModule) Module"; Write-Verbose "      -- $($Message)"; throw $Message; }
            DoesNotExist    { $Message = "Invalid configuration of $($ThirdPartyPowershellModule) Module in $($SourceName)";  Write-Verbose "      -- $($Message)"; throw $Message; }
            NoModuleName    { Write-Verbose "       -- No Third Party Module Needed"; }
            default {  Throw "     -- Unknown Status of 'Import-ThirdPartyModule' API Call ($ImportStatus)"  }
        }

        Write-Verbose "       -- Initializing DataSet Security";
        $TELCredential = Get-TELCredential -SourceName $SourceName -DataSetName $DataSetName;
        Write-Verbose "       -- Initializing Cache";
        $CacheKey = Get-TELCacheKey -SourceName $SourceName -DataSetName $DataSetName -UseCache $DataSetConfiguration.CacheDataSet;
        Write-Debug "CacheKey -> $($CacheKey)";

        Write-Verbose "       -- Initializing Expressions";
        Write-Verbose "          -- Connect Expression";
        $ConnectExpression = $null;
        if($SourceConfiguration.ModuleInfo.ModuleConnect){
            $ConnectExpression = "$($SourceConfiguration.ModuleInfo.ModuleConnect)";
            if($TELCredential){
                $ConnectExpression = $ConnectExpression + " -Credential `$TELCredential";
            }
        }
        $FunctionStatisticsDataSet.Add('ConnectExpression',$ConnectExpression);
        Write-Verbose "ConnectExpression -> $($ConnectExpression)"

        $AddParameterToDataSet = $DataSetConfiguration.AddParameterToDataSet;
        if(!($AddParameterToDataSet)) { $AddParameterToDataSet = 'No';}
        Write-Verbose  "AddParameterToDataSet -> $($AddParameterToDataSet)"

        Write-Verbose "          -- DataSet Expression";
        $DataSetExpression = @();
        $DataSetFunction = $DataSetConfiguration.FunctionName;
        if(!($DataSetFunction)) {$DataSetFunction = $SourceConfiguration.DataSets.FunctionName ;}
        $ParameterList = Get-DataSetParameterList $DataSetConfiguration;
        if($DataSetFunction -and $ParameterList) {
            foreach($ParamterSet in $ParameterList){
                $BuildParamter = $null;
                $PreBuildParamter = $null;
                foreach($Parameter in $ParamterSet){
                    if($Parameter.PSObject.Properties.Value.StartsWith("Literal:")){
                        $BuildParamter = $BuildParamter +" -$($Parameter.PSObject.Properties.Name) $($Parameter.PSObject.Properties.Value -replace "Literal:",[string]::Empty)";
                    }elseif($Parameter.PSObject.Properties.Value.StartsWith("Variable:")){
                        $ConvertedParameterValue = ConvertFrom-ParameterVariable($Parameter.PSObject.Properties.Value -replace "Variable:",[string]::Empty);
                        $BuildParamter = $BuildParamter +" -$($Parameter.PSObject.Properties.Name) '$($ConvertedParameterValue)'";
                    }elseif ($Parameter.PSObject.Properties.Value.StartsWith("Before:")){
                        $PreBuildParamter = $PreBuildParamter +" `"$($Parameter.PSObject.Properties.Value -replace "Before:",[string]::Empty)`"";
                    }elseif ($Parameter.PSObject.Properties.Name -eq "Query"){
                        $ConvertedParameterValue =  ConvertFrom-SQLQueryVariable -DataSetConfiguration $DataSetConfiguration -DataSetName $DataSetName -ParameterValue $Parameter.PSObject.Properties.Value;
                        $BuildParamter = $BuildParamter +" -$($Parameter.PSObject.Properties.Name) `"$($ConvertedParameterValue)`"";
                        #-- " `"$($Parameter.PSObject.Properties.Value -replace "Before:",[string]::Empty)`"";
                    }else {
                        $BuildParamter = $BuildParamter +" -$($Parameter.PSObject.Properties.Name) `"$($Parameter.PSObject.Properties.Value)`"";
                    }
                }
                if($TELCredential -and !($ConnectExpression)) {$BuildParamter = $BuildParamter +" -Credential `$TELCredential";}
                if( $null -eq $PreBuildParamter) {
                    $DataSetExpression += "$($DataSetFunction) $($BuildParamter);"
                } else {
                    $DataSetExpression += "$($PreBuildParamter) | $($DataSetFunction) $($BuildParamter);"
                }
            }
        }elseif($DataSetFunction -and !($ParameterList)) {
            $DataSetExpression += "$($DataSetFunction)";
        }

        $FunctionStatisticsDataSet.Add('DataSetExpression',$DataSetExpression);
        #Write-Host "DataSetExpression -> $($DataSetExpression)"
        Write-Verbose "DataSetExpression -> $($DataSetExpression)"


        Write-Verbose "          -- Conversion Expression";
        $ConversionExpression = "`$BlockDataSet;";
        if($SourceConfiguration.Conversion){
            $ConversionExpression = "$($SourceConfiguration.Conversion) -DataSet $($ConversionExpression)";
        }
        $FunctionStatisticsDataSet.Add('ConversionExpression',$ConversionExpression);
        Write-Verbose "ConversionExpression -> $($ConversionExpression)"

        Write-Verbose "          -- Disconnect Expression";
        $DisconnectExpression = $null;
        if($SourceConfiguration.ModuleInfo.ModuleDisconnect){
            $DisconnectExpression = "$($SourceConfiguration.ModuleInfo.ModuleDisconnect)";
        }
        $FunctionStatisticsDataSet.Add('DisconnectExpression',$DisconnectExpression);
        Write-Verbose "DisconnectExpression -> $($DisconnectExpression)"


        Write-Verbose "       -- Initializing CommandExpression";
        [scriptblock]$CommandExpression = {
            try {
                $BlockDataSet = @();
                Write-Verbose "  -- Command Expression Execution";
                if($ConnectExpression)    {Write-Verbose "    -- Connecting to module"; $ConnectResult = Invoke-Expression -Command $ConnectExpression;}
                if($DataSetExpression)    {
                    Write-Verbose "    -- Retrieving DataSet";
                    $DataSetExpressionCounter = 0;
                    foreach($Expression in $DataSetExpression) {
                        $DataSetExpressionCounter +=1
                        $ModifiedDataSet = $null
                        Write-Host "      -- Expression($($DataSetExpressionCounter):$($DataSetExpression.Count))): $($Expression)";
                        $Expression = $Expression -Replace('<<KronosSecValue>>', $env:KronosSecValue);
                        $Expression = $Expression -Replace('<<NOWSecValue>>', $env:NOWSecValue);
                        $ExpressionDataSet = Invoke-Expression -Command $Expression;
                        IF(-not $ExpressionDataSet) {continue;}
                        IF($AddParameterToDataSet -eq 'Yes'){
                            Write-Verbose "      -- Adding Paramters to Dataset";
                            $ModifiedDataSet = @{};
                            $SplitExpression = $Expression.Replace(" -","!");
                            $ParamterSetSeperator = @("!");
                            $ParameterSet = $SplitExpression.Split($ParamterSetSeperator);
                            foreach($Parameter in $ParameterSet){
                                if($Parameter.Trim() -match ' '){
                                    $ParamName = $Parameter.Split(' ',2)[0];
                                    $ParamValue = $Parameter.Split(' ',2)[1] -replace '"','' -replace ';','';
                                    $ModifiedDataSet.Add($ParamName,$ParamValue);
                                }
                            }
                            $ModifiedDataSet.Add("Data",$ExpressionDataSet)
                        }else {
                            $ModifiedDataSet = $ExpressionDataSet;
                        }
                        $BlockDataSet += $ModifiedDataSet;
                    }
                }
                if($DisconnectExpression) {Write-Verbose "    -- Disonnecting from module"; $DisconnectResult = Invoke-Expression -Command $DisconnectExpression;}
            }
            catch {
                Write-Host "****Exception*****";
                Write-Host $_.Exception.Message;
            }
            $ConvertedDataSet = Invoke-Expression -command $ConversionExpression;
            return $ConvertedDataSet;
        }
        $FunctionStatisticsDataSet.Add('CommandExpression',$CommandExpression);

        Write-Verbose "       -- Invoking CommandExpression";

        $FullDataSet = @();
        $FullDataSet = Invoke-DataRequest -Command $CommandExpression -CacheKey $CacheKey;

        Write-Verbose "       -- Wrapping up";
        Write-Host "$($FullDataSet.Count) records retrieved.";
        $FunctionStatisticsDataSet.Add('RowsRetrieved',$FullDataSet.Count);

        Write-Verbose "       -- Returning Retrieved Dataset";
        return $FullDataSet;
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