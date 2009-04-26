/*
 * Copyright 2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.parsley.cinnamon {
import org.spicefactory.cinnamon.client.ServiceChannel;
import org.spicefactory.cinnamon.client.ServiceProxy;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;

/**
 * @author Jens Halm
 */
public class ServiceTag {
	
            
	public var id:String;

	[Required]
	public var name:String;
	
	[Required]
	public var type:Class;
	
	public var channel:String;
	
	public var timeout:uint = 0;
	
	
	[Inject]
	public var context:Context;
	
	
	[Factory]
	public function createService () : Object {
		if (name == null) {
			throw new ContextError("Name of the service with id " + id + " has not been specified"); 
		}

		var service:Object = new type();
		
		var channelInstance:ServiceChannel;
		if (channel != null) {
			var channelRef:Object = context.getObject(channel);
			if (!(channelRef is ServiceChannel)) {
				throw new ContextError("Object with id " + channel + " does not implement ServiceChannel");
			}
			channelInstance = channelRef as ServiceChannel;
		}
		else {
			channelInstance = context.getObjectByType(ServiceChannel, true) as ServiceChannel;
		}
		
		var proxy:ServiceProxy = channelInstance.createProxy(name, service);
		if (timeout != null) proxy.timeout = timeout;
		
		return service;		
	}
            
            
}
}
