package c2asm.parser;

import c2asm.parser.ParseRule;

class Item{
	public var rule:ParseRule;
	public var position:Int;

	public function new(rule:ParseRule, position:Int){
		this.rule = rule;
		this.position = position;
	}

	public function equals(o:Item):Bool{
		return o.position == position && o.rule == rule;
	}
}