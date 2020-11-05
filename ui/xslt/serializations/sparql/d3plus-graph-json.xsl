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
						<xsl:apply-templates select="descendant::res:result" mode="edges"/>
					</_array>
				</edges>
			</_object>

		</xsl:variable>

		<!--<xsl:copy-of select="$model"/>-->
		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="*" mode="nodes">
		<xsl:variable name="uri" select="."/>
		<xsl:variable name="name" select="parent::res:binding/@name"/>

		<xsl:if test="not(preceding::node()[. = $uri])">
			<_object>
				<id>
					<xsl:value-of select="tokenize(., '/')[last()]"/>
				</id>
				<label datatype="xs:string">
					<xsl:value-of select="ancestor::res:result/res:binding[@name = concat($name, 'Label')]/res:literal"/>
				</label>
				<side>
					<xsl:choose>
						<xsl:when test="//res:binding[@name='die'][res:uri = $uri]">							
							<xsl:choose>
								<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name='die'][res:uri = $uri] 
									and //res:sparql[2]/res:results/res:result/res:binding[@name='die'][res:uri = $uri]">both</xsl:when>
								<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name='die'][res:uri = $uri]">obv</xsl:when>
								<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name='die'][res:uri = $uri]">rev</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="//res:binding[@name='altDie'][res:uri = $uri]">
							<xsl:choose>
								<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name='altDie'][res:uri = $uri] 
									and //res:sparql[2]/res:results/res:result/res:binding[@name='altDie'][res:uri = $uri]">both</xsl:when>
								<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name='altDie'][res:uri = $uri]">rev</xsl:when>
								<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name='altDie'][res:uri = $uri]">obv</xsl:when>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</side>
			</_object>
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="res:result" mode="edges">
		<xsl:variable name="uri" select="res:uri"/>
		
		<_object>
			<source>
				<xsl:apply-templates select="res:binding[@name='die']" mode="edges"/>
			</source>
			<target>
				<xsl:apply-templates select="res:binding[@name='altDie']" mode="edges"/>
			</target>
			<weight>4</weight>
		</_object>		
		
	</xsl:template>
	
	<xsl:template match="res:binding[@name='altDie' or @name = 'die']" mode="edges">
		<xsl:value-of select="tokenize(res:uri, '/')[last()]"/>
	</xsl:template>


</xsl:stylesheet>
