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
		$no_thank_you = $false,
	[switch]
		$with_candy = $false
)
## const.
$project_root = "../";
$draft_dir = "${project_root}/docs/codes/_drafts";
$published_dir = "${project_root}/docs/codes";
$template = "${project_root}/docs/codes/_template.md";
$inspection_dir = "${project_root}/work/inspections";
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

function get_file_offset($bank, $addr) {
	$bank = [convert]::ToInt32($bank, 16);
	$addr = [convert]::ToInt32($addr, 16);
	return ($bank -shl 13) -bor ($addr -band 0x1fff);
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
	##
	if ($with_candy) {
		## huh, you're so hungry you can't stop it
		$info = generate_da65info $bank $addr $tuple
		$inspection_out_dir = "${inspection_dir}/${bank}_${addr}";
		if (-not (Test-Path $inspection_out_dir)) {
			mkdir -Path $inspection_out_dir | Out-Null;
		}
		## da65 won't accept utf8 with BOM
		$info | Out-File -Encoding ascii -FilePath "${inspection_out_dir}/da65.info.txt";
		Write-Host -ForegroundColor DarkMagenta "huh, you're so hungry you can't stop it: ${inspection_out_dir}/da65.info.txt";
	}
	$outpath = "${draft_dir}/${bank}_${addr}_DRAFT.md";
	if (Test-Path $outpath) {
		throw "oops! it looks like you forgot you have already started drafting! check ${outpath}.";
	}
	## existing draft not found, so let's start drafting!
	try {
		if ($no_thank_you) {
			## ok, just show the search reseult!
			#if ($tuple[0][1] -ne $null) {
			#	$(Get-Content -Path $tuple[0][1].fullname -Encoding utf8) | Write-Output
			#}
			#if ($tuple[2][1] -ne $null) {
			#	$(Get-Content -Path $tuple[2][1].fullname -Encoding utf8) | Write-Output
			#}
			## there is existing documentation for the addr.
			## just point it out.
			#$name = $tuple[1][1].fullname;
			if ($tuple[1] -ne $null) {
				Write-Host -ForegroundColor DarkMagenta "yup! please come back whenever you wished: $($tuple[1][1].name)";
			}
			Write-Host -ForegroundColor DarkBlue "hmm...isn't it tasty for you: $($tuple[0][1].name) $($tuple[2][1].name)";
		} else {
			"" | Out-File -FilePath $outpath -NoNewline -Encoding utf8;
			if ($tuple[0][1] -ne $null) {
				#Get-Content -Path $tuple[0][1].fullname -Encoding utf8 | Out-File -Encoding utf8 -FilePath $outpath;
				cite $(Get-Content -Path $tuple[0][1].fullname -Encoding utf8)  | Out-File -Encoding utf8 -FilePath $outpath;
				"".PadRight(80, "_") | Out-File -Encoding utf8 -FilePath $outpath -Append;
			}
			if ($tuple[1] -eq $null) {
				get_template $bank $addr | Out-File -Encoding utf8 -FilePath $outpath -Append;
			} else {
				$(Get-Content -Path $tuple[1][1].fullname -Encoding utf8)  | Out-File -Encoding utf8 -FilePath $outpath -Append -NoNewline;
			}
			if ($tuple[2][1] -ne $null) {
				"".PadRight(80, "_") | Out-File -Encoding utf8 -FilePath $outpath -Append;
				#Get-Content -Path $tuple[2][1].fullname -Encoding utf8 | Out-File -Encoding utf8 -FilePath $outpath -Append;
				cite $(Get-Content -Path $tuple[2][1].fullname -Encoding utf8) | Out-File -Encoding utf8 -FilePath $outpath -Append;
				
			}
			Write-Host -ForegroundColor DarkBlue "HERE YOU GO! created new file for drafting!: ${outpath}";
			## let's launch it!
			code --reuse-window ${outpath};
		}
	} catch {
		if (Test-Path $outpath) {
			Remove-Item $outpath
		}
		throw;
	}
}
function get_template($bank, $addr) {
	$template = Get-Content -Path $template -Encoding utf8 | Select-Object -Skip 1;
	return @("# `$${bank}:${addr} ns.addr") + ($template);
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

#for info file specs, see the [reference](http://www.cc65.org/doc/da65-4.html)
function generate_da65info($bank, $addr, $tuple) {
	$filename_pattern = "^([0-9a-fA-F]{2})_([0-9a-fA-F]{4})-(.*?)\.md$";
	$size = "{0:X5}" -f ([convert]::ToInt32($tuple[2][0], 16) - [convert]::ToInt32($addr, 16));
	$offset = "{0:X5}" -f (get_file_offset $bank $addr);
	$sym = "";
	if ($tuple[1] -ne $null) {
		if ($tuple[1][1] -match $filename_pattern) {
			$sym = $matches[3];
		}
	}
	$global =
@"
GLOBAL {
	COMMENTS	3;
	INPUTOFFS	`$${offset};
	STARTADDR	`$${addr};
	INPUTSIZE	`$${size};
	OUTPUTNAME	"${bank}_${addr}-${sym}.da65out.txt";
};
"@;
	# list up all functions documented
	$label_hashes = @{};
	Get-ChildItem -Recurse -Filter "*.md" -Path "${published_dir}" | ForEach-Object {
		## map file name into address
		if ($_.Name -match $filename_pattern) {
			if ($matches[3] -ne "") {
				$hash = $label_hashes[$matches[2]];
				if ($hash -eq $null) {
					$hash = @{};
					$label_hashes[$matches[2]] = $hash;
					#$label_hashes.Add($matches[2], $hash);
				}
				#$label =
				$hash[$matches[1]] = $matches[3];
			}
		}
	};
	$labels = @( );
	foreach ($k in $label_hashes.Keys) {
		# $k:addr -> internal hash, keyed by bank
		$hash = $label_hashes[$k];
		$last_bank = $hash.GetEnumerator() | Sort-Object -Property "Key" -Descending | Select-Object -First 1;
		$sym = $last_bank.Value;
		$labels +=
@"

LABEL {
	NAME "${sym}";
	ADDR `$${k};
	COMMENT "bank `$$($last_bank.Key)";
	SIZE	1;
};
"@;
	}
	return $global + ($labels -join "");
}
## ================================================================================
## do it.
try {
	validate_address $bank $addr
	$find_result = find_target_with_context $bank $addr
	make_me_happy $bank $addr $find_result
} catch {
	write-host -ForegroundColor DarkRed $error[0].Exception.Message
	#throw;
}
