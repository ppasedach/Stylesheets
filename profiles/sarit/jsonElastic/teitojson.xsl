<xsl:stylesheet
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    version="2.0"
    >
<!-- cf http://www.bramstein.com/projects/xsltjson/ for better
coverage -->
<xsl:strip-space elements="*"/>
<xsl:output method="text" encoding="utf-8" />
<xsl:variable name="inq">"</xsl:variable>
<xsl:variable name="outq">\\"</xsl:variable>

<xsl:template match="/">
  <xsl:apply-templates select="//TEI/text/body//p[not(ancestor::note)]" mode="pars"/>
  <xsl:apply-templates select="//TEI/text/body//lg[not(ancestor::note)]" mode="linegroups"/>
  <xsl:apply-templates select="//TEI/text/body//note" mode="notes"/>
</xsl:template>


<xsl:template name="makeJson">
  <xsl:param name="context"/>
  <xsl:text>{ "index" : { "_index": "saritindex", "_type": "element" }}</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>{  "tag" : "</xsl:text>
  <xsl:value-of select="local-name()"/>
  <xsl:text>", "path" : "</xsl:text>
  <xsl:value-of select="saxon:path()"/>
  <xsl:text>", "text" : "</xsl:text>
  <xsl:apply-templates />
  <xsl:text>"}</xsl:text>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template match="p">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="p" mode="pars">
  <xsl:call-template name="makeJson" />
</xsl:template>

<xsl:template match="lg">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="lg" mode="linegroups">
  <xsl:call-template name="makeJson"/>
</xsl:template>

<xsl:template match="note" />

<xsl:template match="note" mode="notes">
  <xsl:call-template name="makeJson"/>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="replace(replace(normalize-space(.),'\\','\\\\'),$inq,$outq)"/>
</xsl:template>

<xsl:template name="newline">
  <xsl:text>&#10;</xsl:text>
</xsl:template>
</xsl:stylesheet>
