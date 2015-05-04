xquery version "1.0";

module namespace search="http://itineranova.be/NS/search";

declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace tei="http://www.tei-c.org/ns/1.0/";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
    
(: request parameters :)
declare variable $search:q := request:get-parameter('q', '');
declare variable $search:register := request:get-parameter('register', '');
declare variable $search:page := request:get-parameter('page', '');
declare variable $search:folio := request:get-parameter('folio', '');
declare variable $search:act := request:get-parameter('act', '');
declare variable $search:from := request:get-parameter('from', '');
declare variable $search:to := request:get-parameter('to', '');
declare variable $search:category := request:get-parameter('category-0', '');
declare variable $search:scope := request:get-parameter('scope', '');

declare variable $search:options :=
    <options xmlns="">
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>;

(: is this the first visit of the search page? :)
declare function search:is-first-visit() as xs:boolean {

    if(request:get-parameter('_firstvisit', '') != 'true') 
    then
        false()
    else 
        true()
};
           
(: the database scope query string where we search in :)
declare function search:scope-query-string($type as xs:string) as xs:string {
  if($type = 'transcription')then(
    if($search:register != '') then
        'metadata:base-collection("act", $search:register, "public")'
    else
        'metadata:base-collection("act", "public")'
    )
  else(
    if($search:register != 'all') then
        (
        if($search:folio != '') then
            'metadata:base-collection("annotation", ($search:register, concat($search:folio, $search:page)), "public")'
        else
            'metadata:base-collection("annotation", $search:register, "public")'
        )
    else
        'metadata:base-collection("annotation", "public")'
  )
    
};

declare function search:act-baseelement-query-string() {

    '//atom:content/ead:c'
};

declare function search:annotation-baseelement-query-string() {
    if($search:scope = 'all')then
      '//atom:content/xrx:revision/xrx:annotation/tei:TEI/tei:facsimile/tei:surfaceGrp'
    else(
    if($search:scope = 'transcription')then
        '//atom:content/xrx:revision/xrx:annotation/tei:TEI/tei:facsimile/tei:surfaceGrp/tei:span'
    else
        '//atom:content/xrx:revision/xrx:annotation/tei:TEI/tei:facsimile/tei:surfaceGrp/tei:interp'
    )
};

(:
    act query string, starting with the page 'R or V' 
    following with the name of the act
:)
declare function search:act-query-string() as xs:string {

    concat(
        '[ft:query(./ead:did/ead:unitid,"', 
        concat($search:page, if($search:act) then concat(' ', $search:act) else ''), 
        '", $search:options) or ft:query(./ead:did/ead:unitid,"', 
        concat($search:page, if($search:act) then concat(' ', $search:act, '*') else '*'), 
        '", $search:options)]'
    )
};

declare function search:category-query-string() as xs:string {
    let $params := request:get-parameter-names()
    let $categories := 
        for $param in $params
        return
          if(starts-with($param, 'category'))then
            request:get-parameter($param, '')
          else()
    let $category-filter := 
                if(count($categories) gt 0)then
                        for $category at $number in $categories
                        return
                            if($number = 1)then
                                concat(
                                if($search:scope = 'all')then '(.//@type = "' else '(..//@type = "',
                                $category,
                                '")'
                                )
                            else
                                concat(
                                if($search:scope = 'all')then 'or (.//@type = "' else 'or (..//@type = "',
                                $category,
                                '")'
                                )
                else()
    return
        if(count($categories) gt 0)then
            concat(
                '[',
                 string-join(
                   $category-filter,
                   ' '                   
                 ),
                ']'
            )
        else ''
};
        
(: the fulltext query string :)
declare function search:q-query-string($type) as xs:string {
    
    let $alderman-query-string := 
        if($type = 'transcription')then
            search:alderman-query-string()
        else ''
    return
    concat(
        if($search:scope = 'all')then
            '[ft:query(./tei:span,"'
        else
            '[ft:query(.,"',
        if($alderman-query-string != '') then concat('(', $search:q, ') OR', $alderman-query-string) else $search:q, 
            '", $search:options)',
        if($search:scope = 'all')then
            concat(
                    ' or ft:query(./tei:interp,"', 
                    $search:q, 
                    '", $search:options)'
                )
        else '',
        ']'
    )
};

declare function search:alderman-query-string() as xs:string* {

    let $options :=
    <options xmlns="">
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
    let $person-ids :=
        collection(conf:param('data-db-base-uri'))//ead:namegrp/ead:persname[ft:query(., $search:q, $options)]/@id/string()
    return
    if(count($person-ids) gt 0) then
        concat(
            ' (',
            string-join(
                $person-ids,
                ' '
            ),
            ')'
        )
    else ''
};

declare function search:date-optimized($date as xs:string, $fill) {

    let $clean1 := replace($date, '[^\d]', '')
    let $length := string-length($clean1)
    let $clean2 :=
        string-join(
            (
                $clean1,
                for $f in (1 to 8 - $length)
                return
                $fill
            ),
            ''
        )
    return
    $clean2
};

(: period to query string :)
declare function search:period-query-string() as xs:string {

    let $from-query-string :=
        if($search:from != '') then
            concat(
                '(.//@normal >= "',
                search:date-optimized($search:from, '0'),
                '")'
            )
         else '(.//@normal >= "00000000")'
    let $to-query-string :=
        if($search:to != '') then
        concat(
            '(.//@normal <= "',
            search:date-optimized($search:to, '9'),
            '")'
        )
        else '(.//@normal <= "99999999")'
    return
    concat(
        '[',
        $from-query-string,
        ' and ',
        $to-query-string,
        ']'
    )
};

(: compose the complete transcription query string :)
declare function search:query-string($type as xs:string) as xs:string {
    if($type = 'transcription')then
        concat(
            search:scope-query-string($type),
            search:act-baseelement-query-string(),
            if($search:q != '') then search:q-query-string($type) else '',
            if($search:page != '' or $search:act != '') then search:act-query-string() else '',
            if($search:from != '' or $search:to != '') then search:period-query-string() else ''
        )
    else
        concat(
            search:scope-query-string($type),
            search:annotation-baseelement-query-string(),
            if($search:q != '') then search:q-query-string($type) else '',
            if($search:category != 'all') then search:category-query-string() else '',
            '/..'
        )
};