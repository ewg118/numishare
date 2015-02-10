<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:ecrm="http://erlangen-crm.org/current/"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:relations="http://pelagios.github.io/vocab/relations#"  xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" version="2.0">

	<!-- ************** OBJECT-TO-RDF **************** -->
	<xsl:template name="rdf">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="pelagios"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="pelagios"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$mode='nomisma'">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="nomisma"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="nomisma"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$mode='cidoc'">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="cidoc"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="cidoc"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="nomisma"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="nomisma"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>


	<xsl:template match="nuds:nuds|nh:nudsHoard" mode="pelagios">
		<xsl:variable name="id" select="descendant::*[local-name()='recordId']"/>
		<!-- get timestamp of last modification date of the NUDS record -->
		<xsl:variable name="date" select="descendant::*:maintenanceEvent[last()]/*:eventDateTime/@standardDateTime"/>
		<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
			<foaf:name>
				<xsl:value-of select="//config/template/agencyName"/>
			</foaf:name>
		</foaf:Organization>
		<pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$id}">
			<xsl:for-each select="descendant::*:descMeta/*:title">
				<dcterms:title>
					<xsl:if test="@xml:lang">
						<xsl:attribute name="xml:lang" select="@xml:lang"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</dcterms:title>
			</xsl:for-each>
			<foaf:homepage rdf:resource="{$uri_space}{$id}"/>
			<xsl:if test="string(@recordType)">
				<!-- dates -->
				<xsl:choose>
					<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:date">
						<dcterms:temporal>start=<xsl:value-of select="numishare:iso-to-digit($nudsGroup//nuds:typeDesc/nuds:date/@standardDate)"/>; end=<xsl:value-of
								select="numishare:iso-to-digit($nudsGroup//nuds:typeDesc/nuds:date/@standardDate)"/></dcterms:temporal>
					</xsl:when>
					<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:dateRange">
						<dcterms:temporal>start=<xsl:value-of select="numishare:iso-to-digit($nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>; end=<xsl:value-of
								select="numishare:iso-to-digit($nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/></dcterms:temporal>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="@recordType='physical'">
					<!-- images -->
					<xsl:apply-templates select="nuds:digRep/mets:fileSec" mode="pelagios"/>
				</xsl:if>
			</xsl:if>
		</pelagios:AnnotatedThing>
		<!-- create annotations from pleiades URIs found in nomisma RDF and from findspots -->
		<xsl:for-each select="distinct-values($rdf//skos:related[contains(@rdf:resource, 'pleiades')]/@rdf:resource)">
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
		<xsl:apply-templates select="descendant::*:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::*:findspotDesc[string(@xlink:href)]" mode="pelagios">
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="count" select="count(distinct-values($rdf//skos:related[contains(@rdf:resource, 'pleiades')]/@rdf:resource))"/>
			<xsl:with-param name="date" select="$date"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nuds:nuds|nh:nudsHoard" mode="cidoc">
		<xsl:variable name="id" select="descendant::*[local-name()='recordId']"/>
		<xsl:text>(not yet developed)</xsl:text>
	</xsl:template>


	<!-- PROCESS NUDS RECORDS INTO NOMISMA COMPLIANT RDF MODELS -->
	<xsl:template match="nuds:nuds" mode="nomisma">
		<xsl:variable name="id" select="descendant::*[local-name()='recordId']"/>
		<xsl:choose>
			<xsl:when test="descendant::*:maintenanceStatus != 'new' and descendant::*:maintenanceStatus != 'derived' and descendant::*:maintenanceStatus != 'revised'">
				<xsl:variable name="element">
					<xsl:choose>
						<xsl:when test="@recordType='conceptual'">nmo:TypeSeriesItem</xsl:when>
						<xsl:when test="@recordType='physical'">nmo:NumismaticObject</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="{$element}">
					<xsl:attribute name="rdf:about">
						<xsl:value-of select="concat($uri_space, $id)"/>
					</xsl:attribute>
					<xsl:for-each select="descendant::*:semanticDeclaration">
						<xsl:namespace name="{*:prefix}" select="*:namespace"/>
					</xsl:for-each>
					<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
						<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
						<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
						<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
						<xsl:element name="{@semantic}" namespace="{$namespace}">
							<xsl:attribute name="rdf:resource" select="$uri"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="@recordType='conceptual'">
						<nmo:TypeSeriesItem rdf:about="{$uri_space}{$id}">
							<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
							<!-- insert titles -->
							<xsl:for-each select="descendant::nuds:descMeta/nuds:title">
								<skos:prefLabel>
									<xsl:if test="string(@xml:lang)">
										<xsl:attribute name="xml:lang" select="@xml:lang"/>
									</xsl:if>
									<xsl:value-of select="."/>
								</skos:prefLabel>
								<skos:definition>
									<xsl:if test="string(@xml:lang)">
										<xsl:attribute name="xml:lang" select="@xml:lang"/>
									</xsl:if>
									<xsl:value-of select="."/>
								</skos:definition>
							</xsl:for-each>
							<!-- source nmo:TypeSeries -->
							<dcterms:source rdf:resource="{//config/type_series}"/>
							<!-- other ids -->
							<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
								<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
								<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
								<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
								<xsl:element name="{@semantic}" namespace="{$namespace}">
									<xsl:attribute name="rdf:resource" select="$uri"/>
								</xsl:element>
							</xsl:for-each>
							<!-- process typeDesc -->
							<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc" mode="nomisma">
								<xsl:with-param name="id" select="$id"/>
							</xsl:apply-templates>
						</nmo:TypeSeriesItem>
						<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc/nuds:obverse|nuds:descMeta/nuds:typeDesc/nuds:reverse" mode="nomisma">
							<xsl:with-param name="id" select="$id"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="@recordType='physical'">
						<xsl:variable name="element">
							<xsl:variable name="objectType">
								<xsl:choose>
									<xsl:when test="string(nuds:descMeta/nuds:typeDesc/@xlink:href)">
										<xsl:value-of select="document(concat(nuds:descMeta/nuds:typeDesc/@xlink:href, '.xml'))/descendant::nuds:objectType/@xlink:href"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="descendant::nuds:objectType/@xlink:href"/>
									</xsl:otherwise>
								</xsl:choose>								
							</xsl:variable>
						</xsl:variable>
						
						<xsl:element name="nmo:NumismaticObject">
							<xsl:attribute name="rdf:about">
								<xsl:value-of select="concat($uri_space, $id)"/>
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
							<xsl:if test="nuds:control/nuds:maintenanceAgency/nuds:agencyName">
								<dcterms:publisher>
									<xsl:value-of select="nuds:control/nuds:maintenanceAgency/nuds:agencyName"/>
								</dcterms:publisher>
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
							<xsl:if test="string(nuds:descMeta/nuds:typeDesc/@xlink:href)">
								<nmo:hasTypeSeriesItem rdf:resource="{nuds:descMeta/nuds:typeDesc/@xlink:href}"/>
							</xsl:if>
							<!-- other ids -->
							<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
								<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
								<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
								<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
								<xsl:element name="{@semantic}" namespace="{$namespace}">
									<xsl:attribute name="rdf:resource" select="$uri"/>
								</xsl:element>
							</xsl:for-each>
							<!-- physical attributes -->
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc" mode="nomisma"/>
							<!-- findspot-->
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc" mode="nomisma"/>
							<xsl:if test="descendant::mets:fileGrp[@USE='obverse']">
								<nmo:hasObverse rdf:resource="{$uri_space}{$id}#obverse"/>
							</xsl:if>
							<xsl:if test="descendant::mets:fileGrp[@USE='reverse']">
								<nmo:hasReverse rdf:resource="{$uri_space}{$id}#reverse"/>
							</xsl:if>
						</xsl:element>
						<!-- images -->
						<xsl:apply-templates select="nuds:digRep/mets:fileSec" mode="nomisma">
							<xsl:with-param name="id" select="$id"/>
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mets:fileSec" mode="nomisma">
		<xsl:param name="id"/>

		<xsl:for-each select="mets:fileGrp">
			<xsl:variable name="side" select="@USE"/>
			<rdf:Description rdf:about="{$uri_space}{$id}#{$side}">
				<xsl:for-each select="mets:file">
					<xsl:choose>
						<xsl:when test="@USE='thumbnail'">
							<foaf:thumbnail>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="contains(mets:FLocat/@xlink:href, 'http://')">
											<xsl:value-of select="mets:FLocat/@xlink:href"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</foaf:thumbnail>
						</xsl:when>
						<xsl:when test="@USE='reference'">
							<foaf:depiction>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="contains(mets:FLocat/@xlink:href, 'http://')">
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
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:physDesc" mode="nomisma">
		<xsl:if test="nuds:axis">
			<nmo:hasAxis rdf:datatype="xsd:integer">
				<xsl:value-of select="nuds:axis"/>
			</nmo:hasAxis>
		</xsl:if>
		<xsl:for-each select="nuds:measurementsSet/*">
			<xsl:element name="nmo:has{concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))}">
				<xsl:attribute name="rdf:datatype">xsd:decimal</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:typeDesc" mode="nomisma">
		<xsl:param name="id"/>
		<xsl:if test="nuds:objectType[@xlink:href]">
			<nmo:hasObjectType rdf:resource="{nuds:objectType/@xlink:href}"/>
		</xsl:if>

		<xsl:apply-templates select="nuds:material|nuds:denomination|nuds:manufacture" mode="nomisma"/>
		<xsl:apply-templates select="nuds:geographic/nuds:geogname|nuds:authority/nuds:persname|nuds:authority/nuds:corpname" mode="nomisma"/>
		<xsl:apply-templates select="nuds:date[@standardDate]|nuds:dateRange[child::node()/@standardDate]" mode="nomisma"/>
		<xsl:if test="nuds:obverse">
			<nmo:hasObverse rdf:resource="{$uri_space}{$id}#obverse"/>
		</xsl:if>
		<xsl:if test="nuds:reverse">
			<nmo:hasReverse rdf:resource="{$uri_space}{$id}#reverse"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:obverse|nuds:reverse" mode="nomisma">
		<xsl:param name="id"/>
		<rdf:Description rdf:about="{$uri_space}{$id}#{local-name()}">			
			<xsl:apply-templates mode="nomisma"/>
		</rdf:Description>
	</xsl:template>
	
	<xsl:template match="nuds:legend" mode="nomisma">
		<nmo:hasLegend>
			<xsl:if test="string(@xml:lang)">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</nmo:hasLegend>
	</xsl:template>
	
	<xsl:template match="nuds:type/nuds:description" mode="nomisma">
		<dcterms:description>
			<xsl:if test="string(@xml:lang)">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</dcterms:description>
	</xsl:template>
	
	<!-- ignore symbol for now -->
	<xsl:template match="nuds:symbol" mode="nomisma"/>

	<xsl:template match="nuds:material|nuds:denomination|nuds:manufacture|nuds:geogname|nuds:persname|nuds:corpname" mode="nomisma">		
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="parent::nuds:obverse or parent::nuds:reverse">hasPortrait</xsl:when>
				<!-- ignore maker and artist -->
				<xsl:when test="@xlink:role='artist' or @xlink:role='maker'"/>
				<xsl:otherwise>
					<xsl:variable name="role" select="if (@xlink:role) then @xlink:role else local-name()"/>
					<xsl:value-of select="concat('has', concat(upper-case(substring($role, 1, 1)), substring($role, 2)))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($element) &gt; 0">
			<xsl:choose>
				<xsl:when test="string(@xlink:href)">
					<xsl:element name="nmo:{$element}">
						<xsl:attribute name="rdf:resource" select="@xlink:href"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="nmo:{$element}">
						<xsl:value-of select="."/>
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

	<xsl:template match="nuds:findspotDesc" mode="nomisma">
		<xsl:if test="string(@xlink:href)">
			<nmo:hasFindspot rdf:resource="{@xlink:href}"/>
		</xsl:if>
	</xsl:template>

	<!-- PROCESS NUDS-HOARD RECORDS INTO NOMISMA/METIS COMPLIANT RDF MODELS -->
	<xsl:template match="nh:nudsHoard" mode="nomisma">
		<xsl:variable name="id" select="descendant::*[local-name()='recordId']"/>
		<xsl:choose>
			<xsl:when test="descendant::*:maintenanceStatus != 'new' and descendant::*:maintenanceStatus != 'derived' and descendant::*:maintenanceStatus != 'revised'">
				<xsl:element name="nmo:Hoard">					
					<xsl:attribute name="rdf:about">
						<xsl:value-of select="concat($uri_space, $id)"/>
					</xsl:attribute>
					<xsl:for-each select="descendant::*:semanticDeclaration">
						<xsl:namespace name="{*:prefix}" select="*:namespace"/>
					</xsl:for-each>
					<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
						<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
						<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
						<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
						<xsl:element name="{@semantic}" namespace="{$namespace}">
							<xsl:attribute name="rdf:resource" select="$uri"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<nmo:Hoard rdf:about="{$uri_space}{$id}">					
					<xsl:choose>
						<xsl:when test="lang('en', descendant::nh:descMeta/nh:title)">
							<dcterms:title xml:lang="en">
								<xsl:value-of select="descendant::nh:descMeta/nh:title[@xml:lang='en']"/>
							</dcterms:title>
						</xsl:when>
						<xsl:otherwise>
							<dcterms:title xml:lang="en">
								<xsl:value-of select="descendant::nh:descMeta/nh:title[1]"/>
							</dcterms:title>
						</xsl:otherwise>
					</xsl:choose>
					<dcterms:publisher>
						<xsl:value-of select="descendant::nh:control/nh:maintenanceAgency/nh:agencyName"/>
					</dcterms:publisher>
					<!-- other ids -->
					<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
						<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
						<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
						<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
						<xsl:element name="{@semantic}" namespace="{$namespace}">
							<xsl:attribute name="rdf:resource" select="$uri"/>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
						<nmo:hasFindspot rdf:resource="{@xlink:href}"/>
					</xsl:for-each>
					
					<!-- closing date -->
					<xsl:choose>
						<xsl:when test="not(descendant::nh:deposit/nh:date) and not(descendant::nh:deposit/nh:dateRange)">
							<!-- get the nudsGroup to determine the closing date -->
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
												<xsl:if test="not(position()=last())">
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
										<xsl:if test="index-of(//config/certainty_codes/code[@accept='true'], @certainty)">
											<xsl:choose>
												<xsl:when test="string(@xlink:href)">
													<xsl:variable name="href" select="@xlink:href"/>
													<xsl:for-each select="$nudsGroup//object[@xlink:href=$href]/descendant::*/@standardDate">
														<xsl:if test="number(.)">
															<date>
																<xsl:choose>
																	<xsl:when test="number(.) &lt;= 0">
																		<xsl:value-of select="number(.) - 1"/>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="number(.)"/>
																	</xsl:otherwise>
																</xsl:choose>
															</date>
														</xsl:if>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:for-each select="descendant::*/@standardDate">
														<xsl:if test="number(.)">
															<date>
																<xsl:choose>
																	<xsl:when test="number(.) &lt;= 0">
																		<xsl:value-of select="number(.) - 1"/>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="number(.)"/>
																	</xsl:otherwise>
																</xsl:choose>
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
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="number(descendant::nh:deposit//@standardDate) &lt;= 0">
									<xsl:value-of select="number(descendant::nh:deposit//@standardDate) - 1"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="number(descendant::nh:deposit//@standardDate)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="descendant::nuds:typeDesc/@xlink:href|descendant::nuds:undertypeDesc/@xlink:href">
						<nmo:hasTypeSeriesItem rdf:resource="{.}"/>
					</xsl:for-each>
				</nmo:Hoard>

				<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
					<xsl:variable name="href" select="@xlink:href"/>
					<geo:SpatialThing rdf:about="{@xlink:href}">
						<xsl:if test="contains(@xlink:href, 'geonames.org')">
							<xsl:variable name="geonames-url">
								<xsl:text>http://api.geonames.org</xsl:text>
							</xsl:variable>
							<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
							<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
							<xsl:variable name="geonames_data" as="element()*">
								<xml>
									<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
								</xml>
							</xsl:variable>
							<geo:lat>
								<xsl:value-of select="$geonames_data//lat"/>
							</geo:lat>
							<geo:long>
								<xsl:value-of select="$geonames_data//lng"/>
							</geo:long>
							
							<!-- using foaf:name for the name of place -->
							<!-- generate AACR2 label -->
							<xsl:variable name="label">
								<xsl:variable name="countryCode" select="$geonames_data//countryCode"/>
								<xsl:variable name="countryName" select="$geonames_data//countryName"/>
								<xsl:variable name="name" select="$geonames_data//name"/>
								<xsl:variable name="adminName1" select="$geonames_data//adminName1"/>
								<xsl:variable name="fcode" select="$geonames_data//fcode"/>
								<!-- set a value equivalent to AACR2 standard for US, AU, CA, and GB.  This equation deviates from AACR2 for Malaysia since standard abbreviations for territories cannot be found -->
								<xsl:value-of
									select="if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then if ($fcode = 'ADM1') then $name else concat($name, ' (', $abbreviations//country[@code=$countryCode]/place[. = $adminName1]/@abbr, ')') else if ($countryCode= 'GB') then  if ($fcode = 'ADM1') then $name else concat($name, ' (', $adminName1, ')') else if ($fcode = 'PCLI') then $name else concat($name, ' (', $countryName, ')')"
								/>
							</xsl:variable>
							
							<foaf:name><xsl:value-of select="$label"/></foaf:name>
						</xsl:if>
					</geo:SpatialThing>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- *************** PELAGIOS OBJECT TEMPLATES ************** -->
	<xsl:template match="mets:fileSec" mode="pelagios">
		<xsl:for-each select="mets:fileGrp">
			<xsl:variable name="side" select="@USE"/>
			<xsl:for-each select="mets:file">
				<xsl:choose>
					<xsl:when test="@USE='thumbnail'">
						<foaf:thumbnail>
							<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="contains(mets:FLocat/@xlink:href, 'http://')">
										<xsl:value-of select="mets:FLocat/@xlink:href"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, mets:FLocat/@xlink:href)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</foaf:thumbnail>
					</xsl:when>
					<xsl:when test="@USE='reference'">
						<foaf:depiction>
							<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="contains(mets:FLocat/@xlink:href, 'http://')">
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

	<xsl:template match="*:geogname[@xlink:role='findspot']|*:findspotDesc" mode="pelagios">
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

	<!-- ********************** FUNCTIONS ********************** -->
	<xsl:function name="numishare:iso-to-digit">
		<xsl:param name="year"/>
		<xsl:choose>
			<xsl:when test="number($year) &lt;= 0">
				<xsl:value-of select="number($year) - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($year)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- place normalization variable -->
	<xsl:variable name="abbreviations" as="element()*">
		<abbreviations>
			<country code="US">
				<place abbr="Ala.">Alabama</place>
				<place abbr="Alaska">Alaska</place>
				<place abbr="Ariz.">Arizona</place>
				<place abbr="Ark.">Arkansas</place>
				<place abbr="Calif.">California</place>
				<place abbr="Colo.">Colorado</place>
				<place abbr="Conn.">Connecticut</place>
				<place abbr="Del.">Delaware</place>
				<place abbr="D.C.">Washington, D.C.</place>
				<place abbr="Fla.">Florida</place>
				<place abbr="Ga.">Georgia</place>
				<place abbr="Hawaii">Hawaii</place>
				<place abbr="Idaho">Idaho</place>
				<place abbr="Ill.">Illinois</place>
				<place abbr="Ind.">Indiana</place>
				<place abbr="Iowa">Iowa</place>
				<place abbr="Kans.">Kansas</place>
				<place abbr="Ky.">Kentucky</place>
				<place abbr="La.">Louisiana</place>
				<place abbr="Maine">Maine</place>
				<place abbr="Md.">Maryland</place>
				<place abbr="Mass.">Massachusetts</place>
				<place abbr="Mich.">Michigan</place>
				<place abbr="Minn.">Minnesota</place>
				<place abbr="Miss.">Mississippi</place>
				<place abbr="Mo.">Missouri</place>
				<place abbr="Mont.">Montana</place>
				<place abbr="Nebr.">Nebraska</place>
				<place abbr="Nev.">Nevada</place>
				<place abbr="N.H.">New Hampshire</place>
				<place abbr="N.J.">New Jersey</place>
				<place abbr="N.M.">New Mexico</place>
				<place abbr="N.Y.">New York</place>
				<place abbr="N.C.">North Carolina</place>
				<place abbr="N.D.">North Dakota</place>
				<place abbr="Ohio">Ohio</place>
				<place abbr="Okla.">Oklahoma</place>
				<place abbr="Oreg.">Oregon</place>
				<place abbr="Pa.">Pennsylvania</place>
				<place abbr="R.I.">Rhode Island</place>
				<place abbr="S.C.">South Carolina</place>
				<place abbr="S.D">South Dakota</place>
				<place abbr="Tenn.">Tennessee</place>
				<place abbr="Tex.">Texas</place>
				<place abbr="Utah">Utah</place>
				<place abbr="Vt.">Vermont</place>
				<place abbr="Va.">Virginia</place>
				<place abbr="Wash.">Washington</place>
				<place abbr="W.Va.">West Virginia</place>
				<place abbr="Wis.">Wisconsin</place>
				<place abbr="Wyo.">Wyoming</place>
				<place abbr="A.S.">American Samoa</place>
				<place abbr="Guam">Guam</place>
				<place abbr="M.P.">Northern Mariana Islands</place>
				<place abbr="P.R.">Puerto Rico</place>
				<place abbr="V.I.">U.S. Virgin Islands</place>
			</country>
			<country code="CA">
				<place abbr="Alta.">Alberta</place>
				<place abbr="B.C.">British Columbia</place>
				<place abbr="Alta.">Manitoba</place>
				<place abbr="Man.">Alberta</place>
				<place abbr="N.B.">New Brunswick</place>
				<place abbr="Nfld.">Newfoundland and Labrador</place>
				<place abbr="N.W.T.">Northwest Territories</place>
				<place abbr="N.S.">Nova Scotia</place>
				<place abbr="NU">Nunavut</place>
				<place abbr="Ont.">Ontario</place>
				<place abbr="P.E.I.">Prince Edward Island</place>
				<place abbr="Que.">Quebec</place>
				<place abbr="Sask.">Saskatchewan</place>
				<place abbr="Y.T.">Yukon</place>
			</country>
			<country code="AU">
				<place abbr="A.C.T.">Australian Capital Territory</place>
				<place abbr="J.B.T.">Jervis Bay Territory</place>
				<place abbr="N.S.W.">New South Wales</place>
				<place abbr="N.T.">Northern Territory</place>
				<place abbr="Qld.">Queensland</place>
				<place abbr="S.A.">South Australia</place>
				<place abbr="Tas.">Tasmania</place>
				<place abbr="Vic.">Victoria</place>
				<place abbr="W.A.">Western Australia</place>
			</country>
		</abbreviations>
	</xsl:variable>
</xsl:stylesheet>
