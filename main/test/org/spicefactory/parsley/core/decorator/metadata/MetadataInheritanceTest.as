package org.spicefactory.parsley.core.decorator.metadata {
import flexunit.framework.TestCase;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.metadata.MetadataDecoratorAssembler;

/**
 * @author Jens Halm
 */
public class MetadataInheritanceTest extends TestCase {
	
	
	private var assembler:MetadataDecoratorAssembler = new MetadataDecoratorAssembler();
	
	
	public function testSubclassWithoutInheritance () : void {
		var decorators:Array = assembler.assemble(ClassInfo.forClass(SubclassNoInheritance));
		assertEquals("Unexpected number of decorators", 6, decorators.length);
	}
	
	public function testSubclassWithInheritance () : void {
		var decorators:Array = assembler.assemble(ClassInfo.forClass(SubclassWithInheritance));
		assertEquals("Unexpected number of decorators", 7, decorators.length);
	}
	
	public function testImplementationWithoutInheritance () : void {
		var decorators:Array = assembler.assemble(ClassInfo.forClass(ImplementationNoInheritance));
		assertEquals("Unexpected number of decorators", 2, decorators.length);
	}
	
	public function testImplementationWithInheritance () : void {
		var decorators:Array = assembler.assemble(ClassInfo.forClass(ImplementationWithInheritance));
		assertEquals("Unexpected number of decorators", 2, decorators.length);
	}
	
	
	
}
}
