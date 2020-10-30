<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>

	<xsl:variable name="dies" as="node()*">
		<xsl:copy-of select="/dies"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<nodes>
					<_array>
						<xsl:apply-templates select="descendant::res:binding[@name = 'die']/res:uri | descendant::res:binding[@name = 'altDie']/res:uri"
							mode="nodes"/>
					</_array>
				</nodes>
				<edges>
					<_array>
						<xsl:apply-templates select="descendant::res:binding[@name='die']" mode="edges"/>
					</_array>
				</edges>
			</_object>

		</xsl:variable>

		<!--<xsl:copy-of select="$model"/>-->
		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="*" mode="nodes">
		<xsl:variable name="uri" select="."/>

		<xsl:if test="not(preceding::node()[. = $uri])">
			<_object>
				<id>
					<xsl:value-of select="tokenize(., '/')[last()]"/>
				</id>
			</_object>
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="res:binding[@name='die']" mode="edges">
		<xsl:variable name="uri" select="res:uri"/>
		
		<xsl:if test="not(preceding::res:binding[res:uri = $uri])">
			<_object>
				<source>
					<xsl:value-of select="normalize-space(tokenize(res:uri, '/')[last()])"/>
				</source>
				<xsl:apply-templates select="$dies/descendant::res:result[res:binding[@name='die']/res:uri = $uri]/res:binding[@name='altDie']" mode="edges"/>
				
				<weight>2</weight>
			</_object>
		</xsl:if>		
		
	</xsl:template>
	
	<xsl:template match="res:binding[@name='altDie']" mode="edges">
		<target>
			<xsl:value-of select="tokenize(res:uri, '/')[last()]"/>
		</target>
	</xsl:template>


</xsl:stylesheet>
