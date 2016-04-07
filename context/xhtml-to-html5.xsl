<?xml version="1.0" encoding="UTF-8"?>
<!--

An XHTML5-to-HTML5 Transform

Copyright (c) 2013 Peter S. May

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

- - -

More information follows the body.

-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:s="http://www.w3.org/2000/svg"
	xmlns:m="http://www.w3.org/1998/Math/MathML"
	xmlns:xlink="http://www.w3.org/1999/xlink"
>
	<xsl:output method="text" encoding="UTF-8" />
	<xsl:variable name="nl"><xsl:text><![CDATA[
]]></xsl:text></xsl:variable>
	<xsl:template match="/">
		<xsl:text><![CDATA[<!DOCTYPE html>]]></xsl:text>
		<xsl:value-of select="$nl"/>
		<xsl:apply-templates/>
		<xsl:value-of select="$nl"/>
	</xsl:template>

	<!--
		Elements
	-->

	<!--
		The elements processed are limited to the HTML, SVG, and MathML
		namespaces.
	-->
	<xsl:template match="h:* | s:* | m:*">
		<xsl:call-template name="known-element">
			<xsl:with-param name="this" select="."/>
			<xsl:with-param name="in-nonescaping-mode" select="false()"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="h:* | s:* | m:*" mode="nonescaping">
		<xsl:call-template name="known-element">
			<xsl:with-param name="this" select="."/>
			<xsl:with-param name="in-nonescaping-mode" select="true()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*"/>
	<xsl:template match="*" mode="nonescaping"/>

	<!--
		Comments
	-->
	<xsl:template match="comment()">
		<xsl:text><![CDATA[<!--]]></xsl:text>
		<xsl:value-of select="."/>
		<xsl:text><![CDATA[-->]]></xsl:text>
	</xsl:template>

	<!--
		Text
	-->
	<xsl:template match="text()">
		<xsl:call-template name="escape-cdata">
			<xsl:with-param name="text" select="."/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="text()" mode="nonescaping">
		<xsl:value-of select="."/>
	</xsl:template>

	<!--
		Element handling.
	-->
	<xsl:template name="known-element">
		<xsl:param name="this"/>
		<xsl:param name="in-nonescaping-mode"/>
		<xsl:variable name="is-html" select="boolean(self::h:*)"/>
		<xsl:variable name="is-void-element" select="boolean(
			self::h:area | self::h:base | self::h:basefont | self::h:bgsound |
			self::h:br | self::h:col | self::h:command | self::h:embed |
			self::h:frame | self::h:hr | self::h:img | self::h:input |
			self::h:keygen | self::h:link | self::h:meta | self::h:param |
			self::h:source | self::h:track | self::h:wbr
			)"/>
		<xsl:variable name="is-nonescaping-element" select="boolean(
			self::h:iframe | self::h:noembed | self::h:noframes | self::h:noscript
			| self::h:plaintext | self::h:script | self::h:style | self::h:xmp
			)"/>
		<xsl:value-of select="concat('&lt;', local-name())"/>
		<xsl:for-each select="@*">
			<xsl:variable name="prefix">
				<xsl:choose>
					<!--
						These namespace comparisons are done directly by URI because I
						couldn't get any self::PREFIX:* construction to work with
						attributes.
					-->
					<xsl:when test="namespace-uri() = ''"/>
					<xsl:when test="not($is-html) and namespace-uri() = 'http://www.w3.org/1999/xlink'">xlink:</xsl:when>
					<xsl:when test="namespace-uri() = 'http://www.w3.org/XML/1998/namespace'">
						<xsl:choose>
							<xsl:when test="$is-html">
								<xsl:choose>
									<xsl:when test="local-name() = 'lang'"/>
									<xsl:otherwise>:skip</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>xml:</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>:skip</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$prefix != ':skip'">
				<xsl:value-of select="concat(' ', $prefix, local-name())"/>
				<xsl:text>="</xsl:text>
				<xsl:call-template name="escape-attribute">
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="'&gt;'"/>
		<xsl:if test="not($is-void-element)">
			<xsl:if test="self::h:pre | self::h:textarea | self::h:listing">
				<xsl:value-of select="$nl"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$in-nonescaping-mode or $is-nonescaping-element">
					<xsl:apply-templates mode="nonescaping"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="concat('&lt;/', local-name(), '&gt;')"/>
		</xsl:if>
	</xsl:template>

	<!--
		Text escapes.
	-->
	<!--
		Implementation note: The replacements may occur out of their string order.
		This is okay because none of the searched terms is a substring of any other.
	-->
	<xsl:template name="escape-cdata">
		<xsl:param name="text"/>
		<xsl:variable name="sc">
			<xsl:choose>
				<xsl:when test="contains($text, '&amp;')">&amp;</xsl:when>
				<xsl:when test="contains($text, '&lt;')">&lt;</xsl:when>
				<xsl:when test="contains($text, '&gt;')">&gt;</xsl:when>
				<xsl:when test="contains($text, '&#xA0;')">&#xA0;</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$sc = ''"><xsl:value-of select="$text"/></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escape-cdata">
					<xsl:with-param name="text" select="substring-before($text, $sc)"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="$sc = '&amp;'"><![CDATA[&amp;]]></xsl:when>
					<xsl:when test="$sc = '&lt;'"><![CDATA[&lt;]]></xsl:when>
					<xsl:when test="$sc = '&gt;'"><![CDATA[&gt;]]></xsl:when>
					<xsl:when test="$sc = '&#xA0;'"><![CDATA[&nbsp;]]></xsl:when>
				</xsl:choose>
				<xsl:call-template name="escape-cdata">
					<xsl:with-param name="text" select="substring-after($text, $sc)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="escape-attribute">
		<xsl:param name="text"/>
		<xsl:variable name="sc">
			<xsl:choose>
				<xsl:when test="contains($text, '&amp;')">&amp;</xsl:when>
				<xsl:when test="contains($text, '&quot;')">&quot;</xsl:when>
				<xsl:when test="contains($text, '&#xA0;')">&#xA0;</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$sc = ''"><xsl:value-of select="$text"/></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escape-attribute">
					<xsl:with-param name="text" select="substring-before($text, $sc)"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="$sc = '&amp;'"><![CDATA[&amp;]]></xsl:when>
					<xsl:when test="$sc = '&quot;'"><![CDATA[&quot;]]></xsl:when>
					<xsl:when test="$sc = '&#xA0;'"><![CDATA[&nbsp;]]></xsl:when>
				</xsl:choose>
				<xsl:call-template name="escape-attribute">
					<xsl:with-param name="text" select="substring-after($text, $sc)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:transform>
<!--

Introduction
============

This transform is designed to translate an XHTML5 document to the vastly
more popular plain HTML syntax. It was borne largely of the annoyance
and general dirty feeling that comes with trying to generate a working
polyglot using XSLT (no direct way to output the terse new HTML5
`DOCTYPE`, acrobatics necessary to keep `<script/>` from rendering as a
void element when empty, and so forth). If you're using XSLT anyway and
aren't limited to only one transform, this may be the converter for you.


Features
========

The result of the transform, provided appropriate XHTML5 input, is a
HTML-syntax HTML5 document whose features include:

-   The all-important `<!DOCTYPE html>` leader.
-   UTF-8 encoding (if output directly).
    -   The meta charset is *not* automatically inserted; it must be
        provided in the source document.
-   All `CDATA` blocks resolved to text.
-   Unescaped text in selected elements such as `<script>` and
    `<style>`.
-   Double-quoted attributes.
    -   Attribute text allows unescaped `<` or `>`.
-   Omitted end tag on known void elements, such as `<img>`.
    -   Void elements have no self-closing slash.
-   Included end tag on all other elements, such as `<script></script>`,
    even when empty.
-   Elements from namespaces other than HTML, SVG, or MathML removed.
    -   This includes the default namespace.
-   Most attributes outside the default namespace are removed.
    -   On an HTML element, `xml:lang` is reverted to `lang`.
    -   On an SVG or MathML element, `xml:` and `xlink:` attributes are
        passed through.
-   Namespace declarations removed.

The transform itself is designed to be run using an XSLT 1.0 processor.
No extensions are required.


Omitted Features
================

This transform is a tool meant to translate already correct input into
what will generally be correct output. It is not a validator and does
only extremely narrow-scoped sanitization. Any validation, sanitization,
and so forth must be performed separately.

No pretty formatting of the output is provided. Most input, including
whitespace, is passed to the output, usually with some reformatting
(e.g. escaping changes, deletion). Therefore, in general, the
indentation of the output will resemble that of the input to some
degree.


Expectations of input
=====================

Like any XSLT, this transform operates on XML in general; it doesn't
necessarily require valid XHTML input. It also doesn't necessarily
output valid HTML (even for some contrived examples of valid XHTML
input).

However, valid HTML output should be produced if, for the input:

-   The document is valid XHTML5.
-   No namespaces are used for elements other than
    -   HTML: `http://www.w3.org/1999/xhtml`
    -   SVG: `http://www.w3.org/2000/svg`
    -   MathML: `http://www.w3.org/1998/Math/MathML`
-   The text of each comment does not lead with `>` or `->` and does not
    end with `-`.
    -   It must also not contain two `-` in a row, but this is also
        enforced by HTML
-   The text of each non-escaping element does not contain anything
    resembling a close tag for that element. Since escapes are disabled,
    there is no legal equivalent in HTML.
    -   In other words, `'<' '/' name ('>' | whitespace)`, where `name`
        is a case-insensitive match for the name of the element in
        question.
    -   For example, a `<script>` element should not contain
        `</script>`, `</SCRIPT>`, etc.
    -   The nonescaping elements include `<script/>`, `<style/>`, and
        some less common elements.

The input HTML must be in the XHTML namespace, and any embedded SVG or
MathML should use the appropriate namespace as well. To refresh your
memory:

Elements without one of the above namespaces, including elements with no
namespace, are ignored and not recursed.


Notes on output
===============

The output is performed using the "text" output method rather than
"html" or "xml" in order to retain fine control over the result.

The result document is strictly non-XML since it omits the self-closing
slashes on void elements, outputs characters disallowed by XML in
attribute data and the character data of certain elements, and strips
all namespace information. Crafting polyglot XHTML5 presents a vastly
non-trivial problem, and I am in no hurry to solve it in general
(substantial demand or arbitrary whims could potentially make me
reconsider). Currently, it's probably a better idea just to serve the
original XHTML when XML is needed and the converted version when HTML is
needed.


Alternatives
============

If your pipeline supports Java, the tools from the Validator.nu
htmlparser distribution are highly recommended as an alternative. Aside
from the de facto normative HTML5 parser, the htmlparser suite packs in
extremely useful tools for translating HTML to XHTML and back, as well
as an XSLT tool that can be run directly on HTML5.


Acknowledgement
===============

The inspiration for this transform, and a few important bits of its
being, originate in `nu.validator.htmlparser.sax.HtmlSerializer` from
htmlparser-1.4. `HtmlSerializer` is implemented on SAX, a streaming API,
so the actual implementation details for XSLT necessarily differ. Among
the borrowed parts are the lists of void, non-escaping, and
newline-started elements (which includes obsolete, deprecated, and
non-standard elements in addition to the standard ones), the attribute
prefix mappings, and the particular choice of which characters in cdata
and attributes are escaped to entities. This transform is not and does
not intend to be a perfect workalike to that module, but the results
should be similar on valid XHTML input.


Beware
======

This is not likely to be the final draft.

-->
