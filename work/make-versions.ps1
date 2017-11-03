Param(
)
$release_dir = "./release";
$original = "./base-binary/ff3.nes";
$build_files = @(
	"ff3_hack_beta.asm",
	"ff3_hack_another.asm",
	"ff3_hack_noitem99.asm",
	"ff3_hack_soundtest.asm",
	"ff3_hack_extra_map.asm"
);
$build_files | % {
	$out = $_ -replace '.asm', '.nes';
	write-host -foreground yellow "building $out...";
	##
	./nesasm $_;
	move-item -force $out $release_dir/$out;
	##
	write-host -foreground gray "making patch as .bps..."
	$bps = ./flips --create --bps $original $release_dir/$out;
	$bps;
	##
	write-host -foreground gray "making patch as .ips..."
	$ips = ./flips --create --ips $original $release_dir/$out;
	$ips;
}
write-host -foreground green "done."