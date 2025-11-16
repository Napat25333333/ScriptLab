# author : Anas EL Faijah

# Generate a CSV file from a TSV user file (see README.md for details)

# !! Must specify the input file as parameter !! 
param(
    [string]$InputFile = "ue27-lab-13-users.tsv"
)


# Function to generate login
function Get-Login {
    param(
        [string]$Departement,
        [int]$Count
    )

    $words = $Departement -split " "
    if ($words.Count -eq 1) {
        $prefix = $words[0].Substring(0, [Math]::Min(2, $words[0].Length)).ToLower()
    } else {
        $prefix = ($words | ForEach-Object { $_.Substring(0,1) }) -join "" | ForEach-Object { $_.ToLower() }
    }

    $login = "{0}{1:D4}" -f $prefix, $Count
    return $login
}

# Function to generate a password
function Generate-Password {
    param([int]$Count)

    if ($Count -eq 10) {
        return "P@ssword"
    }

    $digits = 0..9 | ForEach-Object { $_.ToString() }
    $uppers = [char[]](65..90)  # A-Z
    $lowers = [char[]](97..122) # a-z
    $symbols = @('#','+','-','*','/','&','!','?','_')

    $pwd = @()
    $pwd += $digits | Get-Random -Count 2
    $pwd += $uppers | Get-Random -Count 2
    $pwd += $lowers | Get-Random -Count 5
    $pwd += $symbols | Get-Random -Count 1

    return ($pwd | Sort-Object { Get-Random }) -join ''
}


# Read the file
$lines = Get-Content $InputFile -Encoding UTF8

# Initialize dictionary to count users by department
$deptCounter = @{}
$output = @()

foreach ($line in $lines) {
    if ($line.Trim() -eq "") { continue }

    $fields = $line -split "`t"
    $prenom = $fields[0].Trim()
    $nom = $fields[1].Trim()
    $departement = $fields[2].Trim()

    if (-not $deptCounter.ContainsKey($departement)) {
        $deptCounter[$departement] = 1
    } else {
        $deptCounter[$departement]++
    }

    $count = $deptCounter[$departement]
    $login = Get-Login -Departement $departement -Count $count
    $password = Generate-Password -Count $count

    $output += "$prenom,$nom,$departement,$login,$password"
    
} 
# important !! 
# IMPORTANT  !!!!!
# Display output for redirection with '>' & add header with first name... !!!!
$output = @("Prénom,Nom,Département,Matricule,Mot de passe") + $output
$output | Out-String 

