<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: April 2019
	Function: Serialize the Solr query for the ajax results on the maps pages into HTML, calling the numishareResults pipelines for
		coin type corpora, if applicable
-->
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
		<p:input name="config" href="../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- conditional to evaluate the type of collection -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				
				<xsl:template match="/">
					<collection_type>
						<xsl:if test="matches(/config/sparql_endpoint, '^https?://')">
							<xsl:attribute name="sparql_endpoint" select="/config/sparql_endpoint"/>
						</xsl:if>
						
						<xsl:value-of select="/config/collection_type"/>
					</collection_type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collection_type"/>
	</p:processor>
	
	<p:choose href="#collection_type">
		<p:when test="collection_type='cointype' and string(collection_type/@sparql_endpoint)">
			<!-- evaluate the SPARQL endpoint URL to use a Nomisma API or internal one -->
			<p:choose href="#collection_type">
				<p:when test="collection_type/@sparql_endpoint='http://nomisma.org/query'">
					<!-- create the URL Generator config in order to execute an API call to Nomisma -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="config-xml" href="#config"/>
						<p:input name="data" href="#data"/>
						
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
								
								<xsl:template match="/">
									<xsl:variable name="service">
										<xsl:choose>
											<xsl:when test="doc('input:config-xml')/config/union_type_catalog/@enabled = true()">
												<xsl:variable name="identifiers" as="node()*">
													<identifiers>
														<xsl:for-each select="descendant::doc">
															<identifier>
																<xsl:value-of select="concat(str[@name='uri_space'], str[@name='recordId'])"/>
															</identifier>
														</xsl:for-each>
													</identifiers>
												</xsl:variable>
												
												<xsl:value-of
													select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri(string-join($identifiers//identifier, '|')))"
												/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="uri_space" select="doc('input:config-xml')/config/uri_space"/>
												
												<xsl:value-of
													select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri(string-join(descendant::str[@name='recordId'], '|')), '&amp;baseUri=',
													encode-for-uri($uri_space))"
												/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									
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
						<p:output name="data" id="numishareResults-url-generator-config"/>
					</p:processor>
					
					<!-- query Nomisma numishareResults API -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#numishareResults-url-generator-config"/>
						<p:output name="data" id="numishareResults"/>
					</p:processor>
					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="numishareResults" href="#numishareResults"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../ui/xslt/ajax/results_ajax.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<!-- execute series of local SPARQL queries and aggregate into XML model -->
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../models/sparql/numishareResults.xpl"/>
						<p:output name="data" id="sparqlResults"/>
					</p:processor>
					
					<!-- serialize aggregated SPARQL model into a simple, digestible XML document that can be transformed more easily into HTML
						snippets for related images and speciment/hoard count -->
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#sparqlResults"/>
						<p:input name="config" href="../../views/serializations/sparql/numishareResults.xpl"/>
						<p:output name="data" id="numishareResults"/>
					</p:processor>
					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="numishareResults" href="#numishareResults"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../ui/xslt/ajax/results_ajax.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:when test="collection_type='cointype' and not(string(collection_type/@sparql_endpoint))">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>		
				<p:input name="config" href="../../../ui/xslt/ajax/results_ajax.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>		
				<p:input name="config" href="../../../ui/xslt/ajax/results_ajax.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
	
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
