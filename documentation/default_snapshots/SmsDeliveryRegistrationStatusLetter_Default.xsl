<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<xsl:variable name="registrationStatus"><xsl:value-of select="notification_data/delivery_registration/status"/></xsl:variable>
		<xsl:variable name="periodUnit"><xsl:value-of select="notification_data/delivery_registration/period_unit"/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$registrationStatus = 'REGISTERED'">
				@@hi@@@@you_will_receive@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@becomes_available@@
			</xsl:when>
			<xsl:when test="$registrationStatus = 'ITEM_AVAILABLE'">
				<xsl:variable name="deliveryUrl"><xsl:value-of select="notification_data/delivery_registration/delivery_url"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="$periodUnit != '' and $deliveryUrl != ''">
						@@hi@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@is_available@@@@link_sent@@@@you_have@@<xsl:value-of select="notification_data/delivery_registration/grace_period"></xsl:value-of> <xsl:value-of select="concat(' ', $periodUnit)" /> @@to_start_viewing@@	
					</xsl:when>
					<xsl:when test="$periodUnit != '' and $deliveryUrl = ''">
						@@hi@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@is_available@@@@you_have@@<xsl:value-of select="notification_data/delivery_registration/grace_period"></xsl:value-of> <xsl:value-of select="concat(' ', $periodUnit)" /> @@to_start_viewing@@	
					</xsl:when>
					<xsl:when test="$periodUnit = '' and $deliveryUrl = ''">
						@@hi@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@is_available@@@@you_have@@<xsl:value-of select="notification_data/delivery_registration/grace_period"></xsl:value-of>@@minutes_to_start@@	
					</xsl:when>
					<xsl:otherwise>
						@@hi@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@is_available@@@@link_sent@@@@you_have@@<xsl:value-of select="notification_data/delivery_registration/grace_period"></xsl:value-of>@@minutes_to_start@@	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$registrationStatus = 'GRACE_PERIOD_EXPIRED'">
				@@hi@@@@your_availability_for@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@has_expired@@
			</xsl:when>
			<xsl:when test="$registrationStatus = 'REMOVED'">						
				@@hi@@@@removed@@<xsl:value-of select="notification_data/delivery_registration/title"></xsl:value-of>@@contact_library@@ 
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>