<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: March 2026
	Function: Serialize RDF/XML that conforms to Linked Art CIDOC-CRM into JSON-LD according to the profile -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" xmlns:la="https://linked.art/ns/terms/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">

	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- get Nomisma RDF if applicable -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">

			<!-- aggregate distinct Nomisma URIs and perform an API lookup to get the RDF for all of them -->
			<xsl:variable name="id-param">
				<xsl:for-each
					select="distinct-values(descendant::*[contains(@rdf:resource, 'nomisma.org')]/@rdf:resource)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="id-url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>

			<xsl:if test="doc-available($id-url)">
				<xsl:copy-of select="document($id-url)/rdf:RDF/*"/>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<xsl:apply-templates select="rdf:RDF/la:Set"/>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="la:Set">
		<__context>https://linked.art/ns/v1/linked-art.json</__context>
		<id>
			<xsl:value-of select="@rdf:about"/>
		</id>
		<type>Set</type>
		<_label>
			<xsl:value-of select="rdfs:label"/>
		</_label>
		
		<xsl:if test="crm:P1_is_identified_by">
			<identified_by>
				<_array>
					<xsl:apply-templates select="crm:P1_is_identified_by/crm:E33_E41_Linguistic_Appellation"/>
				</_array>
			</identified_by>
		</xsl:if>
		
		<xsl:apply-templates select="la:members_exemplified_by"/>
	</xsl:template>

	<!-- names -->
	<xsl:template match="crm:E33_E41_Linguistic_Appellation">
		<xsl:variable name="type" select="crm:P2_has_type/@rdf:resource"/>

		<_object>
			<type>Name</type>
			<content>
				<xsl:value-of select="crm:P190_has_symbolic_content"/>
			</content>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="$type"/>
						</id>
						<type>Type</type>
						<_label>
							<xsl:choose>
								<xsl:when test="$type = 'http://vocab.getty.edu/aat/300404670'">
									<xsl:text>Primary Name</xsl:text>
								</xsl:when>
								<xsl:when test="$type = 'http://vocab.getty.edu/aat/300404628'">
									<xsl:text>Lot Number</xsl:text>
								</xsl:when>
							</xsl:choose>
						</_label>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<!-- generalized set description -->
	<xsl:template match="la:members_exemplified_by">
		<members_exemplified_by>
			<_array>
				<xsl:apply-templates select="crm:E22_Human-Made_Object"/>
			</_array>
		</members_exemplified_by>
	</xsl:template>

	<xsl:template match="crm:E22_Human-Made_Object">
		<_object>
			<type>HumanMadeObject</type>

			<!-- provenance -->
			<xsl:apply-templates select="crm:P24i_changed_ownership_through/crm:E8_Acquisition"/>

			<!-- contents -->
			<xsl:if test="crm:P43_has_dimension">
				<dimension>
					<_array>
						<xsl:apply-templates select="crm:P43_has_dimension/crm:E54_Dimension"/>
					</_array>
				</dimension>
			</xsl:if>
		</_object>
	</xsl:template>

	<!-- provenance -->
	<xsl:template match="crm:E8_Acquisition">
		<changed_ownership_through>
			<_array>
				<_object>
					<type>Acquisition</type>
					<xsl:apply-templates select="crm:P2_has_type" mode="acquisition"/>
					<xsl:apply-templates select="crm:P4_has_time-span/crm:E52_Time-Span"/>
					
					<xsl:if test="crm:P22_transferred_title_to">
						<transferred_title_to>
							<_array>
								<xsl:apply-templates select="crm:P22_transferred_title_to"/>
							</_array>
						</transferred_title_to>
					</xsl:if>
					<xsl:if test="crm:P23_transferred_title_from">
						<transferred_title_from>
							<_array>
								<xsl:apply-templates select="crm:P23_transferred_title_from"/>
							</_array>
						</transferred_title_from>
					</xsl:if>
					<xsl:apply-templates
						select="crm:P67i_is_referred_to_by/crm:E33_Linguistic_Object"/>
				</_object>
			</_array>
		</changed_ownership_through>


	</xsl:template>

	<xsl:template match="crm:P2_has_type" mode="acquisition">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<classified_as>
			<_array>
				<xsl:apply-templates select="//crm:E55_Type[@rdf:about = $uri]"/>
			</_array>
		</classified_as>
	</xsl:template>

	<!-- transfers between entities -->
	<xsl:template match="crm:P22_transferred_title_to | crm:P23_transferred_title_from">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="//*[@rdf:about = $uri] | $rdf//*[@rdf:about = $uri]"/>
	</xsl:template>

	<xsl:template match="crm:E21_Person | crm:E74_Group | nmo:Collection">
		<_object>
			<id>
				<xsl:value-of select="@rdf:about"/>
			</id>
			<type>
				<xsl:choose>
					<xsl:when test="name() = 'crm:E21_Person'">Person</xsl:when>
					<xsl:otherwise>Group</xsl:otherwise>
				</xsl:choose>
			</type>
			<_label>
				<xsl:choose>
					<xsl:when test="rdfs:label">
						<xsl:value-of select="rdfs:label"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</_label>
			<xsl:if test="skos:exactMatch | la:equivalent">
				<equivalent>
					<_array>
						<xsl:apply-templates select="skos:exactMatch | la:equivalent"/>
					</_array>
				</equivalent>
			</xsl:if>

		</_object>
	</xsl:template>

	<xsl:template match="skos:exactMatch | la:equivalent">
		<_object>
			<id>
				<xsl:value-of select="@rdf:resource"/>
			</id>
		</_object>
	</xsl:template>

	<xsl:template match="crm:E54_Dimension">
		<_object>
			<type>Dimension</type>

			<xsl:if test="crm:P90_has_value">
				<value>
					<xsl:value-of select="crm:P90_has_value"/>
				</value>
			</xsl:if>

			<xsl:if test="crm:P2_has_type">
				<classified_as>
					<_array>
						<xsl:apply-templates select="crm:P2_has_type/crm:E55_Type"/>
					</_array>
				</classified_as>
			</xsl:if>

		</_object>
	</xsl:template>

	<!-- acknowledgement statement -->
	<xsl:template match="crm:E33_Linguistic_Object">
		<referred_to_by>
			<_array>
				<_object>
					<type>LinguisticObject</type>
					<content>
						<xsl:value-of select="crm:P190_has_symbolic_content"/>
					</content>
					<classified_as>
						<_array>
							<_object>
								<id>
									<xsl:value-of select="crm:P2_has_type/@rdf:resource"/>
								</id>
								<type>Type</type>
								<_label>Acknowledgement Statement</_label>
							</_object>
						</_array>
					</classified_as>
				</_object>
			</_array>
		</referred_to_by>
	</xsl:template>

	<xsl:template match="crm:E52_Time-Span">
		<timespan>
			<_object>
				<type>TimeSpan</type>
				<begin_of_the_begin>
					<xsl:value-of select="crm:P82a_begin_of_the_begin"/>
				</begin_of_the_begin>
				<end_of_the_end>
					<xsl:value-of select="crm:P82b_end_of_the_end"/>
				</end_of_the_end>
			</_object>
		</timespan>
	</xsl:template>

	<!-- general representation of types -->
	<xsl:template match="crm:E55_Type">
		<_object>
			<xsl:if test="@rdf:about">
				<id>
					<xsl:value-of select="@rdf:about"/>
				</id>
			</xsl:if>
			<type>Type</type>
			<_label>
				<xsl:value-of select="rdfs:label"/>
			</_label>
			<xsl:if test="crm:P2_has_type[@rdf:resource]">
				<classified_as>
					<_array>
						<_object>
							<id>
								<xsl:value-of select="crm:P2_has_type/@rdf:resource"/>
							</id>
						</_object>
					</_array>
				</classified_as>
			</xsl:if>
		</_object>
	</xsl:template>

</xsl:stylesheet>
