package c2asm.lexer;

class LexiRule{
	public var name:String;
	public var regex:String;
	public var ignore:Bool;

	public function new(name:String, regex:String, ignore:Bool=false){
		this.name = name;
		this.regex = regex;
		this.ignore = ignore;
	}
}