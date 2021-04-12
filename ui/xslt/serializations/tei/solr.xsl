<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2021
	Function: This stylesheet reads the incoming TEI model and serializes into a Solr document
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nm="http://nomisma.org/id/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:org="http://www.w3.org/ns/org#" exclude-result-prefixes="#all" version="2.0">
	
	<xsl:template name="tei">
		<!-- create default document -->
		<xsl:apply-templates select="//tei:TEI">
			<xsl:with-param name="lang"/>
		</xsl:apply-templates>
		
		<!-- create documents for each additional activated language -->
		<xsl:for-each select="//config/descendant::language[@enabled = true()]">
			<xsl:apply-templates select="//tei:TEI">
				<xsl:with-param name="lang" select="@code"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<xsl:param name="lang"/>
		<xsl:variable name="id" select="@xml:id"/>
		
		<doc>
			<field name="id">
				<xsl:choose>
					<xsl:when test="string($lang)">
						<xsl:value-of select="concat($id, '-', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="recordId">
				<xsl:value-of select="$id"/>
			</field>
			<xsl:if test="string($lang)">
				<field name="lang">
					<xsl:value-of select="$lang"/>
				</field>
			</xsl:if>
			
			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>
			
			<field name="recordType">physical</field>
			
			<field name="publisher_display">
				<xsl:value-of select="$publisher"/>
			</field>
			
			<field name="timestamp">
				<xsl:choose>
					<xsl:when test="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime castable as xs:dateTime">
						<xsl:value-of
							select="format-dateTime(xs:dateTime(descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
		</doc>
	</xsl:template>
</xsl:stylesheet>
