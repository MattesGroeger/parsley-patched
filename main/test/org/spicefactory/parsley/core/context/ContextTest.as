package org.spicefactory.parsley.core.context {
import org.spicefactory.lib.reflect.ClassInfo;
import flash.events.IEventDispatcher;
import flexunit.framework.TestCase;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;

/**
 * @author Jens Halm
 */
public class ContextTest extends TestCase {
	
	
	public function testGetAllObjectsByTypeWithInterface () : void {
		var context:Context = RuntimeContextBuilder.build([new InterfaceFactory(), new Object(), new Date()]);
		assertEquals("Unexpected number of instances", 1, context.getAllObjectsByType(IEventDispatcher).length);
		assertEquals("Unexpected number of instances", 4, context.getAllObjectsByType(Object).length);
	}
	
	public function testGetObjectIdsForInterface () : void {
		var context:Context = RuntimeContextBuilder.build([new InterfaceFactory(), new Object(), new Date()]);
		assertEquals("Unexpected number of instances", 1, context.getObjectIds(IEventDispatcher).length);
		assertEquals("Unexpected number of instances", 4, context.getObjectIds(Object).length);
	}
	
	public function testGetObjectCountForInterface () : void {
		var context:Context = RuntimeContextBuilder.build([new InterfaceFactory(), new Object(), new Date()]);
		assertEquals("Unexpected number of instances", 1, context.getObjectCount(IEventDispatcher));
		assertEquals("Unexpected number of instances", 4, context.getObjectCount(Object));
	}
	
	
}
}
