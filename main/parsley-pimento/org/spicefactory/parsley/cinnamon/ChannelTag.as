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
import org.spicefactory.cinnamon.service.NetConnectionServiceChannel;
import org.spicefactory.cinnamon.service.ServiceChannel;
import org.spicefactory.parsley.core.errors.ContextError;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class ChannelTag {
	
            
	public var id:String;
	
	public var type:Class = NetConnectionServiceChannel;

	[Required]
	public var url:String;
	
	public var timeout:uint;


	[Factory]
	public function createChannel () : ServiceChannel {
		var channelObj:Object = new type();
		if (!(type is ServiceChannel)) {
			throw new ContextError("Object of type " + getQualifiedClassName(channelObj) 
					+ " does not implement ServiceChannel");							
		}
		var channel:ServiceChannel = channelObj as ServiceChannel;
		channel.serviceUrl = url;
		channel.timeout = timeout;
		return channel;
	}
	
	
}
}
