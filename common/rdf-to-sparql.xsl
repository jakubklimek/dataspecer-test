<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns="http://www.w3.org/2005/sparql-results#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/rdf:RDF">
        <sparql>
            <head>
                <variable name="s"/>
                <variable name="p"/>
                <variable name="o"/>
            </head>
            <results>
                <xsl:for-each select="rdf:Description">
                    <xsl:call-template name="desc"/>
                </xsl:for-each>
            </results>
        </sparql>
    </xsl:template>

    <xsl:template name="desc">
        <xsl:variable name="id">
            <xsl:apply-templates select="@*"/>
        </xsl:variable>
        <xsl:for-each select="*">
            <xsl:call-template name="prop">
                <xsl:with-param name="subj">
                    <xsl:copy-of select="$id"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="prop">
        <xsl:param name="subj"/>
        <result>
            <binding name="s">
                <xsl:copy-of select="$subj"/>
            </binding>
            <binding name="p">
                <uri>
                    <xsl:value-of select="concat(namespace-uri(),local-name())"/>
                </uri>
            </binding>
            <binding name="o">
                <xsl:apply-templates select="@rdf:resource|@rdf:nodeID|text()"/>
            </binding>
        </result>
    </xsl:template>

    <xsl:template match="@xml:lang">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="@rdf:datatype">
        <xsl:attribute name="datatype">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@rdf:about|@rdf:resource">
        <uri>
            <xsl:value-of select="."/>
        </uri>
    </xsl:template>
    <xsl:template match="@rdf:nodeID">
        <bnode>
            <xsl:value-of select="."/>
        </bnode>
    </xsl:template>
    <xsl:template match="text()">
        <literal>
            <xsl:apply-templates select="parent::*/@xml:lang|parent::*/@rdf:datatype"/>
            <xsl:value-of select="."/>
        </literal>
    </xsl:template>

    <xsl:template match="@*|*"/>
</xsl:transform>