Function Invoke-Agreement {
    $accept = Read-Host -Prompt "By submitting this form you explicitly express your agreement with the RIPE Database Terms and Conditions [y/n]"
    return $accept.ToLower()[0] -eq 'y'
}

Function Invoke-RIPESearch {
    <#
    .SYNOPSIS
        RIPE Database Text Search
    
    .DESCRIPTION
        This cmdlet allows searches over the full text of the RIPE Database object data through RIPE REST API 'fulltextsearch'.
    
    .PARAMETER Criteria
        The search is done on object text without regard for any relationships. 
    
    .PARAMETER Object
        Search only within the specified object.

    .PARAMETER Field
        Search within the specified field.

    .PARAMETER Summary
        Show only results summary.

    .PARAMETER Delay
        Seconds to wait between API queries (default 1).
    
    .EXAMPLE
        PS C:\> Invoke-RIPESearch -Criteria "John Doe"

    .EXAMPLE
        PS C:\> Invoke-RIPESearch -Criteria "Nuclear" -Summary

    .EXAMPLE
        PS C:\> Invoke-RIPESearch -Criteria "warez" -Object "inetnum"

    .EXAMPLE
        PS C:\> Invoke-RIPESearch -Criteria "funny" -Object "poem" -Field "descr"
    #>
    param(
        [Parameter(Mandatory = $True)][string]$Criteria,
        [Parameter(Mandatory = $False)][string]$Object = $null,
        [Parameter(Mandatory = $False)][string]$Field = $null,
        [Parameter(Mandatory = $False)][switch]$Summary,
        [Parameter(Mandatory = $False)][string]$Delay = 1
    )

    if ($False -eq (Invoke-Agreement)) { return }

    $ObjectTypes = @{}
    $ObjectTypes["as-block"] = @("as-block", "created", "descr", "last-modified", "mnt-by", "mnt-lower", "notify", "org", "remarks", "source")
    $ObjectTypes["as-set"] = @("admin-c", "as-set", "created", "descr", "last-modified", "mbrs-by-ref", "members", "mnt-by", "mnt-lower", "notify", "org", "remarks", "source", "tech-c")
    $ObjectTypes["aut-num"] = @("abuse-c", "admin-c", "as-name", "aut-num", "created", "default", "descr", "export", "export-via", "import", "import-via", "last-modified", "member-of", "mnt-by", "mnt-lower", "mnt-routes", "mp-default", "mp-export", "mp-import", "notify", "org", "remarks", "source", "sponsoring-org", "status", "tech-c")
    $ObjectTypes["domain"] = @("admin-c", "created", "descr", "domain", "ds-rdata", "last-modified", "mnt-by", "notify", "nserver", "org", "remarks", "source", "tech-c", "zone-c")
    $ObjectTypes["filter-set"] = @("admin-c", "created", "descr", "filter", "filter-set", "last-modified", "mnt-by", "mnt-lower", "mp-filter", "notify", "org", "remarks", "source", "tech-c")
    $ObjectTypes["inet6num"] = @("abuse-c", "admin-c", "assignment-size", "country", "created", "descr", "geoloc", "inet6num", "language", "last-modified", "mnt-by", "mnt-domains", "mnt-irt", "mnt-lower", "mnt-routes", "netname", "notify", "org", "remarks", "source", "sponsoring-org", "status", "tech-c")
    $ObjectTypes["inetnum"] = @("abuse-c", "admin-c", "country", "created", "descr", "geoloc", "inetnum", "language", "last-modified", "mnt-by", "mnt-domains", "mnt-irt", "mnt-lower", "mnt-routes", "netname", "notify", "org", "remarks", "source", "sponsoring-org", "status", "tech-c")
    $ObjectTypes["inet-rtr"] = @("as-block", "as-set", "aut-num", "domain", "filter-set", "inet6num", "inetnum", "inet-rtr", "irt", "key-cert", "mntner", "organisation", "peering-set", "person", "poem", "poetic-form", "role", "route", "route6", "route-set", "rtr-set")
    $ObjectTypes["irt"] = @("abuse-mailbox", "address", "admin-c", "auth", "created", "e-mail", "encryption", "fax-no", "irt", "irt-nfy", "last-modified", "mnt-by", "notify", "org", "phone", "remarks", "signature", "source", "tech-c")
    $ObjectTypes["key-cert"] = @("admin-c", "certif", "created", "fingerpr", "key-cert", "last-modified", "method", "mnt-by", "notify", "org", "owner", "remarks", "source", "tech-c")
    $ObjectTypes["mntner"] = @("abuse-mailbox", "admin-c", "auth", "created", "descr", "last-modified", "mnt-by", "mnt-nfy", "mntner", "notify", "org", "remarks", "source", "tech-c", "upd-to")
    $ObjectTypes["organisation"] = @("abuse-c", "abuse-mailbox", "address", "admin-c", "created", "descr", "e-mail", "fax-no", "geoloc", "language", "last-modified", "mnt-by", "mnt-ref", "notify", "org", "org-name", "org-type", "organisation", "phone", "ref-nfy", "remarks", "source", "tech-c")
    $ObjectTypes["peering-set"] = @("admin-c", "created", "descr", "last-modified", "mnt-by", "mnt-lower", "mp-peering", "notify", "org", "peering", "peering-set", "remarks", "source", "tech-c")
    $ObjectTypes["person"] = @("abuse-mailbox", "address", "created", "e-mail", "fax-no", "last-modified", "mnt-by", "nic-hdl", "notify", "org", "person", "phone", "remarks", "source")
    $ObjectTypes["poem"] = @("author", "created", "descr", "form", "last-modified", "mnt-by", "notify", "poem", "remarks", "source", "text")
    $ObjectTypes["poetic-form"] = @("admin-c", "created", "descr", "last-modified", "mnt-by", "notify", "poetic-form", "remarks", "source")
    $ObjectTypes["role"] = @("abuse-mailbox", "address", "admin-c", "created", "e-mail", "fax-no", "last-modified", "mnt-by", "nic-hdl", "notify", "org", "phone", "remarks", "role", "source", "tech-c")
    $ObjectTypes["route"] = @("aggr-bndry", "aggr-mtd", "components", "created", "descr", "export-comps", "holes", "inject", "last-modified", "member-of", "mnt-by", "mnt-lower", "mnt-routes", "notify", "org", "origin", "ping-hdl", "pingable", "remarks", "route", "source")
    $ObjectTypes["route6"] = @("aggr-bndry", "aggr-mtd", "components", "created", "descr", "export-comps", "holes", "inject", "last-modified", "member-of", "mnt-by", "mnt-lower", "mnt-routes", "notify", "org", "origin", "ping-hdl", "pingable", "remarks", "route6", "source")
    $ObjectTypes["route-set"] = @("admin-c", "created", "descr", "last-modified", "mbrs-by-ref", "members", "mnt-by", "mnt-lower", "mp-members", "notify", "org", "remarks", "route-set", "source", "tech-c")
    $ObjectTypes["rtr-set"] = @("admin-c", "created", "descr", "last-modified", "mbrs-by-ref", "members", "mnt-by", "mnt-lower", "mp-members", "notify", "org", "remarks", "rtr-set", "source", "tech-c")

    $search_criteria = "({0})" -f ($Criteria.split() -Join '+AND+')
    $query = $null
    If ( ($Object -ne [String]::Empty) -and ($Field -ne [String]::Empty) ) {
        If ($ObjectTypes[$Object] -contains $Field) {
            $query = "({0}:{1})+AND+(object-type:{2})" -f $Field, $search_criteria, $Object
        }
    } ElseIf ($Object -ne [String]::Empty) {
        If ($ObjectTypes.Keys -contains $Object) {
            $query = "{0}+AND+(object-type:{1})" -f $search_criteria, $Object
        } 
    } Else {
        $query = "{0}" -f $search_criteria
    }

    $web_client = new-object system.net.webclient
    $RIPE_API = "https://apps.db.ripe.net/db-web-ui/api/rest/fulltextsearch/select?facet=true&format=xml&hl=true&q={0}&wt=json&start={1}"
    $iter = 0
    $docs = @()
    while ($True) {
        $response = $web_client.DownloadString(($RIPE_API -f $query, $iter)) | ConvertFrom-Json
        If ($Summary) {
            [pscustomobject]@{ Object="All"; Results=$response.result.numFound }
            $response.lsts[-1].lst.lsts[0].lst.lsts[0].lst.ints | %{
                [pscustomobject]@{ Object=$_.int.name; Results=$_.int.value }
            } 
            break;
        } Else {
            $response.result.docs | %{        
                $elem = New-Object -TypeName PSObject
                $_.doc.strs | %{
                    if ($elem.PSobject.Properties.name -eq $_.str.name) {
                        $elem.$($_.str.name) += "`r`n" + $_.str.value
                    } else {
                        $elem | Add-Member -MemberType NoteProperty -Name $_.str.name -Value $_.str.value
                    }
                } 
                $docs += $elem
                $elem
            }
            if (($iter + $response.result.docs.Length) -lt ($response.result.numFound)) {
                $iter += 10
            } else {
                break;
            }
            Start-Sleep -Seconds $Delay
        }
    }
}

