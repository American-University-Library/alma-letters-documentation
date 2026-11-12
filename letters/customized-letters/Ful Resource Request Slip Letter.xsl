<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="senderReceiver.xsl"/>
	<xsl:include href="mailReason.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="style.xsl"/>
	<xsl:include href="recordTitle.xsl"/>
	<xsl:param name="barcode_limit" select="5" />
	<xsl:template match="/">
		<html>
			<head>
				<xsl:call-template name="generalStyle"/>
			</head>
			<body>
			<!-- Collin's solution to stop the printing of "Transit Slips"  -->
			<!--				<xsl:if test="notification_data/request/request_type='Transit for reshelving'">
			<xsl:message terminate="yes">this is an ill item!</xsl:message>
			</xsl:if>-->
				<xsl:if test="(notification_data/request/request_type='Transit for reshelving')
                or
                (notification_data/request/request_type='Transit For Reshelving')">
					<xsl:message terminate="yes">this is an ill item!</xsl:message>
				</xsl:if>
				<!-- This table format should give a 50-50 split on a printed page -->
				<table style="border-spacing: 45px 12px;table-layout: fixed;">
				<!-- change border-spacing above from 15px to 12px to tighten top so more fits on the page - request from Emily -->
					<tr>
						<td style='text-align: center;width: 50%;word-wrap: break-word;'>
							<h1 style="font-size: 80px;">
							<!-- This choice statement is based on the text descriptions in the destination field
                            It will break if the names change and currently doesn't include the law schools, med schools,
                            Trinity, or satellite campuses-->
							<!-- There was a request to have an inverted copy of the school abbreviations
                            at the bottom of the slip like the one that currently exists. However, MS Outlook
                            doesn't support most (otherwise standard) transform and position styling. Without that
                            it's difficult to get text to float to the absolute bottom of a printed page -->
								<xsl:choose>
									<xsl:when test="notification_data/request/request_type='PHYSICAL_TO_DIGITIZATION'">
										<font size="40px;">Article/<br/>Chapter</font>
									</xsl:when>
									
									<xsl:when test="(notification_data/request/request_type='MOVE_TO_TEMPORARY')
                                    and
                                    contains(notification_data/general_data/address_from, 'GU')">
										<font size="40px;">MOVE<br/>REQUEST</font>
									</xsl:when>
									
									<xsl:when test="notification_data/request/request_type='MOVE_TO_TEMPORARY'">
										<font size="40px;">Course<br/>Reserves</font>
									</xsl:when>
									
									<xsl:when test="(notification_data/destination='Office Delivery')
                                    and
                                    contains(notification_data/general_data/address_from, 'GU')">
										<font size="40px;">Office<br/>Delivery</font>
									</xsl:when>
									
									<xsl:when test="notification_data/request/request_type='RESOURCE_SHARING_PHYSICAL_SHIPMENT'">
										<font size="40px;">
											<xsl:value-of select="notification_data/incoming_request/partner_code"/>
										</font>
									</xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'American University Library')">
									AU
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Pence')">
									AULAW
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Catholic')">
									CU
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Columbia, Law')">
									DCL
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'District')">
									DC
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Gallaudet')">
									GA
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Fenwick')">
									GM
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Mason Square')">
									GMA
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Mercer')">
									GMP
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Mason Law')">
									GMA
                                    </xsl:when>
									
									<!-- new set up for Office Delivery Library, Capitol office delivery library, etc.    -->
									<xsl:when test="contains(notification_data/destination, 'Office Delivery (Hilltop faculty)')">
									GT-OD
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Lauinger')">
									GT
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Bioethics')">
									GT-Bioethics
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Blommer')">
									GTB
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'McCourt')">
									GT-McCourt
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Capitol Campus Library')">
									GT-CC
                                    </xsl:when>
									
                                    <xsl:when test="contains(notification_data/destination, 'Office Delivery (Capitol faculty)')">
                                    GT-CC-OD
                                    </xsl:when>                                    
									
									<xsl:when test="contains(notification_data/destination, 'Georgetown Law')">
									GTL
                                    </xsl:when>
									
									
									<xsl:when test="contains(notification_data/destination, 'Gelman')
									or
									contains(notification_data/destination, 'Temporary Pickup Location GW Law Library')">
									GW
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Eckles')">
									GWE
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Virginia')">
									GWN
                                    </xsl:when>
									<!--                                    <xsl:when test="contains(notification_data/destination, 'GW Home Delivery')"-->
									
									<xsl:when test="(contains(notification_data/destination, 'GW Home Delivery')
                                    or                                                                   
                                    (contains(notification_data/destination, 'GW Online-Only')))">
									GWOC
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Burns')">
									JB
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Himmelfarb')">
									HI
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Louis Stokes Health Science')">
									HU-HS
                                    </xsl:when>
									
									<xsl:when test="(contains(notification_data/destination, 'Howard')) 
                                    and 
                                    (contains(notification_data/destination, 'Law'))">
									HUWC
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Howard')">        
									HU                                     
                                    </xsl:when>
									
									<xsl:when test="(contains(notification_data/destination,'Marymount')) 
                                    and 
                                    (contains(notification_data/destination, 'Ballston'))">
									MUB
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Marymount')">
									MU
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Reinsch')">
										<font size="40px;">Reinsch<br/>Library</font>
									</xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'Trinity')">
									TR
                                    </xsl:when>
									
									<xsl:when test="contains(notification_data/destination, 'WRLC')">
									WR
                                    </xsl:when>
									
									<xsl:otherwise>
										<font size="25px;">
											<xsl:value-of select="notification_data/destination"/>
										</font>
										<br/>
									</xsl:otherwise>
								</xsl:choose>
								
								<xsl:if test="(notification_data/phys_item_display/location_code='wrlc shrp')
                                or                                                                                                         
                                (notification_data/phys_item_display/available_items/available_item/item_policy='InLibraryOnly')">
									<br/>
									<font size="4px;">In Library Use ONLY</font>
								</xsl:if>
							</h1>
						</td>
						
						<xsl:choose>
							<xsl:when test="notification_data/request/request_type='PHYSICAL_TO_DIGITIZATION'">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<h3 style='text-decoration: underline;'>DIGITIZATION</h3>
								</td>
							</xsl:when>
							<!--                           <xsl:when test="notification_data/request/request_type='BOOKING'">   -->
							<!-- for type Booking for everyone except Georgetown -->
							<xsl:when test="(notification_data/request/request_type='BOOKING') and (notification_data/org_scope/institution_id !='4111')">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<h3 style='text-decoration: underline;'>BOOKING</h3>
								</td>
							</xsl:when>
							<xsl:when test="notification_data/request/request_type='RESOURCE_SHARING_PHYSICAL_SHIPMENT'">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<h3 style='text-decoration: underline;'>Resource Sharing</h3>
								</td>
							</xsl:when>
							<!-- all physical item request and only GT's booking requests  -->
							<xsl:when test="((notification_data/request/request_type='PATRON_PHYSICAL') or                                                          
                                                           (notification_data/request/request_type='Patron physical item request') or
                                                           (notification_data/request/request_type='BOOKING' and  contains(notification_data/general_data/address_from, 'GU')))">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<h3>Hold until:___________________ </h3>
									<!--<br/>-->
									<!--  <h2>Name: <xsl:value-of select="notification_data/user_for_printing/last_name"/>, <xsl:value-of select="notification_data/user_for_printing/first_name"/> </h2>  -->
									<!--     Another INST: <xsl:value-of select="notification_data/request/from_another_inst"/>   
									Path: <xsl:value-of select="notification_data/organization_unit/path"/>   -->
									<h2>
										<xsl:choose>
											
											<!--  case gw & only preferred first, from partner  -->
											<xsl:when test="(notification_data/user_for_printing/preferred_first_name != '') 
											and
											(contains(notification_data/request/from_another_inst, 'GWA'))"> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/last_name"/>, <xsl:value-of select="notification_data/user_for_printing/preferred_first_name"/>
											</xsl:when>
											
											<!--  case gw & only preferred first, at GW  -->
											<xsl:when test="(notification_data/user_for_printing/preferred_first_name != '') 
											and
											(contains(notification_data/organization_unit/path, 'GWA'))"> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/last_name"/>, <xsl:value-of select="notification_data/user_for_printing/preferred_first_name"/>
											</xsl:when>
											
											<!-- both first and last preferred  -->
											<xsl:when test="(notification_data/user_for_printing/preferred_last_name != '') and 
											(notification_data/user_for_printing/preferred_first_name != '')"> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/preferred_last_name"/>, <xsl:value-of select="notification_data/user_for_printing/preferred_first_name"/>
											</xsl:when>
											
											<!-- only has preferred last name -->
											<xsl:when test="(notification_data/user_for_printing/preferred_last_name != '')"> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/preferred_last_name"/>, <xsl:value-of select="notification_data/user_for_printing/first_name"/>
											</xsl:when>
											
											<!-- only has preferred first name -->
											<xsl:when test="(notification_data/user_for_printing/preferred_first_name != '')"> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/last_name"/>, <xsl:value-of select="notification_data/user_for_printing/preferred_first_name"/>
											</xsl:when>
											
											<!-- default standard names  -->
											<xsl:otherwise> 						
											Name: <xsl:value-of select="notification_data/user_for_printing/last_name"/>,  <xsl:value-of select="notification_data/user_for_printing/first_name"/>
											</xsl:otherwise>
										</xsl:choose>
									</h2>
								</td>
							</xsl:when>
							<xsl:otherwise>
								<td>
									<xsl:value-of select="notification_data/request/request_type"/>
								</td>
							</xsl:otherwise>
						</xsl:choose>
					</tr>

					<tr>
						<td style='text-align: left;width: 50%;word-wrap: break-word;'>
							<h2>
								<!--<xsl:value-of select="notification_data/phys_item_display/available_items/available_item/library_code"/>-->
								<xsl:value-of select="notification_data/phys_item_display/call_number"/>
							</h2>
						</td>
					</tr>
					<tr>
						<td style='text-align: left;width: 50%;word-wrap: break-word;'>
							<h2>
								<xsl:value-of select="notification_data/phys_item_display/location_name"/> (<xsl:value-of select="notification_data/phys_item_display/location_code"/>)
							</h2>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h3>
								<xsl:call-template name="recordTitle"/>
							</h3>
						</td>
					</tr>
					<tr>
						<td>
							<h5 style="word-break: break-word; font-size: 16px">
								<xsl:choose>
									<xsl:when test="notification_data/request/request_type='RESOURCE_SHARING_PHYSICAL_SHIPMENT'">
									Mail to: <xsl:value-of select="notification_data/incoming_request/partner_name"/>
									</xsl:when>
									<xsl:when test="notification_data/destination='Office Delivery'">
									Deliver to: <xsl:value-of select="notification_data/user_for_printing/address1"/>
									</xsl:when>
									<xsl:otherwise>
									Pickup at: <xsl:value-of select="notification_data/destination"/>
									</xsl:otherwise>
								</xsl:choose>
							</h5>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
							</h4>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
							</h4>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
							</h4>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
							</h4>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
                           Requested Date: <xsl:value-of select="notification_data/request/work_flow_entity/create_date"/>
							</h4>
						</td>
					</tr>
					
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h4>
                           Barcode(s): 
                            <xsl:for-each select="notification_data/phys_item_display/available_items/available_item">
                                <xsl:if test="position() &lt;= $barcode_limit">
                                <h3 style='font-size: 20px'>
                                    <xsl:value-of select="barcode"/>
                                </h3>
                                </xsl:if>
                            </xsl:for-each>
							</h4>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<h3>
								<xsl:choose>
									<xsl:when test="contains(notification_data/request/manual_description, 'Volume:')">
									Request Info:  <xsl:value-of select="notification_data/request/manual_description"/>
									</xsl:when>
								</xsl:choose>
							</h3>
						</td>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<br/>
							<!--                              <h3>@@location@@:</h3>   // update location tag??   
                               <h3>Loan Item From:
                                <xsl:value-of select="notification_data/phys_item_display/available_items/available_item/library_code"/>
                                <xsl:value-of select="notification_data/phys_item_display/location_name"/>   
                            </h3>
-->
						</td>
						<!-- This choice statement displays citation detail in the case of digitization,
                        time detail in the case of booking, and nothing for physical item requests -->
						<xsl:choose>
							<xsl:when test="notification_data/request/request_type='PHYSICAL_TO_DIGITIZATION'">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<xsl:if test="notification_data/request/approval_entity/request_type != ''">
										<h3>Type:                                                                                 
											<xsl:value-of select="notification_data/request/approval_entity/request_type"/>
										</h3>
									</xsl:if>
									<xsl:if test="notification_data/request/chapter_article_author != ''">
										<h3>Chapter Author:                                                                                 
                                            <xsl:value-of select="notification_data/request/chapter_article_author"/>
										</h3>
									</xsl:if>
									<xsl:if test="notification_data/request/chapter_article_title != ''">
										<h3>Chapter Title:                                                                                 
                                            <xsl:value-of select="notification_data/request/chapter_article_title"/>
										</h3>
									</xsl:if>
									<xsl:if test="notification_data/request/scan_from_page != ''">
										<h3>Pages:                                                                                 
                                            <xsl:value-of select="notification_data/request/scan_from_page"/> - <xsl:value-of select="notification_data/request/scan_to_page"/>
										</h3>
									</xsl:if>
								</td>
							</xsl:when>
							<xsl:when test="notification_data/request/request_type='BOOKING'">
								<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
									<!-- see below for more on the time conversion template -->
									<xsl:if test="notification_data/request/start_time_dummy/default_value_for_with_validation != ''">
										<h3>Start Time:</h3>
										<h2>
											<xsl:call-template name="epochToDateTime">
												<xsl:with-param name="utcMil" select="notification_data/request/start_time_dummy/default_value_for_with_validation"/>
											</xsl:call-template>
										</h2>
									</xsl:if>
									<xsl:if test="notification_data/request/end_time_dummy/default_value_for_with_validation != ''">
										<h3>End Time:</h3>
										<h2>
											<xsl:call-template name="epochToDateTime">
												<xsl:with-param name="utcMil" select="notification_data/request/end_time_dummy/default_value_for_with_validation"/>
											</xsl:call-template>
										</h2>
									</xsl:if>
								</td>
							</xsl:when>
							<xsl:otherwise>
								<td/>
							</xsl:otherwise>
						</xsl:choose>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
							<br/>
							<!--                            <h3>Barcode:</h3>      -->
							<!-- If Alma finds more than one item that could fill a request this should list all the barcodes,
                            but it hasn't been tested yet -->
							<!--
                            <xsl:for-each select="notification_data/phys_item_display/available_items/available_item">
                                <h2 style='font-family: monospace; font-size: 20px'>
                                    <xsl:value-of select="barcode"/>
                                </h2>
                            </xsl:for-each>
                            <hr />
-->
						</td>
						<!--   regular hold, digitization, cls requests  -->
						<xsl:if test="(notification_data/request/note != '')
                        and
                        (not(contains(notification_data/request/note, 'Request note:')))">
							<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
								<h3>@@request_note@@:</h3>
								<h3>
									<xsl:value-of select="notification_data/request/note"/>
								</h3>
							</td>
						</xsl:if>
						<!--  Resource sharing requests   -->
						<xsl:if test="(notification_data/request/note != '')
                        and
                        (contains(notification_data/request/note, 'Request note:'))">
							<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
								<h3>@@request_note@@:</h3>
								<h3>
									<xsl:value-of select="substring-after(notification_data/request/note, 'Request note:')"/>
								</h3>
							</td>
						</xsl:if>
					</tr>
					<tr>
						<td style="width: 50%;word-wrap: break-word;">
						<!--	<h3>Request ID:                                                                 
                                <xsl:value-of select="notification_data/request_id"/>
							</h3> -->
						</td>
						<td style="width: 50%;word-wrap: break-word;padding:.75pt 2pt .75pt .75pt">
						    <!--
							<xsl:choose>
								<xsl:when test="notification_data/request/request_type='PATRON_PHYSICAL'">
									<h3>
										<b>Need Assistance:</b>
									</h3>
									<xsl:choose>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_AMU'">
											<h2>[AU]</h2>
											<h3>Please contact the American University Library Circulation Desk by phone at 202-885-3221 or email at circulation@american.edu</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_CAA'">
											<h2>[CU]</h2>
											<h3>If you have any questions please contact the Mullen Library Circulation Desk by phone at 202-319-5060 or email at lib-ill@cua.edu.</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GAL'">
											<h2>[GA]</h2>
											<h3>Contact Gallaudet Library staff (library.circdesk@gallaudet.edu) if you encounter any technical problems with online renewals.</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GML'">
											<h2>[GM]</h2>
											<h3>If you encounter any problems with the request process or have questions or comments, please contact any Circulation Staff member at any Mason Library circulation desk or contact clsgm@wrlc.org.</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GUNIV'">
											<h2>[GT]</h2>
											<h3>Contact  Lauinger Library Circulation Desk: (202)687-7607, accessservices@georgetown.edu,
											<br/>
											Blommer Science Library Circulation Desk: (202)687-5687, sciencelib@georgetown.edu
											<br/>
											or SCS Downtown Library Circulation Desk: (202)784-7389, scslibrary@georgetown.edu</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GWA'">
											<h2>[GW]</h2>
											<h3>Please contact the Gelman Library: 202-994-1306, libcls@gwu.edu
											<br/>
											Eckles Library: 202-242-6620, eckles@gwu.edu
											<br/>
											VSTC Library: 571-553-8230, virginia@gwu.edu
											</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_HOW'">
											<h2>[HU]</h2>
											<h3>If you have any questions, please contact the Howard Circulation desk by phone at 202-806-7250 or email at accessdept@howard.edu</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_MAR'">
											<h2>[MU]</h2>
											<h3>Contact Reinsch Library Circulation Desk 703-284-1533 or mucirc@marymount.edu</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_DOC'">
											<h2>[DC]</h2>
											<h3>Please contact the UDC Circulation Desk by phone at 202-274-6009</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_SCF'">
											<h2>[SCF]</h2>
											<h3>If you have any questions, please contact the Shared Collections Facility staff at requests@wrlc.org</h3>
										</xsl:when>
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GUNIVLAW'">
											<h2>[GTL]</h2>
											<h3>Contact Georgetown University Law Library Circulation Desk: (202)662-9131, circ@law.georgetown.edu</h3>
										</xsl:when>
		
										<xsl:when test="notification_data/request/from_another_inst='01WRLC_AMULAW'"><h2>[AL]</h2>
										<h3></h3>
										</xsl:when>

										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GUNIVLAW'"><h2>[GTL]</h2>
										<h3>Contact Georgetown University Law Library Circulation Desk: (202)662-9131, circ@law.georgetown.edu</h3>
										</xsl:when>

										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GWAHLTH'"><h2>[HI]</h2>
										<h3></h3>
										</xsl:when>

										<xsl:when test="notification_data/request/from_another_inst='01WRLC_GWALAW'"><h2>[JB]</h2>
										<h3></h3>
										</xsl:when>

										<xsl:otherwise>
											<h3>Please contact your library's circulation desk if you have any questions or concerns.  
											<xsl:value-of select="notification_data/request/from_another_inst"/>
											</h3>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
								</xsl:otherwise>
							</xsl:choose>
							-->
						</td>
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>
	<!-- Right now bookings can be reserved for specific times and the only field with time (as oppose to just date) 
    in the xml data displays in utc epoch time. Since the Alma letters are (I think) using xsl 1.0
    we don't have access to the newer 2.0 time/date features. This template (which is modified from a Stack Overflow post)
    does a manual conversion, but tzOffset would have to be changed twice a year because of daylight savings -->
	<xsl:template name="epochToDateTime">
		<xsl:param name="utcMil"/>
		<xsl:param name="tzOffset" select="-4"/>
		<xsl:param name="millisecs" select="$utcMil + ($tzOffset * 1000 * 60 * 60)"/>
		<xsl:param name="JDN" select="floor($millisecs div 86400000) + 2440588"/>
		<xsl:param name="mSec" select="$millisecs mod 86400000"/>
		<xsl:param name="f" select="$JDN + 1401 + floor((floor((4 * $JDN + 274277) div 146097) * 3) div 4) - 38"/>
		<xsl:param name="e" select="4*$f + 3"/>
		<xsl:param name="g" select="floor(($e mod 1461) div 4)"/>
		<xsl:param name="h" select="5*$g + 2"/>
		<xsl:param name="d" select="floor(($h mod 153) div 5 ) + 1"/>
		<xsl:param name="m" select="(floor($h div 153) + 2) mod 12 + 1"/>
		<xsl:param name="y" select="floor($e div 1461) - 4716 + floor((14 - $m) div 12)"/>
		<xsl:param name="H" select="floor($mSec div 3600000)"/>
		<xsl:param name="M" select="floor($mSec mod 3600000 div 60000)"/>
		<xsl:param name="AP">
			<xsl:choose>
				<xsl:when test="number($H) &gt; 12">
					<xsl:value-of select="'PM'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'AM'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="hh">
			<xsl:choose>
				<xsl:when test="number($H) &gt; 12">
					<xsl:value-of select="$H - 12"/>
				</xsl:when>
				<xsl:when test="number($H) = 0">
					<xsl:value-of select="12"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$H"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:value-of select="concat($y, format-number($m, '-00'), format-number($d, '-00'))"/>
		<xsl:value-of select="concat(format-number($hh, ' 00'),format-number($M, ':00'), '&#32;', $AP)"/>
	</xsl:template>
</xsl:stylesheet>