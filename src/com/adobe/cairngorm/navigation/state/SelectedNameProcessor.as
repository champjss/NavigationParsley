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
	import com.adobe.cairngorm.navigation.landmark.LandmarkProcessorFactory;
	
	import org.spicefactory.lib.errors.IllegalStateError;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.lib.reflect.Property;
	import org.spicefactory.parsley.core.lifecycle.ManagedObject;
	import org.spicefactory.parsley.core.registry.ObjectProcessor;
	import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
	import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;

	public class SelectedNameProcessor implements ObjectProcessor, ISelectedName
	{
		private var targetObject:ManagedObject;		
		private var property:String;
		
		public function SelectedNameProcessor(targetObject:ManagedObject, property:String)
		{
			this.targetObject = targetObject;
			this.property = property;	
		}		
		
		public static function newFactory(property:String):ObjectProcessorFactory
		{			
			return ObjectProcessorFactories.newFactory(SelectedNameProcessor, [property]);
		}
		
		private var target:Property;				
		
		private var state:SelectedStates;
		
		public function preInit():void
		{
			var info:ClassInfo = targetObject.definition.type;
			target = info.getProperty(property);
			if(!target.writable)
			{
				throw new IllegalStateError("Property " + property + " must be writable.");	
			}
			
			var name:String = findDestinationFromLandmark();
			state = SelectedStatesFactory.getInstance(name);
			if(state)
				state.subscribe(this);
		}
		
		public function postDestroy():void
		{
			if(state)
				state.unsubscribe(this);
		}
		
		private function findDestinationFromLandmark():String
		{
			var factories:Array = targetObject.definition.processorFactories;
			for each (var item:ObjectProcessorFactory in factories)
			{
				if (item is LandmarkProcessorFactory)
				{
					return LandmarkProcessorFactory(item).name;
				}
			}
			return null;
		}
		
		private var _selectedName:String;
		
		public function get selectedName():String
		{
			var value:String;
			if(target.readable)
			{
				value = target.getValue(targetObject.instance) as String;
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
			target.setValue(targetObject.instance, value);
		}		
	}
}