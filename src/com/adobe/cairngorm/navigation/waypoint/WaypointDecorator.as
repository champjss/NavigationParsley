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
package com.adobe.cairngorm.navigation.waypoint
{
    import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
    import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;

    [Metadata(name="Waypoint", types="class")]
    public class WaypointDecorator implements ObjectDefinitionDecorator
    {
        //------------------------------------------------------------------------
        //
        //  Properties
        //
        //------------------------------------------------------------------------

        /**
         * Helps the navigation library to synchronize its state with the view state
         * of the component that is annotated with Waypoint.
         *
         * By default, a SelectedChildWaypoint assumes the UIComponent contains children
         * with automation names. Alternatively, the user can specify a custom waypoint.
         *
         * @default com.adobe.cairngorm.navigation.waypoint.SelectedChildWaypoint
         */
        public var type:Class;

        /**
         * Helps the navigation library to synchronize its state with the view state
         * of the component that is annotated with Waypoint.
         *
         * By default, a SelectedChildWaypoint assumes the UIComponent contains children
         * with automation names. Alternatively, the user can specify a custom waypoint.
         *
         * When using view states, a short-cut value of "states",
         * uses the CurrentStateWaypoint in order to retrieve destinations from states
         * and synchronize the view state with the navigation library state.
         * When using CurrentStateWaypoint, a name property for the waypoint is mandatory.
         *
         * @default com.adobe.cairngorm.navigation.waypoint.SelectedChildWaypoint
         */
        public var mode:String;

        /**
         * Specifies the waypoint name. When using the default SelectedChildWaypoint as type,
         * the waypoint name will be retrieved automatically.
         */
        public var name:String;

        public function decorate(builder:ObjectDefinitionBuilder):void
        {
            builder.lifecycle().processorFactory(WaypointProcessor.newFactory(type,
                                                                              mode,
                                                                              name,
                                                                              builder.config.context.scopeManager,
                                                                              builder.config.domain));
        }
    }
}