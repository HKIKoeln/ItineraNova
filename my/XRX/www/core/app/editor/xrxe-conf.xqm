xquery version"1.0";

module namespace xrxe-conf='http://www.monasterium.net/NS/xrxe-conf';


declare variable $xrxe-conf:default-search-id-in := '/db';

declare variable $xrxe-conf:pre-string-model := 'm-';
declare variable $xrxe-conf:pre-string-instance := 'i-';
declare variable $xrxe-conf:pre-string-bind := 'b-';
declare variable $xrxe-conf:pre-string-trigger := 't-';
declare variable $xrxe-conf:pre-string-dialog := 'd-';
declare variable $xrxe-conf:pre-string-submission := 's-';
declare variable $xrxe-conf:pre-string-repeat := 'r-';
declare variable $xrxe-conf:pre-string-group := 'p-';
declare variable $xrxe-conf:pre-string-switch := 'sw-';

declare variable $xrxe-conf:post-string-document := '-document';
declare variable $xrxe-conf:post-string-load := '-load';
declare variable $xrxe-conf:post-string-unescape := '-unescape';
declare variable $xrxe-conf:post-string-save := '-save';
declare variable $xrxe-conf:post-string-data := '-data';
declare variable $xrxe-conf:post-string-insert := '-insert';
declare variable $xrxe-conf:post-string-delete := '-delete';
declare variable $xrxe-conf:post-string-new := '-new';
declare variable $xrxe-conf:post-string-validate := '-validate';
declare variable $xrxe-conf:post-string-post := '-post';
declare variable $xrxe-conf:post-string-case := '-case';
declare variable $xrxe-conf:post-string-attributes := '-attributes';
declare variable $xrxe-conf:post-string-child-elements := '-child-elements';

(: fn:true doesn't create any controls that enable attribute-editing:)
declare variable $xrxe-conf:default-disable-attribute-editing := fn:false();

(: fn:true doesn't create any dialogs for attribute-editing:)
declare variable $xrxe-conf:default-direct-attribute-editing := fn:true();

(: fn:true doesn't create any insert-triggers:)
declare variable $xrxe-conf:default-disable-insert-elements := fn:false();

(: fn:true doesn't create any delete-triggers and dialogs:)
declare variable $xrxe-conf:default-disable-delete-elements := fn:false();

(: fn:true directly deletes the elements without a dialog:)
declare variable $xrxe-conf:default-direct-delete-nodes := fn:false();

(: fn:true doesn't create any instances and binds for the delete-triggers:)
declare variable $xrxe-conf:default-disable-delete-relevant := fn:false();

(: fn:true doesn't create any instances and binds for the delete-triggers:)
declare variable $xrxe-conf:default-disable-insert-relevant := fn:false();

declare variable $xrxe-conf:default-xrx-development := fn:false();

(: fn:true creates a switch/trigger structure for node's children:)
declare variable $xrxe-conf:default-annotate := fn:false();

declare variable $xrxe-conf:default-embed := fn:false();

declare variable $xrxe-conf:default-debug := fn:false();

declare variable $xrxe-conf:services := "http://localhost:8080/exist/rest/db/editor/xrxe-services.xql";





