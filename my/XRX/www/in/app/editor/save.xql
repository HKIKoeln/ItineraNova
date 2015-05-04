xquery version "1.0";

declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ftp-client="java:org.apache.commons.net.ftp.FTPClient";
declare namespace ftp-file="java:org.apache.commons.net.ftp.FTPFile";

declare option exist:serialize "method=xhtml media-type=text/html";

declare variable $ead-schema := 'http://www.loc.gov/ead/ead.xsd';
declare variable $conf:data-db-base-uri := '/db/in-data/';

declare variable $action := request:get-parameter('action', ());
declare variable $register := request:get-parameter('register', ());
declare variable $act := request:get-parameter('act', ());
declare variable $data := request:get-data();
declare variable $http-server := 'itineranova.be';
declare variable $http-folder := '/images/';
declare variable $admin-pass := '';

declare function local:get-folio-name($name)
{
    let $num := replace(substring-after($name, '_'), '[^\d]', '')
    let $clean := substring-before(substring-after($name, '_'), '.jpg')
    let $prefix := 
        if(matches($clean, '(^e|^b|^B)')) then substring($clean, 1, 1)
        else ''
    let $suffix := 
        if(matches($clean, '[a-zA-Z]$')) then substring($clean, string-length($clean))
        else ''
    let $folio :=
        if((xs:integer($num) mod 2) = 0) 
        then concat($prefix, xs:string(xs:integer($num) div 2), $suffix, 'V°')
        else concat($prefix, xs:string(floor((xs:integer($num) div 2) + 1)), $suffix, 'R°')
    return
    $folio
};

declare function local:get-images()
{
(:
    let $server := $data//ead:server/text()
    let $folder := $data//ead:folder/text()
    let $username := $data//ead:username/text()
    let $password := $data//ead:password/text()
    
    let $client := ftp-client:new()
    let $connect := ftp-client:connect($client, $server)
    let $login := ftp-client:login($client, $username, $password)
    let $mode := ftp-client:enter-local-passive-mode($client)
    let $ftp-names := 
        for $f in ftp-client:list-files($client, $folder)
        let $n := ftp-file:get-name($f)
        return
        if(ftp-file:get-type($f) = 0) then $n
        else()
    let $disconnect := ftp-client:disconnect($client)
    let $server := $data//ead:server/text()
    let $folder := $data//ead:folder/text()
:)
    let $http-names := httpclient:get(xs:anyURI(concat('http://', $http-server, $http-folder, $data//ead:archdesc/ead:did/ead:unitid/text())), true(), ())//a/text()
    for $name in $http-names
    (: for $name in $ftp-names :)
    return
    if(ends-with($name, '.jpg') or ends-with($name, '.JPG')) then
    <dao xmlns="urn:isbn:1-931666-22-9"
        xlink:title="{ local:get-folio-name($name) }" 
        xlink:href="{ concat('http://', $http-server, $http-folder, $data//ead:archdesc/ead:did/ead:unitid/text(), '/', $name) }"/>
    else()
};

declare function local:namespace-optimization($e as element(), $images) as element()
{
    element {QName('urn:isbn:1-931666-22-9', local-name($e))} 
    {
        for $child in $e/(@*,*,text())
        return
        if ($child instance of element())
        then
            if(name($child) eq 'ead:server') then $images
            else if(matches(name($child), '(ead:folder|ead:username|ead:password|ead:http-folder|ead:http-server)')) then()
            else local:namespace-optimization($child, $images)
        else $child
    }
};

declare function local:insert-images($images)
{
    let $ead := local:namespace-optimization($data, $images)
    return
    $ead
};

declare function local:new-register()
{
    let $col-name := $data//ead:archdesc/ead:did/ead:unitid/text()
    return
    if(not(collection($conf:data-db-base-uri)//ead:ead/ead:archdesc/ead:did/ead:unitid[.=$col-name])) then
        let $images := local:get-images()
        return
        if($images) then
            let $ead := local:insert-images($images)
            let $login := xmldb:login($conf:data-db-base-uri, 'admin', $admin-pass)
            let $create-collection := xmldb:create-collection($conf:data-db-base-uri, $col-name)
            let $store-register := xmldb:store(
                concat($conf:data-db-base-uri, $col-name),
                'ead.xml',
                $ead
            )
            return
            <response>
                <message>Register {$col-name} is successfully created.</message>
                <action label="Edit Register" link="edit-an-act?register={ $col-name }"/>
                <action label="Create another Register" link="create-a-new-register"/>
            </response>
        else
             <response>
                <message>No Images were found for Register {$col-name}.</message>
                <message>(Searched in { concat('http://', $http-server, $http-folder, $data//ead:archdesc/ead:did/ead:unitid/text()) })</message>
                <message>Perhaps you didn't upload the images yet?</message>
                <action label="Edit a Register" link="edit-an-act"/>
                <action label="Create another Register" link="create-a-new-register"/>
            </response>
    else
        <response>
            <message>Register {$col-name} already exists.</message>
            <action label="Edit a Register" link="edit-an-act"/>
            <action label="Create another Register" link="create-a-new-register"/>
        </response>
};

declare function local:create-a-new-act()
{
    let $ead := local:namespace-optimization($data, ())
    let $resource-name := 
        concat(
            'c.act.',
            root($ead)/ead:c[@otherlevel='act']/ead:did/ead:unitid/text(),
            '.xml'
            )
    let $login := xmldb:login(
        concat($conf:data-db-base-uri, $register),
        'admin',
        $admin-pass
        )
    let $store-resource := xmldb:store(
        concat($conf:data-db-base-uri, $register),
        $resource-name,
        $ead
        )
    return
    $ead
};

declare function local:delete-act()
{
    let $register := $data//param[@name='register']/@value
    let $login := xmldb:login(concat($conf:data-db-base-uri, $register), 'admin', $admin-pass)
    let $delete := xmldb:remove(concat($conf:data-db-base-uri, $register), concat('c.act.', $data//param[@name='act']/@value, '.xml'))
    return
    <parameters>
    {
        $data//param[not(matches(@name, 'action'))]
    }
        <param name="action" value="edit-an-act"/>
    </parameters>
};

declare function local:rename-act()
{
    let $register := $data//param[@name='register']/@value
    let $login := xmldb:login(concat($conf:data-db-base-uri, $register), 'admin', $admin-pass)
    let $rename := xmldb:rename(concat($conf:data-db-base-uri, $register), concat('c.act.', $data//param[@name='old-name']/@value, '.xml'), concat('c.act.', $data//param[@name='new-name']/@value, '.xml'))
    return
    <parameters>
    {
        $data//param[not(matches(@name, 'rename-act-action'))]
    }
        <param name="rename-act-action" value="false"/>
    </parameters>
};

declare function local:load-act()
{
    document(concat(
        $conf:data-db-base-uri, 
        data($data//param[@name='register']/@value), 
        '/c.act.', 
        data($data//param[@name='act']/@value),
        '.xml'
    ))
};

declare function local:acts-in-register()
{
    <acts>
    {
        for $act in collection(concat($conf:data-db-base-uri, data($data//param[@name='register']/@value)))//ead:c[@otherlevel='act']/ead:did/ead:unitid/text()
        return
        <act>{ $act }</act>
    }
    </acts>
};

declare function local:new-pers-indexentry()
{
    let $pers-id := 
        for $id in data($data//ead:persname[@role='alderman' or @role='mayor']/@id)
        return
        substring-after($id, 'pers-')
    let $max-id := xs:int(max($pers-id))
    return
    <indexentry xmlns="urn:isbn:1-931666-22-9">
        <namegrp>
        <title/>
        {
            for $pos at $num in (1 to 9)
            return
            <persname id="{ concat('pers-', xs:string($num + $max-id)) }" role="alderman"/>
        }
        {
            for $pos at $num in (1 to 2)
            return
            <persname id="{ concat('pers-', xs:string($num + $max-id + 9)) }" role="mayor"/>
        }
        </namegrp>
    </indexentry>
};

declare function local:update-folio-name($e, $new-name)
{
    element {QName('urn:isbn:1-931666-22-9', local-name($e))} 
    {
        for $child in $e/(@*,*,text())
        return
        if($child instance of element())
        then
            if(data($child/@xlink:title) = data($data//param[@name='folio']/@value))
            then <ead:dao xlink:href="{ $child/@xlink:href }" xlink:title="{ $new-name }"></ead:dao>
            else local:update-folio-name($child, $new-name)
        else $child
    }
};

declare function local:rename-folio()
{
    let $col-name := $data//param[@name='register']/@value
    let $new-name := $data//param[@name='new-name']/@value
    let $ead := collection(concat($conf:data-db-base-uri, $col-name))/ead:ead
    let $rename := local:update-folio-name($ead, $new-name)
    let $login := xmldb:login(concat($conf:data-db-base-uri, $col-name), 'admin', $admin-pass)
    let $store-register := xmldb:store(
        concat($conf:data-db-base-uri, $col-name),
        'ead.xml',
        $rename
    )
    return    
    <parameters>
    {
        $data//param
    }
    </parameters>
};

declare function local:main()
{
    let $response := 
    (
        if($action eq 'create-a-new-register') 
        then local:new-register()
        else if($action eq 'new-pers-indexentry') 
        then local:new-pers-indexentry()
        else if($action eq 'rename-folio')
        then local:rename-folio()
        else if(data($data//param[@name='action']/@value) eq 'acts-in-register')
        then local:acts-in-register()
        else if($data//param[@name='action']/@value = 'delete-act')
        then local:delete-act()
        else if($data//param[@name='action']/@value = 'rename-act')
        then local:rename-act()
        else if(data(root($data)/ead:c/@otherlevel) eq 'act')
        then local:create-a-new-act()
        else()
    )
    return
    $response
};

local:main()
