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

	<xsl:template name="nudsHoard">
		<xsl:apply-templates select="/content/nh:nudsHoard"/>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:call-template name="icons"/>
		<xsl:call-template name="nudsHoard_content"/>
		<xsl:call-template name="icons"/>
	</xsl:template>

	<xsl:template name="nudsHoard_content">
		<div class="yui-b">
			<div class="yui-g first">
				<h1>
					<xsl:value-of select="$id"/>
				</h1>
				<div class="yui-u first">
					<div id="timemap">
						<div id="mapcontainer">
							<div id="map"/>
						</div>
						<div id="timelinecontainer">
							<div id="timeline"/>
						</div>
					</div>
				</div>
				<div class="yui-u">
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
				</div>
			</div>
			<div class="yui-g">
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
							<div id="accordion">
								<h3>Visualization</h3>
								<div>
									<xsl:call-template name="visualization"/>
								</div>
								<h3>Data Download</h3>
								<div>
									<xsl:call-template name="data-download"/>
								</div>
							</div>
						</div>
					</div>
				</xsl:if>

			</div>
		</div>
	</xsl:template>

	<xsl:template match="nh:hoardDesc">
		<h2><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/></h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
			<xsl:if test="not(nh:deposit/nh:date)">
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

		</ul>
	</xsl:template>

	<xsl:template name="nh:contents">
		<h2><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/></h2>

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
				<a href="{$typeDesc_resource}" target="_blank">
					<xsl:value-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:title"/>
				</a>
				<br/>
				<xsl:if test="string(exsl:node-set($typeDesc)/nuds:typeDesc/nuds:denomination)">
					<xsl:value-of select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:denomination"/>
					<xsl:if test="string(exsl:node-set($typeDesc)/nuds:typeDesc/nuds:date) or string(exsl:node-set($typeDesc)/nuds:typeDesc/nuds:dateRange)">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="string(exsl:node-set($typeDesc)/nuds:typeDesc/nuds:date)">
						<xsl:value-of select="exsl:node-set($typeDesc)/nuds:typeDesc/nuds:date"/>
					</xsl:when>
					<xsl:when test="string(exsl:node-set($typeDesc)/nuds:typeDesc/nuds:dateRange)">
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
