/*
 * Copyright 2008 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.lib.reflect {
import flash.utils.Dictionary;

/**
 * Base class for all types that can have associated metadata tags.
 * 
 * @author Jens Halm
 */
public class MetadataAware {
	
	
	private var _metadata:Dictionary;
	
	
	/**
	 * @private
	 */
	function MetadataAware (metadata:Dictionary) {
		_metadata = metadata;
	}
	
	/**
	 * @private
	 */
	internal function setMetadata (metadata:Dictionary) : void {
		// in some cases metadata will be lazily initialized
		_metadata = metadata;
	}
	
	/**
	 * @private
	 */
	internal static function metadataFromXml (xml:XML, type:String) : Dictionary {
		var metadata:Dictionary = new Dictionary();
		for each (var metadataTag:XML in xml.metadata) {
			var meta:Metadata = Metadata.fromXml(metadataTag, type);
			var tagsForName:Array = metadata[meta.getKey()];
			if (tagsForName == null) {
				tagsForName = new Array();
				metadata[meta.getKey()] = tagsForName;
			}
			tagsForName.push(meta);
		} 
		return metadata;
	}
	
	/**
	 * Returns all metadata tags for the specified type for this element.
	 * If no tag for the specified type exists an empty Array will be returned.
	 * 
	 * <p>In case you registered a custom metadata class for the specified name,
	 * an Array of instances of that class is returned. You must use a parameter
	 * of type <code>Class</code> specifying the mapped metadata class for the <code>type</code>
	 * parameter then.</p> 
	 * 
	 * <p>Otherwise an Array
	 * of instances of the generic <code>Metadata</code> class is returned.
	 * In this case you use the name of the metadata tag as a String for the type parameter.</p>
	 * 
	 * @param type for mapped metadata the mapped class otherwise the name of the metadata tag as a String.
	 * @param whether the returned objects should be validated (applies only for metadata mapped to custom classes)
	 * @return all metadata tags for the specified type for this element
	 */
	public function getMetadata (type:Object, validate:Boolean = true) : Array {
		// clone Array to prevent modifications
		return (_metadata[type] == undefined) ? [] : prepareMetadata(_metadata[type] as Array, validate);
	}
	
	/**
	 * Returns all metadata tags for this type in no particular order.
	 * 
	 * @param whether the returned objects should be validated (applies only for metadata mapped to custom classes)
	 * @return all metadata tags for this type
	 */
	public function getAllMetadata (validate:Boolean = true) : Array {
		// clone Arrays to prevent modifications
		var all:Array = new Array();
		for each (var metadata:Array in _metadata) {
			all = all.concat(prepareMetadata(metadata, validate));
		}
		return all;
	}
	
	
	private function prepareMetadata (metas:Array, validate:Boolean) : Array {
		var prepared:Array = new Array();
		for (var i:uint = 0; i < metas.length; i++) {
			prepared[i] = Metadata(metas[i]).getExternalValue(validate, i == 0);
		}
		return prepared;
	}
	
	
}

}
