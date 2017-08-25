<?xml version="1.0" encoding="UTF-8"?>
<!-- 	Author: Ethan Gruber
	Date: June 2017
	Function: There are two modes of templates to render SPARQL results into HTML:
	   1. type-examples renders examples of physical specimens related to coin types displayed on coin type pages
	   2. examples of coin types associated with a symbol
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
    xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="res:result">
        <xsl:param name="findtype"/>
        
        <xsl:choose>
            <xsl:when test="res:binding[@name='poly']">
                <xsl:text>{"type": "Feature","geometry":</xsl:text>
                <xsl:value-of select="res:binding[@name='poly']/res:literal"/>
                <xsl:text>,"label": ",</xsl:text>
                <xsl:value-of select="res:binding[@name='label']/res:literal"/>
                <xsl:text>", "properties": {"toponym": "</xsl:text>
                <xsl:value-of select="res:binding[@name='label']/res:literal"/>
                <xsl:text>", "gazetteer_label": "</xsl:text>
                <xsl:value-of select="res:binding[@name='label']/res:literal"/>
                <xsl:text>", "gazetteer_uri": "</xsl:text>
                <xsl:value-of select="res:binding[@name='place']/res:uri"/>
                <xsl:text>","type": "</xsl:text>
                <xsl:value-of select="$findtype"/>
                <xsl:text>"</xsl:text>
                <xsl:text>}}</xsl:text>
                <xsl:if test="not(position()=last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>{"type": "Feature","label":"</xsl:text>
                <xsl:value-of select="if (res:binding[@name='hoardLabel']/res:literal) then res:binding[@name='hoardLabel']/res:literal else res:binding[@name='label']/res:literal"/>
                <xsl:text>",</xsl:text>
                <xsl:if test="res:binding[@name='hoard']/res:uri">
                    <xsl:text>"id":"</xsl:text>
                    <xsl:value-of select="res:binding[@name='hoard']/res:uri"/>
                    <xsl:text>",</xsl:text>
                </xsl:if>
                <!-- geometry -->
                <xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
                <xsl:value-of select="res:binding[@name='long']/res:literal"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="res:binding[@name='lat']/res:literal"/>
                <xsl:text>]},</xsl:text>
                <!-- when -->
                <xsl:if test="res:binding[@name='closingDate']">
                    <xsl:text>"when":{"timespans":[{</xsl:text>
                    <xsl:text>"start":"</xsl:text>
                    <xsl:value-of select="numishare:xsdToIso(res:binding[@name='closingDate']/res:literal)"/>
                    <xsl:text>","end":"</xsl:text>
                    <xsl:value-of select="numishare:xsdToIso(res:binding[@name='closingDate']/res:literal)"/>
                    <xsl:text>"</xsl:text>
                    <xsl:text>}]},</xsl:text>
                </xsl:if>
                <!-- properties -->
                <xsl:text>"properties": {"toponym": "</xsl:text>
                <xsl:value-of select="res:binding[@name='label']/res:literal"/>
                <xsl:text>","gazetteer_label": "</xsl:text>
                <xsl:value-of select="res:binding[@name='label']/res:literal"/>
                <xsl:text>", "gazetteer_uri": "</xsl:text>
                <xsl:value-of select="res:binding[@name='place']/res:uri"/>
                <xsl:text>","type": "</xsl:text>
                <xsl:value-of select="$findtype"/>
                <xsl:text>"</xsl:text>
                <xsl:text>}}</xsl:text>
                <xsl:if test="not(position()=last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
