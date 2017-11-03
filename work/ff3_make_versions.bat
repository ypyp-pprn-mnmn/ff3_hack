@echo off
	rem nesasm ff3_hack.asm
	nesasm ff3_hack_beta.asm
	nesasm ff3_hack_another.asm
	nesasm ff3_hack_noitem99.asm
	nesasm ff3_hack_soundtest.asm
	nesasm ff3_hack_extra_map.asm
	rem move ff3_hack.nes "release\ff3_hack.nes"
	move ff3_hack_beta.nes "release\ff3_hack_beta.nes"
	move ff3_hack_another.nes "release\ff3_hack_another.nes"
	move ff3_hack_noitem99.nes "release\ff3_hack_noitem99.nes"
	move ff3_hack_soundtest.nes "release\ff3_soundtest.nes"
@echo on