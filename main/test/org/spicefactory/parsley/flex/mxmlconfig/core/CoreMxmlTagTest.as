package org.spicefactory.parsley.flex.mxmlconfig.core {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * @author Jens Halm
 */
public class CoreMxmlTagTest extends ContextTestBase {
	
	
	public function testCoreTags () : void {
		var context:Context = FlexContextBuilder.build(CoreMxmlTagContainer);
		checkState(context);
		checkObjectIds(context, ["dependency"], InjectedDependency);	
		checkObjectIds(context, ["object"], CoreModel);	
		var obj:CoreModel 
				= getAndCheckObject(context, "object", CoreModel) as CoreModel;
		assertEquals("Unexpected string property", "foo", obj.stringProp);
		assertEquals("Unexpected int property", 7, obj.intProp);
		assertEquals("Unexpected boolean property", true, obj.booleanProp);
		assertNotNull("Dependency not resolved", obj.refProp);
		var arr:Array = obj.arrayProp;
		assertNotNull("Expected Array instance", arr);
		assertEquals("Unexpected Array element 0", "AA", arr[0]);
		assertEquals("Unexpected Array element 1", "BB", arr[1]);
		assertEquals("Unexpected Array element 2", obj.refProp, arr[2]);
		assertEquals("Unexpected Array element 2", obj.refProp, arr[3]);
	}
}
}
