<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:param name="id" select="descendant::work/@id"/>
	<xsl:param name="exist-config"/>
	<xsl:param name="url">
		<xsl:value-of select="document(concat($exist-config, '/config.xml'))//url"/>
	</xsl:param>
	<xsl:param name="source">vra</xsl:param>
	<xsl:param name="image_url">
		<xsl:value-of select="document(concat($exist-config, '/config.xml'))//url"/>
	</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="descendant::work"/>
	</xsl:template>

	<xsl:template match="work">
		<fo:root>
			<fo:layout-master-set>
				<fo:simple-page-master master-name="A4-portrait" page-height="11in"
					page-width="8.5in" margin-top="1cm" margin-bottom="1cm" margin-left="1.5cm"
					margin-right="1.5cm">
					<fo:region-body margin-top="1.25cm" margin-bottom="1.5cm"/>
					<fo:region-before extent="1.25cm"/>
					<fo:region-after extent="1.5cm" margin-top="26.2cm"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="A4-portrait">
				<fo:static-content flow-name="xsl-region-before">
					<fo:block padding="3px" background-color="#EBEBEB" font-size="10px"
						border-right="1px solid #696969" border-bottom="1px solid #696969"
						border-left="1px solid #C8C8C8" border-top="1px solid #C8C8C8">Please cite:
							<xsl:value-of select="$url"/>id/<xsl:value-of select="$source"
							/>/<xsl:value-of select="@id"/>, <xsl:value-of select="document(concat($exist-config, '/config.xml'))/config/title"/>.</fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-after">
					<fo:block font-size="10px" font-weight="bold" text-align="center">
						<xsl:text>Page </xsl:text>
						<fo:page-number/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-weight="bold" font-size="150%">
						<xsl:value-of select="normalize-space(titleSet/display)"/>
						<xsl:if test="string(dateSet/display)">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="normalize-space(dateSet/display)"/>
						</xsl:if>
					</fo:block>
					<xsl:call-template name="descriptive_information"/>
					<xsl:if test="textrefSet or sourceSet">
						<fo:block space-after="12pt" text-align="center">
							<fo:leader rule-thickness="1px" leader-length="5in"
								leader-pattern="rule" color="#696969"/>
						</fo:block>
						<fo:block font-size="12px" font-weight="bold">
							<xsl:text>Bibliography</xsl:text>
						</fo:block>
						<fo:block font-size="10px" margin-left="20px">
							<xsl:apply-templates select="textrefSet | sourceSet"/>
						</fo:block>
					</xsl:if>
					<xsl:call-template name="archival_data"/>
					<xsl:for-each select="//image">
						<fo:block space-after="12pt" text-align="center">
							<fo:external-graphic width="3in"
								src="{concat($image_url, 'images/artifacts/screen/', @id, '.jpg')}"/>
							<fo:block font-size="10pt">
								<xsl:value-of select="titleSet/display"/>
							</fo:block>
						</fo:block>
					</xsl:for-each>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

	<xsl:template name="descriptive_information">
		<fo:block space-after="12pt" text-align="center">
			<fo:leader rule-thickness="1px" leader-length="5in" leader-pattern="rule"
				color="#696969"/>
		</fo:block>
		<fo:block font-size="12px" font-weight="bold">
			<xsl:text>Descriptive Information</xsl:text>
		</fo:block>
		<fo:table table-layout="fixed">
			<fo:table-column column-width="50%"/>
			<fo:table-column column-width="50%"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell padding-end="3pt" padding-after="3pt" padding-left="10px"
						padding-right="10px">
						<xsl:if test="agentSet/display">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Origination: </fo:inline>
								<xsl:value-of select="agentSet/display"/>
							</fo:block>
						</xsl:if>
						<xsl:if test="dateSet/display">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Date: </fo:inline>
								<xsl:value-of select="dateSet/display"/>
							</fo:block>
						</xsl:if>
						<xsl:if
							test="string(normalize-space(culturalContextSet/culturalContext[1]))">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Cultural Context: </fo:inline>
								<xsl:for-each select="ulturalContextSet/culturalContext">
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</fo:block>
						</xsl:if>
						<xsl:if test="string(normalize-space(worktypeSet/worktype[1]))">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Format: </fo:inline>
								<xsl:for-each select="worktypeSet/worktype">
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</fo:block>
						</xsl:if>
						<xsl:if test="string(normalize-space(techniqueSet/technique[1]))">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Technique: </fo:inline>
								<xsl:for-each select="techniqueSet/technique">
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</fo:block>
						</xsl:if>
						<xsl:if test="string(normalize-space(styleSet/style[1]))">
							<fo:block font-size="10px">
								<fo:inline font-weight="bold">Technique: </fo:inline>
								<xsl:for-each select="styleSet/style">
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</fo:block>
						</xsl:if>
					</fo:table-cell>
					<fo:table-cell padding-end="3pt" padding-before="3pt" padding-after="3pt"
						padding-right="10px" padding-left="30px">
						<xsl:apply-templates select="materialSet"/>
						<xsl:apply-templates select="measurementsSet"/>
						<xsl:apply-templates select="inscriptionSet/inscription"/>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template match="materialSet">
		<fo:block font-size="10px">
			<fo:inline font-weight="bold">Material: </fo:inline>
			<xsl:choose>
				<xsl:when test="string(normalize-space(display))">
					<xsl:value-of select="normalize-space(display)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="material">
						<xsl:if test="@type">
							<xsl:value-of
								select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>

					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="measurementsSet">
		<fo:block font-size="10px">
			<fo:inline font-weight="bold">Measurements: </fo:inline>
			<xsl:choose>
				<xsl:when test="string(normalize-space(display))">
					<xsl:value-of select="normalize-space(display)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="measurements">
						<xsl:if test="@type">
							<xsl:value-of
								select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>

					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="inscription">
		<fo:block font-size="10px">
			<fo:inline font-weight="bold">Inscription: </fo:inline>
			<xsl:if test="string(normalize-space(author))">
				<xsl:text>Author: </xsl:text>
			</xsl:if>
			<xsl:for-each select="author">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="string(normalize-space(author))">
				<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="string(normalize-space(position))">Position: </xsl:if>
			<xsl:for-each select="position">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="string(normalize-space(position))">
				<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:for-each select="text">
				<xsl:text>Text: </xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:if test="@type">
					<i>
						<xsl:text> (</xsl:text>
						<xsl:value-of
							select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
						<xsl:text>)</xsl:text>
					</i>
				</xsl:if>
			</xsl:for-each>

		</fo:block>

		<div>
			<xsl:choose>
				<xsl:when
					test="(string(normalize-space(inscription[1])) and string(normalize-space(display))) or string(normalize-space(inscription[2]))">
					<dt>
						<b>Inscriptions:</b>
					</dt>
				</xsl:when>
				<xsl:otherwise>
					<dt>
						<b>Inscription:</b>
					</dt>
				</xsl:otherwise>
			</xsl:choose>
			<dd>
				<xsl:if test="string(normalize-space(display))">
					<xsl:value-of select="normalize-space(display)"/>
				</xsl:if>
				<xsl:if test="string(normalize-space(inscription[1]))">
					<ul>
						<xsl:for-each select="inscription">
							<li>
								<b>Inscription:</b>
							</li>
							<xsl:for-each select="author">
								<li>
									<xsl:text>Author: </xsl:text>
									<xsl:value-of select="normalize-space(.)"/>
								</li>
							</xsl:for-each>
							<xsl:for-each select="text">
								<li>
									<xsl:text>Text: </xsl:text>
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:if test="@type">
										<i>
											<xsl:text> (</xsl:text>
											<xsl:value-of
												select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
											<xsl:text>)</xsl:text>
										</i>
									</xsl:if>
								</li>
							</xsl:for-each>
							<xsl:for-each select="position">
								<li>
									<xsl:text>Position: </xsl:text>
									<xsl:value-of select="normalize-space(.)"/>
								</li>
							</xsl:for-each>
						</xsl:for-each>
					</ul>
				</xsl:if>
			</dd>
		</div>
	</xsl:template>


	<xsl:template name="archival_data">
		<fo:block space-after="12pt" text-align="center">
			<fo:leader rule-thickness="1px" leader-length="5in" leader-pattern="rule"
				color="#696969"/>
		</fo:block>
		<fo:block font-size="12px" font-weight="bold">
			<xsl:text>Archival Data</xsl:text>
		</fo:block>
		<fo:block font-size="10px" margin-left="10px">
			<xsl:if test="string(normalize-space(@source))">
				<fo:block>
					<fo:inline font-weight="bold">Collection: </fo:inline>
					<xsl:value-of select="normalize-space(@source)"/>
				</fo:block>
				<xsl:apply-templates
					select="locationSet/location[@type='repository'] | locationSet/location[@type='exhibition'] | locationSet/location[@type='formerOwner'] | locationSet/location[@type='formerRepository'] | locationSet/location[@type='installation'] | locationSet/location[@type='intended'] | locationSet/location[@type='owner']"
					mode="archival_data"/>
				<xsl:if test="string(normalize-space(stateEditionSet/display))">
					<fo:block>
						<fo:inline font-weight="bold">State Edition: </fo:inline>
						<xsl:value-of select="normalize-space(stateEditionSet/display)"/>
					</fo:block>
				</xsl:if>
				<xsl:if test="string(normalize-space(rightsSet/display))">
					<fo:block>
						<fo:inline font-weight="bold">Rights Statement: </fo:inline>
						<xsl:value-of select="normalize-space(rightsSet/display)"/>
						<xsl:if test="string(normalize-space(rightsSet/notes[1]))">
							<xsl:text>. </xsl:text>
							<xsl:for-each select="rightsSet/notes">
								<xsl:value-of select="."/>
							</xsl:for-each>
						</xsl:if>
					</fo:block>
				</xsl:if>
			</xsl:if>
		</fo:block>

		<!--<xsl:apply-templates
			select="locationSet/location[@type='repository'] | locationSet/location[@type='exhibition'] | locationSet/location[@type='formerOwner'] | locationSet/location[@type='formerRepository'] | locationSet/location[@type='installation'] | locationSet/location[@type='intended'] | locationSet/location[@type='owner']"
			mode="archival_data"/>-->

	</xsl:template>


	<xsl:template match="locationSet/location" mode="archival_data">
		<fo:block>
			<fo:inline font-weight="bold"><xsl:value-of
					select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>: </fo:inline>
			<xsl:for-each select="name">
				<xsl:choose>
					<xsl:when test="@type='geographic'">
						<xsl:choose>
							<xsl:when test="string(normalize-space(@extent))">
								<xsl:value-of
									select="concat(upper-case(substring(@extent, 1, 1)), substring(@extent, 2))"/>
								<xsl:text>: </xsl:text>
							</xsl:when>
							<xsl:otherwise>Geographical Location: </xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
						<xsl:if test="@type">
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="not(position() = last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</fo:block>
	</xsl:template>

	<xsl:template match="sourceSet">
		<xsl:for-each select="source">
			<fo:block text-indent="-.5in" space-after="12pt" margin-left=".5in">
				<xsl:if test="string(normalize-space(@type))">
					<xsl:value-of select="normalize-space(@type)"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(name)"/>

				<xsl:if test="refid">
					<xsl:apply-templates select="refid"/>
				</xsl:if>

			</fo:block>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="textrefSet">
		<xsl:for-each select="textref">
			<fo:block text-indent="-.5in" space-after="12pt" margin-left=".5in">
				<xsl:if test="string(normalize-space(@type))">
					<xsl:value-of select="normalize-space(@type)"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(name)"/>

				<xsl:if test="refid">
					<xsl:apply-templates select="refid"/>
				</xsl:if>

			</fo:block>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="refid">
		<fo:block margin-left=".5in">
			<xsl:if test="string(normalize-space(@type))">
				<xsl:value-of
					select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@href">
					<fo:basic-link external-destination="url('{@href}')" text-decoration="underline"
						color="blue">
						<xsl:value-of select="normalize-space(.)"/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

</xsl:stylesheet>
