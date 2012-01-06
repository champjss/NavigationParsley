/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.navigation.state
{
	import com.adobe.cairngorm.navigation.landmark.LandmarkProcessor;
	
	import org.spicefactory.lib.errors.IllegalStateError;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.lib.reflect.Property;
	import org.spicefactory.parsley.core.lifecycle.ManagedObject;
	import org.spicefactory.parsley.core.processor.ObjectProcessor;

	public class SelectedNameProcessor implements ObjectProcessor, ISelectedName
	{
		private var targetObject:ManagedObject;		
		private var property:String;
		
		public function SelectedNameProcessor(property:String)
		{
			this.property = property;	
		}
		
		private var targetProperty:Property;				
		
		private var state:SelectedStates;
		
		public function init(target:ManagedObject):void
		{
			this.targetObject = target;
			
			var info:ClassInfo = targetObject.definition.type;
			targetProperty = info.getProperty(property);
			if(!targetProperty.writable)
			{
				throw new IllegalStateError("Property " + property + " must be writable.");	
			}
			
			var name:String = findDestinationFromLandmark();
			state = SelectedStatesFactory.getInstance(name);
			if(state)
				state.subscribe(this);
		}
		
		public function destroy(target:ManagedObject):void
		{
			if(state)
				state.unsubscribe(this);
		}
		
		private function findDestinationFromLandmark():String
		{
			var processors:Array = targetObject.definition.processors;
			for each (var processor:ObjectProcessor in processors)
			{
				if (processor is LandmarkProcessor)
				{
					return LandmarkProcessor(processor).name;
				}
			}
			return null;
		}
		
		private var _selectedName:String;
		
		public function get selectedName():String
		{
			var value:String;
			if(targetProperty.readable)
			{
				value = targetProperty.getValue(targetObject.instance) as String;
			}
			else
			{
				value = _selectedName;
			}
			return value;
		}

		public function set selectedName(value:String):void
		{
			_selectedName = value;
			targetProperty.setValue(targetObject.instance, value);
		}		
	}
}