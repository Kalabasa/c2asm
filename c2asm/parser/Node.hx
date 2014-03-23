package c2asm.parser;

import c2asm.lexer.Token;

class Node{
	public var parent:Node = null;
	public var child:Node = null;
	public var sibling:Node = null;

	public var data:Token;
	public var unit:Unit;

	public function new(data:Token, unit:Unit){
		this.data = data;
		this.unit = unit;
	}
}