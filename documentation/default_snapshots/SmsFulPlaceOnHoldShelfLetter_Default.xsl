<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:include href="smsRecordTitle.xsl" />
	<xsl:template match="/">
"T","1","2","1"," <xsl:value-of select="notification_data/receivers/receiver/user/user_name"/>","","","<xsl:value-of select="notification_data/user_for_printing/name"/>","<xsl:value-of select="notification_data/receivers/sms_receiver/phone_list_str"/>","<xsl:value-of select="notification_data/user_for_printing/email"/>","<xsl:value-of select="notification_data/phys_item_display/location_name"/>","<xsl:value-of select="notification_data/phys_item_display/location_name"/>","<xsl:value-of select="notification_data/phys_item_display/barcode"/>","<xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>","<xsl:value-of select="notification_data/phys_item_display/title"/> ","z37_request_number"

	</xsl:template>

</xsl:stylesheet>




