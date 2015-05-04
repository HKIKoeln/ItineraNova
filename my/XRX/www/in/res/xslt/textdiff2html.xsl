<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:text="http://exist-db.org/xquery/text"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  id="textdiff2html" 
  version="1.0">
  <xsl:output method="html" indent="no"/>
  <xsl:template match="/">
    <span class="textdiff"><xsl:apply-templates/></span>
  </xsl:template>
  <xsl:template match="text:equal">
      <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="text:delete">
      <span class="textdiff-delete"><xsl:apply-templates/></span>
  </xsl:template>
  <xsl:template match="text:insert">
      <span class="textdiff-insert"><xsl:apply-templates/></span>
  </xsl:template>
</xsl:stylesheet>