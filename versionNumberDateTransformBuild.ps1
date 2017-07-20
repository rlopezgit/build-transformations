function Update-AssemblyInfoVersionFiles
{
    $buildNumber = $env:BUILD_BUILDNUMBER
    if ($buildNumber -eq $null)
    {
        $buildIncrementalNumber = 0
    }
    else
    {
        $splitted = $buildNumber.Split('.')
        $buildIncrementalNumber = $splitted[$splitted.Length - 1]
    }
      
	$SrcPath = $env:BUILD_SOURCESDIRECTORY
 
    $AllVersionFiles = Get-ChildItem $SrcPath AssemblyInfo.cs -recurse

	$datestring=Get-Date -format yyyy.MM.dd

    $assemblyVersion = "$datestring.$buildIncrementalNumber"
    $assemblyFileVersion = $assemblyVersion
    $assemblyInformationalVersion = $assemblyVersion
     
    Write-Verbose "Transformed Assembly Version is $assemblyVersion" -Verbose
    Write-Verbose "Transformed Assembly File Version is $assemblyFileVersion" -Verbose
    Write-Verbose "Transformed Assembly Informational Version is $assemblyInformationalVersion" -Verbose
 
    foreach ($file in $AllVersionFiles) 
    { 
		#version replacements
        (Get-Content $file.FullName) |
        %{$_ -replace 'AssemblyDescription\(""\)', "AssemblyDescription(""assembly built by TFS Build $buildNumber"")" } |
        %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyVersion(""$assemblyVersion"")" } |
        %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyFileVersion(""$assemblyFileVersion"")" } |
		%{$_ -replace 'AssemblyInformationalVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyInformationalVersion(""$assemblyInformationalVersion"")" } | 
		Set-Content $file.FullName -Force
    }
  
	return $assemblyFileVersion
}

