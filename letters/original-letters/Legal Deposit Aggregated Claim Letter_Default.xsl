<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="header.xsl" />
  <xsl:include href="senderReceiver.xsl" />
  <xsl:include href="mailReason.xsl" />
  <xsl:include href="footer.xsl" />
  <xsl:include href="style.xsl" />

  <xsl:template match="/">
    <html>
		  <xsl:if test="notification_data/languages/string">
			  <xsl:attribute name="lang">
				  <xsl:value-of select="notification_data/languages/string"/>
			  </xsl:attribute>
		  </xsl:if>
      <body>
        <xsl:attribute name="style">
          <xsl:call-template name="bodyStyleCss" />
          <!-- style.xsl -->
        </xsl:attribute>
        <xsl:call-template name="head" />
        <!-- header.xsl -->
        <xsl:call-template name="senderReceiver" />
        <div class="messageArea">
          <div class="messageBody">
            <table role='presentation' cellspacing="0" cellpadding="5" border="0">
					<tr>
						<td>
							<h3><strong>@@Dear_Publisher@@</strong> <br /></h3>
							<xsl:value-of select="notification_data/claim/claim_text"/>
						</td>
					</tr>

			<tr>
					<td>
						<xsl:for-each select="notification_data/line_details_list/line_claim_letter_details">
							<table role='presentation' cellspacing="0" cellpadding="5" border="0">
								<tr>
									<td>
									<xsl:value-of select="index" />
									<br />
									<xsl:choose>
				 						<xsl:when test="reclaim_message!='' ">
											<xsl:value-of select="reclaim_message" />
											<br />
										</xsl:when>
									</xsl:choose>
									<strong>@@claim@@:</strong>&#160;@@not_yet_arrived@@
									<br />
									<strong>@@order_line_ref_num@@:</strong>&#160;<xsl:value-of select="poline_reference_number" />
									<br />
									<strong>@@order_date@@:</strong>&#160;<xsl:value-of select="poline_date" />
									<br />
									<strong>@@vendor_ref_num@@:</strong>&#160;<xsl:value-of select="vendor_refernce_number" />
									<br />
									<strong>@@delivery_type@@:</strong>&#160;<xsl:value-of select="shipping_method" />
									<br />
									<strong>@@vendor_note@@:</strong>&#160;<xsl:value-of select="vendor_note" />
									<br />
									<strong>@@num_units_arrived@@:</strong>&#160;<xsl:value-of select="items_received" />
									<br />
									<strong>@@num_units_ordered@@:</strong>&#160;<xsl:value-of select="items_oredered" />
									<br />
									<strong>@@vendor_contact@@:</strong>&#160;<xsl:value-of select="vendor_contact_persons" />
									<br />
									<strong>@@title@@:</strong>&#160;<xsl:value-of select="title" />
									<br />
									<strong>@@author@@:</strong>&#160;<xsl:value-of select="author" />
									<br />
									<strong>@@publication_date@@:</strong>&#160;<xsl:value-of select="publication_date" />
									<br />
									<strong>@@publication_place@@:</strong>&#160;<xsl:value-of select="publication_place" />
									<br />
									<strong>@@publisher@@:</strong>&#160;<xsl:value-of select="publisher" />
									<xsl:choose >
										<xsl:when test="last_received_date!=''">
											<br />
											<strong>@@last_received_date@@:</strong>&#160;<xsl:value-of select="last_received_date" />
										</xsl:when>
									</xsl:choose>
									</td>

								</tr>
							</table>
						</xsl:for-each>
					</td>
				</tr>

			</table>
			<br />
				<table role='presentation'>

						<tr><td>@@sincerely@@</td></tr>
						<tr><td>@@department@@</td></tr>

				</table>
          </div>
        </div>
        <xsl:call-template name="lastFooter" />
        <!-- footer.xsl -->
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>



