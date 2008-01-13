package org.spicefactory.parsley.config.util {
	
import org.spicefactory.lib.expr.VariableResolver;

public class CustomVariableResolver implements VariableResolver {
	
	public function resolveVariable (variableName:String) : * {
		if (variableName == "foo") {
			return "bar";
		} else {
			return undefined;
		}
	}
		
}

}