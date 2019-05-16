<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:template name="numishare:filterToMetamodel">
        <xsl:param name="subject"/>
        <xsl:param name="filter"/>

        <xsl:for-each select="tokenize($filter, ';')">
            <xsl:variable name="property" select="substring-before(normalize-space(.), ' ')"/>
            <xsl:variable name="object" select="substring-after(normalize-space(.), ' ')"/>
            <xsl:choose>
                <xsl:when test="$property = 'portrait' or $property = 'deity'">
                    <union>
                        <triple s="{$subject}" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
                        <triple s="{$subject}" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
                    </union>
                </xsl:when>
                <xsl:when test="$property = 'authPerson'">
                    <triple s="{$subject}" p="nmo:hasAuthority" o="{$object}"/>
                </xsl:when>
                <xsl:when test="$property = 'authCorp'">
                    <union>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="{$object}"/>
                        </group>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="?authority"/>
                            <triple s="?authority" p="org:hasMembership/org:organization" o="{$object}"/>
                        </group>
                    </union>
                </xsl:when>
                <xsl:when test="$property = 'from'">
                    <xsl:if test="$object castable as xs:integer">
                        <xsl:variable name="gYear" select="format-number(number($object), '0000')"/>

                        <triple s="{$subject}" p="nmo:hasStartDate" o="?startDate">
                            <xsl:attribute name="filter">
                                <xsl:text>(?startDate >= "</xsl:text>
                                <xsl:value-of select="$gYear"/>
                                <xsl:text>"^^xsd:gYear)</xsl:text>
                            </xsl:attribute>
                        </triple>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'to'">
                    <xsl:if test="$object castable as xs:integer">
                        <xsl:variable name="gYear" select="format-number(number($object), '0000')"/>

                        <triple s="{$subject}" p="nmo:hasEndDate" o="?endDate">
                            <xsl:attribute name="filter">
                                <xsl:text>(?endDate &lt;= "</xsl:text>
                                <xsl:value-of select="$gYear"/>
                                <xsl:text>"^^xsd:gYear)</xsl:text>
                            </xsl:attribute>
                        </triple>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'range'">
                    <xsl:if test="matches($object, '-?\d+\|-?\d+')">
                        <xsl:variable name="range" select="tokenize($object, '\|')"/>

                        <xsl:variable name="s">
                            <xsl:choose>
                                <xsl:when test="contains($filter, 'nmo:hasTypeSeriesItem')">
                                    <xsl:analyze-string select="$filter" regex="nmo:hasTypeSeriesItem\s(&lt;.*&gt;)">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$subject"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <triple s="{$s}" p="nmo:hasEndDate" o="?endDate">
                            <xsl:attribute name="filter">
                                <xsl:text>(?endDate &gt;= "</xsl:text>
                                <xsl:value-of select="format-number(number($range[1]), '0000')"/>
                                <xsl:text>"^^xsd:gYear &amp;&amp; ?endDate &lt;= "</xsl:text>
                                <xsl:value-of select="format-number(number($range[2]), '0000')"/>
                                <xsl:text>"^^xsd:gYear)</xsl:text>
                            </xsl:attribute>
                        </triple>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'nmo:hasTypeSeriesItem'">
                    <!-- get the measurements for all coins connected with a given type or any of its subtypes -->
                    <union>
                        <group>
                            <triple s="{$subject}" p="{$property}" o="{$object}"/>
                        </group>
                        <group>
                            <triple s="?broader" p="skos:broader+" o="{$object}"/>
                            <triple s="{$subject}" p="{$property}" o="?broader"/>
                        </group>
                    </union>
                </xsl:when>
                <xsl:otherwise>
                    <triple s="{$subject}" p="{$property}" o="{$object}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="numishare:distToMetamodel">
        <xsl:param name="object"/>
        <xsl:param name="dist"/>

        <xsl:choose>
            <xsl:when test="$dist = 'authPerson'">
                <triple s="?coinType" p="nmo:hasAuthority" o="{$object}"/>
                <triple s="{$object}" p="a" o="foaf:Person"/>
            </xsl:when>
            <xsl:when test="$dist = 'authCorp'">
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="{$object}"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="?authority"/>
                        <triple s="?authority" p="org:hasMembership/org:organization" o="{$object}"/>
                    </group>
                </union>
                <triple s="{$object}" p="a" o="foaf:Organization"/>
            </xsl:when>
            <xsl:when test="$dist = 'portrait' or $dist = 'deity'">
                <xsl:variable name="distClass"
                    select="
                        if ($dist = 'portrait') then
                            'foaf:Person'
                        else
                            'wordnet:Deity'"/>
                <union>
                    <triple s="?coinType" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
                    <triple s="?coinType" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
                </union>
                <triple s="{$object}" p="a" o="{$distClass}"/>
            </xsl:when>
            <xsl:when test="$dist = 'region'">
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasRegion" o="{$object}"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasMint" o="?mint"/>
                        <triple s="?mint" p="skos:broader+" o="{$object}"/>
                    </group>
                </union>
            </xsl:when>
            <xsl:otherwise>
                <triple s="?coinType" p="{$dist}" o="{$object}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
