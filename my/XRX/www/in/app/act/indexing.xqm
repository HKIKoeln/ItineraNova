xquery version "1.0";

module namespace indexing="http://itineranova.be/NS/indexing";

declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace atom="http://www.w3.org/2005/Atom";

(: request parameters :)
declare variable $indexing:register := 
    request:get-parameter('register', '');
declare variable $indexing:actpos := 
    xs:integer(request:get-parameter('actpos', '1'));
declare variable $indexing:gotoact := 
    request:get-parameter('gotoact', '');
declare variable $indexing:newaddition-flag := 
    if(request:get-parameter('newaddition', 'false') = 'true') then true()
    else false();
declare variable $indexing:removeaddition-flag := 
    if(request:get-parameter('removeaddition', 'false') = 'true') then true()
    else false();
declare variable $indexing:additionpos :=
    xs:integer(request:get-parameter('additionpos', '-1'));

declare function indexing:act-element($act-elements as element(ead:c)*) as element(){

    (: get act by pos or by name :)
    let $act-element :=
        (: get by act name? :)
        if($indexing:gotoact != '') then 
            let $elmt := $act-elements[./ead:did/ead:unitid = $indexing:gotoact]
            return
            (: if the act does exist we take it :)
            if($elmt) then $elmt
            (: else we return the old act actually shown :)
            else $act-elements[$indexing:actpos]
        else $act-elements[$indexing:actpos]
        
    return
    
    $act-element
};

declare function indexing:actpos($act-elements, $act-element as element(ead:c)) as xs:integer {

    if($indexing:newaddition-flag) then $indexing:actpos
    else if($indexing:gotoact != '') then index-of($act-elements, $act-element)
    else $indexing:actpos
};

declare function indexing:remove-addition($act-entry as element(atom:entry)) as element() {

    let $ead-c-textpos := $indexing:additionpos + 1
    let $addition-count := count($act-entry//ead:c[@otherlevel='text'])
    let $start-rename-addition := $ead-c-textpos + 1
    let $xslt :=
    <xsl:stylesheet xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
        <xsl:template match="//ead:c[@otherlevel='text'][{ $ead-c-textpos }]"/>
        {
          for $num-addition in ($start-rename-addition to $addition-count)
          return
          <xsl:template match="//ead:c[@otherlevel='text'][{ $num-addition }]/ead:did/ead:unitid/text()">
            <xsl:text>Add. { $num-addition - 2 }</xsl:text>
          </xsl:template>
        }
        <xsl:template match="@*|*" priority="-2">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
        </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($act-entry, $xslt, ())
};