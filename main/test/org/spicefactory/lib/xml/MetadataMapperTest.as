package org.spicefactory.lib.xml {
import flexunit.framework.TestCase;

import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;
import org.spicefactory.lib.xml.mapper.SimpleMappingType;
import org.spicefactory.lib.xml.mapper.XmlObjectMappings;
import org.spicefactory.lib.xml.model.ChildA;
import org.spicefactory.lib.xml.model.ChildB;
import org.spicefactory.lib.xml.model.ChildC;
import org.spicefactory.lib.xml.model.ClassWithChild;
import org.spicefactory.lib.xml.model.SimpleClass;
import org.spicefactory.lib.xml.model.metadata.ChildTextNodes;
import org.spicefactory.lib.xml.model.metadata.CustomName;
import org.spicefactory.lib.xml.model.metadata.MappedAttribute;
import org.spicefactory.lib.xml.model.metadata.MappedIdChoice;
import org.spicefactory.lib.xml.model.metadata.MappedTextNode;
import org.spicefactory.lib.xml.model.metadata.MappedTypeChoice;
import org.spicefactory.lib.xml.model.metadata.UnmappedXml;

import flash.events.Event;

/**
 * @author Jens Halm
 */
public class MetadataMapperTest extends TestCase {
	
	
	public function testAttributeMapper () : void {
		var xml:XML = <tag boolean-prop="true" string-prop="foo" int-prop="7" class-prop="flash.events.Event"/>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", Event, sc.classProp);
	}
	
	public function testAttributeMapperWithMissingOptionalAttr () : void {
		var xml:XML = <tag boolean-prop="true" string-prop="foo" int-prop="7"/>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", null, sc.classProp);
	}
	
	public function testAttributeMapperWithMissingRequiredAttr () : void {
		var xml:XML = <tag boolean-prop="true" int-prop="7"/>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.build();
		var context:XmlProcessorContext = new XmlProcessorContext();
		try {
			mapper.mapToObject(xml, context);
		} catch (e:MappingError) {
			assertTrue("Expected context with errors", context.hasErrors());
			assertEquals("Unexpected number of errors", 1, context.errors.length);
			return;
		}
		fail("Expected mapping error");
	}
	
	public function testTextNodeMapper () : void {
		var xml:XML = <tag>
			<string-prop>foo</string-prop>
			<int-prop>7</int-prop>
			<boolean-prop>true</boolean-prop>
			<class-prop>flash.events.Event</class-prop>
		</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.defaultSimpleMappingType(SimpleMappingType.CHILD_TEXT_NODE)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", Event, sc.classProp);
	}
	
	public function testTextNodeMapperWithMissingOptionalNode () : void {
		var xml:XML = <tag>
			<string-prop>foo</string-prop>
			<int-prop>7</int-prop>
			<boolean-prop>true</boolean-prop>
		</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.defaultSimpleMappingType(SimpleMappingType.CHILD_TEXT_NODE)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is SimpleClass);
		var sc:SimpleClass = SimpleClass(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", null, sc.classProp);
	}
	
	public function testTextNodeMapperWithMissingRequiredNode () : void {
		var xml:XML = <tag>
			<int-prop>7</int-prop>
			<boolean-prop>true</boolean-prop>
		</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(SimpleClass)
							.defaultSimpleMappingType(SimpleMappingType.CHILD_TEXT_NODE)
							.build();
		var context:XmlProcessorContext = new XmlProcessorContext();
		try {
			mapper.mapToObject(xml, context);
		} catch (e:MappingError) {
			assertTrue("Expected context with errors", context.hasErrors());
			assertEquals("Unexpected number of errors", 1, context.errors.length);
			return;
		}
		fail("Expected mapping error");
	}
	
	public function testTextNodeMapperWithMetadata () : void {
		var xml:XML = <tag>
			<string-prop>foo</string-prop>
			<int-prop>7</int-prop>
			<boolean-prop>true</boolean-prop>
			<class-prop>flash.events.Event</class-prop>
		</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(ChildTextNodes)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is ChildTextNodes);
		var sc:ChildTextNodes = ChildTextNodes(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected Class Property", Event, sc.classProp);
	}
	
	public function testMapTextNodeAndAttribute () : void {
		var xml:XML = <tag int-prop="7">foo</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTextNode)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is MappedTextNode);
		var sc:MappedTextNode = MappedTextNode(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected int Property", 7, sc.intProp);
	}
	
	public function testMapAttributeAndIgnoredProperty () : void {
		var xml:XML = <tag string-prop="foo"><boolean-prop>true</boolean-prop></tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedAttribute)
							.defaultSimpleMappingType(SimpleMappingType.CHILD_TEXT_NODE)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of SimpleClass", obj is MappedAttribute);
		var sc:MappedAttribute = MappedAttribute(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
		assertEquals("Unexpected Boolean Property", true, sc.booleanProp);
		assertEquals("Unexpected int Property", 0, sc.intProp);
	}
	
	public function testMapSingleChildElement () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="foo"/>
		</tag>;
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(ClassWithChild)
							.mappedClasses(ChildA)
							.build();
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of ClassWithChild", obj is ClassWithChild);
		var cwc:ClassWithChild = ClassWithChild(obj);
		assertEquals("Unexpected int Property", 7, cwc.intProp);
		assertTrue("Expected ChildA as child property", cwc.child != null);
		assertEquals("Unexpected name Property", "foo", cwc.child.name);
	}
	
	public function testIdChoice () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="A"/>
			<child-b name="B"/>
		</tag>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedIdChoice)
							.choiceId("foo", ChildA, ChildB)
							.build();
		
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of MappedIdChoice", obj is MappedIdChoice);
		var cwc:MappedIdChoice = MappedIdChoice(obj);
		assertEquals("Unexpected int Property", 7, cwc.intProp);
		assertTrue("Expected Array as children property", cwc.children != null);
		assertEquals("Unxpected length of children Array", 2, cwc.children.length);
		assertTrue("Unexpected child type", cwc.children[0] is ChildA);
		assertTrue("Unexpected child type", cwc.children[1] is ChildB);
		assertEquals("Unexpected name Property", "A", ChildA(cwc.children[0]).name);
		assertEquals("Unexpected name Property", "B", ChildB(cwc.children[1]).name);
	}
	
	public function testIdChoiceWithIllegalChild () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="A"/>
			<child-b name="B"/>
			<child-c name="C"/>
		</tag>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedIdChoice)
						    .mappedClasses(ChildC)
							.choiceId("foo", ChildA, ChildB)
							.build();
		var context:XmlProcessorContext = new XmlProcessorContext();
		try {
			mapper.mapToObject(xml, context);
		} catch (e:MappingError) {
			assertTrue("Expected context with errors", context.hasErrors());
			assertEquals("Unexpected number of errors", 1, context.errors.length);
			return;
		}
		fail("Expected mapping error");
	}
	
	public function testTypeChoice () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="A"/>
			<child-b name="B"/>
		</tag>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice)
							.mappedClasses(ChildA, ChildB, ChildC)
							.build();
		
		var obj:Object = mapper.mapToObject(xml);
		validateMappedTypeChoice(obj);
	}
	
	public function testTypeChoiceWithIllegalChild () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="A"/>
			<child-b name="B"/>
			<child-c name="C"/>
		</tag>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice)
							.mappedClasses(ChildA, ChildB, ChildC)
							.build();
		var context:XmlProcessorContext = new XmlProcessorContext();
		try {
			mapper.mapToObject(xml, context);
		} catch (e:MappingError) {
			assertTrue("Expected context with errors", context.hasErrors());
			assertEquals("Unexpected number of errors", 1, context.errors.length);
			return;
		}
		fail("Expected mapping error");
	}
	
	public function testCustomBuilder () : void {
		var xml:XML = <tag int-prop="7">
			<custom name="A"/>
			<child-b name="B"/>
		</tag>;
		
		var mappings:XmlObjectMappings 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice);
		mappings.newMapperBuilder(ChildA, new QName("custom"));
		var mapper:XmlObjectMapper = mappings.mappedClasses(ChildB, ChildC).build();
		
		var obj:Object = mapper.mapToObject(xml);
		validateMappedTypeChoice(obj);
	}
	
	public function testCustomMapper () : void {
		var xml:XML = <tag int-prop="7">
			<custom name="A"/>
			<child-b name="B"/>
		</tag>;
		
		var builder:PropertyMapperBuilder = new PropertyMapperBuilder(ChildA, new QName("custom"));
		builder.mapAllToAttributes();
		var customMapper:XmlObjectMapper = builder.build();
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice)
						.customMapper(customMapper)
						.mappedClasses(ChildB, ChildC)
						.build();
		
		var obj:Object = mapper.mapToObject(xml);
		validateMappedTypeChoice(obj);
	}
	
	public function testMergedMappings () : void {
		var xml:XML = <tag int-prop="7">
			<child-a name="A"/>
			<child-b name="B"/>
		</tag>;
		
		var mappings:XmlObjectMappings = XmlObjectMappings
			.forUnqualifiedElements()
				.withoutRootElement()
					.mappedClasses(ChildA, ChildB, ChildC);
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice)
						.mergedMappings(mappings)
						.build();
		
		var obj:Object = mapper.mapToObject(xml);
		validateMappedTypeChoice(obj);
	}
	
	public function testNamespace () : void {
		var xml:XML = <tag int-prop="7" xmlns:ns="testuri">
			<ns:child-a name="A"/>
			<ns:child-b name="B"/>
		</tag>;
		
		var mappings:XmlObjectMappings = XmlObjectMappings
			.forNamespace("testuri")
				.withoutRootElement()
					.mappedClasses(ChildA, ChildB, ChildC);
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(MappedTypeChoice)
						.mergedMappings(mappings)
						.build();
		
		var obj:Object = mapper.mapToObject(xml);
		validateMappedTypeChoice(obj);
	}
	
	private function validateMappedTypeChoice (obj:Object) : void {
		assertTrue("Expected instance of MappedIdChoice", obj is MappedTypeChoice);
		var mtc:MappedTypeChoice = MappedTypeChoice(obj);
		assertEquals("Unexpected int Property", 7, mtc.intProp);
		assertTrue("Expected Array as children property", mtc.children != null);
		assertEquals("Unxpected length of children Array", 2, mtc.children.length);
		assertTrue("Unexpected child type", mtc.children[0] is ChildA);
		assertTrue("Unexpected child type", mtc.children[1] is ChildB);
		assertEquals("Unexpected name Property", "A", ChildA(mtc.children[0]).name);
		assertEquals("Unexpected name Property", "B", ChildB(mtc.children[1]).name);
	}
	
	public function testCustomName () : void {
		var xml:XML = <custom string-prop="foo"/>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(CustomName)
						.build();
		
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of CustomName", obj is CustomName);
		var sc:CustomName = CustomName(obj);
		assertEquals("Unexpected String Property", "foo", sc.stringProp);
	}
	
	public function testIgnoreUnmappedXml () : void {
		var xml:XML = <ignore-unmapped-xml unmapped="foo"><unmapped/></ignore-unmapped-xml>;
		
		var mapper:XmlObjectMapper 
				= XmlObjectMappings
					.forUnqualifiedElements()
						.withRootElement(UnmappedXml)
						.build();
		
		var obj:Object = mapper.mapToObject(xml);
		assertTrue("Expected instance of UnmappedXml", obj is UnmappedXml);
	}
	
	 
}
}
