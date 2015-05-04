xquery version "1.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace portal="http://www.monasterium.net/NS/portal";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace css="http://www.monasterium.net/NS/css"
    at "../css/css.xqm";

(:
    returns a document of type xrx:portal
    by overloading a main widget of 
    type xrx:widget
:)
declare function portal:get($main-widget as element(xrx:widget)) as element() {

    let $portal-id := 
        $main-widget/xrx:portal/text()
    return
    $xrx:db-base-collection//xrx:id[.=$portal-id]/parent::xrx:portal
};

(:
    
:)
declare function portal:get-models($portal as element(), $main-widget as element()*) {

    portal:get-model($portal, $main-widget)
};

(:
    recursively reads all models
    defined in a portal and all its
    widgets and subwidgets
:)
declare function portal:get-model($super-widget as element(), $main-widget as element()*) {

    (
        (: we include the model defined in the portal :)
        $super-widget/xrx:model/node(),
        (: include the model defined in the main widget :)
        $main-widget/xrx:model/node(),
        (: recursively include all models of the subwidgets :)
        for $subwidget-id in 
            (
                $super-widget//xrx:subwidget/text(),
                $main-widget//xrx:subwidget/text()
            )
        let $subwidget := 
            $xrx:db-base-collection//xrx:id[.=$subwidget-id]/parent::xrx:widget
        (: ID of the widget class :)
        let $subwidgetclass-id :=
            $subwidget/xrx:inherits/text()
        (: the main widget's class :)
        let $subwidget-class :=
            if($subwidgetclass-id) then
                $xrx:db-base-collection//xrx:id[.=$subwidgetclass-id]/parent::xrx:widget
            else()
        let $widget :=
            if($subwidget-class) then
                xrx:inherit($subwidget-class, $subwidget)
            else
                $subwidget  
        return
        portal:get-model($widget, ())
    )
};
   
declare function portal:get-resources($portal as element(), $main-widget as element()) as element()* {

    (
        portal:get-css($portal, $main-widget),
        portal:get-js($portal, $main-widget)
    )
};

declare function portal:get-js($super-widget as element(), $main-widget as element()*) as element()*{

    (
        $super-widget/xrx:res/xrx:js/xhtml:script,
        $main-widget/xrx:res/xrx:js/xhtml:script,
        for $subwidget-id in 
            (
                $super-widget//xrx:subwidget/text(),
                $main-widget//xrx:subwidget/text()
            )
        let $subwidget := 
          $xrx:db-base-collection//xrx:id[.=$subwidget-id]/parent::xrx:widget
        (: ID of the widget class :)
        let $subwidgetclass-id :=
            $subwidget/xrx:inherits/text()
        (: the main widget's class :)
        let $subwidget-class :=
            if($subwidgetclass-id) then
                $xrx:db-base-collection//xrx:id[.=$subwidgetclass-id]/parent::xrx:widget
            else()
        let $widget :=
            if($subwidget-class) then
                xrx:inherit($subwidget-class, $subwidget)
            else
                $subwidget 
        return
        portal:get-js($widget, ())        
    )
};

declare function portal:get-css($super-widget as element(), $main-widget as element()*) as element()* {

    let $super-widget-id := $super-widget/xrx:id/text()
    let $included-widget-ids := 
        (
            $main-widget/xrx:id/text()
            |
            $super-widget//xrx:subwidget/text()
        )
    return
    (
        (: first we look for portal specific css :)
        (: keep the order of the css files! :)
        for $css in $super-widget/xrx:res//xrx:css
    
        return
        
        typeswitch($css/parent::*)
        
        case element(xrx:include) return
        
            css:link($css/text())
        
        case element(xrx:res) return
        
        (
            if($css/xhtml:style) then css:link($super-widget-id) else(),
            $css/xhtml:link
         )
        
        default return ()
        
        ,
        
        (: 
            at the end we make a recursive call of this 
            function if there are widgets included in the
            included widgets
        :)
        for $included-widget-id in $included-widget-ids
        let $included-widget := $xrx:db-base-collection//xrx:id[.=$included-widget-id]/parent::xrx:widget
        let $inherited-widget-id := $included-widget/xrx:inherits/text()
        let $inherited-widget := 
            if($inherited-widget-id) then
                $xrx:db-base-collection//xrx:id[.=$inherited-widget-id]/parent::xrx:widget
            else ()
        let $widget := 
            if($inherited-widget) then 
                xrx:inherit($inherited-widget, $included-widget)
            else
                $included-widget
        return
        portal:get-css($widget, ())
    )

};