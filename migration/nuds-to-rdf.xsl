<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl nuds nh xlink mets" xmlns:exsl="http://exslt.org/common"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:georss="http://www.georss.org/georss" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oac="http://www.openannotation.org/ns/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:dc="http://purl.org/dc/terms/" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:mets="http://www.loc.gov/METS/" version="2.0">
	<xsl:output method="xml" encoding="utf-8" indent="yes"/>
	<xsl:param name="url">http://numismatics.org/ocre/</xsl:param>	

	<xsl:template match="/">
		<rdf:RDF xmlns:dc="http://purl.org/dc/terms/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:georss="http://www.georss.org/georss"
			xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oac="http://www.openannotation.org/ns/" xmlns:gml="http://www.opengis.net/gml/" xmlns:owl="http://www.w3.org/2002/07/owl#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			
			<xsl:for-each select="collection('file:///home/komet/ans_migration/ocre/objects/?select=*.xml')">				
				<xsl:apply-templates select="document(document-uri(.))/nuds:nuds" mode="nomisma"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>
	
	<!-- PROCESS NUDS RECORDS INTO NOMISMA/METIS COMPLIANT RDF MODELS -->
	<xsl:template match="nuds:nuds" mode="nomisma">
		<xsl:variable name="id" select="descendant::*[local-name()='recordId']"/>
		
		<xsl:choose>
			<xsl:when test="@recordType='conceptual'">
				<nm:type_series_item rdf:about="{$url}id/{$id}">
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
					<dcterms:isPartOf rdf:resource="http://nomisma.org/id/ric"/>					
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
					<xsl:apply-templates select="nuds:descMeta/nuds:typeDesc" mode="nomisma"/>					
				</nm:type_series_item>
			</xsl:when>
			<xsl:when test="@recordType='physical'">
				<nm:coin rdf:about="{$url}id/{$id}">
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
						<nm:collection>
							<xsl:choose>
								<xsl:when test="string(@xlink:href)">
									<xsl:attribute name="rdf:resource" select="@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</nm:collection>
					</xsl:for-each>
					<xsl:if test="string(nuds:descMeta/nuds:typeDesc/@xlink:href)">
						<nm:type_series_item rdf:resource="{nuds:descMeta/nuds:typeDesc/@xlink:href}"/>
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
					
					<!-- images -->
					<xsl:apply-templates select="nuds:digRep/mets:fileSec" mode="nomisma"/>
				</nm:coin>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="mets:fileSec" mode="nomisma">
		<xsl:for-each select="mets:fileGrp">
			<xsl:variable name="side" select="@USE"/>
			
			<xsl:for-each select="mets:file">
				<xsl:variable name="element" select="concat($side, concat(upper-case(substring(@USE, 1, 1)), substring(@USE, 2)))"/>
				
				<xsl:element name="nm:{$element}">
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
				</xsl:element>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="nuds:physDesc" mode="nomisma">
		<xsl:if test="nuds:axis">
			<nm:axis rdf:datatype="xs:integer">
				<xsl:value-of select="nuds:axis"/>
			</nm:axis>
		</xsl:if>
		
		<xsl:for-each select="nuds:measurementsSet/*">
			<xsl:element name="nm:{local-name()}">
				<xsl:attribute name="rdf:datatype">xs:decimal</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="nuds:typeDesc" mode="nomisma">
		<xsl:if test="nuds:objectType[@xlink:href]">
			<nm:object_type rdf:resource="{nuds:objectType/@xlink:href}"/>
		</xsl:if>
		
		<xsl:if test="nuds:obverse">
			<nm:obverse>
				<rdf:Description>
					<xsl:apply-templates select="nuds:obverse" mode="nomisma"/>
				</rdf:Description>
			</nm:obverse>
		</xsl:if>
		<xsl:if test="nuds:reverse">
			<nm:obverse>
				<rdf:Description>
					<xsl:apply-templates select="nuds:reverse" mode="nomisma"/>
				</rdf:Description>
			</nm:obverse>
		</xsl:if>
		
		<xsl:apply-templates select="nuds:material|nuds:denomination|nuds:manufacture" mode="nomisma"/>
		<xsl:apply-templates select="descendant::nuds:geogname|descendant::nuds:persname|descendant::nuds:corpname" mode="nomisma"/>
		<xsl:apply-templates select="nuds:date[@standardDate]|nuds:dateRange[child::node()/@standardDate]" mode="nomisma"/>
	</xsl:template>
	
	<xsl:template match="nuds:obverse|nuds:reverse" mode="nomisma">
		<xsl:if test="nuds:legend">
			<nm:legend>
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="nuds:legend"/>
			</nm:legend>
		</xsl:if>
		<xsl:for-each select="nuds:type/nuds:description">
			<nm:description>
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="."/>
			</nm:description>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="nuds:material|nuds:denomination|nuds:manufacture|nuds:geogname|nuds:persname|nuds:corpname" mode="nomisma">
		<xsl:variable name="element" select="if (@xlink:role) then @xlink:role else local-name()"/>
		
		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:element name="nm:{$element}">
					<xsl:attribute name="rdf:resource" select="@xlink:href"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="nm:{$element}">
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="nuds:date" mode="nomisma">
		<nm:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="@standardDate"/>
		</nm:start_date>
		<nm:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="@standardDate"/>
		</nm:end_date>
		
	</xsl:template>
	
	<xsl:template match="nuds:dateRange" mode="nomisma">
		<nm:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="nuds:fromDate/@standardDate"/>
		</nm:start_date>
		<nm:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="nuds:toDate/@standardDate"/>
		</nm:end_date>
	</xsl:template>

</xsl:stylesheet>
