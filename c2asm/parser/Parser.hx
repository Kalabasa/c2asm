package c2asm.parser;

import c2asm.lexer.Token;
import c2asm.parser.Node;
import c2asm.parser.Terminal;

class Parser{
	public var grammar:ParseGrammar;

	public function new(grammar:ParseGrammar){
		this.grammar = grammar;
	}

	public function parse(tokens:List<Token>):Node{
		var top:Node = new Node(tokens.pop());
		return top;
	}

	private function shift(top:Node, tokens:List<Token>):Void{
		while(top.sibling != null){
			top = top.sibling;
		}
		top.sibling = new Node(tokens.pop());
	}

	private function reduce(top:Node):Void{

	}
}