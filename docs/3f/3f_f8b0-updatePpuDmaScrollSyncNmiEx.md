
# $3f:f8b0 updatePpuDmaScrollSyncNmiEx


## code:
```js
{
	waitNmi();	//$3f:fb80();
	setDmaSourceAddrTo0200();	//f8aa;
	loadPalette();	//$f897();
	return updatePpuScrollNoWait();	//f8cb
}
```



