xquery version "1.0";

module namespace migrate20="http://itineranova.be/NS/migrate20";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace tei="http://www.tei-c.org/ns/1.0/";

declare function migrate20:insert-atomid($entry as element(atom:entry), $atomid as xs:string) as element() {

  let $xsl := 
  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" version="1.0">
    <xsl:template match="/atom:entry/atom:id">
      <atom:id>{ $atomid }</atom:id>
    </xsl:template>
    <xsl:template match="@*|*" priority="-2">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" />
      </xsl:copy>
    </xsl:template>
  </xsl:stylesheet>
  
  let $transform := transform:transform($entry, $xsl, ())
  
  return
  
  $transform
 
};
