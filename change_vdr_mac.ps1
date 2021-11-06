#region // User-Specific Environmental Variables for NSX-T

    #region // Replace the following variables with your own environment
    $nsxserver = 'nsx01.pod3.demo'
    $username = 'admin'
    $password = 'VMware1!VMware1!'
    #endregion

    #region // Do not modify the following six lines
    $auth = $username + ':' + $password
    $Encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
    $EncodedPassword = [System.Convert]::ToBase64String($Encoded)
    $headers = @{"Authorization"="Basic $($EncodedPassword)"}
    $newmac = "02:50:56:56:44:62"
    $path = "https://$($nsxserver)/policy/api/v1/infra/global-config"
    #endregion

#endregion

#region // Create JSON body from NSX-T VDR MAC output
    
    $getvdrmac = Invoke-WebRequest -Uri $path -Header $headers -SkipCertificateCheck
    
    $jsonOutput = ConvertFrom-Json $getvdrmac.content 

    #region // Modify VDR Components (per documentation https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/migration/GUID-538774C2-DE66-4F24-B9B7-537CA2FA87E9.html)
    
        $jsonOutput.allow_changing_vdr_mac_in_use = 'True'

        $jsonOutput.vdr_mac = $newmac

    $body = $jsonOutput

    #endregion

    #region // Modify NSX-T VDR MAC

        $json = $body | ConvertTo-Json

        Invoke-RestMethod -Method Put -Uri $path -Headers $headers -Body $json -ContentType 'application/json' -SkipCertificateCheck

    #endregion 

#endregion
