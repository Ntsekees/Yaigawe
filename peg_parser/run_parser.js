/*
 * USAGE:
 *   $ nodejs run_parser -PARSER_ID -m MODE TEXT
 * OR
 *   $ nodejs run_parser -PARSER_ID -m MODE -t TEXT
 * OR
 *   $ nodejs run_parser -p PARSER_PATH -m MODE TEXT
 * OR
 *   $ nodejs run_parser -p PARSER_PATH -m MODE -t TEXT
 * 
 * PARSER_PATH and TEXT being the path of the desired parser engine, and the
 * Lojban text to be parsed, respectively.
 * 
 * Possible values for PARSER_ID:
 *    "std", "beta", "cbm", "ckt", "exp", "morpho"
 * 
 * MODE can be any letter string, each letter stands for a specific option.
 * Here is the list of possible letters and their associated meaning:
 *    'M' -> Keep morphology
 *    'S' -> Show spaces
 *    'T' -> Show terminators
 *    'C' -> Show word classes (selmaho)
 *    'R' -> Raw output, do not trim the parse tree. If this option isn't set,
 *           all the nodes (with the exception of those saved if the 'N' option
 *           is set) are pruned from the tree.
 *    'N' -> Show main node labels
 *    'L' -> Loop. Second 'L' for specifying the mode in the first word.
 * Example:
 *    -m CTN
 *    This will show terminators, selmaho and main node labels.
 */

var parser_preproc = require('./parser_preproc.js');
var parser_postproc = require('./parser_postproc.js');

var engine_path = "./parser.js";
var mode = "";
var text = "";

var target = '-t';
var p = [["-std","./parser.js"],["-beta","./parser-beta.js"],["-cbm","./parser-beta-cbm.js"],
          ["-ckt","./parser-beta-cbm-ckt.js"],["-exp","./parser-exp.js"],["-morpho","./parser-morpho.js"]];

for (var i = 2; i < process.argv.length; i++) {
    if (process.argv[i].length > 0) {
        var a = process.argv[i];
        if (a[0] == '-') {
            for (j = 0; j < p.length; j++) {
                if (p[j][0] == a) {
                    engine_path = p[j][1];
                    target = '-t';
                    break;
                }
            }
            if (j == p.length)
                target = a;
        } else {
            switch (target) {
                case '-t':
                    text = a;
                    break;
                case '-p':
                    engine_path = a;
                    break;
                case '-m':
                    mode = a;
            }
            target = '-t';
        }
    }
}

if (engine_path.length > 0 && !(engine_path[0] == '/' || engine_path.substring(0, 2) == './'))
    engine_path = './' + engine_path;

try {
    var engine = require(engine_path);
} catch (err) {
    process.stdout.write(err.toString() + '\n');
    process.exit();
}
var mode_loop = among_count('L', mode);
if (mode_loop) {
    mode = mode.replace('L','');
    if (text != "") {
        process.stdout.write(run_parser(text, mode, engine) + '\n');
    }
    run_parser_loop(mode, engine);
} else {
    process.stdout.write(run_parser(text, mode, engine) + '\n');
    process.exit();
}

// ================================ //

async function run_parser_loop(mode, engine) {
    const mode_reset = among_count('L', mode);
    const readline = require('readline')
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
        prompt: '> '
    });
    rl.prompt();

    rl.on('line', (line) => {
        if (mode_reset) {
            mode = line.substr(0, line.indexOf(' '));
            line = line.substr(line.indexOf(' ') + 1);
        }
        ret = run_parser(line, mode, engine);
        process.stdout.write(run_parser(line, mode, engine)+ '\n');
        rl.prompt();
    }).on('close', () => {
        process.stdout.write("\nco'o\n");
        process.exit();
    });
}

// ================================ //

function run_parser(input, mode, engine) {
	var result;
	var syntax_error = false;
	result = parser_preproc.preprocessing(input);
	try {
        result = engine.parse(result);
	} catch (e) {
        var location_info = ' Location: [' + e.location.start.offset + ', ' + e.location.end.offset + ']';
        location_info += ' …' + input.substring(e.location.start.offset, e.location.start.offset + 12) + '…';
		result = e.toString() + location_info;
		syntax_error = true;
	} finally {
        if (!syntax_error)
            result = parser_postproc.postprocessing(result, mode);
        return result;
    }
}


function among_count(v, s) {
    var i = 0;
    var ret = 0;
    while (i < s.length) {
        if (s[i++] == v) ret = ret + 1;
    }
    return ret;
}

