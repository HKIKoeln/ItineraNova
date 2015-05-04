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

module namespace oaiinterface="http://www.monasterium.net/NS/oaiinterface";

(: declaration of namespaces:)
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace eag="http://www.archivgut-online.de/eag";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace oai="http://www.openarchives.org/OAI/2.0/";
declare namespace atom="http://www.w3.org/2005/Atom";

(: params from OAI-PMH spec :)
declare variable $oaiinterface:verb                := request:get-parameter("verb","0");
declare variable $oaiinterface:identifier          := request:get-parameter("identifier","0");
declare variable $oaiinterface:metadataPrefix      := request:get-parameter("metadataPrefix","0"); 
declare variable $oaiinterface:set                 := request:get-parameter("set","0");
declare variable $oaiinterface:from                := request:get-parameter("from","0");
declare variable $oaiinterface:until               := request:get-parameter("until","0");
declare variable $oaiinterface:resumptionToken     := request:get-parameter("resumptionToken","0");
declare variable $oaiinterface:parameters          := request:get-parameter-names();
declare variable $oaiinterface:earliest-datestamp  := '2005-01-01T00:00:00Z' cast as xs:dateTime;

(:  output has to be XML :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

(: import module :)
import module namespace esetrans='http://www.monasterium.net/NS/esetrans' at 'oaimodule_ese.xqm';
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

(: validate both dates:)
declare function local:validate-dates() {
    let $date-pattern := '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z){0,1}$'
    let $oaiinterface:from-len     := string-length($oaiinterface:from)
    let $oaiinterface:until-len    := string-length($oaiinterface:until)
    return
        if ($oaiinterface:from-len > 0 and $oaiinterface:until-len > 0 and $oaiinterface:from-len != $oaiinterface:until-len) then
            false()
        else
            matches($oaiinterface:from, $date-pattern) and matches($oaiinterface:until, $date-pattern)
};

(: validate from dates:)
declare function local:validate-fromdate() {
    let $date-pattern := '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z){0,1}$'
    let $oaiinterface:from-len     := string-length($oaiinterface:from)
    return
        if ($oaiinterface:from-len = 0) then
            false()
        else
            matches($oaiinterface:from, $date-pattern)
};

(: validate until dates:)
declare function local:validate-untildate() {
    let $date-pattern := '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z){0,1}$'
    let $oaiinterface:until-len     := string-length($oaiinterface:until)
    return
        if ($oaiinterface:until-len = 0) then
            false()
        else
            matches($oaiinterface:until, $date-pattern)
};

(: validate Resumption Token:)
declare function local:validate-ResToken() {
    let $ResTok-len   := string-length($oaiinterface:resumptionToken)
    return
        if ($ResTok-len = 0) then
            false()
        else
            starts-with($oaiinterface:resumptionToken, "oai_dc\oai:MoM:") 
};

(: validate parameter :)
declare function local:validate-params() as node()*{
let $errors :=

if(not(fn:compare($oaiinterface:set,"0")=0)) then <error code="noSetHierarchy">No set structure available</error> 

else if((fn:compare($oaiinterface:resumptionToken,"0")!=0)) then
    if(not(local:validate-ResToken()))then 
        <error code="badResumptionToken">Resumption Token is not valid</error>
    else()

else if($oaiinterface:verb  = "ListSets") then <error code="noSetHierarchy">No set structure available</error>

else if($oaiinterface:verb  = "ListIdentifiers" or $oaiinterface:verb  ="ListRecords") then
      if(fn:compare($oaiinterface:metadataPrefix,"0")=0) then <error code="badArgument">The parameter metadataPrefix is required</error>
      else if(fn:compare($oaiinterface:metadataPrefix,"oai_dc")!=0) then <error code="cannotDisseminateFormat">Metadata format is not available</error> 
      else if(fn:compare($oaiinterface:from,"0")!=0 and fn:compare($oaiinterface:until,"0")!=0) then
           if(not(local:validate-dates())) then <error code="badArgument">No valid date format</error>
           else if($oaiinterface:until cast as xs:dateTime < $oaiinterface:earliest-datestamp)
                then <error code="noRecordsMatch">date of until parameter is lower than the earliest datestamp</error>
           else if($oaiinterface:from cast as xs:dateTime > current-dateTime() cast as xs:dateTime)
                then <error code="noRecordsMatch">date of from- parameter is a future date</error>
           else()
      else if(fn:compare($oaiinterface:from,"0")!=0 and fn:compare($oaiinterface:until,"0")=0) then 
           if(not(local:validate-fromdate())) then <error code="badArgument">No valid from- date format</error>
           else if($oaiinterface:from cast as xs:dateTime > current-dateTime() cast as xs:dateTime)
                then <error code="noRecordsMatch">date of from- parameter is a future date</error>
           else()
      else if(fn:compare($oaiinterface:from,"0")=0 and fn:compare($oaiinterface:until,"0")!=0) then 
           if(not(local:validate-untildate())) then <error code="badArgument">No valid until- date format</error>
           else if($oaiinterface:until cast as xs:dateTime < $oaiinterface:earliest-datestamp)
                then <error code="noRecordsMatch">date of until parameter is lower than the earliest datestamp</error>
           else()
      else ()
      
else if($oaiinterface:verb  ="Identify") then
        if(count($oaiinterface:parameters)>1) then <error code="badArgument">No further arguments allowed</error> 
        else()
        
else if($oaiinterface:verb  ="ListMetadataFormats") then
         if (count($oaiinterface:parameters)>1)then 
                if(fn:compare($oaiinterface:identifier,"0")=0) then <error code="badArgument">Arguments is not allowed</error>
                else()
         else()

else if($oaiinterface:verb  ="GetRecord")then
      if(fn:compare($oaiinterface:metadataPrefix,"0")=0) then <error code="badArgument">The parameter metadataPrefix is required</error>
      else if(fn:compare($oaiinterface:metadataPrefix,"oai_dc")!=0) then <error code="cannotDisseminateFormat">Metadata format is not available</error>
      else if(fn:compare($oaiinterface:identifier,"0")=0) then <error code="badArgument">The parameter identifier is required</error>
      else()
      
else <error code="badVerb">No valid request type</error>
return
    if(empty($errors)) then
         (: handle parameters to produce a response:)
         local:response()
    else
        $errors
};

(: try to produce the headers :)
declare function local:oaiheader($oaifrom as xs:string, $oaiuntil as xs:string) as node()*{
let $allArchives := collection(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/'))//*:repositorid
return
    for $archive in $allArchives
    return
        let $allFonds := collection(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text()))//*:unitid
        return
            for $fond in $allFonds
            return
                let $allCharters := collection(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), "/", string($fond/@identifier), "/"))
                return
                    for $charter in $allCharters
                    return
                        if(fn:compare($oaifrom,"0")!=0 or fn:compare($oaiuntil,"0")!=0)
                        then
                            if(fn:compare($oaifrom,"0")!=0 and fn:compare($oaiuntil,"0")!=0)
                            then
                                let $oaifrom := $oaifrom cast as xs:dateTime
                                let $oaiuntil := $oaiuntil cast as xs:dateTime
                                return
                                    if($oaifrom <= $charter//atom:updated/text() cast as xs:dateTime and $oaiuntil >= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        <test>oai</test>
                                    else()  
                            else if(fn:compare($oaifrom,"0")!=0 and fn:compare($oaiuntil,"0")=0)
                            then
                                let $oaifrom := $oaifrom cast as xs:dateTime
                                return 
                                    if($oaifrom <= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml')))
                                    else ()  
                            else if(fn:compare($oaifrom,"0")=0 and fn:compare($oaiuntil,"0")!=0)
                            then
                                let $oaiuntil := $oaiuntil cast as xs:dateTime
                                return                                        
                                    if($oaiuntil >= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml')))
                                    else () 
                            else()          
                        else esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml')))             
};

(: try to produce the headers and content:)
declare function local:oairecords($oaifrom as xs:string, $oaiuntil as xs:string) as node()*{
let $allArchives := collection(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/'))//*:repositorid
return
    for $archive in $allArchives
    return
        let $allFonds := collection(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text()))//*:unitid
        return
            for $fond in $allFonds
            return
                let $allCharters := collection(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), "/", string($fond/@identifier), "/"))
                return
                    for $charter in $allCharters
                    return
                        if(fn:compare($oaifrom,"0")!=0 or fn:compare($oaiuntil,"0")!=0)
                        then
                            if(fn:compare($oaifrom,"0")!=0 and fn:compare($oaiuntil,"0")!=0)
                            then
                                let $oaifrom := $oaifrom cast as xs:dateTime
                                let $oaiuntil := $oaiuntil cast as xs:dateTime
                                return
                                    if($oaifrom <= $charter//atom:updated/text() cast as xs:dateTime and $oaiuntil >= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        <record>
                                        {(esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))),
                                         esetrans:content(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))))}
                                        </record>
                                   else()  
                            else if(fn:compare($oaifrom,"0")!=0 and fn:compare($oaiuntil,"0")=0)
                            then
                                let $oaifrom := $oaifrom cast as xs:dateTime
                                return 
                                    if($oaifrom <= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        <record>
                                        {(esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))),
                                         esetrans:content(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))))}
                                        </record>
                                    else()  
                            else if(fn:compare($oaifrom,"0")=0 and fn:compare($oaiuntil,"0")!=0)
                            then
                                let $oaiuntil := $oaiuntil cast as xs:dateTime
                                return                                        
                                    if($oaiuntil >= $charter//atom:updated/text() cast as xs:dateTime)
                                    then
                                        <record>
                                        {(esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))),
                                         esetrans:content(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))))}
                                        </record>   
                                    else()
                            else()          
                        else 
                        <record> 
                        {( esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))),
                           esetrans:content(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $archive/text(), '/', $archive/text(),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $archive/text(), '/', string($fond/@identifier), '/', string($fond/@identifier),'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $archive/text(), '/', string($fond/@identifier), '/', string($charter//cei:idno/@id),'.xml'))))}
                        </record>                        
};

declare function local:searchResPoint($hits as node()*, $ResIdentity as xs:string) as xs:integer*{
    for $hit at $number in $hits
    return
       if ($hit//oai:identifier = $ResIdentity) then $number
       else() 
};

(: handle parameters to produce a response:)
declare function local:response() as node()*{ 
    if($oaiinterface:verb  ="Identify")
       then
            (: identify the data provider:)
            <Identify>
                <repositoryName>Monasterium.net</repositoryName>
                <baseURL>http://www.mom-ca.uni-koeln.de/mom/oai</baseURL>
                <protocolVersion>2.0</protocolVersion>
                <adminEmail>andre.streicher@uni-koeln.de</adminEmail>
                <earliestDatestamp>{$oaiinterface:earliest-datestamp}</earliestDatestamp>
                <deletedRecord>transient</deletedRecord>
                <granularity>YYYY-MM-DDThh:mm:ssZ</granularity>
            </Identify>           
    else if($oaiinterface:verb  ="ListMetadataFormats")
        then
        if (count($oaiinterface:parameters)=1)
            then
            (: list the metadata format, actually vdu/mom only uses the ese format :)
            <ListMetadataFormats>
                <metadataFormat>
                    <metadataPrefix>oai_dc</metadataPrefix>
                    <schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
                    <metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
                </metadataFormat>
            </ListMetadataFormats>
           (: placeholder for more metadata formats in database - check the identifier:) 
         else 
           (: structure of resource- id: oai:MoM:-archive-/-fond-/-charterid- :)
           let $idArchiv := substring-after(substring-after(substring-before($oaiinterface:identifier, "/"),":"),":")
           let $idBestand := substring-before(substring-after($oaiinterface:identifier,"/"),"/")
           let $idUrkunde := substring-after(substring-after($oaiinterface:identifier,"/"),"/")
                return
                   if(exists(collection(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $idArchiv))))
                      then
                        if(exists(collection(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $idArchiv, "/", $idBestand))))
                           then
                              if(doc-available(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $idArchiv, "/", $idBestand, "/", $idUrkunde, ".xml")))
                                  then
                                     <ListMetadataFormats>
                                            <metadataFormat>
                                                <metadataPrefix>oai_dc</metadataPrefix>
                                                <schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
                                                <metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
                                            </metadataFormat>
                                      </ListMetadataFormats>
                              else <error code="idDoesNotExist">CharterID does not exist</error>
                        else <error code="idDoesNotExist">FondID does not exist</error>
                 else <error code="idDoesNotExist">ArchiveID does not exist</error>
                 
    else if($oaiinterface:verb  ="ListIdentifiers")
         then
            if(fn:compare($oaiinterface:resumptionToken,"0")=0) then
            (: List identifiers (in addiction to the until/ from parameter) :)
             let $hits := local:oaiheader($oaiinterface:from, $oaiinterface:until)
             return
                  if(empty($hits/child::*))then <error code="noRecordsMatch">No records match</error>
                  else 
                  <ListIdentifier>
                  {
                  for $hit at $number in $hits
                     return
                        if($number < 5000)then
                            $hit
                        else if($number = 5000) then
                            <resumptionToken>{$oaiinterface:metadataPrefix}\{$hit//oai:identifier/text()}\{$oaiinterface:from}\{$oaiinterface:until}</resumptionToken>
                        else()            
                     }
                  </ListIdentifier> 
                  
            else let $oaiinterface:metadataPrefix := substring-before($oaiinterface:resumptionToken, "\")
            let $ResIdentity := substring-before(substring-after($oaiinterface:resumptionToken, "\"), "\")
            let $resfrom := substring-before(substring-after(substring-after($oaiinterface:resumptionToken, "\"), "\"), "\")
            let $resuntil := substring-after(substring-after(substring-after($oaiinterface:resumptionToken, "\"), "\"), "\")
            return
                (: List records (in addiction to the until/ from parameter) :)
                let $hits := local:oaiheader($resfrom, $resuntil)
                return
                  if(empty($hits/child::*))then <error code="badResumptionToken">Resumption Token is not valid</error>
                  else 
                     let $index := local:searchResPoint($hits, $ResIdentity)
                     return
                        if(empty($index))then <error code="badResumptionToken">Resumption Token is not valid</error>
                        else
                        <ListIdentifier>
                            {
                            for $hit at $number in $hits
                            return
                                if($number >= $index and $number < $index+5000)then
                                    $hit
                                else if($number = ($index+5000)) then
                                    <resumptionToken>{$oaiinterface:metadataPrefix}\{$hit//oai:identifier/text()}\{$resfrom}\{$resuntil}</resumptionToken>
                                else()            
                           }
                        </ListIdentifier> 

    else if($oaiinterface:verb  ="ListRecords")
    then 
        if(fn:compare($oaiinterface:resumptionToken,"0")=0) then
            (: List records (in addiction to the until/ from parameter) :)
            let $hits := local:oairecords($oaiinterface:from, $oaiinterface:until)
                return
                  if(empty($hits/child::*))then <error code="noRecordsMatch">No records match</error>
                  else
                  <ListRecords>
                     {
                     for $hit at $number in $hits
                     return
                        if($number < 5000)then
                            $hit
                        else if($number = 5000) then
                            <resumptionToken>{$oaiinterface:metadataPrefix}\{$hit//oai:identifier/text()}\{$oaiinterface:from}\{$oaiinterface:until}</resumptionToken>
                        else()            
                     }
                  </ListRecords> 
                  
       else let $oaiinterface:metadataPrefix := substring-before($oaiinterface:resumptionToken, "\")
            let $ResIdentity := substring-before(substring-after($oaiinterface:resumptionToken, "\"), "\")
            let $resfrom := substring-before(substring-after(substring-after($oaiinterface:resumptionToken, "\"), "\"), "\")
            let $resuntil := substring-after(substring-after(substring-after($oaiinterface:resumptionToken, "\"), "\"), "\")
            return
                (: List records (in addiction to the until/ from parameter) :)
                let $hits := local:oairecords($resfrom, $resuntil)
                return
                  if(empty($hits/child::*))then <error code="badResumptionToken">Resumption Token is not valid</error>
                  else 
                     let $index := local:searchResPoint($hits, $ResIdentity)
                     return
                        if(empty($index))then <error code="badResumptionToken">Resumption Token is not valid</error>
                        else
                        <ListRecords>
                            {
                            for $hit at $number in $hits
                            return
                                if($number >= $index and $number < $index+5000)then
                                    $hit
                                else if($number = ($index+5000)) then
                                    <resumptionToken>{$oaiinterface:metadataPrefix}\{$hit//oai:identifier/text()}\{$resfrom}\{$resuntil}</resumptionToken>
                                else()            
                           }
                        </ListRecords>      
                          
    else if($oaiinterface:verb  ="GetRecord")
    then
        (: Get a single record with the identifier parameter :)
        (: structure of resource- id: oai:MoM:-archive-/-fond-/-charterid- :)
        let $idArchiv := substring-after(substring-after(substring-before($oaiinterface:identifier, "/"),":"),":")
        let $idBestand := substring-before(substring-after($oaiinterface:identifier,"/"),"/")
        let $idUrkunde := substring-after(substring-after($oaiinterface:identifier,"/"),"/")
        return
                   if(exists(collection(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $idArchiv))))
                      then
                        if(exists(collection(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $idArchiv, "/", $idBestand))))
                           then
                              if(doc-available(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $idArchiv, "/", $idBestand, "/", $idUrkunde, ".xml")))
                                  then
                                     <GetRecord>
                                       <record>
                                        {(esetrans:header(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $idArchiv, '/', $idArchiv,'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $idArchiv, '/', $idBestand, '/', $idBestand,'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $idArchiv, '/', $idBestand, '/', $idUrkunde,'.xml'))),
                                         esetrans:content(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $idArchiv, '/', $idArchiv,'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.fond.public/', $idArchiv, '/', $idBestand, '/', $idBestand,'.xml')), doc(concat(conf:param('data-db-base-uri'), 'metadata.charter.public/', $idArchiv, '/', $idBestand, '/', $idUrkunde,'.xml'))))}
                                        </record>
                                    </GetRecord>
                              else <error code="idDoesNotExist">CharterID does not exist</error>
                        else <error code="idDoesNotExist">FondID does not exist</error>
                 else <error code="idDoesNotExist">ArchiveID does not exist</error>
     else <error code="badVerb">No valid request type</error>
};

declare function oaiinterface:main(){
    (: OAI- PMH informations - has to be defined:)
    <OAI_PMH xmlns="http://www.openarchives.org/OAI/2.0/" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
         http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
    <responseDate>{current-dateTime()}</responseDate>
    <request> {(for $parameter in $oaiinterface:parameters
                return
                    attribute {$parameter}{request:get-parameter(string($parameter),0)})
                ,"http://www.mom-ca.uni-koeln.de/mom/service/oai"}</request>
    {
    (: check parameters and produce a response:)
    local:validate-params()
    }
     </OAI_PMH>
};
