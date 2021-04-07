########################################################
# Disable SSL/TLS
########################################################
             
function SSL-TLS {
       Function Ensure-RegKeyExists {
             param (
                    $key
             )
                           
             If (!(Test-Path -Path $key)) {
                    New-Item $key | Out-Null
             }
       }
                    
       Function Set-RegKey {
             param (
                    $key,
                    $value,
                    $valuedata,
                    $valuetype
             )
                           
             # Check for existence of registry key, and create if it does not exist
             Ensure-RegKeyExists $key
                           
             # Get data of registry value, or null if it does not exist
             $val = (Get-ItemProperty -Path $key -Name $value -ErrorAction SilentlyContinue).$value
                           
             If ($val -eq $null) {
                    # Value does not exist - create and set to desired value
                    New-ItemProperty -Path $key -Name $value -Value $valuedata -PropertyType $valuetype | Out-Null
             }
             Else {
                    # Value does exist - if not equal to desired value, change it
                    If ($val -ne $valuedata) {
                           Set-ItemProperty -Path $key -Name $value -Value $valuedata
                    }
             }
       }
                    
       # Registry Paths
       $MPUH_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello";
       $MPUH_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\Client";
       $MPUH_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\Server";
       $PCT_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0";
       $PCT_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client";
       $PCT_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server";
       $SSL2_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0";
       $SSL2_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client";
       $SSL2_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server";
       $SSL3_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0";
       $SSL3_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client";
       $SSL3_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server";
       $TLS10_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0";
       $TLS10_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client";
       $TLS10_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server";
       $TLS11_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1";
       $TLS11_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client";
       $TLS11_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server";
       $TLS12_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2";
       $TLS12_Client_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client";
       $TLS12_Server_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server";
       $Cipher_Parent_Key = "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers";
       $IPSRv6_Parent_Key = "HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters";
       $IPSRv4_Parent_Key = "HKLM:/System/CurrentControlSet/Services\Tcpip\Parameters";
       $PRD_Parent_Key = "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters";
       $QualityCompat_Parent_Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat";
       $MM_Parent_Key = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management";
       $VTCPU_Parent_Key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization";
       $CredSSP_Parent_Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP";
       $CredSSP_Server_Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters";
       $IEPrint_Parent_Key = "HKLM:\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX";
       $IE64Print_Parent_Key = "HKLM:\Software\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX";
                    
                    
       # Check for existence of parent registry keys, and create if they do not exist
       Ensure-RegKeyExists $MPUH_Parent_Key
       Ensure-RegKeyExists $PCT_Parent_Key
       Ensure-RegKeyExists $SSL2_Parent_Key
       Ensure-RegKeyExists $SSL3_Parent_Key
       Ensure-RegKeyExists $TLS10_Parent_Key
       Ensure-RegKeyExists $TLS11_Parent_Key
       Ensure-RegKeyExists $TLS12_Parent_Key
       # Keys added for NexPose security audit
       Ensure-RegKeyExists $IPSRv6_Parent_Key
       Ensure-RegKeyExists $IPSRv4_Parent_Key
       Ensure-RegKeyExists $PRD_Parent_Key
       Ensure-RegKeyExists $QualityCompat_Parent_Key
       Ensure-RegKeyExists $MM_Parent_Key
       Ensure-RegKeyExists $VTCPU_Parent_Key
       Ensure-RegKeyExists $CredSSP_Parent_Key
       Ensure-RegKeyExists $IEPrint_Parent_Key
       Ensure-RegKeyExists $IE64Print_Parent_Key
                    
       # Ensure Multi-Protocol Unified Hello disabled for client
       Set-RegKey $MPUH_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure Multi-Protocol Unified Hello disabled for server
       Set-RegKey $MPUH_Server_Key Enabled 0 DWord
       Write-Host 'Multi-Protocol Unified Hello has been disabled.'
                    
       # Ensure PCT 1.0 disabled for client
       Set-RegKey $PCT_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure PCT 1.0 disabled for server
       Set-RegKey $PCT_Server_Key Enabled 0 DWord
       Write-Host 'PCT 1.0 has been disabled.'
                    
       # Ensure SSL 2.0 disabled for client
       Set-RegKey $SSL2_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure SSL 2.0 disabled for server
       Set-RegKey $SSL2_Server_Key Enabled 0 DWord
       Write-Host 'SSL 2.0 has been disabled.'
                    
       # Ensure SSL 3.0 disabled for client
       Set-RegKey $SSL3_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure SSL 3.0 disabled for server
       Set-RegKey $SSL3_Server_Key Enabled 0 DWord
       Write-Host 'SSL 3.0 has been disabled.'
                    
       # Ensure TLS 1.0 disabled for client
       Set-RegKey $TLS10_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure TLS 1.0 disabled for server
       Set-RegKey $TLS10_Server_Key Enabled 0 DWord
       Write-Host 'TLS 1.0 has been disabled.'
                    
       # Ensure TLS 1.1 disabled for client
       Set-RegKey $TLS11_Client_Key DisabledByDefault 1 DWord
                    
       # Ensure TLS 1.1 disabled for server
       Set-RegKey $TLS11_Server_Key Enabled 0 DWord
       Write-Host 'TLS 1.1 has been disabled.'
                    
       # Ensure TLS 1.2 disabled for client
       Set-RegKey $TLS12_Client_Key DisabledByDefault 0 DWord
                    
       # Ensure TLS 1.2 disabled for server
       Set-RegKey $TLS12_Server_Key Enabled 0xffffffff DWord
       Write-Host 'TLS 1.2 has been enabled.'
                    
       # Set 'MSS: (DisableIPSourceRoutingIPv6) IP source routing protection level (protects against packet spoofing)' 
       Set-RegKey $IPSRv6_Parent_Key DisableIPSourceRouting 2 DWord
       Write-Host 'IPv6 source routing protection level disabled.'
                    
       # Set 'MSS: (DisableIPSourceRouting) IP source routing protection level (protects against packet spoofing)' 
       Set-RegKey $IPSRv4_Parent_Key DisableIPSourceRouting 2 DWord
       Write-Host 'IPv4 source routing protection level disabled.'
                    
       # Set 'MSS: (PerformRouterDiscovery) Allow IRDP to detect and configure Default Gateway Access (Could lead to DoS)' 
       Set-RegKey $PRD_Parent_Key PerformRouterDiscovery 0 DWord
       Write-Host 'IP Allow IRDP to detect and configure Default Gateway Access (Could lead to DoS).'
                    
       # Set correct key for Meltdown/Spectre
       Set-RegKey $QualityCompat_Parent_Key cadca5fe-87d3-4b96-b7fb-a231484277cc 0 DWord
       Write-Host 'Antivirus ISV update key added.'
       Set-RegKey $MM_Parent_Key FeatureSettingsOverride 0 DWord
       Set-RegKey $MM_Parent_Key FeatureSettingsOverrideMask 3 DWord
       Set-RegKey $VTCPU_Parent_Key MinVmVersionForCpuBasedMitigations "1.0" String
       Write-Host 'MeltDown/Spectre update key added.'
                    
       # Set keys for other Rapid7 issues
       Set-RegKey $CredSSP_Server_Key AllowEncryptionOracle 1 DWord
       Set-RegKey $IE64Print_Parent_Key iexplore.exe 1 DWord
       Set-RegKey $IEPrint_Parent_Key iexplore.exe 1 DWord
       Write-Host 'More keys applied for CredSSP and IEPrint'
                    
                    
       # Disable insecure/weak ciphers.
       $insecureCiphers = @(
             'DES 56/56',
             'NULL',
             'RC2 128/128',
             'RC2 40/128',
             'RC2 56/128',
             'RC4 40/128',
             'RC4 56/128',
             'RC4 64/128',
             'RC4 128/128',
             'Triple DES 168'
       )
                    
       Foreach ($insecureCipher in $insecureCiphers) {
             $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($insecureCipher)
             $key.SetValue('Enabled', 0, 'DWord')
             $key.close()
             Write-Host "Weak cipher $insecureCipher has been disabled."
       }
                    
       $secureCiphers = @(
             'AES 128/128',
             'AES 256/256'
                           
       )
       Foreach ($secureCipher in $secureCiphers) {
             $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($secureCipher)
             New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$secureCipher" -Name 'Enabled' -Value '0xffffffff' -PropertyType 'DWord' -Force | Out-Null
             $key.close()
             Write-Host "Strong cipher $secureCipher has been enabled."
       }
                    
       # Set hashes configuration.
       New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes' -Force | Out-Null
       New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5' -Force | Out-Null
       New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5' -Name Enabled -Value 0 -PropertyType 'DWord' -Force | Out-Null
                    
       $secureHashes = @(
             'SHA',
             'SHA256',
             'SHA384',
             'SHA512'
       )
       Foreach ($secureHash in $secureHashes) {
             $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes', $true).CreateSubKey($secureHash)
             New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\$secureHash" -Name 'Enabled' -Value '0xffffffff' -PropertyType 'DWord' -Force | Out-Null
             $key.close()
             Write-Host "Hash $secureHash has been enabled."
       }
                    
       # Set KeyExchangeAlgorithms configuration.
       New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms' -Force | Out-Null
       $secureKeyExchangeAlgorithms = @(
             'Diffie-Hellman',
             'ECDH',
             'PKCS'
       )
       Foreach ($secureKeyExchangeAlgorithm in $secureKeyExchangeAlgorithms) {
             $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms', $true).CreateSubKey($secureKeyExchangeAlgorithm)
             New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\$secureKeyExchangeAlgorithm" -Name 'Enabled' -Value '0xffffffff' -PropertyType 'DWord' -Force | Out-Null
             $key.close()
             Write-Host "KeyExchangeAlgorithm $secureKeyExchangeAlgorithm has been enabled."
       }
                    
       # Set cipher suites order as secure as possible (Enables Perfect Forward Secrecy).
       $os = Get-WmiObject -class Win32_OperatingSystem
       if ([System.Version]$os.Version -lt [System.Version]'10.0') {
             Write-Host 'Use cipher suites order for Windows 2008R2/2012/2012R2.'
             $cipherSuitesOrder = @(
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P521',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P521',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P384',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P521',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P521',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P384',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P256',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P256',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P521',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P256',
                    'TLS_RSA_WITH_AES_256_GCM_SHA384',
                    'TLS_RSA_WITH_AES_128_GCM_SHA256',
                    'TLS_RSA_WITH_AES_256_CBC_SHA256',
                    'TLS_RSA_WITH_AES_128_CBC_SHA256',
                    'TLS_RSA_WITH_AES_256_CBC_SHA',
                    'TLS_RSA_WITH_AES_128_CBC_SHA',
                    'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
             )
       }
       else {
             Write-Host 'Use cipher suites order for Windows 10/2016 and later.'
             $cipherSuitesOrder = @(
                    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
                    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
                    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256',
                    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA',
                    'TLS_RSA_WITH_AES_256_GCM_SHA384',
                    'TLS_RSA_WITH_AES_128_GCM_SHA256',
                    'TLS_RSA_WITH_AES_256_CBC_SHA256',
                    'TLS_RSA_WITH_AES_128_CBC_SHA256',
                    'TLS_RSA_WITH_AES_256_CBC_SHA',
                    'TLS_RSA_WITH_AES_128_CBC_SHA',
                    'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
             )
       }
       $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
       # One user reported this key does not exists on Windows 2012R2. Cannot repro myself on a brand new Windows 2012R2 core machine. Adding this just to be save.
       New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -ErrorAction SilentlyContinue
       New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name 'Functions' -Value $cipherSuitesAsString -PropertyType 'String' -Force | Out-Null
                    
} 