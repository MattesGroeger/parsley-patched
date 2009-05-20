package org.spicefactory.parsley.core.decorator.asyncinit {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class AsyncInitTest extends ContextTestBase {
	
	
	public function testDefaultAsyncInit () : void {
		var context:Context = ActionScriptContextBuilder.build(AsyncInitContainer);
		checkState(context, true, false);
		checkObjectIds(context, ["asyncInitModel"], AsyncInitModel);
		var model:AsyncInitModel = AsyncInitModel.instance;	
		model.dispatchEvent(new Event(Event.COMPLETE));
		checkState(context, true, true);
	}
	
	
	public function testOrderedAsyncInit () : void {
		var context:Context = ActionScriptContextBuilder.build(AsyncInitOrderedContainer);
		checkState(context, true, false);
		checkObjectIds(context, ["asyncInitModel1"], AsyncInitOrderedModel1);
		checkObjectIds(context, ["asyncInitModel2"], AsyncInitOrderedModel2);
		assertNotNull("First model should be initialized", AsyncInitOrderedModel1.instance);
		assertNull("Second model should not be initialized", AsyncInitOrderedModel2.instance);
		
		var model1:AsyncInitOrderedModel1 = AsyncInitOrderedModel1.instance;	
		model1.dispatchEvent(new Event(Event.COMPLETE));
		checkState(context, true, false);
		assertNotNull("Second model should now be initialized", AsyncInitOrderedModel2.instance);
		
		var model2:AsyncInitOrderedModel2 = AsyncInitOrderedModel2.instance;	
		model2.dispatchEvent(new Event("customComplete"));
		checkState(context, true, true);
	}
	
	
}
}
