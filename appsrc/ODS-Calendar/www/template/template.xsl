<?xml version="1.0" encoding="UTF-8"?>
<!--
 -
  -  $Id$
 -
 -  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 -  project.
 -
 -  Copyright (C) 1998-2007 OpenLink Software
 -
 -  This project is free software; you can redistribute it and/or modify it
 -  under the terms of the GNU General Public License as published by the
 -  Free Software Foundation; only version 2 of the License, dated June 1991.
 -
 -  This program is distributed in the hope that it will be useful, but
 -  WITHOUT ANY WARRANTY; without even the implied warranty of
 -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 -  General Public License for more details.
 -
 -  You should have received a copy of the GNU General Public License along
 -  with this program; if not, write to the Free Software Foundation, Inc.,
 -  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 -
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:v="http://www.openlinksw.com/vspx/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:vm="http://www.openlinksw.com/vspx/macro" xmlns:ods="http://www.openlinksw.com/vspx/ods/">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:variable name="page_title" select="string (//vm:pagetitle)"/>

  <xsl:include href="http://local.virt/DAV/VAD/wa/comp/ods_bar.xsl"/>
  <xsl:include href="dav_browser.xsl"/>

  <!--=========================================================================-->
  <xsl:template match="head/title[string(.)='']" priority="100">
    <title>
      <xsl:value-of select="$page_title"/>
    </title>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="head/title">
    <title>
      <xsl:value-of select="replace(string(.),'!page_title!',$page_title)"/>
    </title>
  </xsl:template>
  <xsl:template match="vm:pagetitle"/>

  <!--=========================================================================-->
  <xsl:template match="v:page[not @style and not @on-error-redirect][@name != 'calendar']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
        <xsl:attribute name="on-error-redirect">error.vspx</xsl:attribute>
        <xsl:if test="not (@on-deadlock-retry)">
          <xsl:attribute name="on-deadlock-retry">5</xsl:attribute>
       </xsl:if>
       <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="v:button[not @xhtml_alt or not @xhtml_title]|v:url[not @xhtml_alt or not @xhtml_title]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="not (@xhtml_alt)">
        <xsl:choose>
          <xsl:when test="@xhtml_title">
            <xsl:attribute name="xhtml_alt"><xsl:value-of select="@xhtml_title"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="@text">
            <xsl:attribute name="xhtml_alt"><xsl:value-of select="@text"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="xhtml_alt"><xsl:value-of select="@value"/></xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="not (@xhtml_title)">
        <xsl:choose>
          <xsl:when test="@xhtml_alt">
            <xsl:attribute name="xhtml_title"><xsl:value-of select="@xhtml_alt"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="@text">
            <xsl:attribute name="xhtml_title"><xsl:value-of select="@text"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="xhtml_title"><xsl:value-of select="@value"/></xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:copyright">
    <?vsp http (coalesce (wa_utf8_to_wide ((select top 1 WS_COPYRIGHT from WA_SETTINGS)), '')); ?>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:disclaimer">
    <?vsp http (coalesce (wa_utf8_to_wide ((select top 1 WS_DISCLAIMER from WA_SETTINGS)), '')); ?>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:popup_page_wrapper">
    <v:variable name="nav_pos_fixed" type="integer" default="1"/>
    <v:variable name="nav_top" type="integer" default="0"/>
    <v:variable name="nav_tip" type="varchar" default="''"/>
    <xsl:for-each select="//v:variable">
      <xsl:copy-of select="."/>
    </xsl:for-each>
    <div style="padding: 0.5em;">
      <div style="padding: 0 0 0.5em 0;">
        &amp;nbsp;<a href="#" onClick="javascript: if (opener != null) opener.focus(); window.close();"><img src="image/close_16.png" border="0" alt="Close" title="Close" />&amp;nbsp;Close</a>
        <hr />
      </div>
      <v:form name="F1" type="simple" method="POST">
        <xsl:apply-templates select="vm:pagebody" />
      </v:form>
    </div>
    <div class="copyright"><vm:copyright /></div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:popup_external_page_wrapper">
    <xsl:element name="v:variable">
      <xsl:attribute name="persist">0</xsl:attribute>
      <xsl:attribute name="name">page_owner</xsl:attribute>
      <xsl:attribute name="type">varchar</xsl:attribute>
      <xsl:choose>
        <xsl:when test="../@vm:owner">
          <xsl:attribute name="default">'<xsl:value-of select="../@vm:owner"/>'</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="default">null</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:apply-templates select="node()|processing-instruction()"/>
    <div class="copyright"><vm:copyright /></div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:pagewrapper">
    <v:variable name="nav_pos_fixed" type="integer" default="0"/>
    <v:variable name="nav_top" type="integer" default="0"/>
    <v:variable name="nav_tip" type="varchar" default="''"/>
    <xsl:for-each select="//v:variable">
      <xsl:copy-of select="."/>
    </xsl:for-each>
    <xsl:apply-templates select="vm:init"/>
    <v:form name="F1" method="POST" type="simple" xhtml_enctype="multipart/form-data">
      <ods:ods-bar app_type='Calendar'/>
      <div id="app_area">
      <div style="background-color: #fff;">
        <div style="float: left;">
          <v:url value="--''" format="%s" url="--sprintf ('%shome.vspx?sid=%s&realm=%s', CAL.WA.calendar_url (self.domain_id), self.sid, self.realm)" xhtml_title="Calendar Home">
            <v:before-render>
              <![CDATA[
                control.ufl_value := '<img src="image/calendarbanner_sml.jpg" border="0" alt="Calendar Home" />';
              ]]>
            </v:before-render>
          </v:url>
        </div>
        <v:template type="simple" enabled="--either(gt(self.domain_id, 0), 1, 0)">
          <div style="float: right; text-align: right; padding-right: 0.5em; padding-top: 20px;">
            <v:text name="keywords" value="--case when (self.cScope = 'search') and (CAL.WA.xml_get ('mode', self.cSearch) <> 'advanced') then CAL.WA.xml_get ('keywords', self.cSearch, '') else '' end" xhtml_onkeypress="return submitEnter(\'F1\', \'GO\', event)"/>
            <xsl:call-template name="nbsp"/>
            <v:button name="GO" action="simple" style="url" value="Search" xhtml_alt="Simple Search">
              <v:on-post>
                <![CDATA[
                  if ((trim (self.keywords.ufl_value) <> '') or (self.cScope = 'search')) {
                    if (CAL.WA.page_name () <> 'home.vspx') {
                      self.vc_redirect (sprintf ('home.vspx?search=%s', self.keywords.ufl_value));
                      return;
                    }
                    self.cScope := 'search';
                    self.cAction := 'browse';
                    self.cSearch := null;
                    CAL.WA.xml_set('keywords', self.cSearch, self.keywords.ufl_value);
                    self.vc_data_bind (e);
                  }
                ]]>
              </v:on-post>
            </v:button>
            |
            <v:button action="simple" style="url" value="Advanced" xhtml_alt="Advanced Search">
              <v:on-post>
                <![CDATA[
                  if (CAL.WA.page_name () <> 'home.vspx') {
                    self.vc_redirect (sprintf ('home.vspx?search=%s&mode=advanced', self.keywords.ufl_value));
                    return;
                  }
                  self.cScope := 'search';
                  self.cAction := 'advanced';
                  self.cSearch := null;
                  CAL.WA.xml_set('mode', self.cSearch, 'advanced');
                  self.vc_data_bind (e);
                ]]>
              </v:on-post>
            </v:button>
          </div>
        </v:template>
        <br style="clear: left;"/>
      </div>
        <div style="border: solid #935000; border-width: 0px 0px 1px 0px;">
          <div style="float: left; padding-left: 0.5em; padding-bottom: 0.25em;">
            <?vsp 
              if (self.domain_id > 0) {
                http (concat (CAL.WA.domain_name (self.domain_id), ' (', CAL.WA.account_fullName (CAL.WA.domain_owner_id (self.domain_id)), ')')); 
              } else {
                http ('Public Calendar'); 
              }
            ?>
          </div>
          <div style="text-align: right; padding-right: 0.5em; padding-bottom: 0.25em;">
        <v:template type="simple" enabled="--case when (self.account_role in ('public', 'guest')) then 0 else 1 end">
          <v:button action="simple" style="url" value="Preferences" xhtml_title="Preferences">
            <v:on-post>
              <![CDATA[
                self.cAction := 'settings';
                self.vc_data_bind (e);
              ]]>
            </v:on-post>
          </v:button>
          |
        </v:template>
        <v:button action="simple" style="url" value="Help" xhtml_alt="Help"/>
      </div>
        </div>
      <v:include url="calendar_login.vspx"/>
      <table id="MTB">
        <tr>
          <!-- Navigation left column -->
          <td id="LC">
            <vm:if test="CAL.WA.page_name () = 'home.vspx'">
              <vm:if test="self.account_role not in ('public', 'guest')">
              <xsl:call-template name="vm:event"/>
            </vm:if>
              <xsl:call-template name="vm:calendar"/>
              <xsl:call-template name="vm:exchange"/>
            <xsl:call-template name="vm:formats"/>
            </vm:if>
          </td>
          <!-- Navigation right column -->
          <td id="RC">
            <v:template type="simple" condition="not self.vc_is_valid">
              <div class="error">
                <p><v:error-summary/></p>
              </div>
            </v:template>
            <div class="main_page_area">
              <xsl:apply-templates select="vm:pagebody" />
            </div>
          </td>
        </tr>
      </table>
      <div id="FT">
        <div id="FT_L">
          <a href="http://www.openlinksw.com/virtuoso">
            <img alt="Powered by OpenLink Virtuoso Universal Server" src="image/virt_power_no_border.png" border="0" />
          </a>
        </div>
        <div id="FT_R">
          <a href="<?V CAL.WA.wa_home_link () ?>faq.html">FAQ</a> |
          <a href="<?V CAL.WA.wa_home_link () ?>privacy.html">Privacy</a> |
          <a href="<?V CAL.WA.wa_home_link () ?>rabuse.vspx">Report Abuse</a>
          <div><vm:copyright /></div>
          <div><vm:disclaimer /></div>
        </div>
      </div> <!-- FT -->
      </div>  
    </v:form>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="vm:event">
    <div class="CE_new lc lc_head" onclick="javascript: cNewEvent(event);">
      New Event
    </div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="vm:calendar">
    <div class="lc">
      <table cellspacing="0" cellpadding="3" style="-moz-user-select: none; cursor: pointer;" class="C_monthtable" id="c_tbl">
        <tbody>
          <tr id="c_header" class="C_heading">
            <td class="C_prev" id="c_month_-1" onmousedown="cSelect(this)" colspan="1">&amp;lt;</td>
            <td class="C_cur" colspan="5">
              <span id="c_month_0" onmousedown="cSelect(this)">
              <?vsp
                http (sprintf ('%s %d', monthname (self.cnMonth), year (self.cnMonth)));
              ?>
              </span>
            </td>
            <td class="C_next" id="c_month_1" onmousedown="cSelect(this)" colspan="1">&amp;gt;</td>
          </tr>
          <tr id="c_dow" class="C_days">
            <?vsp
              declare N integer;
              declare names any;

              names := CAL.WA.dt_WeekNames (self.cWeekStarts, 1);
              for (N := 0; N < length (names); N := N + 1)
                http (sprintf ('<td id="c_day_%d" class="C_dayh">%s</td>', N, names[N]));
            ?>
          </tr>
          <?vsp
            declare N, M, W, D integer;
            declare dt date;
            declare C, S varchar;
            declare eventDays any;

            eventDays := vector ();
            for (select rs.*
                   from CAL.WA.events_forPeriod (rs0, rs1, rs2, rs3)(e_id integer, e_event integer, e_subject varchar, e_start datetime, e_end datetime, e_repeat varchar, e_repeat_offset integer, e_reminder integer) rs
                  where rs0 = self.domain_id
                    and rs1 = self.nCalcDate (0)
                    and rs2 = self.nCalcDate (length (self.cnDays)-1)
                    and rs3 = self.cTimeZone) do
            {
              eventDays := vector_concat (eventDays, vector (CAL.WA.dt_dateClear (e_start)));
            }
            names := CAL.WA.dt_WeekNames (self.cWeekStarts, 1);
            for (N := 0; N < length (self.cnDays); N := N + 1) {
              W := floor (N / 7);
              D := mod (N, 7);
              if ((D = 0) and (W <> 0))
                http ('</tr>');
              if (D = 0)
                http (sprintf ('<tr id="c_week_%d">', W));
              C := '';
              if (W = 0)
                C := C || ' C_day_top';
              if (D = 0)
                C := C || ' C_day_left';
              if (D = 6)
                C := C || ' C_day_right';
              if (self.cnDays[N] > 0)
                C := C || ' C_onmonth';
              if (self.cnDays[N] < 0)
                C := C || ' C_offmonth';
              dt := self.nCalcDate (N);
              if ((dt >= self.cStart) and (dt <= self.cEnd)) {
                if (CAL.WA.dt_isWeekDay (dt, self.cWeekStarts)) {
                  C := C || ' C_weekday_selected';
                } else {
                  C := C || ' C_weekend_selected';
                }
              } else {
                if (CAL.WA.dt_isWeekDay (dt, self.cWeekStarts)) {
                  C := C || ' C_weekday';
                } else {
                  C := C || ' C_weekend';
              }
              }
              if (CAL.WA.dt_compare (self.cnMonth, CAL.WA.dt_BeginOfMonth (curdate ())))
                if (CAL.WA.dt_compare (dt, curdate ()))
                  if ((dt >= self.cStart) and (dt <= self.cEnd)) {
                    C := C || ' C_today_selected';
                  } else {
                    C := C || ' C_today';
                  }
              C := trim (C, ' ');

              S := '';
              for (M := 0; M < length (eventDays); M := M + 1) {
                if (CAL.WA.dt_compare (dt, eventDays [M])) {
                  S := sprintf ('style="%s"', 'font-weight: bold;');
                  goto _exit;
                }
              }
            _exit:;
              http (sprintf ('<td onclick="cSelect(this)" class="%s" %s id="c_day_%d_%d">%d</td>', C, S, W, D, abs (self.cnDays[N])));
            }
            http ('</tr>');
          ?>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="vm:exchange">
    <div class="lc lc_head" onclick="shCell('exchange')">
      <img id="exchange_image" src="image/tr_close.gif" border="0" alt="Open" style="float: left;" />Exchange
    </div>
    <div id="exchange" class="lc lc_closer lc_noborder" style="display: none;">
      <a href="javascript: cExchange('import');" title="Import" class="gems"><img src="image/upld_16.png" border="0" alt="Import" /> Import</a>
      <a href="javascript: cExchange('export');" title="Export" class="gems"><img src="image/dwnld_16.png" border="0" alt="Export" /> Export</a>
    </div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="vm:formats">
    <div class="lc lc_head" onclick="shCell('gems')">
      <img id="gems_image" src="image/tr_close.gif" border="0" alt="Open" style="float: left;" />Calendar Gems
    </div>
    <div id="gems" class="lc lc_closer lc_noborder" style="display: none;">
      <?vsp
        declare exit handler for not found;

        declare S varchar;
        declare lat, lng any;

        select WAUI_LAT, WAUI_LNG into lat, lng from DB.DBA.WA_USER_INFO where WAUI_U_ID = self.account_id;
        if (not is_empty_or_null(lat) and not is_empty_or_null (lng) and exists (select 1 from ODS..SVC_HOST, ODS..APP_PING_REG where SH_NAME = 'GeoURL' and AP_HOST_ID = SH_ID and AP_WAI_ID = self.domain_id)) {
          http (sprintf('<a href="http://geourl.org/near?p=%U" title="GeoURL link" class="gems"><img src="http://i.geourl.org/geourl.png" border="0"/></a>', CAL.WA.calendar_url (self.domain_id)));
          http ('<div style="border-top: 1px solid #7f94a5;"></div>');
        }

        S := CAL.WA.dav_url (self.domain_id);
        http (sprintf('<a href="%sCalendar.%s" target="_blank" title="%s export" class="gems"><img src="image/rss-icon-16.gif" border="0" alt="%s export" /> %s</a>', S, 'rss', 'RSS', 'RSS', 'RSS'));
        http (sprintf('<a href="%sCalendar.%s" target="_blank" title="%s export" class="gems"><img src="image/blue-icon-16.gif" border="0" alt="%s export" /> %s</a>', S, 'atom', 'ATOM', 'ATOM', 'Atom'));
        http (sprintf('<a href="%sCalendar.%s" target="_blank" title="%s export" class="gems"><img src="image/rdf-icon-16.gif" border="0" alt="%s export" /> %s</a>', S, 'rdf', 'RDF', 'RDF', 'RDF'));

        http ('<div style="border-top: 1px solid #7f94a5;"></div>');
        http (sprintf ('<a href="%s" target="_blank" title="FOAF export" alt="FOAF export" class="gems"><img src="image/foaf.png" border="0" alt="FOAF export" /> FOAF</a>', CAL.WA.foaf_url (self.domain_id)));
        http ('<div style="border-top: 1px solid #7f94a5;"></div>');

        S := sprintf ('http://%s/dataspace/%U/calendar/%U/', DB.DBA.wa_cname (), CAL.WA.domain_owner_name (self.domain_id), CAL.WA.domain_name (self.domain_id));
        http (sprintf('<a href="%ssioc.%s" title="%s" class="gems"><img src="image/rdf-icon-16.gif" border="0" alt="%s export" /> %s</a>', S, 'rdf', 'SIOC (RDF/XML)', 'SIOC (RDF/XML)', 'SIOC (RDF/XML)'));
        http (sprintf('<a href="%ssioc.%s" title="%s" class="gems"><img src="image/rdf-icon-16.gif" border="0" alt="%s export" /> %s</a>', S, 'ttl', 'SIOC (N3/Turtle)', 'SIOC (N3/Turtle)', 'SIOC (N3/Turtle)'));
      ?>
    </div>
  </xsl:template>


  <!--=========================================================================-->
  <xsl:template match="vm:ds-navigation">
    &lt;?vsp
      {
        declare _prev, _next, _last, _first vspx_button;
        declare d_prev, d_next, d_last, d_first integer;

        d_prev := d_next := d_last := d_first := 0;
        _first := control.vc_find_control ('<xsl:value-of select="@data-set"/>_first');
        _last := control.vc_find_control ('<xsl:value-of select="@data-set"/>_last');
        _next := control.vc_find_control ('<xsl:value-of select="@data-set"/>_next');
        _prev := control.vc_find_control ('<xsl:value-of select="@data-set"/>_prev');

        if (not (_next is not null and not _next.vc_enabled and _prev is not null and not _prev.vc_enabled)) {
        if (_first is not null and not _first.vc_enabled)
          d_first := 1;

        if (_next is not null and not _next.vc_enabled)
          d_next := 1;

        if (_prev is not null and not _prev.vc_enabled)
          d_prev := 1;

        if (_last is not null and not _last.vc_enabled)
          d_last := 1;
        }
    ?&gt;
    <?vsp
      if (d_first)
        http ('<img src="image/first_16.gif" alt="First" title="First" border="0" />&nbsp;');
    ?>
    <v:button name="{@data-set}_first" action="simple" style="image" value="image/first_16.gif" xhtml_alt="First" text="&amp;nbsp;"/>
    <?vsp
      if (d_prev)
        http ('<img src="image/previous_16.gif" alt="Previous" title="Previous" border="0" />&nbsp;');
    ?>
    <v:button name="{@data-set}_prev" action="simple" style="image" value="image/previous_16.gif" xhtml_alt="Previous" text="&amp;nbsp;"/>
    <?vsp
      if (d_next)
        http ('<img src="image/next_16.gif" alt="Next" title="Next" border="0" />&nbsp;');
    ?>
    <v:button name="{@data-set}_next" action="simple" style="image" value="image/next_16.gif" xhtml_alt="Next" text="&amp;nbsp;"/>
    <?vsp
      if (d_last)
        http ('<img src="image/last_16.gif" alt="Last" title="Last" border="0" />');
    ?>
    <v:button name="{@data-set}_last" action="simple" style="image" value="image/last_16.gif" xhtml_alt="Last" text="&amp;nbsp;"/>
    <?vsp
      }
    ?>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="vm:splash">
    <div style="padding: 1em; font-size: 0.70em;">
      <a href="http://www.openlinksw.com/virtuoso"><img title="Powered by OpenLink Virtuoso Universal Server" src="image/PoweredByVirtuoso.gif" border="0" /></a>
      <br />
      Server version: <?V sys_stat('st_dbms_ver') ?><br/>
      Server build date: <?V sys_stat('st_build_date') ?><br/>
      Calendar version: <?V registry_get('calendar_version') ?><br/>
      Calendar build date: <?V registry_get('calendar_build') ?><br/>
    </div>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:rawheader">
  &lt;?vsp if (self.nav_pos_fixed) { ?&gt;
  <xsl:apply-templates select="node()|processing-instruction()"/>
  &lt;?vsp } ?&gt;
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:raw">
  &lt;?vsp if (self.nav_pos_fixed) { ?&gt;
  <xsl:apply-templates select="node()|processing-instruction()"/>
  &lt;?vsp } ?&gt;
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:pagebody">
    <xsl:choose>
      <xsl:when test="@url">
        <v:template name="vm_pagebody_include_url" type="simple">
          <v:include url="{@url}"/>
        </v:template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()|processing-instruction()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- The rest is from page.xsl -->
  <!--=========================================================================-->
  <xsl:template match="vm:header">
    <xsl:if test="@caption">
    &lt;?vsp if (self.nav_pos_fixed) { ?&gt;
    <td class="page_title">
      <!-- <xsl:copy-of select="@class"/> -->
      <xsl:value-of select="@caption"/>
    </td>
    &lt;?vsp } ?&gt;
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:init">
    <xsl:apply-templates select="node()|processing-instruction()"/>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:if">
    <xsl:processing-instruction name="vsp">
      if (<xsl:value-of select="@test"/>)
      {
    </xsl:processing-instruction>
        <xsl:apply-templates />
    <xsl:processing-instruction name="vsp">
      }
    </xsl:processing-instruction>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:caption">
    <xsl:value-of select="@fixed"/>
    <xsl:apply-templates/>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:label">
    <label>
      <xsl:attribute name="for"><xsl:value-of select="@for"/></xsl:attribute>
      <v:label><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute></v:label>
    </label>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template match="vm:tabCaption">
      <xsl:element name="v:url">
      <xsl:attribute name="url">javascript: showTab(\'<xsl:value-of select="@tab" />\', <xsl:value-of select="@tabsCount" />, <xsl:value-of select="@tabNo" />);</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="@caption"/></xsl:attribute>
      <xsl:attribute name="xhtml_id"><xsl:value-of select="concat(@tab, '_tab_', @tabNo)" /></xsl:attribute>
      <xsl:attribute name="xhtml_class">tab noapp</xsl:attribute>
      </xsl:element>
  </xsl:template>

  <!--=========================================================================-->
  <xsl:template name="nbsp">
    <xsl:param name="count" select="1"/>
    <xsl:if test="$count != 0">
      <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
      <xsl:call-template name="nbsp">
        <xsl:with-param name="count" select="$count - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!--=========================================================================-->

</xsl:stylesheet>
