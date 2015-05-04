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

module namespace service="http://www.monasterium.net/NS/service";

import module namespace auth="http://www.monasterium.net/NS/auth"
    at "../auth/auth.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";





declare function service:auth($service as element()*) {

    if(not($service)) then
        response:set-status-code(404)
    
    else
        $service/xrx:body
};

(: main function to process services :)
declare function service:process($service as element(xrx:service)) as element() {

    service:preprocess($service)
};

(: basic wrapper construction for services :)
declare function service:preprocess($service as element(xrx:service)) as element() {

    element { 'xrx:service' } {
        
        '{ let $x___ := "" ',
        (: we look if there are local variables defined :)
        for $variable in $service/xrx:variables/xrx:variable
        return
        concat(' let ', $variable/xrx:name/text(), ' := ', $variable/xrx:expression/text()),
        
        ' return ',
        
        service:parse($service/xrx:body),
        
        '}'
    }
    
};

(: function parses the service body :)
declare function service:parse($element as element()) as element() {

    element { node-name($element) } {
    
        $element/@*,
        for $child in $element/child::node()
        return
        typeswitch($child)
        
        case element(xrx:sendmail) return
        
            let $mail :=
                root($child)//xrx:emails/xrx:email[xrx:key=$child/xrx:key/text()]/mail
            return
            (
                ' mail:send-email(',
                $mail,
                ', (), "UTF-8") '
            )
        
        case element() return
            
            service:parse($child)
            
        default return $child
        
    }    
};
