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
		var p:Node = null;
		for(t in tokens){
			var node:Node = new Node(t);
			if(subtree == null){
				p = subtree = node;
			}
			p = p.sibling = node;
		}
		return subtree;
	}
}