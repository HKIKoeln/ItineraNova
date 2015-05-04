xquery version "1.0";

(: lang change request? :)
declare variable $_lang-changed := 
    if(request:get-parameter('_lang', '') != '') then
        session:set-attribute('lang', request:get-parameter('_lang', ''))
    else();
    
(: relative path to the xrx system :)  
declare variable $xrx-relative-path :=

    string-join(
        for $pos in ( 1 to (count(tokenize($exist:path, '/')) - 1) )
        return
        '../',
        ''
    );

(: redirect :)
if($exist:path = '/') then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <redirect url="/in/home"/>
</dispatch>

(: resources :)
else if(starts-with($exist:path, '/icon/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }core/res/tango-icon-theme/32x32/{ substring-after($exist:path, '/icon/') }"/>
</dispatch>

else if(starts-with($exist:path, '/jquery/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }lib/jquery/development-bundle{ substring-after($exist:path, 'jquery') }"/>
</dispatch>

else if(ends-with($exist:resource, '.jpg') or ends-with($exist:resource, '.png') or ends-with($exist:resource, '.gif')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/img/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.xsl')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/xsl/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.xsd')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/xsd/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.css') and not(contains($exist:path, '/css/'))) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/css/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.js')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/js/', $exist:resource) }"/>
</dispatch>

else if(matches($exist:path, '/res/(.*)\.xml')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('xml/', $exist:resource) }"/>
</dispatch>

(: main dispatcher :)
else
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }core/app/xrx/xrx.xql"/>
    <cache-control cache="no"/>
</dispatch>
