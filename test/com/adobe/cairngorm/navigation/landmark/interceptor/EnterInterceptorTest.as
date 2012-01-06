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
package com.adobe.cairngorm.navigation.landmark.interceptor
{
	import com.adobe.cairngorm.CairngormNavigationSupport;
	import com.adobe.cairngorm.navigation.NavigationEvent;
	import com.adobe.cairngorm.navigation.core.DestinationRegistry;
	import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptorFactory;
	import com.adobe.cairngorm.navigation.landmark.Destinations;
	import com.adobe.cairngorm.navigation.landmark.interceptor.ChatPM;
	import com.adobe.cairngorm.navigation.landmark.interceptor.NewsPM;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.dsl.context.ContextBuilder;
	
	public class EnterInterceptorTest
	{
		private var context:Context;		
		
		public var newsPM:NewsPM;
		private var chatPM:ChatPM;
		
		[BeforeClass]
		public static function initializeCairngormNavigationSupport():void
		{
			CairngormNavigationSupport.initialize();
		}	
		
		[Before]
		public function setUp():void
		{
			newsPM = new NewsPM();
			chatPM = new ChatPM();
			context = ContextBuilder.newBuilder()
				.object(newsPM)
				.object(chatPM)
				.build();
		}	
		
		[After]
		public function tearDown():void
		{
			var registry:DestinationRegistry = NavigationParsleyAdaptorFactory.getInstance(context.scopeManager).controller.destinations;
			registry.unregisterDestination(Destinations.MESSAGES);
			registry.unregisterDestination(Destinations.CHAT);
			registry.unregisterDestination(Destinations.NEWS);
			registry.unregisterDestination(Destinations.CONTENT);
			
			context.destroy();
		}	
		
		[Test]
		public function whenNavigatingToLandmark_then_enterInterceptorIsInvoked():void
		{
			navigateTo(Destinations.MESSAGES);
			navigateTo(Destinations.NEWS);
			assertTrue(newsPM.enterInterceptorFired);
		}
		
		[Test]
		public function whenNavigatingAwayFromLandmark_then_exitInterceptorIsInvoked():void
		{			
			navigateTo(Destinations.MESSAGES);	
			navigateTo(Destinations.NEWS);
			navigateTo(Destinations.CHAT);
			assertTrue(newsPM.exitInterceptorFired);
		}
		
		[Test]
		public function whenNavigatingSomewhereElse_then_enterInterceptorIsNotInvoked():void // Terrible name...
		{
			navigateTo(Destinations.CHAT);
			assertFalse(newsPM.enterInterceptorFired);
		}
		
		private function navigateTo(destination:String):void
		{
			context.scopeManager.dispatchMessage(NavigationEvent.createNavigateToEvent(destination));
		}
	}
}