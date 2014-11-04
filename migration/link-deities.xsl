<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" 
	exclude-result-prefixes="nuds" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:variable name="deities" as="element()*">
		<xsl:copy-of select="document('deities.xml')/*"/>
	</xsl:variable>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="nuds:maintenanceHistory">
		<xsl:element name="maintenanceHistory" namespace="http://nomisma.org/nuds">
			<xsl:apply-templates/>
			<maintenanceEvent xmlns="http://nomisma.org/nuds">
				<eventType>derived</eventType>
				<eventDateTime standardDateTime="{current-dateTime()}">
					<xsl:value-of select="format-dateTime(current-dateTime(), '[D1] [MNn] [Y0001] [H01]:[m01]:[s01]:[f01]')"/>
				</eventDateTime>
				<agentType>machine</agentType>
				<agent>XSLT</agent>
				<eventDescription>Linked deities to BM URIs.</eventDescription>
			</maintenanceEvent>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="nuds:persname[@xlink:role='deity']">
		<xsl:element name="persname" namespace="http://nomisma.org/nuds">
			<xsl:attribute name="xlink:role">deity</xsl:attribute>
			<xsl:attribute name="xlink:type">simple</xsl:attribute>
			
			<xsl:variable name="value" select="normalize-space(.)"/>
			
			<xsl:choose>
				<xsl:when test="string($deities//deity[name=$value]/uri)">
					<xsl:attribute name="xlink:href" select="$deities//deity[name=$value]/uri"/>
					<xsl:value-of select="$value"/>
				</xsl:when>
				<xsl:when test="string($deities//deity[name=$value]/should_be)">
					<xsl:variable name="should_be" select="$deities//deity[name=$value]/should_be"/>
					<xsl:if test="string($deities//deity[name=$should_be]/uri)">
						<xsl:attribute name="xlink:href" select="$deities//deity[name=$should_be]/uri"/>						
					</xsl:if>
					<xsl:value-of select="$should_be"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
