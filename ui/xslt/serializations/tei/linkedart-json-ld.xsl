<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:output name="default" indent="no" omit-xml-declaration="yes"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[contains(@ref,
						'nomisma.org')]/@ref | descendant::*[contains(@period,
						'nomisma.org')]/@period)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="id-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>

			<xsl:variable name="id-var" as="element()*">
				<xsl:if test="doc-available($id-url)">
					<xsl:copy-of select="document($id-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- read distinct org:organization and org:memberOf URIs from the initial RDF API request and request these, but only if they aren't in the initial request -->
			<xsl:variable name="org-param">
				<xsl:for-each select="distinct-values($id-var//org:organization/@rdf:resource | $id-var//org:memberOf/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="org-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($org-param))"/>

			<xsl:variable name="org-var" as="element()*">
				<xsl:if test="doc-available($org-url)">
					<xsl:copy-of select="document($org-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- read distinct skos:broaders for mints in the RDF -->
			<xsl:variable name="region-param">
				<xsl:for-each select="distinct-values($id-var//nmo:Mint/skos:broader[not(@rdf:resource = $id-var//*/@rdf:about)]/@rdf:resource)">
					<xsl:variable name="href" select="."/>

					<xsl:if test="not($id-var/*[@rdf:about = $href])">
						<xsl:value-of select="substring-after($href, 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="region-url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($region-param))"/>

			<xsl:variable name="region-var" as="element()*">
				<xsl:if test="doc-available($region-url)">
					<xsl:copy-of select="document($region-url)/rdf:RDF"/>
				</xsl:if>
			</xsl:variable>

			<!-- copy the contents of the API request variables into this variable -->
			<xsl:copy-of select="$id-var/*"/>
			<xsl:copy-of select="$org-var/*"/>
			<xsl:copy-of select="$region-var/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<xsl:apply-templates select="//tei:TEI"/>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<__context>https://linked.art/ns/v1/linked-art.json</__context>
		<id>
			<xsl:value-of select="$objectUri"/>
		</id>
		<type>HumanMadeObject</type>
		<_label>
			<xsl:value-of select="descendant::tei:titleStmt/tei:title"/>
		</_label>

		<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc"/>

		<!--<xsl:apply-templates select="nuds:descMeta"/>-->

		<!-- IIIF manifest, if relevant -->
		<!--<xsl:if test="descendant::mets:file[@USE = 'iiif']">
			<subject_of>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="concat($url, 'manifest/', $id)"/>
						</id>
						<type>InformationObject</type>
						<conforms_to>http://iiif.io/api/presentation</conforms_to>
						<format>application/ld+json;profile="http://iiif.io/api/presentation/2/context.json"</format>
					</_object>
				</_array>
			</subject_of>
		</xsl:if>-->
	</xsl:template>

	<xsl:template match="tei:msDesc">

		<!-- physical description and general typologies -->
		<xsl:apply-templates select="tei:physDesc"/>

		<!-- production node, which combines elements from physDesc and history -->
		<xsl:if test="tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs[@type = 'execution'][@ref] or tei:history">
			<produced_by>
				<_object>
					<type>Production</type>

					<!-- physDesc includes technique -->
					<xsl:if test="tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs[@type = 'execution'][@ref]">
						<technique>
							<_array>
								<xsl:apply-templates select="tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs[@type = 'execution'][@ref]"/>
							</_array>
						</technique>
					</xsl:if>

					<!-- history includes people, dates, and places of production -->
					<xsl:apply-templates select="tei:history/tei:origin"/>
				</_object>
			</produced_by>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:origin">
		<xsl:if test="tei:persName[@ref]">
			<influenced_by>
				<_array>
					<xsl:apply-templates select="tei:persName[@ref]"/>
				</_array>
			</influenced_by>
		</xsl:if>

		<xsl:if test="tei:origPlace/tei:placeName[@ref]">
			<took_place_at>
				<_array>
					<xsl:apply-templates select="tei:origPlace/tei:placeName[@ref]"/>
				</_array>
			</took_place_at>
		</xsl:if>
		
		<xsl:apply-templates select="tei:origDate"/>
	</xsl:template>
	
	<xsl:template match="tei:origDate">
		<!-- timespan -->		
		<xsl:if test="@notBefore castable as xs:gYear and @notAfter castable as xs:gYear">
			<timespan>
				<_object>
					<type>TimeSpan</type>
					<_label>
						<xsl:if test="@notBefore">
							<xsl:value-of select="numishare:normalizeDate(@notBefore)"/>
						</xsl:if>
						<xsl:if test="@notBefore and @notAfter">
							<xsl:text>-</xsl:text>
						</xsl:if>
						<xsl:if test="@notAfter">
							<xsl:value-of select="numishare:normalizeDate(@notAfter)"/>
						</xsl:if>
					</_label>
					<begin_of_the_begin>
						<xsl:value-of select="numishare:expandDatetoDateTime(@notBefore, 'begin')"/>
					</begin_of_the_begin>
					<end_of_the_end>
						<xsl:value-of select="numishare:expandDatetoDateTime(@notAfter, 'end')"/>
					</end_of_the_end>
				</_object>
			</timespan>
		</xsl:if>		
	</xsl:template>

	<xsl:template match="tei:physDesc">

		<!-- typological attributes -->
		<classified_as>
			<_array>
				<_object>
					<id>aat:300133025</id>
					<type>Type</type>
					<_label>Artwork</_label>
				</_object>
				<xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:support/tei:objectType[@ref]"/>
			</_array>
		</classified_as>

		<xsl:if test="tei:objectDesc/tei:supportDesc/tei:support/tei:material[@ref]">
			<made_of>
				<_array>
					<xsl:apply-templates select="tei:objectDesc/tei:supportDesc/tei:support/tei:material[@ref]"/>
				</_array>
			</made_of>
		</xsl:if>



		<!-- tei:objectDesc/tei:layoutDesc/tei:layout/tei:rs[@ref]-->

		<!-- measurements -->
		<xsl:if test="tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions or tei:objectDesc/tei:supportDesc/tei:support/tei:measure">
			<dimension>
				<_array>
					<xsl:apply-templates
						select="tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/* | tei:objectDesc/tei:supportDesc/tei:support/tei:measure"/>
				</_array>
			</dimension>
		</xsl:if>

	</xsl:template>

	<!-- dimensions -->
	<xsl:template match="tei:dimensions/* | tei:measure">
		<xsl:variable name="field">
			<xsl:choose>
				<xsl:when test="string(@type)">
					<xsl:value-of select="@type"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local-name()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<_object>
			<type>Dimension</type>
			<value>
				<xsl:choose>
					<xsl:when test=". castable as xs:integer">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:when test=". castable as xs:decimal">
						<xsl:value-of select='format-number(., "0.00")'/>
					</xsl:when>
				</xsl:choose>
			</value>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="numishare:normalizeClassification($field)"/>
						</id>
						<type>Type</type>
						<_label>
							<xsl:value-of select="$field"/>
						</_label>
					</_object>
				</_array>
			</classified_as>
			<xsl:choose>
				<xsl:when test="@unit = 'mm'">
					<unit>
						<_object>
							<id>aat:300379097</id>
							<type>Type</type>
							<_label>millimeters</_label>
						</_object>
					</unit>
				</xsl:when>
				<xsl:when test="@unit = 'cm'">
					<unit>
						<_object>
							<id>aat:300379098</id>
							<type>Type</type>
							<_label>centimeters</_label>
						</_object>
					</unit>
				</xsl:when>
				<xsl:when test="@unit = 'g'">
					<unit>
						<_object>
							<id>aat:300379225</id>
							<type>Type</type>
							<_label>grams</_label>
						</_object>
					</unit>
				</xsl:when>
			</xsl:choose>
		</_object>
	</xsl:template>

	<xsl:template match="tei:material | tei:objectType | tei:rs | tei:persName | tei:orgName | tei:placeName">
		<xsl:variable name="uri" select="@ref"/>

		<_object>
			<id>
				<xsl:value-of select="numishare:resolveUriToCurie($uri, $rdf//*[@rdf:about = $uri])"/>
			</id>
			<type>
				<xsl:choose>
					<xsl:when test="self::tei:Material">Material</xsl:when>
					<xsl:when test="self::tei:placeName">Place</xsl:when>
					<xsl:when test="self::tei:persName">Person</xsl:when>
					<xsl:when test="self::tei:orgName">Group</xsl:when>
					<xsl:otherwise>Type</xsl:otherwise>
				</xsl:choose>
			</type>
			<_label>
				<xsl:value-of select="."/>
			</_label>

			<xsl:choose>
				<xsl:when test="local-name() = 'objectType'">
					<classified_as>
						<_array>
							<_object>
								<id>aat:300435443</id>
								<type>Type</type>
								<_label>Type of Work</_label>
							</_object>
						</_array>
					</classified_as>
				</xsl:when>

				<xsl:when test="@role[not(. = 'region') and not(. = 'statedAuthority')]">
					<xsl:variable name="role">
						<xsl:choose>
							<xsl:when test="matches(@role, 'https?://nomisma\.org')">
								<xsl:value-of select="tokenize(@role, '/')[last()]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@role"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<classified_as>
						<_array>
							<_object>
								<type>Type</type>
								<xsl:choose>
									<xsl:when test="$role = 'authority'">
										<xsl:choose>
											<xsl:when test="self::tei:persName">
												<id>aat:300025475</id>
												<_label>rulers (people)</_label>
											</xsl:when>
											<xsl:when test="self::tei:orgName">
												<id>aat:300232420</id>
												<_label>sovereign states</_label>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="$role = 'productionPlace'">
										<id>aat:300006031</id>
										<_label>mints (buildings)</_label>
									</xsl:when>
								</xsl:choose>

							</_object>
						</_array>
					</classified_as>
				</xsl:when>
			</xsl:choose>
		</_object>
	</xsl:template>



</xsl:stylesheet>
