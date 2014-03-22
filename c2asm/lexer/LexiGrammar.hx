package c2asm.lexer;

import sys.io.FileInput;

class LexiGrammar{
	public var rules:List<LexiRule>;

	public function new(){
		rules = new List<LexiRule>();
	}
}