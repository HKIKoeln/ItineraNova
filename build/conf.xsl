<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:param name="cache-size"/>
  <xsl:param name="collection-cache"/>
  <xsl:param name="db-files"/>
  <xsl:param name="backup-cron-trigger"/>
  
  <xsl:template match="//scheduler">
    <scheduler>
		  <job type="system" name="check1"
		      class="org.exist.storage.ConsistencyCheckTask">
		      <xsl:attribute name="cron-trigger">
		        <xsl:value-of select="$backup-cron-trigger"/>
		      </xsl:attribute>
          <parameter name="output" value="export"/>
          <parameter name="backup" value="yes"/>
          <parameter name="incremental" value="yes"/>
          <parameter name="incremental-check" value="no"/>
          <parameter name="max" value="7"/>
		  </job>
	  </scheduler>
  </xsl:template>

  <xsl:template match="//db-connection/@cacheSize">
    <xsl:attribute name="cacheSize">
      <xsl:value-of select="$cache-size"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="//xquery/@enable-java-binding">
    <xsl:attribute name="enable-java-binding">yes</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="//db-connection/@collectionCache">
    <xsl:attribute name="collectionCache">
      <xsl:value-of select="$collection-cache"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="//db-connection/@files">
    <xsl:attribute name="files">
      <xsl:text>../</xsl:text>
      <xsl:value-of select="$db-files"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="//xquery/builtin-modules">
    <xsl:element name="builtin-modules">
      <xsl:copy-of select="@*"/>
      <!-- enable modules for eXist/A -->
      <module class="org.exist.xquery.modules.xslfo.XSLFOModule" uri="http://exist-db.org/xquery/xslfo"/>
      <module class="org.exist.xquery.modules.file.FileModule" uri="http://exist-db.org/xquery/file"/>
      <module class="org.exist.xquery.modules.mail.MailModule" uri="http://exist-db.org/xquery/mail"/>
      <module class="org.exist.xquery.modules.excel.ExcelModule" uri="http://exist-db.org/xquery/excel"/>
      <module class="org.exist.xquery.modules.image.ImageModule" uri="http://exist-db.org/xquery/image"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
