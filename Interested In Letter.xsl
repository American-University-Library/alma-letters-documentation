<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="header.xsl" />
    <xsl:include href="senderReceiver.xsl" />
    <xsl:include href="mailReason.xsl" />
    <xsl:include href="footer.xsl" />
    <xsl:include href="style.xsl" />


    <xsl:template match="/">
        <html>
            <head>
                <xsl:call-template name="generalStyle" />
            </head>

            <body>

            <xsl:if test="notification_data/poline_inventory/*">
                <xsl:message terminate="yes">This is for a physical item</xsl:message>
            </xsl:if>
            <xsl:if test="notification_data/message='Order was Cancelled.'">
	            <xsl:message terminate="yes">This order was cancelled</xsl:message>
            </xsl:if>

                <xsl:attribute name="style">
                    <xsl:call-template name="bodyStyleCss" />
                    <!-- style.xsl -->
                </xsl:attribute>

                <xsl:call-template name="head" />
                <!-- header.xsl -->
                <xsl:call-template name="senderReceiver" />
                <!-- SenderReceiver.xsl -->

                <br />
                <xsl:call-template name="toWhomIsConcerned" />
                <!-- mailReason.xsl -->
                <!--@@You_were_specify@@:-->
                <br />
                <table>
                    <tr>
                        <td>@@You_were_specify@@</td>
                    </tr>

                    <tr>
                        <td>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td>Most electronic resources are activated and available within 24 hours. Prior to activation, e-resources are not available for use.</td>
                        <br />
                    </tr>
                    <tr>

                        <td>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td>Once activated you can access it through the included link.</td>
                    </tr>
                </table>
                <table cellspacing="0" cellpadding="5" border="0">
                    <tr>
                        <td>
                            <br />
				@@title@@

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/title"/>

                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				Link:

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:element name="a">
                                <xsl:attribute name="href"> https://wrlc-amu.primo.exlibrisgroup.com/discovery/fulldisplay?context=L&amp;vid=01WRLC_AMU:prod&amp;search_scope=DN_and_CI&amp;tab=Everything&amp;lang=en&amp;docid=alma<xsl:value-of select="notification_data/mms_id"/>
                                </xsl:attribute> https://wrlc-amu.primo.exlibrisgroup.com/discovery/fulldisplay?context=L&amp;vid=01WRLC_AMU:prod&amp;search_scope=DN_and_CI&amp;tab=Everything&amp;lang=en&amp;docid=alma<xsl:value-of select="notification_data/mms_id"/>
                            </xsl:element>

                            <br />

                        </td>
                    </tr>
                </table>

                <!--<table cellspacing="0" cellpadding="5" border="0">
                    <tr>
                        <td>
                            <br />
				@@orderNumber@@	:

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/line_number"/>

                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				@@title@@ :

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/title"/>

                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				@@mmsId@@ :

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/mms_id"/>

                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				@@callNumber@@	:

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/poline_inventory/call_number"/>

                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				@@receivingNote@@ :

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/receiving_note"/>
                            <br />

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
				@@message@@	:

                            <br />

                        </td>
                        <td>
                            <br />
                            <xsl:value-of select="notification_data/message"/>

                            <br />

                        </td>
                    </tr>

                </table>-->
                <br />
                <table>
                    <tr>
                        <td>@@sincerely@@</td>
                        <br />
                    </tr>
                    <tr>
                        <td>@@department@@</td>
                    </tr>
                </table>

                <xsl:call-template name="lastFooter" />
                <!-- footer.xsl -->
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>