CodeMirror.defineMode("insyntax", function() {

		
	var TOKENS = [
	          
	    // name				start		end			collision
	      
		["default"		, 	[""			, "" ]					],        
		["strike"		, 	["="		, "="]					],
		["glyph"		, 	["("		, ")"]					],
		["unsure"		, 	[" "		, "?"]					],
		["superscript"	, 	["["		, "]"]					],
		["linebreak"	, 	["/"		, "" ]					],
		["pagebreak"	, 	["//"		, "" ]					]
		
	];
	
	// default
	var defaultForbidden = /[\]\)\?]/;
	
	var TOKEN_ERROR = "error";
	
	// strike
	var TOKEN_STRIKESTART = "strikestart";
	var TOKEN_STRIKEIN = "strikein";
	var TOKEN_STRIKEEND = "strikeend";
	var strikeForbidden = defaultForbidden;
	
	// glyph
	var TOKEN_GLYPHSTART = "glyphstart";
	var TOKEN_GLYPHIN = "glyphin";
	var TOKEN_GLYPHEND = "glyphend";
	var glyphForbidden = /[\s\?\(\)\[\]\/]/;
	
	// unsure
	var TOKEN_UNSURESTART = "unsurestart";
	var TOKEN_UNSUREIN = "unsurein";
	var TOKEN_UNSUREEND = "unsureend";
	var unsureCollision = /^[^\s\?=\[]+\?[\]=]?(\s|\/|\+|-)/;
	var unsureInSuperscriptCollision = /^[^\s\]=]+\?(\s|\]|\+|-)/;
	var unsureInStrikeCollision = /^[^\s=\[]+\?(\s|=|\+|-)/;
	var unsureForbidden = /[\/\]\)=\[]/;
	
	// superscript
	var TOKEN_SUPERSCRIPTSTART = "superscriptstart";
	var TOKEN_SUPERSCRIPTIN = "superscriptin";
	var	TOKEN_SUPERSCRIPTEND = "superscriptend";
	var superscriptForbidden = /[\/\)\[\?]/;
	
	// line-break and page-break (stand-alone)
	var TOKEN_LINEBREAK = "linebreak";
	var TOKEN_PAGEBREAK = "pagebreak";
	
	// regular expressions
	var syntaxComplete = "";
	var isNotSyntax = /[^\(]/;
	// keep parallel to service check-forbidden-input 
	// '=' should be added here
	// '&lt;' and '&gt;' should be decoded here
	var notAllowedChars = /[^a-zA-Z0-9\s\[\]\(\)?\/.½{}<>=]/;
	
	function style(state, style, isStart) {
		
		var tmp;
		if(isStart) tmp = state.stack.pop();
		var overlayStyle = state.stack.join(" ") + " " + style;
		if(isStart) state.stack.push(tmp);
		return overlayStyle;
	}
	
	function pushState(state, node) {
		
		state.tokenize = eval(node);
		state.stack.push(node);
		// console.log("Push: " + state.stack);
	}
	
	function popState(state) {
		
		state.stack.pop();
		state.tokenize = eval(state.stack[state.stack.length - 1]);
		// console.log("Pop: " + state.stack);
	}
	
	function caseForbiddenChar(ch) {
		
		return ch.match(notAllowedChars, false, true);
	}
	
	function change(state, actual, change) {
		
		var isStart = change == null ? false : true;
		if(change) pushState(state, change);
		return style(state, actual, isStart);
	}
	
	function defaultin(stream, state) {

		var sol = stream.sol();
		var ch = stream.next();
		// not allowed char?
		if (ch.match(notAllowedChars, false, true)) return TOKEN_ERROR;
		// starting point of a new stand-alone node
		else if (ch == "/") {
			if(stream.match("/")) return change(state, TOKEN_PAGEBREAK, null);
			else return change(state, TOKEN_LINEBREAK, null);
		}
		// starting point of a new node
		else if (ch == '=') {
			if(stream.match(unsureInStrikeCollision, false)) {
				state.stack.push(TOKEN_STRIKEIN);
				return change(state, TOKEN_STRIKESTART, TOKEN_UNSUREIN);
			}
			else
				return change(state, TOKEN_STRIKESTART, TOKEN_STRIKEIN);
		}
		else if (ch == "(") return change(state, TOKEN_GLYPHSTART, TOKEN_GLYPHIN);
		else if (ch == "[") {
			if(stream.match(unsureInSuperscriptCollision, false)) {
				state.stack.push(TOKEN_SUPERSCRIPTIN);
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_UNSUREIN);
			}
			else 
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_SUPERSCRIPTIN);
		}
		else if ((ch == " " || sol) && !stream.match(/^=?\[/, false)) {
			if(stream.match(unsureCollision, false)) {
				if(sol) stream.backUp(1);
				return change(state, TOKEN_UNSURESTART, TOKEN_UNSUREIN);
			}
			else return null;
		}
		// forbidden syntax
		else if(defaultForbidden.test(ch)) {
			stream.skipToEnd();
			return TOKEN_ERROR;
		}
		else return null;
	}
	
	function unsurein(stream, state) {

		var ch = stream.next();
		// not allowed char?
		if (ch.match(notAllowedChars, false, true)) return change(state, TOKEN_ERROR, null);
		// did we reach the end of this node?
		else if (ch == "?") {
			popState(state);
			return change(state, TOKEN_UNSUREEND, null);
		}
		// starting point of a new node?
		else if (ch == "(") return change(state, TOKEN_GLYPHSTART, TOKEN_GLYPHIN);
		// forbidden syntax
		else if(unsureForbidden.test(ch)) {
			stream.skipToEnd();
			return TOKEN_ERROR;
		}
		else return change(state, TOKEN_UNSUREIN, null);
	}
	
	function superscriptin(stream, state) {
		
		var ch = stream.next();
		// not allowed char?
		if (ch.match(notAllowedChars, false, true)) return TOKEN_ERROR;
		// did we reach the end of this node?
		else if (ch == "]") {
			popState(state);
			return change(state, TOKEN_SUPERSCRIPTEND, null);
		}		
		else if (ch == "[") {
			if(stream.match(unsureInSuperscriptCollision, false)) {
				state.stack.push(TOKEN_SUPERSCRIPTIN);
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_UNSUREIN);
			}
			else 
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_SUPERSCRIPTIN);
		}
		// starting point of a new node?
		else if (ch == '=') return change(state, TOKEN_STRIKESTART, TOKEN_STRIKEIN);
		else if (ch == "(") return change(state, TOKEN_GLYPHSTART, TOKEN_GLYPHIN);
		else if (ch == " ") {
			if(stream.match(unsureCollision, false)) 
				return change(state, TOKEN_UNSURESTART, TOKEN_UNSUREIN);
			else return null;
		}
		// forbidden syntax
		else if(superscriptForbidden.test(ch)) {
			stream.skipToEnd();
			return TOKEN_ERROR;
		}
		else return change(state, TOKEN_SUPERSCRIPTIN, null);
	}
	
	function glyphin(stream, state) {
		
		var ch = stream.next();
		// not allowed char?
		if (ch.match(notAllowedChars, false, true)) return change(state, TOKEN_ERROR, null);
		// did we reach the end of this node?
		else if (ch == ")") {
			popState(state);
			return change(state, TOKEN_GLYPHEND, null);
		}
		// forbidden syntax
		else if(glyphForbidden.test(ch)) {
			stream.skipToEnd();
			return TOKEN_ERROR;
		}
		else return style(state, TOKEN_GLYPHIN);
	}
	
	function strikein(stream, state) {

		var sol = stream.sol();
		var ch = stream.next();
		// not allowed char?
		if (ch.match(notAllowedChars, false, true)) return style(state, TOKEN_ERROR);
		// did we reach the end of this node?
		else if (ch == '=') {
			popState(state);
			return change(state, TOKEN_STRIKEEND, null);
		}
		// starting point of a new stand-alone node
		else if (ch == "/") {
			if(stream.match("/")) return change(state, TOKEN_PAGEBREAK, null);
			else return change(state, TOKEN_LINEBREAK, null);
		}
		// starting point of a new node
		else if (ch == "(") return change(state, TOKEN_GLYPHSTART, TOKEN_GLYPHIN);
		else if (ch == "[") {
			if(stream.match(unsureInSuperscriptCollision, false)) {
				state.stack.push(TOKEN_SUPERSCRIPTIN);
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_UNSUREIN);
			}
			else 
				return change(state, TOKEN_SUPERSCRIPTSTART, TOKEN_SUPERSCRIPTIN);
		}
		else if ((ch == " " || sol) && !stream.match(/^=?\[/, false)) {
			if(stream.match(unsureCollision, false)) {
				if(sol) stream.backUp(1);
				return change(state, TOKEN_UNSURESTART, TOKEN_UNSUREIN);
			}
			else return change(state, TOKEN_STRIKEIN, null);
		}
		// forbidden syntax
		else if(strikeForbidden.test(ch)) {
			stream.skipToEnd();
			return TOKEN_ERROR;
		}
		else return change(state, TOKEN_STRIKEIN, null);
	}
	
	return {
		
		startState: function() {
			return {
				tokenize: defaultin,
				stack: ["defaultin"]
			};
		},
		
		token: function(stream, state) {
			
			var style = state.tokenize(stream, state);
			return style;
		}
	};
});

CodeMirror.defineMIME("text/insyntax", "insyntax");
