
# $34:8f6f sort



### args:
+ [in] u8 a : end
+ [in] u8 $1a : begin
+ [in] ptr $1c : keys
+ [in] ptr $1e : values
+	u8 $18 : begin
+	u8 $19 : end
+	u8 $1a : firstLesserKeyIndexInFront
+	u8 $1b : firstGreaterKeyIndexInBack
+	u8 $20 : pivot (key of begin)

### notes:
>sorts descending (greater key first)

### (pseudo-)code:
```js
{
	$1b = a;	//len? or end?
	push (a = $18);
	push (a = $19);
	push (a = x);
	$18 = x = $1a;	//begin?
	$19 = y = $1b;	//end?
	$20 = $1c[y = $1a];	//key of begin (pivot)
$8f87:
	y = $1b;
	//end < leastIndex ?	
	if (y < $1a) $8fd3;	//bcc 8fd3
$8f8d:
	while ($1c[y] < $20) { y--;}
	//if ($1c[y] >= $20) $8f96;	//bcs
	//y--;
	//goto $8f8d;	//bcc
$8f96:
	$1b = y;	//後ろから探して最初に見つかった 先頭の値以上の値位置
	y = $1a;	//begin
$8f9a:
	while ($1c[y] > $20) { y++; }	//$8fa5;	//beq bcc
$8fa2:
$8fa5:
	$1a = y;	//先頭から探して最初に見つかった 先頭の値以下の値の位置
	//greaterIndexInBack < lesserIndexInFront?
	if ( (y = $1b) < $1a) $8fd3;	//bcc
$8fad:
	x = $1c[y];	//y:$1b = greaterInBack;
	$21 = $1e[y];	//key
	$1c[y = $1b] = $1c[y = $1a];	// greatertIndex = lesserValue
	$1e[y = $1b] = $1e[y = $1a];	// greaterKey = lesserKey
	$1e[y = $1a] = $21;		// lesserKey = greaterKey
	$1c[y] = x;	//y:$1a		// lesserValue = greaterValue
	//narrow ranges
	$1b--;	//back
	$1a++;	//front
	goto $8f87;	//bcs;always satisfied( last affecting op is: $8fa9 cpy $1a)
$8fd3:
	x = $1a;	//leastIndex
	//greatsetIndex <= begin?
	if (y <= $18) $8fe3;	//beq bcc
$8fdb:
	$1a = $18;	//nextBegin = begin
	a = y;		//nextEnd = greatestIndex
	$8f6f();	//recurse
$8fe3:
	//leastIndex >= end?
	if (x >= $19) $8fee;	//bcs
$8fe7:
	$1a = x;	//nextBegin = leastIndex
	a = $19;	//nextEnd = end
	$8f6f();	//recurse
$8fee:
	x = pop a;
	$19 = pop a;
	$18 = pop a;
	return;
$8ff7:
}
```



