package org.spicefactory.parsley.binding.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.Subscriber;

/**
 * A Subscriber that updates the value of a single property whenever the
 * value of matching publishers changes.
 * 
 * @author Jens Halm
 */
public class PropertySubscriber implements Subscriber {

	
	private var _type:ClassInfo;
	private var _id:String;
	
	private var target:Object;
	private var property:Property;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param target the instance that holds the property to observe
	 * @param property the target property that holds the published value
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 */
	function PropertySubscriber (target:Object, property:Property, type:ClassInfo = null, id:String = null) {
		this.target = target;
		this.property = property;
		_type = (type == null) ? property.type : type;
		_id = id;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return _type;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		return _id;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function update (newValue:*) : void {
		property.setValue(target, newValue);
	}
	
	
}
}
