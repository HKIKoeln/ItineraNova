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

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xrxe="http://www.monasterium.net/NS/xrxe";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace functx = "http://www.functx.com"; 

declare variable $qschema:name := "editVDU";
declare variable $qschema:default-relevant := fn:true();


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

declare function qschema:getSchema($namespace)
{
    (: let $xsd := doc("http://localhost:8181/rest/db/editor/querySchema/schemas/anno_cei_schema.xsd") :)
    
    let $servername := request:get-server-name()
    let $port := request:get-server-port()    
    let $server := if($port gt 80) then concat($servername, ':', xs:string($port)) else $servername    
    let $request-root :=  'mom'
    let $request := concat('http://', $server, $request-root)
    
    (: let $cei-loc := concat('http://', $xrx:servername, conf:param("request-root"), 'cei-xsd-annotated.xsd') :)
    
    let $xsd := 
    	if($namespace = 'cei') then
    		doc(concat($request, "cei-xsd-annotated.xsd"))
		else 
    		doc(concat($request, "ead-xsd-annotated.xsd"))
    
    (: let $xsd := doc("/db/editor/querySchema/schemas/anno_cei_schema.xsd") :)
    
    (: let $xsd := xmldb:document("/db/editor/querySchema/schemas/anno_cei_schema.xsd") :)
    
    (: let $xsd := root(collection('/db/editor/querySchema/schemas')//*:schema[@id='cei-xsd-annotated']) :)
   
   return $xsd
};

(:###############################################################:)
(:Duplicated from xrxe; TODO: create seared util module and place function's used together there:)

(:### function to give back the element root node defined in one 3 ways (db-path, id, or node)###:)
declare function qschema:get-node($something){    
    let $node := 
        if($something instance of xs:string) then
            if (exists(doc($something))) then
                doc($something)/element()
            else if (collection('/db')/*[@id=$something]) then
                collection('/db')/*[@id=$something]    
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

(:###############################################################:)

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
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:group[ancestor::xs:element/@name=$parent],
		(: $xsd/descendant::xs:element[@name=$parent]/descendant::xs:group[ancestor::xs:element[1]/@name=$parent], :)
		
		(: Für EAD-XSD zumindest nicht rekursiv relevant :)

		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:group[ancestor::xs:complexType/@name=$parent],
		(:$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:group[ancestor::xs:complexType[1]/@name=$parent],:)
		
		$xsd/descendant::xs:group[@name=$parent]/descendant::xs:group
	)
	let $elmts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:element[ancestor::xs:element/@name=$parent]/(@ref|@name),
		(: $xsd/descendant::xs:element[@name=$parent]/descendant::xs:element[ancestor::xs:element[1]/@name=$parent]/(@ref|@name), :)
		
		
		(: Für EAD-XSD zumindest nicht rekursiv relevant :)
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:element[ancestor::xs:complexType/@name=$parent]/(@ref|@name),
		(: $xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:element[ancestor::xs:complexType[1]/@name=$parent]/(@ref|@name),:)
		
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
		if($appinfo//*:relevant) then
			if($appinfo//*:relevant/text()) then
				if($appinfo//*:relevant/text()='true') then
					fn:true()
			    else if($appinfo//*:relevant/text()='false') then
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

declare function qschema:get-menu-item($elmt, $xsd)
{
	let $menu-item :=  
	
	(: flach bspw. EAD :)
	if ($xsd/descendant::xs:complexType[@name=$elmt]/xs:annotation[1]/xs:appinfo/*:menu-item) then
	   $xsd/descendant::xs:complexType[@name=$elmt]/xs:annotation[1]/xs:appinfo/*:menu-item
	
	(: lokale Def bspw. CEI :)
	else if($xsd/descendant::xs:element[@name=$elmt]/xs:annotation/xs:appinfo/*:menu-item) then
	    $xsd/descendant::xs:element[@name=$elmt]/xs:annotation/xs:appinfo/*:menu-item 
	
	else
	  ()
	
	
	return $menu-item
};

declare function qschema:get-the-label($elmt, $att-name, $att-value, $xsd) 
{
	let $pseudo :=  $xsd/descendant::xs:complexType[@name=$elmt]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$elmt and descendant::xs:enumeration and @name=$att-name]//xs:enumeration[@value=$att-value]//xs:appinfo/*:label
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
	let $label :=  $xsd/descendant::xs:enumeration[@value=$value]/xs:annotation[1]/xs:appinfo/*:label
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
    let $parent := replace($parent, 'xlink:', '')
 
	let $grps := 
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element/@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType/@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')],
		$xsd/descendant::xs:attributeGroup[@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')]/descendant::xs:attributeGroup
	)
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')]/(@ref|@name), 
		$xsd/descendant::xs:attributeGroup[@name=$parent and not(./xs:annotation/xs:appinfo/xrxe:relevant/text()='false')]/descendant::xs:attribute/(@ref|@name) 
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
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element/@name=$parent],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType/@name=$parent],
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attributeGroup
	)
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attribute/(@ref|@name)
	)
    return ()
	(:
		
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
	:)
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
        (qschema:get-atts($localName, (), $xsd) , qschema:get-imported-atts($localName, (), $xsd))
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
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent]/(@ref|@name)
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
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent and descendant::xs:enumeration]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent and descendant::xs:enumeration]/(@ref|@name)
	)	   
	return 
	
		$atts
		
	
};

(:only local defined non group attribues restriced by a enumeration and labeled by an annotation:)
declare function qschema:get-direct-labeled-enum-atts($parent, $found, $xsd)
{

	
	let $atts :=
	(
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent and descendant::xs:enumeration]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent and descendant::xs:enumeration]/(@ref|@name)
		(:
			$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name),
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType[1]/@name=$parent and descendant::xs:enumeration]/(@ref|@name)
		:)
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
		$xsd/descendant::xs:element[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:element/@name=$parent],
		$xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attributeGroup[ancestor::xs:complexType/@name=$parent],
		$xsd/descendant::xs:attributeGroup[@name=$parent]/descendant::xs:attributeGroup
	)
	

	let $enums :=
	(
	   $xsd/descendant::xs:element[@name=$parent]/descendant::xs:attribute[ancestor::xs:element/@name=$parent]/descendant::xs:enumeration[descendant::xs:appinfo]/@value,
	   $xsd/descendant::xs:complexType[@name=$parent]/descendant::xs:attribute[ancestor::xs:complexType/@name=$parent]/descendant::xs:enumeration[descendant::xs:appinfo]/@value,
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
    
       
        
        for $elmt in $elements
                let $att-names :=
                    for $att-name in distinct-values(qschema:get-direct-labeled-enum-atts($elmt, (), $xsd))   
                       
                            for  $att-value in distinct-values(qschema:get-direct-labeled-enum-att-value($elmt, $att-name, $xsd))       
                            let $label := qschema:get-enum-label($att-value, $xsd)                
                    
                            return <option value="{fn:concat($ns_add, $elmt, '@', $att-name, '="', $att-value, '"')}">
                                         {$label}
                                     </option> 
                                
                
                let $label : = qschema:get-label($elmt, $xsd)
                
                let $menu-item : = qschema:get-menu-item($elmt, $xsd)
                
                return if (qschema:is-relevant($elmt, $xsd))  then
	                (
	                <xrxe:option value="{fn:concat($ns_add, $elmt)}">
	                        {($label, $menu-item)}
	                       
	                </xrxe:option>
	                ,
	                $att-names)
                else
                	()
      


    return $options
};

declare function qschema:get-menu($options){
	
	(:HARDCODED MENU IN SCHEMA:)
	(: let $menu := $xsd/xs:annotation/xs:appinfo/xrxe:menu 
	return $menu
	:)
	
		
	(:DYNAMIC MENU:)
	 
	 let $menu-items := 
         for $menu-item in $options//xrxe:menu-item
         return $menu-item   
   
    let $distinct-menu-items := functx:distinct-deep($menu-items)

    
    let $submenus :=
        for $menu-item in $distinct-menu-items
            return
                 <xrxe:sub-menu>
                 
                 {
                     (
                     $menu-item
                     ,
                     for $option in $options/xrxe:option
                     let $option-menu-item := $option/xrxe:menu-item[1]                
                     return
                         if(functx:is-node-in-sequence-deep-equal($option-menu-item , $menu-item)) then
                             $option
                         else () 
                      )  
                 }
                 </xrxe:sub-menu>
                 
    let $submenus :=
        if($submenus) then
            $submenus
        else if ($options/xrxe:option) then
             <xrxe:sub-menu>           
                {
                (
                <xrxe:menu-item><xrx:i18n>
						<xrx:key>select-annotation</xrx:key>
						<xrx:default>...Markierung auswählen</xrx:default>
					</xrx:i18n>
         		</xrxe:menu-item>
         		,
         		$options/xrxe:option
         		)
         		}
             </xrxe:sub-menu>
        else()
    
    return   <xrxe:menu>{$submenus}</xrxe:menu>
	
	
};

(: declare function qschema:get-menu($options){ :)
	
	(:HARDCODED MENU IN SCHEMA:)
	(: let $menu := $xsd/xs:annotation/xs:appinfo/xrxe:menu 
	return $menu
	:)
	
		
	(:DYNAMIC MENU without options:)
	 
	 (:let $menu-items := 
         for $menu-item in $options//xrxe:menu-item
         return $menu-item   
   
    let $distinct-menu-items := functx:distinct-deep($menu-items)

    return   <xrxe:menu>{$distinct-menu-items}</xrxe:menu>
	
	
};:)

declare function functx:is-node-in-sequence-deep-equal 
  ( $node as node()? ,
    $seq as node()* )  as xs:boolean {
       
   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 } ;

declare function functx:distinct-deep 
  ( $nodes as node()* )  as node()* {
       
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
                          .,$nodes[position() < $seq]))]
 } ; 
 declare function functx:is-node-in-sequence-deep-equal 
  ( $node as node()? ,
    $seq as node()* )  as xs:boolean {
       
   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 } ;






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