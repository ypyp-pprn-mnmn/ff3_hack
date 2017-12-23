

# $3d:ad85 menu.jobs.get_change_costs
> ジョブチェンジに必要なコストを算出する。

### args:
+	[out] u8 $7200[0x17] : costs

### (pseudo)code:
```js
{
	for ($8f = 0; $8f < 0x17; $8f++) {
$ad89:
		field.get_job_params();	//$adf2();
		$80 = $7c00 >> 4;
		a = $7c08 >> 4;
		$80 = abs( a - $80 );

		$81 = $7c00 & 0x0f;
		a = $7c08 & 0x0f;
		$81 = abs( a - $81 );

		$82 = $80 + $81;

		x = ($8f << 1) | $7f;
		$83 = $6210.x;
		a = ($82 << 2) - $83;
		if (a < 0) { //bcs addd
$addb:
			a = 0;
		}
$addd:
		$7200.(x = $8f) = a;
	} //cmp #17; bcs aded; jmp ad89
$aded:
	return call_switch1stBank(a = 0x3c);	//jmp $ff06
}
```




