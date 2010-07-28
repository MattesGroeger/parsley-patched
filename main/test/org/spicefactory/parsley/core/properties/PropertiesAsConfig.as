package org.spicefactory.parsley.core.properties {
import org.spicefactory.parsley.asconfig.ConfigurationBase;

/**
 * @author Jens Halm
 */
public class PropertiesAsConfig extends ConfigurationBase {
	
	
	
	public function get object () : StringHolder {
		var sh:StringHolder = new StringHolder();
		sh.stringProp = properties.someValue;
		return sh;
	}
	
	
	
}
}
