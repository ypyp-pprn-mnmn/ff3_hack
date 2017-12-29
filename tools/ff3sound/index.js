'use strict';
const BinaryFile = require('binary-file');

module.exports = {
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
                console.log(`exception while getting input: ${e}`);
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
                console.log(`exception while writing output: ${e}`);
            } finally {

            }
        });
    },
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
        console.log(`track #${track_no} - pointer to stream at ${pp_stream.toString(16)}
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
                const address_queue = [result.start];
                console.log(`channel #${k} - stream begins at ${p.toString(16)} => ${result.start.toString(16)}`);
                
                while (address_queue.length > 0) {
                    let cursor = address_queue.pop();
                    if (!!result.commands[cursor]) {
                        console.log(`address ${cursor.toString(16)} has already parsed.`);
                        continue;
                    }
                    result.address_trails.push(cursor);
                    let note = buffer.readUInt8(cursor);
                    /*
                    if (note == 0xff) {
                        continue;
                    }//*/
                    const command_bytes = (result.commands[cursor++] = []);
                    const len = ((note < 0xe0) ? 0 : this.ADDITIONAL_LENGTH[note - 0xe0]);
                    command_bytes.push(
                        note,
                        ...Array(len).fill(0).map((v, i) => buffer.readUInt8(cursor++))
                    );
                    // parse jump target later, if any.
                    if (0xfc <= note && note < 0xff) {
                        const jump_target = command_bytes[1] | (command_bytes[2] << 8);
                        console.log(`adding jump target for parsing: ${jump_target.toString(16)}`);
                        address_queue.push(map_address(jump_target));
                    }
                    if (0x00 <= note && note < 0xfe) {
                        //0xfe is 'jump always'
                        address_queue.push(cursor);
                    }
                }
                return result;
            });
           
    },
    to_format(format, streams) {
        const PITCH = "C C+ D D+ E F F+ G G+ A A+ B".split(/ +/);
        //           60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01
        const LEN = "1  2. 2  4. 3  4  8. 6  8  16. 12 16 24 32 48 96".split(/ +/);
        const DUTY_MAPS = [
            [1, 2, 4],
            [5, 6, 4],
            [8, 8, 8],
            [9, 9, 9],
            [10, 10, 10],
        ];
        const OCTAVE_SHIFT = 3;
        const CHANNEL_DEFAULTS = [
            `%1 @2 t150 o${OCTAVE_SHIFT + 4} v15`,
            `%1 @3 o${OCTAVE_SHIFT + 4} v15`,
            `%1 @8 o${OCTAVE_SHIFT + 4} v15`,
            `%1 @9 o${OCTAVE_SHIFT + 4} v15`,
            `%1 @10 o${OCTAVE_SHIFT + 4} v15`,
        ];
        return streams.map(
            (note_stream, k) => {
                const mml_stream = Object.keys(note_stream.commands).reduce((result, rom_addr) => {
                    const command_bytes = note_stream.commands[rom_addr];
                    const to_mml = ((command_bytes) => {
                        const command = command_bytes[0];
                        if (command < 0xc0) {
                            //play note.
                            return `${PITCH[command >> 4]}${LEN[command & 0xF]}`;
                        } else if (command < 0xd0) {
                            //rest.
                            return `R${LEN[command & 0xF]}`;
                        } else if (command < 0xe0) {
                            //tie?
                            //return `!:${command.toString(16)}`;
                            return `&${PITCH[result.states.last_note >> 4]}${LEN[command & 0xF]}`;
                        } else if (command == 0xe0) {
                            //tempo.
                            return `T${command_bytes[1]}`;
                        } else if (0xe1 <= command && command < 0xef) {
                            //volume envelopse?
                            return `V${command - 0xe1 + 2}`;
                        } else if (0xEf <= command && command < 0xf5) {
                            //set octave.
                            return `O${command - 0xEF + OCTAVE_SHIFT}`;
                        } else if (0xf5 <= command && command < 0xf8) {
                            //set duty/envelope.
                            return `@${DUTY_MAPS[k][command - 0xf5]}`;
                        } else if (command == 0xf8) {
                            //set sweep.
                            return `K${command_bytes[1]}`;
                        } else if (command == 0xF9) {
                            //set note defaults?
                            return `O${4 + OCTAVE_SHIFT}`;
                        } else if (command == 0xFA) {
                            //set note defaults?
                            return `O${5 + OCTAVE_SHIFT}`;
                        } else if (0xfb <= command && command < 0xff) {
                            //return `!:${command.toString(16)}`;
                            return "";
                        }
                        return "";
                    });
                    result.mml[rom_addr] = to_mml(command_bytes);
                    //
                    if (command_bytes < 0xc0) {
                        result.states.last_note = command_bytes[0];
                    }
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
                    CHANNEL_DEFAULTS[k],
                    ...note_stream.address_trails.map((rom_addr) => mml_stream.mml[rom_addr]),
                ].map((note) => note.toLowerCase()).join(" ");
            }
        ).join(`;\n${'-'.repeat(100)}\n`);
    }
};
