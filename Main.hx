import c2asm.lexer.Lexer;
import c2asm.lexer.LexiGrammar;
import c2asm.lexer.LexiRule;
import c2asm.lexer.Token;
import c2asm.parser.Node;
import c2asm.parser.ParseGrammar;
import c2asm.parser.Parser;
import c2asm.parser.ParseRule;
import sys.io.File;
import sys.io.FileInput;

class Main{
	public static function main(){
		// Load source code
		var cFin:FileInput = File.read('test.c', false);
		var str:String = '';
		try{
			while(!cFin.eof()){
				str += cFin.readLine() + '\n';
			}
		}catch(e:Dynamic){}
		cFin.close();

		// Load lexical rules
		var lg:LexiGrammar = loadLexiGrammar('tokens');

		// Tokenize
		var l:Lexer = new Lexer(lg);
		var tokens:List<Token> = l.tokenize(str);
		if(tokens != null){
			trace('');
			trace('Tokens-------------------------------------');
			trace('');
			for(t in tokens){
				trace(t.type + ' ' + t.data);
			}
		}

		// Load grammatical rules
		var pg:ParseGrammar = loadParseGrammar('grammar');
		trace('');
		trace('Rules-----------------------------------------');
		trace('');
		for(r in pg.rules){
			trace(r.pre);
			for(post in r.post){
				trace('\t' + post);
			}
		}

		// Parse
		var p:Parser = new Parser(pg);
		var root:Node = p.parse(tokens);
		while(root != null){
			trace(root.data.type + ' ' + root.data.data);
			root = root.sibling;
		}
	}

	public static function loadLexiGrammar(filename:String):LexiGrammar{
		var lg:LexiGrammar = new LexiGrammar();

		var fin:FileInput = File.read(filename, false);
		var ws:EReg = ~/\s+/g;
		try{
			while(!fin.eof()){
				var line:String = fin.readLine();
				if(line.length == 0 || line.charAt(0) == '#'){
					continue;
				}
				var s:Array<String> = ws.split(line);
				lg.rules.add(new LexiRule(s[0], s[1], s.length > 2 && s[2] == 'ignore'));
			}
		}catch(e:Dynamic){}
		fin.close();

		return lg;
	}

	public static function loadParseGrammar(filename:String):ParseGrammar{
		var pg:ParseGrammar = new ParseGrammar();

		var fin:FileInput = File.read(filename, false);
		var ws:EReg = ~/\s+/g;
		var currentPre:String = null;
		var currentPost:List<String> = null;
		try{
			while(!fin.eof()){
				var line:String = fin.readLine();
				if(line.length == 0 || line.charAt(0) == '#'){
					continue;
				}
				var s:Array<String> = ws.split(line);
				if(s[0].length > 0){
					currentPre = s[0];
				}else{
					currentPost = new List<String>();
					for(i in 1...s.length){
						currentPost.add(s[i]);
					}
					pg.rules.add(new ParseRule(currentPre, currentPost));
				}
			}
		}catch(e:Dynamic){}
		fin.close();

		return pg;
	}
}