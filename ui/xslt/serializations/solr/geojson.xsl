<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

	<!-- variables and parameters -->
	<xsl:param name="mode" select="//lst[@name='params']/str[@name='mode']"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="string($mode)">
				<xsl:choose>
					<xsl:when test="count(descendant::doc) &gt; 0">
						<xsl:choose>
							<xsl:when test="$mode='query'">
								<xsl:text>[</xsl:text>
								<xsl:apply-templates select="descendant::doc" mode="query"/>
								<xsl:text>]</xsl:text>
							</xsl:when>
							<xsl:when test="$mode='hoard'">
								<xsl:text>[</xsl:text>
								<xsl:apply-templates select="descendant::doc" mode="hoard"/>
								<xsl:text>]</xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>{}</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				
				<xsl:choose>
					<xsl:when test="//lst[contains(@name, '_geo')]">
						<xsl:text>{"type": "FeatureCollection","features":[</xsl:text>
						<xsl:apply-templates select="//lst[contains(@name, '_geo')]"/>
						<xsl:text>]}</xsl:text>						
					</xsl:when>
					<xsl:otherwise>{}</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>


	</xsl:template>

	<xsl:template match="lst">
		<xsl:variable name="pointType" select="substring-before(@name, '_')"/>
		<xsl:for-each select="int">
			<xsl:variable name="value" select="tokenize(@name, '\|')[1]"/>
			<xsl:variable name="uri" select="tokenize(@name, '\|')[2]"/>
			<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(@name, '\|')[3], ','))"/>
			<xsl:variable name="long" select="normalize-space(substring-before(tokenize(@name, '\|')[3], ','))"/>

			<xsl:if test="number($lat) and number($long)">
				<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
				<xsl:value-of select="$long"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$lat"/>
				<xsl:text>]},"properties": {"name": "</xsl:text>
				<xsl:value-of select="$value"/>
				<xsl:text>", "uri": "</xsl:text>
				<xsl:value-of select="$uri"/>
				<xsl:text>","type": "</xsl:text>
				<xsl:value-of select="$pointType"/>
				<xsl:text>"</xsl:text>
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="doc" mode="hoard">
		<xsl:variable name="value" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[1]"/>
		<xsl:variable name="uri" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[2]"/>
		<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(arr[@name='findspot_geo']/str[1], '\|')[3], ','))"/>
		<xsl:variable name="long" select="normalize-space(substring-before(tokenize(arr[@name='findspot_geo']/str[1], '\|')[3], ','))"/>
		<xsl:if test="number($lat) and number($long)">
			<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
			<xsl:value-of select="$long"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$lat"/>
			<xsl:text>]},"properties": {"name": "</xsl:text>
			<xsl:value-of select="$value"/>
			<xsl:text>", "uri": "</xsl:text>
			<xsl:value-of select="$uri"/>
			<xsl:text>","type": "hoard","id":"</xsl:text>
			<xsl:value-of select="str[@name='recordId']"/>
			<xsl:text>","objectURI":"</xsl:text>
			<xsl:value-of select="if (//config/uri_space) then concat(//config/uri_space, str[@name='recordId']) else concat($url, 'id/', str[@name='recordId'])"/>
			<xsl:text>","closing_date":"</xsl:text>
			<xsl:value-of select="str[@name='closing_date_display']"/>
			<xsl:text>"</xsl:text>
			<xsl:text>}}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="doc" mode="query">
		<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(arr[@name='mint_geo']/str[1], '\|')[3], ','))"/>
		<xsl:variable name="long" select="normalize-space(substring-before(tokenize(arr[@name='mint_geo']/str[1], '\|')[3], ','))"/>
		<xsl:if test="number($lat) and number($long)">
			<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
			<xsl:value-of select="$long"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$lat"/>
			<xsl:text>]},"properties": {"name": "</xsl:text>
			<xsl:value-of select="str[@name='title_display']"/>
			<xsl:text>", "uri": "</xsl:text>
			<xsl:value-of select="if (//config/uri_space) then concat(//config/uri_space, str[@name='recordId']) else concat($url, 'id/', str[@name='recordId'])"/>
			<xsl:text>"</xsl:text>
			<xsl:text>}}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
