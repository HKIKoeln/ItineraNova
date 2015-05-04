<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" version="1.0" id="migrate">
  <xsl:param name="register"/>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="ead:persname/ead:ptr">
    <xsl:choose>
      <xsl:when test="@target = ''">
        <ead:ptr/>
      </xsl:when>
      <xsl:when test="not(starts-with(@target, 'pers'))">
        <xsl:value-of select="@target"/>
      </xsl:when>
      <xsl:when test="starts-with(@target, 'pers')">
        <ead:ptr>
          <xsl:value-of select="concat('pers-', $register, '-', substring-after(@target, '-'))"/>
        </ead:ptr>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@*|*" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>