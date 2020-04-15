<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:org="http://www.w3.org/ns/org#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>

	<!-- use the dist URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<!-- HTTP request paramters -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name = 'exclude']/value"/>
	<xsl:variable name="codes" as="item()*">
		<xsl:sequence select="tokenize($exclude, ',')"/>
	</xsl:variable>

	<!-- evaluate the $dist parameter into the necessary NUDS element and role -->
	<xsl:variable name="element">
		<xsl:choose>
			<xsl:when test="$dist = 'material' or $dist = 'denomination'">
				<xsl:value-of select="$dist"/>
			</xsl:when>
			<xsl:when test="$dist = 'mint' or $dist = 'region'">
				<xsl:text>geogname</xsl:text>
			</xsl:when>
			<xsl:when test="$dist = 'dynasty'">
				<xsl:text>famname</xsl:text>
			</xsl:when>
			<xsl:when test="$dist = 'state'">
				<xsl:text>corpname</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>persname</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="role">
		<xsl:if test="$dist != 'material' and $dist != 'denomination' and $dist != 'date' and $dist != 'coinType'">
			<xsl:value-of select="$dist"/>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="title" select="normalize-space(//*[local-name() = 'descMeta']/*[local-name() = 'title'])"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_series" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
						<type_series>
							<xsl:value-of select="."/>
						</type_series>
					</xsl:for-each>
				</list>
			</xsl:variable>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>

			<xsl:for-each select="$type_series//type_series">
				<xsl:variable name="type_series_uri" select="."/>

				<xsl:variable name="id-param">
					<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
						<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
							<xsl:copy-of select="."/>
						</object>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
				<object>
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>


			<!-- if the dist is dynasty or state, then grab the RDF for any org/dynasty linked to people -->
			<xsl:choose>
				<xsl:when test="$dist = 'dynasty' or $dist = 'state'">
					<xsl:variable name="first-iteration" as="element()*">
						<xsl:copy-of select="document($rdf_url)/rdf:RDF"/>
					</xsl:variable>

					<xsl:variable name="id-param">
						<xsl:for-each
							select="
								distinct-values($first-iteration/descendant::org:organization/@rdf:resource | $first-iteration/descendant::org:memberOf/@rdf:resource)">
							<xsl:value-of select="substring-after(., 'id/')"/>
							<xsl:if test="not(position() = last())">
								<xsl:text>|</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:variable name="org_rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>

					<xsl:copy-of select="$first-iteration/*"/>

					<xsl:copy-of select="document($org_rdf_url)/rdf:RDF/*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:variable>

	<!-- get the total number of coins that can be geographically mapped. the numeric visualization is based only on mappable coin groups, not the total -->
	<xsl:variable name="total-counts">
		<total>
			<xsl:for-each select="/nh:nudsHoard//nh:coin | /nh:nudsHoard//nh:coinGrp">

				<xsl:variable name="concept" as="element()*">
					<concept>
						<xsl:choose>
							<xsl:when test="nuds:typeDesc/@xlink:href">
								<xsl:variable name="href" select="nuds:typeDesc/@xlink:href"/>

								<xsl:choose>
									<xsl:when test="string($role)">
										<xsl:variable name="uris" as="element()*">
											<uris>
												<xsl:apply-templates
													select="$nudsGroup//object[@xlink:href = $href]/descendant::*[local-name() = $element and @xlink:role = $role][starts-with(@xlink:href, 'http://nomisma.org/id/')]"
													mode="extract-concepts">
													<xsl:sort select="@xlink:href" order="ascending"/>
												</xsl:apply-templates>
												
												<xsl:if test="$dist = 'dynasty' or $dist = 'state'">
													<xsl:apply-templates
														select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:persname[starts-with(@xlink:href, 'http://nomisma.org/id/')]"
														mode="extract-orgs">
														<xsl:sort select="@xlink:href" order="ascending"/>
													</xsl:apply-templates>
												</xsl:if>
											</uris>
										</xsl:variable>

										<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
										<xsl:value-of select="string-join($uris/uri, '/')"/>
									</xsl:when>
									<xsl:when test="$dist = 'coinType'">
										<xsl:attribute name="uri" select="$href"/>
										<xsl:attribute name="label"
											select="
												$nudsGroup//object[@xlink:href = $href]/descendant::nuds:descMeta/nuds:title[if (@xml:lang = $lang) then
													(@xml:lang = $lang)
												else
													'en']"
										/>
									</xsl:when>
									<xsl:when test="$dist = 'date'">
										<xsl:choose>
											<xsl:when test="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:date/@standardDate">
												<xsl:attribute name="date"
													select="number($nudsGroup//object[@xlink:href = $href]/descendant::nuds:date/@standardDate)"/>
											</xsl:when>
											<xsl:when test="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:toDate/@standardDate">
												<xsl:attribute name="date"
													select="number($nudsGroup//object[@xlink:href = $href]/descendant::nuds:toDate/@standardDate)"/>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="uris" as="element()*">
											<uris>
												<xsl:apply-templates
													select="$nudsGroup//object[@xlink:href = $href]/descendant::*[local-name() = $element][starts-with(@xlink:href, 'http://nomisma.org/id/')]"
													mode="extract-concepts">
													<xsl:sort select="@xlink:href" order="ascending"/>
												</xsl:apply-templates>
											</uris>
										</xsl:variable>

										<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
										<xsl:value-of select="string-join($uris/uri, '/')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="string($role)">
										<xsl:variable name="uris" as="element()*">
											<uris>
												<xsl:apply-templates
													select="descendant::*[local-name() = $element and @xlink:role = $role][starts-with(@xlink:href, 'http://nomisma.org/id/')]"
													mode="extract-concepts">
													<xsl:sort select="@xlink:href" order="ascending"/>
												</xsl:apply-templates>
												
												<xsl:if test="$dist = 'dynasty' or $dist = 'state'">
													<xsl:apply-templates
														select="descendant::nuds:persname[starts-with(@xlink:href, 'http://nomisma.org/id/')]"
														mode="extract-orgs">
														<xsl:sort select="@xlink:href" order="ascending"/>
													</xsl:apply-templates>
												</xsl:if>
											</uris>
										</xsl:variable>

										<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
										<xsl:value-of select="string-join($uris/uri, '/')"/>
									</xsl:when>
									<xsl:when test="$dist = 'coinType'">
										<!-- TODO: parse coin type URIs stored in the reference -->
									</xsl:when>
									<xsl:when test="$dist = 'date'">
										<xsl:choose>
											<xsl:when test="nuds:typeDesc/nuds:date/@standardDate">
												<xsl:attribute name="date" select="number(nuds:typeDesc/nuds:date/@standardDate)"/>
											</xsl:when>
											<xsl:when test="nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
												<xsl:attribute name="date" select="number(nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="uris" as="element()*">
											<uris>
												<xsl:apply-templates
													select="descendant::*[local-name() = $element][starts-with(@xlink:href, 'http://nomisma.org/id/')]"
													mode="extract-concepts">
													<xsl:sort select="@xlink:href" order="ascending"/>
												</xsl:apply-templates>
											</uris>
										</xsl:variable>

										<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
										<xsl:value-of select="string-join($uris/uri, '/')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</concept>
				</xsl:variable>

				<xsl:variable name="count" as="xs:integer">
					<xsl:choose>
						<xsl:when test="self::nh:coin">1</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="number(@minCount) and number(@maxCount)">
									<xsl:value-of select="round((@minCount + @maxCount) div 2)"/>
								</xsl:when>
								<xsl:when test="number(@minCount)">
									<xsl:value-of select="@minCount"/>
								</xsl:when>
								<xsl:when test="number(@maxCount)">
									<xsl:value-of select="@maxCount"/>
								</xsl:when>
								<xsl:when test="number(@count)">
									<xsl:value-of select="@count"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- only include a countable item when there is a concept -->
				<xsl:if test="string($concept//@uri) or string($concept//@date)">
					<item count="{$count}">
						<xsl:if test="$concept//@uri">
							<xsl:attribute name="uri" select="$concept/@uri"/>
						</xsl:if>
						<xsl:if test="$concept//@date">
							<xsl:attribute name="date" select="$concept/@date"/>
						</xsl:if>
						<xsl:if test="$concept//@label">
							<xsl:attribute name="label" select="$concept/@label"/>
						</xsl:if>
					</item>
				</xsl:if>

			</xsl:for-each>
		</total>
	</xsl:variable>

	<!-- NUDS Hoard templates -->
	<xsl:template match="/">
		<xsl:variable name="total">
			<xsl:choose>
				<xsl:when test="/nh:nudsHoard/nh:descMeta/nh:contentsDesc/nh:contents[@count or @minCount or @maxCount]">
					<xsl:apply-templates select="/nh:nudsHoard/nh:descMeta/nh:contentsDesc/nh:contents"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="
							sum(//nh:coinGrp[if (@certainty) then
								if (nuds:typeDesc/@certainty) then
									boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()
								else
									*
							else
								*]/@count) +
							count(//nh:coin[if (@certainty) then
								if (nuds:typeDesc/@certainty) then
									boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()
								else
									*
							else
								*])"
					/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<hoard id="{$id}" total="{$total}" title="{$title}">
			<xsl:choose>
				<xsl:when test="$dist = 'date'">
					<xsl:call-template name="date-distribution">
						<xsl:with-param name="total" select="$total"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$dist = 'coinType'">
					<xsl:call-template name="type-distribution">
						<xsl:with-param name="total" select="$total"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="concept-distribution">
						<xsl:with-param name="total" select="$total"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</hoard>
	</xsl:template>

	<xsl:template match="nh:contents">
		<xsl:choose>
			<xsl:when test="@count">
				<xsl:value-of select="@count"/>
			</xsl:when>
			<xsl:when test="@maxCount">
				<xsl:value-of select="@maxCount"/>
			</xsl:when>
			<xsl:when test="@minCount">
				<xsl:value-of select="@minCount"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- templates for different types of distributions -->
	<xsl:template name="date-distribution">
		<xsl:param name="total"/>

		<!-- generate a list of the distinct dates that appear in the total count list, with a cumulative result per value -->
		<xsl:variable name="distinct-counts" as="element()*">
			<dates>
				<xsl:for-each select="$total-counts//item">
					<xsl:sort select="@date" order="ascending" data-type="number"/>

					<xsl:variable name="date" select="@date"/>

					<xsl:if test="not(preceding-sibling::item/@date = $date)">
						<date>
							<xsl:attribute name="date" select="@date"/>
							<xsl:attribute name="count" select="sum($total-counts//item[@date = $date]/@count)"/>
							<xsl:value-of select="numishare:normalizeDate(@date)"/>
						</date>
					</xsl:if>
				</xsl:for-each>
			</dates>
		</xsl:variable>

		<xsl:for-each select="$distinct-counts//date">
			<xsl:sort select="@date" order="ascending" data-type="number"/>

			<item label="{.}" sort="{number(@date)}">
				<xsl:attribute name="num">
					<xsl:choose>
						<xsl:when test="$type = 'cumulative'">
							<xsl:value-of select="format-number(((@count + sum(preceding-sibling::date/@count)) div $total) * 100, '0.00')"/>
						</xsl:when>
						<xsl:when test="$type = 'percentage'">
							<xsl:value-of select="format-number((@count div $total) * 100, '0.00')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@count"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</item>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="concept-distribution">
		<xsl:param name="total"/>

		<!-- get a list of all occurrences of the given concept across all typeDescs, including combinations of uncertain ones -->
		<xsl:variable name="all-concepts" as="element()*">
			<concepts>
				<xsl:apply-templates select="$nudsGroup//nuds:typeDesc" mode="extract-concepts"/>
			</concepts>
		</xsl:variable>

		<xsl:for-each select="$all-concepts//concept[string(.)]">
			<xsl:sort select="."/>

			<xsl:variable name="uri" select="@uri"/>

			<xsl:if test="not(preceding-sibling::concept/@uri = $uri)">
				<item label="{.}">
					<xsl:attribute name="num">
						<xsl:choose>
							<xsl:when test="$type = 'count'">
								<xsl:value-of select="sum($total-counts//item[@uri = $uri]/@count)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number((sum($total-counts//item[@uri = $uri]/@count) div $total) * 100, '0.00')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</item>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- types should theoretically not occur more than once, and so the $total-counts is sufficient -->
	<xsl:template name="type-distribution">
		<xsl:param name="total"/>

		<xsl:for-each select="$total-counts//item">

			<item label="{@label}">
				<xsl:attribute name="num">
					<xsl:choose>
						<xsl:when test="$type = 'count'">
							<xsl:value-of select="@count"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number((number(@count) div $total) * 100, '0.00')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</item>
		</xsl:for-each>
	</xsl:template>

	<!-- extract the matching concept or group of concepts from each typeDesc -->
	<xsl:template match="nuds:typeDesc" mode="extract-concepts">
		<concept>
			<xsl:choose>
				<xsl:when test="string($role)">
					<xsl:variable name="uris" as="element()*">
						<uris>
							<xsl:apply-templates
								select="descendant::*[local-name() = $element and @xlink:role = $role][starts-with(@xlink:href, 'http://nomisma.org/id/')]"
								mode="extract-concepts">
								<xsl:sort select="@xlink:href" order="ascending"/>
							</xsl:apply-templates>
							
							<xsl:if test="$dist = 'dynasty' or $dist = 'state'">
								<xsl:apply-templates
									select="descendant::nuds:persname[starts-with(@xlink:href, 'http://nomisma.org/id/')]"
									mode="extract-orgs">
									<xsl:sort select="@xlink:href" order="ascending"/>
								</xsl:apply-templates>
							</xsl:if>
						</uris>
					</xsl:variable>

					<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
					<xsl:value-of select="string-join($uris/uri, '/')"/>
				</xsl:when>
				<xsl:when test="$dist = 'coinType'">
					<xsl:apply-templates select="$nudsGroup//nuds:title[@xml:lang = $lang]" mode="extract-concepts"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="uris" as="element()*">
						<uris>
							<xsl:apply-templates select="*[local-name() = $element][starts-with(@xlink:href, 'http://nomisma.org/id/')]" mode="extract-concepts">
								<xsl:sort select="@xlink:href" order="ascending"/>
							</xsl:apply-templates>
						</uris>
					</xsl:variable>

					<xsl:attribute name="uri" select="string-join($uris/uri/@uri, '|')"/>
					<xsl:value-of select="string-join($uris/uri, '/')"/>
				</xsl:otherwise>
			</xsl:choose>
		</concept>
	</xsl:template>

	<xsl:template match="*" mode="extract-concepts">
		<xsl:variable name="href" select="@xlink:href"/>

		<uri>
			<xsl:if test="@xlink:href">
				<xsl:attribute name="uri" select="@xlink:href"/>
			</xsl:if>

			<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
		</uri>
	</xsl:template>
	
	<!-- get the dynasty and corporate entities related to each person for state/dynasty distributions -->
	<xsl:template match="nuds:persname" mode="extract-orgs">
		<xsl:variable name="href" select="@xlink:href"/>
		
		<xsl:choose>
			<xsl:when test="$dist = 'state'">
				<xsl:apply-templates select="$rdf/*[@rdf:about = $href]/org:hasMembership" mode="extract-orgs"/>
			</xsl:when>
			<xsl:when test="$dist = 'dynasty'">
				<xsl:apply-templates select="$rdf/*[@rdf:about = $href]/org:memberOf" mode="extract-orgs"/>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="org:memberOf|org:organization" mode="extract-orgs">
		<xsl:variable name="href" select="@rdf:resource"/>
		
		<uri uri="{@rdf:resource}">			
			<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
		</uri>
	</xsl:template>
	
	<xsl:template match="org:hasMembership" mode="extract-orgs">
		<xsl:variable name="href" select="@rdf:resource"/>
		
		<xsl:apply-templates select="$rdf/org:Membership[@rdf:about = $href]/org:organization" mode="extract-orgs"/>
	</xsl:template>

</xsl:stylesheet>
