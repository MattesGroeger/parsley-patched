package org.spicefactory.parsley.xml {
import org.spicefactory.lib.expr.impl.DefaultExpressionContext;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.xml.builder.XmlObjectDefinitionBuilder;

/**
 * @author Jens Halm
 */
public class XmlContextTestBase extends ContextTestBase {
	
	
	protected function getContext (xml:XML) : Context {
		var builder:CompositeContextBuilder = new CompositeContextBuilder();
		var xmlBuilder:XmlObjectDefinitionBuilder = new XmlObjectDefinitionBuilder([], new DefaultExpressionContext());
		xmlBuilder.addXml(xml);
		builder.addBuilder(xmlBuilder);
		return builder.build();
	}
	
	
}
}
