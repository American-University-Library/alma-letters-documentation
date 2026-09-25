<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:include href="smsRecordTitle.xsl" />
<xsl:template match="/">
<xsl:value-of select="notification_data/receivers/sms_receiver/phone_list_str"/> : <xsl:value-of select="notification_data/organization_unit/name"/>.
@@hi@@ <xsl:value-of select="notification_data/user_for_printing/name"/>,
@@following_item_requested_on@@<xsl:value-of select="notification_data/request/create_date"/>, @@can_picked_at@@ <xsl:value-of select="notification_data/request/assigned_unit_name"/> @@circulation_desk@@.
@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
<xsl:value-of select="notification_data/phys_item_display/title"/>

</xsl:template>
</xsl:stylesheet>


