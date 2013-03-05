<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs numishare cinclude"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:cinclude="http://apache.org/cocoon/include/1.0" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="q"/>

	<xsl:template match="/">
		<xsl:apply-templates select="descendant::lst[@name='century_num']"/>
	</xsl:template>

	<xsl:template match="lst[@name='century_num']">
		<xsl:choose>
			<xsl:when test="count(int) = 0">
				<option disabled="disabled">No options available</option>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="int">
					<xsl:choose>
						<xsl:when test="number(@name) &lt; 0">
							<li>
								<span class="expand_century" century="{@name}" q="{$q}">
									<img src="images/{if (contains($q, concat(':\', @name))) then 'minus' else 'plus'}.gif" alt="expand"/>
								</span>
								<xsl:choose>
									<xsl:when test="contains($q, concat(':\',@name))">
										<input type="checkbox" value="{@name}" checked="checked" class="century_checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" value="{@name}" class="century_checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<!-- output for 1800s, 1900s, etc. -->
								<xsl:value-of select="numishare:normalize_century(@name)"/>
								<ul id="century_{@name}_list" class="decades-list" style="{if(contains($q, concat(':\',@name))) then '' else 'display:none'}">
									<xsl:if test="contains($q, concat(':',@name))">
										<cinclude:include src="cocoon:/get_decades?q={encode-for-uri($q)}&amp;century={@name}"/>d </xsl:if>
								</ul>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<span class="expand_century" century="{@name}" q="{$q}">
									<img src="images/{if (contains($q, concat(':', @name))) then 'minus' else 'plus'}.gif" alt="expand"/>
								</span>
								<xsl:choose>
									<xsl:when test="contains($q, concat(':',@name))">
										<input type="checkbox" value="{@name}" checked="checked" class="century_checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" value="{@name}" class="century_checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<!-- output for 1800s, 1900s, etc. -->
								<xsl:value-of select="numishare:normalize_century(@name)"/>
								<ul id="century_{@name}_list" class="decades-list" style="{if(contains($q, concat(':',@name))) then '' else 'display:none'}">
									<xsl:if test="contains($q, concat(':',@name))">
										<cinclude:include src="cocoon:/get_decades?q={encode-for-uri($q)}&amp;century={@name}"/>
									</xsl:if>
								</ul>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
