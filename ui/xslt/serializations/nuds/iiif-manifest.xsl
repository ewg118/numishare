<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>

	<!-- variables -->
	<xsl:variable name="recordType" select="//nuds:nuds/@recordType"/>
	<xsl:variable name="lang">en</xsl:variable>
	<xsl:variable name="recordId" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $recordId)
			else
				concat($url, 'id/', $recordId)"/>

	<!-- read other manifest URI patterns -->
	<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, $recordId), '/')"/>

	<xsl:variable name="manifestUri">
		<xsl:variable name="before" select="tokenize(substring-before(doc('input:request')/request/request-url, concat('/', $recordId)), '/')"/>

		<xsl:choose>
			<xsl:when test="$before[last()] = 'manifest'">
				<xsl:value-of select="concat($url, 'manifest/', $recordId)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'manifest/', $before[last()], '/', $recordId)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="manifestSide">
		<xsl:variable name="before" select="tokenize(substring-before(doc('input:request')/request/request-url, concat('/', $recordId)), '/')"/>

		<xsl:choose>
			<xsl:when test="$before[last()] = 'manifest'"/>
			<xsl:otherwise>
				<xsl:value-of select="$before[last()]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<xsl:call-template name="numishare:getNudsDocument">
						<xsl:with-param name="uri" select="$uri"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
				</xsl:otherwise>
			</xsl:choose>
		</nudsGroup>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$pieces[2] = 'sequence'">
				<xsl:variable name="model" as="element()*">
					<_object>
						<xsl:call-template name="sequences"/>
					</_object>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<xsl:when test="$pieces[2] = 'canvas'">
				<xsl:variable name="side" select="$pieces[3]"/>

				<xsl:variable name="model" as="element()*">
					<xsl:apply-templates select="//descendant::mets:fileGrp[@USE = $side]/mets:file[@USE = 'iiif']"/>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<xsl:when test="$pieces[2] = 'annotation'">
				<xsl:variable name="side" select="$pieces[3]"/>

				<xsl:variable name="model" as="element()*">
					<xsl:apply-templates select="//descendant::mets:fileGrp[@USE = $side]/mets:file[@USE = 'iiif']/mets:FLocat">
						<xsl:with-param name="side" select="$side"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//nuds:nuds"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<!-- construct XML-JSON metamodel inspired by the XForms JSON-XML serialization -->
		<xsl:variable name="model" as="element()*">
			<_object>
				<__context>http://iiif.io/api/presentation/2/context.json</__context>
				<__id>
					<xsl:value-of select="$manifestUri"/>
				</__id>
				<__type>sc:Manifest</__type>
				<attribution>
					<xsl:value-of select="/content/config/template/agencyName"/>
				</attribution>
				<label>
					<xsl:value-of select="//nuds:descMeta/nuds:title[@xml:lang = 'en']"/>
				</label>

				<!-- generate description from obverse and reverse -->
				<xsl:if test="$nudsGroup//nuds:typeDesc/nuds:obverse or $nudsGroup//nuds:typeDesc/nuds:reverse">
					<description>
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc/nuds:obverse | $nudsGroup//nuds:typeDesc/nuds:reverse"/>
					</description>
				</xsl:if>

				<!-- extract metadata from descMeta -->
				<metadata>
					<_array>
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc | nuds:descMeta/nuds:physDesc | nuds:descMeta/nuds:adminDesc"/>
					</_array>
				</metadata>

				<rendering>
					<_object>
						<__id>
							<xsl:value-of select="$objectUri"/>
						</__id>
						<format>text/html</format>
						<label>Full record</label>
					</_object>
				</rendering>

				<seeAlso>
					<_array>
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.rdf')"/>
							</__id>
							<format>application/rdf+xml</format>
						</_object>
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.ttl')"/>
							</__id>
							<format>text/turtle</format>
						</_object>
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.jsonld')"/>
							</__id>
							<format>application/ld+json</format>
						</_object>
					</_array>
				</seeAlso>
				<xsl:call-template name="sequences"/>
				<within>
					<xsl:value-of select="$url"/>
				</within>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>

	</xsl:template>

	<!-- XSLT templates to generate XML-JSON metamodel from NUDS -->
	<xsl:template match="nuds:typeDesc">
		<xsl:apply-templates select="nuds:date | nuds:dateRange | nuds:denomination | nuds:material | nuds:objectType | nuds:manufacture"/>
	</xsl:template>

	<xsl:template match="nuds:physDesc">
		<xsl:apply-templates select="nuds:weight | nuds:diameter | nuds:axis"/>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<xsl:apply-templates select="nuds:identifier"/>
	</xsl:template>

	<xsl:template
		match="nuds:date | nuds:denomination | nuds:material | nuds:weight | nuds:diameter | nuds:axis | nuds:identifier | nuds:objectType | nuds:manufacture">
		<_object>
			<label>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</label>
			<value>
				<xsl:value-of select="normalize-space(.)"/>
			</value>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:dateRange">
		<_object>
			<label>
				<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
			</label>
			<value>
				<xsl:value-of select="normalize-space(nuds:fromDate)"/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="normalize-space(nuds:toDate)"/>
			</value>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse">
		<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		<xsl:text>: </xsl:text>
		<xsl:if test="nuds:legend">
			<xsl:apply-templates select="nuds:legend"/>
		</xsl:if>
		<xsl:if test="nuds:legend and nuds:type">
			<xsl:text> - </xsl:text>
		</xsl:if>
		<xsl:if test="nuds:type">
			<xsl:value-of select="nuds:type/nuds:description[@xml:lang = $lang]"/>
		</xsl:if>
		<xsl:if test="not(position() = last())">
			<xsl:text>\n</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="nuds:legend">
		<xsl:choose>
			<xsl:when test="child::tei:div[@type = 'edition']">
				<xsl:apply-templates select="tei:div[@type = 'edition']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- generate sequence -->
	<xsl:template name="sequences">
		<sequences>
			<_array>
				<_object>
					<__id>
						<xsl:value-of select="concat($manifestUri, '/sequence/default')"/>
					</__id>
					<__type>sc:Sequence</__type>
					<label>Default sequence</label>
					<canvases>
						<_array>
							<xsl:choose>
								<!-- apply METS templates for NUDS records of physical coins -->
								<xsl:when test="$recordType = 'physical'">
									<xsl:variable name="sizes" as="element()*">
										<sizes>
											<xsl:choose>
												<xsl:when
													test="descendant::mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'iiif'] or descendant::mets:fileGrp[@USE = 'reverse']/mets:file[@USE = 'iiif']">
													<obverse>
														<xsl:apply-templates select="doc('input:obverse-json')/*"/>
													</obverse>
													<reverse>
														<xsl:apply-templates select="doc('input:reverse-json')/*"/>
													</reverse>
												</xsl:when>
												<xsl:when test="descendant::mets:fileGrp[@USE='card']/descendant::mets:file[@USE='iiif']">
													<xsl:for-each select="doc('input:iiif-json')//json[@type = 'object']">
														<image>
															<xsl:apply-templates select="self::node()"/>
														</image>
													</xsl:for-each>													
													
												</xsl:when>
											</xsl:choose>
											
										</sizes>
									</xsl:variable>
									
									

									<xsl:choose>
										<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
											<xsl:apply-templates select="descendant::mets:fileGrp[@USE = $manifestSide]/mets:file[@USE = 'iiif']">
												<xsl:with-param name="sizes" select="$sizes"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											
											<xsl:choose>
												<xsl:when test="descendant::mets:fileGrp[@USE = 'obverse']/mets:file[@USE = 'iiif'] or descendant::mets:fileGrp[@USE = 'reverse']/mets:file[@USE = 'iiif']">
													<xsl:apply-templates select="descendant::mets:file[@USE = 'iiif']">
														<xsl:with-param name="postion"/>
														<xsl:with-param name="sizes" select="$sizes"/>
													</xsl:apply-templates>
												</xsl:when>
												<xsl:when test="descendant::mets:fileGrp[@USE='card']/descendant::mets:file[@USE='iiif']">
													
													<xsl:for-each select="descendant::mets:file[@USE = 'iiif']">
														<xsl:variable name="position" select="position()"/>
														
														<xsl:apply-templates select="self::node()">
															<xsl:with-param name="position" select="$position"/>
															<xsl:with-param name="sizes" select="$sizes"/>
														</xsl:apply-templates>
													</xsl:for-each>
													
													<!--<xsl:apply-templates select="descendant::mets:fileGrp[@USE = 'card']">
														<xsl:with-param name="sizes" select="$sizes"/>
													</xsl:apply-templates>-->
												</xsl:when>
											</xsl:choose>
											
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<!-- otherwise, apply templates on SPARQL results -->
								<xsl:otherwise>
									<xsl:apply-templates select="doc('input:sparqlResults')//res:result"/>
								</xsl:otherwise>
							</xsl:choose>
						</_array>

					</canvases>
					<viewingHint>individuals</viewingHint>
				</_object>
			</_array>
		</sequences>
	</xsl:template>
	
	<xsl:template match="mets:fileGrp[@USE = 'card']">
		<xsl:param name="sizes"/>
		
		<xsl:variable name="position" select="position()"/>
		
		<xsl:apply-templates select="descendant::mets:file[@USE = 'iiif']">
			<xsl:with-param name="sizes" select="$sizes"/>
			<xsl:with-param name="position" select="$position"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- create canvases out of mets:files -->
	<xsl:template match="mets:file">
		<xsl:param name="sizes"/>
		<xsl:param name="position"/>
		<xsl:variable name="side" select="parent::mets:fileGrp/@USE"/>
		
		<xsl:variable name="id" select="if (string($position)) then $position else $side"/>
		

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/canvas/', $id)"/>
			</__id>
			<__type>sc:Canvas</__type>
			<label>
				<xsl:value-of select="numishare:regularize_node($side, $lang)"/>
			</label>
			<thumbnail>
				<_object>
					<__id>
						<xsl:choose>
							<xsl:when test="parent::mets:fileGrp/mets:file[@USE = 'thumbnail']">
								<xsl:value-of select="parent::mets:fileGrp/mets:file[@USE = 'thumbnail']/mets:FLocat/@xlink:href"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(mets:FLocat/@xlink:href, '/full/175,175/0/default.jpg')"/>
							</xsl:otherwise>
						</xsl:choose>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<height>175</height>
					<width>175</width>
				</_object>
			</thumbnail>
			
			<xsl:choose>
				<xsl:when test="string($position)">
					<height>
						<xsl:value-of select="$sizes/image[$position]/height"/>
					</height>
					<width>
						<xsl:value-of select="$sizes/image[$position]/width"/>
					</width>
				</xsl:when>
				<xsl:otherwise>
					<height>
						<xsl:value-of select="$sizes/*[name() = $side]/height"/>
					</height>
					<width>
						<xsl:value-of select="$sizes/*[name() = $side]/width"/>
					</width>
				</xsl:otherwise>
			</xsl:choose>			

			<images>
				<_array>
					<xsl:apply-templates select="mets:FLocat">
						<xsl:with-param name="side" select="$side"/>
						<xsl:with-param name="sizes" select="$sizes"/>
						<xsl:with-param name="position" select="$position"/>
						<xsl:with-param  name="id" select="$id"/>
					</xsl:apply-templates>
				</_array>
			</images>
		</_object>
	</xsl:template>

	<xsl:template match="mets:FLocat">
		<xsl:param name="sizes"/>
		<xsl:param name="side"/>
		<xsl:param name="position"/>
		<xsl:param name="id"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/annotation/', $id)"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motivation>sc:painting</motivation>
			<on>
				<xsl:value-of select="concat($manifestUri, '/canvas/', $id)"/>
			</on>
			<resource>
				<_object>
					<__id>
						<xsl:value-of select="concat(@xlink:href, '/full/full/0/default.jpg')"/>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<xsl:choose>
						<xsl:when test="string($position)">
							<height>
								<xsl:value-of select="$sizes/image[$position]/height"/>
							</height>
							<width>
								<xsl:value-of select="$sizes/image[$position]/width"/>
							</width>
						</xsl:when>
						<xsl:otherwise>
							<height>
								<xsl:value-of select="$sizes/*[name() = $side]/height"/>
							</height>
							<width>
								<xsl:value-of select="$sizes/*[name() = $side]/width"/>
							</width>
						</xsl:otherwise>
					</xsl:choose>
					<service>
						<_object>
							<__context>http://iiif.io/api/image/2/context.json</__context>
							<__id>
								<xsl:value-of select="@xlink:href"/>
							</__id>
							<profile>http://iiif.io/api/image/2/level2.json</profile>
						</_object>
					</service>
				</_object>
			</resource>
		</_object>
	</xsl:template>

	<!-- generate dimsension variable for image sizes, derived from the image API JSON -->
	<xsl:template match="json[@type = 'object']">
		<height>
			<xsl:value-of select="height"/>
		</height>
		<width>
			<xsl:value-of select="width"/>
		</width>
	</xsl:template>

	<!-- generate canvases from SPARQL results for coin type manifests -->
	<xsl:template match="res:result">
		<_object>
			<__id>
				<xsl:value-of select="res:binding[@name = 'object']/res:uri"/>
			</__id>
			<__type>sc:Canvas</__type>
			<label>
				<xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
			</label>

			<!-- extract metadata from other SPARQL fields -->
			<metadata>
				<_array>
					<xsl:choose>
						<xsl:when test="res:binding[@name = 'collection']">
							<xsl:apply-templates select="res:binding[@name = 'collection']" mode="metadata"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="res:binding[@name = 'datasetTitle']" mode="metadata"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates
						select="res:binding[@name = 'axis'] | res:binding[@name = 'weight'] | res:binding[@name = 'diameter'] | res:binding[@name = 'identifier']"
						mode="metadata"/>
				</_array>
			</metadata>
			<xsl:choose>
				<xsl:when test="res:binding[@name = 'comService']">
					<xsl:variable name="service" select="res:binding[@name = 'comService']/res:uri"/>
					<xsl:variable name="info" as="element()*">
						<xsl:copy-of select="doc('input:images')//image[@uri = $service][child::json]/json"/>
					</xsl:variable>

					<thumbnail>
						<_object>
							<__id>
								<xsl:value-of
									select="
										concat($service, '/full/240,120/0/', if ($info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
											'default'
										else
											'native', '.jpg')"
								/>
							</__id>
							<__type>dctypes:Image</__type>
							<format>image/jpeg</format>
							<height>120</height>
							<width>240</width>
							<xsl:call-template name="service">
								<xsl:with-param name="service" select="$service"/>
								<xsl:with-param name="info" select="$info"/>
							</xsl:call-template>
						</_object>
					</thumbnail>

					<xsl:choose>
						<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="ceiling(number($info/width) div 2)"/>
							</width>
						</xsl:when>
						<xsl:otherwise>
							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="$info/width"/>
							</width>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="res:binding[@name = 'obvService'] and res:binding[@name = 'revService']">
					<xsl:choose>
						<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
							<xsl:variable name="service" select="res:binding[@name = concat(substring($manifestSide, 1, 3), 'Service')]/res:uri"/>
							<xsl:variable name="info" as="element()*">
								<xsl:copy-of select="doc('input:images')//image[@uri = $service][child::json]/json"/>
							</xsl:variable>

							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="$info/width"/>
							</width>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="obvService" select="res:binding[@name = 'obvService']/res:uri"/>
							<xsl:variable name="revService" select="res:binding[@name = 'revService']/res:uri"/>

							<xsl:variable name="obvInfo" as="element()*">
								<xsl:copy-of select="doc('input:images')//image[@uri = $obvService][child::json]/json"/>
							</xsl:variable>
							<xsl:variable name="revInfo" as="element()*">
								<xsl:copy-of select="doc('input:images')//image[@uri = $revService][child::json]/json"/>
							</xsl:variable>

							<thumbnail>
								<_object>
									<__id>
										<xsl:value-of
											select="
												concat($obvService, '/full/120,120/0/', if ($obvInfo/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
													'default'
												else
													'native', '.jpg')"
										/>
									</__id>
									<__type>dctypes:Image</__type>
									<format>image/jpeg</format>
									<height>120</height>
									<width>120</width>
									<xsl:call-template name="service">
										<xsl:with-param name="service" select="$obvService"/>
										<xsl:with-param name="info" select="$obvInfo"/>
									</xsl:call-template>
								</_object>
							</thumbnail>

							<height>
								<xsl:choose>
									<xsl:when test="number($obvInfo/height) &gt;= number($revInfo/height)">
										<xsl:value-of select="$obvInfo/height"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$revInfo/height"/>
									</xsl:otherwise>
								</xsl:choose>
							</height>
							<width>
								<xsl:value-of select="number($obvInfo/width) + number($revInfo/width)"/>
							</width>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<images>
				<_array>
					<xsl:choose>
						<xsl:when test="res:binding[@name = 'comService']">
							<xsl:apply-templates select="res:binding[@name = 'comService']"/>
						</xsl:when>
						<xsl:when test="res:binding[@name = 'obvService'] and res:binding[@name = 'revService']">
							<xsl:choose>
								<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
									<xsl:apply-templates select="res:binding[@name = concat(substring($manifestSide, 1, 3), 'Service')]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="res:binding[@name = 'obvService']"/>
									<xsl:apply-templates select="res:binding[@name = 'revService']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</_array>
			</images>
		</_object>
	</xsl:template>

	<!-- generate images for IIIF service URIs -->
	<xsl:template match="res:binding[@name = 'comService'] | res:binding[@name = 'obvService'] | res:binding[@name = 'revService']">
		<xsl:variable name="service" select="res:uri"/>

		<xsl:variable name="info" as="element()*">
			<xsl:copy-of select="doc('input:images')//image[@uri = $service][child::json]/json"/>
		</xsl:variable>

		<_object>
			<__id>
				<xsl:value-of select="res:uri"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motivation>sc:painting</motivation>
			<label>
				<xsl:choose>
					<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
						<xsl:value-of select="numishare:regularize_node($manifestSide, $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="starts-with(@name, 'com')">Combined</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:regularize_node(concat(substring(@name, 1, 3), 'erse'), $lang)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</label>
			<on>
				<xsl:choose>
					<xsl:when test="$manifestSide = 'obverse' or $manifestSide = 'reverse'">
						<xsl:value-of select="parent::node()/res:binding[@name = 'object']/res:uri"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- otherwise, only render the left or right side of the combined image -->

						<!-- if the current service is the reverse, then set the 'on' with xy coordinates to display it to the right of the obverse -->
						<xsl:choose>
							<xsl:when test="@name = 'obvService'">
								<xsl:value-of
									select="concat(parent::node()/res:binding[@name = 'object']/res:uri, '#xywh=0,0,', $info/width, ',', $info/height)"/>
							</xsl:when>
							<xsl:when test="@name = 'revService'">
								<xsl:variable name="obvService" select="parent::node()/res:binding[@name = 'obvService']/res:uri"/>
								<xsl:variable name="obvInfo" as="element()*">
									<xsl:copy-of select="doc('input:images')//image[@uri = $obvService][child::json]/json"/>
								</xsl:variable>

								<xsl:value-of
									select="concat(parent::node()/res:binding[@name = 'object']/res:uri, '#xywh=', $obvInfo/width, ',0,', $info/width, ',', $info/height)"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="parent::node()/res:binding[@name = 'object']/res:uri"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</on>
			<resource>
				<_object>
					<!--<xsl:choose>
						<xsl:when test="@name = 'comService' and ($manifestSide = 'obverse' or $manifestSide = 'reverse')">
							<xsl:variable name="size"
								select="
									concat(if ($manifestSide = 'obverse') then
										'0'
									else
										floor(number($info/width) div 2), ',0,', ceiling(number($info/width) div 2), ',', $info/height)"/>

							<__id>
								<xsl:value-of
									select="
										concat(res:uri, '/', $size, '/full/0/', if ($info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
											'default'
										else
											'native', '.jpg')"
								/>
							</__id>
							<__type>oa:SpecificResource</__type>
							<!-\-<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="ceiling(number($info/width) div 2)"/>
							</width>-\->
							<full>
								<_object>
									<__id>
										<xsl:value-of
											select="
												concat(res:uri, '/full/full/0/', if ($info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
													'default'
												else
													'native', '.jpg')"
										/>
									</__id>
									<__type>dctypes:Image</__type>
									<xsl:call-template name="service">
										<xsl:with-param name="info" select="$info"/>
									</xsl:call-template>
								</_object>
							</full>
						</xsl:when>
						<xsl:otherwise>
							<__id>
								<xsl:value-of
									select="
										concat(res:uri, '/full/full/0/', if ($info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
											'default'
										else
											'native', '.jpg')"
								/>
							</__id>
							<__type>dctypes:Image</__type>
							<format>image/jpeg</format>
							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="$info/width"/>
							</width>
							<xsl:call-template name="service">
								<xsl:with-param name="info" select="$info"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>-->

					<__id>
						<xsl:variable name="size">
							<xsl:choose>
								<xsl:when test="@name = 'comService' and ($manifestSide = 'obverse' or $manifestSide = 'reverse')">
									<xsl:value-of
										select="
											concat(if ($manifestSide = 'obverse') then
												'0'
											else
												floor(number($info/width) div 2), ',0,', ceiling(number($info/width) div 2), ',', $info/height)"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>full</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:value-of
							select="
								concat(res:uri, '/', $size, '/full/0/', if ($info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json') then
									'default'
								else
									'native', '.jpg')"
						/>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<xsl:choose>
						<xsl:when test="@name = 'comService' and ($manifestSide = 'obverse' or $manifestSide = 'reverse')">
							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="ceiling(number($info/width) div 2)"/>
							</width>
						</xsl:when>
						<xsl:otherwise>
							<height>
								<xsl:value-of select="$info/height"/>
							</height>
							<width>
								<xsl:value-of select="$info/width"/>
							</width>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="service">
						<xsl:with-param name="service" select="$service"/>
						<xsl:with-param name="info" select="$info"/>
					</xsl:call-template>
				</_object>
			</resource>

			<!--<xsl:if test="@name = 'comService' and ($manifestSide = 'obverse' or $manifestSide = 'reverse')">
				<selector>
					<_object>
						<__context>http://iiif.io/api/annex/openannotation/context.json</__context>
						<__type>iiif:ImageApiSelector</__type>						
					</_object>
				</selector>
			</xsl:if>-->
		</_object>
	</xsl:template>

	<xsl:template name="service">
		<xsl:param name="service"/>
		<xsl:param name="info"/>

		<service>
			<_object>
				<__context>
					<xsl:choose>
						<xsl:when test="$info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json'">
							<xsl:text>http://iiif.io/api/image/2/level2.json</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>http://iiif.io/api/image/1/context.json</xsl:text>
						</xsl:otherwise>
					</xsl:choose>

				</__context>
				<__id>
					<xsl:value-of select="$service"/>
				</__id>
				<profile>
					<xsl:choose>
						<xsl:when test="$info/_context[@name = '@context'] = 'http://iiif.io/api/image/2/context.json'">
							<xsl:text>http://iiif.io/api/image/2/level2.json</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</profile>
			</_object>
		</service>
	</xsl:template>

	<xsl:template match="res:binding" mode="metadata">
		<_object>
			<label>
				<xsl:choose>
					<xsl:when test="@name = 'datasetTitle'">Dataset</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:regularize_node(@name, $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</label>
			<value>
				<xsl:value-of select="child::*"/>
			</value>
		</_object>
	</xsl:template>

</xsl:stylesheet>
