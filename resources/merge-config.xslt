<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dyn="http://exslt.org/dynamic"
  xmlns:mb="http://itude.com/schemas/MB/2.0"
  extension-element-prefixes="dyn">

  <xsl:output indent="yes" method="xml" encoding="utf-8"
    omit-xml-declaration="yes" />

  <xsl:param name="path" />
  <xsl:param name="includes" />
  <xsl:param name="comments" />

  <xsl:template match="@*|node()">
    <xsl:param name="depth" select="'/*'" />
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="depth" select="concat($depth, '/*')" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[local-name()='Include']">
    <xsl:param name="depth" />
    <xsl:if test="$includes = 'yes'">
      <xsl:copy-of select="." />
    </xsl:if>
    <xsl:if test="$comments = 'yes'">
      <xsl:comment> BEGIN include: <xsl:value-of select="@name" /> </xsl:comment>
    </xsl:if>
    <xsl:apply-templates
select="dyn:evaluate(concat('document(&quot;', $path, '/', @name, '&quot;)', $depth))">
      <xsl:with-param name="depth" select="$depth" />
    </xsl:apply-templates>
    <xsl:if test="$comments = 'yes'">
      <xsl:comment> END include: <xsl:value-of select="@name" /> </xsl:comment>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

