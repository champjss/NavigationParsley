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
	
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	import org.spicefactory.parsley.core.messaging.MessageState;
	import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;

	public class NavigateAwayInterceptor implements MessageTarget
	{
		public function get order():int
		{
			return 0;
		}

		[Bindable]
		public var messageType:Class=NavigationEvent;
		
		[Bindable]
		public var selector:*=NavigationEvent.NAVIGATE_AWAY;

		private var _controller:NavigationController;

		public function get controller():NavigationController
		{
			return _controller;
		}
		
		public function get type():Class
		{
			return NavigationEvent;
		}

		public function NavigateAwayInterceptor(controller:NavigationController)
		{
			_controller=controller;
		}

		public function handleMessage(processor:MessageProcessor):void
		{
			processor.suspend();
			
			var event:NavigationEvent=NavigationEvent(processor.message.instance);
			if(controller.navigateAway(event.destination))
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