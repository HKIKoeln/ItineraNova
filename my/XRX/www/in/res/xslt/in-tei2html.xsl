<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0/"
	id="in-tei2html" version="1.0">
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template name="globalReplace">
		<xsl:param name="outputString" />
		<xsl:param name="target" />
		<xsl:param name="replacement" />
		<xsl:choose>
			<xsl:when test="contains($outputString,$target)">
				<xsl:value-of
					select="concat(substring-before($outputString,$target), $replacement)" />
				<xsl:call-template name="globalReplace">
					<xsl:with-param name="outputString"
						select="substring-after($outputString,$target)" />
					<xsl:with-param name="target" select="$target" />
					<xsl:with-param name="replacement" select="$replacement" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$outputString" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:call-template name="globalReplace">
			<xsl:with-param name="outputString" select="." />
			<xsl:with-param name="target" select="'&#160;'" />
			<xsl:with-param name="replacement" select="' '" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="string-replace-all">
		<xsl:param name="text" />
		<xsl:param name="replace" />
		<xsl:param name="by" />
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)" />
				<xsl:value-of select="$by" />
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text"
						select="substring-after($text,$replace)" />
					<xsl:with-param name="replace" select="$replace" />
					<xsl:with-param name="by" select="$by" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="exist:match">
		<span class="highlight">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	<xsl:template match="tei:del">
		<strike>
			<xsl:apply-templates />
		</strike>
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
		<div />
	</xsl:template>
	<xsl:template match="tei:pb">
		<br />
		<xsl:text>//</xsl:text>
		<br />
	</xsl:template>
	<xsl:template match="tei:unclear">
		<xsl:apply-templates />
		<xsl:text>?</xsl:text>
	</xsl:template>
</xsl:stylesheet>