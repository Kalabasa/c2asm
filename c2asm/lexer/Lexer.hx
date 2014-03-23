package c2asm.lexer;

import c2asm.lexer.LexiGrammar;
import c2asm.lexer.Token;

class Lexer{
	public var grammar:LexiGrammar;

	public function new(grammar:LexiGrammar){
		this.grammar = grammar;
	}

	public function tokenize(string:String):List<Token>{
		var tokens:List<Token> = new List<Token>();
		var pos:Int = 0;

		while(string.length > 0){
			var matched:Bool = false;
			for(rule in grammar.rules){
				var regex:EReg = new EReg('\\A' + rule.regex, 'm');
				if(regex.match(string)){
					var data:String = regex.matched(0);
					if(data.length > 0){
						if(!rule.ignore){
							var token:Token = new Token(rule.name, data);
							tokens.add(token);
						}

						pos += data.length;
						string = regex.matchedRight();

						matched = true;
						break;
					}
				}
			}

			if(!matched){
				throw 'Lexical error at ' + pos + ':' + string.substring(0, 10);
				return null;
			}
		}

		return tokens;
	}	
}