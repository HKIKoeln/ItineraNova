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
module namespace moderator='http://itineranova.be/NS/moderator';

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
    
declare namespace xrx="http://www.monasterium.net/NS/xrx";

(:  output has to be XML :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no";

(: edit moderator in user-file :)
declare function moderator:edit-moderator($element as element(), $moderator as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
          return
               if ($child instance of element()) then
                     if(xs:string(fn:node-name($child)) = "xrx:moderator")then
                        <xrx:moderator>{xmldb:decode($moderator)}</xrx:moderator>
                     else
                           moderator:edit-moderator($child, $moderator)
                 else $child
      }
};

declare function moderator:create-moderator($element as element(), $moderator as xs:string) as element() {
      if(xs:string(fn:node-name($element)) = "xrx:user")then
                        <xrx:user>
                            {
                            let $allNodes := $element//child::*
                                for $node in $allNodes
                                return
                                    local:copy-nodes($node),
                            <xrx:moderator>{xmldb:decode($moderator)}</xrx:moderator>
                            }
                        </xrx:user>
     else ()
};

declare function local:copy-nodes($element as element()) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
          return
               if ($child instance of element()) then
                           local:copy-nodes($child)
              else $child
      }
};
