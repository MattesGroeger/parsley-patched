package org.spicefactory.parsley.util.matcher {
import org.hamcrest.BaseMatcher;
import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.object.IsEqualMatcher;
import org.spicefactory.parsley.core.context.Context;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class ContextIdMatcher extends BaseMatcher {
	
	private var type:Class;
	private var ids:Array;
	private var matcher:Matcher;
	
	public function ContextIdMatcher (type:Class, ids:Array) {
		super();
		this.type = type;
		this.ids = ids;
		ids.sort();
		this.matcher = new IsEqualMatcher(ids);
	}
	
	/**
	 * @inheritDoc
	 */
    public override function matches (item:Object) : Boolean {
    	if (!(item is Context)) return false;
    	var context:Context = Context(item);
		var actualIds:Array = context.getObjectIds(type);
		actualIds.sort();
		return matcher.matches(actualIds);
	}
        
    /**
	 * @inheritDoc
	 */
    public override function describeTo (description:Description) : void {
    	describeContextIds(ids, description);
	}
	
	public override function describeMismatch (item : Object, mismatchDescription : Description) : void {
		if (!(item is Context)) {
			mismatchDescription.appendText("Not a Context instance");
		}
		else {
			describeContextIds(Context(item).getObjectIds(type), mismatchDescription);
		}
	}
	
	private function describeContextIds (ids:Array, desc:Description) : void {
		if (!ids) ids = [];
		desc.appendText("Context with object ids <")
        	/* .appendList("<", ",", ">", ids) --> appendList is broken in hamcrest 1.0.2 (expects SelfDescribing) */
        	.appendText(ids.join(","))
        	.appendText("> for type ")
        	.appendText(getQualifiedClassName(type));
	}
        
	
}
}

