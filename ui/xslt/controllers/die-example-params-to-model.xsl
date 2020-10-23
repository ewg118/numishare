<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: October 2020
	Function: Construct a complex SPARQL union named graph query to get photographic examples of coins related to a die URI, only displaying the obverse or reverse image if possible -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>				
	<xsl:param name="page" select="doc('input:request')/request/parameters/parameter[name='page']/value"/>
	
	<xsl:variable name="uri">
		<xsl:choose>
			<xsl:when test="string($id)">
				<xsl:value-of select="concat(/config/uri_space, $id)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
	
	<!-- derive offset from page param -->
	<xsl:variable name="limit" select="if (/config/specimens_per_page castable as xs:integer) then /config/specimens_per_page else '48'"/>
	<xsl:variable name="offset">
		<xsl:choose>
			<xsl:when test="string-length($page) &gt; 0 and $page castable as xs:integer and number($page) > 0">
				<xsl:value-of select="($page - 1) * number($limit)"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="query">
		<xsl:value-of select="concat(doc('input:query'), ' OFFSET %OFFSET% LIMIT %LIMIT%')"/>
	</xsl:variable>
	<xsl:variable name="statements" as="element()*">
		<statements>
			<union>
				<xsl:for-each select="/config/die_study/namedGraph">
					<group>
						<xsl:call-template name="numishare:graph-group">
							<xsl:with-param name="uri" select="$uri"/>
							<xsl:with-param name="namedGraph" select="."/>
							<xsl:with-param name="side">Obverse</xsl:with-param>
						</xsl:call-template>
					</group>
					<group>
						<xsl:call-template name="numishare:graph-group">
							<xsl:with-param name="uri" select="$uri"/>
							<xsl:with-param name="namedGraph" select="."/>
							<xsl:with-param name="side">Reverse</xsl:with-param>
						</xsl:call-template>
					</group>
				</xsl:for-each>
			</union>			
		</statements>
	</xsl:variable>	
	
	<xsl:variable name="statementsSPARQL">
		<xsl:apply-templates select="$statements/*"/>
	</xsl:variable>
	
	<xsl:variable name="service">
		<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace(replace($query, '%STATEMENTS%', $statementsSPARQL), '%OFFSET%', $offset), '%LIMIT%', $limit)), '&amp;output=xml')"/>					
	</xsl:variable>
	
	<xsl:template match="/">
		<config>
			<url>
				<xsl:value-of select="$service"/>
			</url>
			<content-type>application/xml</content-type>
			<encoding>utf-8</encoding>
		</config>
	</xsl:template>
	
</xsl:stylesheet>
