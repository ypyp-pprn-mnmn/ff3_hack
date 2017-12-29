#!/usr/bin/env node
'use strict';
//const binary = require('binary-file');
//const commander = require('commander');
const argv = require('minimist')(
    process.argv,
    {
        string: [
            "--input-path",
            "--output-path",
        ],
        alias: {
            "i": "input-path",
            "o": "output-path",
            "t": "track-number",
        },
        default: {
            "input-path": "ff3.nes",
            "output-path": "track.mml",
        }
    }
);

console.dir(argv);
console.log(process.argv);

require('../').export_track_as({
    input: argv['input-path'],
    output: argv['output-path'],
    track_no: argv['track-number'],
    format: 'mml',
});
/*
commander
    .version('0.1.0')
    .option('-i, --input-path <path>', "FF3.nes")
    .option('-o, --output-path <path>', "track.mml")
    //.option('-t, --track-number <number>', 0)
    ;

commander
    .command('export <track>', "exports tracks from the nes file.")
    //.option('-t, --track-number <number>', 0)
    .action((...args) => {
        console.log(['export', ...args]);
    });
commander
    .command('list', "lists available tracks within the nes file.")
    .action((...args) => {
        console.log(['list', ...args]);
    });

commander.parse(process.argv);
//*/
