package org.spicefactory.lib.xml {
import flexunit.framework.TestCase;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.lib.xml.model.SimpleClass;

import flash.events.Event;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class PropertyMapperTest extends TestCase {
	
	
	public function testAttributeMapper () : void {
		var xml:XML = <tag boolean-prop="true" string-prop="foo" int-prop="7" class-prop="flash.events.Event"/>;
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(SimpleClass), new QName("", "tag"));
		builder.mapAllToAttributes();
		var mapper:XmlObjectMapper = builder.build();
		var obj:Object = mapper.mapToObject(xml, new XmlProcessorContext());
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", Event, sc.classProp);
	}
	
	public function testAttributeMapperWithMissingOptionalAttr () : void {
		var xml:XML = <tag boolean-prop="true" string-prop="foo" int-prop="7"/>;
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(SimpleClass), new QName("", "tag"));
		builder.mapAllToAttributes();
		var mapper:XmlObjectMapper = builder.build();
		var obj:Object = mapper.mapToObject(xml, new XmlProcessorContext());
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", null, sc.classProp);
	}
	
	public function testAttributeMapperWithMissingRequiredAttr () : void {
		var xml:XML = <tag boolean-prop="true" int-prop="7"/>;
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ClassInfo.forClass(SimpleClass), new QName("", "tag"));
		builder.mapAllToAttributes();
		var mapper:XmlObjectMapper = builder.build();
		var context:XmlProcessorContext = new XmlProcessorContext();
		var obj:Object = mapper.mapToObject(xml, context);
		assertNull("Expected null result", obj);
		assertTrue("Expected context with errors", context.hasErrors());
	}
	
	
	public function xtestDictionary () : void {
		var d:Dictionary = new Dictionary();
		var b:Boolean = (d["foo"] != undefined);
		var o:Object = new Object();
		b = (d[o] != undefined);
		var n:QName = new QName("", "foo");
		b = (d[n] != undefined);
	}
}
}
