<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: June 2021
	Function: Serialize three SPARQL results for mints, findspots, and hoards associated with a symbol into GeoJSON -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xxf="http://www.orbeon.com/oxf/pipeline"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gml="http://www.opengis.net/gml" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:nm="http://nomisma.org/id/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
	xmlns:crmgeo="http://www.ics.forth.gr/isl/CRMgeo/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:digest="org.apache.commons.codec.digest.DigestUtils" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="geojson-templates.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<features>
					<_array>
						<xsl:apply-templates select="doc('input:mints')//res:result"/>
						<xsl:apply-templates select="doc('input:hoards')//res:result"/>
						<xsl:apply-templates select="doc('input:findspots')//res:result"/>
					</_array>
				</features>
			</_object>
		</xsl:variable>
		
		<xsl:apply-templates select="$model"/>
	</xsl:template>

</xsl:stylesheet>
