# https://web.archive.org/web/20101218214830/http://perl-users.jp/articles/advent-calendar/2010/sym/11

Function Get-EncodedString {
    # [string]::Format "replacement"
    # {n} by correpondence ${c}
    param(
        [char[]]$charset,
        [string]$data
    )
        $data -replace "\{0\}", "{$($charset[0])}" -replace "\{1\}", "{$($charset[1])}" -replace "\{2\}", "{$($charset[2])}" -replace "\{3\}", "{$($charset[3])}" -replace "\{4\}", "{$($charset[4])}" -replace "\{5\}", "{$($charset[5])}" -replace "\{6\}", "{$($charset[6])}" -replace "\{7\}", "{$($charset[7])}" -replace "\{8\}", "{$($charset[8])}" -replace "\{9\}", "{$($charset[9])}" -replace "\{10\}", "{$($charset[10])}" -replace "\{11\}", "{$($charset[11])}" -replace "\{12\}", "{$($charset[12])}" -replace "\{13\}", "{$($charset[13])}"
}

Function Get-EncodedCode {
    # [char]n to correspondence ${c}
    param(
        [char[]]$charset,
        [string]$data
    )
    ([char[]]$data| %{
        "`${$($charset[11])}" + [int]$_  `
            -replace "0","`${$($charset[1])}" -replace "1","`${$($charset[2])}" -replace "2","`${$($charset[3])}" -replace "3","`${$($charset[4])}" `
            -replace "4","`${$($charset[5])}" -replace "5","`${$($charset[6])}" -replace "6","`${$($charset[7])}" -replace "7","`${$($charset[8])}" `
            -replace "8","`${$($charset[9])}" -replace "9","`${$($charset[10])}" 
    }) -join '+'
}

Function Get-EncodedScript {
    param(
        [Parameter(Mandatory = $True)][string]$inFile,
        [Parameter(Mandatory = $True)][string]$outFile
    )
    If (-not (Test-Path $inFile)) { return }
    $charset = [char[]]"!#%&()*+,-./;<=>@[\] |"
    $charset = $charset | Sort-Object {Get-Random}
    $nums = Get-EncodedString -charset $charset -data "`${0}=+`$();`${1}=`${0};`${2}=++`${0};`${3}=++`${0};`${4}=++`${0};`${5}=++`${0};`${6}=++`${0};`${7}=++`${0};`${8}=++`${0};`${9}=++`${0};`${10}=++`${0}"
    $char=Get-EncodedString -charset $charset -data '${11}="["+"$(@{})"["${8}"]+"$(@{})"["${2}${10}"]+"$(@{})"["${3}${1}"]+"$?"["${2}"]+"]"'
    $str_withX=Get-EncodedString -charset $charset -data '${0}="".("$(@{})"["${2}${5}"]+"$(@{})"["${2}${7}"]+"$(@{})"[${1}]+"$(@{})"[${5}]+"$?"[${2}]+"$(@{})"[${4}])'
    $iex=Get-EncodedString -charset $charset -data '${0}="$(@{})"["${2}${5}"]+"$(@{})"[${5}]+"${0}"["${3}${8}"]'
    $content = '"' + (Get-Content -Encoding Ascii -Path $inFile) + '"'
    $command = Get-EncodedCode -charset $charset -data $content
    $invoke = "`${$($charset[0])}`"|&`${$($charset[0])}|&`${$($charset[0])}"
    "$nums;$char;$str_withX;$iex;`"$command|$invoke" | Out-File $outFile
}

Get-EncodedScript -inFile .\foo.ps1 -outFile .\bar.ps1