xquery version "1.0";

module namespace register="http://itineranova.be/NS/register";

declare namespace ead="urn:isbn:1-931666-22-9";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare function register:link($registerid as xs:string) as xs:string {

    concat(
        conf:param('request-root'),
        $registerid,
        '/register'
    )
};

declare function register:new-pers-indexentry($register as xs:string) {

      <ead:indexentry>
        <ead:namegrp>
          <ead:title />
          <ead:persname id="pers-{ $register }-01" role="alderman" />
          <ead:persname id="pers-{ $register }-02" role="alderman" />
          <ead:persname id="pers-{ $register }-03" role="alderman" />
          <ead:persname id="pers-{ $register }-04" role="alderman" />
          <ead:persname id="pers-{ $register }-05" role="alderman" />
          <ead:persname id="pers-{ $register }-06" role="alderman" />
          <ead:persname id="pers-{ $register }-07" role="alderman" />
          <ead:persname id="pers-{ $register }-08" role="alderman" />
          <ead:persname id="pers-{ $register }-09" role="alderman" />
          <ead:persname id="pers-{ $register }-10" role="alderman" />
          <ead:persname id="pers-{ $register }-11" role="alderman" />
          <ead:persname id="pers-{ $register }-12" role="alderman" />
          <ead:persname id="pers-{ $register }-13" role="alderman" />
          <ead:persname id="pers-{ $register }-14" role="alderman" />
          <ead:persname id="pers-{ $register }-15" role="alderman" />
          <ead:persname id="pers-{ $register }-16" role="mayor" />
          <ead:persname id="pers-{ $register }-17" role="mayor" />
          <ead:persname id="pers-{ $register }-18" role="mayor" />
          <ead:persname id="pers-{ $register }-19" role="mayor" />
          <ead:persname id="pers-{ $register }-20" role="mayor" />
        </ead:namegrp>
      </ead:indexentry>
};
