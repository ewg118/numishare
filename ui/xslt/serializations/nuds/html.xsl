<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">

	<!-- quantitative analysis parameters -->
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name='measurement']/value"/>
	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name='numericType']/value"/>	
	<xsl:param name="interval" select="doc('input:request')/request/parameters/parameter[name='interval']/value"/>
	<xsl:param name="fromDate" select="doc('input:request')/request/parameters/parameter[name='fromDate']/value"/>
	<xsl:param name="toDate" select="doc('input:request')/request/parameters/parameter[name='toDate']/value"/>
	<xsl:param name="sparqlQuery" select="doc('input:request')/request/parameters/parameter[name='sparqlQuery']/value"/>
	<xsl:variable name="tokenized_sparqlQuery" as="item()*">
		<xsl:sequence select="tokenize($sparqlQuery, '\|')"/>
	</xsl:variable>
	<xsl:variable name="duration" select="number($toDate) - number($fromDate)"/>

	<xsl:template name="nuds">
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:if test="$mode = 'compare'">
			<div class="compare_options">
				<small>
					<a href="compare_results?q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}&amp;mode=compare{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
						class="back_results">« Search results</a>
					<xsl:text> | </xsl:text>
					<a href="id/{$id}">Full record »</a>
				</small>
			</div>
		</xsl:if>
		<!-- below is a series of conditionals for forming the image boxes and displaying obverse and reverse images, iconography, and legends if they are available within the EAD document -->
		<xsl:choose>
			<xsl:when test="not($mode = 'compare')">
				<xsl:choose>
					<xsl:when test="$recordType='conceptual'">
						<div class="row">
							<div class="col-md-12">
								<xsl:call-template name="icons"/>
								<h1 id="object_title">
									<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
								</h1>
								<a href="#examples"><xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/></a> | <a href="#charts"><xsl:value-of
										select="numishare:normalizeLabel('display_quantitative', $lang)"/></a>
							</div>
						</div>
						<xsl:call-template name="nuds_content"/>
						<div class="row">
							<div class="col-md-12">
								<xsl:if test="string($sparql_endpoint)">
									<a name="examples"/>
									<cinclude:include src="cocoon:/widget?uri={concat(//config/uri_space, $id)}&amp;template=display"/>
								</xsl:if>
							</div>
						</div>
						<div class="row">
							<div class="col-md-12">
								<xsl:if test="$recordType='conceptual' and string($sparql_endpoint) and //config/collection_type='cointype'">
									<xsl:call-template name="charts"/>
								</xsl:if>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="$recordType='physical'">
						<xsl:choose>
							<xsl:when test="$orientation = 'vertical'">
								<div class="row">
									<div class="col-md-12">
										<h1 id="object_title">
											<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
										</h1>
									</div>
								</div>

								<div class="row">
									<xsl:choose>
										<xsl:when test="$image_location = 'left'">
											<div class="col-md-4">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</div>
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
										</xsl:when>
										<xsl:when test="$image_location = 'right'">
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
											<div class="col-md-4">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</div>
										</xsl:when>
									</xsl:choose>
								</div>
							</xsl:when>
							<xsl:when test="$orientation = 'horizontal'">

								<div class="row">
									<div class="col-md-12">
										<h1 id="object_title">
											<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
										</h1>
									</div>
								</div>

								<xsl:choose>
									<xsl:when test="$image_location = 'top'">
										<div class="row">
											<div class="col-md-6">
												<xsl:call-template name="obverse_image"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="reverse_image"/>
											</div>
										</div>
										<div class="row">
											<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'bottom'">
										<div class="row">
											<div class="col-md-12">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
										<div class="row">
											<div class="col-md-6">
												<xsl:call-template name="reverse_image"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="obverse_image"/>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<div class="row">
					<div class="col-md-12">
						<xsl:call-template name="obverse_image"/>
						<xsl:call-template name="reverse_image"/>
						<xsl:call-template name="nuds_content"/>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="nuds_content">
		<!--********************************* MENU ******************************************* -->
		<xsl:choose>
			<xsl:when test="$mode = 'compare'">
				<!-- process $typeDesc differently -->
				<div>
					<xsl:if test="nuds:descMeta/nuds:physDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
						</div>
					</xsl:if>
					<!-- process $typeDesc differently -->
					<div class="metadata_section">
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
							<xsl:with-param name="typeDesc_resource" select="@xlink:href"/>
						</xsl:apply-templates>
					</div>
					<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:findspotDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
						</div>
					</xsl:if>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$recordType='conceptual'">
						<div class="row">
							<div class="col-md-6">
								<xsl:call-template name="metadata-container"/>
							</div>
							<div class="col-md-6">
								<xsl:call-template name="map-container"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="row">
							<div class="col-md-12">
								<ul class="nav nav-pills" id="tabs">
									<li class="active">
										<a href="#metadata" data-toggle="pill">
											<xsl:value-of select="numishare:normalizeLabel('display_summary', $lang)"/>
										</a>
									</li>
									<li>
										<a href="#mapTab" id="mapButton" data-toggle="pill">
											<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
										</a>
									</li>
								</ul>
								<div class="tab-content">
									<div class="tab-pane active" id="metadata">
										<xsl:call-template name="metadata-container"/>
									</div>
									<div class="tab-pane" id="mapTab">
										<xsl:call-template name="map-container"/>
									</div>
								</div>
							</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="metadata-container">
		<xsl:if test="nuds:descMeta/nuds:physDesc">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
			</div>
		</xsl:if>
		<!-- process $typeDesc differently -->
		<div class="metadata_section">			
			<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
				<xsl:with-param name="typeDesc_resource" select="@xlink:href"/>
			</xsl:apply-templates>
		</div>
		<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
			</div>
		</xsl:if>
		<xsl:if test="nuds:descMeta/nuds:refDesc">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
			</div>
		</xsl:if>
		<xsl:if test="nuds:descMeta/nuds:adminDesc">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc"/>
			</div>
		</xsl:if>
		<xsl:if test="nuds:descMeta/nuds:findspotDesc">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
			</div>
		</xsl:if>
		<xsl:if test="nuds:descMeta/nuds:subjectSet">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet"/>
			</div>
		</xsl:if>
		<xsl:if test="nuds:descMeta/nuds:noteSet">
			<div class="metadata_section">
				<xsl:apply-templates select="nuds:descMeta/nuds:noteSet"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="map-container">
		<h2>
			<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
		</h2>
		<xsl:choose>
			<xsl:when test="$recordType='conceptual'">
				<div id="timemap">
					<div id="mapcontainer">
						<div id="map"/>
					</div>
					<div id="timelinecontainer">
						<div id="timeline"/>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id="mapcontainer"/>
			</xsl:otherwise>
		</xsl:choose>
		<div class="legend">
			<table>
				<tbody>
					<tr>
						<th style="width:100px;background:none">
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
						<xsl:if test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
							<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
							<td style="width:100px">
								<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>
							</td>
						</xsl:if>
					</tr>
				</tbody>
			</table>
		</div>
		<p>View map in <a href="{$display_path}map/{$id}">fullscreen</a>.</p>
	</xsl:template>

	<xsl:template match="nuds:undertypeDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:choose>
					<xsl:when test="contains(@xlink:href, 'nomisma.org')">
						<xsl:variable name="elem" as="element()*">
							<findspot xlink:href="{@xlink:href}"/>
						</xsl:variable>
						<ul>
							<xsl:apply-templates select="$elem" mode="descMeta"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p>Source: <a href="{@xlink:href}"><xsl:value-of select="@xlink:href"/></a></p>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<ul>
					<xsl:apply-templates mode="descMeta"/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subjectSet|nuds:noteSet">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subject">
		<li>
			<b><xsl:value-of select="if (string(@localType)) then @localType else numishare:regularize_node(local-name(), $lang)"/>: </b>
			<a
				href="{$display_path}results?q={if (string(@localType)) then @localType else 'subject'}_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
				<xsl:value-of select="."/>
			</a>
			<xsl:if test="string(@xlink:href)">
				<a href="{@xlink:href}" target="_blank">
					<img src="{$display_path}images/external.png" alt="external link" class="external_link"/>
				</a>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="nuds:note">
		<li>
			<xsl:value-of select="."/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:provenance" mode="descMeta">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h4>
			<ul>
				<xsl:for-each select="descendant::nuds:chronItem">
					<li>
						<xsl:apply-templates select="*" mode="descMeta"/>
					</li>
				</xsl:for-each>
			</ul>
		</li>
	</xsl:template>

	<xsl:template name="obverse_image">
		<xsl:variable name="obverse_image">
			<xsl:if test="string(//mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)">
				<xsl:value-of select="//mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href"/>
			</xsl:if>
		</xsl:variable>

		<!-- display legend and type and image if available -->
		<xsl:choose>
			<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:obverse">
				<xsl:for-each select="$nudsGroup//nuds:typeDesc/nuds:obverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image">
						<xsl:if test="string($obverse_image)">
							<xsl:choose>								
								<xsl:when test="contains($obverse_image, 'http://')">
									<img src="{$obverse_image}" alt="{$side}"/>
								</xsl:when>
								<xsl:otherwise>
									<img src="{$display_path}{$obverse_image}" alt="{$side}"/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:if>

						<b>
							<xsl:value-of select="numishare:regularize_node($side, $lang)"/>
							<xsl:if test="string(nuds:legend) or string(nuds:type)">
								<xsl:text>: </xsl:text>
							</xsl:if>
						</b>
						<xsl:apply-templates select="nuds:legend"/>
						<xsl:if test="string(nuds:legend) and string(nuds:type)">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="nuds:type"/>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise only display the image -->
				<xsl:if test="string($obverse_image)">
					<div class="reference_image">
						<img src="{if (contains($obverse_image, 'http://')) then $obverse_image else concat($display_path, $obverse_image)}" alt="obverse"/>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="reverse_image">
		<xsl:variable name="reverse_image">
			<xsl:if test="string(//mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)">
				<xsl:value-of select="//mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href"/>
			</xsl:if>
		</xsl:variable>

		<!-- display legend and type and image if available -->
		<xsl:choose>
			<xsl:when test="$nudsGroup//nuds:typeDesc/nuds:reverse">
				<xsl:for-each select="$nudsGroup//nuds:typeDesc/nuds:reverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image">
						<xsl:if test="string($reverse_image)">
							<xsl:choose>								
								<xsl:when test="contains($reverse_image, 'http://')">
									<img src="{$reverse_image}" alt="{$side}"/>
								</xsl:when>
								<xsl:otherwise>
									<img src="{$display_path}{$reverse_image}" alt="{$side}"/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:if>

						<b>
							<xsl:value-of select="numishare:regularize_node($side, $lang)"/>
							<xsl:if test="string(nuds:legend) or string(nuds:type)">
								<xsl:text>: </xsl:text>
							</xsl:if>
						</b>
						<xsl:apply-templates select="nuds:legend"/>
						<xsl:if test="string(nuds:legend) and string(nuds:type)">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="nuds:type"/>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise only display the image -->
				<xsl:if test="string($reverse_image)">
					<div class="reference_image">
						<img src="{if (contains($reverse_image, 'http://')) then $reverse_image else concat($display_path, $reverse_image)}" alt="reverse"/>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- charts template -->
	<xsl:template name="charts">
		<a name="charts"/>
		<h2>
			<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
		</h2>
		<p>Average measurements for this coin type:</p>
		<dl class="dl-horizontal">
			<dt><xsl:value-of select="numishare:regularize_node('axis', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;{concat(//config/uri_space, $id)}&gt;&amp;template=avgMeasurement&amp;measurement=axis"/>
			</dd>
			<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;{concat(//config/uri_space, $id)}&gt;&amp;template=avgMeasurement&amp;measurement=diameter"/>
			</dd>
			<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;{concat(//config/uri_space, $id)}&gt;&amp;template=avgMeasurement&amp;measurement=weight"/>
			</dd>
		</dl>
		<xsl:call-template name="measurementForm"/>
	</xsl:template>

	<xsl:template match="nuds:chronList | nuds:list">
		<ul class="list">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:chronItem | nuds:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:choose>
			<xsl:when test="parent::nuds:chronItem">
				<i>
					<xsl:value-of select="."/>
				</i>
				<xsl:text>:  </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:event">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="nuds:eventgrp">
		<xsl:for-each select="nuds:event">
			<xsl:apply-templates select="."/>
			<xsl:if test="not(position() = last())">
				<xsl:text>; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
