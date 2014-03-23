package c2asm.parser;

class Nonterminal extends Unit{
	public function new(name:String){
		this.name = name;
		unitType = Nonterminal;
	}
}