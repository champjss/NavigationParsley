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
package com.adobe.cairngorm.navigation.core
{
	import com.adobe.cairngorm.navigation.NavigationEvent;
	
	import flash.events.EventDispatcher;
	
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	import org.spicefactory.parsley.core.messaging.MessageState;
	import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

	public class NavigationParsleyAdaptor extends EventDispatcher implements MessageTarget
	{
		public function get order():int
		{
			return 0;
		}

		[Bindable]
		public var messageType:Class=NavigationEvent;

		[Bindable]
		public var selector:*=NavigationEvent.NAVIGATE_TO;

		private var _controller:NavigationController;

		public function get controller():NavigationController
		{
			return _controller;
		}
		
		public function get type():Class
		{
			return NavigationEvent;
		}

		public var processorInterceptor:MessageProcessorInterceptor;

		public function NavigationParsleyAdaptor(controller:NavigationController)
		{
			_controller=controller;
			_controller.addEventListener(LastInterceptorEvent.LAST_ENTER_INTERCEPTOR, handleLastInterceptor);
			processorInterceptor=new MessageProcessorInterceptor(this);
		}
		
		private function handleLastInterceptor(event:LastInterceptorEvent):void
		{
			processorInterceptor.lastInterceptors[event.destination] = true;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			_controller.addEventListener(type, processorInterceptor.navigationHandler, useCapture, priority, useWeakReference);
		}

		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			_controller.removeEventListener(type, processorInterceptor.navigationHandler);
		}

		public function handleMessage(processor:MessageProcessor):void
		{
			processor.suspend();
			
			var event:NavigationEvent=NavigationEvent(processor.message.instance);
			
			processorInterceptor.registerProcessor(event.destination, processor);
			
			if (controller.navigateTo(event.destination))
			{
				processor.resume();
			}
			else
			{
				if(processor.state != MessageState.COMPLETE)
				{
					processor.cancel();
				}
			}
		}
	}
}