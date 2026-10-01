<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- 
	NOTES:
	Date transformation functions adapted from https://stackoverflow.com/questions/23566734/date-operations-on-xsl-1-0.
	Pickup date = the "current_date" element in the XML document + the "daysToPickup" param defined in this template.
	This is calculated by converting current_date to its Julian Day Number (integer) equivalent via the JDN function, adding $daysToPickup, and converting the result back to a formatted date via the gGD function.
-->
	<xsl:param name="daysToPickup" select="3"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="senderReceiver.xsl"/>
	<xsl:include href="mailReason.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="style.xsl"/>
	<xsl:include href="recordTitle.xsl"/>
	<xsl:template match="/">
		<html>
			<head>
				<xsl:call-template name="generalStyle"/>
			</head>
			<body>
				<!-- Don't send notice for booking requests for all except Georgetown  -->
				<xsl:if test="notification_data/organization_unit/org_scope/institution_id != '4111' and 
                                                  notification_data/request/request_type='BOOKING'">
					<xsl:message terminate="yes">this is a booking request!</xsl:message>
				</xsl:if>
				<xsl:attribute name="style">
					<xsl:call-template name="bodyStyleCss"/>
					<!-- style.xsl -->
				</xsl:attribute>
				<xsl:call-template name="head"/>
				<!-- header.xsl -->
				<!--			<xsl:call-template name="senderReceiver" />    kk -->
				<!-- SenderReceiver.xsl -->
				<!--		-->
				<xsl:call-template name="toWhomIsConcerned"/>
				<!--  -->
				<!-- mailReason.xsl -->
				<div class="messageArea">
					<div class="messageBody">
						<table cellspacing="0" cellpadding="5" border="0">
							<tr>
								<td>@@following_item_requested_on@@ <xsl:value-of select="notification_data/request/create_date"/>, @@can_picked_at@@  
								
								<!--Pickup Location for GM Libraries equals Library's specific Circ Desk, otherwise Pickup location is Library name; using Library ID number for GM Law Library -->
									<xsl:choose>
										<xsl:when test="contains(notification_data/request/delivery_address, 'Fenwick Library') 
										or 
										contains(notification_data/request/delivery_address, 'Mercer Library') 
										or 
										contains(notification_data/request/delivery_address, 'Mason Square Library')
										or
										contains(notification_data/request/library_id, '13707130004105')">
											<xsl:value-of select="notification_data/request/calculated_destination_name"/>.<br/>
											<br/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="notification_data/request/delivery_address"/>.<br/>
											<br/>
										</xsl:otherwise>
									</xsl:choose>
									<!-- 
									<xsl:if test="(notification_data/phys_item_display/available_items/available_item/location_code='wrlc shrp')">
									<B>PLEASE NOTE this item is for "In Library Use ONLY"</B><br/><br/>
									</xsl:if>
									-->
									
									<xsl:if test="(notification_data/phys_item_display/available_items/available_item/location_code='wrlc shrp')
									or
									(notification_data/phys_item_display/available_items/available_item/item_policy='InLibraryOnly')">
										<B>PLEASE NOTE this item is for "In Library Use ONLY"</B>
										<br/>
										<br/>
									</xsl:if>
									
									<B>Please carefully follow the instructions below.</B>
									<br/>
									<br/>
									<!--    <xsl:value-of select="notification_data/request/assigned_unit_name"/>    @@circulation_desk@@.   kk  -->
									
									<xsl:choose>
										
										<!-- AMERICAN Reserve desk -->
										<xsl:when test="(notification_data/phys_item_display/available_items/available_item/location_code='auz')
                                                   and
                                                   contains(notification_data/request/delivery_address, 'American University Library')">
											<B>Items on Course Reserves are held for an hour and can only be picked up in person.</B>
											<br/>
											<br/>
										</xsl:when>
										
										<!-- AMERICAN Main Circ -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'American University Library')">
											The item you requested on <xsl:value-of select="notification_data/request/create_date"/> will be ready for checkout at the AU Library Circulation Desk in about an hour.
											<br/>
											<br/>
											If you have any questions, feel free to reply to this message or email <a href="mailto:circulation@american.edu">circulation@american.edu</a>.<br/>
											<br/>
										</xsl:when>
										
										<!-- AU LAW --> 
										<xsl:when test="contains(notification_data/request/delivery_address, 'Pence')">                
										The following item has been placed on hold for you at the Pence Law Library <b>circulation desk</b>. Your item may be picked up during normal operating hours.
										<br/>
										<br/>
										If you have any questions, please contact the circulation desk at (202) 274-4300 or email <a href="mailto:circ@wcl.american.edu">circ@wcl.american.edu</a>.<br/>
										<br/>
											<xsl:if test="notification_data/request/work_flow_entity/expiration_date">
												<tr>
													<td>
														@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
														<br/>
														<br/>
													</td>
												</tr>
											</xsl:if>
										</xsl:when>
										
										<!-- CATHOLIC -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Mullen')">	
										Items can be picked up from Mullen Library's circulation desk during regular library hours, excluding overnight.  Please see the <a href="https://libraries.catholic.edu/about-us/library-hours.html">library website</a> for the library's hours.
										</xsl:when>
										
										<!-- Catholic Law -->
										<xsl:when test="contains(notification_data/request/library_id, '112359280008086')">
										Items can be picked up from the Law Library's circulation desk during regular library hours.  Please see the <a href="https://law-cua.libcal.com/hours/" target="_blank">Law Library's website</a> for the library's hours.
										</xsl:when>
										
										<!--   UDC Van Ness Library   -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Van Ness Library')">
										Please wait at least 1 hour while library staff complete processing before asking for this item.
										<br/>
										<br/>
										Van Ness Library Location:<br/>
                                        Building 39, Level B<br/>
                                        4200 Connecticut Ave. NW<br/>
                                        Washington, DC  20008<br/>
										</xsl:when>
										
										<!--   UDC Lamond-Riggs Library  -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Lamond-Riggs Library')">
										Please wait at least 1 hour while library staff complete processing before asking for this item.
										<br/>
										<br/>
										Lamond-Riggs Library Location:<br/>
                                        Room 225<br/>
                                        5171 South Dakota Ave. NE<br/>
                                        Washington, DC  20017<br/>
										</xsl:when>
										
										<!-- GALLAUDET -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Gallaudet')">
										The Gallaudet University Library is located at Jordan Student Academic Center (JSAC) #1221. For more information, contact library.circdesk@gallaudet.edu. 
										<br/>
										<br/>
										</xsl:when>
										
										<!-- GM   -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Fenwick Library') 
										or 
										contains(notification_data/request/delivery_address, 'Mercer Library') 
										or 
										contains(notification_data/request/delivery_address, 'Mason Square Library')">
										Please check your designated library’s hours on the University Libraries homepage to confirm <a href="https://library.gmu.edu/library-hours">available hours</a>. 
										<a href="https://library.gmu.edu/contact">Contact the Libraries</a> for more information.
										<br/>
										<br/> 
										Please make sure to bring your School ID, driver’s license, or another form of government ID to the Information Desk to check out your materials.
										<br/>
										<br/>
											<tr>
												<td>
												@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
												</td>
											</tr>
										</xsl:when>
										
										<!-- GM LAW  -->
										<xsl:when test="(notification_data/request/library_id='13707130004105')"> 
										Please check the law library’s <a href="https://libguides.law.gmu.edu/library-technology-services">available hours</a> and contact information.
										<br/>
										<br/> 
										Please make sure to bring your School ID, driver’s license, or another form of government ID to the Information Desk to check out your materials.
										<br/>
										<br/>
											<tr>
												<td>
												@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
												</td>
											</tr>
										</xsl:when>
										
										<!-- GT  -->
										
                                        <!-- GT BLOMMER -->
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Blommer')">
                                        <p>@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.</p>                                    
                                        <p>Questions? Please reply to this notice or contact <a href="mailto:accessservices@georgetown.edu">AccessServices@georgetown.edu</a>.</p>
                                        </xsl:when>
                                        
                                        <!-- GT BIOETHICS -->                                        
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Bioethics')">
                                        <p>@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.</p>
                                        <p>Questions? Please reply to this notice or contact <a href="mailto:bioethics@georgetown.edu">bioethics@georgetown.edu</a>.</p>
                                        </xsl:when>
                                        
                                        <!-- GT CAPITOL -->
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Capitol Campus Library')">
                                            <xsl:choose>
                                                <xsl:when test="contains(notification_data/request/request_type, 'BOOKING')">
                                                    <p>Your booked item will be held until the circulation desk closes on your requested pick up day.</p>
                                                </xsl:when>
                                                <xsl:otherwise>
                                            <p>The item below can be picked up from the hold shelf during the <a href="https://library.georgetown.edu/hours/111-mass">Capitol Campus Library Self-Service hours</a>.</p>
                                            <p>Look for pickup number <b><xsl:value-of select="/notification_data/user_for_printing/identifiers/code_value/value"/></b></p>
                                            <p><b>This item has been checked out to your account.</b> It will be held for you on the hold shelf until <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.</p>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        <p>Questions? Visit the Capitol Campus Library Service Desk during <a href="https://library.georgetown.edu/hours/capitol-campus">open hours</a> or contact <a href="mailto:accessservices@georgetown.edu">AccessServices@georgetown.edu</a>.</p>
                                        </xsl:when>
                                        
                                        <!-- GT LAUINGER -->
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Lauinger')">
                                        <p>    <xsl:choose>
                                                <xsl:when test="contains(notification_data/request/request_type, 'BOOKING')">
                                                Your booked item will be held until the circulation desk closes on your requested pick up day.
                                                </xsl:when>
                                                <xsl:otherwise>
                                                @@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
                                                </xsl:otherwise>
                                            </xsl:choose></p>
                                            <p>Questions? Please reply to this notice or contact <a href="mailto:accessservices@georgetown.edu">AccessServices@georgetown.edu</a>.</p>
                                        </xsl:when>

                                        <!--  GT Hilltop OFFICE DELIVERY -->
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Office Delivery (Hilltop')">
                                            <xsl:choose>
                                                <xsl:when test="contains(notification_data/user_for_printing/title, 'WRLCFaculty')">
                                                <p>You requested Office Delivery for this item, so we will bring it to your office within the next few business days.</p>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <p><b>Please visit the Lauinger Service Desk to collect your item.</b> @@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.</p>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <p>Questions? Please reply to this notice or contact <a href="mailto:accessservices@georgetown.edu">AccessServices@georgetown.edu</a>.</p>
                                        </xsl:when>
                                        
                                         <!--  GT Capitol Campus OFFICE DELIVERY -->
                                        <xsl:when test="contains(notification_data/request/delivery_address, 'Office Delivery (Capitol')">
                                            <xsl:choose>
                                                <xsl:when test="contains(notification_data/user_for_printing/title, 'WRLCFaculty')">
                                                <p>You requested Office Delivery for this item, so we will bring it to your office within the next few business days.</p>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <p><b>Please visit the Capitol Campus Library Service Desk during <a href="https://library.georgetown.edu/hours/capitol-campus">open hours</a> to collect your item.</b> @@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.</p>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <p>Questions? Please reply to this notice or contact <a href="mailto:accessservices@georgetown.edu">AccessServices@georgetown.edu</a>.</p>
                                        </xsl:when>
										
										<!--  GT QATAR -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'GU-Q')">
										The item you requested is available on the holdshelf. You may check it out at the Service Desk during the library <a href="https://library.qatar.georgetown.edu/about-us/hours/">opening hours</a>. The item will be held for you until <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.<br/>
										<br/>
										</xsl:when>
										
										<!--  GT Law  -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Georgetown Law')">
										Your item can be picked up at the Georgetown Law Library - Williams Circulation Desk.<br/>
											<xsl:if test="notification_data/request/work_flow_entity/expiration_date">
												<b>@@note_item_held_until@@ </b>
												<xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
											</xsl:if>
											<br/>
											<br/>
										</xsl:when>
										
										<!-- GW -->
										
										<!-- GW - Special Collections Library -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Special Collections Research Center')">
										The materials you requested have arrived and are on hold for you in the <a href="https://library.gwu.edu/scrc"> Special Collections Research Center</a>.
										<br/>
										<br/>
										Special Collections materials can only be viewed on site in the Special Collections Research Center located on the 7th floor of the Gelman Library.
										<br/>
										<br/>
										GW students, faculty, and staff who have a physical GWorld card enabled for campus access may visit the reading room without an appointment during our regular hours: Monday-Friday 10 AM to 4 PM.
										<br/>
										<br/>
										Non-GW patrons* (alumni and visitors) can access the reading room by appointment only. 
										<br/>
										<br/>
										Please <a href="https://library.gwu.edu/scrc/contact">contact us</a> to schedule an appointment if you have not already done so.
										<br/>
										<br/>The Gelman Library building's HVAC system maintenance project will require closing the building for three consecutive summers (2024, 2025, and 2026). All of the Gelman Library building, including the Special Collections Research Center, will be closed in the summer of 2025 and 2026. Specific dates are still to be determined.
										<br/>
										<br/>
										Researchers who were planning to visit Special Collections during this time period should <a href="https://library.gwu.edu/form/contact-special-collections-rese"> contact us as soon as possible to discuss options for your research.</a>
										<br/>
										<br/>
										Thank you.
										<br/>
										<br/>
										</xsl:when>
                                        
										<!-- GW - GELMAN VISITOR OR ALUM -->
										<xsl:when test="(notification_data/receivers/receiver/user/user_group='gwalum' or notification_data/receivers/receiver/user/user_group='gwvist')                                       
										and
										contains(notification_data/request/delivery_address, 'Gelman')">
										<!--  <B>TEST - PICKUP FOR ALUMS AND VISITORS</B><br/><br/>   -->
										Please come to the Check Out desk during staffed hours to pick up your item(s).
										<br/>
										<br/>
										Or, to schedule a pickup appointment:
										<br/>
										If you have requested multiple items, we ask that you check your <a href="https://wrlc-gwu.primo.exlibrisgroup.com/discovery/login?vid=01WRLC_GWA:live">My Library Account</a> for the statuses of your other book requests before scheduling a pickup time. This way, we can consolidate all your items into one pickup for your convenience. 
										<br/>
										<br/>
										Please note that you will receive a notice for each item you have requested when it is available to carry out. Only one appointment is needed if you receive multiple notices in the same period of time. We will check out and package all items ready for pickup at the time your appointment is approved. 
										<br/>
										<br/>
										Link to schedule a Gelman book pickup -  <a href="https://booking.library.gwu.edu/reserve/Gelmanpickup"> https://booking.library.gwu.edu/reserve/Gelmanpickup</a>
										<br/>
										<br/>
										</xsl:when>
										
										<!-- GW GELMAN ILLIAD -->
										<xsl:when test="contains(notification_data/request/delivery_address,'Gelman')
										and 
										contains(notification_data/request/notes, 'ILLiad TN:')">
										<B>ILLiad Notice:</B>
										<br/>The item requested fills an ILLiad physical item request.  If you indicated that SCF staff should mail the item, then this is a notice that the item is being sent.  If you indicated that the item should not be mailed then this is a notice that the item is on the Hold Shelf.
										<br/>
										<br/>
										<xsl:value-of select="substring-before(//notification_data/request/note,'; BorCode')"/>
										<br/>
										</xsl:when>
										
										
										<xsl:when test="contains(notification_data/request/delivery_address, 'Gelman')">
											<!--  do nothing, Gelman wanted message moved below  -->
										</xsl:when>
										
										<xsl:when test="contains(notification_data/request/delivery_address, 'Temporary Pickup Location GW Law Library (Summer 2026)')">
											<!--  do nothing, Gelman wanted message moved below  -->
										</xsl:when>
										
										
										<!-- GW - Virginia -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Virginia')">
										If you have requested multiple items, we ask that you check your <a href="https://wrlc-gwu.primo.exlibrisgroup.com/discovery/login?vid=01WRLC_GWA:live">My Library Account</a> for the statuses of your other book requests before scheduling a pickup time. This way, we can consolidate all your items into one pickup for your convenience. 
										<br/>
										<br/>
										Please note that you will receive a notice for each item you have requested when it is available to carry out. Only one appointment is needed if you receive multiple notices in the same period of time. We will check out and package all items ready for pickup at the time your appointment is approved. 
										<br/>
										<br/>
										Link to schedule a VSTCL book pickup - <a href="https://booking.library.gwu.edu/reserve/VSTCLpickup"> https://booking.library.gwu.edu/reserve/VSTCLpickup</a>
										<br/>
										<br/>
										</xsl:when>
										
										<!-- GW HOME DELIVERY  -->
										<xsl:when test="(contains(notification_data/request/delivery_address, 'GW Home Delivery')
										or
										(contains(notification_data/request/delivery_address, 'GW Online-Only')))">
										Your item has been retrieved and will be checked out to your account. Per your request, we will be shipping this item to your address. You will receive a separate notification from FedEx Ground with a tracking number.
										<br/>
										<br/>
										</xsl:when>
										
										<!-- GW HIMMELFARB -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Himmelfarb')">
											<!-- convert current_date to Julian Day Number -->
											<xsl:variable name="JDN_cur_date">
												<xsl:call-template name="JDN">
													<xsl:with-param name="date" select="notification_data/general_data/current_date"/>
												</xsl:call-template>
											</xsl:variable>
											<!-- add $daysToPickup and convert back to formatted date -->
											<xsl:variable name="pickup_date">
												<xsl:call-template name="GD">
													<xsl:with-param name="JDN" select="$JDN_cur_date + $daysToPickup"/>
												</xsl:call-template>
											</xsl:variable>
											<xsl:if test="notification_data/request/work_flow_entity/expiration_date">					
											@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
											</xsl:if>
											<!--<br/><a href="https://guides.himmelfarb.gwu.edu/borrowing">Books and selected other materials are now available for Courtyard Pick-up and Shipping.</a><br/><br/>-->
										</xsl:when>
										
										<!-- GW LAW -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Jacob Burns')">
										For pickup information and instructions visit your library's website.
										<br/>
										<br/>
										</xsl:when>
										
										<!--  HOWARD LAW AND STOKES  -->
										<xsl:when test="contains(notification_data/request/library_id, '13704380004109')
										or
										contains(notification_data/request/delivery_address, 'Louis Stokes')">
										For pickup information and instructions visit your library's website.
										<br/>
										<br/>
										</xsl:when>
										
										<!-- HOWARD -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Founders')"> 
											<xsl:if test="notification_data/request/work_flow_entity/expiration_date">
											The item will be held for you at the Founders Library Circulation Desk (located on the second floor) until <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.  Please be sure to bring your University ID card to check out your requested item.
											</xsl:if>
										<br/>
										<br/>
										Howard University Founders Library
										<br/>
										500 Place NW
										<br/>
										Washington, DC  20059
										<br/>
										<br/>
										Questions? Please contact <a href="mailto:founders.ill@howard.edu">founders.ill@howard.edu</a>
										<br/>
										<br/>
										</xsl:when>
										
										<!-- MARYMOUNT -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Ballston')
										or
										contains(notification_data/request/delivery_address, 'Reinsch')">
										Your requested item is now available for pickup at the Circulation Desk, where your item will be held for 14 days. If you have any questions please contact us at mucirc@marymount.edu.<br/>
										<br/>
										</xsl:when>
										
										<!-- TRINITY -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'Trinity')">
										For pickup information and instructions visit your library's website.
										<br/>
										<br/>
										</xsl:when>
										
										<!-- WRLC -->
										<xsl:when test="contains(notification_data/request/delivery_address, 'WRLC')">
										For pickup information and instructions visit your library's website.
										<br/>
										<br/>
										</xsl:when>
										
										<!-- OTHERWISE -->
										<xsl:otherwise>
										For item pickup information and instructions visit your library's website.
										<br/>
										<br/>
										</xsl:otherwise>
									
									</xsl:choose>
									<!--        comment out   -->
								</td>
							</tr>
							
							<!--<xsl:if test="notification_data/request/work_flow_entity/expiration_date">
								<tr>
									<td>
									@@note_item_held_until@@ <xsl:value-of select="notification_data/request/work_flow_entity/expiration_date"/>.
									</td>
								</tr>
							</xsl:if>    kk  -->
							
							<tr>
								<td>
									<B>Item to be picked up: <br/>
									</B>
									<xsl:call-template name="recordTitle"/>
									<!-- recordTitle.xsl -->
								</td>
							</tr>
							
							<!-- location where GELMAN wants instructions  -->
							<xsl:choose>
								
								<!-- Gelman specific  -->
								<xsl:when test="contains(notification_data/request/assigned_unit_name, 'Special Collections')">
									<!-- do nothing, place holder if Gelman wants message moved  -->
								</xsl:when>
								
								<xsl:when test="(notification_data/receivers/receiver/user/user_group='gwalum' or notification_data/receivers/receiver/user/user_group='gwvist')                                       
                                and
                                (contains(notification_data/request/delivery_address, 'Gelman'))">
									<!--  do nothing, place holder if Gelman wants message moved  -->
								</xsl:when>
								
								<xsl:when test="contains(notification_data/request/delivery_address,'Gelman')
                                and 
                                contains(notification_data/request/notes, 'ILLiad TN:')">
									<!--  do nothing, place holder if Gelman wants message moved   -->
								</xsl:when>
								
								<!--GW Gelman -->
								<xsl:when test="contains(notification_data/request/delivery_address, 'Gelman')">
									<tr>
										<td>
										You may pick up your item(s) at the Check Out desk during staffed <a href="https://library.gwu.edu/hours">hours</a>.
										<br/>
										<br/>
										<B>Alternatively</B>, for your convenience, you may use the following link to schedule your book pickup outside of normal staffed hours at Gelman Library - <a href="https://booking.library.gwu.edu/reserve/carryout">https://booking.library.gwu.edu/reserve/carryout</a>
										<br/>
										<br/>
										If you are expecting multiple items, you may wish to wait to schedule your appointment until all items have arrived. You will receive separate  notice for each item you have requested when the item is available to check out.  Please check your <a href="https://wrlc-gwu.primo.exlibrisgroup.com/discovery/login?vid=01WRLC_GWA:live">My Library Account</a> for the statuses of your other item requests prior to scheduling an appointment for book pickup. We will consolidate all your items into one pickup appointment for your convenience. Please wait for an approval confirmation prior to coming to the Carry Out Desk.
										<br/>
										<br/>
										<b>NOTE*</b> Only one appointment is needed if you receive multiple notices in the same period of time. You will be able to pick up all of your items at the Carry Out Desk at the selected appointment time. 
										<br/>
										</td>
									</tr>
								</xsl:when>
								
							<!-- Previously used for GW GELMAN HVAC INTERIM CLOSURE 2026, To be used August 14th to August 24th for GW
								<xsl:when test="contains(notification_data/request/delivery_address, 'Gelman')">
							    	<tr>
							    	    <td>
							    	    Between August 15th and August 23rd, <b>Gelman Library is still closed</b> but we are offering appointment pickup on the Kogan Plaza patio, directly outside the front doors.  Please use this link to schedule a pickup time-<a href="https://booking.library.gwu.edu/reserve/Gelmanpickup">https://booking.library.gwu.edu/reserve/Gelmanpickup</a>.
							    	    <br/>
							    	    <br/>
							    	     If you are expecting multiple items, you may wish to wait to schedule your appointment until all items have arrived. You will receive separate notice for each item you have requested when the item is available to check out.  Please check your <a href="https://wrlc-gwu.primo.exlibrisgroup.com/discovery/login?vid=01WRLC_GWA:live">My Library Account</a> for the statuses of your other item requests prior to scheduling an appointment for book pickup. We will consolidate all your items into one pickup appointment for your convenience.   
							    	    <br/>
							    	    <br/>
							    	    Please wait for an approval confirmation email prior to coming to collect items at Gelman Library.  Books will be available for pickup from a cart to the right of the revolving doors at the top of the steps.
							    	    <br/>
							    	    <br/>
							    	    NOTE* Only one appointment is needed if you receive multiple notices in the same period of time. You will be able to pick up all of your items at the selected appointment time. 
							    	    </td>
							    	</tr>	
							   </xsl:when>-->
						     <!-- GW GELMAN HVAC INTERIM CLOSURE 2026-->
								<xsl:when test="contains(notification_data/request/delivery_address, 'Temporary Pickup Location GW Law Library (Summer 2026)')">
								    <tr>
									    <td>
                                        Between May 9th, 2026  and mid August, <b>Gelman Library is closed</b> but you may schedule an appointment to pick up your items at Burns Law Library.  Please use this link to schedule a pickup time : <a href="https://booking.library.gwu.edu/space/131160">https://booking.library.gwu.edu/reserve/Gelmanpickup</a>
                                        <br/>
                                        <br/>
                                        If you are expecting multiple items, you may wish to wait to schedule your appointment until all items have arrived. You will receive separate notice for each item you have requested when the item is available to check out.  Please check your <a href="https://wrlc-gwu.primo.exlibrisgroup.com/discovery/login?vid=01WRLC_GWA:live">My Library Account</a> for the statuses of your other item requests prior to scheduling an appointment for book pickup. We will consolidate all your items into one pickup appointment for your convenience.
                                        <br/>
                                        <br/>
                                        Please wait for an approval confirmation email prior to coming to collect items at Burns Law Library. For access to Burns Law Library you will need to use the 20th St entrance (<a href="=https://g.co/kgs/zNkpyTt">716 20th St NW</a>).  Please ring the intercom and advise staff that you have arrived to pick up your items. You will need to show your GWorld card or Mobile ID to be admitted through the turnstiles.  Once admitted please proceed to the Reference Desk to retrieve your items.
                                        <br/>
                                        <br/>
                                        NOTE* Only one appointment is needed if you receive multiple notices in the same period of time. You will be able to pick up all of your items at the selected appointment time. 
                                        </td>
                                    </tr>
                                </xsl:when>    
								<xsl:otherwise>
									<!-- do nothing  -->
								</xsl:otherwise>
							</xsl:choose>
							
							<!-- Noes that may affect Loan line appears only if there is a block on the patron -->
							<xsl:if test="notification_data/request/system_notes !=''">
								<tr>
									<td>
										<b>@@notes_affect_loan@@:</b>
									</td>
								</tr>
								<tr>
									<td>
										<xsl:value-of select="notification_data/request/system_notes"/>
									</td>
								</tr>
							</xsl:if>
							
						</table>
					</div>
				</div>
				<br/>
				<table>
					<tr>
						<td>@@sincerely@@,</td>
					</tr>
					<tr>
						<td>@@department@@</td>
					</tr>
				</table>
				<xsl:call-template name="lastFooter"/>
				<!-- footer.xsl -->
			</body>
		</html>
	</xsl:template>
	<xsl:template name="JDN">
		<!-- Date string to Julian day number -->
		<xsl:param name="date"/>
		<xsl:param name="year" select="substring($date, 7, 4)"/>
		<xsl:param name="month" select="substring($date, 1, 2)"/>
		<xsl:param name="day" select="substring($date, 4, 2)"/>
		<xsl:param name="a" select="floor((14 - $month) div 12)"/>
		<xsl:param name="y" select="$year + 4800 - $a"/>
		<xsl:param name="m" select="$month + 12*$a - 3"/>
		<xsl:value-of select="$day + floor((153*$m + 2) div 5) + 365*$y + floor($y div 4) - floor($y div 100) + floor($y div 400) - 32045"/>
	</xsl:template>
	<xsl:template name="GD">
		<!-- Julian day number to Gregorian Date -->
		<xsl:param name="JDN"/>
		<xsl:param name="f" select="$JDN + 1401 + floor((floor((4 * $JDN + 274277) div 146097) * 3) div 4) - 38"/>
		<xsl:param name="e" select="4*$f + 3"/>
		<xsl:param name="g" select="floor(($e mod 1461) div 4)"/>
		<xsl:param name="h" select="5*$g + 2"/>
		<xsl:param name="D" select="floor(($h mod 153) div 5 ) + 1"/>
		<xsl:param name="M" select="(floor($h div 153) + 2) mod 12 + 1"/>
		<xsl:param name="Y" select="floor($e div 1461) - 4716 + floor((14 - $M) div 12)"/>
		<xsl:param name="MM" select="substring(100 + $M, 2)"/>
		<xsl:param name="DD" select="substring(100 + $D, 2)"/>
		<xsl:value-of select="concat($MM, '/', $DD, '/', $Y)"/>
	</xsl:template>
</xsl:stylesheet>