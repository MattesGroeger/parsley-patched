package org.spicefactory.parsley.flex.view.tag {
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.tag.ContextAwareTagBase;

import flash.display.DisplayObject;

/**
 * @author Jens Halm
 */
public class AlternativeFastInject extends ContextAwareTagBase {
	
	
	public var type:Class;
	
	public var property:String;
	
	
	function AlternativeFastInject () {
		super(ContextEvent.INITIALIZED);
	}

	protected override function handleContext (context:Context, view:DisplayObject) : void {
		var value:Object =  context.getObjectByType(type);	
		trace("AlternativeFastInject - set property " + property + " for " + view + " to " + value);
		view[property] = value;
	}
	
	
}
}
