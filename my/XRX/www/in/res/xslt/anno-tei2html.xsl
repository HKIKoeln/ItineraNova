<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0/" xmlns:exist="http://exist.sourceforge.net/NS/exist" id="anno-tei2html" version="1.0">
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="exist:match">
        <span class="highlight">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:abbr">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
    </xsl:template>
</xsl:stylesheet>