package org.spicefactory.parsley.flash.binding {
import org.spicefactory.parsley.binding.BindingTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.xml.XmlContextTestBase;

/**
 * @author Jens Halm
 */
public class FlashBindingXmlTagTest extends BindingTestBase {
	
	
	protected override function get bindingContext () : Context {
		FlashCat;
		FlashAnimal;
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<dynamic-object id="publish" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<publish property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="publishId" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<publish property="value" object-id="cat"/>
		</dynamic-object>
		
		<dynamic-object id="publishLocal" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<publish property="value" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="publishManaged" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<publish property="value" managed="true" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribe" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<subscribe property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribeId" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<subscribe property="value" object-id="cat"/>
		</dynamic-object> 
		
		<dynamic-object id="subscribeLocal" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<subscribe property="value" scope="local"/>
		</dynamic-object> 
		
		<dynamic-object id="animalSubscribe" type="org.spicefactory.parsley.flash.binding.FlashAnimal">
			<subscribe property="value"/>
		</dynamic-object> 
		
		<dynamic-object id="pubsub" type="org.spicefactory.parsley.flash.binding.FlashCat">
			<publish-subscribe property="value"/>
		</dynamic-object>
		
	</objects>;	
}
}
