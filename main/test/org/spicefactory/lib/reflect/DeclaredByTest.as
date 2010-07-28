package org.spicefactory.lib.reflect {
import flexunit.framework.TestCase;

import org.spicefactory.lib.reflect.model.DeclaredBySub;
import org.spicefactory.lib.reflect.model.DeclaredBySuper;

/**
 * @author Jens Halm
 */
public class DeclaredByTest extends TestCase {
	
	
	
	public function testSuperClass () : void {
		var ci:ClassInfo = ClassInfo.forClass(DeclaredBySuper);
		assertEquals("Unexpected declaredBy value", ci, ci.getProperty("someProp").declaredBy);
		assertEquals("Unexpected declaredBy value", ci, ci.getMethod("someMethod").declaredBy);
		assertEquals("Unexpected declaredBy value", ci, ci.getMethod("otherMethod").declaredBy);
	}
	
	public function testSubClass () : void {
		var ciSuper:ClassInfo = ClassInfo.forClass(DeclaredBySuper);
		var ci:ClassInfo = ClassInfo.forClass(DeclaredBySub);
		assertEquals("Unexpected declaredBy value", ci, ci.getProperty("someProp").declaredBy);
		assertEquals("Unexpected declaredBy value", ci, ci.getMethod("someMethod").declaredBy);
		assertEquals("Unexpected declaredBy value", ciSuper, ci.getMethod("otherMethod").declaredBy);
	}
	
	
}
}
