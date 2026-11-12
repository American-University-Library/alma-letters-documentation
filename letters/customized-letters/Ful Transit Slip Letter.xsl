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
        <div class="messageArea">
          <div class="messageBody">
            <table role='presentation'  cellspacing="0" cellpadding="5" border="0">
              <tr>
                <td><strong>@@print_date@@: </strong>
                <xsl:value-of select="notification_data/request/create_date" />-

                <xsl:value-of select="notification_data/request/create_time" /></td>
              </tr>
              <tr>
                <td>
                  <strong>@@request_id@@: </strong>
                  <img src="cid:request_id_barcode.png"
                  alt="Request Barcode" />
                </td>
              </tr>
              <tr>
                <td>
                  <strong>@@item_barcode@@: </strong>
                  <img src="cid:item_id_barcode.png"
                  alt="Item Barcode" />
                </td>
              </tr>
              <tr>
                <td>@@we_are_transferring_item_below@@</td>
              </tr>
              <tr>
                <td><strong>@@from@@: </strong>
                <xsl:value-of select="notification_data/request/assigned_unit_name" /></td>
              </tr>
              <tr>
                <td><strong>@@to@@: </strong>
                <xsl:value-of select="notification_data/request/calculated_destination_name" /></td>
              </tr>
              <tr>
                <td><strong>@@transfer_date@@: </strong>
                <xsl:value-of select="notification_data/request/create_date" /></td>
              </tr>
              <tr>
                <td><strong>@@transfer_time@@: </strong>
                <xsl:value-of select="notification_data/request/create_time" /></td>
              </tr>
			  <xsl:if test="notification_data/request/material_type_display">
				  <tr>
					<td><strong>@@material_type@@: </strong>
					<xsl:value-of select="notification_data/request/material_type_display" /></td>
				  </tr>
			  </xsl:if>
              <xsl:if test="notification_data/user_for_printing/note">
                <tr>
                  <td>
                    <strong>@@user_note@@:</strong>
                  </td>
                </tr>
                <tr>
                  <td>
                    <xsl:value-of select="notification_data/user_for_printing/note" />
                  </td>
                </tr>
              </xsl:if>
              <xsl:if test="notification_data/request/system_notes">
                <tr>
                  <td>
                    <strong>@@system_notes@@:</strong>
                  </td>
                </tr>
                <tr>
                  <td>
                    <xsl:value-of select="notification_data/request/system_notes" />
                  </td>
                </tr>
              </xsl:if>
              <xsl:if test="notification_data/request/note">
				<tr>
					<td>
						<strong>@@request_note@@:</strong>
					</td>
				</tr>
				<tr>
					<td>
						<xsl:value-of select="notification_data/request/note" />
					</td>
				</tr>
			  </xsl:if>
              <xsl:if test="notification_data/user_for_printing/name">
                <tr>
                  <td>
                    <strong>@@requested_for@@:</strong>
                  </td>
                </tr>
                <tr>
                  <td>
                    <xsl:value-of select="notification_data/user_for_printing/name" />
                  </td>
                </tr>
                <xsl:if test="notification_data/user_for_printing/email">
                  <tr>
                    <td><strong>@@email@@: </strong>
                    <xsl:value-of select="notification_data/user_for_printing/email" /></td>
                  </tr>
                </xsl:if>
                <xsl:if test="notification_data/user_for_printing/phone">
                  <tr>
                    <td><strong>@@tel@@: </strong>
                    <xsl:value-of select="notification_data/user_for_printing/phone" /></td>
                  </tr>
                </xsl:if>
                <tr>
                  <td><strong>@@request_date@@: </strong>
                  <xsl:value-of select="notification_data/request/create_date" /></td>
                </tr>
                <xsl:if test="notification_data/request/lastInterestDate">
                  <tr>
                    <td><strong>@@expiration_date@@: </strong>
                    <xsl:value-of select="notification_data/request/lastInterestDate" /></td>
                  </tr>
                </xsl:if>
              </xsl:if>
			  <tr>
				<td><xsl:call-template name="recordTitle" /></td>
			  </tr>
			  <xsl:if test="notification_data/phys_item_display/owning_library_name">
                  <tr>
                    <td><strong>@@owning_library@@: </strong>
                    <xsl:value-of select="notification_data/phys_item_display/owning_library_name" /></td>
                  </tr>
                </xsl:if>
            </table>
          </div>
        </div>
        <!-- recordTitle.xsl -->
        <xsl:call-template name="lastFooter" />
        <!-- footer.xsl -->
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
