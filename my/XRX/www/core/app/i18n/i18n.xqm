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

module namespace i18n="http://www.monasterium.net/NS/i18n";

declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

(:
    ##################
    #
    # i18n System
    #
    ##################
    
    Since this module is included by xrx.xql
    these functions and variables are visible 
    for all widgets, services, portals ...
:)

(:
    ##################
    #
    # Variables
    #
    ##################
:)
(: DB base collection of all i18n messages :)
declare variable $i18n:db-base-collection-path :=
    conf:param('xrx-i18n-db-base-uri');
(: DB base collection where all i18n messages are stored :)
declare variable $i18n:db-base-collection :=
    collection(
        $i18n:db-base-collection-path
    );

(:
    ##################
    #
    # Functions
    #
    ##################
:)
(: 
    helper function to get either 
    the default translation or the
    one of the i18n catalog
:)
declare function i18n:value($key as xs:string, $lang as xs:string) {
    
    collection(
        concat(
            $i18n:db-base-collection-path,
            $lang
        )
    )//xrx:i18n[xrx:key = xs:string($key)]/xrx:text/text()
};

declare function i18n:value($key as xs:string, $lang as xs:string, $default as xs:string) {
    
    let $value :=
        collection(
            concat(
                $i18n:db-base-collection-path,
                $lang
            )
        )//xrx:i18n[xrx:key = xs:string($key)]/xrx:text/text()
    return
    if($value != '') then $value else $default
};

(: 
    returns a element of type i18n:label 
    by overloading a key and a language 
:)
declare function i18n:message($key as xs:string, $lang as xs:string) as element()* {
    
    collection(
        concat(conf:param('xrx-i18n-db-base-uri'), $lang)
    )//xrx:i18n[xrx:key = xs:string($key)]
};

(:
    returns the default value of a i18n
    message by overloading a key
:)
declare function i18n:default-value($key as xs:string) {
    
    ($i18n:db-base-collection//xrx:i18n[xrx:key = xs:string($key)]/xrx:default/text())[1]
};

(:
    returns the (default) translation
    of a xrx:i18n element construction
:)
declare function i18n:translate($element as element(xrx:i18n)) {

    let $key-to-serach := $element/xrx:key/text()
    let $text := $xrx:i18n-catalog//xrx:i18n[xrx:key = xs:string($key-to-serach)]/xrx:text/text()
    return
    if($text != '') then 
        $text
    else 
        $element/xrx:default/text()
};

(:
    translates a whole XML document
:)
declare function i18n:translate-xml($element as element(*))
{
    element {node-name($element)}
    {
        $element/@*,
        for $child in $element/node()
        return
        if($child instance of element()) then
            if(xs:string(name($child)) = 'xrx:i18n') then
                i18n:translate($child)
            else 
                i18n:translate-xml($child)
        else $child
    }
};

declare function i18n:message-mark-non-active($entry as element(atom:entry)) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:xrx="http://www.monasterium.net/NS/xrx" 
        version="1.0">
      <xsl:template match="xrx:i18n">
        <xsl:element name="xrx:i18n">
          <xsl:attribute name="activeflag">false</xsl:attribute>
          <xsl:copy-of select="*"/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>    
    return
    transform:transform($entry, $xslt, ())
};
