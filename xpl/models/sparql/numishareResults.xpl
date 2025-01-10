<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: January 2025
	Function: Execute a series of SPARQL queries to get the count and sample images for each identifier listed in the Solr-based browse page and subtypes on type record pages.
		This is intended to be used when the SPARQL endpoint defined in the config differs from Nomisma.org	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/numishareResults-count.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="numishareResults-count"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#numishareResults-count"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="numishareResults-count-document"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/numishareResults-specimens.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="numishareResults-specimens"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#numishareResults-specimens"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="numishareResults-specimens-document"/>
	</p:processor>
	
	<!-- evaluate the Solr results and use Solr recordId fields and optional uri spaces -->	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:template match="/">
					<identifiers>
						<xsl:choose>
							<xsl:when test="doc('input:config-xml')/config/union_type_catalog/@enabled = true()">
								<xsl:for-each select="descendant::doc">
									<identifier>
										<xsl:value-of select="concat(str[@name='uri_space'], str[@name='recordId'])"/>
									</identifier>
								</xsl:for-each>								
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="uri_space" select="doc('input:config-xml')/config/uri_space"/>

								<!-- evaluate Solr docs vs subtype elements -->								
								<xsl:choose>
									<xsl:when test="count(descendant::doc) &gt; 0">
										<xsl:for-each select="descendant::doc">
											<identifier>
												<xsl:value-of select="concat($uri_space, str[@name='recordId'])"/>
											</identifier>
										</xsl:for-each>
									</xsl:when>
									<xsl:when test="count(descendant::subtype) &gt; 0">
										<xsl:for-each select="descendant::subtype">
											<identifier>
												<xsl:value-of select="concat($uri_space, @recordId)"/>
											</identifier>
										</xsl:for-each>
									</xsl:when> 
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</identifiers>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="identifiers"/>
	</p:processor>
	
	<p:for-each href="#identifiers" select="//identifier" root="response" id="response">
		<p:processor name="oxf:identity">
			<p:input name="data" href="current()"/>
			<p:output name="data" id="id"/>
		</p:processor>
		
		<!-- execute SPARQL for hoard/object counts -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="config-xml" href=" #config"/>
			<p:input name="data" href="current()"/>
			<p:input name="query" href="#numishareResults-count-document"/>
			
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
					<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_endpoint"/>
					<xsl:variable name="query" select="doc('input:query')"/>
					
					<xsl:template match="/">
						<xsl:variable name="uri" select="."/>
						<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
						
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
			<p:output name="data" id="count-url-generator-config"/>
		</p:processor>
		
		<!-- query SPARQL -->
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#count-url-generator-config"/>
			<p:output name="data" id="counts"/>
		</p:processor>
		
		<!-- execute SPARQL query for images -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="config-xml" href=" #config"/>
			<p:input name="data" href="current()"/>
			<p:input name="query" href="#numishareResults-specimens-document"/>
			
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">	
					<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_endpoint"/>
					<xsl:variable name="query" select="doc('input:query')"/>
					
					<xsl:template match="/">
						<xsl:variable name="uri" select="."/>
						<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
						
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
			<p:output name="data" id="images-url-generator-config"/>
		</p:processor>
		
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#images-url-generator-config"/>
			<p:output name="data" id="images"/>
		</p:processor>
		
		<p:processor name="oxf:identity">
			<p:input name="data" href="aggregate('content', #id, #counts, #images)"/>
			<p:output name="data" ref="response"/>
		</p:processor>				
	</p:for-each>
	
	<!-- return aggregated SPARQL/XML response -->
	<p:processor name="oxf:identity">
		<p:input name="data" href="#response"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
