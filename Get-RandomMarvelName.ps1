# Get Random Marvel Character name

# Public and Private Keys. You can get these from https://developer.marvel.com/
$publicKey = "<PRIVATE KEY>"
$privateKey = "<PUBLIC KEY>"
# API Call requires a time stamp
$ts = Get-Date -Format s

# The required hash can be generated from stitching together the time stamp, public key and private key
# After stitching them together, generate the required MD5 hash
$string = $ts+$privateKey+$publicKey
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($string)))
$hash = $hash.ToLower() -replace '-', ''

# First we do an initial call, the API only returns 100 results, we can change the result set by using an offset
# To know the range for the offset we need to know how much characters the API contains
$charactersURINoOffset = "http://gateway.marvel.com/v1/public/characters?apikey=$publicKey&hash=$hash&ts=$ts&limit=1"

$Params = @{
    ContentType = 'application/json'
    Method = 'Get'
    URI = $charactersURINoOffset
}

$resultNoOffset = Invoke-RestMethod @Params
$totalNames = $resultNoOffset.data.total

# Now we know the total number of results and we can randomize the offset
$offset = Get-Random -Minimum 1 -Maximum $totalNames
$charactersURIOffset = "http://gateway.marvel.com/v1/public/characters?apikey=$publicKey&hash=$hash&ts=$ts&limit=100&offset=$offset"

$Params = @{
    ContentType = 'application/json'
    Method = 'Get'
    URI = $charactersURIOffset
}

# Let's make the actual call
$resultNoOffset = Invoke-RestMethod @Params

# Store the list of names in $names and then remove characters that aren't support by Azure naming conventions
# Quote out the stuff you don't need.
# Create a list of special chars for replace
$chars = '!', '""', ' ', '#', '£', '$', '%', '&', '^', '*', '(', ')', '@', '=', '+', '<', '>', '.', '?', '/', ':', ';', "'", "-"
$chars = [string]::join('|', ($chars | % {[regex]::escape($_)}))

$names = $resultNoOffset.data.results.name
$name = $names | Get-Random
$name = $name.split('(')[0] 
$name = $name.ToLower()
$name = $name -replace $chars, ""

# Add a random number for uniqueness
$randomNumber = Get-Random -Minimum 1000 -Maximum 9999
$result = $name + $randomNumber

# Return the result
Write-host $result