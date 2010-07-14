package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.binding.BindingTestBase;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class BindingXmlTagTest extends BindingTestBase {
	
	
	protected override function get bindingContext () : Context {
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<dynamic-object id="publish" type="org.spicefactory.parsley.binding.model.CatHolder">
			<publish property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="publishId" type="org.spicefactory.parsley.binding.model.CatHolder">
			<publish property="value" object-id="cat"/>
		</dynamic-object>
		
		<dynamic-object id="publishLocal" type="org.spicefactory.parsley.binding.model.CatHolder">
			<publish property="value" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="publishManaged" type="org.spicefactory.parsley.binding.model.CatHolder">
			<publish property="value" managed="true" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribe" type="org.spicefactory.parsley.binding.model.CatHolder">
			<subscribe property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribeId" type="org.spicefactory.parsley.binding.model.CatHolder">
			<subscribe property="value" object-id="cat"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribeLocal" type="org.spicefactory.parsley.binding.model.CatHolder">
			<subscribe property="value" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="animalSubscribe" type="org.spicefactory.parsley.binding.model.AnimalHolder">
			<subscribe property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="pubsub" type="org.spicefactory.parsley.binding.model.CatHolder">
			<publish-subscribe property="value"/>
		</dynamic-object>
		
	</objects>;	
}
}
