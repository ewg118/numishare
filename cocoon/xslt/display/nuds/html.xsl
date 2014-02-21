<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:exsl="http://exslt.org/common" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="q"/>
	<xsl:param name="start"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="type"/>

	<!-- quantitative analysis parameters -->
	<xsl:param name="measurement"/>
	<xsl:param name="numericType"/>
	<xsl:param name="chartType"/>
	<xsl:param name="interval"/>
	<xsl:param name="fromDate"/>
	<xsl:param name="toDate"/>
	<xsl:param name="sparqlQuery"/>
	<xsl:variable name="tokenized_sparqlQuery" as="item()*">
		<xsl:sequence select="tokenize($sparqlQuery, '\|')"/>
	</xsl:variable>
	<xsl:variable name="duration" select="number($toDate) - number($fromDate)"/>

	<xsl:variable name="recordType" select="/content/nuds:nuds/@recordType"/>

	<xsl:variable name="nuds:typeDesc_resource">
		<xsl:if test="string(/content/nuds:nuds/nuds:descMeta/nuds:typeDesc/@xlink:href)">
			<xsl:value-of select="/content/nuds:nuds/nuds:descMeta/nuds:typeDesc/@xlink:href"/>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="nuds:typeDesc">
		<xsl:choose>
			<xsl:when test="string($nuds:typeDesc_resource)">
				<xsl:copy-of select="exsl:node-set($nudsGroup)/nudsGroup/object[@xlink:href = $nuds:typeDesc_resource]/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="/content/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:template name="nuds">
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:if test="$mode = 'compare'">
			<div class="compare_options">
				<a href="compare_results?q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}&amp;mode=compare{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
					class="back_results">« Search results</a>
				<xsl:text> | </xsl:text>
				<a href="id/{$id}">Full record »</a>
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
									<cinclude:include src="cocoon:/widget?uri={concat('http://nomisma.org/id/', $id)}&amp;template=display"/>
								</xsl:if>
							</div>
						</div>
						<div class="row">
							<div class="col-md-12">
								<xsl:if test="$recordType='conceptual' and (count(//nuds:associatedObject) &gt; 0 or string($sparql_endpoint))">
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

								<xsl:choose>
									<xsl:when test="$image_location = 'left'">
										<div class="row">
											<div class="col-md-4">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'right'">
										<div class="row">
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>

								<xsl:choose>
									<xsl:when test="$image_location = 'left'">
										<div class="row">
											<div class="col-md-8">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'right'">
										<div class="row">
											<div class="col-md-4">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
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
											<div class="col-md-6">
												<xsl:call-template name="nuds_content"/>
											</div>
											<div class="col-md-6">
												<xsl:call-template name="obverse_image"/>
											</div>
										</div>
										<div class="row">
											<div class="col-md-12">
												<xsl:call-template name="reverse_image"/>
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
				<!-- process $nuds:typeDesc differently -->
				<div>
					<xsl:if test="nuds:descMeta/nuds:physDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
						</div>
					</xsl:if>
					<!-- process $nuds:typeDesc differently -->
					<div class="metadata_section">
						<xsl:apply-templates select="exsl:node-set($nuds:typeDesc)/nuds:typeDesc">
							<xsl:with-param name="typeDesc_resource" select="$nuds:typeDesc_resource"/>
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
				<div class="row">
					<div class="col-md-6">
						<xsl:if test="nuds:descMeta/nuds:physDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
							</div>
						</xsl:if>
						<!-- process $nuds:typeDesc differently -->
						<div class="metadata_section">
							<xsl:apply-templates select="exsl:node-set($nuds:typeDesc)/*[local-name()='typeDesc']">
								<xsl:with-param name="typeDesc_resource" select="$nuds:typeDesc_resource"/>
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
						<xsl:if test="nuds:descMeta/nuds:findspotDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
							</div>
						</xsl:if>
					</div>
					<div class="col-md-6">
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
									</tr>
								</tbody>
							</table>
						</div>
						<p>Use the layer control along the right edge of the map (the "plus" symbol) to toggle map layers.</p>
						<ul id="term-list" style="display:none">
							<xsl:for-each select="document(concat($solr-url, 'select?q=id:&#x022;', $id, '&#x022;'))//arr">
								<xsl:if test="contains(@name, '_facet') and not(contains(@name, 'institution')) and not(contains(@name, 'collection')) and not(contains(@name, 'department'))">
									<xsl:variable name="name" select="@name"/>
									<xsl:for-each select="str">
										<li class="{$name}">
											<xsl:value-of select="."/>
										</li>
									</xsl:for-each>

								</xsl:if>
							</xsl:for-each>
						</ul>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
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
			<xsl:when test="exsl:node-set($nuds:typeDesc)/nuds:typeDesc/nuds:obverse">
				<xsl:for-each select="exsl:node-set($nuds:typeDesc)/nuds:typeDesc/nuds:obverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image">
						<xsl:if test="string($obverse_image)">
							<xsl:choose>
								<xsl:when test="contains($obverse_image, 'flickr.com')">
									<xsl:variable name="photo_id" select="substring-before(tokenize($obverse_image, '/')[last()], '_')"/>
									<a href="{numishare:get_flickr_uri($photo_id)}">
										<img src="{$obverse_image}" alt="{$side}"/>
									</a>

								</xsl:when>
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
						<img src="{if (contains($obverse_image, 'flickr.com')) then $obverse_image else concat($display_path, $obverse_image)}" alt="obverse"/>
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
			<xsl:when test="exsl:node-set($nuds:typeDesc)/nuds:typeDesc/nuds:reverse">
				<xsl:for-each select="exsl:node-set($nuds:typeDesc)/nuds:typeDesc/nuds:reverse">
					<xsl:variable name="side" select="local-name()"/>
					<div class="reference_image">
						<xsl:if test="string($reverse_image)">
							<xsl:choose>
								<xsl:when test="contains($reverse_image, 'flickr.com')">
									<xsl:variable name="photo_id" select="substring-before(tokenize($reverse_image, '/')[last()], '_')"/>
									<a href="{numishare:get_flickr_uri($photo_id)}">
										<img src="{$reverse_image}" alt="{$side}"/>
									</a>

								</xsl:when>
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
						<img src="{if (contains($reverse_image, 'flickr.com')) then $reverse_image else concat($display_path, $reverse_image)}" alt="reverse"/>
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
		<dl>
			<dt><xsl:value-of select="numishare:regularize_node('axis', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;http://nomisma.org/id/{$id}&gt;&amp;template=avgMeasurement&amp;measurement=axis"/>
			</dd>
			<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;http://nomisma.org/id/{$id}&gt;&amp;template=avgMeasurement&amp;measurement=diameter"/>
			</dd>
			<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>:</dt>
			<dd>
				<cinclude:include src="cocoon:/widget?constraints=nm:type_series_item &lt;http://nomisma.org/id/{$id}&gt;&amp;template=avgMeasurement&amp;measurement=weight"/>
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
