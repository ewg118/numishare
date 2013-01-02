<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs gml exsl skos rdf xlink nuds" xmlns="http://earth.google.com/kml/2.0"
	version="2.0">
	<xsl:include href="templates.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>

	<xsl:variable name="nudsGroup">
		<nudsGroup>
			<!-- get nomisma NUDS documents with get-nuds API -->
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="string-length($id-param) &gt; 0">
				<xsl:for-each select="document(concat('http://nomisma.org/get-nuds?id=', $id-param))//nuds:nuds">
					<object xlink:href="http://nomisma.org/id/{nuds:nudsHeader/nuds:nudsid}">
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>

			<!-- incorporate other typeDescs which do not point to nomisma.org -->
			<xsl:for-each select="descendant::nuds:typeDesc[not(contains(@xlink:href, 'nomisma.org'))]">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<xsl:if test="boolean(document(concat(@xlink:href, '.xml')))">
							<object xlink:href="{@xlink:href}">
								<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds"/>
							</object>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<object>
							<xsl:copy-of select="."/>
						</object>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf">
		<rdf:RDF>
			<xsl:variable name="id-param">
				<xsl:for-each
					select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href|exsl:node-set($nudsGroup)/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="rdf_url" select="concat('http://www.w3.org/2012/pyRdfa/extract?format=xml&amp;uri=', encode-for-uri(concat('http://nomisma.org/get-ids?id=', $id-param)))"/>
			<xsl:copy-of select="document($rdf_url)/descendant::*[string(@rdf:about) and not(local-name()='Description')]"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="kml"/>
	</xsl:template>

</xsl:stylesheet>
