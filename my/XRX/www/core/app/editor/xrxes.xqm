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

module namespace xrxes="http://www.monasterium.net/NS/xrxes";

import module namespace qschema="http://www.monasterium.net/NS/qschema"
    at "../editor/qschema.xqm";
    
   

    



		declare function xrxes:get-attributes($localName, $xsd){ 	
			
			
			let $elmt := qschema:get-attr-elmt($localName, $xsd)
			return
				$elmt
		};
		
		
	
		declare function xrxes:get-menu($localName, $containsElements, $ns, $xsd){ 	
			
			let $options :=  xrxes:get-options($localName, $containsElements, $ns, $xsd)
			
			let $menu := qschema:get-menu($options)
			return
				if ($menu) then 
					$menu
				else
					()
		};
		
		declare function xrxes:get-options($localName, $containsElements, $ns, $xsd){ 	
			
			let  $fwd-elmts := distinct-values(qschema:get-fwd-elmts($localName, (), $xsd))

			let $occurContainIntersection :=
			     for $containElement in $containsElements
			       return qschema:value-intersect(distinct-values(qschema:get-bwd-elmts(qschema:getLocalName($containElement), (), $xsd)), $fwd-elmts)
			
			let $intersectionOfAll := qschema:non-distinct-values-count($occurContainIntersection, count($containsElements))
			
			let $allowed-elements :=
			    if(count($containsElements) gt 0) then
			        $intersectionOfAll
			    else
			        $fwd-elmts
			let $options := qschema:get-options($allowed-elements, $xsd, concat($ns, ':'))
			return
			    <span>
			   		{$options}
			   	</span> 
		
		};
		
		declare function xrxes:get-label($localName, $attrname, $attrvalue, $xsd){ 	
			let $label := qschema:get-the-label($localName, $attrname, $attrvalue, $xsd) 
			return 
				<span>					
					{$label}
				</span>
		};		
		
