/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.xml.impl {

/**
 * @author Jens Halm
 */
public class XmlFile {
	
	
	private var _filename:String;
	private var _rootElement:XML;
	
	
	function XmlFile (filename:String, rootElement:XML) {
		_filename = filename;
		_rootElement = rootElement;
	}
	
	
	public function get filename () : String {
		return _filename;
	}
	
	public function get rootElement () : XML {
		return _rootElement;
	}
	
	
	public function toString () : String {
		return "[XmlFile " + _filename + "]";
	}
	
	
}
}
