/*
 * Copyright 2007 the original author or authors.
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

package org.spicefactory.parsley.integration.pimento.model {
import org.spicefactory.cinnamon.ns.cinnamon;
import org.spicefactory.cinnamon.service.ServiceRequest;
import org.spicefactory.cinnamon.service.support.AbstractServiceBase;

use namespace cinnamon;
	
public class EchoServiceImpl extends AbstractServiceBase implements EchoService {
	
	
	public function EchoServiceImpl () {
		super();
	}
	
	cinnamon override function initialize () : void {
		cinnamon::addOperation("echo");
	}
	
	public function echo (value:*) : ServiceRequest {
		return cinnamon::getOperation("echo").execute([value]);
	}
		
}

}