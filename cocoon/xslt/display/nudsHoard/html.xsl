<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/"
	xmlns:math="http://exslt.org/math" exclude-result-prefixes="xsl xs rdf xlink exsl numishare skos nuds nh nm math">

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="calculate"/>
	<xsl:param name="compare"/>
	<xsl:param name="type"/>
	<xsl:param name="chartType"/>
	<xsl:param name="exclude"/>
	<xsl:param name="options"/>

	<xsl:template name="nudsHoard">
		<xsl:apply-templates select="/content/nh:nudsHoard"/>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:call-template name="icons"/>
		<xsl:call-template name="nudsHoard_content"/>
		<xsl:call-template name="icons"/>
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

		<div class="yui3-u-1">
			<div class="content">
				<h1>
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
		<div class="yui3-u-1-2">
			<div class="content">
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
			</div>
		</div>
		<div class="yui3-u-1-2">
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
						<h2>
							<xsl:value-of select="numishare:regularize_node('noteSet', $lang)"/>
						</h2>
						<ul>
							<xsl:apply-templates select="nh:descMeta/nh:noteSet/nh:note" mode="descMeta"/>
						</ul>
					</div>
				</xsl:if>
			</div>
		</div>
		<div class="yui3-u-1">
			<div class="content">
				<!--********************************* MENU ******************************************* -->
				<xsl:if test="count(nh:descMeta/nh:contentsDesc/nh:contents/*) &gt; 0">
					<div id="tabs">
						<ul>
							<li>
								<a href="#contents">
									<xsl:value-of select="numishare:normalizeLabel('display_contents', $lang)"/>
								</a>
							</li>
							<li>
								<a href="#quantitative">
									<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
								</a>
							</li>
						</ul>
						<div id="contents">
							<xsl:if test="nh:descMeta/nh:contentsDesc">
								<div class="metadata_section">
									<xsl:call-template name="nh:contents"/>
								</div>
							</xsl:if>
						</div>
						<div id="quantitative">
							<h1>
								<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
							</h1>
							<span style="display:none" id="vis-pipeline">
								<xsl:value-of select="$pipeline"/>
							</span>
							<div id="quantTabs">
								<ul>
									<li>
										<a href="#visTab">
											<xsl:value-of select="numishare:normalizeLabel('display_visualization', $lang)"/>
										</a>
									</li>
									<li>
										<a href="#dateTab">
											<xsl:value-of select="numishare:normalizeLabel('display_date-analysis', $lang)"/>
										</a>
									</li>
									<li>
										<a href="#csvTab">
											<xsl:value-of select="numishare:normalizeLabel('display_data-download', $lang)"/>
										</a>
									</li>
								</ul>
								<div id="visTab">
									<xsl:call-template name="visualization">
										<xsl:with-param name="action" select="concat('./', $id, '#quantitative')"/>
									</xsl:call-template>
								</div>
								<div id="dateTab">
									<xsl:call-template name="date-vis">
										<xsl:with-param name="action" select="concat('./', $id, '#quantitative')"/>
									</xsl:call-template>
								</div>
								<div id="csvTab">
									<xsl:call-template name="data-download"/>
								</div>
							</div>
							<span id="formId" style="display:none"/>
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

		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
			<xsl:if test="not(nh:deposit/nh:date) and not(nh:deposit/nh:dateRange)">
				<!-- get date values for closing date -->
				<xsl:variable name="dates">
					<dates>
						<xsl:for-each select="distinct-values(exsl:node-set($nudsGroup)/descendant::*/@standardDate)">
							<xsl:sort data-type="number"/>
							<xsl:if test="number(.)">
								<date>
									<xsl:value-of select="number(.)"/>
								</date>
							</xsl:if>
						</xsl:for-each>
					</dates>
				</xsl:variable>
				<li>
					<b>Closing Date: </b>
					<xsl:choose>
						<xsl:when test="count(exsl:node-set($dates)/dates/date) &gt; 0">
							<xsl:value-of select="nh:normalize_date(exsl:node-set($dates)/dates/date[last()], exsl:node-set($dates)/dates/date[last()])"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Unknown</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</li>
			</xsl:if>
			<xsl:if test="$hasContents = 'true'">
				<xsl:variable name="denominations">
					<xsl:copy-of select="document(concat($url, 'get_hoard_quant?id=', $id, '&amp;calculate=denomination&amp;type=count'))"/>
				</xsl:variable>

				<li>
					<b>Description: </b>
					<xsl:for-each select="exsl:node-set($denominations)//*[local-name()='name']">
						<xsl:sort select="@count" order="descending" data-type="number"/>
						<xsl:value-of select="."/>
						<xsl:text>: </xsl:text>
						<xsl:value-of select="@count"/>
						<xsl:if test="not(position()=last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>
			</xsl:if>
		</ul>
	</xsl:template>

	<xsl:template name="nh:contents">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>

		<table style="width:100%">
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
		<xsl:variable name="typeDesc">
			<xsl:choose>
				<xsl:when test="string($typeDesc_resource)">
					<xsl:copy-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="nuds:typeDesc"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<tr>
			<td style="width:10%;text-align:center">
				<xsl:value-of select="if(@count) then @count else 1"/>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="nuds:typeDesc/@certainty='2'">
						<xsl:text>As </xsl:text>
					</xsl:when>
					<xsl:when test="nuds:typeDesc/@certainty='3'">
						<xsl:text>Copy of </xsl:text>
					</xsl:when>
					<xsl:when test="nuds:typeDesc/@certainty='4'">
						<xsl:text>Copy as </xsl:text>
					</xsl:when>
					<xsl:when test="nuds:typeDesc/@certainty='5'">
						<xsl:text>As issue </xsl:text>
					</xsl:when>
					<xsl:when test="nuds:typeDesc/@certainty='9'">
						<xsl:text>At least one of </xsl:text>
					</xsl:when>
				</xsl:choose>
				<a href="{$typeDesc_resource}" target="_blank">
					<xsl:value-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
				</a>
				<xsl:if test="nuds:typeDesc/@certainty='7'">
					<xsl:text> (extraneous)</xsl:text>
				</xsl:if>
				<br/>
				<xsl:for-each select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:denomination">
					<xsl:value-of select="."/>
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
				<xsl:choose>
					<xsl:when test="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:date">
						<xsl:value-of select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:date[1]"/>
					</xsl:when>
					<xsl:when test="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:dateRange">
						<xsl:value-of select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:dateRange/nuds:fromDate"/>
						<xsl:text> - </xsl:text>
						<xsl:value-of select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:dateRange/nuds:toDate"/>
					</xsl:when>
				</xsl:choose>
				<div class="coin-content" id="{$obj-id}-div" style="display:none">
					<xsl:apply-templates select="nuds:physDesc"/>
					<xsl:apply-templates select="exsl:node-set($typeDesc)/nuds:typeDesc">
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
</xsl:stylesheet>
