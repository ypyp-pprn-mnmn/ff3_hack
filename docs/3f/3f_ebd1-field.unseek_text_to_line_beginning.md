
# $3f:ebd1 field::unseek_text_to_line_beginning


## args:
+	[in,out] ptr $1c: pointer to text to seek with
+	[out] ptr $3e: pointer to the text, pointing the beginning of line
## callers:
+	`1F:EB81:20 D1 EB  JSR field.unseek_to_line_beginning`
## notes:
used to scroll back texts, in particular when a cursor moved up in item window.

## code:
```js
{
	var ptr = $1c - 1;
	var index = Y;
/*
	1F:EBD1:A5 1C     LDA $001C = #$A8
	1F:EBD3:38        SEC
	1F:EBD4:E9 01     SBC #$01
	1F:EBD6:85 1C     STA $001C = #$A8
	1F:EBD8:A5 1D     LDA $001D = #$83
	1F:EBDA:E9 00     SBC #$00
	1F:EBDC:85 1D     STA $001D = #$83
*/
	for (;;) {
		index = 0;
/*
	1F:EBDE:A0 00     LDY #$00
	1F:EBE0:B1 1C     LDA ($1C),Y @ $83A8 = #$C0
	1F:EBE2:C9 10     CMP #$10
	1F:EBE4:90 0C     BCC $EBF2
	1F:EBE6:C9 28     CMP #$28
	1F:EBE8:B0 08     BCS $EBF2
*/
		if (0x10 <= ptr[index] && ptr[index] < 0x28) {
/*
	1F:EBEA:A5 1C     LDA $001C = #$A8
	1F:EBEC:38        SEC
	1F:EBED:E9 02     SBC #$02
	1F:EBEF:4C D6 EB  JMP $EBD6
*/
			ptr -= 2;
			continue;	//jmp $ebd6
		}
/*
	1F:EBF2:C8        INY
	1F:EBF3:B1 1C     LDA ($1C),Y @ $83A8 = #$C0
	1F:EBF5:F0 07     BEQ $EBFE
	1F:EBF7:C9 01     CMP #$01
	1F:EBF9:F0 03     BEQ $EBFE
	1F:EBFB:4C D1 EB  JMP field.unseek_to_line_beginning
*/
		index++;
		if (ptr[index] == 0 || ptr[index] == 1) {
			break;	//beq $ebfe
		}
		ptr--;
	}
/*
	1F:EBFE:A5 1C     LDA $001C = #$A8
	1F:EC00:18        CLC
	1F:EC01:69 02     ADC #$02
	1F:EC03:85 3E     STA $003E = #$AC
	1F:EC05:A5 1D     LDA $001D = #$83
	1F:EC07:69 00     ADC #$00
	1F:EC09:85 3F     STA $003F = #$83
	1F:EC0B:60        RTS
*/
	$3e = ptr + 2;
	return;
$ec0c:
}
```



