package c2asm.parser;

import c2asm.lexer.Token;

class Node{
	public var child:Node = null;
	public var sibling:Node = null;
	public var data:Token;

	public function new(data:Token){
		this.data = data;
	}
}