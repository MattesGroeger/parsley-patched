package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.flex.mxmlconfig.lifecycle.PostConstructModel;
import org.spicefactory.parsley.flex.mxmlconfig.lifecycle.PreDestroyModel;

/**
 * @author Jens Halm
 */
public class LifecycleXmlTagTest extends XmlContextTestBase {

	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="postConstructModel" type="org.spicefactory.parsley.flex.mxmlconfig.lifecycle.PostConstructModel">
			<post-construct method="init"/>		
		</object>
		
		<object id="preDestroyModel" type="org.spicefactory.parsley.flex.mxmlconfig.lifecycle.PreDestroyModel">
			<pre-destroy method="dispose"/>		
		</object>
	</objects>; 
	
	
	public function testPostConstruct () : void {
		var context:Context = getContext(config);
		checkState(context);
		checkObjectIds(context, ["postConstructModel"], PostConstructModel);	
		var obj:PostConstructModel 
				= getAndCheckObject(context, "postConstructModel", PostConstructModel) as PostConstructModel;
		assertTrue("PostConstruct method not called", obj.methodCalled);	
	}
	
	
	public function testPreDestroy () : void {
		var context:Context = getContext(config);
		checkState(context);
		checkObjectIds(context, ["preDestroyModel"], PreDestroyModel);	
		var obj:PreDestroyModel 
				= getAndCheckObject(context, "preDestroyModel", PreDestroyModel) as PreDestroyModel;
		context.destroy();
		assertTrue("PreDestroy method not called", obj.methodCalled);			
	}
	
	
	
}
}
