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

module namespace qschema="http://www.monasterium.net/NS/qschema";

import module namespace upd="http://www.monasterium.net/NS/upd"
    at "../upd/upd.xqm";


declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xrxe="http://www.monasterium.net/NS/xrxe";

declare variable $qschema:name := "editVDU";
declare variable $qschema:default-relevant := fn:true();

(: ################# SCHEMA ################################:)

declare function qschema:getSchema($namespace)
{

	(: Neu verurschat fehler:)
    
    let $xsd := 
    	if($namespace = 'cei') then
    		collection('/db/www/mom/res')/xs:schema[@id='cei-xsd-annotated']
		else 
    		collection('/db/www/mom/res')/xs:schema[@id='ead-xsd-annotated']
	
	
	(: Alt :)
    (:
    let $xsd := 
    	if($namespace = 'cei') then
    		doc("http://localhost:8181/mom/cei-xsd-annotated.xsd")
		else 
    		doc("http://localhost:8181/mom/ead-xsd-annotated.xsd")
   :) 
   return $xsd
};

(: ################# GET XS-ELEMENTS BY NAME ################################:)


declare function qschema:get-element($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used:)
	let $element := $xsd/descendant::xs:element[@name=$name][1]
	return $element
};


declare function qschema:get-group($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $group := $xsd/descendant::xs:group[@name=$name][1] 
	return $group
};

declare function qschema:get-attribute($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $attribute := $xsd/descendant::xs:attribute[@name=$name][1] 
	return $attribute
};

declare function qschema:get-attribute-group($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $group := $xsd/descendant::xs:attributeGroup[@name=$name][1] 
	return $group
};

(:join qschema:get-complex-type and qschema:get-simple-type to qschema:get-type if a simpleTYpe cannot have the same name than a complexType:)
declare function qschema:get-complex-type($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $complex-type := $xsd/descendant::xs:complexType[@name=$name][1] 
	return $complex-type
};

declare function qschema:get-simple-type($name, $xsd){
	(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $simple-type := $xsd/descendant::xs:simpleType[@name=$name][1] 
	return $simple-type
};

(: ################# GET XS-ELEMENTS BY NAME ################################:)

declare function qschema:get-label-of-named-item($name, $item-type, $xsd){
(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $item :=
		if ($item-type='element') then
			qschema:get-element($name, $xsd)
		else if ($item-type='attribute') then
			qschema:get-attribute($name, $xsd)
		else if ($item-type='group') then
			qschema:get-group($name, $xsd)
		else if ($item-type='attribute-group') then
			 qschema:get-attribute-group($name, $xsd)
		else if ($item-type='type') then
			qschema:get-complex-type($name, $xsd)
		else ()
	return $item
};

declare function qschema:get-label-of-item($name, $item-type, $xsd){
(: Use path instead of just name. There can be more than one xs:element with the same name (see ead). They could have diffrent types. Use [1] as long as no path is used :)
	let $item :=
		if ($item-type='element') then
			qschema:get-child-elements-def(qschema:get-element($name, $xsd), $xsd)		
		else ()
	return $item
};


(: ##########################################################################:)


declare function qschema:get-relevant-child-elements($name, $xsd)
{
	for $child-element in qschema:get-child-elements-def($name, $xsd)
		let $appinfos := qschema:get-appinfo($child-element)
		let $in-force-relevant :=
			if ($appinfos[1]/xrxe:relevant[1]) then
		 			qschema:get-boolean-relevant($appinfos[1]/xrxe:relevant[1]/text())
			else $qschema:default-relevant	
				
		return 
			if ($in-force-relevant) then
				$child-element
			else
				()
};



declare function qschema:get-boolean-relevant($relevant-string as xs:string) as xs:boolean{
	let $relevant := 	
		if($relevant-string='true') then
			fn:true()
		else if ($relevant-string='false') then
			fn:false()
		else
			$qschema:default-relevant	
	return $relevant
};

declare function qschema:get-child-elements-def($name, $xsd)
{
	for $child-element in qschema:get-child-elements($name, (), $xsd)	
		return 
			
		if ($child-element/@ref) then
			let $name := data($child-element/@ref)
			let $local-appinfo := qschema:get-appinfo($child-element)
			let $child-element-def := qschema:get-element($name, $xsd)
			let $child-element-copy :=  qschema:copy($child-element-def) 
			let $local-appinfo := qschema:get-appinfo($child-element)
			let $insert-into-as-first :=
                 if ($child-element-copy and $local-appinfo) then
                	upd:insert-into-as-first($child-element-copy, $local-appinfo) 
                 else if ($child-element-def) then
                 	$child-element-def
                 else ()        
            return $insert-into-as-first 
			
		else if ($child-element/@name and $child-element/@type) then
			let $name := data($child-element/@type)
			let $type := qschema:get-complex-type($name, $xsd)
			let $child-element-copy := qschema:copy($child-element)
			let $insert-into-as-last :=
                if ($child-element-copy and $type) then
                	upd:insert-into-as-last($child-element-copy, $type) 
                 else $child-element           
            return $insert-into-as-last   
		else
			$child-element
		
};

declare function qschema:create-element-definition($child-element, $xsd){
	let $element-def :=
		if ($child-element/@ref) then
			let $name := data($child-element/@ref)
			let $local-appinfo := qschema:get-appinfo($child-element)
			let $child-element-def := qschema:get-element($name, $xsd)
			let $child-element-copy :=  qschema:copy($child-element-def) 
			let $local-appinfo := qschema:get-appinfo($child-element)
			let $insert-into-as-first :=
                 if ($child-element-copy and $local-appinfo) then
                	upd:insert-into-as-first($child-element-copy, $local-appinfo) 
                 else if ($child-element-def) then
                 	$child-element-def
                 else ()        
            return $insert-into-as-first 
			
		else if ($child-element/@name and $child-element/@type) then
			let $name := data($child-element/@type)
			let $type := qschema:get-complex-type($name, $xsd)
			let $child-element-copy := qschema:copy($child-element)
			let $insert-into-as-last :=
                if ($child-element-copy and $type) then
                	upd:insert-into-as-last($child-element-copy, $type) 
                 else $child-element           
            return $insert-into-as-last   
		else
			$child-element
	return $element-def
};



(: #######################  CHILDREN ################################:)

(:
declare function qschema:get-local-relevant-child-elements-def($name, $xsd)
{
	for $child-element in qschema:get-child-elements($parent, $found, $xsd)
		return 
		if ($child-element/@ref) then
			let $name := data($child-element/@ref)
			return qschema:get-element($name, $xsd)
		else if ($child-element/@name and $child-element/@type) then
			let $name := data($child-element/@type)
			(: copy type into element :)
			return qschema:get-complex-type($name, $xsd)
		else
			$child-element
};
:)


declare function qschema:get-child-elements($parent, $found, $xsd)
{
	let $local-groups := qschema:get-local-child-groups($parent, $xsd)
	
	let $local-child-elements := qschema:get-local-child-elements($parent, $xsd) 

	let $grouped-elements := qschema:get-elements-from-groups($local-groups, $found, $xsd)		
	
	let $elements := ($local-child-elements , $grouped-elements)
	
	return
		$elements
};

declare function qschema:get-children($parent, $found, $xsd)
{
	let $local-groups := qschema:get-local-child-groups($parent, $xsd)
	
	let $local-child-elements := qschema:get-local-child-elements($parent, $xsd) 
	
	let $children := ($local-groups, $local-child-elements)
	
	return
		$children
};


(: #######################  CHILD GROUPS ################################:)

declare function qschema:get-local-child-groups($parent, $xsd)
{	
	let $groups := 
	(
		qschema:get-child-groups-in-element($parent, $xsd)
		,
		qschema:get-child-groups-in-complex-type($parent, $xsd)
		,
		qschema:get-child-groups-in-group($parent, $xsd)
	)	
	return $groups	
};

declare function qschema:get-child-groups-in-element($parent, $xsd)
{	
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:group[ancestor::xs:element/@name=$parent]	
		(:$xsd/descendant::xs:element[@name=$parent]/descendant::xs:group[ancestor::xs:element[1]/@name=$parent]:)
};

declare function qschema:get-child-groups-in-complex-type($parent, $xsd)
{	
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:group[ancestor::xs:complexType/@name=$parent]
		(:$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:group[ancestor::xs:complexType[1]/@name=$parent]:)
};

declare function qschema:get-child-groups-in-group($parent, $xsd)
{	
		$xsd/descendant::xs:group[@name=$parent]/descendant::xs:group
};

(: #######################  CHILD ELEMENTS ################################:)

declare function qschema:get-local-child-elements($parent, $xsd)
{	
	let $elements := 
	(
		qschema:get-child-elements-in-element($parent, $xsd)
		,
		qschema:get-child-elements-in-complex-type($parent, $xsd)
		,
		qschema:get-child-elements-in-group($parent, $xsd)
	)	
	return $elements	
};

declare function qschema:get-child-elements-in-element($parent, $xsd)
{	
	$xsd/descendant::xs:element[@name=$parent]/descendant::xs:element[ancestor::xs:element/@name=$parent]
	(:$xsd/descendant::xs:element[@name=$parent]/descendant::xs:element[ancestor::xs:element[1]/@name=$parent]:)
};

declare function qschema:get-child-elements-in-complex-type($parent, $xsd)
{	
	$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:element[ancestor::xs:complexType/@name=$parent]
	(:$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:element[ancestor::xs:complexType[1]/@name=$parent]:)
};

declare function qschema:get-child-elements-in-group($parent, $xsd)
{	
	$xsd/descendant::xs:group[@name=$parent]/descendant::xs:element
};

declare function qschema:get-elements-from-groups($groups, $found, $xsd){
	for $group in $groups
			return
				if($group intersect $found) then
					()
				else
					qschema:get-child-elements(data($group/@ref), ($found, $group), $xsd) 
};



declare function qschema:get-named-type($name, $xsd){
	
	let $type := 
		if($xsd/descendant::xs:complexType[@name=$name]) then
			$xsd/descendant::xs:complexType[@name=$name]
		else if($xsd/descendant::xs:simpleType[@name=$name]) then
			$xsd/descendant::xs:simpleType[@name=$name]
		else ()
	return $type
};

(: FROM http://en.wikibooks.org/wiki/XQuery/Filtering_Nodes :)
declare function qschema:copy($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then qschema:copy($child)
                 else $child
      }
};




























declare function qschema:getPath($elementExpression)
{
   let $path := 
   if (fn:contains($elementExpression, '[')) then
        fn:substring-before($elementExpression, '[')
   else 
        $elementExpression
   return $path
};

declare function qschema:getPathArray($elementPath){
    let $pathArray := fn:tokenize($elementPath, '/')
    return $pathArray
};

declare function qschema:geContainsPathesArray($elementExpression){
      let $containsString := fn:substring-after(fn:translate($elementExpression, ']', ''), '[')
      let $containsArray := fn:tokenize($containsString, ' ') 
      return $containsArray
};

declare function  qschema:geContainsElements($containsPathesArray)
{
    for $containsPath in $containsPathesArray
        let $containsPathArray :=  qschema:getPathArray($containsPath)
        let $elementOfPath := $containsPathArray[fn:last()]
        return $elementOfPath
    
 
};



declare function qschema:getLocalName($element)
{
    let $localName :=
        if (fn:contains($element, ':')) then
              substring-after($element, ':')
        else $element 
    return $localName
};

declare function qschema:getNamespace($element)
{
    let $ns :=
        if (fn:contains($element, ':')) then
              substring-before($element, ':')
        else 'cei'
    return $ns
};



declare function qschema:get-fwd-elmts($parent, $found, $xsd)
{
	
	let $grps := 
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:group[ancestor::xs:element[1]/@name=$parent],
		
		(: Für EAD-XSD zumindest nicht rekursiv relevant :)
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:group[ancestor::xs:complexType[1]/@name=$parent],
		
		$xsd/descendant::xs:group[@name=$parent]/descendant::xs:group
	)
	let $elmts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:element[ancestor::xs:element[1]/@name=$parent]/(@ref|@name),
		
		(: Für EAD-XSD zumindest nicht rekursiv relevant :)
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:element[ancestor::xs:complexType[1]/@name=$parent]/(@ref|@name),
		
		$xsd/descendant::xs:group[@name=$parent]/descendant::xs:element/(@ref|@name)
	)
	return
	(
		$elmts,
		if($grps)
		then
			for $grp in $grps
			return
				if($grp intersect $found)
				then()
				else
				qschema:get-fwd-elmts(data($grp/@ref), ($found, $grp), $xsd)
		else ()
	)
};

declare function qschema:get-definition($elmt, $xsd)
{
	let $def := 
		if($xsd/descendant::xs:element[child::xs:complexType and @name=$elmt]) then
			$xsd/descendant::xs:element[child::xs:complexType and @name=$elmt] 
		else if ($xsd/descendant::xs:complexType[@name=$elmt] ) then
 			$xsd/descendant::xs:complexType[@name=$elmt] 
		else ()
	return $def
};

declare function qschema:get-appinfo($def)
{
	let $appinfo := $def//xs:appinfo[@source='EditVDU']
	return $appinfo
};

declare function qschema:get-relevant($appinfo)
{
	let $relevant := 
		if($appinfo//relevant) then
			if($appinfo//relevant/text()) then
				if($appinfo//relevant/text()='true') then
					fn:true()
			    else if($appinfo//relevant/text()='false') then
					fn:false()
				else
				  $qschema:default-relevant
				
			else
			 $qschema:default-relevant
		else 
			 $qschema:default-relevant
	return $relevant
};

declare function qschema:is-relevant($elmt, $xsd)
{
	let $def := qschema:get-definition($elmt, $xsd)
	let $appinfo := qschema:get-appinfo($def)	
	let $is-relevant := qschema:get-relevant($appinfo) 
	return $is-relevant
};



declare function qschema:get-label($elmt, $xsd)
{
	let $label :=  
	
	(: flach bspw. EAD :)
	if ($xsd/descendant::xs:complexType[@name=$elmt]/xs:annotation[1]/xs:appinfo/*:label) then
	   $xsd/descendant::xs:complexType[@name=$elmt]/xs:annotation[1]/xs:appinfo/*:label
	
	(: lokale Def bspw. CEI :)
	else if($xsd/descendant::xs:element[@name=$elmt]/xs:annotation/xs:appinfo/*:label) then
	    $xsd/descendant::xs:element[@name=$elmt]/xs:annotation/xs:appinfo/*:label 
	
	(: nicht annotirte Schemas --> Knotenname wird label:)
	else
	  $elmt
	
	
	
	return $label
};

declare function qschema:get-the-label($elmt, $att-name, $att-value, $xsd) 
{
	let $pseudo :=  $xsd/descendant::xs:complexType[@name=$elmt]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$elmt and descendant::xs:enumeration and @name=$att-name]//xs:enumeration[@value=$att-value]//xs:appinfo/text()
	let $label := 
	if ($pseudo and $pseudo!='') 
	then
	   $pseudo
	else 
	   qschema:get-label($elmt, $xsd)   
	
	return $label

};

declare function qschema:get-enum-label($value, $xsd)
{
	let $label :=  $xsd/descendant::xs:enumeration[@value=$value]/xs:annotation[1]/xs:appinfo/text()
	return $label
};

declare function qschema:get-bwd-elmts($child, $found, $xsd)
{
	let $grps := 
	(
		$xsd/descendant::xs:element[(@name|@ref)=$child]/ancestor::xs:group[1],
		$xsd/descendant::xs:group[@ref=$child]/ancestor::xs:group[1]
	)
	let $elmts :=
	(
		$xsd/descendant::xs:element[(@name|@ref)=$child]/ancestor::xs:element[1]/@name,
		$xsd/descendant::xs:element[(@name|@ref)=$child]/ancestor::xs:complexType[1]/@name,	
		$xsd/descendant::xs:group[@ref=$child]/ancestor::xs:element[1]/@name,
		$xsd/descendant::xs:group[@ref=$child]/ancestor::xs:complexType[1]/@name
	)
	return
	(
		$elmts,
		if($grps)
		then
			for $grp in $grps
			return
			if($grp intersect $found)
			then()
			else
			qschema:get-bwd-elmts(data($grp/@name), ($grp, $found), $xsd)
		else ()
	)
};




declare function qschema:get-atts($parent, $found, $xsd)
{
 
	let $grps := 
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element[1]/@name=$parent],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType[1]/@name=$parent],
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attributeGroup
	)
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attribute/(@ref|@name)
	)
	   
	return 
	(
		$atts,
		if($grps)
		then
			for $grp in $grps
			return
			if($grp intersect $found)
			 then()
			else
			
			 qschema:get-atts(data($grp/@ref), ($grp, $found), $xsd)
		else ()
	)
};

declare function qschema:get-imported-atts($parent, $found, $xsd){
    let $grps := 
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element[1]/@name=$parent],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType[1]/@name=$parent],
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attributeGroup
	)
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attribute/(@ref|@name)
	)
    return 
	(
		
		if($grps)
		then
			for $grp in $grps
			return
			if($grp intersect $found)
			then ()
			else
			    if( fn:contains ($grp/@ref/string(), ':'))
     			then 
			       let $ns := substring-before($grp/@ref/string(), ':')
			       let $name := substring-after($grp/@ref/string(), ':')
			       let $imp := $xsd//xs:import/@schemaLocation/string()
                   let $imp-xsd :=doc(xs:anyURI($imp))
			       return
			       qschema:get-atts($name, (), $imp-xsd)
			     else			     
			     qschema:get-imported-atts(data($grp/@ref), ($grp, $found), $xsd)
		else ()
	)
};

declare function qschema:get-attr-elmt($localName, $xsd)       
{

    let $elmt :=
    element { $localName } {
    namespace xlink {'http://www.w3.org/1999/xlink'},
     for $attr in  distinct-values(qschema:get-all-atts($localName, $xsd))
        return
          attribute {$attr}{''}
    }
    
    return $elmt
};


(:declare function qschema:get-attr-elmt($localName, $xsd)       
{

    let $elmt :=
    element { $localName } {
     for $attr in  distinct-values(qschema:get-imp-atts($localName, (), $xsd))
        return
          attribute {$attr}{''}
    }
    
    return $elmt
};:)

declare function qschema:get-all-atts($localName, $xsd){
    let $all-atts :=
        (qschema:get-atts($localName, (), $xsd), qschema:get-imported-atts($localName, (), $xsd))
     return $all-atts
};


(:
declare function qschema:get-imp-attr-elmt($localName, $xsd)    
{
    let $elmt :=
    element { $localName } {
     namespace xlink {'http://www.w3.org/1999/xlink'},
     for $attr in  distinct-values(qschema:get-imp-atts($localName, (), $xsd))
        return
                attribute {$attr}{''}
    }
    return $elmt
};:)







(:only local defined non group attribues:)
declare function qschema:get-direct-atts($parent, $found, $xsd)
{
	let $grps := ()
	
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent]/(@ref|@name)
	)
	   
	return 
	(
		$atts,
		if($grps)
		then
			for $grp in $grps
			return
			if($grp intersect $found)
			then()
			else
			qschema:get-atts(data($grp/@ref), ($grp, $found), $xsd)
		else ()
	)
};

(:only local defined non group attribues restriced by a enumeration:)
declare function qschema:get-direct-enum-atts($parent, $found, $xsd)
{
	
	
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name)
	)	   
	return 
	
		$atts
		
	
};

(:only local defined non group attribues restriced by a enumeration and labeled by an annotation:)
declare function qschema:get-direct-labeled-enum-atts($parent, $found, $xsd)
{

	
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name)
	)	   
	return 	
		$atts
		

};

declare function qschema:get-direct-labeled-enum-att-value($elmt, $att, $xsd)    

{
    let $enums :=
	(
	    $xsd/descendant::xs:element[@name=$elmt]/descendant::xs:attribute[@name=$att]/descendant::xs:enumeration[descendant::xs:appinfo]/@value, 
	   $xsd/descendant::xs:complexType[@name=$elmt]/descendant::xs:attribute[@name=$att]/descendant::xs:enumeration[descendant::xs:appinfo]/@value
	)
	return 	
		$enums

};



declare function qschema:get-enums($parent, $found, $xsd)
{
	let $grps := 
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element[1]/@name=$parent],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType[1]/@name=$parent],
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attributeGroup
	)
	

	let $enums :=
	(
	   $xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent]/descendant::xs:enumeration[descendant::xs:appinfo]/@value,
	   $xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent]/descendant::xs:enumeration[descendant::xs:appinfo]/@value,
	   $xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attribute/descendant::xs:enumeration[descendant::xs:appinfo]/@value
	)
	   
	return 
	(
		$enums,
		if($grps)
		then
			for $grp in $grps
			return
			if($grp intersect $found)
			then()
			else
			qschema:get-enums(data($grp/@ref), ($grp, $found), $xsd)
		else ()
	)
};






declare function qschema:get-prnt-elmts($child, $found, $xsd)
{
	let $grps := 
	(
		$xsd/descendant::xs:attribute[(@name|@ref)=$child]/ancestor::xs:attributeGroup[1],
		$xsd/descendant::xs:attributeGroup[@ref=$child]/ancestor::xs:attributeGroup[1]
	)
	let $elmts :=
	(
		$xsd/descendant::xs:attribute[(@name|@ref)=$child]/ancestor::xs:element[1]/@name,
		$xsd/descendant::xs:attribute[(@name|@ref)=$child]/ancestor::xs:complexType[1]/@name,
		$xsd/descendant::xs:attributeGroup[(@name|@ref)=$child]/ancestor::xs:element[1]/@name,
		$xsd/descendant::xs:attributeGroup[(@name|@ref)=$child]/ancestor::xs:complexType[1]/@name
	)
	return
	(
		$elmts,
		for $grp in $grps
		return
		qschema:get-prnt-elmts(data($grp/@name), (), $xsd)
	)
};




declare function qschema:value-intersect($arg1 as xs:anyAtomicType* ,
    $arg2 as xs:anyAtomicType* )  as xs:anyAtomicType* {       
  distinct-values($arg1[.=$arg2])
 } ;
 
declare function qschema:non-distinct-values-count($seq, $num){
for $val in distinct-values($seq)
   return $val[count($seq[. = $val]) = $num]
};


declare function qschema:get-options($elements, $xsd, $ns_add){
    

    
    let $options :=
    
        <span>
        {  
        
        for $elmt in $elements
                let $att-names :=
                    for $att-name in distinct-values(qschema:get-direct-labeled-enum-atts($elmt, (), $xsd))   
                       
                            for  $att-value in distinct-values(qschema:get-direct-labeled-enum-att-value($elmt, $att-name, $xsd))       
                            let $label := qschema:get-enum-label($att-value, $xsd)                
                    
                            return <option value="{fn:concat($ns_add, $elmt, '@', $att-name, '="', $att-value, '"')}">
                                         {$label}
                                     </option> 
                                
                
                let $label : = qschema:get-label($elmt, $xsd)
                
                return if (qschema:is-relevant($elmt, $xsd))  then
	                (
	                <option value="{fn:concat($ns_add, $elmt)}">
	                        {$label}
	                </option>
	                ,
	                $att-names)
                else
                	()
        }
        
        
      
        
       
        </span>

    return $options
};



(:############## HTML WIDGETS #####################:)

declare function qschema:elmt-link($elmt, $xsd)
{
	<span>
  		<form name="form" method="POST">
  			<input type="hidden" name="name" value="{data($elmt)}"/>
  		</form>
		<a href="{concat('element.xql?name=', data($elmt))}" onclick="form.submit()"> {data($elmt)} </a>
		<span>({qschema:get-label($elmt, $xsd)})</span>
		
		<!--ul>{
		  for $att in qschema:get-atts($elmt, (), $xsd)
		  let $att-name := data($att) 
		  
		 

		  return <li>{$att-name}</li>
		  }
		</ul-->
		
		
		 
		
	</span>
};

declare function qschema:get-fwd-elements-select($elementLocalName, $xsd)
{	
	<form action="element.xql">
       	<select name="name">
       	{
       	    for $elmt in distinct-values(qschema:get-fwd-elmts($elementLocalName, (), $xsd))
		    order by $elmt
		    return   qschema:get-fwd-elements-select-options($elmt) 
		}
       	</select>
	</form>
};

declare function qschema:get-fwd-elements-select-options($elmt)
{
	<option onchange="form.submit()" value="{data($elmt)}">{data($elmt)}</option>
};

declare function qschema:get-select($options){
let $select :=
<select >
        {  
        for $elmt in $options
                let $label := qschema:get-label($elmt, $xsd)
                order by $label
                return <option value="{$elmt}">
                        {$label}
                       </option>  
        }
</select>
return $select
};