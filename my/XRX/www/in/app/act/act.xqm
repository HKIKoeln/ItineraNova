xquery version "1.0";

module namespace act="http://itineranova.be/NS/act";

declare namespace tei="http://www.tei-c.org/ns/1.0/";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare function act:actually-transcribed($act-atomid as xs:string, $user-db-base-collection as node()*, $draft-db-base-collection as node()*) as xs:boolean {
    
    let $transcription-atomid := replace($act-atomid, '/act/', '/transcription/')
    return
    exists($user-db-base-collection//atom:id[.=$transcription-atomid]|$draft-db-base-collection//atom:id[.=$transcription-atomid])
};

declare function act:istranscribed($entry as element(atom:entry)) as xs:boolean {

    exists($entry//tei:body/tei:p//text())
};
   
declare function act:link($object-uri-tokens as xs:string+) as xs:string {

    xmldb:encode-uri(
        xmldb:decode(
            concat(
                conf:param('request-root'),
                string-join(
                    $object-uri-tokens,
                    '/'
                ),
                '/act'
            )
        )
    )    
};

declare function act:sorted-elements($act-elements as element(ead:c)*) as element()* {

    for $act-element in $act-elements
    
    let $act-unitid := $act-element/ead:did/ead:unitid/text()
    
    let $act-tmp :=
      if(contains($act-unitid,'-')) then 
        substring-before($act-unitid, '-') 
      else if(contains($act-unitid,',')) then 
        substring-before($act-unitid, ',') 
      else $act-unitid 
        
    let $folio-num := 
      if(contains($act-tmp, '.')) then
        substring-before(substring-after($act-tmp,'°'), '.') 
      else substring-after($act-tmp, '°') 
        
    let $act-num :=
      if(contains($act-tmp,'.')) then 
        if(string-length(substring-after($act-tmp, '.')) = 1) then
          concat('0',(substring-after($act-tmp, '.'))) 
        else substring-after($act-tmp, '.') 
      else '00' 
        
    let $page := 
      if(contains($act-tmp, 'R')) then 
        '0' 
      else
        '1' 
        
    let $orderstring := 
      replace(concat($folio-num, $page, $act-num), '\D', '') 
        
    order by xs:integer($orderstring)
    
    return
    $act-element    
};