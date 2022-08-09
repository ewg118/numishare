<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: June 2022
	Function: HTML view for NUDS. It involves conditionals for conceptual vs. physical specimens, 
		including SPARQL queries for associated specimens and annoations.
		July 2018: added type-examples.xpl into this XPL in order to avoid xsl:document() function call to /api pipeline within the XSLT
		October-November 2020: Added support for die studies
		June 2022: Moved subtype XQuery into XPL and associated numishareResults SPARQL query for example specimens
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:saxon="http://saxon.sf.net/">
	<p:param type="input" name="data"/>
	<!--<p:param type="output" name="data"/>-->
	
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
		<p:input name="data" href="#config"/>
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
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/specimen-count.xpl"/>
				<p:output name="data" id="specimenCount"/>
			</p:processor>
			
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/die-examples.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="die-examples-query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#die-examples-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="die-examples-query-document"/>
			</p:processor>
			
			<p:choose href="#specimenCount">
				<p:when test="//res:binding[@name='count']/res:literal = 0">
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="query" href="#die-examples-query-document"/>
						<p:input name="data" href="aggregate('content', #data, #specimenCount, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<p:otherwise>					
					<!-- execute SPARQL query to get the images related to the die URI -->
					<p:processor name="oxf:pipeline">						
						<p:input name="data" href="#config"/>
						<p:input name="config" href="../../../models/sparql/die-examples.xpl"/>
						<p:output name="data" id="specimens"/>
					</p:processor>
					
					<!-- iterate through named graphs and execute a die-linking query for each named graph to evaluate links from the obverse or reverse -->					
					<p:for-each href="#config" select="/config/die_study/namedGraph" root="obverse" id="obv-dies">
						<p:processor name="oxf:pipeline">						
							<p:input name="data" href="#config"/>
							<p:input name="request" href="#request"/>
							<p:input name="namedGraph" href="current()"/>
							<p:input name="side">
								<side>obv</side>
							</p:input>
							<p:input name="config" href="../../../models/sparql/query-die-relations.xpl"/>
							<p:output name="data" ref="obv-dies"/>
						</p:processor>
					</p:for-each>
					
					<p:for-each href="#config" select="/config/die_study/namedGraph" root="reverse" id="rev-dies">
						<p:processor name="oxf:pipeline">						
							<p:input name="data" href="#config"/>
							<p:input name="request" href="#request"/>
							<p:input name="namedGraph" href="current()"/>
							<p:input name="side">
								<side>rev</side>
							</p:input>
							<p:input name="config" href="../../../models/sparql/query-die-relations.xpl"/>
							<p:output name="data" ref="rev-dies"/>
						</p:processor>
					</p:for-each>
					
					<!-- get a list of associated coin type URIs -->
					<p:processor name="oxf:pipeline">						
						<p:input name="data" href="#config"/>
						<p:input name="config" href="../../../models/sparql/getDieTypes.xpl"/>
						<p:output name="data" id="die-types"/>
					</p:processor>
					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="specimens" href="#specimens"/>
						<p:input name="die-types" href="#die-types"/>
						<p:input name="dies" href="aggregate('dies', #obv-dies, #rev-dies)"/>
						<p:input name="query" href="#die-examples-query-document"/>
						<p:input name="data" href="aggregate('content', #data, #specimenCount, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>		
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="collection_type='cointype'">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/specimen-count.xpl"/>
				<p:output name="data" id="specimenCount"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-findspots.xpl"/>
				<p:output name="data" id="hasFindspots"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-iiif.xpl"/>
				<p:output name="data" id="hasIIIF"/>
			</p:processor>
			
			<!-- evaluate the config for a die study and return true or false if there are dies associated with the coin type -->
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-dies.xpl"/>
				<p:output name="data" id="hasDies"/>
			</p:processor>
			
			<!-- execute XQuery to get subtypes -->
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/xquery/get-subtypes.xpl"/>
				<p:output name="data" id="subtypes"/>
			</p:processor>
			
			<!-- execute the Numishare Results SPARQL query for subtypes -->
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#subtypes"/>
				<p:input name="config" href="../../../models/sparql/numishareResults.xpl"/>
				<p:output name="data" id="subtype-sparqlResults"/>
			</p:processor>
			
			<!-- serialize aggregated SPARQL model for subtypes -->
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#subtype-sparqlResults"/>
				<p:input name="config" href="../../../views/serializations/sparql/numishareResults.xpl"/>
				<p:output name="data" id="numishareResults"/>
			</p:processor>
			
			<!-- if hasDies is true, then submit a SPARQL query for the die links in order to generate an HTML chart.
				This is the same query for the d3plus forced network graph, but serialized differently -->
			<p:choose href="#hasDies">
				<p:when test="boolean(//res:boolean = true())">
					<p:for-each href="#config" select="/config/die_study/namedGraph" root="dies" id="sparql-response">
						<p:processor name="oxf:pipeline">						
							<p:input name="data" href="#config"/>
							<p:input name="request" href="#request"/>
							<p:input name="namedGraph" href="current()"/>
							<p:input name="side">
								<side/>
							</p:input>
							<p:input name="config" href="../../../models/sparql/query-die-relations.xpl"/>
							<p:output name="data" ref="sparql-response"/>
						</p:processor>
					</p:for-each>
					
					<p:processor name="oxf:identity">
						<p:input name="data" href="#sparql-response"/>
						<p:output name="data" id="dies"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#"/>
						</p:input>
						<p:output name="data" id="dies"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
			
			<!-- load type examples SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/type-examples.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="type-examples-query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#type-examples-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="type-examples-query-document"/>
			</p:processor>
			
			<!-- load die frequencies SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/die-frequencies.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="die-frequencies-query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#die-frequencies-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="die-frequencies-query-document"/>
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
							
							<p:choose href="#specimenCount">
								<p:when test="//res:binding[@name='count']/res:literal = 0">
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="hasDies" href="#hasDies"/>
										<p:input name="dies" href="#dies"/>
										<p:input name="subtypes" href="#subtypes"/>
										<p:input name="numishareResults" href="#numishareResults"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:when>
								<p:otherwise>	
									<p:processor name="oxf:pipeline">						
										<p:input name="data" href="#config"/>
										<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
										<p:output name="data" id="specimens"/>
									</p:processor>
									
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="hasDies" href="#hasDies"/>
										<p:input name="dies" href="#dies"/>
										<p:input name="specimens" href="#specimens"/>
										<p:input name="subtypes" href="#subtypes"/>
										<p:input name="numishareResults" href="#numishareResults"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:otherwise>
							</p:choose>							
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">
								<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
								<p:output name="data" id="annotations"/>
							</p:processor>
							
							<p:choose href="#specimenCount">
								<p:when test="//res:binding[@name='count']/res:literal = 0">
									<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="annotations" href="#annotations"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="hasDies" href="#hasDies"/>
										<p:input name="dies" href="#dies"/>
										<p:input name="subtypes" href="#subtypes"/>		
										<p:input name="numishareResults" href="#numishareResults"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:when>
								<p:otherwise>
									<p:processor name="oxf:pipeline">						
										<p:input name="data" href="#config"/>
										<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
										<p:output name="data" id="specimens"/>
									</p:processor>
									
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="hasDies" href="#hasDies"/>
										<p:input name="dies" href="#dies"/>
										<p:input name="annotations" href="#annotations"/>
										<p:input name="specimens" href="#specimens"/>
										<p:input name="subtypes" href="#subtypes"/>
										<p:input name="numishareResults" href="#numishareResults"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:otherwise>
							</p:choose>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:choose href="#specimenCount">
						<p:when test="//res:binding[@name='count']/res:literal = 0">
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hasIIIF" href="#hasIIIF"/>
								<p:input name="hasDies" href="#hasDies"/>
								<p:input name="dies" href="#dies"/>
								<p:input name="subtypes" href="#subtypes"/>
								<p:input name="numishareResults" href="#numishareResults"/>
								<p:input name="query" href="#type-examples-query-document"/>
								<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
								<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">						
								<p:input name="data" href="#config"/>
								<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
								<p:output name="data" id="specimens"/>
							</p:processor>
							
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hasIIIF" href="#hasIIIF"/>
								<p:input name="hasDies" href="#hasDies"/>
								<p:input name="specimens" href="#specimens"/>
								<p:input name="subtypes" href="#subtypes"/>
								<p:input name="numishareResults" href="#numishareResults"/>
								<p:input name="dies" href="#dies"/>
								<p:input name="query" href="#type-examples-query-document"/>
								<p:input name="die-frequencies-query" href="#die-frequencies-query-document"/>
								<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<!-- evaluate the config for a die study and return true or false if there are dies associated with the coin type -->
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-dies.xpl"/>
				<p:output name="data" id="hasDies"/>
			</p:processor>
			
			<!-- if hasDies is true, then submit a SPARQL query for the die links to include into the HTML output for a coin -->
			<p:choose href="#hasDies">
				<p:when test="boolean(//res:boolean = true())">
					<p:for-each href="#config" select="/config/die_study/namedGraph" root="dies" id="sparql-response">
						<p:processor name="oxf:pipeline">						
							<p:input name="data" href="#config"/>
							<p:input name="request" href="#request"/>
							<p:input name="namedGraph" href="current()"/>
							<p:input name="side">
								<side>Obverse</side>
							</p:input>
							<p:input name="config" href="../../../models/sparql/query-die-relations.xpl"/>
							<p:output name="data" id="obv-response"/>
						</p:processor>
						
						<p:processor name="oxf:pipeline">						
							<p:input name="data" href="#config"/>
							<p:input name="request" href="#request"/>
							<p:input name="namedGraph" href="current()"/>
							<p:input name="side">
								<side>Reverse</side>
							</p:input>
							<p:input name="config" href="../../../models/sparql/query-die-relations.xpl"/>
							<p:output name="data" id="rev-response"/>
						</p:processor>
						
						<p:processor name="oxf:identity">
							<p:input name="data" href="aggregate('query', #obv-response, #rev-response)"/>
							<p:output name="data" ref="sparql-response"/>
						</p:processor>
					</p:for-each>
					
					<p:processor name="oxf:identity">
						<p:input name="data" href="#sparql-response"/>
						<p:output name="data" id="dies"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#"/>
						</p:input>
						<p:output name="data" id="dies"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
			
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
								<p:input name="hasDies" href="#hasDies"/>
								<p:input name="dies" href="#dies"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
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
								<p:input name="hasDies" href="#hasDies"/>
								<p:input name="dies" href="#dies"/>
								<p:input name="annotations" href="#annotations"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="hasDies" href="#hasDies"/>
						<p:input name="dies" href="#dies"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>
	
	<!-- prepare the HTML model to be piped through the HTTP serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output name="html" encoding="UTF-8" method="html" indent="yes" omit-xml-declaration="yes" doctype-system="HTML"/>
				
				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						content-type="text/html">
						<xsl:value-of select="saxon:serialize(/html, 'html')"/>
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>
	
	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="request" href="#request"/>
		<p:input name="config" href="../../../../ui/xslt/controllers/http-headers.xsl"/>
		<p:output name="data" id="serializer-config"/>
	</p:processor>
	
	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#serializer-config"/>
	</p:processor>
	
	<!--<p:processor name="oxf:html-converter">
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
	</p:processor>-->
</p:config>
