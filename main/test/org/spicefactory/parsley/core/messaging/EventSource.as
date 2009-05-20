package org.spicefactory.parsley.core.messaging {
import flash.events.EventDispatcher;

[Event(name="test1",type="org.spicefactory.parsley.TestEvent")]
[Event(name="test2",type="org.spicefactory.parsley.TestEvent")]
[Event(name="foo",type="flash.events.Event")]
[ManagedEvents("test1,test2,foo")]
/**
 * @author Jens Halm
 */
public class EventSource extends EventDispatcher {
}
}
