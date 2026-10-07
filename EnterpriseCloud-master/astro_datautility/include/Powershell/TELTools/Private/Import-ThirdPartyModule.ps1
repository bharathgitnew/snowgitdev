function Import-ThirdPartyModule {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-ModuleName specifies the module name")]
        [string]$ModuleName,

        [parameter(Mandatory = $false,
        HelpMessage = "-ModuleLocation specifies the module code location")]
        [string]$ModuleLocation
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
        $SavedVerbosePreference = $VerbosePreference;
		Write-Verbose "... Initializing $($ModuleName) Powershell Module";
		[bool]$ModuleAvailable   = $false;
		[bool]$ModuleRemoved   = $false;
		[bool]$ModuleImported   = $false;

        if($ModuleName){
            if($ModuleLocation) {
                $ImportModuleName = "$ModuleLocation\$ModuleName";
            }else{
                $ImportModuleName = $ModuleName;
            }
            $VerbosePreference = 'SilentlyContinue';
            if((Get-Module -Name $ModuleName -ListAvailable) -or ($ModuleLocation) ) {
                $VerbosePreference = $SavedVerbosePreference;
                $VerbosePreference = 'SilentlyContinue';
                if(Get-Module -Name $ModuleName) {
                    $VerbosePreference = $SavedVerbosePreference;
                    Remove-Module $ModuleName;
                    $ModuleRemoved = if(Get-Module -Name $ModuleName){$false}else{$true}
                    $VerbosePreference = $SavedVerbosePreference;
                }
                try {
                    $VerbosePreference = $SavedVerbosePreference;
                    Write-Verbose "... Importing $($ModuleName) Powershell Module";
                    $VerbosePreference = 'SilentlyContinue';
                    Import-Module $ImportModuleName;
                    $VerbosePreference = $SavedVerbosePreference;
                    $ModuleImported = $true;
                    if(Get-Module -Name $ModuleName){
                        $ModuleAvailable = $true
                        $ReturnValue = 'Success';
                    }
                }
                catch {
                    $VerbosePreference = $SavedVerbosePreference;
                    $ReturnValue = 'Failure';
                }
            }
            else{
                $VerbosePreference = $SavedVerbosePreference;
                $ReturnValue = 'DoesNotExist';
            }
		}else{
            $VerbosePreference = $SavedVerbosePreference;
			$ReturnValue = 'NoModuleName';
		}
		$FunctionStatisticsDataSet.Add('Available',$ModuleAvailable);
		$FunctionStatisticsDataSet.Add('Removed',$ModuleRemoved);
		$FunctionStatisticsDataSet.Add('Imported',$ModuleImported);
		$FunctionStatisticsDataSet.Add('ReturnValue',$ReturnValue);
		Write-Verbose "... Completed $($ModuleName) Powershell Module : $($ReturnValue)";
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
        Adds a module to the current session.

        .DESCRIPTION
        Adds a module to the current session.  Used for importing third party functions into a specific process of this module.

        .PARAMETER ModuleName
        Specifies the module name.

        .INPUTS
        None. You cannot pipe objects to this Import-ThirdPartyModule.

        .OUTPUTS
		System.String. Import-ThirdPartyModule returns a string status based on if the requested module is imported.
				Values are "Succeess","Failure","DoesNotExist","NoModuleName"

        .EXAMPLE
        C:\PS> Import-ThirdPartyModule -ModuleName "AzureAD"
		Success

        .EXAMPLE
        C:\PS> Import-ThirdPartyModule -ModuleName "AzureAD"   #Fails Import
		Success

        .EXAMPLE
        C:\PS> Import-ThirdPartyModule -ModuleName "NonExistantModule"
		DoesNotExist

        .EXAMPLE
        C:\PS> Import-ThirdPartyModule
        NoModuleName

        .LINK
        TEL Modified Version of Online version: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module

        .LINK
        Write-DataSetToFile
    #>
}