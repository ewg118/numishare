<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl" xmlns:pelagios="http://pelagios.github.io/vocab/terms#"
	xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">

	<xsl:param name="mode" select="//lst[@name='params']/str[@name='mode']"/>
	<xsl:param name="url" select="/content/config/url"/>
	<xsl:param name="uri_space" select="/content/config/uri_space"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
						<foaf:name>
							<xsl:value-of select="/content/config/template/agencyName"/>
						</foaf:name>
					</foaf:Organization>
					<xsl:apply-templates select="//doc" mode="pelagios"/>
				</xsl:when>
				<xsl:when test="$mode='nomisma'">
					<xsl:apply-templates select="//doc" mode="nomisma"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<!-- ************************* SOLR-BASED RDF ********************** -->
	<!-- PELAGIOS RDF -->
	<xsl:template match="doc" mode="pelagios" exclude-result-prefixes="#all">
		<xsl:variable name="id" select="str[@name='recordId']"/>
		<xsl:variable name="date" select="date[@name='timestamp']"/>
		<pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="str[@name='title_display']"/>
			</dcterms:title>
			<foaf:homepage rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}"/>

			<!-- temporal -->
			<xsl:choose>
				<xsl:when test="str[@name='recordType'] = 'hoard'">
					<xsl:if test="int[@name='taq_num'] or int[@name='tpq_num']">
						<dcterms:temporal>start=<xsl:value-of select="if (int[@name='tpq_num']) then int[@name='tpq_num'] else int[@name='taq_num']"/>; end=<xsl:value-of select="if
								(int[@name='taq_num']) then int[@name='taq_num'] else int[@name='tpq_num']"/></dcterms:temporal>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(arr[@name='year_num']/int) = 2">
							<dcterms:temporal>start=<xsl:value-of select="min(arr[@name='year_num']/int)"/>; end=<xsl:value-of select="max(arr[@name='year_num']/int)"/></dcterms:temporal>
						</xsl:when>
						<xsl:when test="count(arr[@name='year_num']/int) = 1">
							<dcterms:temporal>start=<xsl:value-of select="arr[@name='year_num']/int"/>; end=<xsl:value-of select="arr[@name='year_num']/int"/></dcterms:temporal>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>

			<!-- images -->
			<xsl:if test="str[@name='recordType'] = 'physical'">
				<xsl:if test="string(str[@name='thumbnail_obv'])">
					<xsl:variable name="href">
						<xsl:choose>
							<xsl:when test="contains(str[@name='thumbnail_obv'], 'http://')">
								<xsl:value-of select="str[@name='thumbnail_obv']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, str[@name='thumbnail_obv'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<foaf:thumbnail rdf:resource="{$href}"/>
				</xsl:if>
				<xsl:if test="string(str[@name='reference_obv'])">
					<xsl:variable name="href">
						<xsl:choose>
							<xsl:when test="contains(str[@name='reference_obv'], 'http://')">
								<xsl:value-of select="str[@name='reference_obv']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, str[@name='reference_obv'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<foaf:depiction rdf:resource="{$href}"/>
				</xsl:if>
				<xsl:if test="string(str[@name='thumbnail_rev'])">
					<xsl:variable name="href">
						<xsl:choose>
							<xsl:when test="contains(str[@name='thumbnail_rev'], 'http://')">
								<xsl:value-of select="str[@name='thumbnail_rev']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, str[@name='thumbnail_rev'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<foaf:thumbnail rdf:resource="{$href}"/>
				</xsl:if>
				<xsl:if test="string(str[@name='reference_rev'])">
					<xsl:variable name="href">
						<xsl:choose>
							<xsl:when test="contains(str[@name='reference_rev'], 'http://')">
								<xsl:value-of select="str[@name='reference_rev']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, str[@name='reference_rev'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<foaf:depiction rdf:resource="{$href}"/>
				</xsl:if>
			</xsl:if>
		</pelagios:AnnotatedThing>

		<!-- create annotations from pleiades URIs found in nomisma RDF and from findspots -->
		<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
			<oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number(position(), '000')}">
				<oa:hasBody rdf:resource="{.}#this"/>
				<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
				<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#attestsTo"/>
				<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
				<oa:annotatedAt rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="$date"/>
				</oa:annotatedAt>
			</oa:Annotation>
		</xsl:for-each>

		<!-- create annotations for findspots, but not for coin types -->
		<xsl:if test="not(str[@name='recordType'] = 'conceptual')">
			<xsl:variable name="count" select="count(distinct-values(arr[@name='pleiades_uri']/str))"/>
			<xsl:for-each select="distinct-values(arr[@name='findspot_uri']/str)">
				<oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number($count + 1, '000')}">
					<oa:hasBody rdf:resource="{.}"/>
					<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
					<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#foundAt"/>
					<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
					<oa:annotatedAt rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="$date"/>
					</oa:annotatedAt>
				</oa:Annotation>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- NOMISMA COIN TYPE RDF -->
	<xsl:template match="doc" mode="nomisma">
		<xsl:variable name="id" select="str[@name='recordId']"/>
		<xsl:variable name="recordType" select="str[@name='recordType']"/>

		<xsl:element name="{if ($recordType = 'hoard') then 'nmo:Hoard' else 'nmo:NumismaticObject'}" exclude-result-prefixes="#all">
			<xsl:attribute name="rdf:about" select="if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)"/>
			<dcterms:title xml:lang="{if (str[@name='lang']) then str[@name='lang'] else 'en'}">
				<xsl:value-of select="str[@name='title_display']"/>
			</dcterms:title>
			<dcterms:identifier>
				<xsl:value-of select="$id"/>
			</dcterms:identifier>
			<xsl:for-each select="arr[@name='collection_uri']/str">
				<nmo:hasCollection rdf:resource="{.}"/>
			</xsl:for-each>

			<xsl:if test="count(arr[@name='coinType_uri']/str) &gt; 0">
				<xsl:choose>
					<xsl:when test="$recordType='hoard'">
						<dcterms:tableOfContents rdf:resource="{concat($url, 'id/', $id, '#contents')}"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="arr[@name='coinType_uri']/str">
							<nmo:hasTypeSeriesItem rdf:resource="{.}"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!-- measurements for physical coins -->
			<xsl:if test="int[@name='axis_num']">
				<nmo:hasAxis rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
					<xsl:value-of select="int[@name='axis_num']"/>
				</nmo:hasAxis>
			</xsl:if>
			<xsl:if test="float[@name='diameter_num']">
				<nmo:hasDiameter rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
					<xsl:value-of select="float[@name='diameter_num']"/>
				</nmo:hasDiameter>
			</xsl:if>
			<xsl:if test="float[@name='weight_num']">
				<nmo:hasWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
					<xsl:value-of select="float[@name='weight_num']"/>
				</nmo:hasWeight>
			</xsl:if>
			<!-- findspot information -->
			<xsl:if test="int[@name='taq_num']">
				<nmo:hasClosingDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
					<xsl:value-of select="format-number(int[@name='taq_num'], '0000')"/>
				</nmo:hasClosingDate>
			</xsl:if>

			<xsl:if test="arr[@name='hoard_uri']/str">
				<dcterms:isPartOf rdf:resource="{arr[@name='hoard_uri']/str[1]}"/>
			</xsl:if>

			<!-- only include findspot if the coin is not part of a hoard -->
			<xsl:if test="arr[@name='findspot_geo']/str and not(arr[@name='hoard_uri'])">
				<xsl:variable name="findspot" select="tokenize(arr[@name='findspot_geo']/str, '\|')"/>
				<nmo:hasFindspot rdf:resource="{$findspot[2]}"/>
			</xsl:if>
			<!-- images -->
			<!-- obverse -->
			<xsl:if test="string(str[@name='reference_obv']) or string(str[@name='thumbnail_obv'])">
				<nmo:hasObverse>
					<rdf:Description>
						<xsl:attribute name="rdf:about" select="concat($url, 'id/', $id, '#obverse')"/>
						<xsl:if test="string(str[@name='reference_obv'])">
							<xsl:variable name="href">
								<xsl:choose>
									<xsl:when test="contains(str[@name='reference_obv'], 'http://')">
										<xsl:value-of select="str[@name='reference_obv']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, str[@name='reference_obv'])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<foaf:depiction rdf:resource="{$href}"/>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_obv'])">
							<xsl:variable name="href">
								<xsl:choose>
									<xsl:when test="contains(str[@name='thumbnail_obv'], 'http://')">
										<xsl:value-of select="str[@name='thumbnail_obv']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, str[@name='thumbnail_obv'])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<foaf:thumbnail rdf:resource="{$href}"/>
						</xsl:if>
					</rdf:Description>
				</nmo:hasObverse>
			</xsl:if>
			<!-- reverse -->
			<xsl:if test="string(str[@name='reference_rev']) or string(str[@name='thumbnail_rev'])">
				<nmo:hasReverse>
					<rdf:Description>
						<xsl:attribute name="rdf:about" select="concat($url, 'id/', $id, '#reverse')"/>
						<xsl:if test="string(str[@name='reference_rev'])">
							<xsl:variable name="href">
								<xsl:choose>
									<xsl:when test="contains(str[@name='reference_rev'], 'http://')">
										<xsl:value-of select="str[@name='reference_rev']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, str[@name='reference_rev'])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<foaf:depiction rdf:resource="{$href}"/>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_rev'])">
							<xsl:variable name="href">
								<xsl:choose>
									<xsl:when test="contains(str[@name='thumbnail_rev'], 'http://')">
										<xsl:value-of select="str[@name='thumbnail_rev']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, str[@name='thumbnail_rev'])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<foaf:thumbnail rdf:resource="{$href}"/>
						</xsl:if>
					</rdf:Description>
				</nmo:hasReverse>
			</xsl:if>
			<void:inDataset rdf:resource="{$url}"/>
		</xsl:element>

		<xsl:if test="count(arr[@name='coinType_uri']/str) &gt; 0 and $recordType = 'hoard'">
			<dcmitype:Collection rdf:about="{concat($url, 'id/', $id, '#contents')}">
				<xsl:for-each select="arr[@name='coinType_uri']/str">
					<nmo:hasTypeSeriesItem rdf:resource="{.}"/>
				</xsl:for-each>
			</dcmitype:Collection>
		</xsl:if>

		<xsl:if test="arr[@name='findspot_geo']/str and not(arr[@name='hoard_uri'])">
			<xsl:variable name="findspot" select="tokenize(arr[@name='findspot_geo']/str, '\|')"/>
			<xsl:choose>
				<xsl:when test="contains($findspot[2], 'nomisma.org')"/>
				<xsl:otherwise>
					<geo:SpatialThing rdf:about="{$findspot[2]}">
						<geo:lat>
							<xsl:value-of select="substring-after($findspot[3], ',')"/>
						</geo:lat>
						<geo:long>
							<xsl:value-of select="substring-before($findspot[3], ',')"/>
						</geo:long>
						<foaf:name>
							<xsl:value-of select="$findspot[1]"/>
						</foaf:name>
					</geo:SpatialThing>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
