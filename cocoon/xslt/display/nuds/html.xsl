<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:exsl="http://exslt.org/common" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="xs xlink mets exsl numishare xsl skos xlink cinclude" version="2.0">

	<xsl:param name="q"/>
	<xsl:param name="weightQuery"/>
	<xsl:variable name="tokenized_weightQuery" select="tokenize($weightQuery, ' AND ')"/>
	<xsl:param name="start"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="type"/>

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
				<!-- determine whether the document has published findspots or associated object findspots -->
				<script type="text/javascript" langage="javascript">
                                                        $(function () {
                                                                $("#tabs").tabs({
                                                                        show: function (event, ui) {
                                                                                if (ui.panel.id == "mapTab" &amp;&amp; $('#mapcontainer').html().length == 0) {
                                                                                        $('#mapcontainer').html('');
                                                                                        initialize_map('<xsl:value-of select="$id"/>', '<xsl:value-of select="$display_path"/>');
                                                                                }
                                                                        }
                                                                });
                                                        });
                                                </script>
				<xsl:if test="$has_mint_geo = 'true'">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
				</xsl:if>
				<xsl:call-template name="icons"/>
				<xsl:choose>
					<xsl:when test="$recordType='conceptual'">
						<h1 id="object_title">
							<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
						</h1>
						<xsl:call-template name="nuds_content"/>

						<!-- show associated objects, preferencing those from Metis first -->
						<xsl:choose>
							<xsl:when test="string($sparql_endpoint)">
								<cinclude:include src="cocoon:/widget?uri={concat('http://numismatics.org/ocre/', 'id/', $id)}&amp;template=display"/>
							</xsl:when>
							<xsl:when test="count(nuds:digRep/nuds:associatedObject) &gt; 0">
								<div class="objects">
									<h2>Examples of this type</h2>
									<xsl:apply-templates select="nuds:digRep/nuds:associatedObject"/>
								</div>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$recordType='physical'">
						<xsl:choose>
							<xsl:when test="$orientation = 'vertical'">
								<div class="yui-g">
									<div class="yui-u first">
										<xsl:choose>
											<xsl:when test="$image_location = 'left'">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</xsl:when>
											<xsl:when test="$image_location = 'right'">
												<h1 id="object_title">
													<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
												</h1>
												<xsl:call-template name="nuds_content"/>
											</xsl:when>
										</xsl:choose>
									</div>
									<div class="yui-u">
										<xsl:choose>
											<xsl:when test="$image_location = 'left'">
												<h1 id="object_title">
													<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
												</h1>
												<xsl:call-template name="nuds_content"/>
											</xsl:when>
											<xsl:when test="$image_location = 'right'">
												<xsl:call-template name="obverse_image"/>
												<xsl:call-template name="reverse_image"/>
											</xsl:when>
										</xsl:choose>
									</div>
								</div>
							</xsl:when>
							<xsl:when test="$orientation = 'horizontal'">
								<h1 id="object_title">
									<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
								</h1>
								<xsl:choose>
									<xsl:when test="$image_location = 'top'">
										<div class="yui-g">
											<div class="yui-u first">
												<xsl:call-template name="obverse_image"/>
											</div>
											<div class="yui-u">
												<xsl:call-template name="reverse_image"/>
											</div>
										</div>
										<div>
											<xsl:call-template name="nuds_content"/>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'bottom'">
										<div>
											<xsl:call-template name="nuds_content"/>
										</div>
										<div class="yui-g">
											<div class="yui-u first">
												<xsl:call-template name="obverse_image"/>
											</div>
											<div class="yui-u">
												<xsl:call-template name="reverse_image"/>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
				<xsl:call-template name="icons"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="obverse_image"/>
				<xsl:call-template name="reverse_image"/>
				<xsl:call-template name="nuds_content"/>
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
				<div id="tabs">
					<ul>
						<li>
							<a href="#summary">
								<xsl:value-of select="numishare:normalizeLabel('display_summary', $lang)"/>
							</a>
						</li>
						<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
							<li>
								<a href="#mapTab">
									<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="$recordType='conceptual' and (count(//nuds:associatedObject) &gt; 0 or string($sparql_endpoint))">
							<li>
								<a href="#charts">
									<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="nuds:descMeta/nuds:adminDesc/*">
							<li>
								<a href="#administrative">
									<xsl:value-of select="numishare:normalizeLabel('display_administrative', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="nuds:description">
							<li>
								<a href="#commentary">
									<xsl:value-of select="numishare:normalizeLabel('display_commentary', $lang)"/>
								</a>
							</li>
						</xsl:if>

					</ul>
					<div id="summary">
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
						<xsl:if test="nuds:descMeta/nuds:findspotDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
							</div>
						</xsl:if>
					</div>
					<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
						<div id="mapTab">
							<h2>Map This Object</h2>
							<p>Use the layer control along the right edge of the map (the "plus" symbol) to toggle map layers.</p>
							<div id="mapcontainer"/>
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
					</xsl:if>
					<xsl:if test="$recordType='conceptual' and (count(//nuds:associatedObject) &gt; 0 or string($sparql_endpoint))">
						<div id="charts">
							<xsl:call-template name="charts"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:adminDesc/*">
						<div id="administrative">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="nuds:description">
						<div id="commentary">
							<xsl:apply-templates select="nuds:description"/>
						</div>
					</xsl:if>
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
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:variable name="currentLang" select="if (string($lang)) then $lang else 'en'"/>
				<xsl:variable name="label">
					<xsl:choose>
						<xsl:when test="contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$currentLang])">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$currentLang]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$href"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<p>Source: <a href="{@xlink:href}"><xsl:value-of select="$label"/></a></p>
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

	<xsl:template match="nuds:subjectSet">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates select="subject"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subject">
		<li>
			<xsl:choose>
				<xsl:when test="string(@type)">
					<b><xsl:value-of select="@type"/>: </b>
					<a href="{$display_path}results?q={@type}_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="."/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>
					<a href="{$display_path}results?q=subject_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="."/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
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

	<xsl:template match="nuds:associatedObject">
		<xsl:variable name="object">
			<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds/*"/>
		</xsl:variable>
		<div class="g_doc">
			<span class="result_link">
				<a href="{@xlink:href}" target="_blank">
					<xsl:value-of select="exsl:node-set($object)/nuds:descMeta/nuds:title"/>
				</a>
			</span>
			<xsl:if test="exsl:node-set($object)/nuds:digRep/mets:fileSec">
				<div class="gi_c">
					<xsl:if test="exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']">
						<xsl:choose>
							<xsl:when test="contains(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, 'flickr')">
								<xsl:variable name="photo_id"
									select="substring-before(tokenize(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, '/')[last()], '_')"/>
								<xsl:variable name="flickr_uri" select="numishare:get_flickr_uri($photo_id)"/>

								<a href="{$flickr_uri}" target="_blank" class="flickrthumb">
									<img class="gi" src="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href}"/>
								</a>
							</xsl:when>
							<xsl:when test="contains(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, 'http://')">
								<a href="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href}" class="thumbImage">
									<img class="gi" src="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href}"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a href="{concat($display_path, exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)}"
									class="thumbImage">
									<img class="gi"
										src="{concat($display_path, exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='obverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href)}"
									/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']">
						<xsl:choose>
							<xsl:when test="contains(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, 'flickr')">
								<xsl:variable name="photo_id"
									select="substring-before(tokenize(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, '/')[last()], '_')"/>
								<a
									href="{document(concat('http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', $flickr-api-key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']}"
									target="_blank" class="flickrthumb">
									<img class="gi" src="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href}"/>
								</a>
							</xsl:when>
							<xsl:when test="contains(exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href, 'http://')">
								<a href="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href}" class="thumbImage">
									<img class="gi" src="{exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href}"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a href="{concat($display_path, exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='reference']/mets:FLocat/@xlink:href)}"
									class="thumbImage">
									<img class="gi"
										src="{concat($display_path, exsl:node-set($object)/nuds:digRep/mets:fileSec/mets:fileGrp[@USE='reverse']/mets:file[@USE='thumbnail']/mets:FLocat/@xlink:href)}"
									/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</div>
			</xsl:if>
			<dl>
				<xsl:if test="exsl:node-set($object)/nuds:nudsHeader/nuds:publicationStmt/nuds:publisher">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('publisher', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="exsl:node-set($object)/nuds:nudsHeader/nuds:publicationStmt/nuds:publisher"/>
						</dd>
					</div>
				</xsl:if>
				<!--<xsl:if test="exsl:node-set($object)/nuds:descMeta/nuds:descMeta/nuds:adminDesc/nuds:owner">
					<div>
						<dt>Owner: </dt>
						<dd style="margin-left:125px;">
							<xsl:for-each select="exsl:node-set($object)/nuds:descMeta/nuds:adminDesc/nuds:owner">
								<xsl:value-of select="."/>
								<xsl:if test="not(position() = last())">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</dd>
					</div>
				</xsl:if>-->
				<xsl:if test="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:axis">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('axis', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:axis"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:measurementsSet/nuds:diameter">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:measurementsSet/nuds:diameter"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:measurementsSet/nuds:weight">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="exsl:node-set($object)/nuds:descMeta/nuds:physDesc/nuds:measurementsSet/nuds:weight"/>
						</dd>
					</div>
				</xsl:if>
			</dl>
		</div>
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
		<h2>
			<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
		</h2>
		<p>Average weight for this coin-type: <cinclude:include src="cocoon:/get_avg_weight?q=id:&#x022;{$id}&#x022;"/> grams</p>
		<xsl:if test="string($weightQuery)">
			<div id="{@name}-container" style="min-width: 400px; height: 400px; margin: 20px auto"/>
			<!-- class="calculate" -->
			<table class="calculate">
				<caption>Average Weight for Coin-Type: <xsl:value-of select="$id"/></caption>
				<thead>
					<tr>
						<th/>
						<th>Average Weight</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<th>
							<xsl:value-of select="$id"/>
						</th>
						<td>
							<cinclude:include src="cocoon:/get_avg_weight?q=id:&#x022;{$id}&#x022;"/>
						</td>
					</tr>
					<xsl:for-each select="$tokenized_weightQuery">
						<tr>
							<th>
								<xsl:value-of select="substring-after(translate(., '&#x022;', ''), ':')"/>
							</th>
							<td>
								<cinclude:include src="cocoon:/get_avg_weight?q={.}"/>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>

		<form id="charts-form" action="./{$id}#charts" style="margin:20px">
			<h3>Compare weights in related categories</h3>
			<!-- create checkboxes for available facets -->
			<xsl:for-each select="//nuds:material|//nuds:denomination|//nuds:department|//nuds:manufacture|//nuds:persname|//nuds:corpname|//nuds:famname|//nuds:geogname">
				<xsl:sort select="local-name()"/>
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang])">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="string($lang) and contains($href, 'geonames.org')">
							<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
							<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
							<xsl:choose>
								<xsl:when test="count(exsl:node-set($geonames_data)//alternateName[@lang=$lang]) &gt; 0">
									<xsl:for-each select="exsl:node-set($geonames_data)//alternateName[@lang=$lang]">
										<xsl:value-of select="."/>
										<xsl:if test="not(position()=last())">
											<xsl:text>/</xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="exsl:node-set($geonames_data)//name"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<!-- if there is no text value and it points to nomisma.org, grab the prefLabel -->
							<xsl:choose>
								<xsl:when test="not(string(normalize-space(.))) and contains($href, 'nomisma.org')">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="name">
					<xsl:choose>
						<xsl:when test="string(@xlink:role)">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
						<xsl:when test="string(@type)">
							<xsl:value-of select="@type"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="query_fragment" select="concat($name, '_facet:&#x022;', ., '&#x022;')"/>

				<xsl:choose>
					<xsl:when test="contains($weightQuery, $query_fragment)">
						<input type="checkbox" id="{$name}-checkbox" checked="checked" value="{$query_fragment}" class="weight-checkbox"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" id="{$name}-checkbox" value="{$query_fragment}" class="weight-checkbox"/>
					</xsl:otherwise>
				</xsl:choose>

				<label for="{$name}-checkbox">
					<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="$value"/>
				</label>
				<br/>
			</xsl:for-each>
			<div>
				<label>
					<xsl:text>Chart Type</xsl:text>
					<select name="type">
						<xsl:variable name="types">column,line,spline,area,areaspline,scatter</xsl:variable>
						<xsl:for-each select="tokenize($types, ',')">
							<option>
								<xsl:if test="$type = .">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
				</label>
			</div>
			<input type="hidden" name="weightQuery" id="weights-q" value=""/>
			<br/>
			<input type="submit" value="Modify Chart" id="submit-weights"/>
		</form>
	</xsl:template>

	<!--<xsl:when test="$field = 'category_facet'">
		<xsl:variable name="tokenized-category" select="tokenize(normalize-space(.), '-/-')"/>
		
		<xsl:for-each select="$tokenized-category">
			<xsl:variable name="category-query">
				<xsl:call-template name="assemble_category_query">
					<xsl:with-param name="level" as="xs:integer" select="position()"/>
					<xsl:with-param name="tokenized-category" select="$tokenized-category"/>
				</xsl:call-template>
			</xsl:variable>
			<a href="{$display_path}results?q=category_facet:({$category-query})">
				<xsl:value-of select="."/>
			</a>
			<xsl:if test="not(position() = last())">
				<xsl:text>-/-</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:when>-->

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
