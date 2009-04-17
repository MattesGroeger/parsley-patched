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

package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.xml.impl.XmlObjectDefinitionBuilder;
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class XmlContextBuilder {
	
	
	public static function build (filename:String, parent:Context = null, domain:ApplicationDomain = null, 
			expressionContext:ExpressionContext = null) : Context {
		return buildAll([filename], parent, domain, expressionContext);		
	}
	
	public static function buildAll (filenames:Array, parent:Context = null, domain:ApplicationDomain = null, 
			expressionContext:ExpressionContext = null) : Context {
		var builder:CompositeContextBuilder = new CompositeContextBuilder(parent, domain);
		mergeAll(filenames, builder);
		return builder.build();
	}
	
	public static function merge (filename:String, builder:CompositeContextBuilder, 
			expressionContext:ExpressionContext = null) : void {
		mergeAll([filename], builder, expressionContext);
	}

	public static function mergeAll (filenames:Array, builder:CompositeContextBuilder, 
			expressionContext:ExpressionContext = null) : void {
		builder.addBuilder(new XmlObjectDefinitionBuilder(filenames, expressionContext));
	}
	
	
}
}
