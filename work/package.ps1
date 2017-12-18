Param(
	[Parameter(Mandatory)]
	[string] $release_tag
)
$project_root = "../"
$publish_dir = "${project_root}/published";
$patch_dir = "${project_root}/published/release";
$package_dir = "${project_root}/published/_package";
$7z = "D:\Program Files\7-Zip\7z";

$bundle_files = @(
	"${project_root}/docs/code-reference.html",
	"${project_root}/docs/address-map.md",
	"${project_root}/published/README.md",
	"${project_root}/published/CHANGELOG.md",
	"${project_root}/published/CHANGELOG-before-0.7.9.md"
);
$bundle_files | ForEach-Object {
	copy-item $_ $package_dir -Force
}
Get-ChildItem $patch_dir | Where-Object { $_ -match "\.ips|\.bps"} | ForEach-Object {
	Copy-Item $_.FullName $package_dir -Force
}

$command = "& `"$7z`" a -tzip `"${publish_dir}/ff3-DSfy-${release_tag}.zip`" `"${package_dir}/*`""
Invoke-Expression $command;
write-host -foreground green "done.";
