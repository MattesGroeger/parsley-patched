package org.spicefactory.parsley.config {

import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;	
	
public class EmptyContextTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
    public function testEmptyContext () : void {
    	parseForContext("emptyContext", null, onTestEmptyContext);
    }
    
    private function onTestEmptyContext (context:ApplicationContext) : void {
    	assertStrictlyEquals("Expecting 0 objects in context", 0, context.objectCount);
    }
    
    
    public function testEmptyConfig () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0"/>;
    	parseForContext("emptyObject", xml, onTestEmptyConfig);
    }
    
    private function onTestEmptyConfig (context:ApplicationContext) : void {
    	assertStrictlyEquals("Expecting 0 objects in context", 0, context.objectCount);
    }
    
    
    public function testEmptyObject () : void {
    	var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
    		<factory>
    			<object id="empty"/>
    		</factory>
    	</application-context>;
    	parseForSingleObject("empty", xml, onTestEmptyObject, Object);
    }
    
    private function onTestEmptyObject (obj:Object) : void {
    	/* do nothing */
    }
    
	
}

}