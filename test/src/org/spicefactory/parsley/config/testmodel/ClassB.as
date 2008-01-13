package org.spicefactory.parsley.config.testmodel {
	
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
	
	
public class ClassB	implements ApplicationContextAware {
	
	
	public static const CONSTANT:String = "krautquark";
	
	public static var tempStatic:int = 0;
	public var tempVar:int = 0;
	
	
	private var _context:ApplicationContext;
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	public function createClassAInstance (stringProp:String) : ClassA {
		var classA:ClassA = new ClassA();
		classA.stringProp = stringProp;
		return classA;
	}
	
}

}