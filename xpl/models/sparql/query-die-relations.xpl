<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: November 2020
	Function: Query the dies that are in the opposite property (nmo:hasObverse or nmo:hasReverse) from the current die URI or query the die combinations for a coin type URI
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="input" name="request"/>
	<p:param type="input" name="side"/>
	<p:param type="input" name="namedGraph"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<collection_type>
						<xsl:value-of select="/config/collection_type"/>
					</collection_type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collectionType"/>
	</p:processor>
	
	<p:choose href="#collectionType">		
		<p:when test="collection_type = 'die'">
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/query-die-relations.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="query-document"/>
			</p:processor>
			
			<!-- generator config for URL generator -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#query-document"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side" href="#side"/>
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
						exclude-result-prefixes="#all">
						<xsl:include href="../../../ui/xslt/controllers/metamodel-templates.xsl"/>
						<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
						
						<xsl:variable name="uri">
							<xsl:choose>
								<xsl:when test="doc('input:request')/request/parameters/parameter[name='die']/value">
									<xsl:value-of select="concat(/config/uri_space, doc('input:request')/request/parameters/parameter[name='die']/value)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
						
						<xsl:variable name="query">
							<xsl:value-of select="doc('input:query')"/>
						</xsl:variable>
						
						<xsl:variable name="statements" as="element()*">
							<statements>
								<xsl:call-template name="numishare:queryDieRelations">
									<xsl:with-param name="dieURI" select="$uri"/>
									<xsl:with-param name="namedGraph" select="doc('input:namedGraph')/namedGraph"/>
									<xsl:with-param name="side" select="doc('input:side')/side"/>
								</xsl:call-template>			
							</statements>
						</xsl:variable>	
						
						<xsl:variable name="statementsSPARQL">
							<xsl:apply-templates select="$statements/*"/>
						</xsl:variable>
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>					
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
				<p:output name="data" id="url-generator-config"/>
			</p:processor>
		</p:when>
		<p:when test="collection_type = 'cointype'">
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/query-die-relations-for-type.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="query-document"/>
			</p:processor>
			
			<!-- generator config for URL generator -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#query-document"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side" href="#side"/>
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
						exclude-result-prefixes="#all">
						<xsl:include href="../../../ui/xslt/controllers/metamodel-templates.xsl"/>
						<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
						
						<xsl:variable name="uri">
							<xsl:choose>
								<xsl:when test="doc('input:request')/request/parameters/parameter[name='type']/value">
									<xsl:value-of select="concat(/config/uri_space, doc('input:request')/request/parameters/parameter[name='type']/value)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>				
						
						<xsl:variable name="query">
							<xsl:value-of select="doc('input:query')"/>
						</xsl:variable>
						
						<xsl:variable name="statements" as="element()*">
							<statements>
								<xsl:call-template name="numishare:queryDieRelationsForType">
									<xsl:with-param name="typeURI" select="$uri"/>
									<xsl:with-param name="namedGraph" select="doc('input:namedGraph')/namedGraph"/>									
								</xsl:call-template>			
							</statements>
						</xsl:variable>	
						
						<xsl:variable name="statementsSPARQL">
							<xsl:apply-templates select="$statements/*"/>
						</xsl:variable>
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>					
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
				<p:output name="data" id="url-generator-config"/>
			</p:processor>
		</p:when>
		<p:when test="collection_type = 'object'">
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/query-die-relations.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="query-document"/>
			</p:processor>
			
			<!-- generator config for URL generator -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#query-document"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side" href="#side"/>
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
						exclude-result-prefixes="#all">
						<xsl:include href="../../../ui/xslt/controllers/metamodel-templates.xsl"/>
						<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
						
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						
						<!-- config variables -->
						<xsl:variable name="url" select="/config/url"/>
						<xsl:variable name="uri_space" select="/config/uri_space"/>
						<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
						
						<xsl:variable name="uri"
							select="if (string($uri_space)) then
							concat($uri_space, $id)
							else
							concat($url, 'id/', $id)"/>			
						
						<xsl:variable name="query">
							<xsl:value-of select="doc('input:query')"/>
						</xsl:variable>
						
						<xsl:variable name="statements" as="element()*">
							<statements>
								<xsl:call-template name="numishare:queryDieRelationsForCoin">
									<xsl:with-param name="objectURI" select="$uri"/>
									<xsl:with-param name="namedGraph" select="doc('input:namedGraph')/namedGraph"/>
								</xsl:call-template>			
							</statements>
						</xsl:variable>	
						
						<xsl:variable name="statementsSPARQL">
							<xsl:apply-templates select="$statements/*"/>
						</xsl:variable>
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>					
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
				<p:output name="data" id="url-generator-config"/>
			</p:processor>
		</p:when>
	</p:choose>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
