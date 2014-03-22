package c2asm.parser;

import c2asm.lexer.Token;
import c2asm.parser.Node;

class Parser{
	public var grammar:ParseGrammar;

	public function new(grammar:ParseGrammar){
		this.grammar = grammar;
	}


	public function parse(tokens:List<Token>):Node{
		var subtree:Node = null;
		for(t in tokens){
			var node:Node = new Node(t);
			if(subtree == null){
				subtree = node;
			}else{
				subtree.sibling = node;
			}
		}
		return subtree;
	}
}