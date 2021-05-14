<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: May 2021
	Function: evaluate the accept or accept-profile headers in order to determine which serialization to execute for content negotiation of the ID pipeline -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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

	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
				exclude-result-prefixes="#all">
				<xsl:output indent="yes"/>

				<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
				<xsl:variable name="accept-profile" select="//header[name[.='accept-profile']]/value"/>

				<xsl:template match="/">
					<content-type>
						<xsl:variable name="pieces" select="tokenize($content-type, ';')"/>
						
						<!-- normalize space in fragments in order to support better parsing for content negotiation -->
						<xsl:variable name="accept-fragments" as="item()*">
							<nodes>
								<xsl:for-each select="$pieces">
									<node>
										<xsl:value-of select="normalize-space(.)"/>
									</node>
								</xsl:for-each>
							</nodes>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="count($accept-fragments/node) &gt; 1">
								
								<!-- validate profiles, only linked.art profile for JSON-LD is supported at the moment, to differentiate from the default Nomisma.org JSON-LD -->
								<xsl:choose>
									<xsl:when test="$accept-fragments/node[starts-with(., 'profile=')]">
										<!-- parse the profile URI -->
										<xsl:variable name="profile" select="replace(substring-after($accept-fragments/node[starts-with(., 'profile=')][1], '='), '&#x022;', '')"/>

										<xsl:choose>
											<!-- only allow the linked.art profile if the content-type is validated to JSON-LD -->
											<xsl:when test="numishare:resolve-content-type($accept-fragments/node[1]) = 'json-ld'">												
												<xsl:choose>
													<xsl:when test="$profile = 'https://linked.art/ns/v1/linked-art.json'">linked-art</xsl:when>
													<xsl:otherwise>json-ld</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="numishare:resolve-content-type($accept-fragments/node[1])"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="numishare:resolve-content-type($accept-fragments/node[1])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:choose>
									<xsl:when test="$accept-profile = '&lt;https://linked.art/ns/v1/linked-art.json&gt;'">linked-art</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="numishare:resolve-content-type($content-type)"/>
									</xsl:otherwise>
								</xsl:choose>-->
								
								<xsl:value-of select="numishare:resolve-content-type($content-type)"/>
							</xsl:otherwise>
						</xsl:choose>
					</content-type>
				</xsl:template>

				<xsl:function name="numishare:resolve-content-type">
					<xsl:param name="content-type"/>

					<xsl:choose>
						<xsl:when test="$content-type='application/ld+json'">json-ld</xsl:when>
						<xsl:when test="$content-type='application/vnd.google-earth.kml+xml'">kml</xsl:when>
						<xsl:when test="$content-type='application/vnd.geo+json'">geojson</xsl:when>
						<xsl:when test="$content-type='application/xml' or $content-type='text/xml'">xml</xsl:when>
						<xsl:when test="$content-type='application/rdf+xml'">rdfxml</xsl:when>
						<xsl:when test="$content-type='text/turtle'">turtle</xsl:when>
						<xsl:when test="contains($content-type, 'text/html') or contains($content-type, 'xhtml') or $content-type='*/*' or not(string($content-type))">html</xsl:when>
						<xsl:otherwise>error</xsl:otherwise>
					</xsl:choose>
				</xsl:function>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="conneg-config"/>
	</p:processor>

	<p:choose href="#conneg-config">
		<p:when test="content-type='xml'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#data"/>
				<p:output name="data" ref="data"/>				
			</p:processor>
		</p:when>
		<p:when test="content-type='linked-art'">
			<!-- evalute the namespace of the root element and call either the NUDS or TEI serialization -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<recordType>
								<xsl:choose>
									<!--<xsl:when test="*/namespace-uri()='http://nomisma.org/nudsHoard'">nudsHoard</xsl:when>-->
									<xsl:when test="*/namespace-uri()='http://nomisma.org/nuds'">nuds</xsl:when>
									<xsl:when test="*/namespace-uri()='http://www.tei-c.org/ns/1.0'">tei</xsl:when>
								</xsl:choose>
							</recordType>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="recordType"/>
			</p:processor>
			
			<p:choose href="#recordType">				
				<p:when test="recordType='nuds'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../views/serializations/nuds/linkedart-json-ld.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="recordType='tei'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../views/serializations/tei/linkedart-json-ld.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
			</p:choose>
		</p:when>
		<p:when test="content-type='json-ld'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../views/serializations/object/json-ld.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='turtle'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/rdf/ttl.xpl"/>
				<p:input name="data" href="#data"/>				
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='kml'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/object/kml.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='rdfxml'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/object/rdf.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='geojson'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/object/geojson.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='html'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/object/html.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="406-not-acceptable.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>
