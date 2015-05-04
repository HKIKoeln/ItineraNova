xquery version "1.0";

module namespace chamber="http://itineranova.be/NS/chamber";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare function chamber:link($chamberid as xs:string) as xs:string {

    xmldb:encode-uri(
        xmldb:decode(
            concat(
                conf:param('request-root'),
                $chamberid,
                '/chamber'
            )
        )
    )        
};