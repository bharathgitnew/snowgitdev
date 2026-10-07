function Write-TELLogFile {
  #No logging of this function as this function does the logging too ...  would result in an infinite loop
  [CmdletBinding()]
  param(
      [parameter(Mandatory = $true)] [string]$FileName,
      [parameter(Mandatory = $true)] $DataSet,
      [parameter(Mandatory = $false)] [int]$JSonDepth
  )
  process
  {
    if($script:MachineConfiguration.Logging){
      Write-DataSetToFile -FileName $FileName -DataSet $DataSet -JSonDepth $JSonDepth;
    }
  }
}