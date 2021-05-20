<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: April 2021
	Function: transform EpiDoc TEI into RDF conforming to the Nomisma ontology -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:gml="http://www.opengis.net/gml"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#"
	xmlns:void="http://rdfs.org/ns/void#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:crmsci="http://www.ics.forth.gr/isl/CRMsci/" xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/"
	xmlns:crmarchaeo="http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/" xmlns:relations="http://pelagios.github.io/vocab/relations#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#"
	xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="xs xsl nuds nh tei xlink gml numishare" version="2.0">

	<xsl:template match="tei:TEI" mode="nomisma">
		<xsl:variable name="id" select="descendant::tei:idno[@type='filename']"/>
		
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
				<xsl:value-of select="//tei:titleStmt/tei:title"/>
			</dcterms:title>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
