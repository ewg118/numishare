<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:oa="http://www.w3.org/ns/oa#"
	xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:gml="http://www.opengis.net/gml" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:edm="http://www.europeana.eu/schemas/edm/"
	xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:crmsci="http://www.ics.forth.gr/isl/CRMsci/" xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:crmarchaeo="http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="xsl xs nuds nh xlink numishare mets gml tei" version="2.0">

	<!-- ************** PELAGIOS TEMPLATES **************** -->
	<xsl:template match="nuds:nuds | nh:nudsHoard" mode="pelagios">
		<xsl:variable name="id" select="descendant::*[local-name() = 'recordId']"/>
		<!-- get timestamp of last modification date of the NUDS record -->
		<xsl:variable name="date" select="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime"/>
		<pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$id}">
			<xsl:for-each select="descendant::*:descMeta/*:title">
				<dcterms:title>
					<xsl:if test="@xml:lang">
						<xsl:attribute name="xml:lang" select="@xml:lang"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</dcterms:title>
			</xsl:for-each>
			<foaf:homepage rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}"/>
			<xsl:if test="string(@recordType)">
				<!-- dates -->
				<xsl:choose>
					<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:date">
						<dcterms:temporal>start=<xsl:value-of select="number($nudsGroup//nuds:typeDesc/nuds:date/@standardDate)"/>; end=<xsl:value-of
								select="number($nudsGroup//nuds:typeDesc/nuds:date/@standardDate)"/></dcterms:temporal>
					</xsl:when>
					<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:dateRange">
						<dcterms:temporal>start=<xsl:value-of select="number($nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>;
								end=<xsl:value-of select="number($nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/></dcterms:temporal>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="@recordType = 'physical'">
					<!-- images -->
					<xsl:apply-templates select="nuds:digRep/mets:fileSec" mode="pelagios"/>
				</xsl:if>
			</xsl:if>
		</pelagios:AnnotatedThing>
		<!-- create annotations from pleiades URIs found in nomisma RDF and from findspots -->
		<xsl:for-each select="distinct-values($rdf//skos:closeMatch[contains(@rdf:resource, 'pleiades')]/@rdf:resource)">
			<oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number(position(), '000')}">
				<oa:hasBody rdf:resource="{.}#this"/>
				<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
				<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#attestsTo"/>
				<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
				<oa:annotatedAt rdf:datatype="xsd:dateTime">
					<xsl:value-of select="$date"/>
				</oa:annotatedAt>
			</oa:Annotation>
		</xsl:for-each>
		<xsl:apply-templates select="descendant::*:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | descendant::*:findspotDesc[string(@xlink:href)]"
			mode="pelagios">
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="count" select="count(distinct-values($rdf//skos:closeMatch[contains(@rdf:resource, 'pleiades')]/@rdf:resource))"/>
			<xsl:with-param name="date" select="$date"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- images -->
	<xsl:template match="mets:fileSec" mode="pelagios">
		<xsl:for-each select="mets:fileGrp">
			<xsl:variable name="side" select="@USE"/>
			<xsl:for-each select="mets:file">
				<xsl:choose>
					<xsl:when test="@USE = 'thumbnail'">
						<foaf:thumbnail>
							<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
										<xsl:value-of select="mets:FLocat/@xlink:href"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</foaf:thumbnail>
					</xsl:when>
					<xsl:when test="@USE = 'reference'">
						<foaf:depiction>
							<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
										<xsl:value-of select="mets:FLocat/@xlink:href"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</foaf:depiction>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*:geogname[@xlink:role = 'findspot'] | *:findspotDesc" mode="pelagios">
		<xsl:param name="id"/>
		<xsl:param name="count"/>
		<xsl:param name="date"/>
		<oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number($count + 1, '000')}">
			<oa:hasBody rdf:resource="{@xlink:href}"/>
			<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
			<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#foundAt"/>
			<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
			<oa:annotatedAt rdf:datatype="xsd:dateTime">
				<xsl:value-of select="$date"/>
			</oa:annotatedAt>
		</oa:Annotation>
	</xsl:template>

	<!-- ***** PROCESS NUDS RECORDS INTO NOMISMA COMPLIANT RDF MODELS ***** -->
	<xsl:template match="nuds:nuds" mode="nomisma">
		<xsl:variable name="id" select="descendant::*[local-name() = 'recordId']"/>

		<!-- deprecated objects (usually types and subtypes) -->
		<xsl:choose>
			<xsl:when
				test="descendant::*:maintenanceStatus != 'new' and descendant::*:maintenanceStatus != 'derived' and descendant::*:maintenanceStatus != 'revised'">
				<xsl:variable name="element">
					<xsl:choose>
						<xsl:when test="@recordType = 'conceptual'">
							<xsl:choose>
								<xsl:when test="$collection-type = 'cointype'">nmo:TypeSeriesItem</xsl:when>
								<xsl:when test="$collection-type = 'die'">crm:E28_Conceptual_Object</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="@recordType = 'physical'">nmo:NumismaticObject</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="hasDefinition" select="boolean(nuds:descMeta/nuds:noteSet/nuds:note[@semantic = 'skos:definition'])" as="xs:boolean"/>

				<xsl:element name="{$element}">
					<xsl:attribute name="rdf:about">
						<xsl:value-of
							select="
								if (string($uri_space)) then
									concat($uri_space, $id)
								else
									concat($url, 'id/', $id)"/>
					</xsl:attribute>

					<!-- include any additional prefix/namespace before processing otherRecordIds -->
					<xsl:for-each select="nuds:control/nuds:semanticDeclaration">
						<xsl:namespace name="{*:prefix}" select="*:namespace"/>
					</xsl:for-each>

					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

					<!-- insert titles -->
					<xsl:for-each select="descendant::nuds:descMeta/nuds:title">
						<skos:prefLabel>
							<xsl:if test="string(@xml:lang)">
								<xsl:attribute name="xml:lang" select="@xml:lang"/>
							</xsl:if>
							<xsl:value-of select="."/>
						</skos:prefLabel>
						<xsl:if test="$hasDefinition = false()">
							<skos:definition>
								<xsl:if test="string(@xml:lang)">
									<xsl:attribute name="xml:lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:value-of select="."/>
							</skos:definition>
						</xsl:if>
					</xsl:for-each>

					<!-- source nmo:TypeSeries, use typeSeries inherent to NUDS by default, if available -->
					<xsl:choose>
						<xsl:when test="nuds:descMeta/nuds:typeDesc/nuds:typeSeries/@xlink:href">
							<dcterms:source rdf:resource="{nuds:descMeta/nuds:typeDesc/nuds:typeSeries/@xlink:href}"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$collection-type = 'cointype'">
									<dcterms:source rdf:resource="{//config/type_series}"/>
								</xsl:when>
								<xsl:when test="$collection-type = 'die'">
									<dcterms:source rdf:resource="{//config/die_series}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>

					<!-- map notes with skos properties into skos -->
					<xsl:apply-templates select="nuds:descMeta/nuds:noteSet/nuds:note[@semantic]"/>

					<!-- other ids -->
					<xsl:apply-templates select="nuds:control/nuds:otherRecordId[string(@semantic)]"/>

					<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc" mode="nomisma">
						<xsl:with-param name="id" select="$id"/>
					</xsl:apply-templates>

					<void:inDataset rdf:resource="{$url}"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="@recordType = 'conceptual'">
						<xsl:variable name="hasDefinition" select="boolean(nuds:descMeta/nuds:noteSet/nuds:note[@semantic = 'skos:definition'])" as="xs:boolean"/>

						<xsl:variable name="element">
							<xsl:choose>
								<xsl:when test="$collection-type = 'cointype'">nmo:TypeSeriesItem</xsl:when>
								<xsl:when test="$collection-type = 'die'">crm:E28_Conceptual_Object</xsl:when>
							</xsl:choose>
						</xsl:variable>

						<xsl:element name="{$element}">
							<xsl:attribute name="rdf:about">
								<xsl:value-of
									select="
										if (string($uri_space)) then
											concat($uri_space, $id)
										else
											concat($url, 'id/', $id)"
								/>
							</xsl:attribute>

							<!-- include any additional prefix/namespace before processing otherRecordIds -->
							<xsl:for-each select="nuds:control/nuds:semanticDeclaration">
								<xsl:namespace name="{*:prefix}" select="*:namespace"/>
							</xsl:for-each>


							<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
							<!-- insert titles -->
							<xsl:for-each select="nuds:descMeta/nuds:title">
								<skos:prefLabel>
									<xsl:if test="string(@xml:lang)">
										<xsl:attribute name="xml:lang" select="@xml:lang"/>
									</xsl:if>
									<xsl:value-of select="."/>
								</skos:prefLabel>

								<!-- only display the definition if it's not explicitly included in a nuds:note -->
								<xsl:if test="$hasDefinition = false()">
									<skos:definition>
										<xsl:if test="string(@xml:lang)">
											<xsl:attribute name="xml:lang" select="@xml:lang"/>
										</xsl:if>
										<xsl:value-of select="."/>
									</skos:definition>
								</xsl:if>

							</xsl:for-each>

							<!-- map notes with skos properties into skos -->
							<xsl:apply-templates select="nuds:descMeta/nuds:noteSet/nuds:note[@semantic]"/>

							<!-- source nmo:TypeSeries, use typeSeries inherent to NUDS by default, if available -->
							<xsl:choose>
								<xsl:when test="nuds:descMeta/nuds:typeDesc/nuds:typeSeries/@xlink:href">
									<dcterms:source rdf:resource="{nuds:descMeta/nuds:typeDesc/nuds:typeSeries/@xlink:href}"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="$collection-type = 'cointype'">
											<dcterms:source rdf:resource="{//config/type_series}"/>
										</xsl:when>
										<xsl:when test="$collection-type = 'die'">
											<dcterms:source rdf:resource="{//config/die_series}"/>
										</xsl:when>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>

							<!-- other ids -->
							<xsl:apply-templates select="nuds:control/nuds:otherRecordId[string(@semantic)]"/>

							<!-- process typeDesc -->
							<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc" mode="nomisma">
								<xsl:with-param name="id" select="$id"/>
							</xsl:apply-templates>
							<void:inDataset rdf:resource="{$url}"/>

						</xsl:element>

						<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc/nuds:obverse | nuds:descMeta/nuds:typeDesc/nuds:reverse" mode="nomisma">
							<xsl:with-param name="id" select="$id"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="@recordType = 'physical'">
						<xsl:element name="nmo:NumismaticObject">
							<xsl:attribute name="rdf:about">
								<xsl:value-of
									select="
										if (string($uri_space)) then
											concat($uri_space, $id)
										else
											concat($url, 'id/', $id)"
								/>
							</xsl:attribute>
							<dcterms:title>
								<xsl:if test="string(@xml:lang)">
									<xsl:attribute name="xml:lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:value-of select="nuds:descMeta/nuds:title"/>
							</dcterms:title>
							<xsl:if test="nuds:descMeta/nuds:adminDesc/nuds:identifier">
								<dcterms:identifier>
									<xsl:value-of select="nuds:descMeta/nuds:adminDesc/nuds:identifier"/>
								</dcterms:identifier>
							</xsl:if>
							<xsl:for-each select="descendant::nuds:collection">
								<nmo:hasCollection>
									<xsl:choose>
										<xsl:when test="string(@xlink:href)">
											<xsl:attribute name="rdf:resource" select="@xlink:href"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="."/>
										</xsl:otherwise>
									</xsl:choose>
								</nmo:hasCollection>
							</xsl:for-each>

							<!-- type series items -->
							<xsl:for-each
								select="distinct-values(nuds:descMeta/nuds:typeDesc[not(@certainty)]/@xlink:href | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][@xlink:href][not(@certainty)]/@xlink:href)">
								<nmo:hasTypeSeriesItem rdf:resource="{.}"/>
							</xsl:for-each>

							<!-- other ids -->
							<xsl:apply-templates select="nuds:control/nuds:otherRecordId[string(@semantic)]"/>

							<!-- physical attributes -->
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc" mode="nomisma"/>

							<!-- findspot-->
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc" mode="nomisma">
								<xsl:with-param name="objectURI"
									select="
										if (string($uri_space)) then
											concat($uri_space, $id)
										else
											concat($url, 'id/', $id)"
								/>
							</xsl:apply-templates>

							<xsl:if test="descendant::mets:fileGrp[@USE = 'obverse']">
								<nmo:hasObverse rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#obverse"/>
							</xsl:if>
							<xsl:if test="descendant::mets:fileGrp[@USE = 'reverse']">
								<nmo:hasReverse rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#reverse"/>
							</xsl:if>
							
							<!-- look for combined images -->
							<xsl:apply-templates select="nuds:digRep/mets:fileSec/mets:fileGrp[@USE = 'combined']"/>			
							
							<void:inDataset rdf:resource="{$url}"/>
						</xsl:element>

						<!-- images -->
						<xsl:apply-templates select="nuds:digRep/mets:fileSec" mode="nomisma">
							<xsl:with-param name="id" select="$id"/>
						</xsl:apply-templates>

						<!-- findspot object -->
						<xsl:if test="nuds:descMeta/nuds:findspotDesc/nuds:findspot[gml:location]">
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc/nuds:findspot[gml:location]" mode="nomisma-object">
								<xsl:with-param name="objectURI"
									select="
										if (string($uri_space)) then
											concat($uri_space, $id)
										else
											concat($url, 'id/', $id)"
								/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="mets:fileGrp[@USE = 'combined']">
		<xsl:for-each select="mets:file">
			<xsl:choose>
				<xsl:when test="@USE = 'thumbnail'">
					<foaf:thumbnail>
						<xsl:attribute name="rdf:resource">
							<xsl:choose>
								<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
									<xsl:value-of select="mets:FLocat/@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</foaf:thumbnail>
				</xsl:when>
				<xsl:when test="@USE = 'reference'">
					<foaf:depiction>
						<xsl:attribute name="rdf:resource">
							<xsl:choose>
								<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
									<xsl:value-of select="mets:FLocat/@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</foaf:depiction>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mets:fileSec" mode="nomisma">
		<xsl:param name="id"/>

		<xsl:for-each select="mets:fileGrp[@USE = 'obverse' or @USE = 'reverse']">
			<xsl:variable name="side" select="@USE"/>
			<rdf:Description rdf:about="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#{$side}">
				<xsl:for-each select="mets:file">
					<xsl:choose>
						<xsl:when test="@USE = 'thumbnail'">
							<foaf:thumbnail>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
											<xsl:value-of select="mets:FLocat/@xlink:href"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</foaf:thumbnail>
						</xsl:when>
						<xsl:when test="@USE = 'reference'">
							<foaf:depiction>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="matches(mets:FLocat/@xlink:href, 'https?://')">
											<xsl:value-of select="mets:FLocat/@xlink:href"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</foaf:depiction>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</rdf:Description>

			<xsl:apply-templates select="mets:file[@USE = 'iiif']">
				<xsl:with-param name="reference" select="mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<!-- other record IDs -->
	<xsl:template match="*:otherRecordId[@semantic]">
		<xsl:variable name="uri" select="
				if (matches(., 'https?://') or @semantic = 'skos:notation') then
					.
				else
					concat($url, 'id/', .)"/>
		<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
		<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix = $prefix]/*:namespace"/>
		<xsl:element name="{@semantic}" namespace="{$namespace}">
			<xsl:choose>
				<xsl:when test="@semantic = 'skos:notation'">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="rdf:resource" select="$uri"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- IIIF images -->
	<xsl:template match="mets:file[@USE = 'iiif']">
		<xsl:param name="reference"/>

		<edm:WebResource rdf:about="{$reference}">
			<svcs:has_service rdf:resource="{mets:FLocat/@xlink:href}"/>
			<dcterms:isReferencedBy rdf:resource="{mets:FLocat/@xlink:href}/info.json"/>
		</edm:WebResource>
		<svcs:Service rdf:about="{mets:FLocat/@xlink:href}">
			<dcterms:conformsTo rdf:resource="http://iiif.io/api/image"/>
			<doap:implements rdf:resource="http://iiif.io/api/image/2/level1.json"/>
		</svcs:Service>
	</xsl:template>

	<!-- physical description -->
	<xsl:template match="nuds:physDesc" mode="nomisma">
		<xsl:if test="nuds:axis">
			<nmo:hasAxis rdf:datatype="xsd:integer">
				<xsl:value-of select="nuds:axis"/>
			</nmo:hasAxis>
		</xsl:if>
		<xsl:for-each select="nuds:measurementsSet/*">
			<xsl:element name="nmo:has{concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))}">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#decimal</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<!-- typological description -->
	<xsl:template match="nuds:typeDesc" mode="nomisma">
		<xsl:param name="id"/>

		<xsl:apply-templates select="nuds:objectType[@xlink:href]" mode="nomisma"/>

		<xsl:apply-templates select="nuds:material[@xlink:href] | nuds:denomination[@xlink:href] | nuds:manufacture[@xlink:href]" mode="nomisma"/>
		<xsl:apply-templates
			select="nuds:geographic/nuds:geogname[@xlink:href] | nuds:authority/nuds:persname[@xlink:href] | nuds:authority/nuds:corpname[@xlink:href]"
			mode="nomisma"/>
		<xsl:apply-templates select="nuds:date[@standardDate] | nuds:dateRange[child::node()/@standardDate]" mode="nomisma"/>
		<xsl:if test="nuds:obverse">
			<nmo:hasObverse rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#obverse"/>
		</xsl:if>
		<xsl:if test="nuds:reverse">
			<nmo:hasReverse rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#reverse"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:objectType" mode="nomisma">
		<nmo:representsObjectType rdf:resource="{@xlink:href}"/>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse" mode="nomisma">
		<xsl:param name="id"/>
		<rdf:Description rdf:about="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#{local-name()}">
			<xsl:apply-templates mode="nomisma"/>
		</rdf:Description>
	</xsl:template>

	<xsl:template match="nuds:legend" mode="nomisma">
		<xsl:if test="string(.)">
			<nmo:hasLegend>
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="."/>
			</nmo:hasLegend>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:die" mode="nomisma">
		<xsl:if test="string(.)">
			<nmo:hasDie>
				<xsl:choose>
					<xsl:when test="@xlink:href">
						<xsl:attribute name="rdf:resource" select="@xlink:href"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</nmo:hasDie>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:type/nuds:description" mode="nomisma">
		<dcterms:description>
			<xsl:if test="string(@xml:lang)">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</dcterms:description>
	</xsl:template>

	<!-- only include the symbol if it has a designated RDF property through the @xlink:arcrole -->
	<xsl:template match="nuds:symbol" mode="nomisma">
		<xsl:choose>
			<xsl:when test="@xlink:arcrole and @xlink:href">
				<xsl:variable name="element"
					select="
						if (@xlink:arcrole = 'nmo:hasMonogram') then
							'nmo:hasControlmark'
						else
							@xlink:arcrole"/>

				<xsl:element name="{$element}">
					<xsl:attribute name="rdf:resource" select="@xlink:href"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="descendant::tei:g[@ref]">
				<xsl:apply-templates select="descendant::tei:g[@ref]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- render TEI glyphs -->
	<xsl:template match="tei:g">
		<xsl:choose>
			<xsl:when test="ancestor::tei:choice">
				<!-- if there is a choice, then the implication is that the monogram is uncertain -->
				<nmo:hasControlmark>
					<rdf:Description>
						<rdf:value rdf:resource="{@ref}"/>
						<un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
					</rdf:Description>
				</nmo:hasControlmark>
			</xsl:when>
			<xsl:otherwise>
				<nmo:hasControlmark rdf:resource="{@ref}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:material | nuds:denomination | nuds:manufacture | nuds:geogname | nuds:persname | nuds:corpname" mode="nomisma">
		<xsl:variable name="href" select="@xlink:href"/>

		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="parent::nuds:obverse or parent::nuds:reverse">hasPortrait</xsl:when>
				<!-- ignore maker and artist -->
				<xsl:when test="@xlink:role = 'artist' or @xlink:role = 'maker'"/>
				<xsl:when test="@xlink:role = 'ruler'">hasAuthority</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="role" select="
							if (@xlink:role) then
								@xlink:role
							else
								local-name()"/>
					<xsl:value-of select="concat('has', concat(upper-case(substring($role, 1, 1)), substring($role, 2)))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($element) &gt; 0">
			<xsl:choose>
				<xsl:when test="@certainty = 'uncertain' or matches(@certainty, 'https?://nomisma\.org')">
					<xsl:element name="nmo:{$element}">
						<rdf:Description>
							<rdf:value rdf:resource="{@xlink:href}"/>
							<un:hasUncertainty>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="@certainty = 'uncertain'">http://nomisma.org/id/uncertain_value</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@certainty"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</un:hasUncertainty>
						</rdf:Description>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="nmo:{$element}">
						<xsl:attribute name="rdf:resource" select="@xlink:href"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:date" mode="nomisma">
		<nmo:hasStartDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="@standardDate"/>
		</nmo:hasStartDate>
		<nmo:hasEndDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="@standardDate"/>
		</nmo:hasEndDate>
	</xsl:template>

	<xsl:template match="nuds:dateRange" mode="nomisma">
		<nmo:hasStartDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="nuds:fromDate/@standardDate"/>
		</nmo:hasStartDate>
		<nmo:hasEndDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="nuds:toDate/@standardDate"/>
		</nmo:hasEndDate>
	</xsl:template>

	<!-- distinguish between hoards and individual finds -->
	<xsl:template match="nuds:findspotDesc" mode="nomisma">
		<xsl:param name="objectURI"/>

		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<!-- if the @xlink:href is in the findspotDesc, this is presumed to be the hoard -->
				<dcterms:isPartOf rdf:resource="{@xlink:href}"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="nuds:findspot" mode="nomisma">
					<xsl:with-param name="objectURI" select="$objectURI"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="nuds:findspot" mode="nomisma">
		<xsl:param name="objectURI"/>

		<xsl:choose>
			<xsl:when test="nuds:geogname/@xlink:href">
				<nmo:hasFindspot rdf:resource="{nuds:geogname/@xlink:href}"/>
			</xsl:when>
			<xsl:otherwise>
				<nmo:hasFindspot rdf:resource="{$objectURI}#findspot"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:findspot" mode="nomisma-object">
		<xsl:param name="objectURI"/>
		<xsl:variable name="coords" select="tokenize(gml:location/gml:Point/gml:coordinates, ',')"/>


		<xsl:if test="count($coords) = 2">
			<geo:SpatialThing rdf:about="{$objectURI}#findspot">
				<foaf:name>
					<xsl:value-of select="nuds:geogname"/>
				</foaf:name>
				<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
					<xsl:value-of select="normalize-space($coords[1])"/>
				</geo:lat>
				<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
					<xsl:value-of select="normalize-space($coords[2])"/>
				</geo:long>
			</geo:SpatialThing>
		</xsl:if>

	</xsl:template>

	<xsl:template match="nuds:note[@semantic]">
		<xsl:element name="{@semantic}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<!-- PROCESS NUDS-HOARD RECORDS INTO NOMISMA/METIS COMPLIANT RDF MODELS -->
	<xsl:template match="nh:nudsHoard" mode="nomisma">
		<xsl:variable name="id" select="descendant::*[local-name() = 'recordId']"/>
		<xsl:choose>
			<xsl:when
				test="descendant::*:maintenanceStatus != 'new' and descendant::*:maintenanceStatus != 'derived' and descendant::*:maintenanceStatus != 'revised'">
				<xsl:element name="nmo:Hoard">
					<xsl:attribute name="rdf:about">
						<xsl:value-of
							select="
								if (string($uri_space)) then
									concat($uri_space, $id)
								else
									concat($url, 'id/', $id)"/>
					</xsl:attribute>
					<xsl:for-each select="descendant::*:semanticDeclaration">
						<xsl:namespace name="{*:prefix}" select="*:namespace"/>
					</xsl:for-each>
					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
					<xsl:apply-templates select="nh:control/nh:otherRecordId[string(@semantic)]"/>
					<void:inDataset rdf:resource="{$url}"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<nmo:Hoard rdf:about="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}">
					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

					<!-- other ids -->
					<xsl:apply-templates select="nh:control/nh:otherRecordId[string(@semantic)]"/>

					<xsl:apply-templates select="nh:descMeta">
						<xsl:with-param name="id" select="$id"/>
					</xsl:apply-templates>

					<void:inDataset rdf:resource="{$url}"/>
				</nmo:Hoard>

				<xsl:if test="descendant::nh:contentsDesc[nh:contents]">
					<dcmitype:Collection rdf:about="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#contents">

						<xsl:for-each select="descendant::nuds:typeDesc/@xlink:href | descendant::nuds:undertypeDesc/@xlink:href">
							<nmo:hasTypeSeriesItem rdf:resource="{.}"/>
						</xsl:for-each>

						<xsl:variable name="all-nodes" as="element()*">
							<nodes>
								<xsl:for-each
									select="
										descendant::nuds:material[@xlink:href] | descendant::nuds:denomination[@xlink:href] | descendant::nuds:manufacture[@xlink:href] |
										descendant::nuds:geogname[@xlink:href] | descendant::nuds:persname[@xlink:href] | descendant::nuds:corpname[@xlink:href]">
									<xsl:sort select="@xlink:href"/>

									<xsl:copy-of select="."/>
								</xsl:for-each>
							</nodes>
						</xsl:variable>


						<xsl:apply-templates select="$all-nodes/*[not(@xlink:href = preceding-sibling::*/@xlink:href)]" mode="nomisma"/>
					</dcmitype:Collection>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:descMeta">
		<xsl:param name="id"/>

		<xsl:choose>
			<xsl:when test="lang('en', nh:title)">
				<skos:prefLabel xml:lang="en">
					<xsl:value-of select="nh:title[@xml:lang = 'en']"/>
				</skos:prefLabel>
			</xsl:when>
			<xsl:otherwise>
				<skos:prefLabel xml:lang="en">
					<xsl:value-of select="nh:title[1]"/>
				</skos:prefLabel>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="nh:hoardDesc"/>

		<!-- if there's no deposit date, then use the contents to derive a closing date (note, hoard records should have this manually entered to minimize pre-processing for RDF -->
		<xsl:if test="not(nh:hoardDesc/nh:deposit[nh:date or nh:dateRange]) and not(nh:hoardDesc/nh:closingDate[nh:date or nh:dateRange])">
			<xsl:call-template name="derive-closing-date"/>
		</xsl:if>

		<xsl:if test="nh:contentsDesc">
			<dcterms:tableOfContents rdf:resource="{if (string($uri_space)) then concat($uri_space, $id) else concat($url, 'id/', $id)}#contents"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nh:hoardDesc">
		<xsl:apply-templates select="nh:deposit | nh:closingDate | nh:findspot"/>
	</xsl:template>

	<xsl:template match="nh:deposit | nh:closingDate">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="descendant::*/@standardDate">
					<xsl:value-of select="descendant::*[last()]/@standardDate"/>
				</xsl:when>
				<xsl:when test="descendant::*//@notAfter">
					<xsl:value-of select="descendant::*[last()]/@notAfter"/>
				</xsl:when>
				<xsl:when test="descendant::*//@notBefore">
					<xsl:value-of select="descendant::*[last()]/@notBefore"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$date castable as xs:gYear">
			<nmo:hasClosingDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
				<xsl:value-of select="$date"/>
			</nmo:hasClosingDate>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nh:findspot">
		<nmo:hasFindspot>

			<xsl:choose>
				<xsl:when test="nh:geogname[@xlink:role = 'findspot'][@xlink:href]">
					<!-- create a shorthand directly to gazetteer URI in the old Hoard model -->
					<xsl:attribute name="rdf:resource" select="nh:geogname[@xlink:role = 'findspot'][1]/@xlink:href"/>
				</xsl:when>
				<xsl:otherwise>
					<nmo:Find>
						<xsl:apply-templates select="parent::node()/nh:discovery"/>

						<crm:P7_took_place_at>
							<crm:E53_Place>
								<xsl:apply-templates select="nh:description"/>
								<xsl:choose>
									<xsl:when test="nh:fallsWithin[nh:geogname[@xlink:role = 'findspot'][@xlink:href]]">
										<xsl:apply-templates select="nh:fallsWithin[nh:geogname[@xlink:role = 'findspot'][@xlink:href]]"/>
									</xsl:when>
									<xsl:when test="nh:geogname[@xlink:role = 'findspot'][not(@xlink:href)]">
										<rdfs:label>
											<xsl:value-of select="nh:geogname[@xlink:role = 'findspot'][not(@xlink:href)]"/>
										</rdfs:label>
									</xsl:when>
								</xsl:choose>
							</crm:E53_Place>
						</crm:P7_took_place_at>
					</nmo:Find>
				</xsl:otherwise>
			</xsl:choose>
		</nmo:hasFindspot>
	</xsl:template>

	<xsl:template match="nh:fallsWithin">
		<xsl:apply-templates select="nh:geogname[@xlink:href]" mode="fallsWithin"/>
	</xsl:template>

	<xsl:template match="nh:geogname" mode="fallsWithin">
		<xsl:choose>
			<xsl:when test="matches(@certainty, 'https?://')">
				<crm:P89_falls_within>
					<rdf:Description>
						<rdf:value rdf:resource="{@xlink:href}"/>
						<un:hasUncertainty rdf:resource="{@certainty}"/>
					</rdf:Description>
				</crm:P89_falls_within>
			</xsl:when>
			<xsl:otherwise>
				<crm:P89_falls_within rdf:resource="{@xlink:href}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:geogname" mode="place">
		<!-- default to using internal coordinates first -->
		<xsl:choose>
			<xsl:when test="parent::nh:fallsWithin/gml:location">
				<xsl:variable name="geoURI" select="concat(@xlink:href, '#this')"/>
				<crm:E53_Place rdf:about="{@xlink:href}">
					<rdfs:label>
						<xsl:value-of select="."/>
					</rdfs:label>

					<xsl:if test="parent::nh:fallsWithin/nh:type[@xlink:href]">
						<crm:P2_has_type rdf:resource="{parent::nh:fallsWithin/nh:type/@xlink:href}"/>
					</xsl:if>

					<geo:location rdf:resource="{$geoURI}"/>
					<crm:P168_place_is_defined_by rdf:resource="{$geoURI}"/>
				</crm:E53_Place>

				<xsl:apply-templates select="parent::nh:fallsWithin/gml:location">
					<xsl:with-param name="geoURI" select="$geoURI"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="contains(@xlink:href, 'geonames.org')">
				<xsl:variable name="geonameId" select="tokenize(@xlink:href, '/')[4]"/>
				<xsl:variable name="geoURI" select="concat('https://sws.geonames.org/', $geonameId, '/#this')"/>

				<!-- get coords from Geonames API -->
				<xsl:variable name="geonames_data" as="element()*">
					<xsl:copy-of
						select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
				</xsl:variable>

				<crm:E53_Place rdf:about="{@xlink:href}">
					<rdfs:label>
						<xsl:value-of select="."/>
					</rdfs:label>

					<xsl:if test="parent::nh:fallsWithin/nh:type[@xlink:href]">
						<crm:P2_has_type rdf:resource="{parent::nh:fallsWithin/nh:type/@xlink:href}"/>
					</xsl:if>

					<geo:location rdf:resource="{$geoURI}"/>
					<crm:P168_place_is_defined_by rdf:resource="{$geoURI}"/>
				</crm:E53_Place>

				<xsl:call-template name="generateSpatialThing">
					<xsl:with-param name="geoURI" select="$geoURI"/>
					<xsl:with-param name="lat" select="$geonames_data//lat"/>
					<xsl:with-param name="long" select="$geonames_data//lng"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="gml:location">
		<xsl:param name="geoURI"/>

		<geo:SpatialThing rdf:about="{$geoURI}">
			<rdf:type rdf:resource="http://www.ics.forth.gr/isl/CRMgeo/SP5_Geometric_Place_Expression"/>
			<crmgeo:Q9_is_expressed_in_terms_of rdf:resource="http://www.wikidata.org/entity/Q215848"/>

			<xsl:choose>
				<xsl:when test="gml:Point">
					<xsl:variable name="lat" select="normalize-space(substring-after(gml:Point/gml:coordinates, ','))"/>
					<xsl:variable name="long" select="normalize-space(substring-before(gml:Point/gml:coordinates, ','))"/>

					<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
						<xsl:value-of select="$lat"/>
					</geo:lat>
					<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
						<xsl:value-of select="$long"/>
					</geo:long>
					<crmgeo:asWKT rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral">
						<xsl:value-of select="concat('POINT (', $long, ' ', $lat, ')')"/>
					</crmgeo:asWKT>
				</xsl:when>
				<xsl:when test="gml:Polygon">
					<xsl:variable name="points" select="tokenize(gml:Polygon/gml:coordinates, ' ')"/>
					<xsl:variable name="x1" select="tokenize(normalize-space($points[1]), ',')[1]"/>
					<xsl:variable name="x2" select="tokenize(normalize-space($points[2]), ',')[1]"/>
					<xsl:variable name="y1" select="tokenize(normalize-space($points[1]), ',')[2]"/>
					<xsl:variable name="y2" select="tokenize(normalize-space($points[2]), ',')[2]"/>

					<xsl:variable name="polygon" as="element()*">
						<polygon>
							<sw>
								<x>
									<xsl:value-of select="
											if ($x1 &lt; $x2) then
												$x1
											else
												$x2"/>
								</x>
								<y>
									<xsl:value-of select="
											if ($y1 &lt; $y2) then
												$y1
											else
												$y2"/>
								</y>
							</sw>
							<nw>
								<x>
									<xsl:value-of select="
											if ($x1 &lt; $x2) then
												$x1
											else
												$x2"/>
								</x>
								<y>
									<xsl:value-of select="
											if ($y1 &gt; $y2) then
												$y1
											else
												$y2"/>
								</y>
							</nw>
							<ne>
								<x>
									<xsl:value-of select="
											if ($x1 &gt; $x2) then
												$x1
											else
												$x2"/>
								</x>
								<y>
									<xsl:value-of select="
											if ($y1 &gt; $y2) then
												$y1
											else
												$y2"/>
								</y>
							</ne>
							<se>
								<x>
									<xsl:value-of select="
											if ($x1 &gt; $x2) then
												$x1
											else
												$x2"/>
								</x>
								<y>
									<xsl:value-of select="
											if ($y1 &lt; $y2) then
												$y1
											else
												$y2"/>
								</y>
							</se>
						</polygon>
					</xsl:variable>

					<crmgeo:asWKT rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral">
						<xsl:text>POLYGON (</xsl:text>
						<xsl:for-each select="$polygon/*">
							<xsl:value-of select="x"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="y"/>
							<xsl:if test="not(position() = last())">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>)</xsl:text>
					</crmgeo:asWKT>
				</xsl:when>
			</xsl:choose>
		</geo:SpatialThing>
	</xsl:template>

	<xsl:template match="nh:description">
		<rdfs:label>
			<xsl:if test="@xml:lang">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</rdfs:label>
	</xsl:template>

	<xsl:template match="nh:discovery">
		<xsl:choose>
			<xsl:when test="nh:date/@standardDate">
				<xsl:apply-templates select="nh:date"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:date | nh:fromDate | nh:toDate">
		<xsl:element name="nmo:{if (self::nh:fromDate) then 'hasStartDate' else if (self::nh:toDate) then 'hasEndDate' else 'hasDate'}"
			namespace="http://nomisma.org/ontology#">
			<xsl:attribute name="rdf:datatype">
				<xsl:choose>
					<xsl:when test="@standardDate castable as xs:date">
						<xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
					</xsl:when>
					<xsl:when test="@standardDate castable as xs:gYearMonth">
						<xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
					</xsl:when>
					<xsl:when test="@standardDate castable as xs:gYear">
						<xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:attribute>

			<xsl:value-of select="@standardDate"/>
		</xsl:element>
	</xsl:template>

	<!-- ***** generate geo:SpatialThing from coordinates extracted from Geonames API ***** -->
	<xsl:template name="generateSpatialThing">
		<xsl:param name="geoURI"/>
		<xsl:param name="lat"/>
		<xsl:param name="long"/>

		<geo:SpatialThing rdf:about="{$geoURI}">
			<rdf:type rdf:resource="http://www.ics.forth.gr/isl/CRMgeo/SP5_Geometric_Place_Expression"/>
			<crmgeo:Q9_is_expressed_in_terms_of rdf:resource="http://www.wikidata.org/entity/Q215848"/>
			<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
				<xsl:value-of select="$lat"/>
			</geo:lat>
			<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
				<xsl:value-of select="$long"/>
			</geo:long>
			<crmgeo:asWKT rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral">
				<xsl:value-of select="concat('POINT (', $long, ' ', $lat, ')')"/>
			</crmgeo:asWKT>
		</geo:SpatialThing>
	</xsl:template>

	<!-- ***** derive closing date from hoard contents. this should be primarily deprecated since the closing date will be added to CHRR record in order to minimize pre-processing -->
	<xsl:template name="derive-closing-date">
		<xsl:variable name="nudsGroup" as="element()*">
			<nudsGroup>
				<xsl:variable name="type_series" as="element()*">
					<list>
						<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
							<type_series>
								<xsl:value-of select="."/>
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
							<xsl:if test="not(position() = last())">
								<xsl:text>|</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="string-length($id-param) &gt; 0">
						<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
							<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
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
		</xsl:variable>

		<xsl:variable name="all-dates" as="element()*">
			<dates>
				<xsl:for-each select="descendant::nuds:typeDesc">
					<xsl:if test="index-of(//config/certainty_codes/code[@accept = 'true'], @certainty)">
						<xsl:choose>
							<xsl:when test="string(@xlink:href)">
								<xsl:variable name="href" select="@xlink:href"/>
								<xsl:for-each select="$nudsGroup//object[@xlink:href = $href]/descendant::*/@standardDate">
									<xsl:if test="number(.)">
										<date>
											<xsl:value-of select="number(.)"/>
										</date>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="descendant::*/@standardDate">
									<xsl:if test="number(.)">
										<date>
											<xsl:value-of select="number(.)"/>
										</date>
									</xsl:if>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</dates>
		</xsl:variable>

		<!-- get date values for closing date -->
		<xsl:variable name="dates" as="element()*">
			<dates>
				<xsl:for-each select="distinct-values($all-dates//date)">
					<xsl:sort data-type="number"/>
					<date>
						<xsl:value-of select="number(.)"/>
					</date>
				</xsl:for-each>
			</dates>
		</xsl:variable>

		<xsl:if test="count($dates//date) &gt; 0">
			<nmo:hasClosingDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
				<xsl:value-of select="format-number($dates//date[last()], '0000')"/>
			</nmo:hasClosingDate>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
