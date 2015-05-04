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

(:author daniel.ebner@uni-koeln.de:)

module namespace qxrxa="http://www.monasterium.net/NS/qxrxa";

import module namespace qxrxe="http://www.monasterium.net/NS/qxrxe" at "../editor/qxrxe.xqm";
import module namespace qxsd="http://www.monasterium.net/NS/qxsd" at "../editor/qxsd.xqm";

declare namespace xrxa="http://www.monasterium.net/NS/xrxa";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $qxrxa:default-content-control := 'input';

(:#####################SERVICES BY PATH ############################:)


declare function qxrxa:get-attributes($path, $xsd){    
    for $attribute-info in qxrxe:get-node-relevant-attributes($path, qxsd:xsd($xsd))
        return
        qxrxa:attribute($attribute-info, $xsd)
};


(:#################################################:)

declare function  qxrxa:attribute($attribute-info, $xsd){
    element xrxa:attribute {
        qxrxa:namespace($attribute-info, $xsd),
        qxrxa:name($attribute-info, $xsd),
        qxrxa:label($attribute-info, $xsd),
        qxrxa:control($attribute-info, $xsd),
        qxrxa:html-control($attribute-info, $xsd)
    }
};

declare function qxrxa:namespace($attribute-info, $xsd){
    if(xs:string($attribute-info/@form)="qualified") then
        element xrxa:namespace {xs:string(qxrxe:get-namespace($attribute-info))}
    else 
        ()
};

declare function qxrxa:name($attribute-info, $xsd){
    element xrxa:name {xs:string(qxrxe:get-name($attribute-info))}
};

declare function  qxrxa:label($attribute-info, $xsd){
    element xrxa:label {
        (:handle translation:)
        qxrxa:label-string($attribute-info, $xsd)  
    }
};

declare function  qxrxa:label-string($attribute-info, $xsd){
    (:handle translation:)
    xs:string(qxrxe:get-label($attribute-info, $xsd))    
};

declare function qxrxa:control($attribute-info, $xsd){
    element xrxa:control {
        let $declared-control := qxrxe:get-content-control($attribute-info, $xsd)
        return
        if($declared-control) then
            $declared-control
        else 
            $qxrxa:default-content-control
    }
};

declare function qxrxa:html-control($attribute-info, $xsd){
   <xhtml:div>
        <xhtml:span class="xrxaAttributeLabel">{xs:string(qxrxe:get-label($attribute-info, $xsd))}</xhtml:span>
        {
            element {concat('xhtml:', qxrxa:control($attribute-info, $xsd))} 
                {
                    attribute value {qxrxe:get-value($attribute-info, $xsd)},
                    if(qxrxe:get-fixed($attribute-info, $xsd)) then
                        attribute disabled {'disabled'}
                    else
                        ()
                }
        }
   </xhtml:div>
};





