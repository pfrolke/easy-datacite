<xsl:stylesheet xmlns:car="http://www.carare.eu/carareSchema" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eas="http://easy.dans.knaw.nl/easy/easymetadata/eas/" xmlns:emd="http://easy.dans.knaw.nl/easy/easymetadata/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="emd dc dcterms eas car" version="1.0">
  <xsl:output encoding="UTF-8" indent="yes" method="xml" version="1.0"></xsl:output>
  <xsl:template match="/">
    <xsl:variable name="archaeological_aip" select="emd:easymetadata/emd:other/eas:application-specific/eas:metadataformat[.=&apos;ARCHAEOLOGY&apos;]"></xsl:variable>
    <xsl:variable name="text_aip" select="emd:easymetadata/emd:type/dc:type[.=&apos;Text&apos; and @eas:scheme=&apos;DCMI&apos;]"></xsl:variable>
    <xsl:variable name="open_toegang_geregistreerd" select="emd:easymetadata/emd:rights/dcterms:accessRights[.=&apos;OPEN_ACCESS_FOR_REGISTERED_USERS&apos;]"></xsl:variable>
    <xsl:variable name="open_toegang" select="emd:easymetadata/emd:rights/dcterms:accessRights[.=&apos;OPEN_ACCESS&apos;]"></xsl:variable>
    <xsl:variable name="pointX" select="emd:easymetadata/emd:coverage/eas:spatial/eas:point/eas:x != &apos;&apos;"></xsl:variable>
    <xsl:variable name="boxX" select="emd:easymetadata/emd:coverage/eas:spatial/eas:box/eas:west != &apos;&apos;"></xsl:variable>
    <xsl:if test="$archaeological_aip and $text_aip and ($open_toegang or $open_toegang_geregistreerd) and ($pointX or $boxX)">
      <xsl:apply-templates select="emd:easymetadata"></xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  <xsl:template match="emd:easymetadata">
    <xsl:element name="car:carareWrap">
      <xsl:variable name="pid" select="emd:identifier/dc:identifier[@eas:scheme=&apos;PID&apos; or @eas:identification-system=&apos;http://www.persistent-identifier.nl&apos;]"></xsl:variable>
      <car:carare>
        <xsl:attribute name="id">
          <xsl:value-of select="$pid"></xsl:value-of>
        </xsl:attribute>
        <car:collectionInformation>
          <car:title lang="en">e-archive Dutch Archaeology (DANS-EDNA)</car:title>
          <car:title lang="nl" preferred="true">e-depot Nederlandse archeologie (DANS-EDNA)</car:title>
          <car:keywords lang="en">data archive; datasets; publications; archaeological research; Archaeology; the
            Netherlands</car:keywords>
          <car:contacts>
            <car:name>Drs. Hella Hollander</car:name>
            <car:role lang="en">data archivist archaeology</car:role>
            <car:organization>Data Archiving and Networked Services (DANS)</car:organization>
            <car:address>Anna van Saksenlaan 51, 2593 HW The Hague, the Netherlands</car:address>
            <car:phone>+31 70 3494450</car:phone>
            <car:email>hella.hollander@dans.knaw.nl</car:email>
            <car:email>info@dans.knaw.nl</car:email>
          </car:contacts>
          <car:rights>
            <car:reproductionRights>
              <car:statement lang="en">allowed for research and educational use only</car:statement>
              <car:statement lang="en">for personal reuse only, reproduction or redistribution in any form is not
                allowed, no commercial use allowed</car:statement>
              <car:statement lang="en">attribution compulsory</car:statement>
            </car:reproductionRights>
            <car:licence>http://www.dans.knaw.nl/en/content/data-archive/terms-and-conditions</car:licence>
          </car:rights>
          <car:source>DANS-KNAW</car:source>
          <car:language>nl</car:language>
          <car:coverage>
            <car:spatial>
              <car:locationSet>
                <car:geopoliticalArea>
                  <car:geopoliticalAreaName lang="en">the Netherlands</car:geopoliticalAreaName>
                  <car:geopoliticalAreaType lang="en">country</car:geopoliticalAreaType>   
             </car:geopoliticalArea>
              </car:locationSet>
            </car:spatial>
          </car:coverage>
        </car:collectionInformation>
        
        <xsl:variable name="dataset_taal" select="emd:language/dc:language[@eas:scheme=&apos;ISO 639&apos;]"></xsl:variable>
        <xsl:variable name="meta_taal">
          <xsl:choose>
            <xsl:when test="$dataset_taal=&apos;dut/nld&apos;">nl</xsl:when>
            <xsl:when test="$dataset_taal=&apos;eng&apos;">en</xsl:when>
            <xsl:when test="$dataset_taal=&apos;fre/fra&apos;">fr</xsl:when>
            <xsl:when test="$dataset_taal=&apos;ger/deu&apos;">de</xsl:when>
            <xsl:otherwise>nl</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <car:digitalResource>
          <car:recordInformation>
            <car:id>
              <xsl:value-of select="$pid"></xsl:value-of>
            </car:id>
            <car:source>DANS-KNAW</car:source>
            <car:country>NLD</car:country>
            <car:creation>
              <car:date>
                <xsl:value-of select="substring(emd:date/eas:dateSubmitted[1],1,10)"></xsl:value-of>
              </car:date>
              <car:actor>
                <car:name lang="en">dataset depositor (locally known)</car:name>
                <car:actorType lang="en">individual</car:actorType>
                <car:roles lang="en">depositor</car:roles>
              </car:actor>
            </car:creation>
            <car:language>
              <xsl:value-of select="$meta_taal"></xsl:value-of>
            </car:language>
            <car:rights>
              <car:accessRights>
                <car:grantedTo lang="en">everyone</car:grantedTo>
                <car:statement lang="en">metadata of the archived dataset is freely available to everyone (open
                    access)</car:statement>
              </car:accessRights>
            </car:rights>
          </car:recordInformation>
          <car:appellation>
            
            <xsl:for-each select="emd:title/dc:title">
              <car:name>
                <xsl:attribute name="lang">
                  <xsl:value-of select="$meta_taal"></xsl:value-of>
                </xsl:attribute>
                <xsl:value-of select="."></xsl:value-of>
              </car:name>
            </xsl:for-each>
            <xsl:for-each select="emd:title/dcterms:alternative">
              <car:name>
                <xsl:attribute name="lang">
                  <xsl:value-of select="$meta_taal"></xsl:value-of>
                </xsl:attribute>
                <xsl:value-of select="."></xsl:value-of>
              </car:name>
            </xsl:for-each>
            <car:id>
              <xsl:value-of select="$pid"></xsl:value-of>
            </car:id>
          </car:appellation>
          
          
          <xsl:for-each select="emd:creator/dc:creator">
            <car:actors>
              <car:name>
                <xsl:value-of select="."></xsl:value-of>
              </car:name>
              <car:actorType lang="en">individual</car:actorType>
              <car:roles lang="en">creator</car:roles>
            </car:actors>
          </xsl:for-each>
          
          <xsl:for-each select="emd:creator/eas:creator">
            <xsl:element name="car:actors">
              <xsl:call-template name="nameAndActorType"></xsl:call-template>
              <car:roles lang="en">creator</car:roles>
            </xsl:element>
          </xsl:for-each>
          
          <xsl:for-each select="emd:contributor/dc:contributor">
            <car:actors>
              <car:name>
                <xsl:value-of select="."></xsl:value-of>
              </car:name>
              <car:actorType lang="en">individual</car:actorType>
              <car:roles lang="en">contributor</car:roles>
            </car:actors>
          </xsl:for-each>
          
          <xsl:for-each select="emd:contributor/eas:contributor">
            <xsl:element name="car:actors">        
      <xsl:call-template name="nameAndActorType"></xsl:call-template>
              <car:roles lang="en">contributor</car:roles>
            </xsl:element>
          </xsl:for-each> 
         
          <car:format lang="en">text</car:format>
          <xsl:for-each select="emd:format/dc:format[@eas:scheme=&apos;IMT&apos;]">
            <car:format>
              <xsl:value-of select="."></xsl:value-of>
            </car:format>
          </xsl:for-each>
          
          <car:medium lang="en">webresource</car:medium>
          <car:extent lang="en">one or more digital files</car:extent>
          
          <car:spatial>
            <car:locationSet>
              <xsl:for-each select="emd:coverage/dcterms:spatial">
                <car:namedLocation>
                  <xsl:value-of select="."></xsl:value-of>
                </car:namedLocation>
              </xsl:for-each>
              <car:geopoliticalArea>
                <car:geopoliticalAreaName lang="en">the Netherlands</car:geopoliticalAreaName>
                <car:geopoliticalAreaType lang="en">country</car:geopoliticalAreaType>
              </car:geopoliticalArea>
            </car:locationSet>
            
            <xsl:apply-templates select="emd:coverage"></xsl:apply-templates>
          </car:spatial>
          <car:subject>archeologie</car:subject>
          
          <xsl:for-each select="emd:subject/dc:subject">
            <xsl:variable name="abrsubject" select="@eas:scheme"></xsl:variable>
            <xsl:if test="not ($abrsubject) or $abrsubject != &apos;ABR&apos;">
              <car:subject>
                <xsl:value-of select="."></xsl:value-of>
              </car:subject>
            </xsl:if>
          </xsl:for-each>
                    
          <xsl:variable name="ind" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (substring(.,1,2)=&apos;EI&apos; or substring(.,1,2)=&apos;EG&apos;)]"></xsl:variable>
          <xsl:if test="$ind">
            <car:subject>INDUSTRIAL</car:subject>
          </xsl:if>
          <xsl:variable name="aas" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (substring(.,1,2)=&apos;EX&apos; or substring(.,1,2)=&apos;EL&apos;)]"></xsl:variable>
          <xsl:if test="$aas">
            <car:subject>AGRICULTURE_AND_SUBSISTENCE</car:subject>
          </xsl:if>
          <xsl:variable name="def" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (substring(.,1,1)=&apos;V&apos;)]"></xsl:variable>
          <xsl:if test="$def">
            <car:subject>DEFENCE</car:subject>
          </xsl:if>
          <xsl:variable name="dom" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (substring(.,1,1)=&apos;N&apos;)]"></xsl:variable>
          <xsl:if test="$dom">
            <car:subject>DOMESTIC</car:subject>
          </xsl:if>
          <xsl:variable name="rel" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (.=&apos;DEPO&apos; or substring(.,1,1)=&apos;G&apos; or substring(.,1,1)=&apos;R&apos;)]"></xsl:variable>
          <xsl:if test="$rel">
            <car:subject>RELIGIOUS_RITUAL_AND_FUNERARY</car:subject>
          </xsl:if>
          <xsl:variable name="mar" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (.=&apos;EVX&apos; or .=&apos;ESCH&apos;)]"></xsl:variable>
          <xsl:if test="$mar">
            <car:subject>MARITIME</car:subject>
          </xsl:if>
          <xsl:variable name="mbf" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (.=&apos;GMEG&apos; or substring(.,1,2)=&apos;RK&apos;)]"></xsl:variable>
          <xsl:if test="$mbf">
            <car:subject>MONUMENT_BY_FORM</car:subject>
          </xsl:if>
          <xsl:variable name="trans" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (substring(.,1,1)=&apos;I&apos;)]"></xsl:variable>
          <xsl:if test="$trans">
            <car:subject>TRANSPORT</car:subject>
          </xsl:if>
          <xsl:variable name="unk" select="emd:subject/dc:subject[@eas:scheme=&apos;ABR&apos; and (.=&apos;XXX&apos;)]"></xsl:variable>
          <xsl:if test="$unk">
            <car:subject>UNASSIGNED</car:subject>
          </xsl:if>
          
          <car:temporal>
            
            <xsl:variable name="xxx" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (.=&apos;XXX&apos;)]"></xsl:variable>
            <xsl:if test="$xxx">
              <car:periodName lang="en">UNCERTAIN</car:periodName>
            </xsl:if>
            <xsl:variable name="paleolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,5)=&apos;PALEO&apos;)]"></xsl:variable>
            <xsl:if test="$paleolithicum">
              <car:periodName lang="en">PALAEOLITHIC</car:periodName>
            </xsl:if>
            <xsl:variable name="mesolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,4)=&apos;MESO&apos;)]"></xsl:variable>
            <xsl:if test="$mesolithicum">
              <car:periodName lang="en">MESOLITHIC</car:periodName>
            </xsl:if>
            <xsl:variable name="neolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;NEO&apos;)]"></xsl:variable>
            <xsl:if test="$neolithicum">
              <car:periodName lang="en">NEOLITHIC</car:periodName>
            </xsl:if>
            <xsl:variable name="bronstijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,5)=&apos;BRONS&apos;)]"></xsl:variable>
            <xsl:if test="$bronstijd">
              <car:periodName lang="en">BRONZE_AGE</car:periodName>
            </xsl:if>
            <xsl:variable name="ijzertijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;IJZ&apos;)]"></xsl:variable>
            <xsl:if test="$ijzertijd">
              <car:periodName lang="en">IRON_AGE</car:periodName>
            </xsl:if>
            <xsl:variable name="romeins" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;ROM&apos;)]"></xsl:variable>
            <xsl:if test="$romeins">
              <car:periodName lang="en">ROMAN</car:periodName>
            </xsl:if>
            <xsl:variable name="me" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,2,2)=&apos;ME&apos;)]"></xsl:variable>
            <xsl:if test="$me">
              <car:periodName lang="en">MEDIEVAL</car:periodName>
            </xsl:if>
            <xsl:variable name="nieuwetijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,2)=&apos;NT&apos;)]"></xsl:variable>
            <xsl:if test="$nieuwetijd">
              <car:periodName lang="en">MODERN</car:periodName>
            </xsl:if>
            <xsl:for-each select="emd:coverage/dcterms:temporal">
              <xsl:variable name="abrtemporal" select="@eas:scheme"></xsl:variable>
              <xsl:if test="not ($abrtemporal) or $abrtemporal != &apos;ABR&apos;">
                <car:displayDate lang="nl">
                  <xsl:value-of select="."></xsl:value-of>
                </car:displayDate>
              </xsl:if>
            </xsl:for-each>
            
            <xsl:variable name="t_paleolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,5)=&apos;PALEO&apos;)]"></xsl:variable>
            <xsl:if test="$t_paleolithicum">
              <car:displayDate lang="en">Paleolithic (before 8800 BP)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_mesolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,4)=&apos;MESO&apos;)]"></xsl:variable>
            <xsl:if test="$t_mesolithicum">
              <car:displayDate lang="en">Mesolithic (8800 BP - 4900 BP)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_neolithicum" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;NEO&apos;)]"></xsl:variable>
            <xsl:if test="$t_neolithicum">
              <car:displayDate lang="en">Neolithic (4900 BP - 2000 BP)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_bronstijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,5)=&apos;BRONS&apos;)]"></xsl:variable>
            <xsl:if test="$t_bronstijd">
              <car:displayDate lang="en">Bronze Age (2000 BP - 800 BP)</car:displayDate>
            </xsl:if>       
     <xsl:variable name="t_ijzertijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;IJZ&apos;)]"></xsl:variable>
            <xsl:if test="$t_ijzertijd">
              <car:displayDate lang="en">Iron Age (800 BP - 12 BP)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_romeins" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,3)=&apos;ROM&apos;)]"></xsl:variable>
            <xsl:if test="$t_romeins">
              <car:displayDate lang="en">Roman Era (12 BP - 450)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_me" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,2,2)=&apos;ME&apos;)]"></xsl:variable>
            <xsl:if test="$t_me">
              <car:displayDate lang="en">Middle Ages (450 - 1500)</car:displayDate>
            </xsl:if>
            <xsl:variable name="t_nieuwetijd" select="emd:coverage/dcterms:temporal[@eas:scheme=&apos;ABR&apos; and (substring(.,1,2)=&apos;NT&apos;)]"></xsl:variable>
            <xsl:if test="$t_nieuwetijd">
              <car:displayDate lang="en">Modern Era (after 1500)</car:displayDate>
            </xsl:if>
          </car:temporal>
          
          <car:publicationStatement>
            <xsl:for-each select="emd:publisher/dc:publisher">
              <car:publisher>
                <xsl:value-of select="."></xsl:value-of>
              </car:publisher>
            </xsl:for-each>
            <xsl:if test="not (emd:publisher/dc:publisher)">
              <xsl:for-each select="emd:rights/dcterms:rightsHolder">
                <car:publisher>
                  <xsl:value-of select="."></xsl:value-of>
                </car:publisher>
              </xsl:for-each>
            </xsl:if>
            
            <car:date>
              <xsl:variable name="jaar" select="emd:date/eas:created"></xsl:variable>
              <xsl:value-of select="substring($jaar,1,10)"></xsl:value-of>
            </car:date>
          </car:publicationStatement>
          
          <xsl:variable name="Ntypes" select="count(emd:type/dc:type[@eas:scheme=&apos;DCMI&apos;])"></xsl:variable>
          <xsl:choose>
            <xsl:when test="$Ntypes&gt;0">
              <car:type namespace="http://purl.org/dc/dcmitype/">
                
                <xsl:for-each select="emd:type/dc:type[@eas:scheme=&apos;DCMI&apos;]">
                  <xsl:value-of select="."></xsl:value-of>
                  <xsl:if test="position() != $Ntypes">
                    <xsl:text></xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </car:type>
            </xsl:when>
            <xsl:otherwise>
              <car:type namespace="http://purl.org/dc/dcmitype/">Dataset</car:type>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:variable name="Ndescriptions" select="count(emd:description/dc:description)"></xsl:variable>
          <car:description>
            <xsl:attribute name="lang">
              <xsl:value-of select="$meta_taal"></xsl:value-of>
            </xsl:attribute>
            <xsl:for-each select="emd:description/dc:description">
              <xsl:value-of select="."></xsl:value-of>
              <xsl:if test="position() != $Ndescriptions">
                <xsl:text></xsl:text>
              </xsl:if>
            </xsl:for-each>
          </car:description>
          
          <car:created>
            <xsl:variable name="creatiedatum" select="emd:date/eas:created"></xsl:variable>
            <xsl:variable name="datumvorm" select="emd:date/eas:created/@eas:format"></xsl:variable>
            <xsl:choose>
              <xsl:when test="$datumvorm=&apos;DAY&apos;">
                <xsl:value-of select="substring($creatiedatum,1,10)"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$datumvorm=&apos;MONTH&apos;">
                <xsl:value-of select="substring($creatiedatum,1,7)"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$datumvorm=&apos;YEAR&apos;">
                <xsl:value-of select="substring($creatiedatum,1,4)"></xsl:value-of>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$creatiedatum"></xsl:value-of>
              </xsl:otherwise>
            </xsl:choose>
          </car:created>
          
          <xsl:for-each select="emd:language/dc:language[@eas:scheme=&apos;ISO 639&apos;]">
            <xsl:choose>
              <xsl:when test=".=&apos;dut/nld&apos;">
                <car:language>nl</car:language>
              </xsl:when>
              <xsl:when test=".=&apos;eng&apos;">
                <car:language>en</car:language>
              </xsl:when>
              <xsl:when test=".=&apos;fre/fra&apos;">
                <car:language>fr</car:language>
              </xsl:when>
              <xsl:when test=".=&apos;ger/deu&apos;">
                <car:language>de</car:language>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
          <xsl:if test="not (emd:language/dc:language[@eas:scheme=&apos;ISO 639&apos;])">
            <car:language>nl</car:language>
          </xsl:if>
          <car:link>
            <xsl:value-of select="emd:identifier/dc:identifier[@eas:scheme=&apos;PID&apos; or @eas:identification-system=&apos;http://www.persistent-identifier.nl&apos;]/@eas:identification-system"></xsl:value-of>
            <xsl:text>/?identifier=</xsl:text>
            <xsl:value-of select="emd:identifier/dc:identifier[@eas:scheme=&apos;PID&apos; or @eas:identification-system=&apos;http://www.persistent-identifier.nl&apos;]"></xsl:value-of>
          </car:link>
          <xsl:for-each select="emd:identifier/dc:identifier[@eas:identification-system=&apos;http://archis2.archis.nl&apos;]">
            <car:relations>
              <car:sourceOfRelation>Archis - Research Notification</car:sourceOfRelation>
              <car:typeOfRelation>hasEvent</car:typeOfRelation>
              <car:targetOfRelation>
                <xsl:value-of select="."></xsl:value-of>
              </car:targetOfRelation>
            </car:relations>
          </xsl:for-each>
          <car:rights>
            <car:copyright>
              <xsl:for-each select="emd:rights/dcterms:rightsHolder">
                <car:rightsHolder>
                  <xsl:value-of select="."></xsl:value-of>
                </car:rightsHolder>
              </xsl:for-each>
              <xsl:if test="not (emd:rights/dcterms:rightsHolder)">
                <xsl:for-each select="emd:publisher/dc:publisher">
                  <car:rightsHolder>
                    <xsl:value-of select="."></xsl:value-of>
                  </car:rightsHolder>
                </xsl:for-each>
              </xsl:if>
            </car:copyright>
            <car:accessRights>
              <xsl:variable name="accessrights" select="emd:rights/dcterms:accessRights[@eas:schemeId=&apos;common.dcterms.accessrights&apos; or @eas:schemeId=&apos;archaeology.dcterms.accessrights&apos;]"></xsl:variable>
              <car:grantedTo lang="en">
                <xsl:choose>
                  <xsl:when test="$accessrights=&apos;OPEN_ACCESS&apos;">Everyone</xsl:when>
                  <xsl:when test="$accessrights=&apos;OPEN_ACCESS_FOR_REGISTERED_USERS&apos;">Registered EASY users</xsl:when>
                  <xsl:when test="$accessrights=&apos;GROUP_ACCESS&apos;">Registered EASY users, but
                      belonging to the group of professional Dutch archaeologists only</xsl:when>
                  <xsl:when test="$accessrights=&apos;REQUEST_PERMISSION&apos;">Registered EASY users, but
                      after permission is granted by the depositor </xsl:when>
                  <xsl:when test="$accessrights=&apos;NO_ACCESS&apos;">Registered EASY users, permission is
                      granted occasionally after special mediation</xsl:when>
                </xsl:choose>
              </car:grantedTo>
              <car:conditions lang="en">Allowed for research and educational use, no commercial use allowed,
                  attribution compulsory</car:conditions>
              
              <car:dateFrom>
                <xsl:value-of select="substring(emd:date/eas:available,1,10)"></xsl:value-of>
              </car:dateFrom>
            </car:accessRights>
            <car:reproductionRights>
              <car:statement lang="en">for personal use only, reproduction or redistribution in any form is not
                  allowed, no commercial use is allowed</car:statement>
            </car:reproductionRights>
          </car:rights>
        </car:digitalResource>
      </car:carare>
    </xsl:element>
  </xsl:template>
  <xsl:template name="nameAndActorType">
    
    <xsl:variable name="titles">
      <xsl:choose>
        <xsl:when test="eas:title = &apos;&apos;">
          <xsl:value-of select="&apos;&apos;"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(&apos; &apos;, eas:title)"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="initials">
      <xsl:choose>
        <xsl:when test="eas:initials = &apos;&apos;">
          <xsl:value-of select="&apos;&apos;"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(&apos; &apos;, eas:initials)"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="eas:prefix=&apos;&apos;">
          <xsl:value-of select="&apos;&apos;"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(&apos; &apos;, eas:prefix)"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="organization">
      <xsl:choose>
        <xsl:when test="eas:organization = &apos;&apos;">
          <xsl:value-of select="&apos;&apos;"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(&apos; (&apos;, eas:organization, &apos;)&apos;)"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="eas:surname = &apos;&apos;">
        <xsl:element name="car:name">
          <xsl:value-of select="eas:organization"></xsl:value-of>
        </xsl:element>
        <xsl:element name="car:actorType">
          <xsl:value-of select="&apos;organization&apos;"></xsl:value-of>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="car:name">
          <xsl:value-of select="concat(eas:surname, &apos;,&apos;, $titles, $initials, $prefix, $organization)"></xsl:value-of>
        </xsl:element>
        <xsl:element name="car:actorType">
          <xsl:value-of select="&apos;individual&apos;"></xsl:value-of>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="setPoint">
    <xsl:param name="x"></xsl:param>
    <xsl:param name="y"></xsl:param>
    <car:spatialReferenceSystem>WGS84</car:spatialReferenceSystem>
    <car:geometry>
      <xsl:variable name="dx" select="(-155000.00+$x) div 100000"></xsl:variable>
      <xsl:variable name="dy" select="(-463000.00+$y) div 100000"></xsl:variable>
      
      <xsl:variable name="df" select="(($dy*3235.65389)+($dx*$dx*-32.58297)+($dy*$dy*-0.24750)+($dx*$dx*$dy*-0.84978)+($dy*$dy*$dy*-0.06550)+($dx*$dx*$dy*$dy*-0.01709)+($dx*-0.00738)) div 3600"></xsl:variable>
      <xsl:variable name="dl" select="(($dx*5260.52916)+($dx*$dy*105.94684)+($dx*$dy*$dy*2.45656)+($dx*$dx*$dx*-0.81885)+($dx*$dy*$dy*$dy*0.05594)+($dx*$dx*$dx*$dy*-0.05606)) div 3600"></xsl:variable>
      <xsl:variable name="f" select="52.15517440+$df"></xsl:variable>
      <xsl:variable name="l" select="5.38720621+$dl"></xsl:variable>
      
      <car:quickpoint>
        <car:x>       
   <xsl:value-of select="$l"></xsl:value-of>
        </car:x>
        <car:y>
          <xsl:value-of select="$f"></xsl:value-of>
        </car:y>
      </car:quickpoint>
      <car:storedPrecision>10</car:storedPrecision>
    </car:geometry>
    <car:representations>point</car:representations>
  </xsl:template>
  <xsl:template match="emd:coverage">
    <xsl:choose>
      <xsl:when test="eas:spatial/eas:point[@eas:scheme = &apos;RD&apos;]">
        <xsl:choose>
          <xsl:when test="eas:spatial[1]/eas:point[@eas:scheme = &apos;RD&apos;]">
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="eas:spatial[1]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:x"></xsl:with-param>
              <xsl:with-param name="y" select="eas:spatial[1]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:y"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[2]/eas:point[@eas:scheme = &apos;RD&apos;]">
            <xsl:call-template name="setPoint">   
           <xsl:with-param name="x" select="eas:spatial[2]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:x"></xsl:with-param>
              <xsl:with-param name="y" select="eas:spatial[2]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:y"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[3]/eas:point[@eas:scheme = &apos;RD&apos;]">
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="eas:spatial[3]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:x"></xsl:with-param>
              <xsl:with-param name="y" select="eas:spatial[3]/eas:point[@eas:scheme = &apos;RD&apos;]/eas:y"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="eas:spatial[1]/eas:box[@eas:scheme = &apos;RD&apos;]">
            <xsl:variable name="n" select="number(eas:spatial[1]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:north)"></xsl:variable>
            <xsl:variable name="e" select="number(eas:spatial[1]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:east)"></xsl:variable>
            <xsl:variable name="s" select="number(eas:spatial[1]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:south)"></xsl:variable>
            <xsl:variable name="w" select="number(eas:spatial[1]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:west)"></xsl:variable>
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="round(($w+$e) div 2)"></xsl:with-param>
              <xsl:with-param name="y" select="round(($n+$s) div 2)"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[2]/eas:box[@eas:scheme = &apos;RD&apos;]">
            <xsl:variable name="n" select="number(eas:spatial[2]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:north)"></xsl:variable>
            <xsl:variable name="e" select="number(eas:spatial[2]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:east)"></xsl:variable>
            <xsl:variable name="s" select="number(eas:spatial[2]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:south)"></xsl:variable>
            <xsl:variable name="w" select="number(eas:spatial[2]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:west)"></xsl:variable>
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="round(($w+$e) div 2)"></xsl:with-param>
              <xsl:with-param name="y" select="round(($n+$s) div 2)"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[3]/eas:box[@eas:scheme = &apos;RD&apos;]">
            <xsl:variable name="n" select="number(eas:spatial[3]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:north)"></xsl:variable>
            <xsl:variable name="e" select="number(eas:spatial[3]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:east)"></xsl:variable>
            <xsl:variable name="s" select="number(eas:spatial[3]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:south)"></xsl:variable>
            <xsl:variable name="w" select="number(eas:spatial[3]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:west)"></xsl:variable>
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="round(($w+$e) div 2)"></xsl:with-param>
              <xsl:with-param name="y" select="round(($n+$s) div 2)"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[4]/eas:box[@eas:scheme = &apos;RD&apos;]">
            <xsl:variable name="n" select="number(eas:spatial[4]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:north)"></xsl:variable>
            <xsl:variable name="e" select="number(eas:spatial[4]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:east)"></xsl:variable>
            <xsl:variable name="s" select="number(eas:spatial[4]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:south)"></xsl:variable>
            <xsl:variable name="w" select="number(eas:spatial[4]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:west)"></xsl:variable>
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="round(($w+$e) div 2)"></xsl:with-param>
              <xsl:with-param name="y" select="round(($n+$s) div 2)"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="eas:spatial[5]/eas:box[@eas:scheme = &apos;RD&apos;]">
            <xsl:variable name="n" select="number(eas:spatial[5]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:north)"></xsl:variable>
            <xsl:variable name="e" select="number(eas:spatial[5]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:east)"></xsl:variable>
            <xsl:variable name="s" select="number(eas:spatial[5]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:south)"></xsl:variable>
            <xsl:variable name="w" select="number(eas:spatial[5]/eas:box[@eas:scheme = &apos;RD&apos;]/eas:west)"></xsl:variable>
            <xsl:call-template name="setPoint">
              <xsl:with-param name="x" select="round(($w+$e) div 2)"></xsl:with-param>
              <xsl:with-param name="y" select="round(($n+$s) div 2)"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>