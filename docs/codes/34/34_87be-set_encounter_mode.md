
# $34:87be set_encounter_mode



### args:
+   [in] u8 $7ed8 : battle_mode (situation)
	- bit7 : boss
	- bit6 : magic forbidden
	- bit5 : on invincible
	- bit4 : freeze minimum status
	- bit0 : escape forbidden
+   [out] u8 $78ba :
+	[out] u8 $78c3 : battle_mode

### (pseudo-)code:
```js
{
    // omitted..
$87fb:
    $2a = $2b = $78c3 = $78ba = 0;
    if ( $7ed8 >= 0 && !($7ed8 & 0x20) ) { // bmi $886e and #$20 bne $886e
        $26 = 0x04;
        $28 = $886f();  //jsr $886f sta $28
        get_series1_random(a = 0x64);   //$a564()
        if ( a <= $28 ) {    //bcs $8824
            $2a++;
        }
$8824:        
        $24,25 = 0x7600;
        $26 = 0x08;
        $29 = $886f();
        get_series1_random(a = 0x64);
        if ( a <= $29 ) {   //bcs $8840
            $2b++;
        }
$8840:
        $2a++; $2b++;
        if ( $2a != $2b ) { //beq $886e
            if ( $2a <= $2b ) { //bcs $8852
                $78ba++;
                //jmp $886e
            } else {
$8852:
                $29 >>= 2;
                get_series1_random(a = $28);
                if ( a > $29 ) {    //bcc $8863
                    a = 0x80;
                    //bmi $8868
                } else {
                    $88a4();
                    a = 0x88;
                }
$8868:
                $78ba = $78c3 = a;
            }
        }
    }
$886e:
    return;
}
```



