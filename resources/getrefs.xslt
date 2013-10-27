<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dyn="http://exslt.org/dynamic"
  xmlns:mb="http://itude.com/schemas/MB/2.0"
  extension-element-prefixes="dyn">

  <xsl:output indent="yes" method="text" encoding="utf-8" />

  <xsl:param name="path" />

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <xsl:template match="*[local-name()='Include']">
    <xsl:value-of select="@name" />
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="dyn:evaluate(concat('document(&quot;', $path, '/', @name, '&quot;)'))" />
  </xsl:template>

</xsl:stylesheet>

