package org.spicefactory.parsley.config.testmodel {
	
public class ClassC {
	
	private var _ref:ClassB;
	private var _num:Number;
	
	function ClassC (ref:ClassB, num:Number) {
		_ref = ref;
		_num = num;
	}
	
	public function get ref () : ClassB {
		return _ref;
	}
	
	public function get num () : Number {
		return _num;
	}
	
}

}