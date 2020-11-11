<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: October 2020
	Function: XSLT templates for serializing an XML metamodel for SPARQL queries into text
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">
	
	<!-- default templates for constructed SPARQL -->
	<xsl:template match="triple">
		<xsl:value-of select="concat(@s, ' ', @p, ' ', @o, if (@filter) then concat(' FILTER ', @filter) else '', '.')"/>
		<xsl:if test="not(parent::union)">
			<xsl:if test="not(position() = last())">
				<xsl:text>&#x0A;</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- subselects -->
	<xsl:template match="select">
		<xsl:text>{&#x0A;SELECT </xsl:text>
		<xsl:value-of select="@variables"/>
		<xsl:text> WHERE {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}&#x0A;</xsl:text>
		<xsl:text>}&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="minus">
		<xsl:text>MINUS {</xsl:text>
		<xsl:apply-templates select="triple"/>
		<xsl:text>}&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="optional">
		<xsl:text>OPTIONAL {</xsl:text>
		<xsl:apply-templates select="optional|triple"/>
		<xsl:text>}&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="group">
		<xsl:if test="position() &gt; 1">
			<xsl:text>UNION </xsl:text>
		</xsl:if>
		<xsl:text>{</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="union">
		<xsl:choose>
			<xsl:when test="child::union">
				<xsl:apply-templates select="union"/>
			</xsl:when>
			<xsl:when test="child::group">
				<xsl:apply-templates select="group"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:for-each select="triple">
					<xsl:if test="position() &gt; 1">
						<xsl:text>UNION </xsl:text>
					</xsl:if>
					<xsl:text>{</xsl:text>
					<xsl:apply-templates select="self::node()"/>
					<xsl:text>}&#x0A;</xsl:text>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="graph">
		<xsl:value-of select="concat('GRAPH &lt;', @namedGraph, '&gt; {&#x0A;')"/>	
		<xsl:apply-templates/>
		<xsl:text>}&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="bind">
		<xsl:text>BIND (</xsl:text>
		<xsl:value-of select="concat(@statement, ' AS ', @variable)"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
</xsl:stylesheet>
