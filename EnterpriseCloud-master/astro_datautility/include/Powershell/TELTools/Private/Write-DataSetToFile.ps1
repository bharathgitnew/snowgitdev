function Write-DataSetToFile {
    #No logging of this function as this function does the logging too ...  would result in an infinite loop
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)] [string]$FileName,
        [parameter(Mandatory = $true)] $DataSet,
        [parameter(Mandatory = $false)] [int]$JSonDepth,
        [parameter(Mandatory = $false)] [string]$SplitRowScheme = 'None',
        [parameter(Mandatory = $false)] [int]$SplitRowCount = 0

    )
    begin
    {
        [int]$JSonDepthDefault = 5;
    }
    process
    {
        Write-Debug "Function  : $($MyInvocation.MyCommand)";
        Write-Debug "Parameter : FileName  : $($FileName)";
        Write-Debug "Parameter : DataSet   : Count of Items ($($DataSet.Count))";
        Write-Debug "Parameter : JSonDepth : $($JSonDepth)";

        if ($null -eq $JSonDepth) {
            Write-Debug "JSonDepth Not Defined.  Using Default - $($JSonDepthDefault)";
            $JSonDepth = $JSonDepthDefault;
        }
        $Format = $FileName.SubString($FileName.LastIndexOf('.')+1, $FileName.Length-($FileName.LastIndexOf('.')+1));
        Write-Debug "Format Calculated as $($Format)";
        $SplitFileNumber = 1;
        $RowsLeft = $true;
        while ($RowsLeft) {
            switch ($SplitRowScheme)
            {
                None {
                    $PartialFileName = $FileName;
                    $PartialDataSet = $DataSet;
                    $RowsLeft = $false;
                }
                Sharepoint {
                    $TotalDataRows = $DataSet['Data'].count;
                    $FirstRow = ($SplitFileNumber-1) * $SplitRowCount;
                    $ExpectedLastRow = ($SplitFileNumber * $SplitRowCount) -1;
                    if($ExpectedLastRow -gt $TotalDataRows) {$LastRow = $TotalDataRows-1; } else {$LastRow = $ExpectedLastRow;}

                    $PartialDataSet = @{};
                    $PartialDataSet.Add('List',$DataSet['List']);
                    $ValueHash = @{};
                    for($RowCounter = $FirstRow; $RowCounter -le $LastRow; $RowCounter++) {
                        $ValueHash.Add($($DataSet['Data'].Keys)[$RowCounter],$($DataSet['Data'].Values)[$RowCounter]);
                    }
                    $PartialDataSet.Add('Data',$ValueHash);

                    $PartialFileName = $FileName -Replace(".$($Format)",".$($SplitFileNumber).$($Format)");
                    $RowsLeft = ($LastRow -lt ($TotalDataRows -1)); #-------------------------
                    $SplitFileNumber = $SplitFileNumber +1;
                }
                Standard {
                    $TotalDataRows = $DataSet.count;
                    $FirstRow = ($SplitFileNumber-1) * $SplitRowCount;
                    $ExpectedLastRow = ($SplitFileNumber * $SplitRowCount) -1;
                    if($ExpectedLastRow -gt $TotalDataRows) {$LastRow = $TotalDataRows-1; } else {$LastRow = $ExpectedLastRow+1;}
                    Write-Host "Taking $($SplitRowCount) Starting from $($FirstRow)";
                    $PartialDataSet = $DataSet | Select-Object -First  $SplitRowCount -Skip $FirstRow;
                    $PartialFileName = $FileName -Replace(".$($Format)",".$($SplitFileNumber).$($Format)");
                    $RowsLeft = ($LastRow -lt ($TotalDataRows -1)); #-------------------------
                    $SplitFileNumber = $SplitFileNumber +1;
                }
                default { Throw "Unknown SplitScheme of file ($SplitRowScheme)" }
            }

            switch -Wildcard ($Format)
            {
                'json'   { $PartialDataSet | ConvertTo-JSON -Depth $JSonDepth | Out-File $PartialFileName  -Encoding UTF8 }
                'config' { $PartialDataSet | ConvertTo-JSON -Depth $JSonDepth | Out-File $PartialFileName  -Encoding UTF8 }
                'csv'    { $PartialDataSet | Select-Object * | Export-Csv $PartialFileName -Encoding UTF8 -NoTypeInformation }
                'raw*'   {
                            $PartialFileName = $PartialFileName -Replace('raw','');
                            $PartialDataSet | Out-File $PartialFileName  -Encoding UTF8;
                         }
                default { Throw "Unknown Format of file ($Format)" }
            }
        }
    }
}