<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" id="escape-mixed-ead">
    <xsl:template match="ead:emph | ead:occupation | ead:subject | ead:genreform | ead:function | ead:abstract | ead:container | ead:langmaterial | ead:physfacet | ead:extent | ead:physloc | ead:unitid | ead:eadid | ead:creation | ead:langusage | ead:descrules | ead:runner | ead:titleproper | ead:subtitle | ead:author | ead:sponsor | ead:dimensions | ead:origination | ead:repository | ead:subarea | ead:unitdate | ead:unittitle | ead:language | ead:materialspec | ead:legalstatus | ead:head | ead:p | ead:ref | ead:extref | ead:title  | ead:archref  | ead:bibref  | ead:edition  | ead:bibseries | ead:imprint | ead:publisher | ead:corpname | ead:famname | ead:geogname | ead:name | ead:persname | ead:date | ead:num  | ead:abbr  | ead:expan  | ead:addressline  | ead:event  | ead:label  | ead:head01 | ead:head02 | ead:item | ead:entry | ead:refloc | ead:extrefloc">
        <!--| ead:physdesc-->
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
    <xsl:template match="ead:scopecontent/ead:p">
        <!-- | ead:physdesc[ead:dimension] | ead:physdesc[ead:physfacet/@cei:material] | ead:physdesc[ead:physfacet/@cei:condition] | ead:physdesc[ead:physfacet/@cei:seal] | ead:physdesc[ead:physfacet/@cei:sealDesc] -->
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
</xsl:stylesheet><!--xsl:template match="ead:lb | ead:linkgrp | ead:extptr | ead:chronlist | ead:chronitem | ead:eventgrp | ead:table | ead:tgroup | ead:colspec | ead:tbody | ead:blockquote | ead:descgrp | ead:ead | ead:eadheader | ead:filedesc | ead:titlestmt | ead:editionstmt | ead:publicationstmt | ead:seriesstmt | ead:notestmt | ead:profiledesc | ead:revisiondesc | ead:change | ead:frontmatter | ead:titlepage | ead:archdesc | ead:div | ead:did | ead:accruals | ead:accessrestrict | ead:acqinfo | ead:altformavail | ead:originalsloc | ead:phystech | ead:appraisal  | ead:custodhist | ead:prefercite | ead:processinfo | ead:userestrict | ead:bioghist  | ead:controlaccess | ead:odd | ead:scopecontent | ead:arrangement | ead:bibliography  | ead:fileplan | ead:relatedmaterial | ead:separatedmaterial | ead:otherfindaid | ead:index | ead:indexentry | ead:namegrp | ead:ptrgrp | ead:c  | ead:c01 | ead:c02 | ead:c03 | ead:c04 | ead:c05  | ead:c06 | ead:c07 | ead:c08 | ead:c09 | ead:c10  | ead:c11 | ead:c12 | ead:dao | ead:daodesc | ead:daogrp  | ead:daoloc | ead:ptr | ead:address | ead:list | ead:defitem  | ead:listhead | ead:note | ead:thead | ead:row | ead:ptrloc  | ead:extptrloc | ead:arc | ead:dsc">
    
    <xsl:param name="escape"/>
    
    
    <xsl:choose>        
    <xsl:when test="$escape='true'">
    
    
    <xsl:call-template name="escapedStartTag"></xsl:call-template>
    
    <xsl:apply-templates>
    <xsl:with-param name="escape" select="$escape"></xsl:with-param>    
    </xsl:apply-templates>        
    
    <xsl:call-template name="escapedEndTag"></xsl:call-template>
    
    
    </xsl:when>
    <xsl:otherwise>
    
    <xsl:apply-templates>
    <xsl:with-param name="escape" select="$escape"></xsl:with-param>    
    </xsl:apply-templates>
    
    </xsl:otherwise>
    </xsl:choose>     
    
    
    
    
    
    </xsl:template-->