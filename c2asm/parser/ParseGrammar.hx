package c2asm.parser;

import c2asm.parser.Nonterminal;
import c2asm.parser.ParseRule;
import c2asm.parser.Terminal;

class ParseGrammar{
	public var rules:List<ParseRule>;
	public var start:Nonterminal = null;
	public var trie:TrieNode<ParseRule>;

	public function new(){
		rules = new List<ParseRule>();
		trie = new TrieNode<ParseRule>();
	}

	public function addRuleStr(pre:String, post:Array<String>):Void{
		addNonterminal(pre);
		var preUnit:Nonterminal = cast findUnit(pre);
		if(preUnit == null){
			preUnit = new Nonterminal(pre);
		}

		var postUnits:Array<Unit> = new Array<Unit>();
		for(s in post){
			var u:Unit = findUnit(s);
			if(u == null){
				if(s == pre){
					u = preUnit;
				}else{
					u = new Terminal(s);
				}
			}
			postUnits.push(u);
		}

		var rule:ParseRule = new ParseRule(preUnit, postUnits);
		rules.add(rule);

		var p:TrieNode<ParseRule> = trie;
		trace(rule.toString());
		for(i in 0...post.length-1){
			var s:String = post[i];
			p = p.get(s) == null ? p.set(s) : p.get(s);
		}
		p.set(post[post.length-1], rule);
	}

	public function setStartStr(start:String):Void{
		addNonterminal(start);
		this.start = cast findUnit(start);
	}

	public function findUnit(name:String):Unit{
		for(r in rules){
			if(r.pre.name == name){
				return r.pre;
			}else{
				for(u in r.post){
					if(u.name == name){
						return u;
					}
				}
			}
		}
		return null;
	}

	private function addNonterminal(name:String):Void{
		var nonterminal:Nonterminal = null;
		for(r in rules){
			if(r.pre.name == name){
				if(r.pre.unitType != Nonterminal){
					r.pre = nonterminal == null ? (nonterminal = new Nonterminal(name)) : nonterminal;
				}
			}else{
				for(i in 0...r.post.length){
					var u:Unit = r.post[i];
					if(u.name == name){
						if(u.unitType != Nonterminal){
							r.post[i] = nonterminal == null ? (nonterminal = new Nonterminal(name)) : nonterminal;
						}
					}
				}
			}
		}
	}
}