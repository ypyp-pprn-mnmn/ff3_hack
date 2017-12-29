'use strict';
const BinaryFile = require('binary-file');

module.exports = {
    ADDITIONAL_LENGTH: [
        1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,
        0, 0, 0, 0,  0, 2, 2, 2,  1, 0, 0, 1,  0, 0, 0, 0,
    ],
    TRACK_BOUNDARIES: [
        0,
        0x19,
        0x2b,
        0x37,
        0x3b,
        0xff
    ],
    OFFSET_TO_TABLE: [
        (0x37 << 13) | (0xA000),
        (0x38 << 13) | (0xA000),
        (0x39 << 13) | (0x8C77),
        (0x3a << 13) | (0xB3AE),
        (0x09 << 13) | (0xB400)
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
        get_input_buffer().then((buffer) => {
            const out_buffer =
                this.to_format(
                    format,
                    this.get_native_stream(track_no, buffer)
                );
            try {
                require('fs').writeFile(output, out_buffer, "utf8", (error) => {
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
        const p_stream = this.OFFSET_TO_TABLE[
            this.TRACK_BOUNDARIES.findIndex((bound) => track_no > bound)];
        if (typeof p_stream === 'undefined') {
            throw `eighter track_no or input_file is wrong. track_no=${track_no}`;
        }
        //const pointers = 
        return Array(5).fill(0)
            .map((v, i) => buffer.readUInt16LE(p_stream + i * 2))
            .filter((p) => p != 0xffff)
            .map((p) => {
                const result = [];
                var cursor = (p & 0x1fff) | (p_stream & 0xa000);
                var note;
                while ((note = buffer.readUInt8(cursor++)) != 0xff) {
                    const len = ((note < 0xe0) ? 0 : this.ADDITIONAL_LENGTH[note - 0xe0]);
                    result.push([
                        note,
                        ...Array(len).fill(0).map((v, i) => buffer.readUInt8(cursor++))
                    ]);
                }
                //return buffer.slice(p, cursor);
                return result;
            });
           
    },
    to_format(format, streams) {
        const PITCH = "C C# D D# E F F# G G# A A# B".split(/ +/);
        //           60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01
        const LEN = "1  2. 2  4. 3  4  8. 6  8  16. 12 16 24 32 48 96".split(/ +/);
        return streams.map(
            (note_stream) =>
                note_stream.map((command_bytes) => {
                    const command = command_bytes[0];
                    if (command < 0xc0) {
                        return `${PITCH[command >> 4]}${LEN[command & 0xF]}`;
                    } else if (command < 0xd0) {
                        return `R${LEN[command & 0xF]}`;
                    } else if (command == 0xe0) {
                        return `T${command_bytes[1]}`;
                    } else if (0xEf <= command && command < 0xf5) {
                        return `O${command - 0xEF}`;
                    }
                }).join(" ")
        ).join(`\n${'-'.repeat(100)}\n`);
    }
};
