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

package org.spicefactory.parsley.pimento {
import org.spicefactory.cinnamon.service.ServiceProxy;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.pimento.config.PimentoConfig;

/**
 * @author Jens Halm
 */
public class ServiceTag {
	
            
	public var id:String;

	[Required]
	public var name:String;
	
	[Required]
	public var type:Class;
	
	public var config:String;
	
	public var timeout:uint = 0;
	
	
	[Inject]
	public var context:Context;
	
	
	[Factory]
	public function createService () : Object {
		if (name == null) {
			throw new ContextError("Name of the service with id " + id + " has not been specified"); 
		}

		var service:Object = new type();
		
		var configInstance:PimentoConfig;
		if (config != null) {
			var configRef:Object = context.getObject(config);
			if (!(configRef is PimentoConfig)) {
				throw new ContextError("Object with id " + config + " is not a PimentoConfig instance");
			}
			configInstance = configRef as PimentoConfig;
		}
		else {
			configInstance = context.getObjectByType(PimentoConfig, true) as PimentoConfig;
		}
		
		configInstance.addService(name, service);
		
		var proxy:ServiceProxy = ServiceProxy.forService(service);
		if (timeout != 0) proxy.timeout = timeout;
		
		return service;		
	}
            
            
}
}
