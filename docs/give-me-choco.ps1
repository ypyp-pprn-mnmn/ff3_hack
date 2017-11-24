## give-me-choco.ps
##	gives you a mindful healing chocolate:
##		searches the address for existing documentation
##		and if there isn't it,
##		make new one from a template with combining contextual info.
#[CmdletBinding()]

Param(
	[Parameter(Mandatory)]
	[ValidatePattern("[\.\:\`$_]?[0-9a-fA-f]{2}[\.\:\`$_]?[0-9a-fA-f]{4}")]
		[string] $bank_and_address,
	[switch]
		$no_thank_you = $false
)
## const.
$draft_dir = "./codes/_drafts";
$published_dir = "./codes";
$template = "./codes/_template.md";
## parse command line arguments
$bank_and_address = ($bank_and_address -replace "[^0-9a-fA-F]");
$bank_and_address -match "([0-9a-fA-F]{2})([0-9a-fA-F]{4})(.*?)" | Out-Null;
$bank = $matches[1];
$addr = $matches[2];
## sanity chceks.
function validate_address($bank, $addr) {
	$bank = [convert]::ToInt32($bank, 16);
	$addr = [convert]::ToInt32($addr, 16);
	if (($bank -band 1) -ne (($addr -shr 13) -band 1)) {
		throw "invalid address: even/odd-ness doesn't match.";
	}
	if (($bank -ge 0x3e) -and ($addr -lt 0xc000)) {
		throw "invalid address: last 2 banks are fixed at higher address.";
	}
	if ($bank -ge 0x40) {
		throw "invalid address: valid PRG ROM bank range is 00 to 3F.";
	}
}

function find_target_with_context($bank, $target_addr) {
	## find nearest
	## $out = "$(pwd)/${bank}/${bank}_${addr}-${sym}.md";	
	$prev = @("0000", $null);
	$found = $null;
	$next = @("ffff", $null);
	Get-ChildItem -Recurse -Filter "*.md" -Path "${published_dir}/${bank}" | ForEach-Object {
		## map file name into address
		$_.Name -match "^([0-9a-fA-F]{2})_([0-9a-fA-F]{4})" | Out-Null;
		$addr = $matches[2];
		#@($addr, $target_addr, ($addr -lt $target_addr), ($addr -match $target_addr)) -join "`t";
		if ($addr -match $target_addr) {
			$found = @($addr, $_);
		} elseif (($addr -lt $target_addr) -and ($addr -gt $prev[0])) {
			$prev = @($addr, $_);
		} elseif (($addr -gt $target_addr) -and ($addr -le $next[0])) {
			$next = @($addr, $_);
		}
		#@($prev[0], $found, $next[0]) -join "`t";
	}
	#@($prev, $found, $next);
	#@($prev[0], $found, $next[0]) -join "`t";
	return @($prev, $found, $next, $bank, $target_addr);
}
function make_me_happy($bank, $addr, $tuple) {
	if ($tuple[1] -eq $null) {
		## not found let's start drafting!
		$outpath = "${draft_dir}/${bank}_${addr}_DRAFT.md";
		if (Test-Path $outpath) {
			throw "oops! it looks like you forgot you have already started drafting! check ${outpath}.";
		}
		try {
			if (-not $no_thank_you) {
				"" | Out-File -FilePath $outpath -NoNewline -Encoding utf8;
				if ($tuple[0][1] -ne $null) {
					#Get-Content -Path $tuple[0][1].fullname -Encoding utf8 | Out-File -Encoding utf8 -FilePath $outpath;
					cite $(Get-Content -Path $tuple[0][1].fullname -Encoding utf8)  | Out-File -Encoding utf8 -FilePath $outpath;
					"".PadRight(80, "_") | Out-File -Encoding utf8 -FilePath $outpath -Append;
				}
				get_template $bank $addr | Out-File -Encoding utf8 -FilePath $outpath -Append;
				if ($tuple[2][1] -ne $null) {
					"".PadRight(80, "_") | Out-File -Encoding utf8 -FilePath $outpath -Append;
					#Get-Content -Path $tuple[2][1].fullname -Encoding utf8 | Out-File -Encoding utf8 -FilePath $outpath -Append;
					cite $(Get-Content -Path $tuple[2][1].fullname -Encoding utf8) | Out-File -Encoding utf8 -FilePath $outpath -Append;
					
				}
				Write-Host -ForegroundColor DarkBlue "HERE YOU GO! created new file for drafting!: ${outpath}";
			} else {
				Write-Host -ForegroundColor DarkMagenta "hmm...isn't it tasty for you: $($tuple[0][1].name) $($tuple[2][1].name)";
			}
		} catch {
			if (Test-Path $outpath) {
				Remove-Item $outpath
			}
			throw;
		}
	} else {
		## there is existing documentation for the addr.
		## just point it out.
		$name = $tuple[1][1].fullname;
		Write-Host -ForegroundColor DarkMagenta "found existing documentation: ${name}";
	}
}
function get_template($bank, $addr) {
	$template = Get-Content -Path $template -Encoding utf8 | Select-Object -Skip 1;
	return @("# `$${bank}`$${addr} ns.addr") + ($template);
}

function cite(
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
	[object[]] $content
) {
	#write-host $content;
	$content | ForEach-Object {
		write-output ">>$_";
	}
}
## ================================================================================
## do it.
try {
	validate_address $bank $addr
	$find_result = find_target_with_context $bank $addr
	make_me_happy $bank $addr $find_result
} catch {
	write-host -ForegroundColor DarkRed $error[0].Exception.Message
}