## do-pandoc.ps
## 	front-end wrapper to build stand-alone document with [pandoc] (http://pandoc.org/MANUAL.html#general-options).
##```powershell
#[CmdletBinding()]

Param(
	#[Parameter(Mandatory)]
	#[ValidatePattern("")]
)
## const.
$docs_root = "."
$sources = "${docs_root}/codes";
$draft_dir_name = "_drafts";
$pandoc_template_dir_name = "_pandoc-toc-sidebar";
$pandoc_template_dir = "${docs_root}/codes/${pandoc_template_dir_name}";
$pandoc_template = "${pandoc_template_dir}/toc-sidebar.html";
$pandoc_nav = "${pandoc_template_dir}/nav";

$outpath = "poc.html";
$title = "ff3 プチDS化パッチ";
## parse command line arguments
$pandoc_args = @(
	#"pandoc",
	"--from gfm",
	"--to html5",
	"--toc",
	"--toc-depth 1",
	"--standalone",
	"--self-contained",
	"--metadata=title:'${title}'",
	"--template ${pandoc_template}",
	"--include-before ${pandoc_nav}",
	"--output ${outpath}"
); # -join " ";
## we need bytes flown pipelines be encoded in UTF8.
$OutputEncoding_save = $OutputEncoding;
$OutputEncoding = [Text.UTF8Encoding]::UTF8;
## do it.
try {
	write-host -ForegroundColor Gray $command;
	$contents = 
		Get-ChildItem $sources -Filter "*.md" -Recurse |
			Where-Object {
				-not ($_.FullName -match "\\_");
			} |
			ForEach-Object {
				#Write-Host $_.FullName;
				$_ | Get-Content -Encoding UTF8;
				#$_.Parent.FullName;
				#$_.FullName
			}
	#chcp 65001;	#utf8
	Invoke-Expression -Command "`$contents | pandoc $(${pandoc_args} -join ' ')"
} catch {
	write-host -ForegroundColor DarkRed $error[0].Exception.Message
	throw;
} finally {
	$OutputEncoding = $OutputEncoding_save;
}
##```
