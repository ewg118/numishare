<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<collection-type>
						<xsl:value-of select="/config/collection_type"/>
					</collection-type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collection-type-config"/>
	</p:processor>

	<p:choose href="#collection-type-config">
		<p:when test="collection-type='cointype'">
			<!-- get symbols RDF from XQuery -->
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../models/xquery/aggregate-symbols.xpl"/>
				<p:output name="data" id="symbols"/>
			</p:processor>

			<!-- only aggregate symbols with types when there are symbol URIs -->
			<p:choose href="#symbols">
				<p:when test="count(rdf:RDF/*) &gt; 0">
					<!-- aggregate all NUDS documents and pipe through XSLT into RDF -->
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../models/xquery/aggregate-all.xpl"/>
						<p:output name="data" id="nuds"/>
					</p:processor>

					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #nuds, #config)"/>		
						<p:input name="config" href="../../ui/xslt/serializations/object/rdf.xsl"/>
						<p:output name="data" id="types"/>		
					</p:processor>

					<p:processor name="oxf:unsafe-xslt">
						<p:input name="data" href="aggregate('content', #symbols, #types)"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
								<xsl:output indent="yes" encoding="UTF-8"/>
								<xsl:template match="/">
									<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
										xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
										xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
										xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
										xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:org="http://www.w3.org/ns/org#" xmlns:rdac="http://www.rdaregistry.info/Elements/c/"
										xmlns:bio="http://purl.org/vocab/bio/0.1/">
										<xsl:copy-of select="descendant::rdf:RDF/*"/>
									</rdf:RDF>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<!-- aggregate all NUDS documents and pipe through XSLT into RDF -->
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../models/xquery/aggregate-all.xpl"/>
						<p:output name="data" id="model"/>
					</p:processor>

					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../views/serializations/object/rdf.xpl"/>
						<p:input name="data" href="#model"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
						<!-- config variables -->
						<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>

						<xsl:variable name="service">
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name,
								'+AND+NOT(lang:*)+AND+coinType_uri:*&amp;rows=100000&amp;fl=id,recordId,title_display,coinType_uri,objectType_uri,recordType,publisher_display,axis_num,diameter_num,height_num,width_num,taq_num,weight_num,thumbnail_obv,reference_obv,thumbnail_rev,reference_rev,findspot_uri,findspot_geo,collection_uri,hoard_uri&amp;mode=nomisma')"
							/>
						</xsl:variable>

						<xsl:template match="/">
							<config>
								<url>
									<xsl:value-of select="$service"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="generator-config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#generator-config"/>
				<p:output name="data" id="model"/>
			</p:processor>

			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#model"/>
				<p:input name="config" href="../views/serializations/solr/rdf.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
