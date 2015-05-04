xquery version "1.0";
import module namespace qxsd='http://www.monasterium.net/NS/qxsd' at '../editor/qxsd.xqm';
import module namespace qxrxe='http://www.monasterium.net/NS/qxrxe' at '../editor/qxrxe.xqm';
import module namespace qxrxa='http://www.monasterium.net/NS/qxrxa' at '../editor/qxrxa.xqm';

    
    let $service := request:get-parameter('service', '')
    let $xsdloc := request:get-parameter('xsdloc', '')
    (:TODO Change GET to POST, send the path and the element instead of context:)    
    let $context := request:get-parameter('context', '') 
   
    
   return 
    <xrxe:service name="{$service}" xsdloc="{$xsdloc}" context="{$context}" xmlns:xrxe="http://www.monasterium.net/NS/xrxe">
    {             
        
        (:##### QXSD SERVIVES ######:)        

        if($service='get-xsd') then
            qxsd:xsd($xsdloc)
            
        else if($service='get-node') then
            qxsd:get-node($context, $xsdloc)
            
        else if($service='get-node-definition') then
            qxsd:get-node-definition($context, $xsdloc)                  
   
        else if($service='get-node-content') then
            qxsd:get-node-content($context, $xsdloc)        

        else if($service='get-node-elements') then
            qxsd:get-node-elements($context, $xsdloc)  

        else if($service='get-node-attributes') then
            qxsd:get-node-attributes($context, $xsdloc)  
            
       (:##### QXRXE SERVIVES ######:)
       
       else if($service='get-node-info') then
            qxrxe:get-node-info($context, (), $xsdloc) 
            
       else if($service='get-node-appinfos') then
            qxrxe:get-node-appinfos($context, $xsdloc)
            
       else if($service='get-node-content') then
            qxrxe:get-node-content($context, $xsdloc)
            
       else if($service='get-node-relevant-elements') then
            qxrxe:get-node-relevant-elements($context, $xsdloc)   
            
        else if($service='get-node-relevant-attributes') then
            qxrxe:get-node-relevant-attributes($context, $xsdloc)       
            
        else if($service='get-node-template') then
            qxrxe:get-node-template($context, $xsdloc)
            
       (:##### ANNOTATION ######:)   
          
        else if($service='get-node-annotation-options') then
            qxrxe:get-node-annotation-options($context, $xsdloc)   

        (:##### QXRXA SERVIVES ######:)
        
        
        else if($service='get-attributes') then
            qxrxa:get-attributes($context, $xsdloc)       
       
            
       (:##### NO SERVIVES ######:)
                       
        else if($service='') then
            <qxsd:error>no service was named</qxsd:error>
        else 
            <qxsd:error>{concat('service ', $service, ' not found')}</qxsd:error>
   
    }
    </xrxe:service>


