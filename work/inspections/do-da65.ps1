## do-da65.ps1
##	frontend wrapper script to invoke da65.exe the disassember, from cc65 toolset.
#[CmdletBinding()]

Param(
	[Parameter(Mandatory)]
    #[ValidatePattern("[\.\:\`$_]?[0-9a-fA-f]{2}[\.\:\`$_]?[0-9a-fA-f]{4}")]
        [string] $work_dir,
    [Parameter()]
		[string] $nes_file = "../base-binary/ff3_hack_base.nes.noheader"
)
if (-not (Test-Path $work_dir)) {
    throw;
}
## const.
$cc65_bin = "d:\Documents\emulator\nes\tools\cc65\bin";
$da65 = "${cc65_bin}\da65.exe";
$nes_file = Convert-Path -Path $nes_file;
$work_dir = Convert-Path -Path $work_dir;
## parse command line arguments
#$bank_and_address = ($bank_and_address -replace "[^0-9a-fA-F]");
#$bank_and_address -match "([0-9a-fA-F]{2})([0-9a-fA-F]{4})(.*?)" | Out-Null;
#$bank = $matches[1];
#$addr = $matches[2];
## params.
#$work_dir = "${project_root}/work/inspections/${addr}_${romoffset}"
$info_file = "${work_dir}/da65.info.txt"
#$out_path = "${work_dir}/out.txt"
## do it.
## note: parameters not specified here could be found in 'info' file.
$args = @(
    "--cpu 65c02",
    #"--hexoffs",
    "--info '${info_file}'"
    #"--start-addr ${start_addr}",
    #"-o ${out_path}",
    "'${nes_file}'"
);
$command = "${da65} $(${args} -join ' ')";
Write-Host -ForegroundColor Gray $command;
try {
    Push-Location $work_dir | Out-Null
    Invoke-Expression $command;
    $out_file = Get-ChildItem -Filter "*.da65out.txt" | Select-Object -First 1
    code --reuse-window $out_file.FullName
} catch {
    throw;
} finally {
    Pop-Location | Out-Null;
}