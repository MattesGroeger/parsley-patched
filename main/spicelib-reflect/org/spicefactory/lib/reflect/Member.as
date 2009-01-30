package org.spicefactory.lib.reflect {
import flash.utils.Dictionary;

import org.spicefactory.lib.reflect.MetadataAware;

/**
 * Represents a named member of a Class (a Constructor, Property or Method).
 * 
 * @author Jens Halm
 */
public class Member extends MetadataAware {


	private var _name:String;
	private var _owner:ClassInfo;


	/**
	 * @private
	 */
	function Member (name:String, owner:ClassInfo, metadata:Dictionary) {
		super(metadata);
		_name = name;
		_owner = owner;
	}
	
	/**
	 * The name of this member. For Constructors the value is the same as the name
	 * of the class the Constructor belongs to (not fully qualified). Otherwise the 
	 * value is simply the name of the method or property.
	 */
	public function get name () : String  {	
		return _name; 
	}
	
	/**
	 * The owner of this member. The owner is the Class that was reflected on 
	 * to retrieve an instance of this Member. This may differ from the Class
	 * that this Member is declared on which may be a supertype. The <code>declaredBy</code> attribute
	 * provided by the <code>describeType</code> method is currently ignored
	 * for consistency reasons, since it is not provided for all Member types.
	 */
	public function get owner () : ClassInfo {
		return _owner;
	}
	

}

}