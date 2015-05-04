xquery version "1.0";

module namespace transcription="http://itineranova.be/NS/transcription";

declare namespace tei="http://www.tei-c.org/ns/1.0/";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare variable $transcription:rauthorselect := 
    xmldb:decode(request:get-parameter('authorselect', ''));
declare variable $transcription:metadata-object-type :=
    'transcription';

declare function transcription:rquery-string() as xs:string {

    string-join(
        
        (
            concat('page=', request:get-parameter('page', '1')),
            concat('perpage=', request:get-parameter('perpage', '15')),
            concat('authorselect=', request:get-parameter('authorselect', ''))
        )
        ,
        '&amp;'
    )
};

declare function transcription:entry2text($entry as element(atom:entry)) {

    let $tei2insyntax-xsl := collection('/db/www')/xsl:stylesheet[@id='tei2insyntax'] 
    let $additions := $entry//ead:c[@otherlevel='text']
    let $transcriptions := 
        for $addition in $additions
        let $transcription-element := $addition//tei:body/tei:p

        let $encodingdesc-exists := exists($addition//tei:encodingDesc)
        let $rendition-element := $addition//tei:rendition[@xml:id='itineranova-syntax']
        let $itineranova-syntax := 
            if($encodingdesc-exists) then
                if(exists($rendition-element/text())) then
                    $rendition-element/text()
                else ' '
            else
                transform:transform($transcription-element, $tei2insyntax-xsl, ())/text()
        return
        $itineranova-syntax
    return
    string-join($transcriptions, '||||')
    
};

declare function transcription:author($entry as element(atom:entry)) as xs:string {

    xs:string(($entry//tei:TEI/ancestor::atom:entry[1]/atom:author/atom:email/text())[1])
};

declare function transcription:link($object-uri-tokens as xs:string+) as xs:string {

    xmldb:encode-uri(
        xmldb:decode(
            concat(
                conf:param('request-root'),
                string-join(
                    $object-uri-tokens,
                    '/'
                ),
                '/transcription'
            )
        )
    )        
};

(: 
  Returns a string of the malformed brackets of a given 
  string. If all brackets in the given string are wellformed 
  the returned string is empty. 
:)
declare function transcription:bracket-check($string)
{
    let $brackets := replace($string, '[^\(\)\[\]{}]', '')
    return transcription:bracket-check-recursion($brackets)
};

(: Helper function for bracket-check :)
declare function transcription:bracket-check-recursion($brackets)
{
    let $brackets-new := replace(replace(replace($brackets, '\(\)', ''), '\[\]', ''), '[{][}]', '')
    return
    if(string-length($brackets-new) lt string-length($brackets)) then
    transcription:bracket-check-recursion($brackets-new)
    else
    $brackets    
};

declare function transcription:html-tag-clean($n){

    element { node-name($n) }{
        
        for $child in $n/child::node()
        return
        if($child instance of element(p) and (util:node-id($child) != util:node-id(root($n)//p[last()]))) then
        (
            transcription:html-tag-clean($child),
            '/'
        )
        (:else if($child instance of element(s) or $child instance of element(strike)) then :)
        else if(contains($child/@style, 'text-decoration: line-through') or contains($child/@style, 'text-decoration:line-through')) then
        (
            '<tei:del rend="overstrike">',
            $child/text(),
            '</tei:del>'
        )
        else if($child/self::br) then
            '/'
        else if ($child instance of element()) then
            transcription:html-tag-clean($child)
        else
            $child
    }
};

declare function transcription:clean-html($e){

    let $ns-clean := 
        <tei:p>{ $e//(BODY|body)/node() }</tei:p>
return concat(' ', string-join(transcription:html-tag-clean($ns-clean)//text(), ''), ' ')

};

declare function transcription:create-unclear-elements($e){
    
    let $create-unclear-elements := 
        replace(
                    $e,
                    '([ \[>])([^? \[>]*)\?',
                    '$1<tei:unclear>$2</tei:unclear>'
                )
        
    return $create-unclear-elements
};

declare function transcription:create-superscript-elements($e){

    let $create-superscript-elements :=
        replace(
                    $e,
                    '\[([^\]]*)\]',
                    '<tei:hi rend="super">$1</tei:hi>'
                )
                
    return $create-superscript-elements
};

declare function transcription:create-glyph-elements($e){

    let $create-glyph-elements :=
        replace(
                    $e,
                    '\(([^)]*)\)',
                    '<tei:abbr type="glyph">$1</tei:abbr>'
                )
                
    return $create-glyph-elements
};

declare function transcription:create-pb-lb-and-stuff($e){

    let $create-pb :=
        replace(
                    $e,
                    '//+',
                    '<tei:pb/>'
                )
                
    let $create-lb :=
        replace(
                    $create-pb,
                    '([^<])/([^>])',
                    '$1<tei:lb/>$2'
                )
                
    let $preserve-whitespace :=
        replace(
                    $create-lb,
                    '> <',
                    '>&#160;<'
                )
    return $preserve-whitespace
    
};

declare function transcription:create-strikethrough($e) {

    let $strikethrough :=
        replace(
            $e,
            '=([^=]+)=',
            '<tei:del rend="overstrike">$1</tei:del>'
        )
    return
    $strikethrough
};

declare function transcription:html2tei($e){
    
    (:let $debug1 := xmldb:store('/db/in-data/debug-insert-transcription/', '01-html-content.xml', $html-content):)
    
    let $html-2-string := transcription:clean-html($e)
    let $debug2 := xmldb:store('/db/in-data/debug-insert-transcription/', '02-html-2-string.txt', $html-2-string)
    
    let $create-unclear-elements := transcription:create-unclear-elements($html-2-string)
    let $debug3 := xmldb:store('/db/in-data/debug-insert-transcription/', '03-create-unclear-elements.txt', $create-unclear-elements)
    
    let $create-superscript-elements := transcription:create-superscript-elements($create-unclear-elements)
    let $debug4 := xmldb:store('/db/in-data/debug-insert-transcription/', '04-create-superscript-elements.txt', $create-superscript-elements)
    
    let $create-glyph-elements := transcription:create-glyph-elements($create-superscript-elements)
    let $debug5 := xmldb:store('/db/in-data/debug-insert-transcription/', '05-create-glyph-elements.txt', $create-glyph-elements)
    
    let $create-pb-lb-and-stuff := transcription:create-pb-lb-and-stuff($create-glyph-elements)
    let $debug6 := xmldb:store('/db/in-data/debug-insert-transcription/', '06-create-pb-lb-and-stuff.txt', $create-pb-lb-and-stuff)
    
    let $first-clean-up :=
    if(starts-with($create-pb-lb-and-stuff, ' ')) then
    substring($create-pb-lb-and-stuff, 2)
    else $create-pb-lb-and-stuff
    
    let $second-clean-up :=
    if(ends-with($first-clean-up, ' ')) then
    substring($first-clean-up, 1, string-length($first-clean-up)-1)
    else $first-clean-up
    
    
    return
    concat('<tei:p xmlns:tei="http://www.tei-c.org/ns/1.0/">', $second-clean-up, '</tei:p>')
};

declare function transcription:validate($e){
    
    let $tei := 
        <tei:TEI>
            <tei:teiHeader>
                <tei:fileDesc>
                    <tei:titleStmt>
                        <tei:title/>
                    </tei:titleStmt>
                    <tei:editionStmt>
                        <tei:p/>
                    </tei:editionStmt>
                    <tei:extent/>
                    <tei:publicationStmt>
                        <tei:p/>
                    </tei:publicationStmt>
                    <tei:seriesStmt>
                        <tei:p/>
                    </tei:seriesStmt>
                    <tei:notesStmt>
                        <tei:note/>
                    </tei:notesStmt>
                    <tei:sourceDesc>
                        <tei:p/>
                    </tei:sourceDesc>
                </tei:fileDesc>
                <tei:revisionDesc>
                    <tei:change/>
                </tei:revisionDesc>
            </tei:teiHeader>
            <tei:text>
                <tei:body>
                    { util:parse($e) }
                </tei:body>
            </tei:text>
        </tei:TEI>
    return
    validation:jaxv-report($tei, xs:anyURI('http://sandbox.itineranova.be/rest/db/www/schema/tei_all.xsd'))
};

declare function transcription:determine-status($n)
{
    if(exists($n//response)) then 0
    else 1
};

declare function transcription:text2tei($data){

    let $debuggg := 
        xmldb:store('/db/in-data/debug-insert-transcription/', '000-data.txt', $data)
    
    let $transcriptions :=
        for $transcription at $pos in $data//field
        return
        <transcription id="{ concat('transcription-', $pos) }">
            {
                let $tei-transformed := transcription:html2tei(util:parse-html($data//field[$pos]))
                let $check-wellformedness := util:catch("*", util:parse($tei-transformed), 'Error: XML not well-formed.')
                let $validate :=
                    if($check-wellformedness eq 'Error: XML not well-formed.') then ()
                    else transcription:validate($tei-transformed)
                let $debug :=
                    if($check-wellformedness eq 'Error: XML not well-formed.') then
                    xmldb:store('/db/in-data/debug-insert-transcription/', '07-validate.xml', <Error>An error occured while converting the entered text to TEI. The generated XML is not well formed due to a notational mistake in the transcription.</Error>)
                    else
                    xmldb:store('/db/in-data/debug-insert-transcription/', '07-validate.xml', $validate)
                    return
                if($check-wellformedness eq 'Error: XML not well-formed.') then
                <tei:body>            
                    <response status="0">
                        <message>An error occured while converting the entered text to TEI. The generated XML is not well formed due to a notational mistake in the transcription.</message>
                    </response>
                </tei:body>
                else
                <tei:body>{ util:parse($tei-transformed) }</tei:body>
            }
        </transcription>
    
    let $output :=
        <transcriptions>
        {
            for $transcription at $pos in $transcriptions
            let $status := transcription:determine-status($transcription)
            return
            <transcription id="{ concat('transcription-', $pos) }">
                <success status="{ $status }"/>
                { $transcription/* }
            </transcription>
        }
        </transcriptions>
    
    let $save-output-debug := 
        xmldb:store('/db/in-data/debug-insert-transcription/', '08-output.xml', $output)
    
    return $output

};

declare function transcription:text2tei2($data) {

    let $create-strikethrough := transcription:create-strikethrough($data)
    let $create-unclear-elements := transcription:create-unclear-elements($create-strikethrough)
    let $create-superscript-elements := transcription:create-superscript-elements($create-unclear-elements)
    let $create-glyph-elements := transcription:create-glyph-elements($create-superscript-elements)
    let $create-pb-lb-and-stuff := transcription:create-pb-lb-and-stuff($create-glyph-elements)
    return
    util:parse(
        concat(
            '<tei:p xmlns:tei="http://www.tei-c.org/ns/1.0/">', 
            $create-pb-lb-and-stuff, 
            '</tei:p>'
        )
    )
};

declare function transcription:insert($public-entry as element(), $transcriptions as element(atom:entry)+) as element(){

    element {node-name($public-entry)}
    {
        $public-entry/@*,
        for $child in $public-entry/node()
        return
        typeswitch($child)
        
        case element(atom:entry) return 
            
            if($child = root($child)/atom:entry) then
                transcription:insert($child, $transcriptions)
            else 
                $transcriptions[(count($child/ancestor::ead:c[@otherlevel='text']/preceding-sibling::ead:c) + 1)]
        
        case element(ead:c) return
            
            if($child[@otherlevel = 'text']) then
                transcription:insert($child, $transcriptions)
            else
                transcription:insert($child, $transcriptions)
                
        case element() return
            transcription:insert($child, $transcriptions)
        
        default return 
            $child
    }    
};


