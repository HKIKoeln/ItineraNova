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
module namespace category='http://itineranova.be/NS/category';

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
    
declare namespace xrx="http://www.monasterium.net/NS/xrx";

(:  output has to be XML :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no";

(: add category to category- overview :)
declare function category:add-category($element as element(), $category as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
          return
               if ($child instance of element()) then
                     if(xs:string(fn:node-name($child)) = "xrx:categories")then
                        <xrx:categories>
                            {
                            (
                            let $all-categories := $child//xrx:category
                                for $single-category in $all-categories
                                return
                                    category:add-category($single-category, $category),
                            <xrx:category>{ $category }</xrx:category>)
                            }
                         </xrx:categories>
                     else
                           category:add-category($child, $category)
                 else $child
      }
};

(: remove category to category- overview :)
declare function category:remove-category($element as element(), $category as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if(xs:string(fn:node-name($child)) = "xrx:category" and compare(xmldb:encode($child/text()), $category)=0)then
                        ()
                    else
                        category:remove-category($child, $category)
               else $child
      }
};
