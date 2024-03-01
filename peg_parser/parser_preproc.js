function parser_preprocessing(input) {
	if (!(typeof input.valueOf() === 'string'))
		return "ERROR: Wrong input type.";
	input = input.replace(/’/gm,"'");
	input = input.replace(/\(|\)|«|»|‹|›|—|:/gm,"");
	return input;
}

if (typeof module !== 'undefined')
    module.exports.preprocessing = parser_preprocessing;

