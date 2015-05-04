 xquery version "1.0";
module namespace esetrans='http://www.monasterium.net/NS/esetrans';

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace europeana="http://www.europeana.eu/schemas/ese/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace eag="http://www.archivgut-online.de/eag";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace oai="http://www.openarchives.org/OAI/2.0/";
declare namespace atom="http://www.w3.org/2005/Atom";
 
declare function local:verschachtelung($adult as node()*) as node()* {
      for $child in $adult/node()
           return 
            if ($child instance of element())
                then local:verschachtelung($child)
            else $child
};

declare function esetrans:content($arch-doc as node(), $fond-doc as node(),  $source-doc as node()) as node() {
        <metadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
                   xmlns:europeana="http://www.europeana.eu/schemas/ese/"
                   xmlns:cdwa="http://www.getty.edu/research/conducting_research/standards/cdwa/">
                   xmlns:dc="http://purl.org/dc/elements/1.1/" 
                   xmlns:dcterms="http://purl.org/dc/terms/"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                   xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                   
             {
             let $provider := $arch-doc//*:autform/text()
             let $image-server-address := string($fond-doc//*:c/@xml:base)
             return
             let $abstract := $source-doc//*:abstract//text()
             let $source-abstract := $source-doc//*:sourceDescRegest/*:bibl/text()
             let $issued-date := concat($source-doc//*:issued/*:dateRange/text(), $source-doc//*:issued/*:date/text())
             let $issued-date-value := data($source-doc//*:issued/*:date/@*:value)
             let $issued-date-from-value := data($source-doc//*:issued/*:dateRange/@*:from)
         	
             let $issued-date-to-value := data($source-doc//*:issued/*:dateRange/@*:to)
             let $created := 
                 if(string-length($issued-date-value) gt 0) then 
                     $issued-date-value
                 else if($issued-date-from-value = $issued-date-to-value) then
                     $issued-date-from-value
                 else
                     concat($issued-date-from-value, ' - ', $issued-date-to-value)
             let $id := data($source-doc/@*:id)
             let $extent := $source-doc//*:physicalDesc/*:dimensions/text()
             let $identifier := ($source-doc//*:idno/text())[1]
             let $material := $source-doc//*:material/text()
             let $issued-place-name := $source-doc//*:issued/*:placeName/text()
             let $quote-date := $source-doc//*:quoteOriginaldatierung/text()[1]
             let $language := $source-doc//*:lang_MOM/text()
             return
             <record>
                 <dc:title>Archive:{string($arch-doc//*:repositorid/text())}_Fond:{string($fond-doc//*:unitid/@identifier)}_Charter:{$source-doc//*:idno/text()}</dc:title>
                 <dcterms:description>{ $abstract }{ if(string-length($source-abstract) gt 0) then concat(' [Quelle: ', $source-abstract, ']') else()}</dcterms:description>
                 { if(string-length($language) gt 0) then <dcterms:language>{ $language }</dcterms:language> else() }
                 { if(string-length($extent) gt 0) then <dcterms:extent>{ $extent }</dcterms:extent> else() }
                 <dcterms:identifier>{ $id }</dcterms:identifier>
                 { if($issued-place-name) then <dcterms:spacial>Ausstellungsort: { $issued-place-name }</dcterms:spacial> else() }
                 <dcterms:temporal>Datum der Ausstellung: { $created } ({ $issued-date }{ if($quote-date) then concat(', "', $quote-date, '"') else() })</dcterms:temporal>
                 { if($material) then <cdwa:materialsTechniquesDescription>{ $material }</cdwa:materialsTechniquesDescription> else() }
                 <cdwa:collection>{string($fond-doc//*:unitid/@identifier)}</cdwa:collection>
                 <europeana:provider>{ $provider }</europeana:provider>
                 <europeana:type>IMAGE</europeana:type>
                 {   
                     for $image in data($source-doc//*:graphic/@*:url)
                     order by $image
                     return
                     <europeana:isShownBy>{ $image-server-address }/{ $image }</europeana:isShownBy>
                 }
             </record>
            }   
       </oai_dc:dc>
     </metadata>
};

declare function esetrans:header($arch-doc as node(), $fond-doc as node(), $source-doc as node()) as node(){
<header>
 <identifier>oai:MoM:{$arch-doc//*:repositorid/text()}/{string($fond-doc//*:unitid/@identifier)}/{string($source-doc//*:idno/@id)}</identifier>
 <datestamp>{$source-doc//atom:updated/text()}</datestamp>
</header>
};
