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



(:
    ##################
    #
    # CSS Module
    #
    ##################
    
    
    A module that handles CSS rules which are
    defined in XRX widgets or portals
    
    Since this module is included by xrx.xql
    these functions and variables are visible 
    for all widgets, services, portals ...
:)

module namespace css="http://www.monasterium.net/NS/css";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

(:
    compose CSS URI by overloading a 
    Atom ID 
:)
declare function css:uri($atom-id as xs:string) as xs:string {

    concat(
        conf:param('css-request-base-uri'),
        'style.css?atomid=',
        $atom-id
    )    
};

(:
    function creates a css HTML resource link
    which can be interpreted by xrx.xql
:)
declare function css:link($atom-id as xs:string) as element() {

    <link xmlns="http://www.w3.org/1999/xhtml" 
        rel="stylesheet" 
        type="text/css" 
        href="{ css:uri($atom-id) }"/>
};

(:
    returns a element of type xrx:css
    by overloading a Atom ID
:)
declare function css:get($atom-id as xs:string) as element()* {

    let $id-element := $xrx:db-base-collection//xrx:id[.=$atom-id]
    let $parent-element := $id-element/parent::*
    
    return

    typeswitch($parent-element)
    
    case element(xrx:portal) return 
    
        $parent-element/xrx:res/xrx:css
    
    case element(xrx:widget) return

        let $inherited-widget-id := 
            $parent-element/xrx:inherits/text()
        let $inherited-widget :=
            $xrx:db-base-collection//xrx:id[.=$inherited-widget-id]/parent::xrx:widget
        return
        (
            $parent-element/xrx:res/xrx:css,
            $inherited-widget/xrx:res/xrx:css
        )[1]
    
    case element(xrx:css) return 
    
        $parent-element
    
    default return ()
}; 

(:
    process the XML fragment
:)
declare function css:process($css) {
    
    $css/xhtml:style
};
