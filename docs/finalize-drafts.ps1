#[CmdletBinding()]
Param(
	[Parameter(Mandatory, ParameterSetName="single",Position=0)]
	[string] $target,
	[Parameter(Mandatory, ParameterSetName="all")]
	[switch] $all = $false,
	[switch] $overwrite = $false
)
$drafts_dir = "./codes/_drafts";
$outdir = "$(Get-Location)/codes";
function split_docs($outdir, $target) {
	$markdown = (Get-Content $target -Encoding UTF8) -join "`n";
	$codes = $markdown -split "^_{5,}$", 0, "Multiline"
	#$codes.Length;
	#$markdown.Length;

	$codes | ForEach-Object {
		$matched = ($_ -match "(?<!\>)\# ?\$`([0-9a-fA-F]{2}).([0-9a-fA-F]{4}) ?(.*?)\n");
		if ($matched) {
			$bank =	$matches[1];
			$addr = $matches[2];
			## sanitize symbols as it will be part of filename.
			$sym = (($matches[3] -split " |\t")[0] -replace "::",".") -replace "[\:\(\)\[\]\?\{\} \t]","";
			$out = "${outdir}/${bank}/${bank}_${addr}-${sym}.md";
			## make it!
			if (-not (Test-Path "${outdir}/${bank}")) {
				mkdir -Path "${outdir}/${bank}"
			}
			$content = $_ -replace "</?details>","";
			try {
				if (-not (Test-Path $out)) {
					$content | Out-File -FilePath $out -Encoding utf8;
					Write-Host -ForegroundColor DarkBlue "NEW : $out";
				} else {
					if ($overwrite) {
						$content | Out-File -FilePath $out -Encoding utf8;
						Write-Host -ForegroundColor DarkGreen "UP  : $out";
					} else {
						Write-Host -ForegroundColor DarkYellow "SKIP: $out";
					}
				}
			} catch {
				Write-Host -ForegroundColor DarkRed "ERR : $out";
			}
		} else {
			if ($_ -match "(#.*?)\n") {
				$head = $matches[1];
				Write-Host -ForegroundColor DarkRed "ERR : failed to parse. ${head}";
			} else {
				Write-Host -ForegroundColor DarkRed "ERR : failed to parse. context unknown";
			}
		}
	}
}

if ($all) {
	Get-ChildItem -Filter "*.md" -Path $drafts_dir | ForEach-Object {
		split_docs "${outdir}" $_.FullName;
	};
} else {
	split_docs ${outdir} ${target};
}