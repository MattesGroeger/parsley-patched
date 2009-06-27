package org.spicefactory.parsley.core.messaging.model {
import org.spicefactory.parsley.core.messaging.TestEvent;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class ProxyMessageHandlersMetadata extends ProxyMessageHandlers {
	
	
	[MessageHandler(createInstance="true")]
	public override function allTestEvents (event:TestEvent) : void {
		super.allTestEvents(event);
	}
	
	[MessageHandler(createInstance="true")]
	public override function allEvents (event:Event) : void {
		super.allEvents(event);
	}
	
	[MessageHandler(selector="test1", createInstance="true")]
	public override function event1 (event:TestEvent) : void {
		super.event1(event);
	}
	
	[MessageHandler(selector="test2", createInstance="true")]
	public override function event2 (event:TestEvent) : void {
		super.event2(event);
	}
	
	
}
}
