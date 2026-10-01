<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

    <xsl:include href="header.xsl" />
    <xsl:include href="senderReceiver.xsl" />
    <xsl:include href="mailReason.xsl" />
    <xsl:include href="footer.xsl" />
    <xsl:include href="style.xsl" />
    <xsl:include href="recordTitle.xsl" />

    <xsl:template match="/">

        <xsl:variable name="items_by_length">
            <xsl:for-each select="notification_data/item_loans/item_loan">
                <xsl:copy>
                    <xsl:attribute name="duration">
                        <xsl:call-template name="date-difference">
                            <xsl:with-param name="date1" select="loan_date" />
                            <xsl:with-param name="date2" select="due_date" />
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        <!-- 2. find items with duration > 1 
        <xsl:variable name="pass_items_by_length" select="exsl:node-set($items_by_length)/item_loan[@duration > 1]" />
        <xsl:if test="not($pass_items_by_length)">
            <xsl:message terminate="yes">no items pass</xsl:message>
        </xsl:if>

        <xsl:variable name="pass_items_by_library" select="count(notification_data/item_loans/item_loan[library_name !='Music Library (American University)'])" />
        <xsl:if test="$pass_items_by_library &lt; 1">
            <xsl:message terminate="yes">no items pass</xsl:message>
        </xsl:if>
        -->

        <html>
            <xsl:if test="notification_data/languages/string">
                <xsl:attribute name="lang">
                    <xsl:value-of select="notification_data/languages/string"/>
                </xsl:attribute>
            </xsl:if>

            <head>
                <title>
                    <xsl:value-of select="notification_data/general_data/subject"/>
                </title>

                <xsl:call-template name="generalStyle" />
            </head>
            <body>
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


                <div class="messageArea">
                    <div class="messageBody">

                        <table role='presentation' cellspacing="0" cellpadding="5" border="0">
                            <tr>
                                <td>
                                    <strong>@@message@@</strong>
                                    <br/>
                                    <br/>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <strong>@@loans@@</strong>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table role='presentation' cellpadding="5" class="listing">
                                        <xsl:attribute name="style">
                                            <xsl:call-template name="mainTableStyleCss" />
                                            <!-- style.xsl -->
                                        </xsl:attribute>
                                        <tr>
                                            <th>@@title@@</th>
                                            <th>@@description@@</th>
                                            <th>@@author@@</th>
                                            <th>@@due_date@@</th>
                                            <th>@@library@@</th>
                                        </tr>

                                        <xsl:for-each select="notification_data/item_loans/item_loan">
                                            <xsl:variable name="JDN_start_date">
                                                <xsl:call-template name="JDN">
                                                    <xsl:with-param name="date" select="loan_date" />
                                                </xsl:call-template>
                                            </xsl:variable>

                                            <xsl:variable name="JDN_end_date">
                                                <xsl:call-template name="JDN">
                                                    <xsl:with-param name="date" select="due_date" />
                                                </xsl:call-template>
                                            </xsl:variable>

                                        <!--    <xsl:if test="(($JDN_end_date - $JDN_start_date) &gt; 1) and (library_name !='Music Library (American University)')"> -->
                                        

                                                <tr>
                                                    <td>
                                                        <xsl:value-of select="title"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="description"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="author"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="new_due_date_str"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="library_name"/>
                                                    </td>

                                                </tr>
                                           <!-- </xsl:if> -->
                                        </xsl:for-each>

                                    </table>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <br />
				@@additional_info_1@@
                        <br />
			@@additional_info_2@@
                        <br />
                        <table role='presentation' >
                            <tr>
                                <td>@@sincerely@@</td>
                            </tr>
                            <tr>
                                <td>@@department@@</td>
                            </tr>
                        </table>

                    </div>
                </div>

                <!-- footer.xsl -->
                <xsl:call-template name="lastFooter" />
                <xsl:call-template name="myAccount" />
                <xsl:call-template name="contactUs" />
            </body>
        </html>
    </xsl:template>

    <xsl:template name="date-difference">
        <xsl:param name="date1"/>
        <xsl:param name="date2"/>
        <xsl:param name="JDN1">
            <xsl:call-template name="JDN">
                <xsl:with-param name="date" select="$date1" />
            </xsl:call-template>
        </xsl:param>
        <xsl:param name="JDN2">
            <xsl:call-template name="JDN">
                <xsl:with-param name="date" select="$date2" />
            </xsl:call-template>
        </xsl:param>
        <xsl:value-of select="$JDN2 - $JDN1"/>
    </xsl:template>

    <xsl:template name="JDN">
        <xsl:param name="date"/>
        <xsl:param name="year" select="substring($date, 7, 4)"/>
        <xsl:param name="month" select="substring($date, 1, 2)"/>
        <xsl:param name="day" select="substring($date, 4, 2)"/>
        <xsl:param name="a" select="floor((14 - $month) div 12)"/>
        <xsl:param name="y" select="$year + 4800 - $a"/>
        <xsl:param name="m" select="$month + 12*$a - 3"/>
        <xsl:value-of select="$day + floor((153*$m + 2) div 5) + 365*$y + floor($y div 4) - floor($y div 100) + floor($y div 400) - 32045" />
    </xsl:template>

</xsl:stylesheet>