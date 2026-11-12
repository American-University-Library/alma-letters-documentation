<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:include href="header.xsl"/>
	<xsl:include href="senderReceiver.xsl"/>
	<xsl:include href="mailReason.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="style.xsl"/>
	<xsl:include href="recordTitle.xsl"/>
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

				<xsl:call-template name="generalStyle"/>
			</head>
			<body>
				<xsl:attribute name="style">
					<xsl:call-template name="bodyStyleCss"/>
					<!-- style.xsl -->
				</xsl:attribute>
				<xsl:call-template name="head"/>

				<div class="messageArea">
					<div class="messageBody">
						<table role='presentation'  cellspacing="0" cellpadding="3" border="0">
							<xsl:attribute name="style">
								<xsl:call-template name="listStyleCss"/>
								<!-- style.xsl -->
							</xsl:attribute>
							<tr>
								<td>
									<strong>@@returned@@</strong>
								</td>
							</tr>
							<tr>
								<td>
									<br/>
                                                                               <strong> @@request_id@@: </strong><img src="externalId.png" alt="externalId"/></td>
							</tr>
							<tr><td><br/></td></tr>
							<xsl:if test="notification_data/request/display/title !=''">
								<tr>
									<td>
										<strong> @@title@@: </strong>
										<xsl:value-of select="notification_data/request/display/title"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/request/display/journal_title !=''">
								<tr>
									<td>
										<strong> @@journal_title@@: </strong>
										<xsl:value-of select="notification_data/request/display/journal_title"/>
									</td>
								</tr>
							</xsl:if>
							<tr>
								<td>
									<strong> @@author@@: </strong>
									<xsl:value-of select="notification_data/request/display/author"/>
								</td>
							</tr>
							<tr>
								<td>
									<strong> @@volume@@: </strong>
									<xsl:value-of select="notification_data/request/display/volume"/>
								</td>
							</tr>
							<tr>
								<td>
									<strong> @@issue@@: </strong>
									<xsl:value-of select="notification_data/request/display/issue"/>
								</td>
							</tr>
							<tr>
								<td>
									<br/>
									<strong> @@arrival_date@@: </strong>
									<xsl:value-of select="notification_data/request/item_arrival_date"/>
								</td>
							</tr>
							<tr>
								<td>
									<strong> @@required_return_date@@: </strong>
									<xsl:value-of select="notification_data/request/due_date"/>
								</td>
							</tr>
							<tr>
								<td>
									<br/>
									<strong> @@note_to_partner@@: </strong>
									<xsl:value-of select="notification_data/note_to_partner"/>
								</td>
							</tr>
						</table>
<!--
						<table role='presentation' >
							<tr>
								<td>@@signature@@</td>
							</tr>
							<tr>
								<td>
									<xsl:value-of select="notification_data/library/name"/>
								</td>
							</tr>
							<xsl:if test="notification_data/library/address/line1 !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/line1"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/line2 !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/line2"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/line3 !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/line3"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/line4 !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/line4"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/line5 !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/line5"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/city !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/city"/>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="notification_data/library/address/country !=''">
								<tr>
									<td>
										<xsl:value-of select="notification_data/library/address/country"/>
									</td>
								</tr>

							</xsl:if>
						</table>
	-->
					</div>
				</div>

  <!--	<xsl:call-template name="lastFooter" /> --> <!-- footer.xsl -->
<xsl>

<br></br><br></br><br></br>
	<table cellspacing="0" cellpadding="0" border="1">
                <tr><td style="font-size:10px;width:350px">Return To:<br></br>
                        <center> Interlibrary Loan - Alma P2P</center>
                        <center> American University Library</center>
                        <center> 4400 Massachusetts Avenue, NW</center>
                        <center> Washington, DC 20016-8046</center><br></br>
                </td></tr>
                <tr><td style="font-size:18px;width:350px"><font size="1">Ship To:</font><br></br>
                <center><b><xsl:value-of select="notification_data/partner_name"/></b></center>
                <xsl:for-each select="notification_data/partner_address">
			<center><xsl:value-of select="line1"/></center>
			<center><xsl:value-of select="line2"/></center>
			<center><xsl:value-of select="line3"/></center>
			<center><xsl:value-of select="line4"/></center>
			<center><xsl:value-of select="city"/>,&#160;<xsl:value-of select="state_province"/>&#160;<xsl:value-of select="postal_code"/></center>
		</xsl:for-each>
               	</td></tr>
	</table>
</xsl>


</body>
</html>


	</xsl:template>
</xsl:stylesheet>