package org.spicefactory.parsley.xml {
import org.spicefactory.lib.expr.impl.DefaultExpressionContext;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.xml.processor.XmlConfigurationProcessor;

/**
 * @author Jens Halm
 */
public class XmlContextTestBase extends ContextTestBase {
	
	
	public static function getXmlContext (xml:XML, parent:Context = null, customScope:String = null, inherited:Boolean = true) : Context {
		var builder:CompositeContextBuilder = new DefaultCompositeContextBuilder(null, parent);
		var xmlProcessor:XmlConfigurationProcessor = new XmlConfigurationProcessor([], new DefaultExpressionContext());
		xmlProcessor.addXml(xml);
		builder.addProcessor(xmlProcessor);
		if (customScope) {
			builder.addScope(customScope, inherited);
		}
		return builder.build();
	}
	
	
}
}
