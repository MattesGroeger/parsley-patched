/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.rpc.cinnamon.command {
import org.spicefactory.cinnamon.service.ServiceRequest;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;

/**
 * CommandFactory implementation that supports command methods that
 * return an Cinnamon ServiceRequest. May be used in Flex or Flash
 * applications that use Cinnamon Remoting for RPC calls.
 * 
 * @author Jens Halm
 */
public class CinnamonCommandFactory implements CommandFactory {

	/**
	 * @inheritDoc
	 */
	public function createCommand (returnValue:Object, message:Object, selector:* = undefined) : Command {
		return new CinnamonCommand(ServiceRequest(returnValue), message, selector);
	}
}
}

import org.spicefactory.cinnamon.service.ServiceContext;
import org.spicefactory.cinnamon.service.ServiceRequest;
import org.spicefactory.cinnamon.service.ServiceResponse;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.messaging.command.impl.AbstractCommand;

class CinnamonCommand extends AbstractCommand {


	function CinnamonCommand (request:ServiceRequest, message:Object, selector:*) {
		super(request, message, selector);
		request.addResultHandler(complete).addErrorHandler(error);
	}
	
	protected override function complete (result:* = null) : void {
		super.complete(ServiceContext.response);
	}
	
	protected override function error (result:* = null) : void {
		super.error(ServiceContext.response);
	}
	
	protected override function selectResultValue (result:*, targetType:ClassInfo) : * {
		return (targetType.getClass() != ServiceResponse) 
			? ServiceResponse(result).result
			: result;
	}
	
	protected override function selectErrorValue (result:*, targetType:ClassInfo) : * {
		return (targetType.getClass() != ServiceResponse)
			? ServiceResponse(result).result
			: result;
	}
	
}
