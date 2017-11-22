Param(
	[string] $target
)
$markdown = (Get-Content $target -Encoding UTF8) -join "`n";
$codes = $markdown -split "^_{5,}$", 0, "Multiline"
$codes.Length;
$markdown.Length;

$codes | ForEach-Object {
	$matched = ($_ -match "\# ?\$`([0-9a-z]{2}).([0-9a-z]{4}) (.*?)\n");
	if ($matched) {
		$bank =	$matches[1];
		$addr = $matches[2];
		## sanitize symbols as it will be part of filename.
		$sym = (($matches[3] -split " |\t")[0] -replace "::",".") -replace "[\:\(\)\[\]\?\{\} \t]","";
		#$out = "$(pwd)/${bank}/`$${bank}`$${addr}-${sym}.md";
		$out = "$(pwd)/${bank}/${bank}_${addr}-${sym}.md";
		## make it!
		if (-not (Test-Path $bank)) {
			mkdir -Path $bank
		}
		$content = $_ -replace "</?details>","";
		try {
			$content | Out-File -FilePath $out -Encoding utf8;
			Write-Host -ForegroundColor DarkGreen "OK : $out";
		} catch {
			Write-Host -ForegroundColor DarkRed "ERR: $out";
		}
	}
}
