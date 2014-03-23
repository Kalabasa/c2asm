package c2asm.parser;
using Lambda;

import c2asm.lexer.Token;
import c2asm.parser.ConfSet;
import c2asm.parser.Item;
import c2asm.parser.Node;
import c2asm.parser.Nonterminal;
import c2asm.parser.ParseRule;
import c2asm.parser.Terminal;
import de.polygonal.ds.ListSet;
import de.polygonal.ds.Set;

class Parser{
	public var grammar:ParseGrammar;

	private var sets:List<ConfSet>;
	private var start:Nonterminal;
	private var state:ConfSet;

	private var firsts:Map<Nonterminal, Set<Terminal>>;
	private var follows:Map<Nonterminal, Set<Terminal>>;

	private var head:Node = null;
	private var tail:Node = null;
	private var tokens:List<Token>;

	private static var nullTerm:Terminal = new Terminal(null);

	public function new(grammar:ParseGrammar){
		this.grammar = grammar;

		sets = new List<ConfSet>();
		generateSets();

		firsts = new Map<Nonterminal, Set<Terminal>>();
		follows = new Map<Nonterminal, Set<Terminal>>();
	}

	public function parse(tokens:List<Token>):Node{
		// return null;
		this.tokens = tokens;
	
		// create dummy nodes
		head = new Node(null, null);
		tail = new Node(null, null);
		head.sibling = tail;
		tail.parent = head;

		// state stack
		var stack:List<ConfSet> = new List<ConfSet>();
		stack.push(state);

		while(true){
			var reduced:Bool = false;
			var top:ConfSet = stack.first();
			// find reductions
			for(i in top.items){
				if(i.position == i.rule.post.length){
					if(i.rule.pre == start){
						if(tokens.isEmpty()){
							// accept
							tail.parent.sibling = null;
							head.sibling.parent = null;
							return head.sibling;
						}
					}else{
						if(follow(i.rule.pre).exists(function(t:Terminal):Bool{
								return tokens.isEmpty() ? (t == nullTerm) : (tokens.first().type == t.name);
							})){
							// reduce
							reduce(i.rule);
							reduced = true;

							for(c in 0...i.rule.post.length){
								stack.pop();
							}
							var next:ConfSet = stack.first().successors.get(i.rule.pre);
							if(next == null){
								stateError(stack.first());
								return null;
							}
							stack.push(next);

							break;
						}
					}
				}
			}
			// shift if no reduction
			if(!reduced){
				if(tokens.isEmpty()){
					throw 'Syntax error. Unexpected end of file.';
				}
				var next:ConfSet = top.successors.get(grammar.findUnit(tokens.first().type));
				if(next == null){
					stateError(top);
					return null;
				}
				stack.push(next);
				shift();
			}

			var p:Node = head.sibling;
			while(p != tail){
				p = p.sibling;
			}
		}
		return null;
	}

	private function stateError(set:ConfSet):Void{
		var expectList:List<String> = new List<String>();
		for(k in set.successors.keys()){
			expectList.add(k.name);
		}
		var msg:String = 'Syntax error at 0: . \n\nExpecting one of the following: ' + expectList.join('\n');
		throw msg;
	}

	private function shift():Void{
		var next:Token = tokens.pop();

		// add node
		var node:Node = new Node(next, grammar.findUnit(next.type));
		node.sibling = tail;
		node.parent = tail.parent;
		node.sibling.parent = node;
		node.parent.sibling = node;
	}

	private function reduce(rule:ParseRule):Void{

		// check
		var begin:Node = tail.parent;
		for(i in 1...rule.post.length){
			begin = begin.parent;
		}

		var p:Node = begin;
		for(u in rule.post){
			if(p.unit.name != u.name){
				return;
			}
			p = p.sibling;
		}

		// replace nodes
		var node:Node = new Node(null, rule.pre);
		node.sibling = tail;
		node.parent = begin.parent;
		node.child = begin;
		tail.parent.sibling = null;
		node.sibling.parent = node;
		node.parent.sibling = node;
		node.child.parent = node;
	}

	private function generateSets():Void{
		var du:Unit;
		var name:String = '';
		do{
			name += '_';
			du = grammar.findUnit(name);
		}while(du != null);
		start = new Nonterminal(name);

		var startRule:ParseRule = new ParseRule(start, [grammar.start]);
		state = new ConfSet(grammar, new Item(startRule, 0));
		sets.add(state);
		generateSuccessors(state);
	}

	private function generateSuccessors(set:ConfSet):Void{
		var units:List<Unit> = new List<Unit>();
		for(i in set.items){
			var u:Unit = i.rule.post[i.position];
			if(!units.exists(function(unit:Unit):Bool{ return u == unit; })){
				units.add(u);
			}
		}
		for(u in units){
			var succ:ConfSet = successor(set, u);
			if(succ != null){
				var old:Bool = false;
				for(s in sets){
					if(s.equals(succ)){
						succ = s;
						old = true;
						break;
					}
				}
				set.successors.set(u, succ);
				if(!old){
					sets.add(succ);
					generateSuccessors(succ);
				}
			}
		}
	}

	private function successor(set:ConfSet, unit:Unit):ConfSet{
		var items:List<Item> = new List<Item>();
		for(i in set.items){
			if(i.position < i.rule.post.length && i.rule.post[i.position] == unit){
				items.add(i);
			}
		}

		if(items.isEmpty()){
			return null;
		}

		var succ:ConfSet = new ConfSet(set.grammar);
		for(i in items){
			succ.addItem(new Item(i.rule, i.position + 1));
		}
		return succ;
	}

	private function follow(n:Nonterminal, exclude:Set<Nonterminal> = null):Set<Terminal>{
		if(exclude == null){
			exclude = new ListSet<Nonterminal>();
		}else{
			if(exclude.contains(n)){
				return null;
			}
			exclude.set(n);
		}

		var fs:Set<Terminal> = follows.get(n);

		if(fs == null){
			fs = new ListSet<Terminal>();

			for(r in grammar.rules){
				if(r.pre == grammar.start){
					fs.set(nullTerm);
				}
				for(i in 0...r.post.length-1){
					if(r.post[i] == n){
						if(r.post[i+1].unitType == Terminal){
							fs.set(cast r.post[i+1]);
						}else{
							var f:Set<Terminal> = first(cast r.post[i+1]);
							if(f != null){
								for(t in f){
									fs.set(t);
								}
							}
						}
					}
				}
				if(r.post[r.post.length-1] == n && n != r.pre){
					var f:Set<Terminal> = follow(r.pre, exclude);
					if(f != null){
						for(t in f){
							fs.set(t);
						}
					}
				}
			}
		}
		return fs;
	}

	private function first(n:Nonterminal, exclude:Set<Nonterminal> = null):Set<Terminal>{
		if(exclude == null){
			exclude = new ListSet<Nonterminal>();
		}else{
			if(exclude.contains(n)){
				return null;
			}
			exclude.set(n);
		}

		var fs:Set<Terminal> = firsts.get(n);

		if(fs == null){
			fs = new ListSet<Terminal>();
			firsts.set(n, fs);

			for(r in grammar.rules){
				if(r.pre == n){
					if(r.post[0].unitType == Terminal){
						fs.set(cast r.post[0]);
					}else{
						var next:Nonterminal = cast r.post[0];
						if(n != next){
							var f:Set<Terminal> = first(next, exclude);
							if(f != null){
								for(t in f){
									fs.set(t);
								}
							}
						}
					}
				}
			}
		}
		return fs;
	}
}