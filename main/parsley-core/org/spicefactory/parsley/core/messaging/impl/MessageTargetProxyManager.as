package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.parsley.core.context.Context;

/**
 * @private
 * 
 * Temporary solution. Will be removed in 2.1.
 * 
 * @author Jens Halm
 */
public class MessageTargetProxyManager {
	
	
	[Inject]
	public var context:Context;
	
	public var proxies:Array;
	
	[PostConstruct]
	public function init () : void {
		for each (var proxy:Object in proxies) {
			proxy.init(context);	
		}
		proxies = null;
	}
	
	
}
}
