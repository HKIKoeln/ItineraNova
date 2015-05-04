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

module namespace widget="http://www.monasterium.net/NS/widget";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace auth="http://www.monasterium.net/NS/auth"
    at "../auth/auth.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
    
    
    
    
(:
    the widget processing main function
:)
declare function widget:process($portal as element(), $main-widget as element()*) as element() {

    widget:preprocess($portal, $main-widget)
};

(:
    function for recursive call
    ( we ignore the xrx:view element )
:)
declare function widget:preprocess($super-widget as element(), $main-widget as element()*) {

    widget:parse($super-widget/xrx:view, $main-widget)/child::node()
};

(:
    widget parser
:)
declare function widget:parse($element as element(), $main-widget as element()*) as element() {

    element { node-name($element) } {
    
        $element/@*,
        for $child in $element/child::node()
        return
        typeswitch($child)
        
        case element(xrx:subwidget) return
        
            let $subwidget-id := $child/text()
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
            widget:preprocess($widget, $main-widget)
        
        case element(xrx:mainwidget) return
        
            widget:preprocess($main-widget, <xhtml:span/>)
        
        case element(xrx:i18n) return
        
            (
                '{i18n:translate(',
                $child,
                ')}'
            )
        
        case element(xrx:auth) return
        
            (
                '{ if(',
                auth:preprocess($child),
                ') then ',
                widget:parse($child/xrx:true/*, $main-widget),
                ' else',
                widget:parse($child/xrx:false/*, $main-widget),
                '}'
            )
            
        case element() return
            
            widget:parse($child, $main-widget)
                    
        default return $child 
    }
};

declare function widget:browser-title($main-widget as element()) {

    concat(
        i18n:translate($main-widget/xrx:title/xrx:i18n),
        ' ',
        string-join(subsequence($xrx:tokenized-uri, 1, count($xrx:tokenized-uri) - 1), '|'),
        ' - ',
        conf:param('platform-browser-title'),
        ' (',
        $main-widget/xrx:id/text(),
        ')'
    )
};