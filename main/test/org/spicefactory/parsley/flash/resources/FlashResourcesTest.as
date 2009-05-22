package org.spicefactory.parsley.flash.resources {
import org.spicefactory.lib.expr.impl.DefaultExpressionContext;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;
import org.spicefactory.parsley.flash.resources.tag.FlashResourceXmlSupport;
import org.spicefactory.parsley.flash.resources.tag.ResourceBundleTag;
import org.spicefactory.parsley.testmodel.AnnotatedResourceBinding;
import org.spicefactory.parsley.xml.XmlContextTestBase;
import org.spicefactory.parsley.xml.builder.XmlObjectDefinitionBuilder;

import flash.net.SharedObject;

public class FlashResourcesTest extends XmlContextTestBase {
	
	
	FlashResourceXmlSupport.initialize();
	
	
	private var binding:AnnotatedResourceBinding;

	
	public override function setUp () : void {
		super.setUp();
		var lso:SharedObject = SharedObject.getLocal("__locale__");
		delete lso.data.locale;
	}
	
	private function prepareContext (xml:XML, callback:Function, parent:Context = null) : void {
		var context:Context = getContext(xml, parent);
    	checkState(context, true, false);
    	var f:Function = addAsync(callback, 3000);		
		context.addEventListener(ContextEvent.INITIALIZED, f);
	}
	
	private function checkContextAndGetResourceManager (context:Context) : ResourceManager {
		checkState(context);
		checkObjectIds(context, ["rm"], ResourceManager);	
		checkObjectIds(context, ["test"], ResourceBundleTag);	
		return getAndCheckObject(context, "rm", ResourceManagerSpi) as ResourceManager;
	}
	
	public function testGetMessageIgnoreCountry () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
    	</objects>;  
    	prepareContext(xml, onTestGetMessageIgnoreCountry);		
	}
	
	private function onTestGetMessageIgnoreCountry (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = checkContextAndGetResourceManager(context);
    	assertEquals("Unexpected message", "2 + 2 = 4", rm.getMessage("test", "test", [2,2,4]));	
	}
	
	public function testGetLocalizedMessage () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true"/>
    	</objects>;  
    	prepareContext(xml, onTestGetLocalizedMessage);		
	}
	
	private function onTestGetLocalizedMessage (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = checkContextAndGetResourceManager(context);
    	assertEquals("Unexpected message", "USA", rm.getMessage("us", "test"));	
	}
	
	public function testResourceBinding () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
	        <object id="binding" type="org.spicefactory.parsley.testmodel.AnnotatedResourceBinding"/>
    	</objects>;  
    	prepareContext(xml, onTestResourceBinding);	
	}
	
	private function onTestResourceBinding (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = checkContextAndGetResourceManager(context);
		checkObjectIds(context, ["binding"], AnnotatedResourceBinding);	
		binding = getAndCheckObject(context, "binding", AnnotatedResourceBinding) as AnnotatedResourceBinding;
    	assertEquals("Unexpected message", "English", binding.boundValue);	
		rm.addEventListener(LocaleSwitchEvent.COMPLETE, addAsync(onSwitchLocale, 3000));
    	rm.currentLocale = new Locale("de", "DE");
	}
	
	private function onSwitchLocale (event:LocaleSwitchEvent) : void {
		assertEquals("Unexpected message", "Deutsch", binding.boundValue);
	}
	
	public function testTwoBundles () : void {
		var xml1:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
            <res:resource-manager id="rm">
	            <res:locale language="de" country="DE"/>
	        </res:resource-manager>
	        <res:resource-bundle id="a_text" basename="textA" localized="false" ignore-country="true"/>
    	</objects>;  
		var xml2:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
	        <res:resource-bundle id="b_text" basename="textB" localized="false" ignore-country="true"/>
    	</objects>;  
		var builder:CompositeContextBuilder = new CompositeContextBuilder();
		var xmlBuilder:XmlObjectDefinitionBuilder = new XmlObjectDefinitionBuilder([]);
		xmlBuilder.addXml(xml1);
		xmlBuilder.addXml(xml2);
		builder.addBuilder(xmlBuilder);
		var context:Context = builder.build();
    	checkState(context, true, false);
    	var f:Function = addAsync(onTestTwoBundles, 3000);		
		context.addEventListener(ContextEvent.INITIALIZED, f);
	}
	
	private function onTestTwoBundles (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = context.getObjectByType(ResourceManager, true) as ResourceManager;
		assertEquals("Unexpected message", "Text A", rm.getMessage("a", "a_text"));
		assertEquals("Unexpected message", "Text B", rm.getMessage("b", "b_text"));
	}
	
	public function testBundleInChildContext () : void {
		var xmlParent:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
            <res:resource-manager id="rm">
	            <res:locale language="de" country="DE"/>
	        </res:resource-manager>
	        <res:resource-bundle id="a_text" basename="textA" localized="false" ignore-country="true"/>
    	</objects>;  
		prepareContext(xmlParent, onTestBundleInChildContext1);
	}
	
	private function onTestBundleInChildContext1 (event:ContextEvent) : void {
		var xmlChild:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
	        <res:resource-bundle id="b_text" basename="textB" localized="false" ignore-country="true"/>
    	</objects>;
		var parent:Context = event.target as Context;
		prepareContext(xmlChild, onTestBundleInChildContext2, parent);
	}
	
	private function onTestBundleInChildContext2 (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = getAndCheckObject(context, "rm", ResourceManagerSpi) as ResourceManager;
		assertEquals("Unexpected message", "Text A", rm.getMessage("a", "a_text"));
		assertEquals("Unexpected message", "Text B", rm.getMessage("b", "b_text"));
	}

		
}

}