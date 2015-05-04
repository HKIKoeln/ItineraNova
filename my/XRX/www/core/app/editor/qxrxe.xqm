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

module namespace qxrxe="http://www.monasterium.net/NS/qxrxe";

(: ################# IMOPORT MODULES #################:)

import module namespace qxsd='http://www.monasterium.net/NS/qxsd' at '../editor/qxsd.xqm';
import module namespace upd="http://www.monasterium.net/NS/upd"  at "../upd/upd.xqm"; 


(: ################# DECLARE NAMESAPCES #################:)

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xrxe="http://www.monasterium.net/NS/xrxe";

(: ################# DECLARE VARIABLES #################:)

declare variable $qxrxe:appinfo-src := "EditVDU";
declare variable $qxrxe:default-label := 'localname'; (: '', 'name', 'localname' :)
declare variable $qxrxe:default-element-relevant := true();
declare variable $qxrxe:default-attribute-relevant := false();
declare variable $qxrxe:default-attribute-group-relevant := true();
declare variable $qxrxe:default-group-relevant := true();
declare variable $qxrxe:default-min-occur := 1;
declare variable $qxrxe:default-max-occur := 1;
declare variable $qxrxe:default-attribute-min-occur := 0;
declare variable $qxrxe:default-rows := 1;

(:#####################SERVICES BY PATH ############################:)

declare function qxrxe:get-node-info($path, $parent-info, $xsd){
    let $xsd := qxsd:xsd($xsd)  
    let $path := qxsd:get-path($path)    
    
    let $parent-info :=
        if($parent-info) then 
            $parent-info
        else
            $xsd
    
    let $node := qxsd:find-node(qxsd:tokenize-path($path), $parent-info,  1, $xsd)    
    return qxrxe:node-info($node, $xsd)   
};

declare function qxrxe:get-node-appinfos($path, $xsd){    
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    return $appinfos
};

declare function qxrxe:get-node-content($path, $xsd){    
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxrxe:get-relevant-content($type, $node-info, $xsd)
};

declare function qxrxe:get-node-relevant-elements($path, $xsd){    
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    let $content := qxrxe:get-relevant-content($type, $node-info, $xsd)
    return qxrxe:get-relevant-elements($content, $node-info, $xsd)
};

declare function qxrxe:get-node-annotation-options($path, $xsd){    
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    let $content := qxrxe:get-relevant-content($type, $node-info, $xsd)
    return qxrxe:get-annotation-options($content, $node-info, $xsd)
};

declare function qxrxe:get-node-relevant-attributes($path, $xsd){    
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxrxe:get-relevant-attributes($type, $node-info, $xsd)
};

declare function  qxrxe:get-node-template($path, $xsd){  
    let $xsd := qxsd:xsd($xsd)    
    let $node-info := qxrxe:get-node-info($path, (), $xsd)  
    return
        
        qxrxe:create-template($node-info, qxsd:get-prefix(qxsd:get-name($path)), () ,  $xsd, 1)   
 
};

(:##################### CREATE INFO NODES ############################:)


declare function  qxrxe:node-info($node, $xsd){ 
        
        let $node-definition := qxsd:node-definition($node, $xsd)
        let $node-info := qxrxe:get-definition-copy($node-definition)
        let $node-info := qxrxe:add-form($node-info, $node-definition)
        let $node-info := qxrxe:add-namespace-into-info($node-info, $node-definition)
        let $node-info := qxrxe:add-node-into-info($node, $node-info)        
        let $node-info := qxrxe:add-type-into-info($node-info, $xsd)
        return $node-info
        
};

declare function qxrxe:get-definition-copy($to-copy){
    if($to-copy) then 
        qxrxe:copy($to-copy)
    else ()    
};

declare function qxrxe:add-node-into-info($node, $node-info){
    if($node/@ref) then    
        let $node-info :=  qxrxe:add-annotations-into-info($node-info, $node)            
        let $node-info :=  qxrxe:add-attributes-into-info($node-info, $node)             
        return 
            $node-info
    else
        $node-info            
};

declare function qxrxe:add-annotations-into-info($node-info, $node){
    let $annotations := $node/xs:annotation 
    return
        if($node-info and $annotations) then 
            upd:insert-into-as-first($node-info, $annotations)
        else 
            $node-info
};

declare function qxrxe:add-attributes-into-info($node-info, $node){
    let $attributes := $node/@*
    return
        if($node-info and $attributes) then
            upd:insert-attributes($node-info, $attributes)
        else
            $node-info
};

declare function qxrxe:add-type-into-info($node-info, $xsd){
    if($node-info/@type) then  
        let $type := qxsd:get-type($node-info, $xsd)  
        return 
            if($type instance of node()) then
                upd:insert-into-as-last($node-info, $type)
            else
                $node-info
    else
       $node-info
};

declare function qxrxe:add-namespace-into-info($node-info, $node-definition){
    let $targetNamespace := $node-definition/ancestor::xs:schema/@targetNamespace
    return
        if($node-info and $targetNamespace) then
            upd:insert-attributes($node-info, $targetNamespace)
        else 
            $node-info
};

declare function qxrxe:add-form($node-info, $node-definition){
    let $form := 
        if(not($node-info/@form)) then
            let $schema := $node-definition/ancestor::xs:schema
            return
            if (qxrxe:get-node-type($node-info)='element') then
                if($schema/@elementFormDefault) then
                    xs:string($schema/@elementFormDefault)
                else
                    'qualified'
            else if (qxrxe:get-node-type($node-info)='attribute') then
                if ($node-definition/parent::xs:schema) then
                    'qualified'
                else if($schema/@attributeFormDefault) then
                    xs:string($schema/@attributeFormDefault)
                else
                    'unqualified'
            else 
                ()
        else
            ()
            
    let $form-attribute := attribute form {$form}
    return
        if($node-info and $form) then
            upd:insert-attributes($node-info, $form-attribute)
        else 
            $node-info 
};

declare function  qxrxe:attribute-group-info($attribute-group, $xsd){
    let $attribute-group-definition := qxsd:attribute-group-definition($attribute-group, $xsd)
    let $attribute-group-info :=  qxrxe:get-definition-copy($attribute-group-definition)
    let $attribute-group-info := qxrxe:add-annotations-into-info($attribute-group-info, $attribute-group)
    return $attribute-group-info
};

declare function  qxrxe:group-info($group, $xsd){
    let $group-definition := qxsd:group-definition($group, $xsd)
    let $group-info :=  qxrxe:get-definition-copy($group-definition)
    let $group-info := qxrxe:add-annotations-into-info($group-info, $group)
    return $group-info
};

(:##################### QUERY NODE-INFO ############################:)


declare function qxrxe:get-appinfos($node-info, $xsd){
    let $appinfos := ($node-info/xs:annotation/xs:appinfo, $node-info/xs:simpleType/xs:annotation/xs:appinfo, $node-info/xs:complexType/xs:annotation/xs:appinfo)
    return $appinfos
};

declare function qxrxe:get-name($node-info){
    if($node-info/@ref) then
        $node-info/@ref
    else if ($node-info/@name) then
        $node-info/@name
    else ()
};

declare function qxrxe:get-namespace($node-info){
    $node-info/@targetNamespace
};

declare function qxrxe:get-node-type($node-info){ 
    local-name($node-info)
};

declare function qxrxe:is-xs-attribute($node-info){ 
    if (qxrxe:get-node-type($node-info)='attribute') then
        true()
    else
        false()
};

declare function qxrxe:is-xs-element($node-info){ 
    if (qxrxe:get-node-type($node-info)='element') then
        true()
    else
        false()
};

declare function qxrxe:get-label($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    
    let $xrxe-labels := $appinfos/xrxe:label
    let $xrxe-label := $xrxe-labels[1]    
    let $label := 
        if($xrxe-label) then
            $xrxe-label
        else 
            xs:string($node-info/@name)
    return $label
};

declare function qxrxe:get-plural-label($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    
    let $xrxe-labels := $appinfos/xrxe:plural-label
    let $xrxe-label := $xrxe-labels[1]    
    let $label := 
        if($xrxe-label) then
            $xrxe-label
        else 
            ()
    return $label
};

declare function qxrxe:is-relevant($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    
    let $xrxe-relevants := $appinfos/xrxe:relevant
    let $xrxe-relevant := $xrxe-relevants[1]    
    let $xrxe-relevant-text := $xrxe-relevant/text()  
    let $relevant := 
        if($xrxe-relevant-text='true' or $xrxe-relevant-text='false') then
            xs:boolean($xrxe-relevant)
        else             
             if($node-info instance of element(xs:attribute)) then
                $qxrxe:default-attribute-relevant
             else if($node-info instance of element(xs:element)) then
                $qxrxe:default-element-relevant
             else if($node-info instance of element(xs:attributeGroup)) then
                $qxrxe:default-attribute-group-relevant
             else if($node-info instance of element(xs:group)) then
                $qxrxe:default-group-relevant            
             else
                true()
    return $relevant
};

declare function qxrxe:get-min-occur($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    
    let $xrxe-min-occurs := $appinfos/xrxe:min-occur
    let $xrxe-min-occur := $xrxe-min-occurs[1]
    let $min-occur := 
        if($xrxe-min-occur/text()='0') then 
           0
        else if($xrxe-min-occur/text()) then
            $xrxe-min-occur/text()
        else
           if($node-info instance of element(xs:attribute)) then
                $qxrxe:default-attribute-min-occur
           else          
                $qxrxe:default-min-occur
    return $min-occur
};

declare function qxrxe:get-max-occur($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    
    let $xrxe-max-occurs := $appinfos/xrxe:max-occur
    let $xrxe-max-occur := $xrxe-max-occurs[1]
    let $max-occur := 
        if($xrxe-max-occur/text()='unbounded') then 
            (:TODO change to () and don't bind:)
            9999
        else if($xrxe-max-occur/text()) then
            $xrxe-max-occur/text()
        else
           if($node-info instance of element(xs:attribute)) then
                1
           else             
                $qxrxe:default-max-occur
    return $max-occur 
};

declare function qxrxe:get-rows($node-info, $xsd){ 
    
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-rows := $appinfos/xrxe:rows
    let $xrxe-row := $xrxe-rows[1]
    let $row := 
        if(xs:int($xrxe-row)) then
            xs:int($xrxe-row)
        else            
             $qxrxe:default-rows
    return $row
};

declare function qxrxe:get-type-type($node-info, $xsd){ 
    
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)      
    let $xrxe-type-types := $appinfos/xrxe:type-type
    let $xrxe-type-type := $xrxe-type-types[1]
    let $xrxe-type-type-text := $xrxe-type-type/text()
    let $type-type := 
        if($xrxe-type-type-text='xs:simpleType' or $xrxe-type-type-text='simpleType' or $xrxe-type-type-text='simple') then
            'simpleType'
        else if($xrxe-type-type-text='xs:complexType' or $xrxe-type-type-text='complexType' or $xrxe-type-type-text='complex') then
            'complexType'
        else 
             qxsd:get-type-type($node-info, $xsd)
    return $type-type
};

declare function qxrxe:is-mixed($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-mixeds := $appinfos/xrxe:mixed
    let $xrxe-mixed := $xrxe-mixeds[1]    
    let $xrxe-mixed-text := $xrxe-mixed/text()  
    let $mixed := 
        if($xrxe-mixed-text='true' or $xrxe-mixed-text='false') then
            xs:boolean($xrxe-mixed-text)
        else 
            qxsd:is-mixed($node-info, $xsd)    
    return $mixed
};

declare function qxrxe:is-enum($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    
    let $type := qxsd:get-type($node-info, $xsd)
    return qxsd:is-enum-restriction($type)
};

declare function qxrxe:get-enums($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)      
    let $type := qxsd:get-type($node-info, $xsd)
    return qxsd:get-enums($type)
};

declare function qxrxe:get-hint($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-hints := $appinfos/xrxe:hint
    let $xrxe-hint := $xrxe-hints[1]
    
    return $xrxe-hint
    (:let $hint := 
        if($xrxe-hint/text()) then 
           $xrxe-hint/text()
        else 
            ()
    return $hint:)
};

declare function qxrxe:get-help($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    
    let $xrxe-helps := $appinfos/xrxe:help
    let $xrxe-help := $xrxe-helps[1]
    return $xrxe-help
    
    (:let $help := 
        if($xrxe-help/text()) then 
           $xrxe-help/text()
        else 
            ()
    return $help:)
};

declare function qxrxe:get-alert($node-info, $xsd){ 
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-alerts := $appinfos/xrxe:alert
    let $xrxe-alert := $xrxe-alerts[1]
    return $xrxe-alert
    
    
    (:let $alert := 
        if($xrxe-alert/text()) then 
           $xrxe-alert/text()
        else 
            ()
    return $alert:)
};

declare function qxrxe:get-default-value($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-default-values := $appinfos/xrxe:default-value
    let $xrxe-default-value := $xrxe-default-values[1]
    let $default-value := 
        if($xrxe-default-value/text()) then 
           $xrxe-default-value/text()
        else 
            qxsd:get-default-string($node-info, $xsd)
    return $default-value
};

declare function qxrxe:get-fixed($node-info, $xsd){    
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)    

    let $xrxe-fixeds := $appinfos/xrxe:fixeds
    let $xrxe-fixed := $xrxe-fixeds[1]
    return
        if($xrxe-fixed/text()) then 
           $xrxe-fixed/text()
        else 
            qxsd:get-fixed-string($node-info, $xsd)
};

declare function qxrxe:get-value($node-info, $xsd){
    let $fixed-value := qxrxe:get-fixed($node-info, $xsd)
    let $default-value := qxrxe:get-default-value($node-info, $xsd)  
    return
        if($fixed-value) then
            $fixed-value
        else if($default-value) then
            $default-value
        else
            ()        

};

declare function qxrxe:get-constraint($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-constraints := $appinfos/xrxe:constraint
    let $xrxe-constraint := $xrxe-constraints[1]
    let $constraint := 
        if($xrxe-constraint/text()) then 
           $xrxe-constraint/text()
        else 
            ()
    return $constraint
};

declare function qxrxe:is-empty($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)  
    let $xrxe-emptys := $appinfos/xrxe:empty
    let $xrxe-empty := $xrxe-emptys[1]    
    return    
        if($xrxe-empty) then 
               true()
            else 
                false()    
};

declare function qxrxe:get-type($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)    

    let $xrxe-types := $appinfos/xrxe:type
    let $xrxe-type := $xrxe-types[1]
    let $type := 
        if($xrxe-type/text()) then 
           $xrxe-type/text()
        else 
            ()(:TODO get xsd type when xs:type:)
    return $type
};

declare function qxrxe:get-children-control($node-info, $xsd){     
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)    
    
    let $xrxe-children-controls := $appinfos/xrxe:children-control
    let $xrxe-children-control := $xrxe-children-controls[1]
    let $children-control := 
        if($xrxe-children-control/text()) then 
           $xrxe-children-control/text()
        else 
            ()
    return $children-control
};

declare function qxrxe:get-content-control($node-info, $xsd){    
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)    

    let $xrxe-content-controls := $appinfos/xrxe:content-control
    let $xrxe-content-control := $xrxe-content-controls[1]
    let $content-control := 
        if($xrxe-content-control/text()) then 
           $xrxe-content-control/text()
        else 
            ()
    return $content-control
};



declare function qxrxe:is-relevant-in-context($node-info, $context-node, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-relevants := $appinfos/xrxe:relevant
    let $xrxe-relevant := $xrxe-relevants[1]
    let $context := xs:string($context-node/@name)
    return
    if($xrxe-relevant/@context) then    
        util:eval(concat('$context', xs:string($xrxe-relevant/@context)))
    else
        qxrxe:is-relevant($node-info, $xsd)
};

declare function qxrxe:can-have-element-content($node-info, $xsd){
    if(qxsd:is-xs-datatype($node-info/@type) or qxrxe:is-mixed($node-info, $xsd) or qxrxe:get-type-type($node-info, $xsd)='simpleType') then
        false()
    else
        true()
};

(:################## QUERY NODE-INFO CONTENT##########################:)



declare function qxrxe:get-relevant-content($type, $context-node, $xsd){     
     (:exactly 1:)
    let $content := qxrxe:get-content($type, $xsd)
    return
    if(qxrxe:is-relevant-in-context($content, $context-node, $xsd)) then
        $content
    else 
         ()
};

declare function qxrxe:get-content($type, $xsd){
    ($type/xs:sequence  | $type/xs:choice | $type/xs:all | qxrxe:group-info($type/xs:group, $xsd))
};

declare function qxrxe:get-relevant-elements($parent, $context-node, $xsd){
    for $content-model-item in qxsd:get-content-model-items($parent)
        return qxrxe:if-relevant-content-model-item($content-model-item, $context-node, $xsd)
};

declare function qxrxe:if-relevant-content-model-item($content-model-item, $context-node, $xsd){
    if ($content-model-item instance of element(xs:element)) then
            qxrxe:if-relevant-element($content-model-item, $context-node, $xsd)
        else if ($content-model-item instance of element(xs:group)) then
            qxrxe:if-relevant-group($content-model-item, $context-node, $xsd)
        else if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
            qxrxe:if-relevant-compositor($content-model-item, $context-node, $xsd)
        else ()
};

declare function qxrxe:if-relevant-element($element, $context-node, $xsd){
    let $element-info := qxrxe:node-info($element, $xsd)
    return
        if(qxrxe:is-relevant-in-context($element-info, $context-node, $xsd)) then
            $element-info
        else 
            ()
};

declare function qxrxe:if-relevant-group($group, $context-node, $xsd){
    let $group-info := qxrxe:group-info($group, $xsd)
        return
        if(qxrxe:is-relevant-in-context($group-info, $context-node, $xsd)) then
                qxrxe:get-relevant-elements($group-info, $context-node, $xsd)
        else 
             ()
};

declare function qxrxe:if-relevant-compositor($compositor, $context-node, $xsd){
    if(qxrxe:is-relevant-in-context($compositor, $context-node, $xsd)) then
            qxrxe:get-relevant-elements($compositor, $context-node, $xsd)
    else 
         ()
};

(:only used in create!!!! :)
declare function qxrxe:get-relevant-content-model-items($content-definition, $context, $xsd){
    for $content-model-item in qxsd:get-content-model-items($content-definition)
    return
        if ($content-model-item instance of element(xs:element)) then
            let $node-info := qxrxe:node-info($content-model-item, $xsd)
            return
                if(qxrxe:is-relevant-in-context($node-info, $context, $xsd)) then
                    $node-info
                else 
                    ()
        else if ($content-model-item instance of element(xs:group)) then
            let $group-info := qxrxe:group-info($content-model-item, $xsd)
            return
            if(qxrxe:is-relevant-in-context($group-info, $context, $xsd)) then
                    $group-info
            else 
                 ()
        else if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
            if(qxrxe:is-relevant-in-context($content-model-item, $context, $xsd)) then
                    $content-model-item
             else 
                 ()
        else ()
};

(:################## QUERY NODE INFO ATTRIBUTES ##########################:)


declare function qxrxe:get-attribute-items($type, $xsd){
    $type/xs:attribute | $type/xs:attributeGroup
};

declare function qxrxe:get-relevant-attributes($parent, $context-node, $xsd){
    
    for $attribute-item in qxrxe:get-attribute-items($parent, $xsd)
        return qxrxe:if-relevant-attribute-item($attribute-item, $context-node, $xsd)
    
    
    (: Old. Make deprecated let $relevant-local-attributes := qxrxe:get-relevant-local-attributes($parent, $context-node, $xsd)
    let $relevant-attribute-groups := qxrxe:get-relevant-attribute-groups($parent, $context-node, $xsd)
    let $relevant-group-attributes := qxrxe:get-relevant-group-attributes($relevant-attribute-groups, $context-node, $xsd)
    return ($relevant-local-attributes,  $relevant-group-attributes)
    :)

};

declare function qxrxe:if-relevant-attribute-item($attribute-item, $context-node, $xsd){
        if ($attribute-item instance of element(xs:attribute)) then
            qxrxe:if-relevant-attribute($attribute-item, $context-node, $xsd)
        else if ($attribute-item instance of element(xs:attributeGroup)) then
            qxrxe:if-relevant-attribute-group($attribute-item, $context-node, $xsd)        
        else ()
};       

declare function qxrxe:if-relevant-attribute($attribute, $context-node, $xsd){
    let $attribute-info := qxrxe:node-info($attribute, $xsd)
    return
        if(qxrxe:is-relevant-in-context($attribute-info, $context-node, $xsd)) then
            $attribute-info
        else 
            ()
};

declare function qxrxe:if-relevant-attribute-group($attribute-group, $context-node, $xsd){
    let $attribute-group-info := qxrxe:attribute-group-info($attribute-group, $xsd)
        return
        if(qxrxe:is-relevant-in-context($attribute-group-info, $context-node, $xsd)) then
                qxrxe:get-relevant-attributes($attribute-group-info, $context-node, $xsd)
        else 
             ()
};

(:Make deprecated:)
(:
declare function qxrxe:get-relevant-local-attributes($parent, $context-node, $xsd) {  
    if($parent instance of element()) then
        for  $attribute in $parent/xs:attribute
            let $attribute-info := qxrxe:node-info($attribute, $xsd)
            return
            if(qxrxe:is-relevant-in-context($attribute-info, $context-node, $xsd)) then
                $attribute-info
            else ()
    else ()
};:)

(:Make deprecated:)
(:
declare function qxrxe:get-relevant-attribute-groups($parent, $context-node, $xsd){
    if($parent instance of element()) then
        for  $attribute-group in $parent/xs:attributeGroup
            let $attribute-group-info := qxrxe:attribute-group-info($attribute-group, $xsd)
            return  
                if(qxrxe:is-relevant-in-context($attribute-group-info, $context-node, $xsd)) then
                    $attribute-group-info
                else
                ()       
    else () 
};
:)

(:
(:Make deprecated:)
declare function qxrxe:get-relevant-group-attributes($attribute-group, $context-node, $xsd){   
    for $group in $attribute-group
        return 
            qxrxe:get-relevant-attributes($group, $context-node, $xsd)
};
:)

(:################# TRAVERSE #################:)

(:qxrxe:traverse($context, $context-node, $xsd, $depth){
    let $type := qxsd:get-type($node-info, $xsd)
    let $content := qxsd:get-content($type, $xsd)
    for content-model-item in qxsd:get-content-model-items($content-definition)

};

qxrxe:traverseAttributes(){
()
};

qxrxe:traverseContent(){
    for content-model-item in qxsd:get-content-model-items($context)

};:)

(:################# CREATE TEMPLATE NODE #################:)

declare function qxrxe:create-template($node-info, $prefix, $context-node, $xsd, $depth){

    (:get prefix from node-info/@ref or use prefix from $context-node:)
     let $prefix := 
        if($node-info/@ref) then
            if(contains(xs:string($node-info/@ref), ':')) then
                substring-before(xs:string($node-info/@ref), ':')
            else
                $prefix
        else
            $prefix
    
    (:check if namespace if node and context-node differ. If yes declare new namespace:)
    
    let $namespace := xs:anyURI(qxrxe:get-namespace($node-info))    
    
    let $declare :=
        if(not($context-node) or $namespace!= xs:anyURI(qxrxe:get-namespace($context-node))) then
             qxrxe:declare-namespace($prefix, $namespace)
        else 
            ()

    let $local-name := $node-info/@name    
    let $name := concat($prefix, ':', $local-name)
    
    let $type := qxsd:get-type($node-info, $xsd)
    
    let $content-definition := qxrxe:get-relevant-content-model-items($type, $context-node, $xsd)
    
    return
    
            if($depth > $qxsd:default-max-depth) then
                ()
            else 
                element {$name} {  
                    
                    (:Debugging:)
                    (:attribute depth {$depth}
                    ,:)
                    qxrxe:create-attributes($type, $node-info, $xsd)
                    ,
                    if(qxrxe:can-have-element-content($node-info, $xsd)) then
                        qxrxe:create-content($content-definition, $prefix, $node-info, $xsd, $depth + 1)
                    else 
                        ()
                    
                }  
};



declare function qxrxe:create-content($content-definition, $prefix, $context, $xsd, $depth){
     let $content-model-items := qxrxe:get-relevant-content-model-items($content-definition, $context, $xsd)
     for $content-model-item in  $content-model-items
        return
                if ($content-model-item instance of element(xs:element)) then
                    qxrxe:create-template($content-model-item, $prefix, $context,  $xsd, $depth)
                else if ($content-model-item instance of element(xs:sequence)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)
                else if ($content-model-item instance of element(xs:choice)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)               
                else if ($content-model-item instance of element(xs:group)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)
                else ()
};





declare function qxrxe:create-attributes($type, $context-node, $xsd){
    for $attribute-info  in qxrxe:get-relevant-attributes($type, $context-node, $xsd)
        return qxrxe:create-attribute($attribute-info, $context-node, $xsd)
};

declare function qxrxe:create-attribute($attribute-info, $context-node, $xsd){
     
     let $prefix := 
        if($attribute-info/@ref) then
                qxsd:get-prefix($attribute-info/@ref)           
        else
            ()
    let $namespace := xs:anyURI(qxrxe:get-namespace($attribute-info))    
    
    let $declare :=
        if(not($context-node) or $namespace!= xs:anyURI(qxrxe:get-namespace($context-node))) then
             qxrxe:declare-namespace($prefix, $namespace)
        else 
            ()
     
     let $local-name := xs:string($attribute-info/@name)
     let $attribute-name := 
        (:TODO handle no prefix:)
        if($attribute-info/@form="qualified" and $prefix) then    
            concat($prefix, ':', $local-name)
        else
           $local-name
     return 
        attribute {$attribute-name} {qxsd:create-attribute-value($attribute-info, $xsd)}
};



declare function qxrxe:create-attribute-value($attribute-info, $xsd){
    let $type := qxsd:get-type($attribute-info, $xsd)    
    let $value := 
        if(qxsd:get-fixed($attribute-info)) then
            qxsd:get-fixed($attribute-info)
        else if(qxsd:get-default($attribute-info)) then
            qxsd:get-default($attribute-info)
        else if (qxsd:is-enum-restriction($type)) then
            qxsd:get-first-enum-value($type)
        else
            ''
   return $value 
};

(: ################# ANNOTATION #################:)


declare function qxrxe:get-annotation-options($parent, $context-node, $xsd){
    
    let $content := <xrxe:content><ead:extptr xmlns:ead="urn:isbn:1-931666-22-9">aber</ead:extptr> hallo <ead:emph xmlns:ead="urn:isbn:1-931666-22-9">liebe</ead:emph> alle zusmammen</xrxe:content>
    let $selection := <xrxe:selection>hallo <ead:emph xmlns:ead="urn:isbn:1-931666-22-9">liebe</ead:emph> alle</xrxe:selection>
    let $declare := util:declare-namespace('ead', xs:anyURI('urn:isbn:1-931666-22-9'))
    let $relevant-elements := qxrxe:get-relevant-elements($parent, $context-node, $xsd)
    
    let $relevant-elements-in-content := qxrxe:get-relevant-elements-in-content($relevant-elements, $content, $xsd)
    let $relevant-elements-for-selection := qxrxe:get-relevant-elements-in-selection($relevant-elements-in-content, $selection, $xsd)
    return $relevant-elements-for-selection
    
};

declare function qxrxe:get-relevant-elements-in-content($elements, $content, $xsd){
    for $element in $elements
        let $element-name := xs:string(qxrxe:get-name($element))
        let $count := util:eval(concat('count($content/ead:', $element-name, ')'))
        return 
            if($count lt qxrxe:get-max-occur($element, $xsd)) then
                $element
            else 
                ()
};

declare function qxrxe:get-relevant-elements-in-selection($elements, $selection, $xsd){
    for $element in $elements    
        return qxrxe:if-relevant-in-selection($element, $selection, $xsd)    
};

declare function qxrxe:if-relevant-in-selection($element, $selection, $xsd){
    
        if(qxrxe:is-empty($element, $xsd) and ($selection/text() or $selection/element())) then
            ()
        else if($selection/text() and $selection/element() and not(qxrxe:is-mixed($element, $xsd))) then
            ()
        else if($selection/element()) then
            (:let $type := qxsd:get-type($node-info, $xsd)
            let $content := qxrxe:get-relevant-content($type, $node-info, $xsd)
            let $elements-can-be-contained :=  qxrxe:get-relevant-elements($content, $node-info, $xsd):)
            $element
                
        else
            $element

};






(: ################# UTIL #################:)


(: FROM http://en.wikibooks.org/wiki/XQuery/Filtering_Nodes :)
declare function qxrxe:copy($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then qxrxe:copy($child)
                 else $child
      }
};

declare function qxrxe:declare-namespace($prefix, $namespace){
    if($prefix!='xml') then
        util:declare-namespace($prefix, xs:anyURI($namespace))
    else 
        ()
};
