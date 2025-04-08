param(
    [Parameter(Mandatory=$false, HelpMessage='Whether to clean up after convertion')]
    [switch]$WithCleanup,
    [Parameter(Mandatory=$false, HelpMessage='Just use this script to clean cache')]
    [switch]$JustCleanup,
    [Parameter(Mandatory=$false, HelpMessage='Number of threads to use in convertion')]
    [string]$ThreadNum=8
)

if ($JustCleanup) {
    Remove-Item $pythonPath,$qqntBackupPath,$qqntExportPath -Force -Recurse
    exit
}

function Print-Msg {
    param ( [Parameter(Mandatory=$true, HelpMessage='String to output')][string]$msg, [string]$color = "Green" )
    Write-Host ('{0}' -f $msg) -ForegroundColor $color
}

function Install-PythonEnv {
    param(
        [Parameter(Mandatory=$true,HelpMessage='Python embeddable package url')]
        [string]$PythonUrl,
        [Parameter(Mandatory=$true,HelpMessage='get-pip.py url')]
        [string]$PipUrl,
        [Parameter(Mandatory=$false,HelpMessage='Path to extract python')]
        [string]$PythonPath='python'
    )
    
    # download embeddable python
    Invoke-WebRequest -Uri $PythonUrl -OutFile './embeddable-python.zip'
    Expand-Archive -Path './embeddable-python.zip' -DestinationPath $PythonPath

    # patch python
    $pthPath = Get-ChildItem -Path $PythonPath -Filter *._pth
    $newContent = (Get-Content -Path $pthPath | Out-String) -replace '#import site','import site'
    $newContent | Set-Content -Path $pthPath

    # download get-pip script
    Invoke-WebRequest -Uri $PipUrl -OutFile "$PythonPath/get-pip.py"
    
    # install pip
    & "$PythonPath/python.exe" "$PythonPath/get-pip.py" --no-warn-script-location

    # install requirements
    & "$PythonPath/Scripts/pip.exe" install -r requirements.txt

    Remove-Item -Path './embeddable-python.zip'
}

function Fetch-Dependency {
    param(
        [Parameter(Mandatory=$true, HelpMessage='Dependency url')]
        [string]$Url,
        [Parameter(Mandatory=$true, HelpMessage='Path to extract')]
        [string]$Path,
        [Parameter(Mandatory=$false, HelpMessage='Patch file path')][AllowEmptyString()]
        [string]$PatchPath
    )

    Invoke-WebRequest -Uri $Url -OutFile './dep.zip'
    Expand-Archive -Path './dep.zip' -Destination $Path
    $inner = Get-ChildItem -Path $Path
    Move-Item -Path "$inner/*" -Destination $Path
    Remove-Item $inner

    if ((Test-Path -Path $PatchPath)) {
        # fix from https://stackoverflow.com/questions/4770177/git-apply-fails-with-patch-does-not-apply-error
        git apply --ignore-space-change --ignore-whitespace --directory=$Path $PatchPath
    }

    Remove-Item -Path './dep.zip'
}

function Run-PythonScript {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = 1)][string]$PythonExe,
        [Parameter()][string]$errorMessage,
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Passthrough
    )
    & $PythonExe @Passthrough
    if ($lastexitcode -ne 0) {
        if (!($errorMessage)) {
          throw ('Exec: Error executing command {0} with arguments ''{1}''' -f $cmd, "$Passthrough")
        } else {
          throw ('Exec: ' + $errorMessage)
        }
    }
}

function Add-PythonSysPath {
    param(
        [Parameter(Mandatory=$true,HelpMessage='Path to embeddable python')]
        [string]$PythonPath,
        [Parameter(Mandatory=$true,HelpMessage='Path to add to python system path')]
        [string]$PathToAdd
    )

    $pthPath = Get-ChildItem -Path $PythonPath -Filter *._pth
    $fullPath = (Get-Item $PathToAdd).FullName
    Add-Content -Path $pthPath -Value $fullPath
}

$pythonUrl = 'https://www.python.org/ftp/python/3.11.8/python-3.11.8-embed-amd64.zip'
$pipUrl = 'https://bootstrap.pypa.io/get-pip.py'
$pythonPath = 'python311'

$pythonAlreadyInstalled = (Test-Path $pythonPath) `
    -and ([IO.Path]::Combine("$pythonPath", 'Scripts', 'pip.exe') | Test-Path) `
    -and (([IO.Path]::Combine("$pythonPath", 'python311._pth') | Get-FileHash -Algorithm MD5).Hash -eq '17DA5DC4E970B5FC4E59A394492D28EF') `
    -and ([IO.Path]::Combine("$pythonPath", 'Lib', 'site-packages') | Get-ChildItem -Filter rotki*)
if (-not $pythonAlreadyInstalled) {
    Remove-Item $pythonPath -Force -Recurse -ErrorAction SilentlyContinue
    Print-Msg "Preparing python environment..."
    Install-PythonEnv -pythonUrl $pythonUrl -pipUrl $pipUrl -pythonPath $pythonPath
}

$qqntBackupUrl = 'https://github.com/xCipHanD/qqnt_backup/archive/main.zip'
$qqntBackupPath = 'qqnt_backup'
$qqntBackupPatchPath = './patches/qqnt_backup-001-add-cmd-input.patch'

$qqntBackupAlreadySet = (Test-Path $qqntBackupPath) `
    -and ([IO.Path]::Combine("$qqntBackupPath", 'decrypt.py') | Test-Path) `
    -and (([IO.Path]::Combine("$qqntBackupPath", 'decrypt.py') | Get-FileHash -Algorithm MD5).Hash -eq 'BA99AFD88E98EA1B5192DEEA4A56F858')

if (-not $qqntBackupAlreadySet) {
    Remove-Item $qqntBackupPath -Force -Recurse -ErrorAction SilentlyContinue
    Print-Msg "Fetching qqnt_backup from $qqntBackupUrl"
    Fetch-Dependency -Url $qqntBackupUrl -Path $qqntBackupPath -PatchPath $qqntBackupPatchPath
}

$qqntExportUrl = 'https://github.com/Tealina28/QQNT_Export/archive/refs/tags/1.5.1.zip'
$qqntExportPath = 'qqnt_export'
$qqntExportPatchPath = './patches/QQNT_Export-001-modify-output-path.patch'

$qqntExportAlreadySet = (Test-Path $qqntExportPath) `
    -and ([IO.Path]::Combine("$qqntExportPath", 'main.py') | Test-Path) `
    -and (([IO.Path]::Combine("$qqntExportPath", 'main.py') | Get-FileHash -Algorithm MD5).Hash -eq '3EC28695E1E175BD759B7A2ABDB57FB9')

if (-not $qqntExportAlreadySet) {
    Remove-Item $qqntExportPath -Force -Recurse -ErrorAction SilentlyContinue
    Print-Msg "Fetching QQNT_Export from $qqntExportUrl"
    Fetch-Dependency -Url $qqntExportUrl -Path $qqntExportPath -PatchPath $qqntExportPatchPath
}

if (-not $pythonAlreadyInstalled) {
    # fix from https://github.com/python/cpython/issues/93875
    Print-Msg "Fixing python system path"
    Add-PythonSysPath -PythonPath $pythonPath -PathToAdd $qqntBackupPath
    Add-PythonSysPath -PythonPath $pythonPath -PathToAdd $qqntExportPath
}

$qqUid = Read-Host 'Enter your qq uid (e.g., u_12345678)'
$dbPath = Read-Host 'Enter the path to your database files (e.g., ./qq-nt-dbs)'

$pythonExe = Join-Path -Path $pythonPath -ChildPath 'python.exe'

Print-Msg "Decrypting..."
Run-PythonScript $pythonExe `
    (Join-Path -Path $qqntBackupPath -ChildPath "decrypt.py") `
    $qqUid $dbPath

Print-Msg "Converting..."
Run-PythonScript $pythonExe `
    (Join-Path -Path $qqntExportPath -ChildPath 'main.py') `
    './decrypt_dbs' $ThreadNum

Remove-Item './decrypt_dbs' -Force -Recurse
Print-Msg "All done"

if ($WithCleanup) {
    Print-Msg "Cleaning..."
    Remove-Item $pythonPath,$qqntBackupPath,$qqntExportPath -Force -Recurse
}