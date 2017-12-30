'use strict';
const BinaryFile = require('binary-file');

module.exports = {
    export_track_as({input, output, track_no, format}) {
        const get_input_buffer = (async function() {
            const infile = new BinaryFile(input, 'r', true);
            try {
                await infile.open();
                const len = await infile.size();
                const skip = (len & 0xFFFF);
                const result = await infile.read(len - skip, skip);
                return result;
            } catch (e) {
                console.exception(`exception while getting input: ${e}`);
            } finally {
                await infile.close();
            }
        });
        const output_path = `${output.replace(/\.mml$/, "")}${track_no}.mml`;
        get_input_buffer().then((buffer) => {
            const out_buffer =
                this.to_format(
                    format,
                    this.get_native_stream(track_no, buffer)
                );
            try {
                require('fs').writeFile(output_path, out_buffer, "utf8", (error) => {
                    if (!!error) {
                        console.log(error);
                    }
                });
            } catch (e) {
                console.exception(`exception while writing output: ${e}`);
            } finally {

            }
            console.info(`successfully exported track #${track_no} into ${output_path}`);
        });
    },
    ADDITIONAL_LENGTH: [
        1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,
        0, 0, 0, 0,  0, 2, 2, 2,  1, 0, 0, 1,  2, 2, 2, 0,
    ],
    TRACK_BOUNDARIES: [
        //0,
        0x19,
        0x2b,
        0x37,
        0x3b,
        0xff
    ],
    TRACK_BANKS: [
        0x37, 0x38, 0x39, 0x3a, 0x09
    ],
    OFFSET_TO_TABLE: [
        (0xA000),
        (0xA000),
        (0x8C77),
        (0xB3AE),
        (0xB400)
    ],
    get_native_stream(track_no, buffer) {
        const map_address = (offset) => {
            const do_map = (bank, offset) => ((bank << 13) & 0xfe000) | (offset & ((1 << 13) -1));
            if ((offset & 0xe000) != 0x8000) {
                return do_map(this.TRACK_BANKS[track_range_index], offset);
            } else {
                return do_map(0x36, offset);
            }
        };
        const track_range_index = this.TRACK_BOUNDARIES.findIndex((bound) => track_no < bound);
        const pp_stream = map_address(
            buffer.readUInt16LE(
                map_address(this.OFFSET_TO_TABLE[track_range_index]))
                + 2 * (track_no - this.TRACK_BOUNDARIES[track_range_index])
            );
        const p_stream = map_address(buffer.readUInt16LE(pp_stream));
        if (typeof p_stream === 'undefined') {
            throw `eighter track_no or input_file is wrong. track_no=${track_no}`;
        }
        console.info(`track #${track_no} - pointer to stream at ${pp_stream.toString(16)}
            => stream pointers begin at ${p_stream.toString(16)} / range: ${track_range_index}`);
        //const pointers = 
        return Array(5).fill(0)
            .map((v, i) => buffer.readUInt16LE(p_stream + i * 2))
            .filter((p) => p != 0xffff)
            .map((p, k) => {
                const result = {
                    start: map_address(p),
                    commands: {},
                    address_trails: [],
                    map_address
                };
                console.info(`channel #${k} - stream begins at ${p.toString(16)} => ${result.start.toString(16)}`);
                
                const address_queue = [result.start];
                while (address_queue.length > 0) {
                    let cursor = address_queue.pop();
                    if (!!result.commands[cursor]) {
                        console.debug(`address ${cursor.toString(16)} has already parsed.`);
                        continue;
                    }
                    result.address_trails.push(cursor);
                    let note = buffer.readUInt8(cursor);

                    const command_bytes = (result.commands[cursor++] = []);
                    const len = ((note < 0xe0) ? 0 : this.ADDITIONAL_LENGTH[note - 0xe0]);
                    command_bytes.push(
                        note,
                        ...Array(len).fill(0).map((v, i) => buffer.readUInt8(cursor++))
                    );
                    // parse jump target later, if any.
                    if (0xfc <= note && note < 0xff) {
                        const jump_target = command_bytes[1] | (command_bytes[2] << 8);
                        console.debug(`adding jump target for parsing: ${jump_target.toString(16)}`);
                        address_queue.push(map_address(jump_target));
                    }
                    if (0x00 <= note && note < 0xfe) {
                        //0xfe is 'jump always'
                        address_queue.push(cursor);
                    }
                }
                const total_bytes = Object.keys(result.commands).reduce((sum, addr) => sum + result.commands[addr].length, 0);
                const last_addr = result.address_trails.slice(-1)[0];
                console.info(`channel #${k} - stream ends at ${(last_addr + result.commands[last_addr].length).toString(16)},`+
                    ` total ${total_bytes} (${total_bytes.toString(16)}) bytes.`);
                return result;
            });
           
    },
    // --- stateless mml converter.
    mml: new (class _mml {
        constructor() {
            const OCTAVE_SHIFT = 3;
            const PITCH = "C C+ D D+ E F F+ G G+ A A+ B".split(/ +/);
            //           60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01
            const LEN = "1  2. 2  4. 3  4  8. 6  8  16. 12 16 24 32 48 96".split(/ +/);
            const CHANNEL_DEFAULTS = [
                `%1 @2 q6 o${OCTAVE_SHIFT + 4} v8 t150`,   //ff3's key-off is defined as 66%
                `%1 @3 q6 o${OCTAVE_SHIFT + 4} v8`,
                `%1 @8 q8 o${OCTAVE_SHIFT + 4} v15`,        //ff3's driver don't control triangle channel's key-off
                `%1 @9 q1 o${OCTAVE_SHIFT + 4} v8`,
                `%1 @10 q1 o${OCTAVE_SHIFT + 4} v8`,
            ];
            const DUTY_MAPS = [
                [1, 2, 4],
                [5, 6, 4],
                [8, 8, 8],
                [9, 9, 9],
                [10, 10, 10],
            ];
            const VOLUME_MAPS = [
                4 / 5,
                4 / 5,
                1,
                2 / 3,
                2 / 3,
            ];
            Object.defineProperty(this, 'default_config', {
                writable: false,
                configurable: false,
                enumerable: true,
                value: {
                    CHANNEL_DEFAULTS,
                    PITCH,
                    LEN,
                    DUTY_MAPS,
                    OCTAVE_SHIFT,
                    VOLUME_MAPS,
                }
            });
        }
        from(channel, command_bytes, last_play_note, config) {
            const command = command_bytes[0];
            if (command < 0xc0) {
                //00-BF: play note.
                return `${config.PITCH[command >> 4]}${config.LEN[command & 0xF]}`;
            } else if (command < 0xd0) {
                //C0-CF: rest note.
                return `R${config.LEN[command & 0xF]}`;
            } else if (command < 0xe0) {
                //D0-DF: tie note.
                return `&${config.PITCH[last_play_note >> 4]}${config.LEN[command & 0xF]}`;
            } else if (command == 0xe0) {
                //E0: set tempo ($7f45)
                return `T${command_bytes[1]}`;
            } else if (0xe1 <= command && command < 0xef) {
                //E1...EF: set volume goals ($7f90)
                return `V${Math.floor(config.VOLUME_MAPS[channel] * (command - 0xe1 + 2))}`;
            } else if (0xEf <= command && command < 0xf5) {
                //EF...F5: set octave ($7f66).
                return `O${command - 0xEF + config.OCTAVE_SHIFT}`;
            } else if (0xf5 <= command && command < 0xf8) {
                //F5: set duty/envelope ($7f89).
                return `@${config.DUTY_MAPS[channel][command - 0xf5]}`;
            } else if (command == 0xf8) {
                //F8: set sweep ($7f82).
                //FIXME: use pitch envelope to simulate this
                return `K${command_bytes[1]}`;
            } else if (command == 0xF9) {
                //F9: set note defaults?
                // $7f66 = octave = 4
                // $7f90 = volume goal = 8
                // $7fc1 = volume envelope type = 0
                return `O${4 + config.OCTAVE_SHIFT} V${Math.floor(8 * config.VOLUME_MAPS[channel])}`;
            } else if (command == 0xFA) {
                //FA: set note defaults?
                // $7f66 = octave = 5
                // $7f90 = volume goal = 0xF
                // $7fc1 = volume envelope type = 1
                return `O${5 + config.OCTAVE_SHIFT} V${Math.floor(15 * config.VOLUME_MAPS[channel])}`;
            } else if (0xfb <= command && command < 0xff) {
                //FB: enter (initialize) loop.
                //FC: end loop, decrement counter.
                //FD: exit loop, if loop counter is odd.
                //FE: jump.
                //return `!:${command.toString(16)}`;
                return "";
            }
            //FF: end of track.
            return "";
        }
    })(),
    to_format(format, streams) {
        return streams.map(
            (note_stream, k) => {
                const mml_stream = Object.keys(note_stream.commands).reduce((result, rom_addr) => {
                    const command_bytes = note_stream.commands[rom_addr];
                    result.mml[rom_addr] = this.mml.from(
                        k,
                        command_bytes,
                        result.states.last_note,
                        this.mml.default_config
                    );
                    //
                    if (command_bytes < 0xc0) {
                        result.states.last_note = command_bytes[0];
                    }
                    //TODO:
                    //  it is better to move this responsibility to get_native_inputs or like,
                    //  as this actually handling rather 'native' stream's details, not mml's details.
                    //  there still need some tasks here once the abovementioned refactoring done,
                    //  since it's appropriate to do here the management of states of entire resultant mml stream,
                    //  as a driver of underlying mml converter. (which merely handles a mapping of internal expression into mml)
                    // handle loops.
                    if (command_bytes[0] == 0xfb) {
                        //enter loop.
                        result.states.counters[++result.states.loop_index] = command_bytes[1];
                    } else if (command_bytes[0] == 0xfc) {
                        //exit loop.
                        const counter = result.states.counters[result.states.loop_index--];
                        const jump_target = note_stream.map_address(command_bytes[1] | (command_bytes[2] << 8));
                        result.mml[rom_addr] = `${result.mml[rom_addr]} ]${counter}`;
                        result.mml[jump_target] = `[ ${result.mml[jump_target]}`;
                    } else if (command_bytes[0] == 0xfd) {
                        result.mml[rom_addr] = `${result.mml[rom_addr]} |`;
                    } else if (command_bytes[0] == 0xfe) {
                        const jump_target = note_stream.map_address(command_bytes[1] | (command_bytes[2] << 8));
                        result.mml[jump_target] = `\$ ${result.mml[jump_target]}`;
                    }
                    return result;
                }, {
                    mml: {},
                    states: {
                        loop_index: -1,     //$7fa5
                        counters: [0, 0],    //$7fac, $7fb3
                        last_note: null,
                    },
                });

                return [
                    this.mml.default_config.CHANNEL_DEFAULTS[k],
                    ...note_stream.address_trails.map((rom_addr) => mml_stream.mml[rom_addr]),
                ].map((note) => note.toLowerCase()).join(" ");
            }
        ).join(`;\n${'-'.repeat(100)}\n`);
    }
};
