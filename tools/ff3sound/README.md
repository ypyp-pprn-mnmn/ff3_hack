# ff3sound.js
Exports sequence data from the ff3's rom data as MML.

## install:
npm install ff3sound

## usage:
`ff3sound [--input-path <nesfile>] [--output-path <path to output mml>] [--track-no:<0...58> | --all]`
options could be specified with single hyphen + initial letter of corresponing long option.

## testing:
convenient with testing of outputs:
http://benjaminsoule.fr/tools/vmml/

## notes:
track #32 - battle1, utilizing command d0...e0 & 5 channels
track #7 - victory, utilizing 5 channels.
track #18 - tool's bug?
track #3 - aria.
track #40 - dark cloud. utilizing 5 channels.
track #42 - battl2. utilizing 5 channels.
track #47 - sunken world.
