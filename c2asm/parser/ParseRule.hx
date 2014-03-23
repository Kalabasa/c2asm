package c2asm.parser;

import c2asm.parser.Nonterminal;
import c2asm.parser.Unit;

class ParseRule{
	public var pre:Nonterminal;
	public var post:Array<Unit>;

	public function new(pre:Nonterminal, post:Array<Unit>){
		this.pre = pre;
		this.post = post;
	}

	public function toString():String{
		var out:String = pre.name + ' ->';
		for(u in post){
			out += ' ' + u.name;
		}
		return out;
	}
}