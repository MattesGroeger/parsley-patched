package org.spicefactory.parsley.config.testmodel {
	
import flash.geom.Rectangle;

import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.parsley.context.ConfigurationError;

public class RectangleConverter implements Converter {
		
		
	public function convert (value:*) : * {
		if (value is Rectangle) {
			return value;
		}
		var parts:Array = value.toString().split(",");
		if (parts.length != 4) {
			throw new ConfigurationError("Expected exactly four parts in comma-separated string");
		}
		return new Rectangle(parts[0], parts[1], parts[2], parts[3]);
	}
		
		
}

}