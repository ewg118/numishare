<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all">
	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="calculate" select="doc('input:request')/request/parameters/parameter[name='calculate']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name='compare']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name='exclude']/value"/>
	<xsl:param name="options" select="doc('input:request')/request/parameters/parameter[name='options']/value"/>
	<xsl:template name="nudsHoard">
		<xsl:apply-templates select="/content/nh:nudsHoard"/>
	</xsl:template>
	<xsl:template match="nh:nudsHoard">
		<xsl:call-template name="icons"/>
		<xsl:call-template name="nudsHoard_content"/>
	</xsl:template>
	<xsl:template name="nudsHoard_content">
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="string(nh:descMeta/nh:title[@xml:lang=$lang])">
					<xsl:value-of select="nh:descMeta/nh:title[@xml:lang=$lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(nh:descMeta/nh:title[@xml:lang='en'])">
							<xsl:value-of select="nh:descMeta/nh:title[@xml:lang='en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(nh:descMeta/nh:title[1])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="row">
			<div class="col-md-12">
				<h1 property="dcterms:title">
					<xsl:if test="string(nh:descMeta/nh:title/@xml:lang)">
						<xsl:attribute name="lang" select="nh:descMeta/nh:title/@xml:lang"/>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="string($title)">
							<xsl:value-of select="$title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$id"/>
						</xsl:otherwise>
					</xsl:choose>
				</h1>
			</div>
		</div>
		<div class="row">
			<div class="col-md-6">
				<div class="content">
					<xsl:if test="nh:descMeta/nh:hoardDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nh:descMeta/nh:hoardDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nh:descMeta/nh:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nh:descMeta/nh:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nh:descMeta/nh:noteSet">
						<div class="metadata_section">
							<h3>
								<xsl:value-of select="numishare:regularize_node('noteSet', $lang)"/>
							</h3>
							<ul>
								<xsl:apply-templates select="nh:descMeta/nh:noteSet/nh:note" mode="descMeta"/>
							</ul>
						</div>
					</xsl:if>
				</div>
			</div>
			<div class="col-md-6">
				<div id="timemap">
					<div id="mapcontainer">
						<div id="map"/>
					</div>
					<div id="timelinecontainer">
						<div id="timeline"/>
					</div>
				</div>
				<div class="legend">
					<table>
						<tbody>
							<tr>
								<th style="width:100px">
									<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>
								</th>
								<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
								<td style="width:100px">
									<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
								</td>
								<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
								<td style="width:100px">
									<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<p>View map in <a href="{$display_path}map/{$id}">fullscreen</a>.</p>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<!--********************************* MENU ******************************************* -->
				<xsl:if test="count(nh:descMeta/nh:contentsDesc/nh:contents/*) &gt; 0">
					<ul class="nav nav-pills" id="tabs">
						<li class="active">
							<a href="#contents" data-toggle="pill">
								<xsl:value-of select="numishare:normalizeLabel('display_contents', $lang)"/>
							</a>
						</li>
						<li>
							<a href="#quantitative" data-toggle="pill">
								<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
							</a>
						</li>
					</ul>
					<div class="tab-content">
						<div class="tab-pane active" id="contents">
							<xsl:if test="nh:descMeta/nh:contentsDesc">
								<div class="metadata_section">
									<xsl:apply-templates select="nh:descMeta/nh:contentsDesc/nh:contents"/>
								</div>
							</xsl:if>
						</div>
						<div class="tab-pane" id="quantitative">
							<h1>
								<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
							</h1>
							<span style="display:none" id="vis-pipeline">
								<xsl:value-of select="$pipeline"/>
							</span>
							<ul class="nav nav-pills" id="quant-tabs">
								<li class="active">
									<a href="#visTab" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('display_visualization', $lang)"/>
									</a>
								</li>
								<li>
									<a href="#dateTab" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('display_date-analysis', $lang)"/>
									</a>
								</li>
								<li>
									<a href="#csvTab" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('display_data-download', $lang)"/>
									</a>
								</li>
							</ul>
							<div class="tab-content">
								<div class="tab-pane active" id="visTab">
									<xsl:call-template name="hoard-visualization">
										<xsl:with-param name="action" select="concat('./', $id, '#quantitative')"/>
									</xsl:call-template>
								</div>
								<div class="tab-pane" id="dateTab">
									<xsl:call-template name="date-vis">
										<xsl:with-param name="action" select="concat('./', $id, '#quantitative')"/>
									</xsl:call-template>
								</div>
								<div class="tab-pane" id="csvTab">
									<xsl:call-template name="data-download"/>
								</div>
								<span id="formId" style="display:none"/>
							</div>
						</div>
					</div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="nh:hoardDesc">
		<xsl:variable name="hasContents">
			<xsl:choose>
				<xsl:when test="count(parent::node()/nh:contentsDesc/nh:contents/*) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="contentsDesc" as="element()*">
			<xsl:copy-of select="parent::node()/nh:contentsDesc/nh:contents"/>
		</xsl:variable>
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		
		
		<ul>
			<xsl:apply-templates mode="descMeta"/>
			<xsl:if test="$hasContents = 'true'">
				<!-- display the closing date, handling only those types which are approved certainty codes -->
				<xsl:if test="not(nh:deposit/nh:date) and not(nh:deposit/nh:dateRange)">
					<xsl:variable name="all-dates" as="element()*">
						<dates>
							<xsl:for-each select="parent::node()/nh:contentsDesc/nh:contents/descendant::nuds:typeDesc">
								<xsl:if test="index-of(//config/certainty_codes/code[@accept='true'], @certainty)">
									<xsl:choose>
										<xsl:when test="string(@xlink:href)">
											<xsl:variable name="href" select="@xlink:href"/>
											<xsl:for-each select="$nudsGroup//object[@xlink:href=$href]/descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="number(.)"/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="descendant::*/@standardDate">
												<xsl:if test="number(.)">
													<date>
														<xsl:value-of select="number(.)"/>
													</date>
												</xsl:if>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>								
							</xsl:for-each>
						</dates>
					</xsl:variable>
					<xsl:variable name="dates" as="element()*">
						<dates>
							<xsl:for-each select="distinct-values($all-dates//date)">
								<xsl:sort data-type="number"/>
								<date>
									<xsl:value-of select="number(.)"/>
								</date>
							</xsl:for-each>
						</dates>
					</xsl:variable>
					<li>
						<b><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>: </b>
						<span property="nmo:hasClosing_date" content="{format-number($dates//date[last()], '0000')}" datatype="xsd:gYear">
							<xsl:value-of select="nh:normalize_date($dates//date[last()], $dates//date[last()])"/>
						</span>
					</li>
				</xsl:if>
				
				<!-- display total counts of distint denominations -->
				<xsl:variable name="total-counts" as="element()*">
					<total-counts>
						<xsl:for-each select="parent::node()/nh:contentsDesc/nh:contents/descendant::nuds:typeDesc">
							<xsl:choose>
								<xsl:when test="string(@xlink:href)">
									<xsl:variable name="href" select="@xlink:href"/>
									<xsl:apply-templates select="$nudsGroup//object[@xlink:href=$href]/descendant::nuds:typeDesc/nuds:denomination" mode="den">
										<xsl:with-param name="contentsDesc" select="$contentsDesc"/>
										<xsl:with-param name="lang" select="$lang"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="nuds:denomination" mode="den">
										<xsl:with-param name="contentsDesc" select="$contentsDesc"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="num" select="if (ancestor::nh:coin) then 1 else ancestor::nh:coinGrp/@count"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</total-counts>
				</xsl:variable>
				<xsl:variable name="denominations" as="element()*">
					<denominations>
						<xsl:for-each select="distinct-values($total-counts//*[local-name()='name' and string-length(normalize-space(.)) &gt; 0])">
							<xsl:variable name="name" select="."/>
							<name>
								<xsl:attribute name="count">
									<xsl:value-of select="sum($total-counts//*[local-name()='name'][.=$name]/@count)"/>
								</xsl:attribute>
								<xsl:value-of select="$name"/>
							</name>
						</xsl:for-each>
					</denominations>
				</xsl:variable>
				<xsl:if test="count($denominations//*[local-name()='name']) &gt; 0">
					<li>
						<b><xsl:value-of select="numishare:regularize_node('description', $lang)"/>: </b>
						<span property="dcterms:description">
							<xsl:for-each select="$denominations//*[local-name()='name']">
								<xsl:sort select="@count" order="descending" data-type="number"/>
								<xsl:value-of select="."/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="@count"/>
								<xsl:if test="not(position()=last())">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</span>
					</li>
				</xsl:if>
				<span style="display:none" property="dcterms:tableOfContents" rel="{concat($url, 'id/', $id, '#contents')}"/>
			</xsl:if>
		</ul>
	</xsl:template>
	<xsl:template match="nh:contents">
		<h3>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h3>
		<table class="table table-striped" typeof="dcmitype:Collection" about="{concat($url, 'id/', $id, '#contents')}" id="contents">
			<thead>
				<tr>
					<th style="width:10%;text-align:center">Count</th>
					<th>Description</th>
					<th style="width:10%;text-align:center"/>
				</tr>
			</thead>
			<tbody>				
				<xsl:apply-templates select="descendant::nh:coin|descendant::nh:coinGrp"/>				
			</tbody>
		</table>
	</xsl:template>
	<xsl:template match="nh:coin|nh:coinGrp">
		<xsl:variable name="obj-id" select="generate-id()"/>
		<xsl:variable name="typeDesc_resource">
			<xsl:if test="string(nuds:typeDesc/@xlink:href)">
				<xsl:value-of select="nuds:typeDesc/@xlink:href"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="typeDesc" as="element()*">
			<xsl:choose>
				<xsl:when test="string($typeDesc_resource)">
					<xsl:copy-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="nuds:typeDesc"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<td class="text-center">
				<xsl:value-of select="if(@count) then @count else 1"/>
			</td>
			<td>				
				<xsl:if test="string($typeDesc_resource)">
					<!-- display labels for certainty codes -->
					<xsl:variable name="code" select="nuds:typeDesc/@certainty"/>
					<xsl:variable name="codeNode" as="element()*">
						<xsl:copy-of select="//config/certainty_codes/code[. = $code]"/>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="string($code) and string($codeNode)">
							
							<xsl:choose>
								<xsl:when test="$codeNode/@position='before'">
									<h3>
										<xsl:value-of select="$codeNode/@label"/>
										<a rel="nmo:hasTypeSeriesItem" href="{$typeDesc_resource}" target="_blank">
											<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
										</a>
									</h3>									
								</xsl:when>
								<xsl:when test="$codeNode/@position='after'">
									<h3>										
										<a rel="nmo:hasTypeSeriesItem" href="{$typeDesc_resource}" target="_blank">
											<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
										</a>
										<xsl:value-of select="$codeNode/@label"/>
									</h3>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<h3>
								<a rel="nmo:hasTypeSeriesItem" href="{$typeDesc_resource}" target="_blank">
									<xsl:value-of select="$nudsGroup//object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
								</a>
							</h3>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$typeDesc/nuds:denomination">
						<xsl:for-each select="$typeDesc/nuds:denomination">
							<xsl:variable name="href" select="@xlink:href"/>
							<xsl:choose>
								<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
									<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="not(string(.))">
											<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], 'en')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="not(position()=last())">
									<xsl:text>, </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="parent::nuds:typeDesc/nuds:date or parent::nuds:typeDesc/nuds:dateRange">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$typeDesc/nuds:geographic/nuds:geogname">
						<xsl:for-each select="$typeDesc/nuds:geographic/nuds:geogname">
							<xsl:variable name="href" select="@xlink:href"/>
							<xsl:choose>
								<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
									<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="not(string(.))">
											<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], 'en')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="not(position()=last())">
									<xsl:text>, </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="parent::nuds:typeDesc/nuds:date or parent::nuds:typeDesc/nuds:dateRange">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$typeDesc/nuds:date">
						<xsl:value-of select="$typeDesc/nuds:date[1]"/>
					</xsl:when>
					<xsl:when test="$typeDesc/nuds:dateRange">
						<xsl:value-of select="$typeDesc/nuds:dateRange/nuds:fromDate"/>
						<xsl:text> - </xsl:text>
						<xsl:value-of select="$typeDesc/nuds:dateRange/nuds:toDate"/>
					</xsl:when>
				</xsl:choose>
				<div class="coin-content" id="{$obj-id}-div" style="display:none">
					<xsl:apply-templates select="nuds:physDesc"/>
					<xsl:apply-templates select="$typeDesc">
						<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="nuds:refDesc"/>
				</div>
			</td>
			<td style="width:10%;text-align:center">
				<a href="#" class="toggle-coin" id="{$obj-id}-link">[more]</a>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="nuds:denomination" mode="den">
		<xsl:param name="contentsDesc"/>
		<xsl:param name="lang"/>
		<xsl:param name="num"/>
		<xsl:variable name="href" select="@xlink:href"/>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="not(string(.))">
							<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$href], 'en')"/>
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
					<xsl:value-of select="$num"/>
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
