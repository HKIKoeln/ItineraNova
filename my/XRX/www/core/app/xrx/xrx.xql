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

(: w3c namespaces :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
(: xforms processor specific namespaces :)
declare namespace bf="http://betterform.sourceforge.net/xforms";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
(: database specific namespaces :)
declare namespace file="http://exist-db.org/xquery/file";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

(: module for hit highlighting :)
import module namespace kwic="http://exist-db.org/xquery/kwic";
(: versioning module :)
import module namespace v="http://exist-db.org/versioning";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "xrx.xqm";
import module namespace excel="http://exist-db.org/xquery/excel";

(:
    ##################
    #
    # Internal Variables
    #
    ##################
:)
(:
    load all modules into 
    the XQuery context
:)
declare variable $load-modules := 

    for $module in $xrx:db-base-collection//xrx:modules/xrx:module
    let $module-base-uri := util:collection-name($module)
    let $module-resource := $module/xrx:resource/text()
    let $module-prefix := $module/xrx:prefix/text()
    let $module-uri := xs:anyURI($module/xrx:uri/text())
    let $module-db-uri := xs:anyURI(concat('xmldb:exist://', $module-base-uri, '/', $module-resource))
    return
    util:import-module($module-uri, $module-prefix, $module-db-uri);

(: get the request data stream :)
declare variable $data :=
    request:get-data();    

(:
    ##################
    #
    # Helper Functions
    #
    ##################
:)
declare function local:eval($xrx as element()) {

    let $serialize := util:serialize($xrx, ())
    return
    if($serialize != '') then util:eval($serialize, false())
    else()
};

(: 
    function returns the id of a xrx object
    which is called from outside by a HTTP
    request
    at the moment we assume that the id is
    overloaded by parameter atomid
:)

(:
    get all models which are defined
    in the portal, the main widget
    or embedded widget and all their
    subwidgets
:)
declare function local:get-xforms-model($widget as element()*, $xrx:superwidget as element()*) {

    util:eval('portal:get-models($xrx:superwidget, $widget)')
};

(: 
    link all css and javascript resources
    defined in portal, widgets and subwidgets
:)
declare function local:get-resources() as element()* {

    if($xrx:mainwidget) then
        util:eval('portal:get-resources($xrx:superwidget, $xrx:mainwidget)')
    else
        util:eval('portal:get-resources($xrx:superwidget, $xrx:embeddedwidget)')
};




(:
    ##################
    #
    # Main Functions
    #
    ##################
:)
(: main function to process atom requests :)
declare function local:mode-atom() {
    
    let $atom-action := $xrx:tokenized-uri[2]
    
    return
    
    if($atom-action = 'GET') then util:eval('atom:GET()')
    else if($atom-action = 'PUT') then util:eval('atom:PUT($data)')
    else if($atom-action = 'POST') then util:eval('atom:POST($data)')
    else if($atom-action = 'DELETE') then util:eval('atom:DELETE()')
    else if($atom-action = 'CONTRIBUTE') then util:eval('atom:CONTRIBUTE($data)')
    else()
};

(: main function to process css :)
declare function local:mode-css() {

    (: ID of the CSS :)
    let $css-id :=
        xrx:object-id()
    (: the css :)
    let $css := 
        util:eval('css:get($css-id)')
        
    return
        
    local:eval(util:eval('css:process($css)'))
};

(: main function to process htdocs :)
declare function local:mode-htdoc() {

    (: ID of the static htdoc :)
    let $htdoc-id := 
        $xrx:resolver/xrx:atomid/text()
    (: the htdoc entry :)
    let $htdoc-entry := 
        util:eval('htdoc:get($htdoc-id)')
    (: browser title :)
    let $browser-title := util:eval('htdoc:browser-title($htdoc-entry)')

    return
    local:eval(
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>{ $browser-title }</title>
            { local:get-resources() } 
        </head>
        <body>
            { util:eval('widget:process($xrx:superwidget, $xrx:mainwidget)') }
        </body>
    </html>
    )

};

(: main function to process embedded widgets :)
declare function local:mode-embeddedwidget() {

    local:eval(
    <div xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:bffn="java:de.betterform.xml.xforms.xpath.BetterFormXPathFunctions"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:bf="http://betterform.sourceforge.net/xforms"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
        xmlns:i18n="http://www.monasterium.net/NS/i18n"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:ead="urn:isbn:1-931666-22-9"
        xmlns:tei="http://www.tei-c.org/ns/1.0/"
        xmlns:vre="http://www.monasterium.net/NS/vre"
        xmlns:eap="http://www.monasterium.net/NS/eap"
        xmlns:eag="http://www.archivgut-online.de/eag"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:excel="http://exist-db.org/xquery/excel">
        <div style="display:none">{ local:get-xforms-model($xrx:embeddedwidget, $xrx:superwidget) }</div>
        { local:get-resources() }
        { util:eval('widget:process($xrx:superwidget, $xrx:embeddedwidget)') }
    </div>
    )
};

(: main function to process main widgets :)
declare function local:mode-mainwidget() {

    if($xrx:xformsflag) then
        local:mode-mainwidget-xforms-enabled($xrx:mainwidget, $xrx:superwidget)
    else if(not($xrx:xformsflag)) then
        local:mode-mainwidget-xforms-disabled($xrx:mainwidget, $xrx:superwidget)
    else
        local:mode-mainwidget-xforms-enabled($xrx:mainwidget, $xrx:superwidget) 
};

(: main function to process widgets (XForms disabled) :)
declare function local:mode-mainwidget-xforms-disabled($xrx:mainwidget, $xrx:superwidget) {

    local:eval(
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>{ util:eval('widget:browser-title($xrx:mainwidget)') }</title> 
            { local:get-resources() }
        </head>
        <body>{ util:eval('widget:process($xrx:superwidget, $xrx:mainwidget)') }</body>
    </html>
    )
};

(: main function to process widgets (XForms enabled) :)
declare function local:mode-mainwidget-xforms-enabled($xrx:mainwidget, $xrx:superwidget) {

    let $browser-title := 
        util:eval('widget:browser-title($xrx:mainwidget)')
    return
    local:eval(
    <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:bffn="java:de.betterform.xml.xforms.xpath.BetterFormXPathFunctions"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:bf="http://betterform.sourceforge.net/xforms"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
        xmlns:ead="urn:isbn:1-931666-22-9"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:i18n="http://www.monasterium.net/NS/i18n"
        xmlns:tei="http://www.tei-c.org/ns/1.0/"
        xmlns:vre="http://www.monasterium.net/NS/vre"
        xmlns:eap="http://www.monasterium.net/NS/eap"
        xmlns:eag="http://www.archivgut-online.de/eag"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:excel="http://exist-db.org/xquery/excel">
        <head>
            <title>{ $browser-title }</title>
            { local:get-resources() }
        </head>
        <body>
            <div style="display:none">{ local:get-xforms-model($xrx:mainwidget, $xrx:superwidget) }</div>
            { util:eval('widget:process($xrx:superwidget, $xrx:mainwidget)') }
            <div id="dialog"/>
        </body>
    </html>
    )
};

(: main function to process services :)
declare function local:mode-service() {

    let $service := 
        local:eval(util:eval('service:process($xrx:service)'))/xrx:body/node()
    return
    if($xrx:translateflag) then
        util:eval('i18n:translate-xml($service)')
    else
        $service

};




(:
    ##################
    #
    # Function Calls
    #
    ##################
:)
(:
    Function calls depending on the 
    XRX mode. This XQuery script (xrx.xql)
    only accepts incoming URIs of the
    following form
    
    /atom/?atomid=%SOME_ATOM_ID%
    /css/?atomid=%SOME_ATOM_ID%
    /htdoc/?atomid=%SOME_ATOM_ID%
    /service/?atomid=%SOME_ATOM_ID%
    /embeddedwidget/?atomid=%SOME_ATOM_ID%
    /mainwidget/?atomid=%SOME_ATOM_ID%
    
    where %SOME_ATOM_ID% should follow the rules
    described in the Atom Syndication Format
    (http://www.ietf.org/rfc/rfc4287.txt)
    
    e.g.:
    tag:www.monasterium.net,2011:/mom/service/tei2pdf 
:)
declare function local:main() {
    
    (: mode atom :)
    if($xrx:mode = 'atom') then
    
        (
            util:declare-option('exist:serialize', 'method=xml media-type=application/xml'),
            local:mode-atom()
        )
    
    (: mode css :)
    else if($xrx:mode = 'css') then
    
        (
            util:declare-option('exist:serialize', 'method=text media-type=text/css'),
            local:mode-css()
        )
    
    (: mode htdoc :)
    else if($xrx:mode = 'htdoc') then
    
        (
            util:declare-option('exist:serialize', 'method=xhtml media-type=text/html'),
            local:mode-htdoc()
        )
    
    (: mode service :)
    else if($xrx:mode = 'service') then
    
        (
            util:declare-option('exist:serialize', $xrx:serializeas),
            local:mode-service()
        )
    
    (: mode embedded widget :)    
    else if($xrx:mode = 'embeddedwidget') then
    
        (
            util:declare-option('exist:serialize', 'method=xml media-type=application/xml'),
            local:mode-embeddedwidget()
        )
    
    (: mode main widget (XForms enabled or disabled) :)
    else if($xrx:mode = 'mainwidget') then
        
        if(not($xrx:xformsflag)) then
        (
            util:declare-option('exist:serialize', 'method=xhtml media-type=text/html omit-xml-declaration=no indent=no'),
            local:mode-mainwidget()
        )
        else
        (
            util:declare-option('exist:serialize', 'method=xhtml media-type=text/html omit-xml-declaration=no indent=no'),
            local:mode-mainwidget()        
        )
    
    else()
};

(: 
    we resolve the incoming URI and
    call the xrx mode we found in the
    project's URI resolver
:)
local:main()