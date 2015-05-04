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

module namespace pagination="http://www.monasterium.net/NS/pagination";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

declare variable $pagination:parameter-names := '(page|perpage)';
declare variable $pagination:rpage := xs:integer(request:get-parameter('page', '1'));
declare variable $pagination:rperpage := xs:integer(request:get-parameter('perpage', '15'));

declare function pagination:navi($numitems as xs:integer) as element() {

    let $numpages := xs:integer(ceiling($numitems div $pagination:rperpage))
    let $parameter-names := 
        for $name in request:get-parameter-names()
        return
        if(not(matches($name, $pagination:parameter-names))) then $name else ()
    let $copy-parameter :=
       string-join(
          for $parameter-name in $parameter-names
          let $parameter-value := request:get-parameter($parameter-name, '')
          return
          concat($parameter-name, '=', $parameter-value),
          '&amp;'
       )
    return
    <div class="dpagination-navi" xmlns="http://www.w3.org/1999/xhtml">
        {
        for $num in (1 to $numpages)
        let $numstring := xs:string($num)
        return
        <div class="dnavigation-item">
          <a href="{ $xrx:tokenized-uri[last()] }?page={ $numstring }&amp;perpage={ $pagination:rperpage }&amp;{ $copy-parameter }">
            {(
                if($num != $pagination:rpage) then () else attribute id { "selecteda" }, 
                $numstring 
            )}
          </a>
          <span>&#160;</span>
        </div>
        }
    </div>
};

declare function pagination:startstop($numitems as xs:integer) as xs:integer+ {

    let $ start := 
        $pagination:rpage * $pagination:rperpage - $pagination:rperpage + 1
    let $stop := 
        if(($start + $pagination:rperpage - 1) lt $numitems) then 
            $start + $pagination:rperpage - 1 
        else 
            $numitems
    return
    ($start to $stop) 
};
