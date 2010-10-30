package org.spicefactory.parsley.integration.pimento {
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.object.equalTo;
import org.spicefactory.cinnamon.service.ServiceChannel;
import org.spicefactory.cinnamon.service.ServiceEvent;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.flex.FlexConfig;
import org.spicefactory.parsley.flex.rpc.ServiceExecutor;
import org.spicefactory.parsley.integration.pimento.config.CinnamonMxmlConfig;
import org.spicefactory.parsley.integration.pimento.model.ServiceObserver;
import org.spicefactory.parsley.messaging.messages.TestEvent;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class CinnamonCommandTest {
	
	
	private var observer:ServiceObserver;
	

	[Task(async)]	
	public function taskWithResult () : void {
		//CinnamonCommandSupport.initialize();
		var executor:ServiceExecutor = new ServiceExecutor();
		observer = new ServiceObserver();
		
		var context:Context = ContextBuilder.newBuilder()
				.config(FlexConfig.forClass(CinnamonMxmlConfig))
				.object(executor)
				.object(observer)
				.build();
		
		assertThat(context.getObjectCount(), equalTo(5));
		
		var callback:Function = Async.asyncHandler(this, onResultEvent, 3000);
    	ServiceChannel(context.getObjectByType(ServiceChannel))
    			.addEventListener(ServiceEvent.COMPLETE, callback);
    			
		context.scopeManager.dispatchMessage(new TestEvent("test1", "The result", 0));
	}
	
	private function onResultEvent (event:Event) : void {
		// TODO - check is invoked too early
		assertThat(observer.resultString, equalTo("The result"));
	}
	
	
}
}
