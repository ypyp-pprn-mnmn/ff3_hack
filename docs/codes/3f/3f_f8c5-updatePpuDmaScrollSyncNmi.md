
# $3f:f8c5 updatePpuDmaScrollSyncNmi


## code:
```js
{
	waitNmi();
	setDmaSourceAddrTo0200;//$3f:f8aa
	return updatePpuScrollNoWait();	//here $f8cb
}
```



