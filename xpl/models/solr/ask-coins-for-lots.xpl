<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: March 2026
	Function: Submit Solr query to find the number of coins in a lot as well as determine whether there are associated geographic facets for visualization -->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="request" href="#request"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
				xmlns:la="https://linked.art/ns/terms/">
				<xsl:variable name="collection-name"
					select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>

				<!-- if the #data being passed into the pipeline is the aggregated XQuery response for sets related to entity URIs, then combine the set query in Solr -->
				<xsl:variable name="query">
					<xsl:choose>
						<xsl:when test="//la:Set">
							<xsl:variable name="lots">
								<xsl:for-each select="//la:Set">
									<xsl:value-of select="concat(rdfs:label, '.*')"/>
									<xsl:if test="not(position() = last())">
										<xsl:text> OR </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							
							<xsl:value-of select="concat('(', $lots, ')')"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- otherwise, we are creating a query for the lot on the landing page for the lot -->
							
							<xsl:variable name="lot"
								select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>
							
							<xsl:value-of select="concat($lot, '.*')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- include regular search facets for populating visualization distribution categories -->
				<xsl:variable name="facets">
					<xsl:text>&amp;facet.field=</xsl:text>
					<xsl:value-of select="string-join(doc('input:config-xml')/config/facets/facet, '&amp;facet.field=')"/>
				</xsl:variable>

				<!-- config variables -->
				<xsl:variable name="solr-url"
					select="concat(doc('input:config-xml')/config/solr_published, 'select/')"/>

				<xsl:variable name="service"
					select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+recordId:', encode-for-uri($query), '&amp;rows=0&amp;facet=true&amp;facet.limit=1', $facets, '&amp;facet.field=productionPlace_geo&amp;facet.field=mint_geo&amp;facet.field=issuePlace_geo&amp;facet.field=subject_geo&amp;facet.field=findspot_geo&amp;facet.field=hoard_geo')"/>

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
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
