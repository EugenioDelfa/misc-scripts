try {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Web")
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:8080/")
    $listener.Start()

    do {
        $context = $listener.GetContext()
        $request = $context.Request

        If ( $request.Url.LocalPath -eq "/exit" ) { break }
        $bcommand = "adb shell content query --uri content:/{0}" -f $request.Url.LocalPath
        If ($request.QueryString["where"] -ne $null) {
            $data = "_id={0}--" -f (($request.QueryString["where"] -replace "([><()'.|])", '\$1') -replace '"', '`"')
            $bcommand += " --where `"{0}`"" -f $data
        }
        If ($request.QueryString["sort"] -ne $null) {
            $data = (("_id/**/limit/**/(SELECT/**/1/**/FROM/**/sqlite_master/**/WHERE/**/1={0})" -f $request.QueryString["sort"])  -replace "([><()',.])", '\$1') -replace '"', '`"'
            $bcommand += " --sort `"{0}`"" -f $data
        }
        $bcommand += " 2>&1"

        $output = (Invoke-Expression $bcommand)
        $response = $context.Response
        $response.ContentType = "text/html"
        $response.StatusCode = 200
        $Content = [System.Text.Encoding]::UTF8.GetBytes("{0}" -f ($output -Join "`r`n") )
        $response.OutputStream.Write($Content, 0, $Content.Length)
        $response.Close()       
    } while ($listener.IsListening)
} finally {
	$listener.Stop()
    $listener.Close()
}