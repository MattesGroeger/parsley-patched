package org.spicefactory.parsley.flash.resources.params {

import org.spicefactory.lib.reflect.Property;

public interface Params {

	function registerParamBinding (instance:Object, property:Property, key:String):void;

	function registerParam (key:String, value:String):void;

	function unregisterParam (key:String):void;

	function hasParam (key:String):Boolean;

	function getParam (key:String):String;
}
}
