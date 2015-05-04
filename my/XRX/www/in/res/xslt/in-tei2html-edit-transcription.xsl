<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:i18n="http://www.mom-ca.uni-koeln.de/NS/i18n"
	xmlns:tei="http://www.tei-c.org/ns/1.0/" id="in-tei2html-edit-transcription"
	version="1.0">
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
	<xsl:template match="tei:del">
		&lt;span style="text-decoration: line-through;"&gt;
		<xsl:apply-templates />
		&lt;/span&gt;
	</xsl:template>
	<xsl:template match="tei:ex">
		<xsl:text>(</xsl:text>
		<xsl:apply-templates />
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template match="tei:expan">
		<xsl:if
			test="preceding-sibling::node()[1]/self::* and not(preceding-sibling::node()[1]/self::tei:lb)">
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="tei:add">
		<xsl:if test="preceding-sibling::node()[1]/self::* or parent::tei:unclear">
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
		<xsl:text>[</xsl:text>
		<xsl:apply-templates />
		<xsl:text>]</xsl:text>
	</xsl:template>
	<xsl:template match="tei:lb">
		<xsl:text>/</xsl:text>
		<xhtml:br />
	</xsl:template>
	<xsl:template match="tei:pb">
		<xhtml:br />
		<xsl:text>//</xsl:text>
		<xhtml:br />
	</xsl:template>
	<xsl:template match="tei:unclear">
		<xsl:apply-templates />
		<xsl:text>?</xsl:text>
	</xsl:template>
</xsl:stylesheet>