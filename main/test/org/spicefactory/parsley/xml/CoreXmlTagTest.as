package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.parsley.flex.mxmlconfig.core.CoreModel;
import org.spicefactory.parsley.xml.XmlContextTestBase;

/**
 * @author Jens Halm
 */
public class CoreXmlTagTest extends XmlContextTestBase {
	
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="dependency" type="org.spicefactory.parsley.core.decorator.injection.InjectedDependency"/>
		
		<object id="object" type="org.spicefactory.parsley.flex.mxmlconfig.core.CoreModel">
			<constructor-args>
				<string>foo</string>
				<int>7</int>
			</constructor-args>
			<property name="booleanProp" value="true"/>
			<property name="refProp" id-ref="dependency"/>
			<property name="arrayProp">
				<array>
					<string>AA</string>
					<string>BB</string>
					<object-ref id-ref="dependency"/>
				</array>
			</property>
		</object> 
	</objects>; 
	
	
	
	public function testCoreTags () : void {
		var context:Context = getContext(config);
		checkState(context);
		trace("?? " + context.getObjectIds());
		checkObjectIds(context, ["dependency"], InjectedDependency);	
		checkObjectIds(context, ["object"], CoreModel);	
		var obj:CoreModel 
				= getAndCheckObject(context, "object", CoreModel) as CoreModel;
		assertEquals("Unexpected string property", "foo", obj.stringProp);
		assertEquals("Unexpected int property", 7, obj.intProp);
		assertEquals("Unexpected boolean property", true, obj.booleanProp);
		assertNotNull("Dependency not resolved", obj.refProp);
		var arr:Array = obj.arrayProp;
		assertNotNull("Expected Array instance", arr);
		assertEquals("Unexpected Array element 0", "AA", arr[0]);
		assertEquals("Unexpected Array element 1", "BB", arr[1]);
		assertEquals("Unexpected Array element 2", obj.refProp, arr[2]);
	}
	
	
}
}
