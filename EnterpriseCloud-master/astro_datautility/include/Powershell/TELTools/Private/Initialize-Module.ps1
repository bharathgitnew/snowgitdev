function Initialize-Module {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false,
        HelpMessage = "-ConfigFileName ****")]
        [string]$ConfigFileName
	)
    begin
    {
        Write-Verbose "$($MyInvocation.MyCommand) Starting...";
    }
    process {
        Write-Verbose "   *** Tokyo Electron Tools (TelTools) Module Loading...";
        Write-Verbose "       -- Reading Configuration File";
        $ConfigurationRoot = "$($PSScriptRoot)\..\..\..\Configuration\"+$ConfigFileName;
        $ConfigurationContent = Get-Content -Path $ConfigurationRoot -Raw;
        $script:ConfigurationData = ConvertFrom-Json -InputObject $ConfigurationContent;
        if(!( $script:ConfigurationData)) {
            throw "Configuration File not found."
        }

        Write-Verbose "       -- Initializing Global Cache Variable";
        $script:CacheVariableName = "TokyoElectronCache";
        if (-not (Get-Variable -Name $script:CacheVariableName -Scope Global -ErrorAction SilentlyContinue)) {
            Set-Variable -Name $script:CacheVariableName -Scope Global -Value @{}
        }

        $Machine = $env:COMPUTERNAME;

        $script:MachineConfiguration = $script:ConfigurationData.Machines.$Machine;
        IF($null -eq $script:MachineConfiguration) {
            $script:MachineConfiguration = $script:ConfigurationData.Machines.LocalhostC;
        }

        Write-Verbose "       -- Initializing Root Folder Location";
        $InitializeDirectoryNames = ($script:MachineConfiguration.RootFileDirectory, `
                                        $script:MachineConfiguration.TemporaryFileDirectory,`
                                        $script:MachineConfiguration.ExecutionLogFileDirectory);

        foreach($Name in $InitializeDirectoryNames){
            Write-Verbose "         ** Checking $($Name)";
            If(test-path $Name)
            {
                Write-Verbose "            -- Exists";
            }
            else {
                throw "            -- Directory '$($Name)' is required to exist.  See DSC Configuration."
            }
        }


        Write-Verbose "       -- Initializing Variables";
        $script:ActiveDirectoryInitialized = $false;

        Write-Verbose "   *** Tokyo Electron Tools (TelTools) Module Loaded";
    }
    end
    {
        Write-Verbose "   ... $($MyInvocation.MyCommand) Ending";
    }
}