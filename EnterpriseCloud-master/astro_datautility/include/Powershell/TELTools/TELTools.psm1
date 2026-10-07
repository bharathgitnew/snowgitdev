[cmdletbinding()]
param(
    [Parameter(Position = 0)]
    [string]$ConfigFileName
)
$PrivateFunctions = @( Get-ChildItem -Path "$($PSScriptRoot)\Private\*.ps1" -ErrorAction SilentlyContinue )
$PublicFunctions  = @( Get-ChildItem -Path "$($PSScriptRoot)\Public\*.ps1" -ErrorAction SilentlyContinue )

Write-Verbose "Importing TELTools-CRM Module";

Write-Verbose "  -- Import All Functions";
Foreach($import in @($PublicFunctions + $PrivateFunctions))
{
    Try
    {
		Write-Verbose "    -- $($import.Basename)";
        . $import.fullname;
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Write-Verbose '  -- Exporting Public Functions';
Export-ModuleMember -Function $PublicFunctions.Basename;

Write-Verbose '  -- Calling Initialize Module Function';
Initialize-Module $ConfigFileName;