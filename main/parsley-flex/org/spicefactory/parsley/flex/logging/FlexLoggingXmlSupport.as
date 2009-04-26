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

package org.spicefactory.parsley.flex.logging {
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.parsley.flash.logging.LogFactoryTag;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespace;
import org.spicefactory.parsley.xml.ext.XmlConfigurationNamespaceRegistry;

/**
 * @author Jens Halm
 */
public class FlexLoggingXmlSupport {
	
	
	public static const NAMESPACE_URI:String = "http://www.spicefactory.org/parsley/flex/logging";


	public static function initialize () : void {
		var ns:XmlConfigurationNamespace = XmlConfigurationNamespaceRegistry.registerNamespace(NAMESPACE_URI);
		var builder:PropertyMapperBuilder = ns.createObjectMapperBuilder(LogFactoryTag, "target");
		builder.mapAllToAttributes();
		builder.mapToChildTextNode("filters", new QName(NAMESPACE_URI, "filter"));
		builder.addPropertyHandler(new LogEventLevelAttributeHandler());
	}
}
}

import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.mapper.handler.AttributeHandler;
import org.spicefactory.parsley.core.errors.ContextError;

import mx.logging.LogEventLevel;

class LogEventLevelAttributeHandler extends AttributeHandler {
	
	public override function getValueFromNode (node:XML, context:XmlProcessorContext) : * {
		var value:String = super.getValueFromNode(node, context).toString().toUpperCase();
		if (!(LogEventLevel[value] is int)) { // TODO - test
			throw new ContextError("Illegal value for log event level: " + value);
		}
		return LogEventLevel[value];
	}
	
}
