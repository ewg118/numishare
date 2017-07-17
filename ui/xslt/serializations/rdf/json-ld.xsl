<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2012 Martynas Jusevičius <martynas@graphity.org>
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
-->

<!-- ***** DEPLOYTMENT NOTES *****
	
	In July 2014, this stylesheet was imported from https://github.com/Graphity/graphity-browser/blob/master/src/main/webapp/static/org/graphity/client/xsl/rdfxml2json-ld.xsl
	Updates by Ethan Gruber.
-->


<!DOCTYPE uridef[
<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:gc="http://client.graphity.org/ontology#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="xs">
	<xsl:strip-space elements="*"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="/rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<xsl:key name="resources" match="*[*][@rdf:about] | *[*][@rdf:nodeID]" use="@rdf:about | @rdf:nodeID"/>
	<xsl:key name="properties" match="*[@rdf:about or @rdf:nodeID]/*" use="concat(namespace-uri(), local-name())"/>

	<xsl:template match="/">
		<xsl:variable name="model">
			<xsl:apply-templates mode="gc:JSONLDMode"/>
		</xsl:variable>

		<xsl:value-of select="normalize-space($model)"/>
	</xsl:template>

	<xsl:template match="rdf:RDF" mode="gc:JSONLDMode">
		<xsl:text>{ </xsl:text>
		<xsl:call-template name="context"/>
		<xsl:call-template name="graph"/>
		<xsl:text> }</xsl:text>
	</xsl:template>

	<xsl:template name="context">
		<xsl:text>"@context": { </xsl:text>
		<xsl:for-each select="$namespaces//namespace"> "<xsl:value-of select="@prefix"/>": "<xsl:value-of select="@uri"/>" <xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="descendant::geo:SpatialThing/osgeo:asGeoJSON">, "type": "@type", "geojson": "http://ld.geojson.org/vocab#", "Polygon": "geojson:Polygon", "Feature": "geojson:Feature",
			"MultiPoint": "geojson:MultiPoint", "Point": "geojson:Point", "FeatureCollection": "geojson:FeatureCollection", "GeometryCollection": "geojson:GeometryCollection", "LineString":
			"geojson:LineString", "MultiPolygon": "geojson:MultiPolygon", "geometry": "geojson:geometry", "features": { "@id": "geojson:coordinates", "@container": "@set" }, "coordinates": { "@id":
			"geojson:coordinates" } </xsl:if>
		<xsl:text>}, </xsl:text>
	</xsl:template>

	<xsl:template name="graph">
		<xsl:text>"@graph": [</xsl:text>
		<xsl:apply-templates mode="gc:JSONLDMode"/>
		<xsl:text> ]</xsl:text>
	</xsl:template>

	<!-- subject -->
	<xsl:template match="*[*][@rdf:about] | *[*][@rdf:nodeID]" mode="gc:JSONLDMode"> {<xsl:if test="@rdf:about">
			<xsl:apply-templates select="@rdf:about" mode="gc:JSONLDMode"/>, </xsl:if>
		<xsl:apply-templates select="." mode="PropertyListMode"/>}<xsl:if test="position() != last()">, </xsl:if>
	</xsl:template>

	<xsl:template match="*[*][@rdf:about] | *[*][@rdf:nodeID]" mode="PropertyListMode">
		<xsl:for-each-group select="*" group-by="name()">
			<!-- block osgeo:asGeoJSON from parsing in this way -->
			<xsl:choose>
				<xsl:when test="name()='osgeo:asGeoJSON'">
					<xsl:apply-templates select="current-group()" mode="gc:JSONLDMode"/>
					<xsl:if test="position() != last()">, </xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not(current-grouping-key() = '&rdf;type')"> "<xsl:value-of select="current-grouping-key()"/>" : [ <xsl:apply-templates select="current-group()" mode="gc:JSONLDMode"
						/>] <xsl:if test="position() != last()">, </xsl:if>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>

	<!-- handle geoJSON differently -->
	<xsl:template match="osgeo:asGeoJSON" mode="gc:JSONLDMode" priority="1"> "features": [{"geometry": <xsl:value-of select="."/> }] </xsl:template>

	<!-- property -->
	<xsl:template match="*[@rdf:about or @rdf:nodeID]/rdf:type" mode="gc:JSONLDMode" priority="1"> "<xsl:value-of select="@rdf:resource"/>" <xsl:if test="position() != last()">, </xsl:if>
	</xsl:template>

	<xsl:template match="*[@rdf:about or @rdf:nodeID]/*" mode="gc:JSONLDMode"> { <xsl:apply-templates select="node() | @rdf:resource | @rdf:nodeID" mode="gc:JSONLDMode"/> } <xsl:if
			test="position() != last()">, </xsl:if>
	</xsl:template>
	
	

	<xsl:template match="text()[. = 'true' or . = 'false'][../@rdf:datatype = '&xsd;boolean'] | text()[../@rdf:datatype = '&xsd;integer'] | text()[../@rdf:datatype = '&xsd;double']"
		mode="gc:JSONLDMode" priority="1"> "@value": <xsl:value-of select="."/>, <xsl:apply-templates select="../@rdf:datatype" mode="gc:JSONLDMode"/>
	</xsl:template>

	<xsl:template match="text()[../@rdf:datatype = '&xsd;string']" mode="gc:JSONLDMode" priority="1"> "@value": "<xsl:value-of select="replace(., '&#x022;', '\\&#x022;')"/>" </xsl:template>

	<xsl:template match="text()" mode="gc:JSONLDMode"> "@value": "<xsl:value-of select="replace(., '&#x022;', '\\&#x022;')"/>" <xsl:if test="../@rdf:datatype"> , <xsl:apply-templates select="../@rdf:datatype" mode="gc:JSONLDMode"/>
		</xsl:if>
		<xsl:if test="../@xml:lang"> , <xsl:apply-templates select="../@xml:lang" mode="gc:JSONLDMode"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@rdf:about | @rdf:resource" mode="gc:JSONLDMode">
		<xsl:text>"@id": "</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
		<!-- handle @type -->
		<xsl:if test="name()='rdf:about'">
			<xsl:variable name="types" as="element()*">
				<types>
					<xsl:if test="parent::node()/name() != 'rdf:Description'">
						<type>
							<xsl:value-of select="parent::node()/name()"/>
						</type>
					</xsl:if>
					<xsl:if test="(parent::node()/name()='geo:SpatialThing' or parent::node()/rdf:type[contains(@rdf:resource, 'SpatialThing')]) and parent::node()/osgeo:asGeoJSON">
						<type>FeatureCollection</type>
					</xsl:if>
					<xsl:for-each select="parent::node()/rdf:type">
						<type>
							<xsl:value-of select="@rdf:resource"/>
						</type>
					</xsl:for-each>
				</types>
			</xsl:variable>
			<xsl:if test="count($types/type) &gt; 0">
				<xsl:text>, "@type": [</xsl:text>
				<xsl:for-each select="$types/type"> "<xsl:value-of select="."/>" <xsl:if test="not(position()=last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@rdf:nodeID" mode="gc:JSONLDMode"/>

	<xsl:template match="*[@rdf:about or @rdf:nodeID]/*/@rdf:nodeID" mode="gc:JSONLDMode">
		<xsl:apply-templates select="key('resources', .)[not(@rdf:nodeID = current()/../../@rdf:nodeID)]" mode="PropertyListMode"/>
	</xsl:template>

	<xsl:template match="@rdf:datatype" mode="gc:JSONLDMode"> "@type": "<xsl:value-of select="."/>" </xsl:template>

	<xsl:template match="@xml:lang" mode="gc:JSONLDMode"> "@language": "<xsl:value-of select="."/>" </xsl:template>

</xsl:stylesheet>
