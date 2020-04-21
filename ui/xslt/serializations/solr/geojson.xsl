<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: April 2020
	Function: serialize Solr results for geographic docs into GeoJSON -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- variables and parameters -->
	<xsl:param name="mode" select="//lst[@name = 'params']/str[@name = 'mode']"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<features>
					<_array>
						<xsl:choose>
							<xsl:when test="string($mode)">								
								<xsl:choose>
									<xsl:when test="$mode = 'query'">
										<xsl:apply-templates select="descendant::doc" mode="query"/>
									</xsl:when>
									<xsl:when test="$mode = 'hoard'">
										<xsl:apply-templates select="descendant::doc" mode="hoard"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>								
								<xsl:apply-templates select="//lst[contains(@name, '_geo')]"/>								
							</xsl:otherwise>
						</xsl:choose>
					</_array>
					
				</features>
			</_object>
			
		</xsl:variable>

		<xsl:apply-templates select="$model"/>

	</xsl:template>

	<xsl:template match="lst">
		<xsl:variable name="pointType" select="substring-before(@name, '_')"/>
		<xsl:for-each select="int">
			<xsl:variable name="value" select="tokenize(@name, '\|')[1]"/>
			<xsl:variable name="uri" select="tokenize(@name, '\|')[2]"/>
			<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(@name, '\|')[3], ','))"/>
			<xsl:variable name="long" select="normalize-space(substring-before(tokenize(@name, '\|')[3], ','))"/>

			<xsl:if test="number($lat) and number($long)">
				<_object>
					<type>Feature</type>
					<geometry>
						<_object>
							<type>Point</type>
							<coordinates>
								<_array>
									<_>
										<xsl:value-of select="$long"/>
									</_>
									<_>
										<xsl:value-of select="$lat"/>
									</_>
								</_array>
							</coordinates>							
						</_object>						
					</geometry>
					<properties>
						<_object>
							<name>
								<xsl:value-of select="$value"/>
							</name>
							<uri>
								<xsl:value-of select="$uri"/>
							</uri>
							<type>
								<xsl:value-of select="$pointType"/>
							</type>
						</_object>
					</properties>
				</_object>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="doc" mode="hoard">
		<xsl:variable name="value" select="tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[1]"/>
		<xsl:variable name="uri" select="tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[2]"/>
		<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[3], ','))"/>
		<xsl:variable name="long" select="normalize-space(substring-before(tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[3], ','))"/>
		<xsl:if test="number($lat) and number($long)">
			<_object>
				<type>Feature</type>
				<geometry>
					<_object>
						<type>Point</type>
						<coordinates>
							<_array>
								<_>
									<xsl:value-of select="$long"/>
								</_>
								<_>
									<xsl:value-of select="$lat"/>
								</_>
							</_array>
						</coordinates>						
					</_object>
				</geometry>
				<properties>
					<_object>
						<name>
							<xsl:value-of select="$value"/>
						</name>
						<uri>
							<xsl:value-of select="$uri"/>
						</uri>
						<type>hoard</type>
						<objectTitle>
							<xsl:value-of select="str[@name='title_display']"/>
						</objectTitle>
						<objectURI>
							<xsl:value-of
								select="
								if (//config/uri_space) then
								concat(//config/uri_space, str[@name = 'recordId'])
								else
								concat($url, 'id/', str[@name = 'recordId'])"
							/>
						</objectURI>
						<xsl:if test="str[@name = 'closing_date_display']">
							<closing_date>
								<xsl:value-of select="str[@name = 'closing_date_display']"/>
							</closing_date>
						</xsl:if>
						<xsl:if test="str[@name = 'deposit_display']">
							<deposit>
								<xsl:value-of select="str[@name = 'deposit_display']"/>
							</deposit>
						</xsl:if>
					</_object>
				</properties>
				
				<xsl:if test="int[@name = 'taq_num' or @name = 'tpq_num' or @name = 'deposit_minint' or @name='deposit_maxint']">
					<when>
						<_object>
							<timespans>
								<_array>
									<_object>
										<xsl:choose>
											<xsl:when test="int[@name='deposit_minint' or @name='deposit_maxint']">
												<xsl:apply-templates select="int[@name='deposit_minint']"/>
												<xsl:apply-templates select="int[@name='deposit_maxint']"/>
											</xsl:when>
											<xsl:when test="int[@name = 'taq_num' or @name = 'tpq_num']">
												<xsl:apply-templates select="int[@name='tpq_num']"/>
												<xsl:apply-templates select="int[@name='taq_num']"/>
											</xsl:when>
										</xsl:choose>
									</_object>
								</_array>
							</timespans>
						</_object>
					</when>
				</xsl:if>
			</_object>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="int[@name = 'taq_num' or @name = 'tpq_num' or @name = 'deposit_minint' or @name='deposit_maxint']">
		<!-- ensure that negative numbers conform to ISO 8601 and not xsd:gYear (1 BC = '0000') -->
		
		<xsl:variable name="element" select="if (@name='deposit_minint' or @name='tpq_num') then 'start' else 'end'"/>
		
		<xsl:element name="{$element}">
			<_object>
				<in>
					<xsl:choose>
						<xsl:when test=". &lt; 0">
							<xsl:value-of select="format-number(number(.) + 1, '0000')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(number(.), '0000')"/>
						</xsl:otherwise>
					</xsl:choose>
				</in>
			</_object>
		</xsl:element>
	</xsl:template>

	<xsl:template match="doc" mode="query">
		<xsl:variable name="lat" select="normalize-space(substring-after(tokenize(arr[@name = 'mint_geo']/str[1], '\|')[3], ','))"/>
		<xsl:variable name="long" select="normalize-space(substring-before(tokenize(arr[@name = 'mint_geo']/str[1], '\|')[3], ','))"/>
		<xsl:if test="number($lat) and number($long)">
			
			<_object>
				<type>Feature</type>
				<geometry>
					<_object>
						<type>Point</type>
						<coordinates>
							<_array>
								<_>
									<xsl:value-of select="$long"/>
								</_>
								<_>
									<xsl:value-of select="$lat"/>
								</_>
							</_array>
						</coordinates>						
					</_object>
				</geometry>
				<properties>
					<_object>
						<name>
							<xsl:value-of select="str[@name = 'title_display']"/>
						</name>
						<uri>
							<xsl:value-of
								select="
								if (//config/uri_space) then
								concat(//config/uri_space, str[@name = 'recordId'])
								else
								concat($url, 'id/', str[@name = 'recordId'])"/>
						</uri>								
					</_object>
				</properties>
			</_object>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
