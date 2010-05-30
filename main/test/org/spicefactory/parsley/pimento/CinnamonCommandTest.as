package org.spicefactory.parsley.pimento {
import flexunit.framework.TestCase;

import org.spicefactory.cinnamon.service.ServiceChannel;
import org.spicefactory.cinnamon.service.ServiceEvent;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.TestEvent;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.flex.FlexConfig;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class CinnamonCommandTest extends TestCase {
	
	
	private var observer:ServiceObserver;
	
	
	public function testTaskWithResult () : void {
		//CinnamonCommandSupport.initialize();
		var executor:ServiceExecutor = new ServiceExecutor();
		observer = new ServiceObserver();
		
		var context:Context = ContextBuilder.newBuilder()
				.config(FlexConfig.forClass(CinnamonMxmlTagContainer))
				.object(executor)
				.object(observer)
				.build();
		
		assertEquals("Unexpected number of objects in Context", 5, context.getObjectCount());
		
		var callback:Function = addAsync(onResultEvent, 3000);
    	ServiceChannel(context.getObjectByType(ServiceChannel))
    			.addEventListener(ServiceEvent.COMPLETE, callback);
    			
		context.scopeManager.dispatchMessage(new TestEvent("test1", "The result", 0));
	}
	
	private function onResultEvent (event:Event) : void {
		// TODO - check is invoked too early
		assertNotNull("Expected String result instance", observer.resultString);
		assertEquals("Unexpected result value", "The result", observer.resultString);
	}
	
	
}
}
