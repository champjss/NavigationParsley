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
	import com.adobe.cairngorm.LogUtil;
	import com.adobe.cairngorm.navigation.NavigationEvent;
	import com.adobe.cairngorm.navigation.NavigationUtil;
	
	import mx.logging.ILogger;
	
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.messaging.Message;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	import org.spicefactory.parsley.core.messaging.MessageState;

	//TODO: Refactor
	public class NavigationMessageProcessor implements MessageProcessor
	{
		private var interceptor:NavigationParsleyAdaptor;

		private var destination:String;

		private var finalDestination:String;

		private var action:String;

		private var processor:MessageProcessor;

		private var newProcessor:MessageProcessor;

		private static const LOG:ILogger=LogUtil.getLogger(NavigationMessageProcessor);

		public function NavigationMessageProcessor(interceptor:NavigationParsleyAdaptor, destination:String, finalDestination:String, action:String, processor:MessageProcessor, newProcessor:MessageProcessor=null)
		{
			this.interceptor=interceptor;
			this.destination=destination;
			this.finalDestination=finalDestination;
			this.action=action;
			this.processor=processor;
			this.newProcessor=newProcessor;
		}
		
		public function get message():Message
		{
			return processor.message;
		}		

		public function get selector():*
		{
			return processor.message.selector;
		}
		
		public function get	senderContext():Context
		{
			return processor.message.senderContext;
		}		
		
		public function get	state():MessageState
		{
			return processor.state;
		}			
		
		public function cancel():void
		{			
			processor.cancel();
		}

		//deprecated
		public function proceed():void
		{
			resume();
		}
		
		//Need to execute the one current Parsley processor 
		//at the last navigation interceptor destination.
		public function resume():void
		{			
			var event:NavigationEvent=NavigationEvent(processor.message.instance);

			if (action == NavigationActionName.ENTER_INTERCEPT)
			{
				interceptor.controller.unblockEnter(destination);

				tryProcessor(destination);

				interceptor.controller.navigateTo(event.destination, finalDestination);
				interceptor.controller.blockEnter(destination);
			}
			else if (action == NavigationActionName.EXIT_INTERCEPT)
			{
				interceptor.controller.unblockExit(destination);

				var isLast:Boolean=interceptor.processorInterceptor.lastInterceptors[destination];
				if (isLast)
				{
					if(newProcessor.state != MessageState.CANCELLED && newProcessor.state != MessageState.COMPLETE)
					{
						newProcessor.resume();					
					}
					interceptor.processorInterceptor.lastInterceptors[destination]=false;
				}
				interceptor.controller.navigateTo(NavigationEvent(newProcessor.message).destination, finalDestination);
				interceptor.controller.blockExit(destination);
			}
		}

		public function rewind():void
		{
			processor.rewind();
		}
				
		public function sendResponse(msg:Object, selector:* = null):void
		{
			processor.sendResponse(msg, selector);
		}
		
		public function suspend():void
		{
			processor.suspend();
		}

		//Enter navigations execute the most nested, registered destinations.
		//The most nested navigation might contain an interceptor but no Parsley current processor.
		private function tryProcessor(destination:String):void
		{
			try
			{
				processor = interceptor.processorInterceptor.getProcessor(destination);
				processor.resume();
				interceptor.processorInterceptor.lastInterceptors[destination]=false;
			}
			catch (e:Error)
			{
				LOG.warn("Processor not found on " + destination + ". Attempt parent destination");
				//assume error occured due to missing current processor on destination.
				//find current processor on any parent destinations.
				var parent:String=NavigationUtil.getParent(destination);
				if(parent != null)
				{
					tryProcessor(parent);
				}
				else
				{
					LOG.error("Error in processor handler of destination " + destination + " " + e);
				}
			}
		}
	}
}