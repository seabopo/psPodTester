function Test-IPInSubnet {
    <#
    .DESCRIPTION
        Tests if an IP Address is in a subnet. Values are strings as they are passed as environment variables.
        If the subnet is passed bare (no /24, etc.) it's treated as a /32 (single IP address)
    .EXAMPLE
        Test-IPInSubnet -i '192.168.3.100' -s '192.168.3.0/24'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [Alias('i')] [String]   $IPAddress,
        [Parameter(Mandatory)] [Alias('s')] [String[]] $Subnet
    )

    process {
        
        $ip = $null
        if (-not [System.Net.IPAddress]::TryParse($IPAddress, [ref]$ip)) {
            throw "Invalid IP address: '$IPAddress'"
        }
        $ipBytes = $ip.GetAddressBytes()

        foreach ($cidr in $Subnet) {
            
            $parts  = $cidr.Split('/')
            $netIp  = $null

            if (-not [System.Net.IPAddress]::TryParse($parts[0], [ref]$netIp)) {
                throw "Invalid subnet: '$cidr'"
            }

          # Bare address = host route
            $maxBits = if ($netIp.AddressFamily -eq 'InterNetworkV6') { 128 } else { 32 }
            $prefix  = if ($parts.Count -gt 1) { [int]$parts[1] } else { $maxBits }

            if ($prefix -lt 0 -or $prefix -gt $maxBits) {
                throw "Invalid prefix length /$prefix in '$cidr'"
            }
            if ($netIp.AddressFamily -ne $ip.AddressFamily) { continue }

            $netBytes  = $netIp.GetAddressBytes()
            $fullBytes = [math]::Floor($prefix / 8)
            $remBits   = $prefix % 8
            $match     = $true

            for ($i = 0; $i -lt $fullBytes; $i++) {
                if ($ipBytes[$i] -ne $netBytes[$i]) { $match = $false; break }
            }

            if ($match -and $remBits -gt 0) {
                $mask = [byte](0xFF -shl (8 - $remBits) -band 0xFF)
                if (($ipBytes[$fullBytes] -band $mask) -ne ($netBytes[$fullBytes] -band $mask)) {
                    $match = $false
                }
            }

            if ($match) { return $true }
        }

        return $false
    }
}