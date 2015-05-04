<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" version="1.0">
  
  <xsl:param name="project-name"/>
  <xsl:param name="xrx-lib-request-root"/>
  <xsl:param name="xrx-lib-db-root"/>
  <xsl:param name="xrx-main-db-root"/>

  <xsl:template match="//exist:root[@pattern='.*'][@path='/']">
    <!-- 
      if there is a conflicts between a file system and
      a database request, all resources on file system
      should be at least reachable starting with /fs
    -->
    <exist:root pattern="/fs" path="/"/>
    <xsl:element name="exist:root"> 
      <xsl:attribute name="pattern">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$project-name"/> 
        <xsl:text>/</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="path">
        <xsl:value-of select="$xrx-main-db-root"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$project-name"/>
        <xsl:text>/</xsl:text>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="exist:root">
      <xsl:attribute name="pattern">
        <xsl:value-of select="$xrx-lib-request-root"/>
      </xsl:attribute>
      <xsl:attribute name="path">
        <xsl:value-of select="$xrx-lib-db-root"/>
      </xsl:attribute>
    </xsl:element>
    <!-- 
      all other requests are passed through.
     -->
    <exist:root pattern=".*" path="/"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
