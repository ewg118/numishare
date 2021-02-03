<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
    Date: February 2021
    Function: Transform the JSON metamodel into text that is then serialized by Orbeon into JSON -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="xs" version="2.0">

    <!-- XSLT templates for rendering the $model into JSON -->
    <xsl:template match="*">
        <xsl:choose>
            <xsl:when test="self::_">
                <xsl:call-template name="numishare:evaluateDatatype">
                    <xsl:with-param name="val" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="child::_array">
                <xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
                <xsl:text>:</xsl:text>
                <xsl:apply-templates select="_array"/>
            </xsl:when>
            <xsl:when test="child::_object">
                <xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
                <xsl:text>:</xsl:text>
                <xsl:apply-templates select="_object"/>
            </xsl:when>
            <xsl:when test="@datatype = 'osgeo:asGeoJSON'">
                <xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <!-- when the element is preceded by two underscores, prepend an @ character, e.g., for @id or @type -->
                <xsl:choose>                    
                    <xsl:when test="substring(name(), 1, 2) = '__'">
                        <xsl:value-of select="concat('&#x022;@', substring(name(), 3), '&#x022;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>:</xsl:text>
                <xsl:call-template name="numishare:evaluateDatatype">
                    <xsl:with-param name="val" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- object template -->
    <xsl:template match="_object">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
        <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- array template -->
    <xsl:template match="_array">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
        <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
