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
                
                <!-- Dont send notice for loans that get converted to CLS requests -->
                <xsl:if test="notification_data/request/status_note_display='Converted to resource sharing request'">
                    <xsl:message terminate="yes">this has been converted to a CLS request!</xsl:message>
                </xsl:if>

                <!-- Dont send notice for booking requests  -->
                <xsl:if test="notification_data/request/request_type='BOOKING'">
                    <xsl:message terminate="yes">this is a booking request!</xsl:message>
                </xsl:if>

                <!-- Dont send notice for cdl digitization  -->
                <xsl:if test="notification_data/request/request_type='PHYSICAL_TO_DIGITIZATION' and (notification_data/phys_item_display/location_code='auzs' or notification_data/phys_item_display/location_code='auz')">
                    <xsl:message terminate="yes">this is a reserves digitization!</xsl:message>
                </xsl:if>

                <xsl:attribute name="style">
                    <xsl:call-template name="bodyStyleCss" />
                    <!-- style.xsl -->
                </xsl:attribute>

                <xsl:call-template name="senderReceiver" />
                <!-- SenderReceiver.xsl -->
                <xsl:call-template name="toWhomIsConcerned" />
                <!-- mailReason.xsl -->

                <div class="messageArea">
                    <div class="messageBody">
                        <table cellspacing="0" cellpadding="5" border="0">
                            <tr>
                                <td>
@@we_cancel_y_req_of@@  @@detailed_below@@ : 
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <xsl:call-template name="recordTitle" />
                                    <!-- recordTitle.xsl -->
                                </td>
                            </tr>

                            <!--Add barcode and mms for work orders-->
                            <xsl:if test="substring(notification_data/request/request_type, string-length(notification_data/request/request_type) - 1, 2) = 'WO'">
                                <tr>
                                    <td>MMS ID: <xsl:value-of select="notification_data/request/record_display_section/id" /></td>
                                </tr>
                                <tr>
                                    <td>Barcode: <xsl:value-of select="notification_data/phys_item_display/barcode" /></td>
                                </tr>
                            </xsl:if>

                            <xsl:if test="notification_data/request/request_type = 'BOOKING'">
                                <xsl:if test="notification_data/request/start_time != ''">
                                    <tr>
                                        <td>
                                            <b> @@start_time@@: </b>
                                            <xsl:value-of select="notification_data/booking_start_time_str" />
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="notification_data/request/end_time != ''">
                                    <tr>
                                        <td>
                                            <b> @@end_time@@: </b>
                                            <xsl:value-of select="notification_data/booking_end_time_str" />
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:if>
                            <xsl:call-template name="note_block"></xsl:call-template>
                            <xsl:if test="notification_data/request/request_type != 'BOOKING'">
                                <tr>
                                    <!--<td>
                                You may be able to obtain this item via <a href="'https://proxyau.wrlc.org/login?url=https://american.illiad.oclc.org/illiad/illiad.dll'">Interlibrary Loan</a>.
                                </td>-->
                                    <td>
                                        <xsl:variable name="metadata_scope">
                                            <xsl:choose>
                                                <xsl:when test="boolean(notification_data/metadata/node())">
                                                    <xsl:value-of select="'metadata'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'phys_item_display'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:call-template name="generate_url">
                                            <xsl:with-param name="metadata_scope" select="$metadata_scope"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                            </xsl:if>
                        </table>
                        <br />
                        <table>

                            <tr>
                                <td>@@sincerely@@,</td>
                            </tr>
                            <tr>
                                <td>@@department@@</td>
                            </tr>

                        </table>
                    </div>
                </div>
                <xsl:call-template name="lastFooter" />
                <!-- footer.xsl -->
                <xsl:call-template name="contactUs" />
            </body>
        </html>

    </xsl:template>

    <!-- Contains the logic for generating an ILLiad OpenURL, where appropriate-->
    <xsl:template name="generate_url">
        <xsl:param name="metadata_scope"/>
        <xsl:variable name="base_url" select="'https://american.illiad.oclc.org/illiad/illiad.dll/'"/>
        <xsl:choose>

            <xsl:when test="(notification_data/metadata/material_type = 'Article') or (notification_data/phys_item_display/material_type = 'Book')">

                <xsl:variable name="material_type" select="notification_data/*[local-name()=$metadata_scope]/material_type"/>
                <xsl:variable name="title" select="notification_data/*[local-name()=$metadata_scope]/title"/>
                <xsl:variable name="author_first" select="substring-before(notification_data/*[local-name()=$metadata_scope]/author, ',')"/>
                <xsl:variable name="author_last" select="substring-after(notification_data/*[local-name()=$metadata_scope]/author, ', ')"/>
                <xsl:variable name="pub_place" select="notification_data/*[local-name()=$metadata_scope]/publication_place"/>
                <xsl:variable name="publisher" select="notification_data/*[local-name()=$metadata_scope]/publisher"/>
                <xsl:variable name="isbn" select="notification_data/*[local-name()=$metadata_scope]/isbn"/>
                <xsl:variable name="journal_title" select="notification_data/*[local-name()=$metadata_scope]/journal_title"/>
                <xsl:variable name="volume" select="notification_data/*[local-name()=$metadata_scope]/volume"/>
                <xsl:variable name="issue" select="notification_data/*[local-name()=$metadata_scope]/issue"/>
                <xsl:variable name="start_page" select="notification_data/*[local-name()=$metadata_scope]/start_page"/>
                <xsl:variable name="end_page" select="notification_data/*[local-name()=$metadata_scope]/end_page"/>
                <xsl:variable name="publication_date" select="notification_data/*[local-name()=$metadata_scope]/publication_date"/>
                <xsl:variable name="edition" select="notification_data/*[local-name()=$metadata_scope]/edition"/>
                <xsl:variable name="issn" select="notification_data/*[local-name()=$metadata_scope]/issn"/>

				You may <a href="{normalize-space($base_url)}OpenURL?rft.isbn={$isbn}&amp;rft.volume={$volume}&amp;rft.month=&amp;rft.genre={$material_type}&amp;rft.au=&amp;rft.pub={$publisher}&amp;rft.issue={$issue}&amp;rft.place={$pub_place}&amp;rft.title={$title}&amp;rft.stitle={$title}&amp;rft.btitle={$title}&amp;rft.jtitle={$journal_title}&amp;rft.aufirst={$author_first}&amp;linktype=openurl&amp;rft.atitle={$title}&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Aarticle&amp;rft.auinit1=&amp;rft.date={$publication_date}&amp;url_ver=Z39.88-2004&amp;rft.aulast={$author_last}&amp;rft.spage={$start_page}&amp;rft.epage={$end_page}&amp;rft.pmid=&amp;rfr_id=CLS">request this item</a> via Interlibrary Loan.
            </xsl:when>
            <xsl:otherwise>
                <a href="{$base_url}">You may be able to obtain this item via Interlibrary Loan.</a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="note_block">
        <xsl:if test="notification_data/request/note != ''">
            <tr>
                <td>
                    <b> @@request_note@@: </b>
                    <xsl:value-of select="notification_data/request/note" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="notification_data/request/approval_entity/note != ''">
            <tr>
                <td>
                    <b> Cancellation Detail: </b>
                    <xsl:value-of select="notification_data/request/approval_entity/note" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="notification_data/request/cancel_reason != ''">
            <tr>
                <td>
                    <b> @@request_cancellation_note@@: </b>
                    <xsl:value-of select="notification_data/request/cancel_reason" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="notification_data/request/status_note_display != ''">
            <tr>
                <td>
                    <b> @@reason_deleting_request@@: </b>
                    <xsl:value-of select="notification_data/request/status_note_display" />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>