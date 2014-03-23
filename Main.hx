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
		var lg:LexiGrammar = loadLexiGrammar('c-tokens');

		// Tokenize
		var l:Lexer = new Lexer(lg);
		var tokens:List<Token> = l.tokenize(str);
		if(tokens != null){
			for(t in tokens){
				trace(t.type + ' ' + t.data);
			}
		}

		// Load grammatical rules
		var pg:ParseGrammar = loadParseGrammar('c-grammar');

		// Parse
		var p:Parser = new Parser(pg);
		var root:Node = p.parse(tokens);
		if(root != null){
			trace('\n' + printTree(root));
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
		var start:String = null;
		var currentPre:String = null;
		var currentPost:Array<String> = null;
		try{
			while(!fin.eof()){
				var line:String = fin.readLine();
				if(line.length == 0 || line.charAt(0) == '#'){
					continue;
				}
				var s:Array<String> = ws.split(line);
				if(s[0].length > 0){
					if(s.length == 1){
						currentPre = s[0];
					}else if(s.length == 2){
						if(s[0] == 'start'){
							start = s[1];
						}
					}
				}else{
					currentPost = new Array<String>();
					for(i in 1...s.length){
						currentPost.push(s[i]);
					}
					pg.addRuleStr(currentPre, currentPost);
				}
			}
		}catch(e:Dynamic){}
		fin.close();

		pg.setStartStr(start);

		return pg;
	}

	static public function printTree(root:Node, prefix0:String = '', prefix:String = ''):String{
		var out:String = prefix0 + (root.data == null ? root.unit.name : root.data.type + ' \'' + root.data.data + '\'') + '\n';

		var p:Node = root.child;
		while(p != null){
			out += printTree(p, prefix + (p.sibling == null ? '\\' : '|') + '_. ', prefix + (p.sibling == null ? ' ' : '|') + ' ');
			p = p.sibling;
		}
		return out;
	}
}