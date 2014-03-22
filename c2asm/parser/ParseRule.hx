package c2asm.parser;

class ParseRule{
	public var pre:String;
	public var post:List<String>;

	public function new(pre:String, post:List<String>){
		this.pre = pre;
		this.post = post;
	}
}