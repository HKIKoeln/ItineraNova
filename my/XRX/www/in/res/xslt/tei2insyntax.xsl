<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0/"
  id="tei2insyntax" 
  version="1.0">
  <xsl:strip-space elements="*"/>
  <xsl:template match="/">
    <tei:p><xsl:apply-templates /></tei:p>
  </xsl:template>
  <xsl:template match="tei:del">
      <xsl:text>=</xsl:text>
      <xsl:apply-templates />
      <xsl:text>=</xsl:text>
  </xsl:template>
  <xsl:template match="tei:abbr">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates />
    <xsl:text>)</xsl:text>
  </xsl:template>
  <xsl:template match="tei:hi">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates />
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="tei:lb">
    <xsl:text>/</xsl:text>
  </xsl:template>
  <xsl:template match="tei:pb">
    <xsl:text>//</xsl:text>
  </xsl:template>
  <xsl:template match="tei:unclear">
    <xsl:apply-templates />
    <xsl:text>?</xsl:text>
  </xsl:template>
</xsl:stylesheet>