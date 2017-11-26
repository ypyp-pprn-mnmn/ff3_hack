## compile-docs.ps
## 	front-end wrapper to build stand-alone document
##	with [pandoc] (http://pandoc.org/MANUAL.html#general-options)
##	powered by [sidebar-toc-template] (https://github.com/Mushiyo/pandoc-toc-sidebar).
##```powershell
#[CmdletBinding()]

Param(
	#[Parameter(Mandatory)]
	#[ValidatePattern("")]
)
## const.
$docs_root = "../docs"
$sources = "${docs_root}/codes";
#$draft_dir_name = "_drafts";
$pandoc_data_dir = "${docs_root}/codes/_pandoc";
$pandoc_template_dir_name = "pandoc-toc-sidebar";
$pandoc_template_dir = "${pandoc_data_dir}/${pandoc_template_dir_name}";
#
$pandoc_metadata = "${pandoc_data_dir}/metadata.yaml";
$pandoc_template = "${pandoc_template_dir}/toc-sidebarL.html";	#'L': self-contained / 'l'ocal, css/js are getting self-contained also
$pandoc_nav = "${pandoc_template_dir}/nav";
$pandoc_date = $(date -Format "yyyy-MM-dd hh:mm:ss+0900");

$outpath = "code-reference.html";
## parse command line arguments
$pandoc_args = @(
	#"pandoc",
	#"--from gfm",	#to enable metadata.yaml, source format should be pandoc flavor markdown (default)
	"--to html5",
	"--toc",
	"--toc-depth 1",
	"--standalone",
	"--self-contained",
	#"--metadata=title:'${title}'",
	"--metadata 'date:${pandoc_date}'",
	"--variable 'date:${pandoc_date}'",
	"--resource-path '${pandoc_template_dir};${docs_root}'",
	#"--data-dir ${pandoc_data_dir}"
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
	$metadata = Get-Content -Encoding UTF8 $pandoc_metadata;
	$contents = 
		Get-ChildItem $sources -Filter "*.md" -Recurse |
			Where-Object {
				-not ($_.FullName -match "(\\(_|\.))|README.md");
			} |
			ForEach-Object {
				Write-Host $_.FullName;
				$_ | Get-Content -Encoding UTF8;
				#$_.Parent.FullName;
				#$_.FullName
				"".PadRight(80, "_");
			}
	$contents = $metadata + $contents;
	#chcp 65001;	#utf8
	Write-Host -ForegroundColor Gray "pandoc $(${pandoc_args} -join ' ')"
	Invoke-Expression -Command "`$contents | pandoc $(${pandoc_args} -join ' ')"
} catch {
	write-host -ForegroundColor DarkRed $error[0].Exception.Message
	throw;
} finally {
	$OutputEncoding = $OutputEncoding_save;
}
##```
