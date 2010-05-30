package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.dsl.context.ContextBuilderSetup;

/**
 * @author Jens Halm
 */
public class XmlContextTestBase extends ContextTestBase {
	
	
	public static function getXmlContext (xml:XML, parent:Context = null, customScope:String = null, inherited:Boolean = true) : Context {
		
		var setup:ContextBuilderSetup = ContextBuilder.newSetup().parent(parent);
		if (customScope) {
			setup.scope(customScope, inherited);
		}
		return setup.newBuilder().config(XmlConfig.forInstance(xml)).build();
	}
	
	
}
}
