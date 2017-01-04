<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2014 Ethan Gruber
	Numishare
	Apache License 2.0
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">
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
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<recordType>
						<xsl:choose>
							<xsl:when test="*/namespace-uri()='http://nomisma.org/nudsHoard'">hoard</xsl:when>
							<xsl:when test="*/@recordType='conceptual'">conceptual</xsl:when>
							<xsl:when test="*/@recordType='physical'">physical</xsl:when>
						</xsl:choose>
					</recordType>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="recordType"/>
	</p:processor>
	
	<p:choose href="#recordType">
		<p:when test="recordType='hoard'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../../../models/solr/get_hoards.xpl"/>
				<p:output name="data" id="get_hoards-model"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#get_hoards-model"/>		
				<p:input name="config" href="../../../../ui/xslt/ajax/get_hoards.xsl"/>
				<p:output name="data" id="get_hoards-view"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../../../models/xquery/get_certainty_codes.xpl"/>
				<p:output name="data" id="codes-model"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#codes-model"/>
				<p:input name="config" href="../../../views/ajax/get_certainty_codes.xpl"/>
				<p:output name="data" id="codes-view"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config, #get_hoards-view, #codes-view)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
				<p:output name="data" id="model"/>				
			</p:processor>
		</p:when>
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="recordType='conceptual'">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-types.xpl"/>
				<p:output name="data" id="hasTypes"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-findspots.xpl"/>
				<p:output name="data" id="hasFindspots"/>
			</p:processor>
			
			<p:choose href="#config">
				<p:when test="matches(/config/annotation_sparql_endpoint, 'https?://')">
					
					<!-- perform ASK query for annotations related to this URI -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#config"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>								
								
								<!-- config variables -->
								<xsl:variable name="sparql_endpoint" select="/config/annotation_sparql_endpoint"/>
								
								<xsl:variable name="query">
									<![CDATA[PREFIX oa:	<http://www.w3.org/ns/oa#>
ASK {?s oa:hasBody <URI>}]]>
								</xsl:variable>
								
								<xsl:variable name="service">
									<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>					
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
						<p:output name="data" id="ask-url-generator-config"/>
					</p:processor>
					
					<!-- get a SPARQL response from the endpoint -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#ask-url-generator-config"/>
						<p:output name="data" id="url-data"/>
					</p:processor>
					
					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#url-data"/>
						<p:output name="data" id="url-data-checked"/>
					</p:processor>
					
					<!-- Check whether we had an exception -->
					<p:choose href="#url-data-checked">
						<p:when test="/exceptions">
							<!-- if there is a problem with the SPARQL endpoint, then simply generate the HTML page -->
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #hasTypes, #hasFindspots, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
							<p:processor name="oxf:pipeline">
								<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
								<p:output name="data" id="annotations"/>
							</p:processor>
							
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #hasTypes, #hasFindspots, #config, #annotations)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #data, #hasTypes, #hasFindspots, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>	
			<p:choose href="#config">
				<p:when test="matches(/config/annotation_sparql_endpoint, 'https?://')">
					
					<!-- perform ASK query for annotations related to this URI -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#config"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>								
								
								<!-- config variables -->
								<xsl:variable name="sparql_endpoint" select="/config/annotation_sparql_endpoint"/>
								
								<xsl:variable name="query">
									<![CDATA[PREFIX oa:	<http://www.w3.org/ns/oa#>
ASK {?s oa:hasBody <URI>}]]>
								</xsl:variable>
								
								<xsl:variable name="service">
									<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>					
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
						<p:output name="data" id="ask-url-generator-config"/>
					</p:processor>
					
					<!-- get a SPARQL response from the endpoint -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#ask-url-generator-config"/>
						<p:output name="data" id="url-data"/>
					</p:processor>
					
					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#url-data"/>
						<p:output name="data" id="url-data-checked"/>
					</p:processor>
					
					<!-- Check whether we had an exception -->
					<p:choose href="#url-data-checked">
						<p:when test="/exceptions">
							<!-- if there is a problem with the SPARQL endpoint, then simply generate the HTML page -->
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
							<p:processor name="oxf:pipeline">
								<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
								<p:output name="data" id="annotations"/>
							</p:processor>
							
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #config, #annotations)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/object/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
