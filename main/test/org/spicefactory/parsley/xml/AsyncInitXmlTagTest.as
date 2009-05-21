package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitModel;
import org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitOrderedModel1;
import org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitOrderedModel2;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class AsyncInitXmlTagTest extends XmlContextTestBase {
	
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="asyncInitModel" type="org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitModel">
			<async-init/>
		</object> 
	</objects>;
	
	public static const orderedConfig:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="asyncInitModel1" type="org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitOrderedModel1">
			<async-init order="1"/>
		</object> 
		<object id="asyncInitModel2" type="org.spicefactory.parsley.flex.mxmlconfig.asyncinit.AsyncInitOrderedModel2">
			<async-init order="2" complete-event="customComplete" error-event="customError"/>
		</object> 
	</objects>;

	
	public function testDefaultAsyncInit () : void {
		var context:Context = getContext(config);
		checkState(context, true, false);
		checkObjectIds(context, ["asyncInitModel"], AsyncInitModel);
		var model:AsyncInitModel = AsyncInitModel.instance;	
		model.dispatchEvent(new Event(Event.COMPLETE));
		checkState(context, true, true);
	}
	
	
	public function testOrderedAsyncInit () : void {
		var context:Context = getContext(orderedConfig);
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
