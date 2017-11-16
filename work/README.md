work
====

このフォルダはパッチ開発用の作業用です。
ソースコードだけでなくPoC的な作業に関するファイルもここで管理しています。

各ファイルの文字コードは原則`UTF-8`です。古いファイルは`shift-jis`の場合があります。

## HOW TO BUILD
[こちらのファイル](./BUILDING.md)を参照してください。

## 各フォルダの用途
現在は以下のとおりですが、気まぐれに変わりますし増減します。
ここでは比較的安定しているであろうフォルダだけ書いています。

-   ## ./
    nesasm用のソースコードを置いています。古いソースコードは`shift-jis`。
    問題なくアセンブルできたものから`utf-8`へ移行中。
    
-   ## base-binary
    パッチ作成時に元にするNESファイルを置くスペースです。
    NESファイル自体はgitでは管理していません。

## そのほか
nesasmはシンボルの文字としてunderscore(_)とdot(.)を許可している模様。
これでネーミングがはかどるね!

```c
		/* symbol */
		else
		if (isalpha(c) || c == '_' || c == '.') {
			if (need_operator)
				goto error;
			if (!push_val(T_SYMBOL))
				return (0);
				
```
```C
	/* get the symbol, stop to the first 'non symbol' char */
	while (valid) {
		c = *expr;
		if (isalpha(c) || c == '_' || c == '.' || (isdigit(c) && i >= 1)) {
			if (i < SBOLSZ - 1)
				symbol[++i] = c;
			expr++;
		}
		else {
			valid = 0;
		}
}
```
