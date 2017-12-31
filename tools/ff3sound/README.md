# ff3sound.js
Exports sequence data from the ff3's rom data as MML
([Music Macro Language@wikipedia@en](https://en.wikipedia.org/wiki/Music_Macro_Language) /
[@wikipedia@ja](https://ja.wikipedia.org/wiki/Music_Macro_Language)).

## install:
just type the follwoing as usual node package:
`npm install ff3sound`

## usage:
`ff3sound [--input-path <nesfile>] [--output-path <path to output mml>] [--track-no=<0...58> | --all]`
options could be specified with single hyphen + initial letter of the corresponing long option.
(e.g., `ff3sound -i ff3.nes -t 40`)

## sample outout:

#### track #30 - 悠久の風
```mml
%1 @2 q6 o7 v8 t150 t120 @1 v3 r8. o5  [ d16 g16 d16 e16 c16 o4 a16 r16 o5 a16 o6 c16 o5 e16 b16 e16 g16  | a16 r16 a16  ]2 @4 v9 $  [ o6 d2. g4 e2. c4 d4 e2. &e1 d2. e4 c2. d4  | o5 b1 &b1  ]2 o5 b1 &b2 r8 b16 o6 c16 d16 e16 f+16 g+16  [ a2 &a8 e8 e8 g8 a4 o7 c4 o6 b4 g4 a2 &a8 e4 d8  | e2 e4 g4 g4. d8 &d8 d8 d8 e8 f4 f4 e4 d4 e1 g+1  ]2 e1 a2 &a8 a8 g8 f8 e4 d4 c4 d4 e1 &e2. r4 ;
----------------------------------------------------------------------------------------------------
%1 @3 q6 o7 v8 @5 v7  [ o5 d16 g16 d16 e16 c16 o4 a16 r16 o5 a16 o6 c16 o5 e16 b16 e16 g16 a16 r16 a16  ]2 $  [ d16 g16 d16 e16 c16 o4 a16 r16 o5 a16 o6 c16 o5 e16 b16 e16 g16 a16 r16 a16  ]6  [ d16 g16 d16 e16 o4 b16 g16 r16 o5 a16 b16 e16 a16 e16 g16 b16 r16 b16  ]2  [ d16 g16 d16 e16 c16 o4 a16 r16 o5 a16 o6 c16 o5 e16 b16 e16 g16 a16 r16 a16  ]6 e16 g16 e16 f+16 d16 o4 b16 r16 o5 a16 b16 e16 a16 e16 g16 a16 r16 a16 e16 g+16 e16 f+16 d16 o4 b16 r16 o5 a16 b16 e16 a16 e16 g+16 b16 r16 b16  [ e16 a16 b16 o6 c16 o5 b16 a16 r16 e16 o6 c8. o5 b8. a8 e16 a16 b16 o6 c16 o5 b16 a16 r16 e16 a8. a8. o6 c8 o5 e16 g16 a16 b16 a16 g16 r16 e16 b8. a8. g8 e16 g16 a16 b16 a16 g16 r16 e16 g8. g8. b8  | e16 f16 a16 o6 c16 o5 b16 a16 r16 f16 o6 c8. o5 b8. a8 e16 f16 a16 o6 c16 o5 b16 a16 r16 f16 a8. a8. o6 c8 o5 e16 f+16 g+16 b16 a16 g+16 r16 e16 b8. a8. g+8 d16 e16 g+16 b16 a16 g+16 r16 e16 g+8. g+8. b8  ]2  [ o5 d16 g16 d16 e16 c16 o4 a16 r16 o5 a16 o6 d16 o5 f16 o6 c16 o5 f16 a+16 o6 c16 r16 c16  ]2 o5 d16 f+16 e16 f+16 d16 o4 b16 r16 o5 b16 o6 d16 o5 f+16 o6 c+16 o5 f+16 a16 b16 r16 b16 e16 g+16 f+16 g+16 d16 o4 b16 r16 o5 g+16 b16 e16 a16 e16 g+16 b16 r16 b16 ;
----------------------------------------------------------------------------------------------------
%1 @8 q8 o6 v15 r1 r1 $  [ o4 c32 r32 c32 r32 r4 c32 r32 c32 r32 r8 o3 g8 o4 e16 r16 o3 g8 o4 c32 r32 c32 r32 r4 c32 r32 c32 r32 r2 o3 a32 r32 a32 r32 r4 a32 r32 a32 r32 r8 a8 o4 e16 r16 o3 g8 a32 r32 a32 r32 r4 a32 r32 a32 r32 r2 o4 f32 r32 f32 r32 r4 f32 r32 f32 r32 r8 c16 r16 o3 a4 o4 f32 r32 f32 r32 r4 f32 r32 f32 r32 r2 e32 r32 e32 r32 r4 e32 r32 e32 r32 r8 o3 b8 o4 f+16 r16 o3 b8 o4 e32 r32 e32 r32 r4 e32 r32 e32 r32 r2  ]2  [ f32 r32 f32 r32 r4 f32 r32 f32 r32 r4 c4 f32 r32 f32 r32 r4 f32 r32 f32 r32 r8 c8 o5 c8 o4 c8 e32 r32 e32 r32 r4 e32 r32 e32 r32 r4 o3 b4 o4 e32 r32 e32 r32 r4 e32 r32 e32 r32 r8 o3 b8 o4 b8 o3 b8  | o4 d32 r32 d32 r32 r4 d32 r32 d32 r32 r8 a4 f8 d32 r32 d32 r32 r4 d32 r32 d32 r32 r8 d8 f4 c+32 r32 c+32 r32 r4 c+32 r32 c+32 r32 r8 c+4 d8 e32 r32 e32 r32 r4 e32 r32 e32 r32 r2  ]2 o3  [ a+32 r32 a+32 r32 r4 a+32 r32 a+32 r32 r2  ]2 b32 r32 b32 r32 r4 b32 r32 b32 r32 r2 o4 e32 r32 e32 r32 r4 e32 r32 e32 r32 r2 
```

### (rest are developer zone)
_____

## testing:
convenient with testing of outputs:
http://benjaminsoule.fr/tools/vmml/

## notes:
- track #32 - battle1, utilizing command d0...e0 & 5 channels
- track #7 - victory, utilizing 5 channels.
- track #18 - tool's bug?
- track #3 - aria.
- track #40 - dark cloud. utilizing 5 channels. intro sweep is not working.
- track #42 - battle2. utilizing 5 channels.
- track #47 - sunken world.
- track #20 - final fantasy
- track #55 - ending (buggy: script needs update)
