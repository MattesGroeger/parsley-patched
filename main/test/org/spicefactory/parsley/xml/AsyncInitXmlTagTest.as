package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.decorator.asyncinit.AsyncInitTestBase;

/**
 * @author Jens Halm
 */
public class AsyncInitXmlTagTest extends AsyncInitTestBase {
	
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="asyncInitModel" type="org.spicefactory.parsley.core.decorator.asyncinit.model.AsyncInitModel">
			<async-init/>
		</object> 
	</objects>;
	
	public static const orderedConfig:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="asyncInitModel1" type="org.spicefactory.parsley.core.decorator.asyncinit.model.AsyncInitModel">
			<async-init order="1"/>
		</object> 
		<object id="asyncInitModel2" type="org.spicefactory.parsley.core.decorator.asyncinit.model.AsyncInitModel">
			<async-init order="2" complete-event="customComplete" error-event="customError"/>
		</object> 
	</objects>;

	protected override function get defaultContext () : Context {
		return XmlContextTestBase.getContext(config);
	}
	
	protected override function get orderedContext () : Context {
		return XmlContextTestBase.getContext(orderedConfig);
	}
	
	
}
}
