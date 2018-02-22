#region EspaciosDeNombres
function Get-WmiNamespace {
	Param (
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $False)] [switch] $Recursive
    )
    Get-WmiObject -ErrorAction SilentlyContinue -Namespace $Namespace -Class __NAMESPACE | ForEach-Object{
        if (-not (($_.Name).ToLower()).StartsWith('ms_')) {
            ($ns = '{0}\{1}' -f $_.__NAMESPACE, $_.Name)
            if ($Recursive) {
                Get-WmiNamespace -Recursive -Namespace $ns		
            }
        }
    }
}
function New-WmiNamespace {
    param(
        [Parameter(Mandatory = $True)]  [string] $Namespace,
        [Parameter(Mandatory = $False)] [string] $Root = "root"
    )
    $space = $([WMICLASS]"\\.\$($Root):__Namespace").CreateInstance()
    $space.name = $Namespace
    $space.put() | Out-Null
    return $space
}
function Remove-WmiNamespace {
    param(
        [Parameter(Mandatory = $True)]  [string] $Namespace,
        [Parameter(Mandatory = $False)] [string] $Root = "root"
    )
    $space = $([WMICLASS]"\\.\$($Root):__Namespace").CreateInstance()
    $space.Name = $Namespace
    try {$space.Delete()} catch {}
}
#endregion

#region Clases
function Get-WmiClass {
    Param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $False)] [string] $Filter
    )
	Get-WmiObject -List -Namespace $Namespace | 
		Where-Object{ $_.Name -match $Filter }
}

function New-WmiClass {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class
    )
    $Klass = New-Object System.Management.ManagementClass($Namespace, $null, $null)
    $Klass.name = $Class
    $Klass.Put()
    return $Klass
}
function Remove-WmiClass {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class
    )
    [wmiclass]$Klass = Get-WmiObject -EA SilentlyContinue -Namespace $Namespace -Class $Class -list
    try {$Klass.Delete()} catch  {}
}

function Copy-WmiClass {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [Parameter(Mandatory = $True)]  [string] $DuplicatedClass
        )
    [wmiclass]$Klass = Get-WmiObject -Namespace $Namespace -Class $Class -list
    $nKlass = $Klass.Derive($DuplicatedClass)
    $nKlass.put() | Out-Null
    return $nKlass
}

#region SubconjuntoClasesEvento
function Get-WmiEventClass {
	Param(
		[string]$Namespace='ROOT\CIMv2',
		[string]$Filter
	)
	Get-WmiObject -ErrorAction SilentlyContinue -Query "SELECT * FROM meta_class WHERE (__This ISA '__Event') AND (__Class like '%$Filter%')" 
}
function Get-WmiExtrinsicEvent {
	Param(
		[string]$Namespace='ROOT\CIMv2',
		[string]$Filter
	)
	$ExclusionList = @( 
        '__SystemEvent', 
        '__EventDroppedEvent',
        '__EventQueueOverflowEvent',
        '__QOSFailureEvent',
        '__ConsumerFailureEvent'
    )
	Get-WmiObject -ErrorAction SilentlyContinue -Namespace $Namespace -Query "SELECT * FROM meta_class WHERE (__This ISA '__Event') AND (__Class like '%$Filter%')" |
		Where-Object{$_.Name -eq '__TimerEvent' -or ($_.Derivation.Contains('__ExtrinsicEvent') -and ($ExclusionList -notcontains $_.Name))}
}
function Get-WmiIntrinsicEvent {
	Param(
		[string]$Namespace='ROOT\CIMv2',
		[string]$Filter
	)
	$ExclusionList = @(
        '__ExtrinsicEvent',
        '__TimerEvent'
    )
	Get-WmiObject -ErrorAction SilentlyContinue -Namespace $Namespace -Query "SELECT * FROM meta_class WHERE (__This ISA '__Event') AND (__Class like '%$Filter%')" |
		Where-Object{ (-not $_.Derivation.Contains('__ExtrinsicEvent') -and ($ExclusionList -notcontains $_.Name)) }
}
#endregion

#endregion

#region PropiedadesDeClase
function Get-WmiClassProperty {
    Param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [string] $Filter
	)
    Get-WmiObject -ErrorAction SilentlyContinue -List -NameSpace $Namespace -Class $Class | ?{
        $_.Properties.Name -match $Filter
    } 
}
function New-WmiClassProperty {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [Parameter(Mandatory = $True)]  [string] $Property,
        [Parameter(Mandatory = $False)] [string[]] $Qualifiers
    )
    [wmiclass]$Klass = Get-WmiObject -Class $Class -Namespace $Namespace -List
    $Klass.Properties.Add($Property, [System.Management.CimType]::String, $false)
    ForEach ($Qualifier in $Qualifiers) {
        $Klass.Properties[$Property].Qualifiers.Add($Qualifier, $true)
    }
    $Klass.Put() | Out-Null
    return $Klass
}
function Remove-WmiClassProperty {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [Parameter(Mandatory = $True)]  [string] $Property
    )
    [wmiclass]$Klass = Get-WmiObject -Namespace $NameSpace -Class $Class -list
    $Klass.Properties.remove($Property)
    $Klass.Put() | out-null
}
function New-WmiClassPropertyValue {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)] [string] $Class,
        [Parameter(Mandatory = $True)] [string] $Property,
        [Parameter(Mandatory = $False)] [string] $Value
    )
    [wmiclass]$Klass = Get-WmiObject -Namespace $Namespace -Class $Class -List
    $Klass.SetPropertyValue($Property,$Value)
    $Klass.Put() | Out-Null
    return $Klass
}
function Remove-WmiClassPropertyValue {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [Parameter(Mandatory = $True)]  [string] $Property
    )
    [wmiclass]$Klass = Get-WmiObject -Namespace $Namespace -Class $Class -List
    $Klass.SetPropertyValue($Property,$null)
    $Klass.Put() | Out-Null    
}
#enregion

#region InstanciasDeClase
function Get-WmiClassInstance {
    Param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class
    )
    Get-WmiObject -ErrorAction SilentlyContinue -Namespace $Namespace -Class $Class
}

#endregion

#region MOF's
function Export-MOF {
    param(
        [Parameter(Mandatory = $False)] [string] $Namespace = "root\cimv2",
        [Parameter(Mandatory = $True)]  [string] $Class,
        [Parameter(Mandatory = $True)]  [string] $Path
    )
    [wmiclass]$WMI_Info = Get-WmiObject -Namespace $Namespace -Class $Class -List
    [system.management.textformat]$mof = "mof"
    $MofText = $WMI_Info.GetText($mof)
    "#PRAGMA AUTORECOVER" | Out-File -Append -FilePath $Path
    $MofText | Out-File -Append -FilePath $Path
    return Get-Item $Path
}
function Import-MOF {
    param(
        [Parameter(Mandatory = $True)]  [string] $Path,
        [Parameter(Mandatory = $False)] [string] $MofCompPath = "C:\Windows\System32\wbem\mofcomp.exe"
    )
    if (test-path $MofCompPath) {
        $MofFile = Get-Item  $Path
        $MofComp = Get-Item $MofCompPath
        Invoke-Expression "& $MofComp $MofFile"
    }
}
#endregion MOF's

#region Proveedores
function Get-WmiProvider {
	Param(
		[string]$Namespace='ROOT\CIMv2',
		[string]$Filter
	)
	Get-WmiObject -ErrorAction SilentlyContinue -Namespace $Namespace -Class __Win32Provider | 
		Where-Object{ $_.Name -match $Filter }
}

function Get-WmiProviderClasses {
	Param(
        [Parameter(Mandatory = $False)][string]$ProviderFilter,
        [Parameter(Mandatory = $False)][string]$ClassFilter
    )
    Get-WmiNamespace -Namespace root -Recursive | %{
        $Namespace = $_
        Get-WmiObject -Namespace $Namespace -List | 
            ?{ $_.Qualifiers['Provider'].Value -match $ProviderFilter} |
            ?{ $_.Name -match $ClassFilter} | %{
                $klass = New-Object -TypeName PSObject
                $klass | Add-Member -MemberType NoteProperty -Name 'Namespace' -Value $Namespace
                $klass | Add-Member -MemberType NoteProperty -Name 'Provider' -Value $_.Qualifiers['Provider'].Value
                $klass | Add-Member -MemberType NoteProperty -Name 'Class' -Value $_
                $klass
            }
    }
}

function Get-WmiProviderImages {
	Param(
        [Parameter(Mandatory = $False)][string]$ProviderFilter,
        [Parameter(Mandatory = $False)][string]$ImageFilter
    )
    Get-WmiNamespace -Namespace root -Recursive | %{
        Get-WmiObject -Namespace $_ -Class __Win32Provider | 
        ?{ $_.Name -match $ProviderFilter } | %{
            $ProviderCLSID = $_.CLSID
            $ProviderImage = (Invoke-WmiMethod -Namespace root/default -Class StdRegProv -Name GetStringValue -ArgumentList @([UInt32] 2147483648, "CLSID\$ProviderCLSID\InprocServer32", $null)).sValue
            if ($ProviderImage -match $ImageFilter) {
                $elem = New-Object -TypeName PSObject
                $elem | Add-Member -MemberType NoteProperty -Name 'ProviderImage' -Value $ProviderImage
                $elem | Add-Member -MemberType NoteProperty -Name 'ProviderName' -Value $_.Name
                $elem    
            }
        }
    }
}

#endregion Proveedores