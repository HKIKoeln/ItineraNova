<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" id="escape-mixed-cei">
    <xsl:template match="cei:encodingDesc | cei:publicationStmt | cei:availability | cei:respStmt | cei:idno  | cei:lang_MOM | cei:abstract | cei:figure | cei:figDesc | cei:graphic | cei:witListPar | cei:traditioForm | cei:condition | cei:sealCondition  | cei:sealDesc | cei:seal | cei:legend | cei:sigillant | cei:notariusDesc  | cei:dimensions | cei:sealDimensions | cei:material | cei:sealMaterial | cei:nota | cei:archIdentifier | cei:altIdentifier | cei:arch | cei:archFond | cei:provenance | cei:msIdentifier | cei:quoteOriginaldatierung | cei:tenor | cei:p | cei:pTenor | cei:invocatio | cei:intitulatio | cei:inscriptio | cei:publicatio | cei:arenga | cei:narratio | cei:dispositio | cei:corroboratio | cei:sanctio | cei:subscriptio | cei:datatio | cei:apprecatio | cei:setPhrase | cei:notariusSub | cei:damage | cei:app | cei:lem | cei:rdg | cei:expan | cei:sic | cei:corr | cei:del | cei:add | cei:sup | cei:c | cei:hi| cei:ref| cei:note | cei:foreign | cei:cit | cei:quote | cei:h1 | cei:h2 | cei:item | cei:measure | cei:num | cei:date | cei:dateRange | cei:persName | cei:recipient | cei:issuer | cei:testis | cei:region | cei:country | cei:settlement | cei:placeName | cei:geogName | cei:imprint | cei:name | cei:bibl | cei:scope | cei:a">
        <!--| cei:listBibl | cei:listBiblEdition | cei:listBiblRegest | cei:listBiblFaksimile | cei:listBiblErw | cei:physicalDesc | cei:auth | cei:text | cei:front | cei:chDesc | cei:witnessOrig | cei:diplomaticAnalysis | cei:witness | cei:index | cei:issued | cei: | cei: | cei:-->
        <xsl:param name="escape"/>
        <xsl:choose>
            <xsl:when test="$escape='true'">
                <xsl:call-template name="writeEscapedNode">
                    <xsl:with-param name="escape">true</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="leaveNode">
                    <xsl:with-param name="escape">true</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*">
        <xsl:param name="escape"/>
        <xsl:choose>
            <xsl:when test="$escape='true'">
                <xsl:call-template name="writeEscapedNode">
                    <xsl:with-param name="escape" select="$escape"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="leaveNode">
                    <xsl:with-param name="escape" select="$escape"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="leaveNode">
        <xsl:param name="escape"/>
        <xsl:copy>
            <xsl:copy-of select="./@*"/>
            <xsl:apply-templates>
                <xsl:with-param name="escape" select="$escape"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="writeEscapedNode">
        <xsl:param name="escape"/>
        <xsl:call-template name="escapedStartTag"/>
        <xsl:apply-templates>
            <xsl:with-param name="escape" select="$escape"/>
        </xsl:apply-templates>
        <xsl:call-template name="escapedEndTag"/>
    </xsl:template>
    <xsl:template name="escapedStartTag">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:for-each select="./@*">
            <xsl:call-template name="escapedAttribute"/>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    <xsl:template name="escapedAttribute">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    <xsl:template name="escapedEndTag">
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
</xsl:stylesheet>