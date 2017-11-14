FC版FF3 プチDS化パッチ
=====================
DSがない…せや!ファミコンですればええんや!

## 概要
 このパッチはDS版FF3発売時まだDSを所持していなかった作者が、
 一部のジョブにDS版で新たに実装されたジョブ特性を実装したり、
 FC版でプレイ上の障害になるバグを修正したり、機能改善を行おうと思い立ち、
 心の赴くままに解析と実装を進めていたものです。

 なお、DS化と銘打ってはありますが、アイテム、敵モンスター、マップなど、
 基本はFC版FF3そのものです。
 
## 大まかな方針
 UFF3 Type-B, FF3C v1 を代表とした、
 本パッチをより進化させた改造FF3が世に生まれ、
 多くの年月も経た2017年現在、
 このパッチを直接遊ぶ必要性は薄いでしょう。
 
 それらの作品は、土台としてのFF3の味は残しつつも、
 現代的で、新しい気持ちで遊べるゲームになっていると私は思います。

 しかし、作者自身、未だに感慨を覚えることがあるのです。
 そうした作品の数々が生まれることは、当時の私は想像してはいなかった。

 このパッチを礎として、別の作品が生まれる可能性。
 それに目を向けるなら、このパッチの行く末も自ずから定められるでしょう。

## というわけで
+ ### 基本的に作者の審美眼と興味に基づき、気の向いたところを実装します
  + 審美眼とはいったい…
+ ### 当面はROM容量512k, マッパーMMC3 を想定したコードにしておきます
  + 家を建てるにはまず基礎工事が必要です

## Milestones
ここまでできたらバージョンアップ(リリースするとはいってない)
### v0.8.0
+ フィールドでのウインドウ描画高速化
### v0.9.0
+ グラフィックスの圧縮(改造は容易なままで)
+ 圧縮により捻出された容量を利用したPoC的なコンセプトダンジョン
