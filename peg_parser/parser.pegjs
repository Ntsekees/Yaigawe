

// ================================================================== //

/*
 *  PEGJS INITIALIZATION CODE
 */

{
  var _g_zoi_delim;

  function _join(arg) {
    if (typeof(arg) == "string")
      return arg;
    else if (arg) {
      var ret = "";
      for (var v in arg) { if (arg[v]) ret += _join(arg[v]); }
      return ret;
    }
  }

  function _node_empty(label, arg) {
    var ret = [];
    if (label) ret.push(label);
    if (arg && typeof arg == "object" && typeof arg[0] == "string" && arg[0]) {
      ret.push( arg );
      return ret;
    }
    if (!arg)
    {
      return ret;
    }
    return _node_int(label, arg);
  }

  function _node_int(label, arg) {
    if (typeof arg == "string")
      return arg;
    if (!arg) arg = [];
    var ret = [];
    if (label) ret.push(label);
    for (var v in arg) {
      if (arg[v] && arg[v].length != 0)
        ret.push( _node_int( null, arg[v] ) );
    }
    return ret;
  }

  function _node2(label, arg1, arg2) {
    return [label].concat(_node_empty(arg1)).concat(_node_empty(arg2));
  }

  function _node(label, arg) {
    var _n = _node_empty(label, arg);
    return (_n.length == 1 && label) ? [] : _n;
  }
  var _node_nonempty = _node;

  // === Functions for faking left recursion === //

  function _flatten_node(a) {
    // Flatten nameless nodes
    // e.g. [Name1, [[Name2, X], [Name3, Y]]] --> [Name1, [Name2, X], [Name3, Y]]
    if (is_array(a)) {
      var i = 0;
      while (i < a.length) {
        if (!is_array(a[i])) i++;
        else if (a[i].length === 0) // Removing []s
          a = a.slice(0, i).concat(a.slice(i + 1));
        else if (is_array(a[i][0]))
          a = a.slice(0, i).concat(a[i], a.slice(i + 1));
        else i++;
      }
    }
    return a;
  }

  function _group_leftwise(arr) {
    if (!is_array(arr)) return [];
    else if (arr.length <= 2) return arr;
    else return [_group_leftwise(arr.slice(0, -1)), arr[arr.length - 1]];
  }

  // "_lg" for "Leftwise Grouping".
  function _node_lg(label, arg) {
    return _node(label, _group_leftwise(_flatten_node(arg)));
  }

  function _node_lg2(label, arg) {
    if (is_array(arg) && arg.length == 2)
      arg = arg[0].concat(arg[1]);
    return _node(label, _group_leftwise(arg));
  }

  // === ZOI functions === //

  function _assign_zoi_delim(w) {
    if (is_array(w)) w = join_expr(w);
    else if (!is_string(w)) throw "ERROR: ZOI word is of type " + typeof w;
    w = w.toLowerCase().replace(/,/gm,"").replace(/h/g, "'");
    _g_zoi_delim = w;
    return;
  }

  function _is_zoi_delim(w) {
    if (is_array(w)) w = join_expr(w);
    else if (!is_string(w)) throw "ERROR: ZOI word is of type " + typeof w;
    /* Keeping spaces in the parse tree seems to result in the absorbtion of
       spaces into the closing delimiter candidate, so we'll remove any space
       character from our input. */
    w = w.replace(/[.\t\n\r?!\u0020]/g, "");
    w = w.toLowerCase().replace(/,/gm,"").replace(/h/g, "'");
    return w === _g_zoi_delim;
  }
	
	// === Stack functions === //

  var _g_stack = [];

  function _push(x) {
    if (is_array(x)) x = join_expr(x);
    else if (!is_string(x)) throw "Invalid argument type: " + typeof x;
    _g_stack.push(x);
    return;
  }

  function _pop() {
    return _g_stack.pop();
  }
	
	  function _peek() {
	  if (_g_stack.length <= 0) return null;
    else return _g_stack[_g_stack.length - 1];
  }
	
	var _g_last_pred_val = null;
	
	function _pop_eq(x) {
    if (is_array(x)) x = join_expr(x);
    else if (!is_string(x)) throw "Invalid argument type: " + typeof x;
    /* Keeping spaces in the parse tree seems to result in the absorbtion of
       spaces into the closing delimiter candidate, so we'll remove any space
       character from our input. */
    x = x.replace(/[.\t\n\r?!\u0020]/g, "");
		l = _g_stack.length;
		y = _peek();
		r = x === y;
		_g_last_pred_val = r;
		if (r) _pop();
    return r;
  }
	
	function _peek_eq(x) {
    if (is_array(x)) x = join_expr(x);
    else if (!is_string(x)) throw "Invalid argument type: " + typeof x;
    /* Keeping spaces in the parse tree seems to result in the absorbtion of
       spaces into the closing delimiter candidate, so we'll remove any space
       character from our input. */
    x = x.replace(/[.\t\n\r?!\u0020]/g, "");
		l = _g_stack.length;
		y = _peek();
		r = x === y;
		_g_last_pred_val = r;
    return r;
  }

	// === MISC === //

  function join_expr(n) {
    if (!is_array(n) || n.length < 1) return "";
    var s = "";
    var i = is_array(n[0]) ? 0 : 1;
    while (i < n.length) {
      s += is_string(n[i]) ? n[i] : join_expr(n[i]);
      i++;
    }
    return s;
  }

  function is_string(v) {
    return Object.prototype.toString.call(v) === '[object String]';
  }

  function is_array(v) {
    return Object.prototype.toString.call(v) === '[object Array]';
  }
}

// ================================================================== //

text = expr:(space? discourse EOF?) {return _node("text", expr);}

discourse = expr:(sentence*) {return _node("discourse", expr);}

sentence = expr:(root_verb_phrase) {return _node("sentence", expr);}

root_verb_phrase = expr:(root_verb_cluster dp*) {return _node("root_verb_phrase", expr);}

sub_verb_phrase = expr:(sub_verb_cluster dp*) {return _node("sub_verb_phrase", expr);}

root_verb_cluster = expr:(root_verb serial_phrase?) {return _node("root_verb_cluster", expr);}

sub_verb_cluster = expr:(stem serial_phrase?) {return _node("sub_verb_cluster", expr);}

root_verb = expr:(stem illocutionary_desinence space freemod*) {return _node("root_verb", expr);}

root_verbal_clause = expr:(subordinator illocutionary_desinence sub_verb_phrase clause_terminator space freemod*) {return _node("root_verbal_clause", expr);}

dp = expr:(determiner? noun_phrase) {return _node("dp", expr);}

noun_phrase = expr:(noun serial_phrase?) {return _node("noun_phrase", expr);}

noun = expr:(stem noun_desinence space freemod*) {return _node("noun", expr);}

noun_clause = expr:(subordinator noun_desinence sub_verb_phrase clause_terminator space freemod*) {return _node("noun_clause", expr);}

serial_phrase = expr:(serial_word serial_word?) {return _node("serial_phrase", expr);}

serial_word = expr:(stem t space freemod*) {return _node("serial_word", expr);}

freemod = expr:(interjection / vocative_phrase) {return _node("freemod", expr);}

vocative_phrase = expr:(vocative dp) {return _node("vocative_phrase", expr);}

interjection = expr:(stem gs space) {return _node("interjection", expr);}

word = expr:(stem desinence space) {return _node("word", expr);}

vocative = expr:(a o space freemod*) {return _node("vocative", expr);}

determiner = expr:(a space freemod*) {return _node("determiner", expr);}

subordinator = expr:((y a / y u / n a) space freemod*) {return _node("subordinator", expr);}

clause_terminator = expr:(l a space freemod*) {return _node("clause_terminator", expr);}

illocutionary_desinence = expr:(s / h / f / y a m / w a m) {return _node("illocutionary_desinence", expr);}

noun_desinence = expr:((n / l / r a m / ch / q)?) {return (expr === "" || !expr) ? ["noun_desinence", "∅"] : _node_empty("noun_desinence", expr);}

stem = expr:(syllable+) {return _node("stem", expr);}

desinence = expr:(consonant?) {return _node("desinence", expr);}

syllable = expr:(consonant vowel) {return _node("syllable", expr);}

consonant = expr:(y / w / r / l / m / n / ng / b / d / j / g / p / t / ch / k / q / gs / f / s / h) {return _node("consonant", expr);}

vowel = expr:(a / e / i / o / u) {return _node("vowel", expr);}

a = expr:([aA]) {return ["a", _join(expr)];}
e = expr:([eE]) {return ["e", _join(expr)];}
i = expr:([ıiI]) {return ["i", _join(expr)];}
o = expr:([oO]) {return ["o", _join(expr)];}
u = expr:([uU]) {return ["u", _join(expr)];}

y = expr:([yY]) {return ["y", _join(expr)];}
w = expr:([wW]) {return ["w", _join(expr)];}
r = expr:([rR]) {return ["r", _join(expr)];}
l = expr:([lL]) {return ["l", _join(expr)];}
m = expr:([mM]) {return ["m", _join(expr)];}
n = expr:([nN]) {return ["n", _join(expr)];}
ng = expr:([ŋŊ]) {return ["ng", _join(expr)];}
b = expr:([bB]) {return ["b", _join(expr)];}
d = expr:([dD]) {return ["d", _join(expr)];}
j = expr:([jJ]) {return ["j", _join(expr)];}
g = expr:([gG]) {return ["g", _join(expr)];}
p = expr:([pP]) {return ["p", _join(expr)];}
t = expr:([tT]) {return ["t", _join(expr)];}
ch = expr:([čČ]) {return ["ch", _join(expr)];}
k = expr:([kK]) {return ["k", _join(expr)];}
q = expr:([qQ]) {return ["q", _join(expr)];}
gs = expr:([ʼ]) {return ["gs", _join(expr)];}
f = expr:([fF]) {return ["f", _join(expr)];}
s = expr:([sS]) {return ["s", _join(expr)];}
h = expr:([hH]) {return ["h", _join(expr)];}

//___________________________________________________________________

digit = expr:([0123456789]) {return _node("digit", expr);}

post_word = expr:(pause / word) {return _node("post_word", expr);}

pause = expr:(space_char+ / EOF) {return _node("pause", expr);}

EOF = expr:(!.) {return _node("EOF", expr);}


non_space = expr:(!space_char .) {return _join(expr);}

space_char = expr:([.\t\n\r?!\u0020]) {return _node("space_char", expr);}


//___________________________________________________________________

space = expr:(space_char+ EOF? / EOF) {return _node("space", expr);}

//___________________________________________________________________

// A <- &cmavo ( a / e / j i / o / u ) &post_word

