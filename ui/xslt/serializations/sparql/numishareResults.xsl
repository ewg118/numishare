<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name = 'format']/value"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$format = 'json'">
				<xsl:variable name="json"> {"types":[<xsl:apply-templates select="//content" mode="json"/>]} </xsl:variable>

				<xsl:value-of select="normalize-space($json)"/>
			</xsl:when>
			<xsl:otherwise>
				<response>
					<xsl:apply-templates select="//content" mode="xml"/>
				</response>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="content" mode="xml">
		<group id="{tokenize(identifier, '/')[last()]}">
			<!-- display counts -->
			<xsl:apply-templates select="res:sparql[1]/res:results" mode="counts"/>

			<!-- display images -->
			<xsl:apply-templates select="res:sparql[2]/res:results[count(res:result) &gt; 0]" mode="images"/>
		</group>
	</xsl:template>

	<xsl:template match="content" mode="json"> { "id": "<xsl:value-of select="tokenize(identifier, '/')[last()]"/>", <xsl:apply-templates select="res:sparql[1]/res:results"
			mode="counts"/>
		<xsl:apply-templates select="res:sparql[2]/res:results[count(res:result) &gt; 0]" mode="images"/> } <xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:results" mode="counts">
		<xsl:choose>
			<xsl:when test="res:result/res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#NumismaticObject'">
				<xsl:choose>
					<xsl:when test="$format = 'json'">"object-count":<xsl:value-of
							select="res:result[res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#NumismaticObject']/res:binding[@name = 'count']/res:literal"
						/>,</xsl:when>
					<xsl:otherwise>
						<object-count>
							<xsl:value-of
								select="res:result[res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#NumismaticObject']/res:binding[@name = 'count']/res:literal"
							/>
						</object-count>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$format = 'json'">"object-count" : 0,</xsl:when>
					<xsl:otherwise>
						<object-count>0</object-count>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="res:result/res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#Hoard'">
				<xsl:choose>
					<xsl:when test="$format = 'json'">"hoard-count" : <xsl:value-of
							select="res:result[res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#Hoard']/res:binding[@name = 'count']/res:literal"
						/></xsl:when>
					<xsl:otherwise>
						<hoard-count>
							<xsl:value-of
								select="res:result[res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#Hoard']/res:binding[@name = 'count']/res:literal"
							/>
						</hoard-count>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$format = 'json'">"hoard-count" : 0</xsl:when>
					<xsl:otherwise>
						<hoard-count>0</hoard-count>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="res:results" mode="images">
		<xsl:choose>
			<xsl:when test="$format = 'json'">
				<xsl:text>, "objects": [</xsl:text>
				<xsl:apply-templates select="res:result" mode="json"/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<objects>
					<xsl:apply-templates select="res:result" mode="xml"/>
				</objects>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="res:result" mode="xml">
		<object>
			<xsl:attribute name="collection"
				select="
					if (string(res:binding[@name = 'collection']/res:literal)) then
						res:binding[@name = 'collection']/res:literal
					else
						res:binding[@name = 'datasetTitle']/res:literal"/>
			<xsl:attribute name="identifier" select="res:binding[@name = 'identifier']/res:literal"/>
			<xsl:attribute name="uri" select="res:binding[@name = 'object']/res:uri"/>

			<xsl:apply-templates select="res:binding[contains(@name, 'Thumb')] | res:binding[contains(@name, 'Ref')]" mode="xml"/>
		</object>
	</xsl:template>

	<xsl:template match="res:result" mode="json">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates select="res:binding" mode="json"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:binding" mode="xml">
		<xsl:element name="{@name}">
			<xsl:value-of select="res:uri"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="res:binding" mode="json">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="
				if (@name = 'object') then
					'uri'
				else
					@name"/>
		<xsl:text>":"</xsl:text>
		<xsl:value-of select="*"/>
		<xsl:text>"</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
