<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:include href="header.xsl" />
    <xsl:include href="senderReceiver.xsl" />
    <xsl:include href="mailReason.xsl" />
    <xsl:include href="footer.xsl" />
    <xsl:include href="style.xsl" />
    <xsl:include href="recordTitle.xsl" />
    <xsl:template match="/">
        <html>
            <head>
                <xsl:call-template name="generalStyle" />
            </head>
            <body>
                <xsl:attribute name="style">
                    <xsl:call-template name="bodyStyleCss" />
                    <!-- style.xsl -->
                </xsl:attribute>
                <xsl:call-template name="head" />
                <!-- header.xsl -->
                <div class="messageArea">
                    <div class="messageBody">
                        <br />
                        <br />
                        <xsl:choose>
                            <!--START OF SPRING 2020 EMAIL-->
                            <xsl:when test="notification_data/notification_type = 'SPRING_2020_DUE_DATE_CHANGE' ">
                                <p style="font-size: 14px;">Hello,</p>
                                <p style="font-size: 14px;">As we all work to adjust to the sudden changes of the last week, the Library remains committed to supporting all members of our community. To take a small step towards reducing stress in a stressful time, we are renewing all American University items not yet flagged as Lost through the end of the semester.</p>
                                <p style="font-size: 14px;">You can view all of your current loans by signing in to your library account through your home institution. If you have any questions please reach out to us by responding to this message or emailing <a href="mailto:circulation@american.edu">circulation@american.edu</a>.
                                </p>
                                <p style="font-size: 14px;">While we will be unable to provide you with physical resources this semester, we are expanding our digital services to support the American University online learning plan. To learn more about these changes please visit <a href="https://www.american.edu/library/covid19">https://www.american.edu/library/covid19</a>. Library staff and faculty will be available throughout the semester via email and chat to assist you.</p>
                                <p style="font-size: 14px;">Sincerely,</p>
                                <p style="font-size: 14px;">American University Library Access Services</p>
                                <!--END OF SPRING 2020 EMAIL-->
                            </xsl:when>
                        </xsl:choose>
                    </div>
                    <br />
                </div>
                <xsl:call-template name="lastFooter" />
                <!-- footer.xsl -->
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>