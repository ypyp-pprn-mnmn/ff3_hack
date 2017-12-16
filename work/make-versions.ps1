Param(
)
$release_dir = "../published/release";
$original = "./base-binary/ff3.nes";
$infile_prefix = "_";
$build_files = @(
	"ff3-DSfy.asm", #"ff3_hack_beta.asm",
	#"ff3-DSfy-sticky-provoke.asm", #"ff3_hack_another.asm",
	#"ff3-DSfy-fix-item99.asm", #"ff3_hack_noitem99.asm",
	#"ff3-DSfy-soundtest.asm", #"ff3_hack_soundtest.asm",
	#"ff3-DSfy-extra-map.asm", #"ff3_hack_extra_map.asm",
	"ff3-DSfy-DEV.asm", #"ff3_hack_DEV.asm",
	"ff3-DSfy-only-fast-window.asm" #"ff3_hack_only_fast_window.asm"
);
$build_files | ForEach-Object {
	$infile = "$infile_prefix$_"
	$out = ($infile -replace '.asm', '.nes');
	$release_path = "$release_dir/$($out -replace $infile_prefix,'')"
	write-host -foreground yellow "building $out...";
	##
	./nesasm $infile;
	move-item -force $out $release_path;
	##
	write-host -foreground gray "making patch as .bps..."
	$bps = ./flips --create --bps $original $release_path;
	$bps;
	##
	write-host -foreground gray "making patch as .ips..."
	$ips = ./flips --create --ips $original $release_path;
	$ips;

	## format-hex "$release_dir/$out.hex";
}
write-host -foreground green "done.";
