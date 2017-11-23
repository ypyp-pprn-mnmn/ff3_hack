
# $34:8ff7 presentBattle

<summary></summary>

## args:
+ [in] u8 $7ec2 : set by commandHandler; usually commandId
	- prizeMessage = 2
	- toadCastsToad = 18	
+ [in] u8 $78d5 : commandChianId
	- (0-5: 0=attack 1=action 2,4=prize)
+ [in] u8 $78da[] : message id queue?
## local variables:
+	u16 $34:950d[<0x20] : dispCommandListPtrTable
+	u16 $34:954d[?] : dispCommandHandlerTable
+	u8 $7ad7[0x14] : string
+	u16 $62 : dispCommandListPtr
+	u8 $64 : currentDispCommandIndex
## (pseudo-)code:
```js
{
	a = $7ec2;
	if (a != 0) {
		a = $78d5 << 1;
		$18,19 = #950d + a;
		$62,63 = *($18,19);
		$78ef,78ee,64 = x = 0;
		for (;;) {
$9020:			initTileArrayStorage();	//$34:9754();
			a = 0;
			for (x = 0x13;x >= 0;x--) {
$9027:				$7ad7.x = a;
			}
$902d:			y = $64;
			$4b = a = $62[y];
//$4b : dispCommand
//	04,02,01,00 : closeWindow?
//	03 : closeMessageWindow?
//	05 : showActorName?
//	06 : showHitCount?/actionName (ex.3かいヒット)
//	07 : showTargetName?	(ex.ぜんたい)
//	08 : showEffectMessage? (ex.めがみえる!)
//	09 : showMessage?	(ex.からだがじょじょにせきかする)
//	0a : waitForAButtonDown
//	0b : effectOnTarget?
//	0c : damage
//	0d : dyingEffect?
//	0e :
			if (#ff == $4b) break;
$9037:
			a <<= 1;
			$18,19 = #954d + a;
			$1a,1b = *($18,19);
			(*$1a)();	//funcptr
$9051:			$64++;
		}
	}
$9056:
	a = #25;
	return call_2e_9d53(a = #25);	//jmp $3f:fa0e();
$905b:
}
```



