xquery version "1.0";


declare option exist:serialize "omit-xml-declaration=yes";





import module namespace qschema="http://www.monasterium.net/NS/qschema"
    at "../qschema.xqm";
import module namespace xrxe="http://www.monasterium.net/NS/xrxe"
    at "../xrxe.xqm";
import module namespace xrxes="http://www.monasterium.net/NS/xrxes"
    at "../xrxes.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../../i18n/i18n.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
	at "../../xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
    
 
declare variable $data :=
    request:get-data();     
    
    

        let $service-name := request:get-parameter("service", "")
        let $xsdloc := request:get-parameter("xsdloc", "")
        
        
        let $xsd := qschema:get-node($xsdloc)
        
                let $service :=
                
                            if($service-name='get-options' or $service-name='get-attributes' or $service-name='get-label' or $service-name='get-menu') then
                            
                             let $elementExpression := request:get-parameter("context", "")
                             let $attrname := request:get-parameter("attrname", "")
                             let $attrvalue := request:get-parameter("attrvalue", "")
                             let $elementPath := qschema:getPath($elementExpression)
                             let $elementPathArray := qschema:getPathArray($elementPath)
                             let $element := $elementPathArray[fn:last()]
                             let $localName := qschema:getLocalName($element)
                             let $ns := qschema:getNamespace($element)
                             let $containsPathesArray := qschema:geContainsPathesArray($elementExpression)
                             let $containsElements := qschema:geContainsElements($containsPathesArray)
                             return 
                
           	                        if($service-name='get-options') then
           	                                xrxes:get-options($localName, $containsElements, $ns, $xsd)
          	                        else if($service-name='get-attributes') then
           	                                        xrxes:get-attributes($localName, $xsd) 	                        
           	                        else if($service-name='get-label') then
           	                                        xrxes:get-label($localName, $attrname, $attrvalue, $xsd)
           	                        else if($service-name='get-menu') then
           	                                        xrxes:get-menu($localName, $containsElements, $ns, $xsd)
           	                        else ()
           	                        
 	                        else if($service-name='unescape-mixed-content') then
 	                                 xrxe:get-unescape-mixed-content($data) 
 	                        else <xrxes:error>Service {$service-name} not found</xrxes:error>
                 return
                 		i18n:translate-xml($service) 
	

