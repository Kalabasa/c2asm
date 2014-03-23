package c2asm.parser;

class TrieNode<T>{
	public var data:T = null;
	public var children:Map<String, TrieNode<T>>;

	public function new(data:T = null){
		children = new Map<String, TrieNode<T>>();
		this.data = data;
	}

	public function get(key:String):TrieNode<T>{
		return children.get(key);
	}

	public function set(child:String, data:T = null):TrieNode<T>{
		var node:TrieNode<T>;
		if(children.exists(child)){
			node = children.get(child);
			node.data = data;
			return node;
		}else{
			node = new TrieNode<T>(data);
			children.set(child, node);
		}
		return node;
	}
}