
# $3f:eba9 field::seek_text_to_next_line


## args:
+	[in,out] ptr $1c: pointer to text to seek with
+	[out] ptr $3e: pointer to the text, pointing the beginning of next line
## callers:
+	`1F:EB5E:20 A9 EB  JSR field::seek_to_next_line`
+	$3f:ee65 field::stream_string_in_window
## code:
```js
{
/*
	1F:EBA9:A0 00     LDY #$00
	1F:EBAB:B1 1C     LDA ($1C),Y @ $9ECC = #$8B
	1F:EBAD:E6 1C     INC $001C = #$D7
	1F:EBAF:D0 02     BNE $EBB3
	1F:EBB1:E6 1D     INC $001D = #$9D
	1F:EBB3:C9 01     CMP #$01	;0x01 == \n
	1F:EBB5:F0 11     BEQ $EBC8
	1F:EBB7:C9 28     CMP #$28	;0x28 >= printable char
	1F:EBB9:B0 F0     BCS $EBAB
	1F:EBBB:C9 10     CMP #$10	;0x10 < ctrl char
	1F:EBBD:90 EC     BCC $EBAB
	1F:EBBF:E6 1C     INC $001C = #$D7
	1F:EBC1:D0 E8     BNE $EBAB
	1F:EBC3:E6 1D     INC $001D = #$9D
	1F:EBC5:4C AB EB  JMP $EBAB
	1F:EBC8:A5 1C     LDA $001C = #$D7
	1F:EBCA:85 3E     STA $003E = #$FD
	1F:EBCC:A5 1D     LDA $001D = #$9D
	1F:EBCE:85 3F     STA $003F = #$9D
	1F:EBD0:60        RTS
*/
}
```



