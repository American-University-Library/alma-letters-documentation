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
    
        
    <html>
		<head>
		<xsl:call-template name="generalStyle" />
		</head>
			<body>
			<xsl:attribute name="style">
				<xsl:call-template name="bodyStyleCss" /> <!-- style.xsl -->
			</xsl:attribute>
				<xsl:call-template name="head" /> <!-- header.xsl -->
				<xsl:call-template name="senderReceiver" /> <!-- SenderReceiver.xsl -->
				<br />
		    <xsl:call-template name="toWhomIsConcerned" /> <!-- mailReason.xsl -->

				
<!-- Start of different notification type code -->

<xsl:choose>
    <!-- NOTIFICATION TYPE 1 -->

    <xsl:when test="/notification_data/notification_type='OverdueNotificationType1'">
        <table cellspacing="0" cellpadding="5" border="0">
            <tr>
            <td>
                <h>@@inform_you_item_below_type1@@</h>
            </td>
            </tr>
        </table>

        <table cellpadding="5" class="listing">
            <xsl:attribute name="style">
            <xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
            </xsl:attribute>

            <xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
                <tr>
                    <td>
                        <table cellpadding="5" class="listing">
                            <xsl:attribute name="style">
                                <xsl:call-template name="mainTableStyleCss" />
                            </xsl:attribute>
                            <tr align="center" bgcolor="#f5f5f5">
                                <td colspan="9">
                                    <h3><xsl:value-of select="organization_unit/name" /></h3>
                                </td>
                            </tr>
                            <tr>
                                <th>@@lost_item@@</th>
                                <th>@@loan_date@@</th>
                                <th>@@due_date@@</th>
                                <th>@@call_number@@</th>
                                <th>@@barcode@@</th>
                            </tr>

                            <xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
                                <tr>
                                    <td><xsl:value-of select="item_loan/title"/></td>
                                    <td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
                                    <td><xsl:value-of select="item_loan/new_due_date_str"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
                                    <td><xsl:value-of select="item_loan/barcode"/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
                <hr/><br/>
            </xsl:for-each>
            <xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
                <tr>
                    <td>
                        <b>@@overdue_notification_fee@@ </b>
                        <xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
                    </td>
                </tr>
            </xsl:if>
            <br />
            <br />
            @@additional_info_1_type1@@
            <br />
            @@additional_info_2_type1@@
            <br />
            <table>
                <tr><td>@@sincerely@@</td></tr>
                <tr><td>@@department@@</td></tr>
            </table>
        </table>
    </xsl:when>

    <!-- NOTIFICATION TYPE 2 -->

    <xsl:when test="/notification_data/notification_type='OverdueNotificationType2'">
        <table cellspacing="0" cellpadding="5" border="0">
            <tr>
            <td>
                <h>@@inform_you_item_below_type2@@ </h>
                <!-- <h>@@decalred_as_lost_type2@@</h> -->
            </td>
            </tr>
        </table>

        <table cellpadding="5" class="listing">
            <xsl:attribute name="style">
            <xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
            </xsl:attribute>

            <xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
                <tr>
                    <td>
                        <table cellpadding="5" class="listing">
                            <xsl:attribute name="style">
                                <xsl:call-template name="mainTableStyleCss" />
                            </xsl:attribute>
                            <tr align="center" bgcolor="#f5f5f5">
                                <td colspan="8">
                                    <h3><xsl:value-of select="organization_unit/name" /></h3>
                                </td>
                            </tr>
                            <tr>
                                <th>@@lost_item@@</th>
                                <th>@@loan_date@@</th>
                                <th>@@due_date@@</th>
                                <th>@@call_number@@</th>
                                <th>@@barcode@@</th>
                                <th>@@charged_with_fines_fees@@</th>
                            </tr>

                            <xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
                                <tr>
                                    <td><xsl:value-of select="item_loan/title"/></td>
                                    <td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
                                    <td><xsl:value-of select="item_loan/new_due_date_str"/></td>
									<td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
                                    <td><xsl:value-of select="item_loan/barcode"/></td>
                                    <td>
                                        <xsl:for-each select="fines_fees_list/user_fines_fees">
                                            <b><xsl:value-of select="fine_fee_type_display"/>: </b><xsl:value-of select="fine_fee_ammount/normalized_sum"/>&#160;<xsl:value-of select="fine_fee_ammount/currency"/>&#160;<xsl:value-of select="ff"/>
                                            <br />
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
                <hr/><br/>
            </xsl:for-each>
            <xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
                <tr>
                    <td>
                        <b>@@overdue_notification_fee@@ </b>
                        <xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
                    </td>
                </tr>
            </xsl:if>
            <br />
            <br />
            @@additional_info_1_type2@@
            <br />
            @@additional_info_2_type2@@
            <br />
            <table>
                <tr><td>@@sincerely@@</td></tr>
                <tr><td>@@department@@</td></tr>
            </table>
        </table>
    </xsl:when>

    <!-- NOTIFICATION TYPE 3 -->

    <xsl:when test="/notification_data/notification_type='OverdueNotificationType3'">
        <table cellspacing="0" cellpadding="5" border="0">
            <tr>
            <td>
                <h>@@inform_you_item_below_type3@@ </h>
              <!--  <h>@@borrowed_by_you@@ @@decalred_as_lost_type3@@</h> -->
            </td>
            </tr>
        </table>

        <table cellpadding="5" class="listing">
            <xsl:attribute name="style">
            <xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
            </xsl:attribute>

            <xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
                <tr>
                    <td>
                        <table cellpadding="5" class="listing">
                            <xsl:attribute name="style">
                                <xsl:call-template name="mainTableStyleCss" />
                            </xsl:attribute>
                            <tr align="center" bgcolor="#f5f5f5">
                                <td colspan="8">
                                    <h3><xsl:value-of select="organization_unit/name" /></h3>
                                </td>
                            </tr>
                            <tr>
                                <th>@@lost_item@@</th>
                                <th>@@description@@</th>
                                <th>@@library@@</th>
                                <th>@@loan_date@@</th>
                                <th>@@due_date@@</th>
                                <th>@@barcode@@</th>
                                <th>@@call_number@@</th>
                                <th>@@charged_with_fines_fees@@</th>
                            </tr>

                            <xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
                                <tr>
                                    <td><xsl:value-of select="item_loan/title"/></td>
                                    <td><xsl:value-of select="item_loan/description"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/library_name"/></td>
									<td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
									<td><xsl:value-of select="item_loan/new_due_date_str"/></td>
                                    <td><xsl:value-of select="item_loan/barcode"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
                                    <td>
                                        <xsl:for-each select="fines_fees_list/user_fines_fees">
                                            <b><xsl:value-of select="fine_fee_type_display"/>: </b><xsl:value-of select="fine_fee_ammount/normalized_sum"/>&#160;<xsl:value-of select="fine_fee_ammount/currency"/>&#160;<xsl:value-of select="ff"/>
                                            <br />
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
                <hr/><br/>
            </xsl:for-each>
            <xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
                <tr>
                    <td>
                        <b>@@overdue_notification_fee@@ </b>
                        <xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
                    </td>
                </tr>
            </xsl:if>
            <br />
            <br />
            @@additional_info_1_type3@@
            <br />
            @@additional_info_2_type3@@
            <br />
            <table>
                <tr><td>@@sincerely@@</td></tr>
                <tr><td>@@department@@</td></tr>
            </table>
        </table>
    </xsl:when>

    <!-- NOTIFICATION TYPE 4 -->

    <xsl:when test="/notification_data/notification_type='OverdueNotificationType4'">
        <table cellspacing="0" cellpadding="5" border="0">
            <tr>
            <td>
                <h>@@inform_you_item_below_type4@@ </h>
               <!-- <h>@@borrowed_by_you@@ @@decalred_as_lost_type4@@</h> -->
            </td>
            </tr>
        </table>

        <table cellpadding="5" class="listing">
            <xsl:attribute name="style">
            <xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
            </xsl:attribute>

            <xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
                <tr>
                    <td>
                        <table cellpadding="5" class="listing">
                            <xsl:attribute name="style">
                                <xsl:call-template name="mainTableStyleCss" />
                            </xsl:attribute>
                            <tr align="center" bgcolor="#f5f5f5">
                                <td colspan="8">
                                    <h3><xsl:value-of select="organization_unit/name" /></h3>
                                </td>
                            </tr>
                            <tr>
                                <th>@@lost_item@@</th>
                                <th>@@description@@</th>
                                <th>@@library@@</th>
                                <th>@@loan_date@@</th>
                                <th>@@due_date@@</th>
                                <th>@@barcode@@</th>
                                <th>@@call_number@@</th>
                                <th>@@charged_with_fines_fees@@</th>
                            </tr>

                            <xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
                                <tr>
                                    <td><xsl:value-of select="item_loan/title"/></td>
                                    <td><xsl:value-of select="item_loan/description"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/library_name"/></td>
									<td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
									<td><xsl:value-of select="item_loan/new_due_date_str"/></td>
                                    <td><xsl:value-of select="item_loan/barcode"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
                                    <td>
                                        <xsl:for-each select="fines_fees_list/user_fines_fees">
                                            <b><xsl:value-of select="fine_fee_type_display"/>: </b><xsl:value-of select="fine_fee_ammount/normalized_sum"/>&#160;<xsl:value-of select="fine_fee_ammount/currency"/>&#160;<xsl:value-of select="ff"/>
                                            <br />
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
                <hr/><br/>
            </xsl:for-each>
            <xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
                <tr>
                    <td>
                        <b>@@overdue_notification_fee@@ </b>
                        <xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
                    </td>
                </tr>
            </xsl:if>
            <br />
            <br />
            @@additional_info_1_type4@@
            <br />
            @@additional_info_2_type4@@
            <br />
            <table>
                <tr><td>@@sincerely@@</td></tr>
                <tr><td>@@department@@</td></tr>
            </table>
        </table>
    </xsl:when>

    <!-- NOTIFICATION TYPE 5 -->

    <xsl:when test="/notification_data/notification_type='OverdueNotificationType5'">
        <table cellspacing="0" cellpadding="5" border="0">
            <tr>
            <td>
                <h>@@inform_you_item_below_type5@@ </h>
              <!--  <h>@@borrowed_by_you@@ @@decalred_as_lost_type5@@</h> -->
            </td>
            </tr>
        </table>

        <table cellpadding="5" class="listing">
            <xsl:attribute name="style">
            <xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
            </xsl:attribute>

            <xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
                <tr>
                    <td>
                        <table cellpadding="5" class="listing">
                            <xsl:attribute name="style">
                                <xsl:call-template name="mainTableStyleCss" />
                            </xsl:attribute>
                            <tr align="center" bgcolor="#f5f5f5">
                                <td colspan="8">
                                    <h3><xsl:value-of select="organization_unit/name" /></h3>
                                </td>
                            </tr>
                            <tr>
                                <th>@@lost_item@@</th>
                                <th>@@description@@</th>
                                <th>@@library@@</th>
                                <th>@@loan_date@@</th>
                                <th>@@due_date@@</th>
                                <th>@@barcode@@</th>
                                <th>@@call_number@@</th>
                                <th>@@charged_with_fines_fees@@</th>
                            </tr>

                            <xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
                                <tr>
                                    <td><xsl:value-of select="item_loan/title"/></td>
                                    <td><xsl:value-of select="item_loan/description"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/library_name"/></td>
									<td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
									<td><xsl:value-of select="item_loan/new_due_date_str"/></td>
                                    <td><xsl:value-of select="item_loan/barcode"/></td>
                                    <td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
                                    <td>
                                        <xsl:for-each select="fines_fees_list/user_fines_fees">
                                            <b><xsl:value-of select="fine_fee_type_display"/>: </b><xsl:value-of select="fine_fee_ammount/normalized_sum"/>&#160;<xsl:value-of select="fine_fee_ammount/currency"/>&#160;<xsl:value-of select="ff"/>
                                            <br />
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
                <hr/><br/>
            </xsl:for-each>
            <xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
                <tr>
                    <td>
                        <b>@@overdue_notification_fee@@ </b>
                        <xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
                    </td>
                </tr>
            </xsl:if>
            <br />
            <br />
            @@additional_info_1_type5@@
            <br />
            @@additional_info_2_type5@@
            <br />
            <table>
                <tr><td>@@sincerely@@</td></tr>
                <tr><td>@@department@@</td></tr>
            </table>
        </table>
    </xsl:when>

<!-- Default Condition -->
    <xsl:otherwise>
        <table cellspacing="0" cellpadding="5" border="0">
				<tr>
				<td>
					<h>@@inform_you_item_below@@ </h>
					<!-- <h>@@borrowed_by_you@@ @@decalred_as_lost@@</h> -->
				</td>
				</tr>
				</table>
				<table cellpadding="5" class="listing">
					<xsl:attribute name="style">
						<xsl:call-template name="mainTableStyleCss" /> <!-- style.xsl -->
					</xsl:attribute>

					<xsl:for-each select="notification_data/loans_by_library/library_loans_for_display">
						<tr>
							<td>
								<table cellpadding="5" class="listing">
									<xsl:attribute name="style">
										<xsl:call-template name="mainTableStyleCss" />
									</xsl:attribute>
									<tr align="center" bgcolor="#f5f5f5">
										<td colspan="8">
											<h3><xsl:value-of select="organization_unit/name" /></h3>
										</td>
									</tr>
									<tr>
										<th>@@lost_item@@</th>
										<th>@@description@@</th>
										<th>@@library@@</th>
										<th>@@loan_date@@</th>
										<th>@@due_date@@</th>
										<th>@@barcode@@</th>
										<th>@@call_number@@</th>
										<th>@@charged_with_fines_fees@@</th>
									</tr>

									<xsl:for-each select="item_loans/overdue_and_lost_loan_notification_display">
										<tr>
											<td><xsl:value-of select="item_loan/title"/></td>
											<td><xsl:value-of select="item_loan/description"/></td>
											<td><xsl:value-of select="physical_item_display_for_printing/library_name"/></td>
											<td><xsl:value-of select="item_loan/new_loan_date_str"/></td>
											<td><xsl:value-of select="item_loan/new_due_date_str"/></td>
											<td><xsl:value-of select="item_loan/barcode"/></td>
											<td><xsl:value-of select="physical_item_display_for_printing/call_number"/></td>
											<td>
												<xsl:for-each select="fines_fees_list/user_fines_fees">
													<b><xsl:value-of select="fine_fee_type_display"/>: </b><xsl:value-of select="fine_fee_ammount/normalized_sum"/>&#160;<xsl:value-of select="fine_fee_ammount/currency"/>&#160;<xsl:value-of select="ff"/>
													<br />
												</xsl:for-each>
											</td>
										</tr>
									</xsl:for-each>
								</table>
							</td>
						</tr>
						<hr/><br/>
						</xsl:for-each>
						<xsl:if test="notification_data/overdue_notification_fee_amount/sum !=''">
						<tr>
							<td>
								<b>@@overdue_notification_fee@@ </b>
								<xsl:value-of select="notification_data/overdue_notification_fee_amount/normalized_sum"/>&#160;<xsl:value-of select="notification_data/overdue_notification_fee_amount/currency"/>&#160;<xsl:value-of select="ff"/>
							</td>
						</tr>
						</xsl:if>
					<br />
					<br />
					@@additional_info_1@@
					<br />
					@@additional_info_2@@
					<br />
					<table>

							<tr><td>@@sincerely@@</td></tr>
							<tr><td>@@department@@</td></tr>

					</table>
				</table>
    </xsl:otherwise>

    </xsl:choose>
<!-- End of different notification type code -->

				<br />

				<xsl:call-template name="lastFooter" /> <!-- footer.xsl -->
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