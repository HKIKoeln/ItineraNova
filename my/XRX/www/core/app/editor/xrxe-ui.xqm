xquery version"1.0";

module namespace xrxe-ui='http://www.monasterium.net/NS/xrxe-ui';

declare variable $xrxe-ui:insert-trigger-label := '+';
declare variable $xrxe-ui:delete-trigger-label := 'X';
declare variable $xrxe-ui:insert-after-trigger-label := '+';
declare variable $xrxe-ui:insert-before-trigger-label := '<+';
declare variable $xrxe-ui:insert-copy-trigger-label := 'c>';
declare variable $xrxe-ui:move-first-trigger-label := '<<';
declare variable $xrxe-ui:move-up-trigger-label := '<';
declare variable $xrxe-ui:move-down-trigger-label := '>';
declare variable $xrxe-ui:move-last-trigger-label := '>>';
declare variable $xrxe-ui:attribute-trigger-label := '@';

declare variable $xrxe-ui:doublecheck-delete := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>doublecheck-delete</xrx:key>
                                                   	<xrx:default>Are you sure that you want to delete: </xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:cancal := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>cancal</xrx:key>
                                                   	<xrx:default>Cancal</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:ok := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>ok</xrx:key>
                                                   	<xrx:default>OK</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:delete :=  <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>delete</xrx:key>
                                                   	<xrx:default>Delete</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:attributes := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>attributes</xrx:key>
                                                   	<xrx:default>Attributes</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:save := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>save</xrx:key>
                                                   	<xrx:default>Save</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:save-and-close := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>save-and-close</xrx:key>
                                                   	<xrx:default>Save and Close</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:document-saved := <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>document-saved</xrx:key>
                                                   	<xrx:default>Document Saved</xrx:default>
                                                </xrx:i18n>;
declare variable $xrxe-ui:save-error:= <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>save-error</xrx:key>
                                                   	<xrx:default>Error: Document could not be saved</xrx:default>
                                                </xrx:i18n>;
                                        
declare variable $xrxe-ui:loading :=  <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>loading</xrx:key>
                                                   	<xrx:default>Loading...</xrx:default>
                                                </xrx:i18n>;

declare variable $xrxe-ui:unescape-submit-error := 'Unescape Submit Error';
declare variable $xrxe-ui:post-error :='Post Data in Document Error';

declare variable $xrxe-ui:not-valid :=  <xrx:i18n xmlns:xrx="http://www.monasterium.net/NS/xrx" >
                                                   	<xrx:key>invaild-message</xrx:key>
                                                   	<xrx:default>  isn't valid. The affected control is marked. Changes may not be saved unitil the document is valid again</xrx:default>
                                                </xrx:i18n>;
                                        

declare variable $xrxe-ui:default-place-triggers := 'top-and-bottom';



