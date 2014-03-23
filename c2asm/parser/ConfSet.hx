package c2asm.parser;

import c2asm.parser.Item;
import c2asm.parser.ParseGrammar;

class ConfSet{
	public var grammar:ParseGrammar;
	public var items:List<Item>;

	public var successors:Map<Unit, ConfSet>;

	public function new(grammar:ParseGrammar, start:Item = null){
		this.grammar = grammar;

		items = new List<Item>();
		if(start != null){
			addItem(start);
		}

		successors = new Map<Unit, ConfSet>();
	}

	public function addItem(item:Item):Bool{
		if(contains(item)){
			return false;
		}
		items.add(item);
		closure(item);
		return true;
	}

	private function closure(item:Item):Void{
		var next:Unit = item.rule.post[item.position];
		if(next != null && next.unitType == Nonterminal){
			for(r in grammar.rules){
				if(r.pre == next){
					var n:Item = new Item(r, 0);
					if(!contains(n)){
						items.add(n);
						if(r.post[0] != next){
							closure(n);
						}
					}
				}
			}
		}
	}

	public function contains(item:Item):Bool{
		for(i in items){
			if(i.equals(item)){
				return true;
			}
		}
		return false;
	}

	public function equals(o:ConfSet):Bool{
		if(o.grammar != grammar){
			return false;
		}
		for(i in o.items){
			if(!contains(i)){
				return false;
			}
		}
		for(i in items){
			if(!o.contains(i)){
				return false;
			}
		}
		return true;
	}
}