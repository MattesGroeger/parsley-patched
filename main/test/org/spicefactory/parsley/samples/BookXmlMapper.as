package org.spicefactory.parsley.samples {
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.xml.mapper.PropertyMapperBuilder;

/**
 * @author Jens Halm
 */
public class BookXmlMapper {
	
	
	public function execute () : void {
		
		var bookBuilder:PropertyMapperBuilder = new PropertyMapperBuilder(Book, new QName("", "book"));
		bookBuilder.mapAllToAttributes();
		
		var orderBuilder:PropertyMapperBuilder = new PropertyMapperBuilder(Order, new QName("", "order"));
		orderBuilder.mapToChildElement("books", bookBuilder.build());
		
		var mapper:XmlObjectMapper = orderBuilder.build();
		
		var context:XmlProcessorContext = new XmlProcessorContext();
		
		mapper.mapToObject(element, context);
		
		mapper.mapToXml(object, context);
	}
}
}


class Book {

}

class Order {
	
}
