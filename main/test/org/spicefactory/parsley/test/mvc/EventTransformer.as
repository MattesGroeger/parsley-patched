package org.spicefactory.parsley.test.mvc {
	
import flash.events.Event;

import org.spicefactory.parsley.mvc.ApplicationEvent;

public class EventTransformer {
	
	
	public function transform (event:Event) : ApplicationEvent {
		switch (event.type) {
			case "e1": return new MockEvent("eventType1");
			case "e2": return new MockEvent("eventType2");
			case "e3": return new ApplicationEvent("eventType1");
			case "e4": return new ApplicationEvent("eventType2");
		}
		return null;
	}

		
}

}