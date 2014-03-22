package c2asm.lexer;

class Token{
	public var type:String;
	public var data:String;

	public function new(type:String, data:String){
		this.type = type;
		this.data = data;
	}
}