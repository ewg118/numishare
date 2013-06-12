<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:numishare="http://code.google.com/p/numishare/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>


	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="lang"/>
	<xsl:variable name="defaultLang" select="if (string($lang)) then $lang else 'en'"/>
	<xsl:param name="calculate"/>
	<xsl:param name="type"/>
	<xsl:param name="format"/>
	<xsl:param name="exclude"/>
	<xsl:variable name="codes" as="item()*">
		<xsl:sequence select="tokenize($exclude, ',')"/>
	</xsl:variable>

	<xsl:variable name="element">
		<xsl:choose>
			<xsl:when test="$calculate = 'material' or $calculate='denomination'">
				<xsl:value-of select="$calculate"/>
			</xsl:when>
			<xsl:when test="$calculate='mint' or $calculate='region'">
				<xsl:text>geogname</xsl:text>
			</xsl:when>
			<xsl:when test="$calculate='dynasty'">
				<xsl:text>famname</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>persname</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="role">
		<xsl:if test="$calculate != 'material' and $calculate != 'denomination' and $calculate != 'date' and $calculate != 'coinType'">
			<xsl:value-of select="$calculate"/>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name()='nudsid'])"/>
	<xsl:variable name="title" select="normalize-space(//*[local-name()='descMeta']/*[local-name()='title'])"/>

	<xsl:variable name="contentsDesc" as="element()*">
		<xsl:copy-of select="descendant::nh:contents"/>
	</xsl:variable>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<!-- get nomisma NUDS documents with get-nuds API -->
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[contains(@xlink:href, 'nomisma.org') and (boolean(index-of($codes, @certainty)) = false())]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="string-length($id-param) &gt; 0">
				<xsl:for-each select="document(concat('http://admin.numismatics.org/nomisma/apis/getNuds?identifiers=', $id-param))//nuds:nuds">
					<object xlink:href="http://nomisma.org/id/{nuds:nudsHeader/nuds:nudsid}">
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>

			<!-- incorporate other typeDescs which do not point to nomisma.org -->
			<xsl:for-each select="descendant::nuds:typeDesc[not(contains(@xlink:href, 'nomisma.org')) and (boolean(index-of($codes, @certainty)) = false())]">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<object xlink:href="{@xlink:href}">
							<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds"/>
						</object>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:gml="http://www.opengis.net/gml/">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href|$nudsGroup/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://admin.numismatics.org/nomisma/apis/getRdf?identifiers=', $id-param)"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$format='js'">
				<xsl:call-template name="generateJs"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="generateXml"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="generateJs">
		<xsl:variable name="total"
			select="sum($contentsDesc//nh:coinGrp[boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()]/@count) + count($contentsDesc//nh:coin[boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()])"/>
		<xsl:variable name="total-counts" as="element()*">
			<total-counts>
				<xsl:choose>
					<xsl:when test="string($role)">
						<xsl:apply-templates select="$nudsGroup//*[local-name()=$element][@xlink:role=$role]"/>
					</xsl:when>
					<xsl:when test="$calculate='date'">
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc/nuds:date|$nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:toDate"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$nudsGroup//*[local-name()=$element]"/>
					</xsl:otherwise>
				</xsl:choose>
			</total-counts>
		</xsl:variable>

		<xsl:text>{ name: "</xsl:text>
		<xsl:value-of select="normalize-space($title)"/>
		<xsl:text>", data: [</xsl:text>

		<xsl:choose>
			<xsl:when test="$calculate='date'">
				<!-- preprocess date counts into counts per distinct value -->
				<xsl:variable name="date-counts" as="element()*">
					<date-counts>
						<xsl:for-each select="distinct-values($total-counts//name)">
							<xsl:sort data-type="number" order="ascending"/>
							<xsl:variable name="name" select="."/>
							<name count="{sum($total-counts//name[.=$name]/@count)}">
								<xsl:value-of select="$name"/>
							</name>
						</xsl:for-each>
					</date-counts>
				</xsl:variable>

				<!-- output cumulative percentage -->
				<xsl:for-each select="$date-counts//name">
					<xsl:sort data-type="number" order="ascending"/>
					<xsl:variable name="name" select="."/>
					<xsl:text>[</xsl:text>
					<xsl:value-of select="$name"/>
					<xsl:text>,</xsl:text>
					<xsl:choose>
						<xsl:when test="$type='cumulative'">
							<xsl:value-of select="format-number(((@count + sum(preceding-sibling::name/@count)) div $total) * 100, '##.00')"/>
						</xsl:when>
						<xsl:when test="$type='count'">
							<xsl:value-of select="@count"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number((@count div $total) * 100, '##.00')"/>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:text>]</xsl:text>
					<xsl:if test="not(position()=last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template name="generateXml">
		<xsl:variable name="total"
			select="sum($contentsDesc//nh:coinGrp[boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()]/@count) + count($contentsDesc//nh:coin[boolean(index-of($codes, nuds:typeDesc/@certainty)) = false()])"/>
		<hoard id="{$id}" total="{$total}" title="{$title}">

			<xsl:variable name="total-counts" as="element()*">
				<total-counts>
					<xsl:choose>
						<xsl:when test="string($role)">
							<xsl:apply-templates select="$nudsGroup//*[local-name()=$element][@xlink:role=$role]"/>
						</xsl:when>
						<xsl:when test="$calculate='date'">
							<xsl:apply-templates select="$nudsGroup//nuds:typeDesc/nuds:date|$nudsGroup//nuds:typeDesc/nuds:dateRange/nuds:toDate"/>
						</xsl:when>
						<xsl:when test="$calculate='coinType'">
							<xsl:apply-templates select="$nudsGroup//nuds:title[@xml:lang=$defaultLang]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$nudsGroup//*[local-name()=$element]"/>
						</xsl:otherwise>
					</xsl:choose>
				</total-counts>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="$calculate='date'">
					<!-- preprocess date counts into counts per distinct value -->
					<xsl:variable name="date-counts" as="element()*">
						<date-counts>
							<xsl:for-each select="distinct-values($total-counts//name)">
								<xsl:sort data-type="number" order="ascending"/>
								<xsl:variable name="name" select="."/>
								<name count="{sum($total-counts//name[.=$name]/@count)}">
									<xsl:value-of select="$name"/>
								</name>
							</xsl:for-each>
						</date-counts>
					</xsl:variable>

					<!-- output cumulative percentage -->
					<xsl:for-each select="$date-counts//name">
						<xsl:sort data-type="number" order="ascending"/>
						<xsl:variable name="name" select="."/>
						<name>
							<xsl:attribute name="count">
								<xsl:choose>
									<xsl:when test="$type='cumulative'">
										<xsl:value-of select="format-number(((@count + sum(preceding-sibling::name/@count)) div $total) * 100, '##.00')"/>
									</xsl:when>
									<xsl:when test="$type='count'">
										<xsl:value-of select="@count"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number((@count div $total) * 100, '##.00')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:value-of select="$name"/>
						</name>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="distinct-values($total-counts//name)">
						<xsl:variable name="name" select="."/>
						<name>
							<xsl:attribute name="count">
								<xsl:variable name="count" select="sum($total-counts//name[.=$name]/@count)"/>
								<xsl:choose>
									<xsl:when test="$type='count'">
										<xsl:value-of select="$count"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(($count div $total) * 100, '##.00')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:value-of select="$name"/>
						</name>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

		</hoard>
	</xsl:template>

	<xsl:template match="*">
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="@standardDate">
					<xsl:value-of select="@standardDate"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string($defaultLang) and contains($href, 'nomisma.org')">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $defaultLang)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="source" select="ancestor::object/@xlink:href"/>
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="string($source)">
					<xsl:choose>
						<xsl:when test="$contentsDesc//nh:coin[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="count($contentsDesc//nh:coin/nuds:typeDesc[@xlink:href=$source])"/>
						</xsl:when>
						<xsl:when test="$contentsDesc//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="sum($contentsDesc//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]/@count)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="count($contentsDesc//nh:coin/nuds:typeDesc/*[local-name()=$element][.=$value]) + sum($contentsDesc//nh:coinGrp[nuds:typeDesc/*[local-name()=$element][.=$value]]/@count)"
					/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<name>
			<xsl:attribute name="count">
				<xsl:value-of select="$count"/>
			</xsl:attribute>
			<xsl:value-of select="$value"/>
		</name>
	</xsl:template>

</xsl:stylesheet>
