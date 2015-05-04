xquery version"1.0";

(:TODO




-add path to node info
-name-for-path := local-name + pre

- xrxa
-get-menu
-get-options
--get-relevant-elements
--get-relevant-in-content
--get-relevant-for-selection
- annotation-options: check content + selection

- make xrxe-services only http-facade / destroy qschema include qxrxe-services and xrxes

- don't use a template

-----------------------------------------------------------------------------

- create new instance by submission
- add validation with eXist?

- choice editor
- sequence editor
- all editor
- handle sequence choice all (min and max adding and removing choice-> select)
- xs:simpleContent xs:complexContent xs:restrictions xs:extentions
~ move up
~ move down
- make mix elements order possibel (head p head p)

- create node-editor service for subeditors
- node editor only with doc-id
- non embeded subeditors 
- embed whole editor and load by script (the param has to be posted to the load-script ig foc is xml db/load.xql)

- umask only elements that are bound to a control

//TEST
- test if schemas and documents can be accessed via http
- can dialogs be within the traversion?
- works without prefixes?

- insert simpleTypes an let xforms use them (ask betterform list if it should work)
- add validation with xforms?

- xs:any
- xs:include
- images for triggers





:)

module namespace xrxe='http://www.monasterium.net/NS/xrxe';

import module namespace qxrxe="http://www.monasterium.net/NS/qxrxe" at "../editor/qxrxe.xqm";
import module namespace qxsd="http://www.monasterium.net/NS/qxsd" at "../editor/qxsd.xqm";
import module namespace xrxe-ui="http://www.monasterium.net/NS/xrxe-ui" at "../editor/xrxe-ui.xqm";
import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";
import module namespace upd="http://www.monasterium.net/NS/upd"  at "../upd/upd.xqm"; 

(:TODO declare dynamically only when $conf/@xforms-processor='betterform':)
declare namespace bf="http://betterform.sourceforge.net/xforms";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
declare namespace functx = "http://www.functx.com"; 

(: ### ping function to test the availability of the module  ### :)
declare function xrxe:ping($param){
        let $ping := <div>editor module available
        				{$param}
        			</div>
        return
            $ping
};

declare function xrxe:editor($param){ 
        
        let $conf := xrxe:set-conf($param)  
        let $xsd := xrxe:get-xsd($param)       
        return 
            
            xrxe:create-document-editor-widget($xsd, $conf)    
            
};

declare function xrxe:subeditor($param){ 
        
        let $conf := xrxe:set-conf($param)        
        let $xsd := xrxe:get-xsd($param) 
        return
            xrxe:create-node-editor-widget($xsd, $conf)           
};


(:### function should  morphe the config with the default config###:)
declare function xrxe:set-conf($param){

(: string values :)   
       
let $search-id-in := 
    if ($param/@search-id-in and string($param/@search-id-in)!='') then 
        $param/@search-id-in    
    else
        $xrxe-conf:default-search-id-in
       
(: boolean values :)

let $direct-attribute-editing  :=
    if ($param/@direct-attribute-editing and (string($param/@direct-attribute-editing)='true' or string($param/@direct-attribute-editing)='false')) then 
        xs:boolean($param/@direct-attribute-editing)    
    else
        $xrxe-conf:default-direct-attribute-editing

let $disable-attribute-editing  :=
    if ($param/@disable-attribute-editing and (string($param/@disable-attribute-editing)='true' or string($param/@disable-attribute-editing)='false')) then 
        xs:boolean($param/@disable-attribute-editing)    
    else
        $xrxe-conf:default-disable-attribute-editing

let $disable-insert-elements  :=
    if ($param/@disable-insert-elements and (string($param/@disable-insert-elements)='true' or string($param/@disable-insert-elements)='false')) then 
        xs:boolean($param/@disable-insert-elements)    
    else
       $xrxe-conf:default-disable-insert-elements
         

let $disable-delete-elements  :=
    if ($param/@disable-delete-elements and (string($param/@disable-delete-elements)='true' or string($param/@disable-delete-elements)='false')) then 
        xs:boolean($param/@disable-insert-elements)    
    else
        $xrxe-conf:default-disable-delete-elements

let $direct-delete-elements  :=
    if ($param/@direct-delete-elements and (string($param/@direct-delete-elements)='true' or string($param/@direct-delete-elements)='false')) then 
        xs:boolean($param/@direct-delete-elements)    
    else
        $xrxe-conf:default-direct-delete-nodes
        
let $xrx-development  :=
    if ($param/@xrx-development and (string($param/@xrx-development)='true' or string($param/@xrx-development)='false')) then 
        xs:boolean($param/@xrx-development)    
    else
        $xrxe-conf:default-xrx-development       
      
 let $debug  :=
    if ($param/@debug and (string($param/@debug)='true' or string($param/@debug)='false')) then 
        xs:boolean($param/@debug)    
    else
        $xrxe-conf:default-debug
        
let $services := 
    if ($param/@services and string($param/@services)!='') then 
        $param/@services   
    else
         $xrxe-conf:services




let $place-triggers  := 
    if ($param/@place-triggers and (string($param/@place-triggers)='bottom' or string($param/@place-triggers)='top' or string($param/@place-triggers)='top-and-bottom') or string($param/@place-triggers)='no' ) then 
        xs:string($param/@place-triggers)    
    else
        $xrxe-ui:default-place-triggers

(:no defaults:)

let $node-path := 
    if ($param/@node-path and string($param/@node-path)!='') then 
        $param/@node-path    
    else
        ''
        
let $template-node-path := 
    if ($param/@template-path and string($param/@template-path)!='') then 
        $param/@template-path    
    else
        ''
        
let $xsd-context-path := 
    if ($param/@xsd-context-path and string($param/@xsd-context-path)!='') then 
        $param/@xsd-context-path    
    else
        ''



let $save := 
    if ($param/@save and string($param/@save)!='') then 
        $param/@save   
    else
        ()
        
let $save-close := 
    if ($param/@save-close and string($param/@save-close)!='') then 
        $param/@save-close   
    else
        ()
        
let $xsdloc := 
    if ($param/@xsd and string($param/@xsd)!='') then 
        $param/@xsd
    else
        ()

let $docloc := 
    if ($param/@doc and string($param/@doc)!='') then 
        $param/@doc
    else
        ()
        
let $templateloc := 
    if ($param/@template and string($param/@template)!='') then 
        $param/@template
    else
        ()

let $ui-template := xrxe:get-ui-template($param)


let $doc := xrxe:set-doc-conf($param) 

let $xsd :=xrxe:get-xsd($param)

let $template := xrxe:set-template-conf($param)  
       
let $conf  :=  element conf {
       if($direct-attribute-editing) then
            attribute direct-attribute-editing {string($direct-attribute-editing)}
       else (),
       
       if($disable-attribute-editing) then
            attribute disable-attribute-editing {string($disable-attribute-editing)}
       else (),
       if($disable-insert-elements) then
            attribute disable-insert-elements  {string($disable-insert-elements)}
       else (),
       if($disable-delete-elements) then
            attribute disable-delete-elements   {string($disable-delete-elements)}
       else (),
       if($direct-delete-elements) then
            attribute direct-delete-elements   {string($direct-delete-elements)}
       else (),
       if($xrx-development) then
            attribute xrx-development   {string($xrx-development)}
       else (),       

       
       attribute search-id-in {$search-id-in},
       if($node-path) then
            attribute node-path {string($node-path)}
       else (),
       if($template-node-path) then
            attribute template-node-path {string($template-node-path)}
       else (),
       if($xsd-context-path) then
            attribute xsd-context-path {string($xsd-context-path)}
       else (),
       
       if($services) then
            attribute services {string($services)}
       else (),
       if($save) then
            attribute save {string($save)}
       else (),
       if($save-close) then
            attribute save-close {string($save-close)}
       else (),
       if($debug) then
            attribute debug {string($debug)}
       else (),       
       if($place-triggers) then
            attribute place-triggers {string($place-triggers)}
       else (),
        if($xsdloc) then
            attribute xsdloc {string($xsdloc)}
       else (),
        if($docloc) then
            attribute docloc {string($docloc)}
       else (),
        if($templateloc) then
            attribute templateloc {string($templateloc)}
       else (),
       
       (: ELEMENTS :)
       if($xsd) then
            element xrxe:xsd {$xsd}
       else (),
       if($ui-template) then
            element xrxe:ui-template {$ui-template/node()}
       else (),       
        if($doc) then
            element xrxe:doc {$doc}
       else (),       
       if($template) then
            element xrxe:template {$template}
       else () 
     }
    return $conf
};

declare function xrxe:get-xsd($param){
    
    let $xsd := 
    if($param/xrxe:xsd[1]/element()) then
            $param/xrxe:xsd[1]/element()
    else if($param/xrxe:xsd[1]/text()) then
            xs:string($param/xrxe:xsd[1]/text())
    else if($param/@xsd) then
            xs:string($param/@xsd)
    else()    
    return  qxsd:xsd($xsd)
};

(:$doc is not a document-node but the root element node of a document:)
declare function xrxe:set-doc-conf($param){   

    if($param/xrxe:doc[1]/element()) then
        $param/xrxe:doc[1]/element()
    else if($param/xrxe:doc[1]/text()) then
         xrxe:get(xs:string($param/xrxe:doc[1]/text()))
    else if($param/@doc) then
         xrxe:get(xs:string($param/@doc))
    else()

    
   
};

declare function xrxe:set-template-conf($param){        
    
    let $template-node :=  
        if($param/xrxe:template[1]/element()) then
            $param/xrxe:template[1]/element()
        else if($param/xrxe:template[1]/text()) then
             xrxe:get(xs:string($param/xrxe:template[1]/text()))
        else if($param/@template) then
             xrxe:get(xs:string($param/@template))
        else()

    return
    if($template-node) then
        let $declare-namespaces :=  xrxe:declare-namespaces($template-node)
        
        let $template-path := 
             if($param/@template-path and string($param/@template-path)!='')     then
                 xs:string($param/@template-path)
             else 
                 '/element()'        
    
        (:document-node or xrxe:template:)
        let $template-doc := 
            if($template-node/parent::*) then
                $template-node/parent::*
            else
                root($template-node)
        
        let $get-template := concat('$template-doc' , $template-path, '[1]') 
        return util:eval($get-template) 
        
    else
        let $template := qxrxe:get-node-template(concat($param/@xsd-context-path, '/',functx:substring-after-last($param/@node-path, '/')), xs:string($param/@xsd))
        let $declare-namespaces :=  xrxe:declare-namespaces($template)
        return $template

};

declare function xrxe:get-template($conf){
    qxrxe:copy($conf/xrxe:template/element())
};

(:### function to get the editor's root node out off the doc by xpath ###:)
declare function xrxe:get-menu($param){
        
        let $param-menu :=
        if($param/xrxe:menu[1]) then
            $param/xrxe:menu[1]
        else if($param/@menu) then
            string($param/@menu)
        else()    
    return  xrxe:get($param-menu) 
};

(:### function to get the editor's root node out off the doc by xpath ###:)
declare function xrxe:get-ui-template($param){
        
        let $param-ui-template :=
        if($param/xrxe:ui-template[1]) then
            $param/xrxe:ui-template[1]
        else if($param/@ui-template) then
            string($param/@ui-template)
        else()
    
    let $ui-template :=  xrxe:get($param-ui-template)     
    return $ui-template
};

(:### function to give back the element root node defined in one 3 ways (db-path, id, or node)###:)
declare function xrxe:get($something){    
    let $node := 
        if($something instance of xs:string) then
            if (exists(doc($something))) then
                doc($something)/element()
            else if (collection($xrxe-conf:default-search-id-in)/*[@id=$something]) then
                collection($xrxe-conf:default-search-id-in)/*[@id=$something]    
            else ()
        
        else if ($something instance of node()) then
            if($something instance of document-node()) then
                $something/element()
            else
                $something
        else
            ()   
    (: return functx:node-kind($node) :)       
    return $node
};

(:### function to  preprocess the editors rood node for example to escape mixed content###:)
declare function xrxe:pre-transform($doc-root-node, $template){
     let $escape-xslt :=
        xrxe:create-escape-mixed-content-xslt($template)
    
    let $editor-node := 
        if($escape-xslt) then
            transform:transform($doc-root-node, $escape-xslt, ()) 
        else 
            $template
    return $editor-node
};


declare function xrxe:create-escape-mixed-content-xslt($template){

let $escape-match:= xrxe:get-leaf-nodes-to-escape-match($template)

(:
        let $stylesheet := util:eval(concat('<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"', xrxe:create-xmlns-string($conf/xrxe:template/element()), ' />'))

        let $templates := (
                  <xsl:template match="{{$escape-match}}">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                ,
                <xsl:template match="*">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                ,
                <xsl:template name="leaveNode">
                    <xsl:param name="escape"/>
                    <xsl:copy>
                        <xsl:copy-of select="./@*"/>
                        <xsl:apply-templates>
                            <xsl:with-param name="escape" select="$escape"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:template>
                ,
                <xsl:template name="writeEscapedNode">
                    <xsl:param name="escape"/>
                    <xsl:call-template name="escapedStartTag"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="escape" select="$escape"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="escapedEndTag"/>
                </xsl:template>
                ,
                <xsl:template name="escapedStartTag">
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:for-each select="./@*">
                        <xsl:call-template name="escapedAttribute"/>
                    </xsl:for-each>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
                ,
                <xsl:template name="escapedAttribute">
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:template>
                ,
                <xsl:template name="escapedEndTag">
                    <xsl:text>&lt;/</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
                )
            
        return upd:insert-into($stylesheet, $templates)  
:)

return 
            
            
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
                <xsl:template match="{$escape-match}">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                <xsl:template match="*">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                <xsl:template name="leaveNode">
                    <xsl:param name="escape"/>
                    <xsl:copy>
                        <xsl:copy-of select="./@*"/>
                        <xsl:apply-templates>
                            <xsl:with-param name="escape" select="$escape"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:template>
                <xsl:template name="writeEscapedNode">
                    <xsl:param name="escape"/>
                    <xsl:call-template name="escapedStartTag"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="escape" select="$escape"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="escapedEndTag"/>
                </xsl:template>
                <xsl:template name="escapedStartTag">
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:for-each select="./@*">
                        <xsl:call-template name="escapedAttribute"/>
                    </xsl:for-each>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
                <xsl:template name="escapedAttribute">
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:template>
                <xsl:template name="escapedEndTag">
                    <xsl:text>&lt;/</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
            </xsl:stylesheet>
            
};

declare function functx:leaf-elements ( $root as node()? )  as element()* {
   $root/descendant-or-self::*[not(*)]
 } ;

(: Declare all Namespaces from the Template/XSD :)
declare function xrxe:declare-namespaces($node){

for $xmlns in  xrxe:get-all-xmlns($node)
    return util:declare-namespace(xs:string($xmlns/@prefix), xs:anyURI($xmlns/@namespace))

(:for $pre in  fn:in-scope-prefixes($node)
   let $ns := fn:namespace-uri-for-prefix($pre, $node)
   return
    (:Namespace predefined prefix 'xml' can not be bound (eXist error message):)
    (:TODO use qxrxe:declare-namespace:)
    if($pre='xml')then
        ()
    else:)
        
};

 declare function xrxe:get-xmlns($nodes) {
  let $all-xmlns :=
    for $node in $nodes
        return xrxe:get-all-xmlns ($node)

  for $prefix in distinct-values($all-xmlns/@prefix)
     return
     <xmlns prefix="{$prefix}" namespace="{subsequence($all-xmlns[@prefix=$prefix]/@namespace, 1, 1)}"/>
}; 

declare function xrxe:get-all-xmlns ($node){
    for $node in $node//element() | $node//attribute()
        let $prefix := prefix-from-QName(node-name($node))
        let $namespace := namespace-uri-from-QName(node-name($node))
            return
                if($prefix and $namespace and $prefix!='xml') then
                    <xmlns prefix="{$prefix}" namespace="{$namespace}" />
                else ()
 } ;

declare function xrxe:get-leaf-nodes-to-escape-match($template){
        let $leafs := functx:leaf-elements($template)
        let $leaf-paths :=
            for $leaf in $leafs
            return 
                xrxe:data-path($leaf)
                (:OLD  xrxe:path-to-node($leaf):)
   
        let $escape-match := string-join($leaf-paths, ' | ')
        return $escape-match
};

declare function xrxe:create-document-editor-widget($xsd, $conf){
    util:eval(xrxe:create-widget-string('DocumentEditor', $conf))  
};

declare function xrxe:create-node-editor-widget($xsd, $conf) {
    util:eval(xrxe:create-widget-string('NodeEditor', $conf))
};

declare function xrxe:create-widget-string($switch, $conf){

    let $before:= '<div class="xrxeEditor"'
    let $namespaces := 
        if($switch='DocumentEditor') then
            xrxe:create-xmlns-string($conf/xrxe:doc/element())  
        else
            xrxe:create-xmlns-string($conf/xrxe:template/element()) 
    
      
    
    let $after := 
        if($switch='DocumentEditor') then
            ">{(xrxe:create-document-editor($xsd, $conf))}</div>"
        else
            ">{(xrxe:create-node-editor($xsd, $conf))}</div>"
            
    
    return concat($before, $namespaces, $after)
};

declare function xrxe:create-xmlns-string($nodes){    
        
    let $xmlns-string :=
        string-join(
        for $xmlns  in xrxe:get-xmlns($nodes)
            let $pre := $xmlns/@prefix
            let $ns := $xmlns/@namespace
            return  concat('xmlns:' , $pre , '="' , $ns, '"')
    ,
    ' ')
    
     let $dummy-string := 
     string-join(
        for $xmlns  in xrxe:get-xmlns($nodes)
            let $pre := xs:string($xmlns/@prefix)
                return concat($pre, ':dummy="prevent xmlns in this element"')            
    ,
    ' ') 
    return concat($xmlns-string, ' ',  $dummy-string)
};



declare function xrxe:create-document-editor($xsd, $conf){
    (
 

        if($conf/@debug) then
            (
            xrxe:create-conf($conf)
            )
        else()
        ,
        xrxe:create-document($xsd, $conf)
    )
};

 (:######################## *** CONF MODEL *** ############################:)

declare function xrxe:create-conf($conf){
    xrxe:create-conf-model($conf)
};

declare function xrxe:create-conf-model($conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:model id="m-conf">
        {xrxe:create-conf-instance($conf)}
    </xf:model>
};

declare function xrxe:create-conf-instance($conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:instance id="i-conf">
        <conf ns="">
            {$conf}
        </conf>
    </xf:instance>
};

 (:######################## *** XSD MODEL *** ############################:)
 
 declare function xrxe:create-xsd($xsd, $conf){
    xrxe:create-xsd-model($xsd, $conf)
};

declare function xrxe:create-xsd-model($xsd, $conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:model id="m-xsd">
        {xrxe:create-xsd-instance($xsd, $conf)}
    </xf:model>
};

declare function xrxe:create-xsd-instance($xsd, $conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:instance id="i-xsd">
        <xsd ns="">
            {$xsd}
        </xsd>
    </xf:instance>
};

(:######################## *** TEMPLATE MODEL *** ############################:)
 
 declare function xrxe:create-template($template, $conf){
    (
    xrxe:create-template-model($template, $conf)
    )
};

declare function xrxe:create-template-model($template, $conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:model id="m-template">
        {xrxe:create-template-instance($template, $conf)}
    </xf:model>
};

declare function xrxe:create-template-instance($template, $conf){
    (:TODO: change ID, use ID Functions and Variables and use an ID:)
    <xf:instance id="i-template">
        <template ns="">
            {$template}
        </template>
    </xf:instance>
};

(:######################## *** DOCUMENT MODEL *** ############################:)

declare function xrxe:create-document($xsd, $conf){
    (
     xrxe:create-document-model($conf)
     ,
     xrxe:create-document-view($xsd, $conf)
     )
};

declare function xrxe:create-document-model($conf){
        <xf:model id="{xrxe:document-model-id($conf)}">
                {(
                xrxe:create-document-instance($conf)
                ,
                if($conf/xrxe:ui-template) then 
                    xrxe:xreate-document-helper-instances($conf)
                else ()
                ,                             
                xrxe:create-document-submissions($conf)               
                )}
         </xf:model>
};

declare function xrxe:xreate-document-helper-instances($conf){
 
    (
    xrxe:create-load-instance($conf)
    ,
    xrxe:create-ui-template-instance($conf)
    )
};


declare function xrxe:create-load-instance($conf){

    (:ui:)
    <xf:instance id="{xrxe:load-instance-id($conf)}">
        <load xmlns="">
        {
            for $node-editor-id in $conf/xrxe:ui-template/xrxe:ui//xrxe:node-editor/@id
                return element {xs:string($node-editor-id)} {true()}
        }
        </load>
    </xf:instance>

};

declare function xrxe:create-ui-template-instance($conf){
    <xf:instance id="i-ui-template">
            <ui-template xmlns="">
            {
                $conf/xrxe:ui-template/xrxe:template/element()
            }
            </ui-template>        
        </xf:instance> 
};

declare function xrxe:create-document-submissions($conf){
    let $submission := 
        (
            xrxe:create-save-document-submission($conf)
            ,
            xrxe:create-unescape-document-submission($conf)         
        )
   return $submission
};

declare function xrxe:create-unescape-document-submission($conf){       
        <xf:submission id="{xrxe:unescape-document-submission-id($conf)}" resource="{xs:string($conf/@services)}?service=unescape-mixed-content"  ref="{xrxe:document-instance-string($conf)}" method="POST" instance="{xrxe:document-instance-id($conf)}" replace="instance">
           {(
           xrxe:create-submission-message('xforms-submit-error', $xrxe-ui:unescape-submit-error)
           ,              
           xrxe:create-submission-chain('xforms-submit-done', xrxe:save-document-submission-id($conf))
           )}               
        </xf:submission>
};

declare function xrxe:create-save-document-submission($conf){        
        (:Can this be decided where conf is set?:)
        let $method := if($conf/@xrx-development) then
            'post'
        else
            'put'
        
        return
            <xf:submission id="{xrxe:save-document-submission-id($conf)}" replace="none" ref="{xrxe:document-instance-string($conf)}/child::element()[1]" method="{$method}" resource="{$conf/@save}">           
               {(
               xrxe:create-submission-message('xforms-submit-done', $xrxe-ui:document-saved)
               ,
               xrxe:create-submission-message('xforms-submit-error', $xrxe-ui:save-error)
               )}        
            </xf:submission>
};

declare function xrxe:create-document-instance($conf){   
    <xf:instance id="{xrxe:document-instance-id($conf)}"> 
        <document xmlns="">
            {$conf/xrxe:doc/element()[1]}
        </document>
    </xf:instance>
};

(:######################## *** XFORMS MODEL UTIL *** ############################:)

(:MOVE TO NICE PLACE:)
declare function xrxe:create-submission-chain($event, $id){
    <xf:action ev:event="{$event}">
       <xf:send submission="{$id}" />
   </xf:action>
};

(:MOVE TO NICE PLACE:)
declare function xrxe:create-submission-message($event, $message){
    <xf:action ev:event="{$event}">
        <xf:message>{$message}</xf:message>               
   </xf:action>
};

(:######################## *** DOCUMENT VIEW *** ############################:)

declare function xrxe:create-document-view($xsd, $conf){
        
<xf:group model="{xrxe:document-model-id($conf)}" class="xrxeEditorGroup">
    {( 
        if(xs:string($conf/@place-triggers)='top' or xs:string($conf/@place-triggers)='top-and-bottom') then
             xrxe:create-document-triggers($conf)
        else
            ()
        ,            
        if($conf/xrxe:ui-template) then
            xrxe:create-document-ui($xsd, $conf)        
        else if ($conf/xrxe:template) then
            xrxe:create-node-editor($xsd, $conf)
        else ()    
        ,
        if(xs:string($conf/@place-triggers)='bottom' or xs:string($conf/@place-triggers)='top-and-bottom') then
            xrxe:create-document-triggers($conf)
        else
            ()
    )}
</xf:group>

};

declare function xrxe:create-document-triggers($conf){

    <xf:group class="xrxeEditorTriggers xrxeTriggers xrxeGroup">
    {
        (     
        if ($conf/@save) then
            xrxe:create-save-trigger($conf)
        else
            ()
        ,
        if ($conf/@save-close) then
            xrxe:create-save-close-trigger($conf)
        else 
            ()        
        )
    }
    </xf:group>
};

declare function xrxe:create-unescape-trigger($conf){
    let $trigger :=
        <xf:trigger class="xrxeTrigger">
            <xf:label>Unescape</xf:label>
            <xf:send submission="{xrxe:unescape-document-submission-id($conf)}" />
        </xf:trigger>
    return $trigger
};

declare function xrxe:create-save-trigger($conf){
        <xf:trigger class="xrxeTrigger xrxeSaveTrigger" title="save">
            <xf:label class="xrxeSaveTriggerLabel">{$xrxe-ui:save}</xf:label>            
            {xrxe:create-save-actions($conf)}
        </xf:trigger>
};

declare function xrxe:create-save-actions($conf){
    (
    xrxe:send-unecape-document-submission($conf)
    (:, Called from Chain in unescape
    xrxe:send-save-document-submission($conf):)
    ,
    xrxe:skipshutdown('true')
    )
};

declare function xrxe:create-save-close-trigger($conf){

        <xf:trigger class="xrxeTrigger xrxeSaveCloseTrigger">
            <xf:label class="xrxeSaveCloseTriggerLabel">{$xrxe-ui:save-and-close}</xf:label>
            {xrxe:create-save-actions($conf)}
            <xf:action>
	          <xf:load
	            resource="{$conf/@save-close}"
	            show="replace" />
	        </xf:action>
        </xf:trigger>

};

declare function xrxe:send-unecape-document-submission($conf){
    <xf:send submission="{xrxe:unescape-document-submission-id($conf)}" />
};


(:Currently not usedf moved to chain in uinescape:)
declare function xrxe:send-save-document-submission($conf){
    <xf:send submission="{xrxe:save-document-submission-id($conf)}" />
};

(:Move to a nice place:)
declare function xrxe:skipshutdown($skipshutdown){
    <script type="text/javascript">
      fluxProcessor.skipshutdown={$skipshutdown};
    </script>
       
};

(:######################## *** MENU   *** ############################:)


declare function xrxe:create-document-ui($xsd, $conf){
let $ui := $conf/xrxe:ui-template/xrxe:ui

for $switch in $ui/xrxe:switch
    return xrxe:create-switch-ui($switch, $xsd, $conf)
};

declare function xrxe:create-switch-ui($switch, $xsd, $conf){
    (
    xrxe:create-ui-triggers($switch, $xsd, $conf)
    ,
    xrxe:create-ui-switch($switch, $xsd, $conf)
    )
};

declare function xrxe:create-ui-triggers($switch, $xsd, $conf){
    <div style="display:none;">
    {
    for $tab in $switch/xrxe:tab
        return 
        xrxe:create-ui-trigger($tab, $xsd, $conf)        
    }
    </div>
};

declare function xrxe:create-ui-trigger($tab, $xsd, $conf){
    let $tab-name := $tab/xrxe:trigger/text()
    return  
    <xf:trigger id="t-{$tab-name}-case" class="xrxeUITrigger">
        <xf:label>{$tab-name}</xf:label>
        <xf:toggle case="{$tab-name}-case" />
         {
        if(count($tab//xrxe:node-editor/@embed[data(.)="true"]) gt 0) then
             xrxe:load-node-editors($tab/xrxe:case, $conf)
          else 
             ()
        }
     </xf:trigger>
};

declare function xrxe:load-node-editors($case, $conf){   
   for $node-editor in $case/xrxe:node-editor
        return
            xrxe:load-node-editor($node-editor, $conf)
};

declare function xrxe:load-node-editor($node-editor, $conf){
    
    let $id := xs:string($node-editor/@id)   
    return
        (
        <xf:action if="{xrxe:load-instance-string($conf)}/{$id}!=0">
            {(
                xrxe:set-ui-tab-loaded($conf, $id)                       
                ,
                xrxe:ensure-node-exists($conf, $node-editor)
                ,
                xrxe:embed-node-editor($conf, $node-editor)   
            )}
        </xf:action>
        )
};

declare function xrxe:set-ui-tab-loaded($conf, $id){
    <xf:setvalue ref="{xrxe:load-instance-string($conf)}/{$id}" value="0"/>
};

declare function xrxe:ensure-node-exists($conf, $node-editor){
    (
    let $node-path := concat($conf/@node-path, $node-editor/@node-path)
    
    let $context := concat(xrxe:document-instance-string($conf), functx:substring-before-last($node-path, '/'))
    return
    <xf:action if="not(exists({xrxe:document-instance-string($conf)}{$node-path}))">
        <xf:insert  nodeset="{$context}/element()" position="after" context="{$context}" origin="instance('i-ui-template'){$node-path}"/>
    </xf:action>
    )   
};

declare function xrxe:embed-node-editor($conf, $node-editor){

let $node-path := concat($conf/@node-path, $node-editor/@node-path)
return
<xf:action if="exists({xrxe:document-instance-string($conf)}{$node-path})"> 
    <xf:load show="embed" targetid="d-{$node-path}">
        {
        let $xsd-context-path := xs:string($node-editor/@xsd-context-path)
        let $template-path := xs:string($node-editor/@template-path)
        let $url :=
        if ($node-editor/@url) then
            xs:string($node-editor/@url)
        else
            let $xsd-context-path := xs:string($node-editor/@xsd-context-path)
            let $template-path := xs:string($node-editor/@template-path)
            return
            concat($conf/@services, '?service=get-subeditor&amp;doc=', $conf/@docloc, '&amp;services=', $conf/@services, '&amp;xsd=', $conf/@xsdloc, '&amp;node-path=', $node-path, '&amp;xsd-context-path=', $xsd-context-path, '&amp;template-path=', $template-path)

        return
            <xf:resource value="'{$url}'"/>    
                      
        }        
    </xf:load>
</xf:action>

};

declare function xrxe:create-ui-switch($switch, $xsd, $conf){
    <xf:switch id="s-ui" appearance="dijit:TabContainer" class="xrxeUISwitch"> 
    {
         for $tab in $switch/xrxe:tab
            return 
               xrxe:create-ui-case($tab, $xsd, $conf) 
    }
    </xf:switch>
};

declare function xrxe:create-ui-case($tab, $xsd, $conf){
   let $tab-name := $tab/xrxe:trigger/text()
   return
    <xf:case id="{$tab-name}-case" class="xrxeUICase">
        <xf:label class="xrxeUICaseLabel">{$tab-name}</xf:label> 
        {xrxe:create-ui-case-content($tab/xrxe:case, $xsd, $conf)}
    </xf:case>   
};

declare function xrxe:create-ui-case-content($case, $xsd, $conf){
   for $node-editor in $case/xrxe:node-editor
        return
        if(xs:string($node-editor/@embed)="true" and $node-editor/@url) then
            <div id="d-{concat($conf/@node-path, $node-editor/@node-path)}">
                <div align="center">
                    {$xrxe-ui:loading}
                     <br/>
                     <img src="/bfResources/images/indicator.gif"/>
                </div>
            </div> 
        else 
            (:TODO Not embeded Subeditors here.
            :)
            ()
};


(:######################## *** NODE EDITOR  *** ############################:)

declare function xrxe:create-node-editor($xsd, $conf){  
        let $template := xrxe:get-template($conf)
        return
            (
            xrxe:create-node-model($template, $xsd, $conf)
            ,       
            xrxe:create-node-view($template, $xsd, $conf)
            )    
};



(:######################## *** NODE MODEL *** ############################:)

(:### causes the charter editor not to render correctly why?###:)
declare function xrxe:create-node-model($template, $xsd, $conf){
        <xf:model id="{xrxe:model-id($template, $conf)}">
                {(                
                xrxe:create-node-instances($template, $xsd, $conf)
                ,
                xrxe:create-nodesets-binds($template, (), $xsd, $conf)
                ,
                xrxe:create-node-actions($conf)
                ,           
                xrxe:create-node-submissions($template, $conf)     
                )}
         </xf:model>    
};

(:######################## *** NODE MODEL INSTANCES *** ############################:)

declare function xrxe:create-node-instances($template, $xsd, $conf){
        let $instances := ''
        return
            (
            xrxe:create-data-instance($template, $conf)
            ,            
            (:xrxe:create-insert-instance($template, $conf)
            ,
            xrxe:create-delete-instance($template, $conf)
            ,:)
            xrxe:create-new-instance($template, $conf)                 
            )
};

declare function xrxe:create-data-instance($template, $conf){    
   
    let $data := xrxe:get-node-data($template, $conf)
    return
    <xf:instance id="{xrxe:data-instance-id($template, $conf)}" >
        <data xmlns="">
            {$data}
        </data>
    </xf:instance>
};

declare function xrxe:get-node-data($template, $conf){  
   
    let $doc := $conf/xrxe:doc/node()
   
    (:xrxe:doc-node:)
    let $document := 
        if($doc/parent::*) then
            $doc/parent::*
        else
            root($doc)
            
    let $declare-namespaces := xrxe:declare-namespaces($doc)
    
    let $node-path := 
        if($conf/@node-path and string($conf/@node-path)!='')     then
            string($conf/@node-path)
        else 
            '/element()'
    
    let $get-node := concat('$document' , $node-path, '[1]') 
    let $node := util:eval($get-node) 
    
   
    (: Dummy to handle non existing data nodes :)
    let $node := 
        if($node) then 
            $node
        else
            element {name($template)} {}
    (: Dummy Dummy Dummy Dummy :)
    
    let $node := xrxe:pre-transform($node, $template)
        return $node    
};

declare function xrxe:create-new-instance($template, $conf){
    let $all-element-names :=
        for $element in $template/descendant::element()
            return name($element)
            
    let $all-attribute-names :=   
        for $attribute in $template/descendant-or-self::element()/attribute::*
            return name($attribute)
    
    let $instance :=
    <xf:instance id="{xrxe:new-instance-id($template, $conf)}">
        <new xmlns="">
            {(
            for $name in fn:distinct-values($all-element-names)
            return  
                element {$name} {}
            ,
            if($xrxe-conf:default-disable-attribute-editing) then ()
            else
                element attribute {
                    for $attribute in fn:distinct-values($all-attribute-names)
                    return attribute {$attribute} {''}
                }
            )}
        </new>        
    </xf:instance>    
    return $instance       
};

(:######################## *** NODE MODEL BINDS *** ############################:)

(: *** traverse prototype:)
declare function xrxe:traverse($node, $xsd, $conf){

    let $path := xrxe:xsd-path($node, $conf)
    let $traversed:= <traverse>{$path}</traverse>
    let $child-nodes := 
        for $child-node in  ($node/element() | $node/attribute())
            return xrxe:traverse($child-node, $xsd, $conf)    
    return ($traversed, $child-nodes)

};

declare function xrxe:create-nodesets-binds($node, $parent-info, $xsd, $conf){
    
    (:create function that uses the ancestor instead of nodeset-path info to faster get the info:)
    
        
    
    let $node-info := qxrxe:get-node-info(xrxe:node-info-path($node, $parent-info, $conf), $parent-info , $xsd)
    
    let $binds := xrxe:create-nodeset-binds($node, $node-info, $xsd, $conf)
    
    let $child-nodes-binds :=
        for $child-node in ($node/element() | $node/attribute())
            return xrxe:create-nodesets-binds($child-node, $node-info, $xsd, $conf) 
    
    return ($binds, $child-nodes-binds)

};

declare function xrxe:create-nodeset-binds($node, $node-info, $xsd, $conf){
    (
    xrxe:create-data-bind($node, $node-info, $xsd, $conf)
     
    (:,
    xrxe:create-relevant-binds($node, $node-info, $xsd, $conf) :)
    )
};

declare function xrxe:create-data-bind($node, $node-info, $xsd, $conf){  
    
    element 
        xf:bind
        {
            xrxe:create-attribute('id', xrxe:data-bind-id($node, $conf))
            ,
            xrxe:create-attribute('nodeset', concat(xrxe:get-data-instance-string($conf), xrxe:data-path($node)))
            ,
            (:TODO currenty only works for annotation not real xs:type:)
            xrxe:create-attribute('type', qxrxe:get-type($node-info, $xsd))
            ,
            xrxe:create-attribute('constraint', qxrxe:get-constraint($node-info, $xsd))                            
            ,
            xrxe:create-attribute('required', ())
            ,
            xrxe:create-attribute('relevant', ())
            ,
            xrxe:create-attribute('readonly', ())
            ,
            xrxe:create-attribute('calculate', ())
        }
};

(:MOVE TO XQUERY UTIL:)
(:######################## *** ATTRIBUTE CONSTRUCTORS *** ############################:)

(:only create an attribute if a value exists:)
declare function xrxe:create-attribute($name, $value){
    if ($value) then
        attribute {$name} {$value}
    else ()
};

(:######################## *** NODE MODEL ACTIONS *** ############################:)

declare function xrxe:create-node-actions($conf){
    (
        xrxe:create-validate-action($conf)
    )
};

declare function xrxe:create-validate-action($conf){
<xf:action ev:event="xforms-refresh">
      <xf:send submission="{xrxe:get-validate-submission-id($conf)}" />                    
</xf:action>
};

(:######################## *** NODE MODEL SUBMISSIONS *** ############################:)

declare function xrxe:create-node-submissions($template, $conf){
    let $submission := 
        (
            xrxe:create-post-submisssion($template, $conf)    
            ,
            xrxe:create-validate-submisssion($template, $conf)            
        )
    return $submission
};

declare function xrxe:create-post-submisssion($template, $conf){    
    <xf:submission id="{xrxe:get-post-submission-id($conf)}" ref="{concat(xrxe:get-data-instance-string($conf), '/', xrxe:data-path($template))}"  replace="none" method="post" resource="model:{xrxe:document-model-id($conf)}#{ xrxe:document-instance-string($conf)}/document{$conf/@node-path}">
       <xf:action ev:event="xforms-submit-done">   

       </xf:action>
       <xf:action ev:event="xforms-submit-error">
           {
           <xf:message>{$xrxe-ui:post-error}</xf:message>
           }
       </xf:action>
   </xf:submission>
};

declare function xrxe:create-validate-submisssion($template, $conf){
      
         <xf:submission id="{xrxe:get-validate-submission-id($conf)}" validate="true" replace="none" method="get" resource="model:{xrxe:get-model-id($conf)}#{xrxe:get-data-instance-string($conf)}/data">
            <xf:action ev:event="xforms-submit" /> 
            <xf:action ev:event="xforms-submit-done">                
                <xf:send if="exists(bf:instanceOfModel('{xrxe:document-model-id($conf)}', '{xrxe:document-instance-id($conf)}'){$conf/@node-path})" submission="{xrxe:get-post-submission-id($conf)}" />
            </xf:action>
            <xf:action ev:event="xforms-submit-error">
               <xf:message>{name($template)}{$xrxe-ui:not-valid}</xf:message>
            </xf:action>
        </xf:submission>
};


(:######################## *** IDS *** ############################:)

(:######################## *** DOCUMENT IDS *** ############################:)

declare function xrxe:document-instance-string($conf){
    xrxe:create-instance-sting(xrxe:document-instance-id($conf))
};

declare function xrxe:document-model-id($conf){
    concat($xrxe-conf:pre-string-model, xrxe:document-id($conf))
};

declare function xrxe:save-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), $xrxe-conf:post-string-save)
};

declare function xrxe:unescape-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), $xrxe-conf:post-string-unescape)
};

declare function xrxe:document-submission-id($conf){
    concat($xrxe-conf:pre-string-submission, xrxe:document-id($conf))
};

declare function xrxe:document-instance-id($conf){
    concat($xrxe-conf:pre-string-instance, xrxe:document-id($conf))
};

declare function xrxe:document-id($conf){
    xrxe:clean-id(concat(name($conf/xrxe:doc/node()), $xrxe-conf:post-string-document))
};

(:######################## *** UI IDS *** ############################:)

(:DEPRECATED LOAD IS IN DOCUMENT MODEL:)
declare function xrxe:load-model-id($conf){
    concat($xrxe-conf:pre-string-model, xrxe:load-id($conf))
};

declare function xrxe:load-id($conf){
    xrxe:clean-id(concat(name($conf/xrxe:doc/node()), $xrxe-conf:post-string-load))
};

declare function xrxe:load-instance-id($conf){
    concat($xrxe-conf:pre-string-instance, xrxe:load-id($conf))
};

declare function xrxe:load-instance-string($conf){
    xrxe:create-instance-sting(xrxe:load-instance-id($conf))
};


(:######################## *** MODEL IDS *** ############################:)

(:Create a model id for the models node:)
declare function xrxe:model-id($node, $conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-model, xrxe:xsd-path($node, $conf)))
};

(:Get the id of the model from everywhere:)
declare function xrxe:get-model-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-model, xrxe:root-xsd-path($conf)))
};

(:######################## *** INSTANCE IDS *** ############################:)

declare function xrxe:data-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-data)
};

declare function xrxe:insert-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-insert)
};

declare function xrxe:delete-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:new-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-new)
};

declare function xrxe:instance-id($node, $conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:xsd-path($node, $conf)))
};

(:model-ids and instance ids may not contain '/':)
declare function xrxe:clean-id($path){
    replace($path, '/', '_')
};

declare function xrxe:get-data-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-data))
};

declare function xrxe:get-insert-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-insert))
};

declare function xrxe:get-delete-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-delete))
};

declare function xrxe:get-new-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-new))
};

declare function xrxe:get-data-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-data-instance-id($conf))
};

declare function xrxe:get-insert-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-insert-instance-id($conf))
};

declare function xrxe:get-delete-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-delete-instance-id($conf))
};

declare function xrxe:get-new-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-new-instance-id($conf))
};

declare function xrxe:create-instance-sting($id){
    concat("instance('", $id, "')")
};

(:######################## *** BIND IDS *** ############################:)

declare function xrxe:data-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-data)
};

declare function xrxe:insert-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-insert)
};

declare function xrxe:delete-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:bind-id($node, $conf){
    concat($xrxe-conf:pre-string-bind, xrxe:xsd-path($node, $conf))
};


(:######################## *** SUBMISSION IDS *** ############################:)

declare function xrxe:get-validate-submission-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-submission, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-validate))
};

declare function xrxe:get-post-submission-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-submission, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-post))
};

(:######################## *** CHILDREN CONTAINER IDS *** ############################:)

declare function xrxe:get-switch-children-id($node, $conf){
    concat($xrxe-conf:pre-string-switch, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-child-elements)
};

declare function xrxe:get-group-children-id($node, $conf){
    concat($xrxe-conf:pre-string-group, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-child-elements)
};

(:######################## *** CASE IDS *** ############################:)

declare function xrxe:get-case-id($node, $conf){
    concat(xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-case)
};

declare function xrxe:get-trigger-case-id($node, $conf){
    concat($xrxe-conf:pre-string-trigger, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-case)
};

(:######################## *** REPEAT IDS *** ############################:)

declare function xrxe:repeat-id($node, $conf){
    concat($xrxe-conf:pre-string-repeat, xrxe:xsd-path($node, $conf))
};

(:######################## *** DIALOG IDS *** ############################:)

declare function xrxe:delete-dialog-id($node, $conf){
    concat(xrxe:dialog-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:attributes-dialog-id($node, $conf){
    concat(xrxe:dialog-id($node, $conf), $xrxe-conf:post-string-attributes)
};

declare function xrxe:dialog-id($node, $conf){
    concat($xrxe-conf:pre-string-dialog, xrxe:xsd-path($node, $conf))
};

(:######################## *** PATHES *** ############################:)

(:*** returns the path for qxsd of the node TODO include path of supernodes for subeditors so subeditors need not all params:)
declare function xrxe:xsd-path($node, $conf){
    concat(xs:string($conf/@xsd-context-path), xrxe:data-path($node))
};

declare function xrxe:root-xsd-path($conf){
    concat(xs:string($conf/@xsd-context-path), '/', name($conf/xrxe:template/element()))
};

declare function xrxe:data-path($node as node()* )  as xs:string* {   
    concat('/', 
            string-join( 
            for $ancestor-or-self in xrxe:ancestor-or-self($node)
            return
                xrxe:path($ancestor-or-self)
            , '/'
            )
        )
 } ;
 
 declare function xrxe:ancestor-or-self($node){
(:xpath's ancestor-or-self::*  doens't work with the root element and with attributes:)
let $parent := $node/parent::*
let $ancestor-of-parent:= $parent/ancestor::*
return($ancestor-of-parent, $parent, $node)
};
 
 declare function xrxe:path($node){
    if($node instance of attribute()) then
        concat('@', name($node))
    else if($node instance of element()) then
        name($node)
    else if($node instance of text()) then
        'text()'
    else 
        ()
 };
 
declare function xrxe:relative-child-path($node, $node-info, $xsd, $conf){
    (:Use function when exists for instance of element(xs:attribute) :)
    if($node-info instance of element(xs:attribute)) then 
            concat("./@", name($node))
    else 
            concat("./", name($node))
};

declare function xrxe:relative-self-path($node, $node-info, $xsd, $conf){
    (:Use function when exists for instance of element(xs:attribute) :)
    if($node-info instance of element(xs:attribute)) then 
            concat("../@", name($node))
    else 
            concat("../", name($node))
};

declare function xrxe:node-info-path($node, $parent-info, $conf){
    if($parent-info) then
        xrxe:path($node)
    else 
        xrxe:xsd-path($node, $conf)
 };

(:
declare function xrxe:path-to-node($node as node()* )  as xs:string* { 
let $parent := $node/parent::*
let $ancestor-of-parent:= $parent/ancestor::*
let $ancestor-or-self := ($ancestor-of-parent, $parent, $node)
let $path :=      
    string-join(
      for $ancestor in $ancestor-or-self(: $node/ancestor-or-self::* :)
        return
            if($ancestor instance of attribute()) then
                concat('@', name($ancestor))
            else if($ancestor instance of document-node()) then
                ()
            else 
                let $name := name($ancestor)   
                return              
                if ($name='doc') then ()
                else $name                
      , '/'
      )
return $path
 } ;
:)
 
 (:########################  *** NODE VIEW ***  ############################:)

declare function xrxe:create-node-view($template, $xsd, $conf){
     
        let $node-info := qxrxe:get-node-info(xrxe:node-info-path($template, (), $conf), () , $xsd)
        return 
        <xf:group model="{xrxe:get-model-id($conf)}" class="xrxeNodeEditor xrxeNodeEditorGroup">
        {(  
           
            xrxe:create-nodeset-controls($template, $node-info, $xsd, $conf)
            ,
            xrxe:create-notesets-dialogs($template, $node-info, $xsd, $conf)     
        )}
        </xf:group>
};

 (:########################  *** NODESET CONTROLS ***  ############################:)

declare function xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf){
    
        <xf:group class="xrxeNodeset">{   
         (
         if(xrxe:root($node)) then         
              xrxe:group-nodeset($node, $node-info, $xsd, $conf)
         else  
             xrxe:create-repeat-nodeset($node, $node-info, $xsd, $conf)
         ,
         if(xrxe:root($node) or $xrxe-conf:default-disable-insert-elements) then 
             ()
         else
              xrxe:create-insert-node-trigger($node, $node-info, $xsd, $conf) 
         )
        }</xf:group>
};

declare function xrxe:group-nodeset($node, $node-info, $xsd, $conf){
        (
        <xf:group ref="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" class="xrxeGroup xrxeNotesetGroup">       
            {xrxe:create-node-control($node, $node-info, $xsd, $conf)}
        </xf:group>
        )
};

declare function xrxe:create-repeat-nodeset($node, $node-info, $xsd, $conf){

    (
    xrxe:create-nodeset-label($node, $node-info, $xsd, $conf)
   (: ,    
    xrxe:debug-count-nodeset($node, $node-info, $xsd, $conf)   :) 
    ,
    <xf:repeat nodeset="{xrxe:relative-child-path($node, $node-info, $xsd, $conf)}" id="{xrxe:repeat-id($node, $conf)}" class="xrxeRepeat xrxeNodesetRepeat"> 
        {xrxe:create-node-control($node, $node-info, $xsd, $conf)} 
    </xf:repeat> 
    )
};

declare function xrxe:create-nodeset-label($node, $node-info, $xsd, $conf){
    let $plural-label := qxrxe:get-plural-label($node-info, $xsd)
    return
    if($plural-label) then
        <xf:label class="xrxeNodetLabel">{$plural-label}</xf:label>
    else
        ()
};

declare function xrxe:create-insert-node-trigger($node, $node-info, $xsd, $conf){
let $label := qxrxe:get-label($node-info, $xsd)
let $max := qxrxe:get-max-occur($node-info, $xsd)
return 
    ( 
    <xf:trigger ref=".[count({xrxe:relative-child-path($node, $node-info, $xsd, $conf)}) lt {$max}]" class="xrxeTrigger xrxeInsertNodeTrigger" > 
        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeInsertNodeTriggerLabel">{$xrxe-ui:insert-trigger-label, ' ' , $label}</xf:label>
        {xrxe:insert-node-action($node, $node-info, $xsd, $conf)}
    </xf:trigger>
    )
};

declare function xrxe:insert-node-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-node($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};

declare function xrxe:set-default-node-value($node, $node-info, $xsd, $conf){
    let $default-value := qxrxe:get-default-value($node-info, $xsd)
    
    let $node-path :=
        if(qxrxe:is-xs-attribute($node-info)) then
            concat('attribute/@', name($node))
        else 
             name($node)
    
    return
    (
    if($default-value) then
        <xf:setvalue ref="{xrxe:get-new-instance-string($conf)}/{$node-path}" value="{$default-value}"/>
    else
        ()
     )
};

declare function xrxe:insert-node($node, $node-info, $xsd, $conf){
    if (qxrxe:is-xs-element($node-info)) then
        (
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}"  nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}"/>
        )
    else if(qxrxe:is-xs-attribute($node-info)) then
        (:<xf:message><xf:output value="name({xrxe:indexed-node-path($node/parent::*, $xsd, $conf)})" /></xf:message>:)
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/attribute/@', name($node))}"  />
    else ()
};


(:######################## *** NODE CONTROLS ***  ############################:)

declare function xrxe:create-node-control($node, $node-info, $xsd, $conf){
    <xf:group class="xrxeNode">
    {(
    
     xrxe:create-node-label($node, $node-info, $xsd, $conf)
     ,
     xrxe:create-node-functions($node, $node-info, $xsd, $conf)
     ,
     (:temp here integrate with children:)
     if (qxrxe:is-xs-element($node-info)) then
        xrxe:create-attributes($node, $node-info, $xsd, $conf)  
     else   
        ()  
     ,      
     if(qxrxe:get-type-type($node-info, $xsd)='complexType' and qxrxe:is-mixed($node-info, $xsd)!=true()) then
        xrxe:create-children-container($node, $node-info, $xsd, $conf)
     else 
        xrxe:create-node-content-control($node, $node-info, $xsd, $conf)
     )}
     </xf:group>
};

declare function xrxe:create-node-label($node, $node-info, $xsd, $conf){
    (:<xf:label>{xrxe:indexed-node-path($node, $xsd, $conf)}</xf:label>:)
    <xf:label class="xrxeLabel xrxeNodeLabel">{qxrxe:get-label($node-info, $xsd) }</xf:label>
};

 
(:######################## *** CHILDREN CONTAINER ***############################:)

declare function xrxe:create-children-container($node, $node-info, $xsd, $conf){
    
    let $children-control :=  qxrxe:get-children-control($node-info, $xsd)
    return       
        if($children-control='tabContainer') then
            xrxe:create-tab-switch-children($node, $node-info, $xsd, $conf)
        else if($children-control='switch') then
            xrxe:create-switch-children($node, $node-info, $xsd, $conf)
        else if($children-control='dialog') then
            xrxe:create-dialog-children($node, $node-info, $xsd, $conf)
        else if($children-control='group') then
            xrxe:create-group-children($node, $node-info, $xsd, $conf)
        else  
            xrxe:create-list-children($node, $node-info, $xsd, $conf)  
};

declare function xrxe:create-tab-switch-children($node, $node-info, $xsd, $conf){
let $controls := 
        (
        <div style="display:none;">
            {xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf)}                     
        </div>
        ,  
        <xf:switch appearance="dijit:TabContainer" id="{xrxe:get-switch-children-id($node, $conf)}" class="xrxeTabContainer">
            {xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf)}
        </xf:switch>
        )
return $controls
};

declare function xrxe:create-switch-children($node, $node-info, $xsd, $conf){
        (
        xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf)
        ,  
        <xf:switch  id="{xrxe:get-switch-children-id($node, $conf)}" class="xrxeSwitch">
            {xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf)}
        </xf:switch>
        )
};

declare function xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        let $child-element-info :=  qxrxe:get-node-info(xrxe:node-info-path($child-element, $node-info, $conf), $node-info , $xsd)
        return            
            xrxe:create-node-case($child-element, $child-element-info, $xsd, $conf)
};

declare function xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf){
    <xf:group class="xrxeSwitchTriggers">
    {
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    let $child-element-info :=  qxrxe:get-node-info(xrxe:node-info-path($child-element, $node-info, $conf), $node-info , $xsd)
    return 
        <xf:trigger id="{xrxe:get-trigger-case-id($child-element, $conf)}" class="xrxeTabSwitchTrigger">
            <xf:label>{xrxe:get-tab-label($child-element, $child-element-info, $xsd, $conf)}</xf:label>
            <xf:toggle case="{xrxe:get-case-id($child-element, $conf)}" />
        </xf:trigger>  
   }
   </xf:group>
   
};


declare function xrxe:create-node-case($node, $node-info, $xsd, $conf){
     <xf:case id="{xrxe:get-case-id($node, $conf)}" class="xrxeTabContainerCase">                       
        {(
        <xf:label>{xrxe:get-tab-label($node, $node-info, $xsd, $conf)}</xf:label>
        ,
        xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf)
        )}
    </xf:case>    
};

declare function xrxe:get-tab-label($node, $node-info, $xsd, $conf){
    let $plural-label:= qxrxe:get-plural-label($node-info, $xsd)
    return 
     if ($plural-label) then
         $plural-label
     else 
         qxrxe:get-label($node-info, $xsd)
};


declare function xrxe:create-dialog-children($node, $node-info, $xsd, $conf){
        ()(:
        xrxe:create-child-elements-dialog-triggers($node, $node-info, $xsd, $conf)
        ,  
        xrxe:create-child-elements-dialogs($node, $node-info, $xsd, $conf)
        :)
};

(:
declare function xrxe:create-child-elements-dialog-triggers($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    let $child-element-info := qxrxe:get-element-info(xrxe:xsd-path($child-element, $conf), $xsd)
    return 
        <xf:trigger id="{xrxe:get-trigger-case-id($child-element, $conf)}" class="xrxeDialogTrigger">
            <xf:label>{qxrxe:get-label($child-element-info, xrxe:xsd-path( $child-element, $conf), $xsd)}</xf:label>
            <xf:toggle dialog="{xrxe:dialog-id($child-element, $conf)}" />
        </xf:trigger>  
};

declare function xrxe:create-child-elements-dialogs($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        let $child-element-info := qxrxe:get-element-info(xrxe:xsd-path($child-element, $conf), $xsd)
        return            
            xrxe:create-node-dialog($child-element, $child-element-info, $xsd, $conf)
};

declare function xrxe:create-node-dialog($node, $node-info, $xsd, $conf){
    <bfc:dialog  id="{xrxe:dialog-id($node, $conf)}" class="xrxeDialog">          
        {(
        <xf:label>{qxrxe:get-label($node-info, xrxe:xsd-path($node, $conf), $xsd)}</xf:label>
        ,
        xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf)
        )}
    </bfc:dialog>
};:)



declare function xrxe:create-group-children($node, $node-info, $xsd, $conf){
    for $child in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    return
         let $child-element-info := qxrxe:get-node-info(xrxe:node-info-path($child, $node-info, $conf), $node-info , $xsd) 
         return
         <xf:group id="{xrxe:get-group-children-id($node, $conf)}">
         {         
         xrxe:create-nodeset-controls($child, $child-element-info, $xsd, $conf)
         }
         </xf:group>
};

declare function xrxe:create-list-children($node, $node-info, $xsd, $conf){
    for $child in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        return
         let $child-element-info := qxrxe:get-node-info(xrxe:node-info-path($child, $node-info, $conf), $node-info , $xsd)  
         return 
         xrxe:create-nodeset-controls($child, $child-element-info, $xsd, $conf)
};

(:Use this Function when removing the template and query the xsd:)
declare function xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf){
    $node/child::element()
};

(:######################## *** NODE CONTENT CONTROL ***  ############################:)

declare function xrxe:create-node-content-control($node, $node-info, $xsd, $conf){
    let $content-control :=  qxrxe:get-content-control($node-info, $xsd)
    return 
        if($content-control) then
            xrxe:create-declared-node-content-control($node, $content-control, $node-info, $xsd, $conf)
        else 
            xrxe:choose-node-content-control($node-info, $xsd)
};

declare function  xrxe:create-declared-node-content-control($node, $content-control, $node-info, $xsd, $conf){
    let $control := 
        if ($content-control='annotation') then
            xrxe:create-annotation-control($node, $node-info, $conf, $xsd)
        else if($content-control='input') then
            xrxe:create-input-control($node-info,$xsd)
        else if($content-control='empty') then
            ()
        else
            xrxe:create-textarea-control($node-info,$xsd)
    return $control
};

declare function xrxe:choose-node-content-control($node-info, $xsd){
    if(qxrxe:is-enum($node-info, $xsd)) then
        xrxe:create-select1-control($node-info, $xsd)   
    else
        xrxe:create-input-control($node-info, $xsd)
};

declare function xrxe:create-input-control($node-info, $xsd){
    <xf:input ref="." class="{xrxe:get-content-control-classes('Input', $node-info)}">
        {(xrxe:get-xforms-control-children($node-info, $xsd))}                    
    </xf:input>
};

declare function xrxe:create-textarea-control($node-info, $xsd){
    <xf:textarea ref="." class="{xrxe:get-content-control-classes('Textarea', $node-info)}">
        {(xrxe:get-xforms-control-children($node-info, $xsd))}                    
    </xf:textarea>
};

declare function xrxe:create-annotation-control($node, $node-info, $conf, $xsd){
    <xf:textarea ref="." mediatype="text/xml" nodepath="{xrxe:xsd-path($node, $conf)}" namespace="{namespace-uri($node)}" nodename="{name($node)}" xsdloc="{$conf/@xsdloc}" services="{$conf/@services}" class="{xrxe:get-content-control-classes('Annotation', $node-info)}" rows="{qxrxe:get-rows($node-info, $xsd)}">
            {(xrxe:get-xforms-control-children($node-info, $xsd))}
    </xf:textarea>
};

declare function xrxe:create-select1-control($node-info, $xsd){
    <xf:select1 ref="." class="{xrxe:get-content-control-classes('Select1', $node-info)}">
        {(
        xrxe:create-items($node-info, $xsd)
        ,
        xrxe:get-xforms-control-children($node-info, $xsd)
        )}                    
    </xf:select1>
};

declare function xrxe:create-items($node-info, $xsd){
    for $enumeration in qxrxe:get-enums($node-info, $xsd)
        return 
            xrxe:create-item($enumeration)
};

declare function xrxe:create-item($enumeration){
    <xf:item>
        <xf:label>{xs:string($enumeration/@value)}</xf:label>
        <xf:value>{xs:string($enumeration/@value)}</xf:value> 
    </xf:item>
};

declare function xrxe:get-content-control-classes($control, $node-info){   
    let $node-type := concat(upper-case(substring(qxrxe:get-node-type($node-info), 1, 1)), substring(qxrxe:get-node-type($node-info), 2))
    let $class1 := concat('xrxe', $node-type, $control)
    let $class2 := concat('xrxe', $node-type, 'ContentControl')
    let $class3 := concat('xrxe', 'Node',  $control)
    let $class4 := concat('xrxe', 'Node',  'ContentControl')
    let $class5 := concat('xrxe', $control)
    return string-join(($class1, $class2, $class3, $class4, $class5), ' ')
};


declare function xrxe:get-xforms-control-children($node-info, $xsd){
     (
     xrxe:get-hint($node-info, $xsd)
     ,
     xrxe:get-help($node-info, $xsd)
     ,
     xrxe:get-alert($node-info, $xsd)
     ,
     xrxe:value-changed-action()
     )
};

declare function xrxe:value-changed-action(){
 <xf:action ev:event="xforms-value-changed">
    {xrxe:skipshutdown('false')}
  </xf:action>
};


declare function xrxe:get-hint($node-info, $xsd){
 let $hint := qxrxe:get-hint($node-info, $xsd)
 return
        if($hint) then
                 <xf:hint>{$hint}</xf:hint>
              else 
                 ()
};

declare function xrxe:get-help($node-info, $xsd){
 let $help := qxrxe:get-help($node-info, $xsd)
   return
        if($help) then
                 <xf:help>{$help}</xf:help>
              else 
                 ()
};

declare function xrxe:get-alert($node-info, $xsd){
 let $alert := qxrxe:get-alert($node-info, $xsd)
    return
        if($alert) then
                 <xf:alert>{$alert}</xf:alert>
              else 
                 ()
    
};

(:########################  *** NODE FUNCTIONS ***  ############################:)

(:Make disable Functions by conf work again:)
declare function xrxe:create-node-functions($node, $node-info, $xsd, $conf){
    <xf:group appearance="minimal" class="xrxeGroup xrxeNodeFunctionsGroup">
        {( 
        if(xrxe:root($node)) then 
            ()
        else
            if (qxrxe:is-xs-element($node-info)) then
                xrxe:create-element-functions($node, $node-info, $xsd, $conf)
            else if(qxrxe:is-xs-attribute($node-info)) then
                xrxe:create-attribute-functions($node, $node-info, $xsd, $conf)    
            else ()
        )}
    </xf:group>
};


declare function xrxe:create-element-functions($node, $node-info, $xsd, $conf){
    (
    xrxe:create-insert-after-trigger($node, $node-info, $xsd, $conf) 
    (:,
    xrxe:create-insert-before-trigger($node, $node-info, $xsd, $conf)
    ,                
    xrxe:create-insert-copy-trigger($node, $node-info, $xsd, $conf):)
    ,
    (:xrxe:create-move-first-trigger($node, $node-info, $xsd, $conf) :)
    (:,
    xrxe:create-move-up-trigger($node, $node-info, $xsd, $conf) 
    ,
    xrxe:create-move-down-trigger($node, $node-info, $xsd, $conf):)
    (:,
    xrxe:create-move-last-trigger($node, $node-info, $xsd, $conf)
    ,:)
    xrxe:create-delete-trigger($node, $node-info, $xsd, $conf)
    )
};

declare function xrxe:create-attribute-functions($node, $node-info, $xsd, $conf){
   xrxe:create-delete-trigger($node, $node-info, $xsd, $conf)
};

declare function xrxe:create-insert-after-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)  
     let $max := qxrxe:get-max-occur($node-info, $xsd)     
     return
        <xf:trigger ref=".[count({xrxe:relative-self-path($node, $node-info, $xsd, $conf)}) lt {$max}]" class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementAfterTrigger"  title="Insert {data($label)}"> 
           <xf:label class="xrxeDeleteElementTriggerLabel">{$xrxe-ui:insert-after-trigger-label}</xf:label>
           {xrxe:insert-after-action($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

declare function xrxe:insert-after-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-after($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};


declare function xrxe:create-insert-before-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)   
     let $max := qxrxe:get-max-occur($node-info, $xsd)     
     return
        <xf:trigger ref=".[count({xrxe:relative-self-path($node, $node-info, $xsd, $conf)}) lt {$max}]" class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementBeforeTrigger"  title="Insert {data($label)}"> 
           <xf:label class="xrxeInsertElementTriggerLabel">{$xrxe-ui:insert-before-trigger-label}</xf:label>
           {xrxe:insert-before-action($node, $node-info, $xsd, $conf)}               
        </xf:trigger>

};

declare function xrxe:insert-before-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-before($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};

(:Only works on loweset level for exaple ead:p works ead:odd just inserts an empty odd:)
declare function xrxe:create-insert-copy-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)       
     let $max := qxrxe:get-max-occur($node-info, $xsd)
     return
        <xf:trigger ref=".[count({xrxe:relative-self-path($node, $node-info, $xsd, $conf)}) lt {$max}]" class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementAfterTrigger"  title="Insert {data($label)}"> 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:insert-copy-trigger-label}</xf:label>
           {xrxe:insert-copy($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

declare function xrxe:create-move-first-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)       
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveFirstTrigger"  title="Move {data($label)} to first position" > 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:move-first-trigger-label}</xf:label>
           {xrxe:move-first($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

 declare function xrxe:create-move-up-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)       
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveUpTrigger"  title="Move {data($label)} up" > 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:move-up-trigger-label}</xf:label>
           {xrxe:move-up($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

 declare function xrxe:create-move-down-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)       
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveDownTrigger"  title="Move {data($label)} up" > 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:move-down-trigger-label}</xf:label>
           {xrxe:move-down($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

declare function xrxe:create-move-last-trigger($node, $node-info, $xsd, $conf){
     
     let $label := qxrxe:get-label($node-info, $xsd)       
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveLastTrigger"  title="Move {data($label)} to last position" > 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:move-last-trigger-label}</xf:label>
           {xrxe:move-last($node, $node-info, $xsd, $conf)}               
        </xf:trigger>
};

(:### creates an attribute trigger for one element-node that triggers the dialog###:)
declare function xrxe:create-delete-trigger($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd)
    let $min := qxrxe:get-min-occur($node-info, $xsd)
    return
        (
        <xf:trigger  ref=".[count({xrxe:relative-self-path($node, $node-info, $xsd, $conf)}) gt {$min}]" class="xrxeTrigger xrxeFunctionTrigger xrxeDeleteTrigger xrxeNodeTrigger"  title="Delete {data($label)}" > 
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-ui:delete-trigger-label}</xf:label>
           {xrxe:create-delete-trigger-action($node, $node-info, $xsd, $conf)}
        </xf:trigger>
        )
};



declare function xrxe:create-delete-trigger-action($node, $node-info, $xsd, $conf){
    if($xrxe-conf:default-direct-delete-nodes) then
        xrxe:delete($node, $node-info, $xsd, $conf)           
    else 
        xrxe:show-dialog(xrxe:delete-dialog-id($node, $conf))
};

(:########################  *** NODESET ACTIONS  ***  ############################:)

declare function xrxe:insert($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" />
    </xf:action>
};

declare function xrxe:insert-after($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}"  position="after" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>  
};


declare function xrxe:insert-before($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}"  position="before" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>  
};

declare function xrxe:move-first($node, $node-info, $xsd, $conf){
    <xf:action while="index('{xrxe:repeat-id($node, $conf)}') > 1">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="before" at="index('{xrxe:repeat-id($node, $conf)}') - 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') + 2" />
    </xf:action>  
};

declare function xrxe:move-up($node, $node-info, $xsd, $conf){
    <xf:action if="index('{xrxe:repeat-id($node, $conf)}') > 1">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="before" at="index('{xrxe:repeat-id($node, $conf)}') - 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') + 2" />
    </xf:action>  
};

declare function xrxe:move-down($node, $node-info, $xsd, $conf){
    <xf:action if="index('{xrxe:repeat-id($node, $conf)}') lt count({xrxe:indexed-nodeset-path($node, $xsd, $conf)})">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}') + 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') - 2" />
    </xf:action>  
};

declare function xrxe:move-last($node, $node-info, $xsd, $conf){
    <xf:action while="index('{xrxe:repeat-id($node, $conf)}') lt count({xrxe:indexed-nodeset-path($node, $xsd, $conf)})">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}') + 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') - 2" />
    </xf:action>  
};

declare function xrxe:insert-copy($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>  
};

declare function xrxe:delete($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:delete ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>
};

declare function xrxe:hide-dialog($id){
    <bfc:hide dialog="{$id}" ev:event="DOMActivate"></bfc:hide>                   
};


declare function xrxe:show-dialog($id){
    <bfc:show dialog="{$id}" ev:event="DOMActivate"></bfc:show> 
};

(:######################## *** ATTRIBUTES  *** ############################:)

(:DESTROY:)
declare function xrxe:create-attributes($node, $node-info, $xsd, $conf) {
    if($xrxe-conf:default-disable-attribute-editing) then 
        ()
    else if($xrxe-conf:default-direct-attribute-editing) then
        (:MOVE TO CHILD CONTAINER:)
        xrxe:create-attributes-controls($node, $node-info, $xsd, $conf)    
    else
        (:MOVE TO FUNCTIONS:)
        xrxe:create-attributes-trigger($node, $xsd, $conf) 
};

declare function xrxe:create-attributes-controls($node, $node-info, $xsd, $conf){      
    for $attribute in xrxe:get-relevant-attribute-children($node, $node-info, $xsd, $conf)
    let $attribute-info := qxrxe:get-node-info(xrxe:node-info-path($attribute, $node-info, $conf), $node-info , $xsd)
    return
        xrxe:create-nodeset-controls($attribute, $attribute-info, $xsd, $conf)           
};

(:Use this Function when removing the template and query the xsd:)
declare function xrxe:get-relevant-attribute-children($node, $node-info, $xsd, $conf){
    $node/attribute::*
};

(:### creates an attribute trigger for one element-node ###:)
declare function xrxe:create-attributes-trigger($node, $xsd, $conf){
        if(count($node/attribute::*)>0) then
            <xf:trigger class="xrxeAttributeTrigger">
                   <xf:label class="xrxeAttributeTriggerLabel">
                       { $xrxe-ui:attribute-trigger-label }
                   </xf:label>
                   {xrxe:show-dialog(xrxe:attributes-dialog-id($node, $conf))}
            </xf:trigger>
         else ()
};

(:######################## *** DIALOGS  *** ############################:)

declare function xrxe:create-notesets-dialogs($node, $node-info, $xsd, $conf){
    
    let $dialogs := xrxe:create-nodeset-dialogs($node, $node-info, $xsd, $conf)    
    let $child-nodes-dialogs :=
        for $child-node in ($node/element() | $node/attribute())
            let $child-node-info := qxrxe:get-node-info(xrxe:node-info-path($child-node, $node-info, $conf), $node-info , $xsd)   
            return
            xrxe:create-notesets-dialogs($child-node,  $child-node-info, $xsd, $conf) 
    return ($dialogs, $child-nodes-dialogs)

};

declare function xrxe:create-nodeset-dialogs($node, $node-info, $xsd, $conf){
    (
        if($xrxe-conf:default-direct-attribute-editing) then
            ()
        else
            xrxe:create-attributes-dialog($node, $node-info, $xsd, $conf)
        ,
        xrxe:create-delete-dialog($node, $node-info, $xsd, $conf)
    )
};

(:######################## *** DELETE DIALOGS  *** ############################:)

declare function xrxe:create-delete-dialog($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd) 
    return 
    <bfc:dialog id="{xrxe:delete-dialog-id($node, $conf)}" class="xrxeDialog xrxeDeleteDialog">
        <xf:label class="xrxeLabel xrxeDialogLabel xrxeDeleteDialogLabel">{$xrxe-ui:delete, ' ', $label}</xf:label>            
        {
        (
        <xf:group ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" class="xrxeGroup xrxeDialogGroup xrxeDeleteDialogGroup">
            {xrxe:create-delete-dialog-content($node, $node-info, $xsd, $conf)}
        </xf:group>
        )
        }
    </bfc:dialog>
};

declare function xrxe:create-delete-dialog-content($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd) 
    return
    (
    <xf:output ref="." class="xrxeOutput xrxeDialogOutput xrxeDeleteDialogOutput">
        <xf:label class="xrxeLabel xrxeOutputLabel xrxeDeleteDialogOutputLabel">{$xrxe-ui:doublecheck-delete, $label}</xf:label>
    </xf:output>
    ,
    <xf:trigger style="float:left;margin-right:4px;" class="xrxeTrigger xrxeDeleteTrigger">
        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeDeleteTriggerLabel">{$xrxe-ui:delete}</xf:label> 
        {
        xrxe:hide-dialog(xrxe:delete-dialog-id($node, $conf))
        ,
        xrxe:delete($node, $node-info, $xsd, $conf)
        }
    </xf:trigger>
    ,
    <xf:trigger class="xrxeDeleteDialogCancalTrigger">
        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeHideDialogTriggerLabel">{$xrxe-ui:cancal}</xf:label>
       {xrxe:hide-dialog(xrxe:delete-dialog-id($node, $conf))}
    </xf:trigger> 
    ) 
};

(:######################## *** ATTRIBUTES DIALOGS  *** ############################:)

declare function xrxe:create-attributes-dialog($node, $node-info, $xsd, $conf){
     if(count($node/attribute::*)>0) then
        let $label := qxrxe:get-label($node-info, $xsd)         
        return
        <bfc:dialog id="{xrxe:attributes-dialog-id($node, $conf)}"  class="xrxeDialog xrxeAttributeDialog">
            <xf:label class="xrxeLabel xrxeDialogLabel xrxeAttributesDialogLabel">
                {($label, ' ',  $xrxe-ui:attributes)}
            </xf:label>
            <xf:group ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" class="xrxeGroup xrxeAttributeGroup xrxeAttributeDialogGroup">
                {xrxe:create-attributes-dialog-content($node, $node-info, $xsd, $conf)}
            </xf:group>  
        </bfc:dialog>
     else ()
};

declare function xrxe:create-attributes-dialog-content($node, $node-info, $xsd, $conf){
    (
    xrxe:create-attributes-controls($node, $node-info, $xsd, $conf)
    ,
    xrxe:create-attributes-close-trigger($node, $xsd, $conf)   
    )
};

declare function xrxe:create-attributes-close-trigger($node, $xsd, $conf){
    <xf:trigger class="xrxeTrigger xrxeHideTrigger">
            <xf:label class="xrxeDeleteDialogCancalTriggerLabel">{$xrxe-ui:ok}</xf:label>
           {xrxe:hide-dialog(xrxe:attributes-dialog-id($node, $conf))}
     </xf:trigger>      
};

(:###  Tests if a node is the root-element. Attention fn:root() gives back the document-node ###:)
declare function xrxe:root($node){
    if (count($node/parent::*)>0) then
        fn:false()
    else 
        fn:true()
};

declare function functx:substring-after-last 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
       
   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;
 
 declare function functx:escape-for-regex 
  ( $arg as xs:string? )  as xs:string {
       
   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;
 
 declare function functx:substring-before-last 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
       
   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;
 
 
 (:########################  *** SERVICES  ***  ############################:)
 
 declare function xrxe:get-unescape-mixed-content($data){ 
			let $serialize:= util:serialize($data, ())   
	    	let $replace := replace(replace($serialize, '&amp;lt;', '&lt;'), '&amp;gt;', '&gt;')
	    	let $replace := replace($replace, 'xmlns:NS1=""', '') 
	    	let $replace := replace($replace, 'NS1:', '') 
	    	let $parse:= util:parse($replace)
	    	(:data is just a dummy element:)
	    	let $data := <data>{$parse}</data>
	    	return $data/element()
		};



(:########################  *** INDEXED PATHES  ***  ############################:)

declare function xrxe:indexed-node-path($node, $xsd, $conf)
{ 
    xrxe:indexed-path($node, $xsd, $conf, 'node')
};


declare function xrxe:indexed-nodeset-path($node, $xsd, $conf)
{ 
   xrxe:indexed-path($node, $xsd, $conf, 'nodeset')
};

declare function xrxe:indexed-path($node, $xsd, $conf, $switch)
{ 
    let $tokenize := subsequence(tokenize(xrxe:data-path($node), '/'), 2)
    let $paths := xrxe:rebuild-individual-pathes($tokenize)
    
    let $repeat-indexed-path := string-join(       
        for $token at $pos in $tokenize
            return 
            (:if the data-root is NOT in xf:repeat:)
            if($pos=1)then
                 concat($token, '[1]')
            else if(($pos = count($tokenize) and $switch='nodeset') or contains($tokenize, '@'))then
                 $token
            else
                concat($token, "[index('", $xrxe-conf:pre-string-repeat, $conf/@xsd-context-path, '/',  $paths[$pos],"')]")
     
      , '/')
    
    let $repeat-indexed-instance-path := concat(xrxe:get-data-instance-string($conf), '/',  $repeat-indexed-path)    
    return $repeat-indexed-instance-path       
};

declare function xrxe:rebuild-individual-pathes($tokenize){
    let $individual-paths := 
        for $token at $pos in $tokenize
    
        let $path-parts := 
            for $i in 1 to $pos 
                return $tokenize[$i]
        
        let $paths :=  
            if(count($path-parts)=1)then
                ($path-parts)
            else
                string-join($path-parts, '/') 
        return $paths
    return $individual-paths
    
};