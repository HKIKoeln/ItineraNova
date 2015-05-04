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

module namespace xrx="http://www.monasterium.net/NS/xrx";

declare namespace xs="http://www.w3.org/2001/XMLSchema";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace resolver="http://www.monasterium.net/NS/resolver"
    at "../resolver/resolver.xqm";


(:
    ##################
    #
    # Platform Variables
    #
    ##################
:)
(: ID of the platform = first URI token :)
declare variable $xrx:platform-id := 
    substring-before(substring-after(request:get-uri(), '/'), '/');
(: DB base collection of all xrx projects :)
declare variable $xrx:db-base-collection :=
    collection('/db/www');




(:
    ##################
    #
    # Pointers for the actual
    # xrx object(s)
    #
    ##################    
    these variables are visible for
    all widgets, services, portals ... 
    
    inside a <xrx:widget/> $xrx:mainwidget 
    can be used as a self-reference
    
    inside a <xrx:service/> $xrx:service 
    can be used as a self-reference
    
    ...
:)
(: the resolver :)
declare variable $xrx:resolver :=
    util:eval('resolver:resolve(request:get-uri())');
(: the mode defined in the resolver :)
declare variable $xrx:mode := 
    $xrx:resolver/xrx:mode/text();
(: the xrx mainwidget :)
declare variable $xrx:mainwidget :=
    xrx:mainwidget();
(: xforms on or off? :)
declare variable $xrx:xformsflag :=
    xrx:xformsflag();
declare variable $xrx:embeddedwidget :=
    xrx:embeddedwidget();
(: the xrx superwidget (portal) of a main or a embedded widget :)
declare variable $xrx:superwidget :=
    xrx:superwidget();
(: the xrx service :)
declare variable $xrx:service := 
    xrx:service();
declare variable $xrx:translateflag :=
    xrx:translateflag();
declare variable $xrx:serializeas := 
    xrx:serializeas();

(: 
    so, we also have a this 
    pointer now for services and 
    main widgets
:)
declare variable $xrx:this :=
    (
        $xrx:mainwidget,
        $xrx:service
    )[1];




(:
    ##################
    #
    # Request Context 
    # Parameters
    #
    ##################    
    these variables are visible for
    all widgets, services, portals ... 
:)
(: the server port :)
declare variable $xrx:port := request:get-server-port();
(: the full server name, with or without port :)
declare variable $xrx:servername := substring-before(substring-after(request:get-url(), 'http://'), '/');
(: sometimes it is helpful to have the complete URL :)
declare variable $xrx:http-request-root := concat('http://', $xrx:servername, concat('/', $xrx:platform-id, '/'));
(: 
    URI path relative to the request root
    e.g.: '../../../' 
:)
declare variable $xrx:request-relative-path :=
    let $tokens := subsequence(tokenize(request:get-uri(), '/'), 4)
    return
    string-join(
        for $token in $tokens
        return
        '../'
        ,
        ''
    );
declare variable $xrx:localhost-request-base-url :=
    concat('http://freyja.uni-koeln.de:8585', conf:param('request-root'));
    (:concat('http://localhost:', conf:param('jetty-port'), conf:param('request-root'));:)
declare variable $xrx:http-icon-root := concat('http://', request:get-server-name(), $xrx:port, concat('/', $xrx:platform-id, '/'), 'icon/');    
(: tokenize each incoming URI :)
declare variable $xrx:_teed-help := 
    tokenize(substring-after(request:get-uri(), concat('/', $xrx:platform-id, '/')), '/');
(: decode and encode it again to have it really consistent :)
declare variable $xrx:tokenized-uri :=
    for $tok in $xrx:_teed-help
    return
    xmldb:encode(xmldb:decode($tok));




(:
    ##################
    #
    # Session Parameters
    #
    ##################
    
    these variables are visible for
    all widgets, services, portals ... 
:)
(: languages configured for this platform :)
declare variable $xrx:configured-languages :=
    conf:param('languages');
    
(: the preferred language of the browser :)
declare variable $xrx:client-lang-key := 
    if(contains(request:get-header('Accept-Language'), '-')) then
    	substring-before(request:get-header('Accept-Language'), '-')
    else 
    	(:Ajax-calls with IE9 have Accept-Language: de :)
    	request:get-header('Accept-Language');
    
(: only for internal usage :)
declare variable $xrx:_platform-lang-key :=
    $xrx:configured-languages/xrx:lang[@old=$xrx:client-lang-key]/@key/string();


(: the ID of the current user :)
declare variable $xrx:user-id := xmldb:get-current-user();
(: the XML description of the current user :)
declare variable $xrx:user-xml := 
    doc(concat(conf:param('xrx-user-db-base-uri'), xmldb:encode($xrx:user-id), '.xml'))/xrx:user;
(: only for internal usage :)
declare variable $xrx:lang-as-string := 
    xs:string(session:get-attribute('lang'));
(: the actual language as xs:string :)

declare variable $xrx:session-id := 
    xs:string(session:get-id());


declare variable $xrx:lang := 
    if($xrx:lang-as-string != '') then $xrx:lang-as-string
    
    else if($xrx:_platform-lang-key != '') then $xrx:_platform-lang-key
    
    else conf:param('default-lang');
(: set the actual language as session attribute :)

declare variable $xrx:_create-session := 
    if(not(session:exists())) then
    (
        session:create(),
        $xrx:lang
    )
    else();
(: only for internal usage :)
declare variable $xrx:_actual-i18n-catalog-db-collection-path :=
    concat(conf:param('xrx-i18n-db-base-uri'), $xrx:lang[1]);
(: the actual i18n catalog db base uri :)
declare variable $xrx:i18n-catalog :=
    collection($xrx:_actual-i18n-catalog-db-collection-path);




(:
    ##################
    #
    # Helper Functions
    #
    ##################
:)

(: function to get the mainwidget in a optimized way :)
declare function xrx:mainwidget() as element()* {

    if($xrx:mode = 'mainwidget') then 
    
        (: ID of the main widget :)
        let $mainwidget-id := 
            $xrx:resolver/xrx:atomid/text()
        (: the main widget :)
        let $main-widget := 
            $xrx:db-base-collection//xrx:id[.=$mainwidget-id]/parent::xrx:widget
        (: ID of the widget class :)
        let $mainwidgetclass-id :=
            $main-widget/xrx:inherits/text()
        (: the main widget's class :)
        let $mainwidget-class :=
            if($mainwidgetclass-id) then
                $xrx:db-base-collection//xrx:id[.=$mainwidgetclass-id]/parent::xrx:widget
            else()
        let $widget :=
            if($mainwidget-class) then
                xrx:inherit($mainwidget-class, $main-widget)
            else
                $main-widget
        return
        $widget
    
    else if($xrx:mode = 'htdoc') then

        (: ID of the htdoc main widget :)
        let $htdocwidget-id := 
            conf:param('xrx-htdoc-main-widget')    
        (: the htdoc main widget :)
        let $htdoc-widget := 
            $xrx:db-base-collection//xrx:id[.=$htdocwidget-id]/parent::xrx:widget
        return
        $htdoc-widget
          
    else()
};

declare function xrx:embeddedwidget() as element()* {
    
    if($xrx:mode = 'embeddedwidget') then
    
        (: ID of the embedded widget :)
        let $embeddedwidget-id :=
            xrx:object-id()
        (: the embedded widget :)
        let $embeddedwidget :=
            $xrx:db-base-collection//xrx:id[.=$embeddedwidget-id]/parent::xrx:widget
        return
        $embeddedwidget
        
    else()
};

declare function xrx:inherit($inherited as element(), $inherits as element()) as element() {

    (: schema ID :)
    let $xsd-id :=
        concat('tag:www.monasterium.net,2011:/core/schema/', $xrx:mode)
    (: the schema in which the xrx object of type widget is described :)
    let $xsd :=
        $xrx:db-base-collection//xrx:id[.=$xsd-id]/parent::xrx:xsd
    (: get all element names of the second level :)
    let $secondlevel-element-names :=
        $xsd//xs:schema/xs:element[@name=$xrx:mode]//xs:element/@name/string()
    (: 
        get all second level elements, either
        the one of the main widget or the one
        of the inherited widget
    :)
    let $secondlevel-elements :=
        for $element-name in $secondlevel-element-names
        let $inherited-element :=
            $inherited/*[local-name(.)=$element-name]
        let $element :=
            $inherits/*[local-name(.)=$element-name]
        return
        if($element/node()) then
            $element
        else
           $inherited-element 
        
    return
    
    element { concat('xrx:', $xrx:mode) }{
        $secondlevel-elements
    }
    
};

(: 
    function to get a main widget's class in a 
    optimized way (if a main widget inherits another)
:)
declare function xrx:mainwidgetclass() as element()* {

    if($xrx:mode = 'mainwidget') then
    
        (: ID of the main widget class :)
        let $mainwidgetclass-id :=
            $xrx:mainwidget/xrx:inherits/text()
        let $mainwidgetclass :=
            $xrx:db-base-collection//xrx:id[.=$mainwidgetclass-id]/parent::xrx:widget
        return
        $mainwidgetclass
        
    else()
};

(: function to get the superwidget in a optimized way :)
declare function xrx:superwidget() as element()* {

    if($xrx:mainwidget) then
    
        (: the ID of the portal used by the main widget :)
        let $superwidget-id := 
            $xrx:mainwidget/xrx:portal/text()
        (: the portal used by the main widget:)
        let $superwidget :=
            $xrx:db-base-collection//xrx:id[.=$superwidget-id]/parent::xrx:portal
        return
        $superwidget
    
    else if($xrx:embeddedwidget) then
    
        (: the ID of the portal used by the embedded widget :)
        let $superwidget-id := 
            $xrx:embeddedwidget/xrx:portal/text()
        (: the portal used by the main widget:)
        let $superwidget :=
            $xrx:db-base-collection//xrx:id[.=$superwidget-id]/parent::xrx:portal
        return
        $superwidget   
    
    else()
};

(: 
    function returns the xforms flag as xs:boolean
    xforms flag 'true' = xforms 'on'
    xforms flag 'false' = xforms 'off' 
:)
declare function xrx:xformsflag() as xs:boolean {

    if($xrx:mode = 'mainwidget') then
    
        (: processor init defined by widget :)
        let $flag := $xrx:mainwidget/xrx:init/xrx:processor/xrx:xformsflag/text()
        return
        if(($flag = 'true' and xmldb:get-current-user() != 'guest') or matches($xrx:tokenized-uri[last()], '(registration|request-password|iipmooviewer)')) then true()
        else if($flag = 'false') then false()
        else false()
    
    else false()
};

(: function to get the service in a optimized way :)
declare function xrx:service() as element()* {
  
    if($xrx:mode = 'service') then
        
        (: ID of the service :)
        let $service-id :=
            if(xrx:object-id() != '') then
                xrx:object-id()
            else
                $xrx:resolver/xrx:atomid/text()
        (: the service :)
        let $service :=
            $xrx:db-base-collection//xrx:id[.=$service-id]/parent::xrx:service
        (: ID of the service class :)
        let $serviceclass-id :=
            $service/xrx:inherits/text()
        (: the service class :)
        let $service-class :=
            if($serviceclass-id) then
                $xrx:db-base-collection//xrx:id[.=$serviceclass-id]/parent::xrx:service
            else()
        let $inherited-service :=
            if($service-class) then
                xrx:inherit($service-class, $service)
            else
                $service
        return
        $inherited-service
        
    else()
};

declare function xrx:translateflag() as xs:boolean {

    if($xrx:mode = 'service') then
    
        let $flag := $xrx:service/xrx:init/xrx:processor/xrx:translateflag/text()
        return
        if($flag = 'true') then true()
        else if($flag = 'false') then false()
        else false()
        
    else false()
};

declare function xrx:serializeas() as xs:string {

    if($xrx:mode = 'service') then
    
        let $option := $xrx:service/xrx:init/xrx:processor/xrx:serializeas/text()
        return
        if(exists($option)) then xs:string($option)
        else 'method=xml media-type=application/xml'
        
    else ''
};

(: 
    get the atom ID of the xrx objects 
    which are not controlled by the resolver,
    e.g. services or css resources
:)
declare function xrx:object-id() as xs:string {

    request:get-parameter('atomid', '')
};

declare function xrx:request-query-string($param-name as xs:string*, $param-value as xs:string*) {
    let $query-string := 
        string-join(
        (
            for $name in request:get-parameter-names()
            return
            if($name != $param-name and not(starts-with($name, '_'))) then
                concat(
                    $name,
                    '=',
                    request:get-parameter($name, '')
                )
            else(),
            concat(
                $param-name,
                '=',
                $param-value
            )
        )
            ,'&amp;'
        )
    return
    concat(
        '?', 
        $query-string
    )
};