xquery version "1.0";

module namespace folio="http://itineranova.be/NS/folio";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare function folio:link($object-uri-tokens as xs:string+) as xs:string {

    xmldb:encode-uri(
        xmldb:decode(
            concat(
                conf:param('request-root'),
                string-join(
                    $object-uri-tokens,
                    '/'
                ),
                '/folio'
            )
        )
    )
};

