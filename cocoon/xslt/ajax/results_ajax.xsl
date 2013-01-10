<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs numishare" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../results_generic.xsl"/>
	<xsl:param name="display_path">
		<xsl:text/>
	</xsl:param>
	<xsl:param name="lang"/>

	<xsl:param name="q"/>
	<xsl:param name="sort"/>
	<xsl:param name="rows">24</xsl:param>
	<xsl:param name="start"/>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<xsl:template match="/">
		<xsl:variable name="place_string" select="replace(translate($tokenized_q[contains(., '_uri')], '&#x022;()', ''), '[a-z]+_uri:', '')"/>
		<xsl:variable name="places" select="tokenize($place_string, ' OR ')"/>

		<h1>
			<xsl:text>Place</xsl:text>
			<xsl:if test="contains($place_string, ' OR ')">
				<xsl:text>s</xsl:text>
			</xsl:if>
			<xsl:text>: </xsl:text>
			<xsl:for-each select="$places">
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<a id="clear_all" href="#">clear</a>
		</h1>
		<xsl:call-template name="paging"/>
		<div style="display:table;width:100%;">
			<xsl:apply-templates select="descendant::doc" mode="map"/>
		</div>
		<xsl:call-template name="paging"/>
	</xsl:template>

	<xsl:template match="doc" mode="map">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="numishare:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>

		<div class="g_doc">
			<span class="result_link">
				<a href="id/{str[@name='id']}{if (string($lang)) then concat('?lang=', $lang) else ''}" target="_blank">
					<xsl:value-of select="str[@name='title_display']"/>
				</a>
			</span>
			<dl>
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'hoard'">
						<div>
							<dt><xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>:</dt>
							<dd style="margin-left:150px;">
								<xsl:value-of select="arr[@name='findspot_facet']/str[1]"/>
							</dd>
						</div>
						<div>
							<dt><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>:</dt>
							<dd style="margin-left:150px;">
								<xsl:value-of select="str[@name='closing_date_display']"/>
							</dd>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('obverse', $lang)"/>:</dt>
								<dd style="margin-left:125px;">
									<xsl:value-of
										select="if (string-length(str[@name='obv_leg_display']) &gt; 30) then concat(substring(str[@name='obv_leg_display'], 1, 30), '...') else str[@name='obv_leg_display']"/>
									<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
										<xsl:text>: </xsl:text>
									</xsl:if>
									<xsl:value-of
										select="if (string-length(str[@name='obv_type_display']) &gt; 30) then concat(substring(str[@name='obv_type_display'], 1, 30), '...') else str[@name='obv_type_display']"
									/>
								</dd>
							</div>
						</xsl:if>
						<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('reverse', $lang)"/>:</dt>
								<dd style="margin-left:125px;">
									<xsl:value-of
										select="if (string-length(str[@name='rev_leg_display']) &gt; 30) then concat(substring(str[@name='rev_leg_display'], 1, 30), '...') else str[@name='rev_leg_display']"/>
									<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
										<xsl:text>: </xsl:text>
									</xsl:if>
									<xsl:value-of
										select="if (string-length(str[@name='rev_type_display']) &gt; 30) then concat(substring(str[@name='rev_type_display'], 1, 30), '...') else str[@name='rev_type_display']"
									/>
								</dd>
							</div>
						</xsl:if>
						<xsl:if test="int[@name='axis_num']">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>: </dt>
								<dd style="margin-left:150px;">
									<xsl:value-of select="int[@name='axis_num']"/>
								</dd>
							</div>
						</xsl:if>
						<xsl:if test="float[@name='diameter_num']">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>: </dt>
								<dd style="margin-left:150px;">
									<xsl:value-of select="float[@name='diameter_num']"/>
								</dd>
							</div>
						</xsl:if>
						<xsl:if test="float[@name='weight_num']">
							<div>
								<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>: </dt>
								<dd style="margin-left:150px;">
									<xsl:value-of select="float[@name='weight_num']"/>
								</dd>
							</div>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</dl>

			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="str[@name='recordType'] = 'physical'">
						<xsl:if test="string(str[@name='thumbnail_obv'])">
							<a class="thumbImage" href="{str[@name='reference_obv']}" title="Obverse of {str[@name='title_display']}">
								<img src="{str[@name='thumbnail_obv']}"/>
							</a>
						</xsl:if>
						<xsl:if test="string(str[@name='thumbnail_rev'])">
							<a class="thumbImage" href="{str[@name='reference_rev']}" title="Reverse of {str[@name='title_display']}">
								<img src="{str[@name='thumbnail_rev']}"/>
							</a>
						</xsl:if>
					</xsl:when>
					<xsl:when test="str[@name='recordType'] = 'conceptual'">
						<xsl:variable name="count" select="count(arr[@name='ao_uri']/str)"/>
						<xsl:variable name="title" select="str[@name='title_display']	"/>
						<xsl:variable name="docId" select="str[@name='id']"/>

						<xsl:if test="count(arr[@name='ao_thumbnail_obv']/str) &gt; 0">
							<xsl:variable name="nudsid" select="substring-before(arr[@name='ao_thumbnail_obv']/str[1], '|')"/>
							<a class="thumbImage" rel="{str[@name='id']}-gallery" href="{substring-after(arr[@name='ao_reference_obv']/str[contains(., $nudsid)], '|')}"
								title="Obverse of {$title}: {$nudsid}">
								<img src="{substring-after(arr[@name='ao_thumbnail_obv']/str[1], '|')}"/>
							</a>
							<xsl:if test="arr[@name='ao_thumbnail_rev']/str[contains(., $nudsid)]">
								<a class="thumbImage" rel="{str[@name='id']}-gallery" href="{substring-after(arr[@name='ao_reference_rev']/str[contains(., $nudsid)], '|')}"
									title="Reverse of {$title}: {$nudsid}">
									<img src="{substring-after(arr[@name='ao_thumbnail_rev']/str[contains(., $nudsid)], '|')}"/>
								</a>
							</xsl:if>
							<div style="display:none">
								<xsl:for-each select="arr[@name='ao_thumbnail_obv']/str[not(contains(., $nudsid))]">
									<xsl:variable name="thisId" select="substring-before(., '|')"/>
									<a class="thumbImage" rel="{$docId}-gallery" href="{substring-after(//arr[@name='ao_reference_obv']/str[contains(., $thisId)], '|')}"
										title="Obverse of {$title}: {$thisId}">
										<img src="{substring-after(., '|')}" alt="image"/>
									</a>
									<xsl:if test="//arr[@name='ao_thumbnail_rev']/str[contains(., $thisId)]">
										<a class="thumbImage" rel="{$docId}-gallery" href="{substring-after(ancestor::doc/arr[@name='ao_reference_rev']/str[contains(., $thisId)], '|')}"
											title="Reverse of {$title}: {$thisId}">
											<img src="{substring-after(//arr[@name='ao_thumbnail_rev']/str[contains(., $thisId)], '|')}"/>
										</a>
									</xsl:if>
								</xsl:for-each>
							</div>
						</xsl:if>
						<br/>
						<xsl:value-of select="concat($count, if($count = 1) then ' associated coin' else ' associated coins')"/>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
