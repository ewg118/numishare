<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
	<xsl:include href="../serializations/object/rdf-templates.xsl"/>
	<xsl:include href="../serializations/object/kml-templates.xsl"/>
	<xsl:include href="../serializations/object/json-templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- url params -->
	<xsl:variable name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
	<xsl:variable name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>
	<xsl:variable name="mode" select="doc('input:request')/request/parameters/parameter[name='mode']/value"/>
	<xsl:variable name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'apis/'))"/>
	
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<!-- data aggregation -->
	<xsl:variable name="nudsGroup" as="element()*">
		<xsl:if test="$format='kml' or $format='json' or ($format='rdf' and $mode='pelagios')">
			<nudsGroup>
				<xsl:variable name="type_series" as="element()*">
					<list>
						<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
							<type_series>
								<xsl:choose>
									<xsl:when test="contains(., 'nomisma')">
										<xsl:value-of select="replace(., 'nomisma.org', 'numismatics.org/crro')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</type_series>
						</xsl:for-each>
					</list>
				</xsl:variable>
				<xsl:variable name="type_list" as="element()*">
					<list>
						<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
							<type_series_item>
								<xsl:value-of select="."/>
							</type_series_item>
						</xsl:for-each>
					</list>
				</xsl:variable>

				<xsl:for-each select="$type_series//type_series">
					<xsl:variable name="type_series_uri" select="."/>

					<xsl:variable name="id-param">
						<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
							<xsl:value-of select="substring-after(., 'id/')"/>
							<xsl:if test="not(position()=last())">
								<xsl:text>|</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:if test="string-length($id-param) &gt; 0">
						<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
							<object xlink:href="{replace($type_series_uri, 'numismatics.org/crro', 'nomisma.org')}id/{nuds:control/nuds:recordId}">
								<xsl:copy-of select="."/>
							</object>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
					<object>
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</nudsGroup>
		</xsl:if>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<xsl:if test="$format='kml' or $format='json' or ($format='rdf' and $mode='pelagios')">
			<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
				<xsl:variable name="id-param">
					<xsl:for-each
						select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href|$nudsGroup/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position()=last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
			</rdf:RDF>
		</xsl:if>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="root">
		<xsl:choose>
			<xsl:when test="$format='xml'">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:when test="$format='kml'">
				<xsl:call-template name="kml"/>
			</xsl:when>
			<xsl:when test="$format='json'">
				<xsl:call-template name="json"/>
			</xsl:when>
			<xsl:when test="$format='rdf'">
				<xsl:call-template name="rdf"/>
			</xsl:when>
			<xsl:otherwise>
				<error>test</error>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
