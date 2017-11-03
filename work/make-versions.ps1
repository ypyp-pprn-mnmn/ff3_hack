Param(
)
$release_dir = "./release";
$build_files = @(
	"ff3_hack_beta.asm",
	"ff3_hack_another.asm",
	"ff3_hack_noitem99.asm",
	"ff3_hack_soundtest.asm",
	"ff3_hack_extra_map.asm"
);
$build_files | % {
	./nesasm $_;
	$out = $_ -replace '.asm', '.nes';
	write-host $out;
	move-item -force $out $release_dir/$out;
}