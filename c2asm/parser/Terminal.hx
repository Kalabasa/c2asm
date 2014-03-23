package c2asm.parser;

class Terminal extends Unit{
	public function new(name:String){
		this.name = name;
		unitType = Terminal;
	}
}