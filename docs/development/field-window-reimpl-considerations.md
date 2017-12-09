# フィールド/メニューのウインドウ描画
## 基本構造
$7000-$7f00 is available to both mode.

### 1. initializations
-   描画に必要な各種メトリック(サイズなど)をstaticな構造体から取得
-   floorでの描画の場合は、ウインドウに重なるオブジェクトの属性変更(ウインドウの後ろに隠す)と背景のパレット指定の変更も行う
#### menu ($37 == 1):
```
    $3d:aaf1 field::draw_menu_window
        $3d:aabc field::get_menu_window_metrics
        [$3f:ed02 field::draw_window_box]
            ($3f:ed61 field::get_window_region) : no operation performed if ($37 == 1)
```

#### floor ($37 == 0):
```
    $3f:ecfa field::draw_in_place_window
        [$3f:ed02 field::draw_window_box]
            $3f:ed61 field::get_window_region
                $3f:ec18 field::hide_sprites_under_window
```

### 2. attribute setup & box rendering
-   この時点では(left,top,width,height)はborderを含む(step1で取得した値のまま)
-   空のウインドウ(borderこみ)を2行/frameで上から描画していく
    +   もっさり感の原因その1
```
    $3f:ed02 field::draw_window_box
        $3f:edc6 field::draw_window_row
            $3e:c98f field::update_window_attr_buff
                $3e:cab1 field::merge_bg_attributes_with_buffer

            [$3f:f6aa field.upload_window_content]
            [$3e:c9a9 field::set_bg_attr_for_window]
                $3e:cb6b field::copyToVramWith_07d0
```

### 3. content rendering
-   この時点では(left,top,width,height)はborderを含まない(step1で取得した値から1tile分内側へ縮小した値: left+=1,top+=1,width-=2,height-=2)
-   枠と背景は描画済みの前提でウインドウの中身を2行/frameで描画していく
    +   もっさり感の原因その2(というか枠の描画とロジックは同じ。パラメータが違うだけ)
```
    $3f:eec0 field.draw_string_in_window
        $3f:eefa textd.draw_in_box
            $3f:f692 field.draw_window_content
                [$3f:f6aa field.upload_window_content]
        $3f:f692 field.draw_window_content
            [$3f:f6aa field.upload_window_content]
```

## buffers
-   $0780/$07a0 それぞれ上のラインと下のライン用のバッファ。中身はname tableに指定するindex(i.e., tile number)。half line描画(code0x09/0x0aを用いて指定)の場合は$07a0だけ使う。
-   $07d0 name table attributes変更のためのバッファで16 entries, 3要素のstructure of array.(16bytes x 3)。vramアドレス,vramにuploadしたい値(=attr value)

# 高速化の実装案
## 1. 背景を埋めるのはやめて、枠だけ描画する
### advantages
-   枠だけなら1fで描画できる
    - 実証ずみ。sprite dma実施後にscanline247から描画を始めてもworst caseでscanline 256には完了。)
-   描画する内容が固定なのでバッファサイズ(32bytes x 2)は気にしなくていい
### disadvantages
-   見た目がキタナイ(枠が先にできて空白を後追いで埋めるのが目立つ)
-   原因その1にしかアプローチしてないので体感はできるけどそこまで速くなってない

⇒ 実装してみたけど、没

## 2. 枠と背景の描画を高速化
### advantages
-   中身が固定なので320bytes(32tiles x 10行相当)/1f程度の描画速度は出せる
-   #1のロジックを流用できる

### disadvantages
-   あんまり速くない
-   パレットが面倒くさい

⇒ 暫定実装としてはアリ

## 3. (本命)枠と中身を同じタイミングで描く
### advantages
-   概念がシンプル
-   オリジナルの等速(2行/1f)だとしても#1より速い
    - 等速でもオリジナルの2倍。

### disadvantages
-   バッファが足らない(´・ω・)
-   枠と中身の合成が面倒 パレットはもっと面倒( ˘•ω•˘ ).｡oஇ

# 必要なモノ
## buffer
描画用のコードを生成するかんじ
- 5 bytes / tiles の buffer
    - 5 bytes = `lda #xx + sta $2007`
    - source は$0780/$07a0
- vram addr変更は2 tiles相当でカウント可能
    - 10 bytes = `lda #xx; sta $2006` x 2
    - window metricsから都度計算
- attr変更は1/8tiles相当
    - sourceは$0300 (画面全体のcache. 0x40 bytes x 2 BGs.)
        - $07c0にも1行分あるけど、枠描画のタイミングで設定するので向いてない

## queing
`$1f: lines_drawn`で行判定

- nmiとは非同期にする
    - どこかのタイミングでnmi handlerを置いておく
- 描画指示が来たら(`field.draw_window_content`がcallされたら)バッファに仮置きする
- 置ききれたら有効長を更新
    - 実際には描画用に生成したコードのrtsを単につぶす
        - rtsを後ろにつけたコードを後ろから展開していけば自動的にそうなるのでよさげ(ﾉ・ω・)ﾉ
- バッファが一杯になったらnmiを待つ
- nmi handlerはバッファにあるだけ描画して、自身をハンドラから取り除く(平時のハンドラに戻す)
    - 通常のハンドラの機能を実行するかは要検討(基本的に`$3f:f692 field.draw_window_content`と同等にする)
        - sprite dma　($f692はやってない。`$3f:edc6 field.draw_window_row`はやってる)
            - window描画はmodal(=game stateのupdateがない)なので最初に1回やったら要らないかも…？
            - field_x.advance_frameでもやってない(paging中にtextをscrollするためによぶやつ)
        - sound driver (やってる)
        - frame counter (やってる)
        - reset scroll (やってる、というか描画したら必須)

## uploader code
1. attr属性変更(初回+2行ごと。1fで描画を4行以上できるなら、4行ごとでok)
    - vram addr
    - attr value

2. name table
    - vram addr
    - namt table index
