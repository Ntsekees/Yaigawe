Yaıgawe PEG parser
=========

The Yaıgawe PEG parser is a work in progress surface syntax parsers for the Yaıgawe language, as well as related tools and interfaces.

The interfaces to the parser are:
* `parser.html`: HTML interface with various parsing options and allowing selecting the desired parser.
* `run_parser.js`: Command line interface.


### Requirements ###

For generating a PEGJS grammar engine from its PEG grammar file, as well as for running the IRC bot interfaces, you need to have [Node.js](https://nodejs.org/) installed on your machine.

For generating a PEGJS engine, you need to have [the Node.js module `pegjs`](http://pegjs.org/) installed in the directory, which you can achieve with the command line `npm install pegjs`.



### Building a PEGJS parser ###

For building the parser (`parser.js`) from the `parser.peg` grammar file, you need to use the following command:
```
node build-parser parser.peg
```


### Running a parser from command line ###

Here's how to parse the Yaıgawe text "lunus a tulu" with the grammar parser from command line:

```
node run_parser "lunus a tulu"
```

The standard grammar parser is used by default, but another grammar engine can be specified.
* The `-std` flag selects the standard grammar engine.
* `-p PATH` can be used for selecting a parser by giving its file path as a command line argument.

Additionally, `-m MODE` can be used to specify output postprocessing options.
Here, MODE can be any letter string, each letter standing for a specific option.
Here is the list of possible letters and their associated meaning:
* M -> Keep morphology
* S -> Show spaces
* C -> Show word classes
* T -> Show terminators
* N -> Show main node labels
* R -> Raw output, do not prune the tree, except the morphology if 'M' not present.
* J -> JSON output
* G -> Replace words by glosses
* L -> Run the parser in a loop, consume every input line terminated by a newline and output parsed result
* L -> A second 'L' means that run_parser will expect every input line to begin with a mode string (possibly empty) followed by a space, after which the actual input follows.

Example:
```
node run_parser -m CTN "lunus a tulu"
```
This will show terminators, word classes and main node labels.
 
