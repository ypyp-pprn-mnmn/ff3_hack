#[CmdletBinding()]
Param(
	[Parameter(Mandatory, ParameterSetName="single",Position=0)]
	[string] $target,
	[Parameter(Mandatory, ParameterSetName="all")]
	[switch] $all = $false,
	[switch] $overwrite = $false,
	[switch] $forget_draft = $false
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
			$content = $_ -replace "</?(details|summary)>","";
			## is there existing file for this address?
			## as symbols may have been renamed, just compare its address.
			$existing = Get-ChildItem -Path "${outdir}/${bank}" | Where-Object { $_.Name -match "${bank}_${addr}"};
			## write the content into file.
			try {
				#if (-not (Test-Path $out)) {
				if ($existing -eq $null) {
					$content | Out-File -FilePath $out -Encoding utf8;
					Write-Host -ForegroundColor DarkBlue "NEW : $out";
				} else {
					if ($overwrite) {
						Remove-Item $existing.FullName;
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
	if ($forget_draft) {
		Remove-Item $target;
	}
}

if ($all) {
	Get-ChildItem -Filter "*.md" -Path $drafts_dir | ForEach-Object {
		split_docs "${outdir}" $_.FullName;
	};
} else {
	split_docs ${outdir} ${target};
}