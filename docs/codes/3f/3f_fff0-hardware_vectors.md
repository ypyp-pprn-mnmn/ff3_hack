
# $3f:fff0 hardware_vectors


### code:
```js
{
	()	FF D6 
	()	FF 75 
	cop	FF F5 
	()	BF D7 
	abort	03 01 
	nmi	00 01 
	reset	48 FF 
	irq	03 01
}
$xx:0100 jmp $fb57
$xx:0103 jmp $fb30
```



