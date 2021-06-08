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

	<xsl:template match="res:result">
		<_object>
			<type>Feature</type>
			<label>
				<xsl:choose>
					<xsl:when test="res:binding[@name = 'findspotLabel']">
						<xsl:value-of select="res:binding[@name = 'findspotLabel']/res:literal"/>
					</xsl:when>
					<xsl:when test="res:binding[@name = 'hoardLabel']">
						<xsl:value-of select="res:binding[@name = 'hoardLabel']/res:literal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
					</xsl:otherwise>
				</xsl:choose>
			</label>

			<xsl:choose>
				<xsl:when test="res:binding[@name = 'hoard']">
					<id>
						<xsl:value-of select="res:binding[@name = 'hoard']/res:uri"/>
					</id>
				</xsl:when>				
				<xsl:when test="res:binding[@name = 'findspot']">
					<id>
						<xsl:choose>
							<xsl:when test="res:binding[@name = 'findspot']/res:uri">
								<xsl:value-of select="res:binding[@name = 'findspot']/res:uri"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="res:binding[@name = 'findspot']/res:bnode"/>
							</xsl:otherwise>
						</xsl:choose>
					</id>
				</xsl:when>
			</xsl:choose>


			<xsl:choose>
				<xsl:when test="res:binding[@name = 'geojson']">
					<geometry datatype="osgeo:asGeoJSON">
						<xsl:value-of select="res:binding[@name = 'geojson']/res:literal"/>
					</geometry>
				</xsl:when>
				<xsl:when test="res:binding[@name = 'long'] and res:binding[@name = 'lat']">
					<geometry>
						<_object>
							<type>Point</type>
							<coordinates>
								<_array>
									<_>
										<xsl:choose>
											<xsl:when test="res:binding[@name = 'findspotLong']">
												<xsl:value-of select="res:binding[@name = 'findspotLong']/res:literal"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="res:binding[@name = 'long']/res:literal"/>
											</xsl:otherwise>
										</xsl:choose>
									</_>
									<_>
										<xsl:choose>
											<xsl:when test="res:binding[@name = 'findspotLat']">
												<xsl:value-of select="res:binding[@name = 'findspotLat']/res:literal"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="res:binding[@name = 'lat']/res:literal"/>
											</xsl:otherwise>
										</xsl:choose>
									</_>
								</_array>
							</coordinates>
						</_object>
					</geometry>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="res:binding[@name = 'closingDate']">
				<when>
					<_object>
						<start>
							<xsl:value-of select="numishare:xsdToIso(res:binding[@name = 'closingDate']/res:literal)"/>
						</start>
						<end>
							<xsl:value-of select="numishare:xsdToIso(res:binding[@name = 'closingDate']/res:literal)"/>
						</end>
					</_object>
				</when>
			</xsl:if>
			<properties>
				<_object>
					<toponym>
						<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
					</toponym>
					<gazetteer_label>
						<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
					</gazetteer_label>
					
					<gazetteer_uri>
						<xsl:choose>
							<xsl:when test="res:binding[@name = 'mint']">
								<xsl:value-of select="res:binding[@name = 'mint']/res:uri"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="res:binding[@name = 'place']/res:uri"/>
							</xsl:otherwise>
						</xsl:choose>						
					</gazetteer_uri>
					
					<xsl:choose>
						<xsl:when test="res:binding[@name = 'hoard']">
							<type>hoard</type>
						</xsl:when>
						<xsl:when test="res:binding[@name = 'mint']">
							<type>mint</type>
						</xsl:when>
						<xsl:otherwise>
							<type>findspot</type>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="res:binding[@name = 'closingDate']">
						<closing_date>
							<xsl:value-of select="numishare:normalizeDate(res:binding[@name = 'closingDate']/res:literal)"/>
						</closing_date>
					</xsl:if>

					<xsl:if test="res:binding[@name = 'count']">
						<count>
							<xsl:value-of select="res:binding[@name = 'count']/res:literal"/>
						</count>
					</xsl:if>
				</_object>
			</properties>
		</_object>
	</xsl:template>

</xsl:stylesheet>
