<?xml version="1.0" encoding="UTF-8"?>
<!-- Repeated functions for regularization to be used through Numishare -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:nomisma="http://nomisma.org/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">

	<!-- ************** PARSE ACCEPT-LANGUAGE FROM HTTP HEADER ************** -->
	<xsl:function name="numishare:parseAcceptLanguage">
		<xsl:param name="lang"/>

		<xsl:variable name="languages" as="item()*">
			<xsl:choose>
				<xsl:when test="contains($lang, 'q=')">
					<xsl:analyze-string select="$lang" regex="([^;]+);q=[0-1]\.[0-9],?">
						<xsl:matching-substring>
							<xsl:for-each select="regex-group(1)">
								<xsl:for-each select="tokenize(., ',')">
									<xsl:value-of
										select="
											if (contains(., '-')) then
												substring-before(., '-')
											else
												."/>
								</xsl:for-each>
							</xsl:for-each>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="string-length($lang) &gt; 0">
					<xsl:for-each select="tokenize($lang, ',')">
						<xsl:value-of select="
								if (contains(., '-')) then
									substring-before(., '-')
								else
									."/>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>

		</xsl:variable>

		<xsl:sequence select="distinct-values($languages)"/>
	</xsl:function>

	<!-- ************** RE-ASSEMBLE CATEGORY SOLR FIELDS INTO HUMAN-READABLE CATEGORY ************** -->
	<xsl:function name="numishare:recompile_category">
		<xsl:param name="level" as="xs:integer"/>
		<xsl:param name="category_fragment"/>
		<xsl:param name="tokenized_fragment"/>
		<xsl:value-of select="substring-after(replace($tokenized_fragment[contains(., concat('L', $level, '|'))], '&#x022;', ''), '|')"/>
		<xsl:if test="contains($category_fragment, concat('L', $level + 1, '|'))">
			<xsl:text>--</xsl:text>
			<xsl:value-of select="numishare:recompile_category($tokenized_fragment, $category_fragment, $level + 1)"/>
		</xsl:if>
	</xsl:function>
	<!-- normalize NUDS element -->
	<!-- Google spreadsheet regular expressions
		find: ([^\s]+)\t.*\t(.*)
		replace: <xsl:when test="\$label='$1'">$2</xsl:when>
	-->
	<xsl:function name="numishare:regularize_node">
        <xsl:param name="label"/>
        <xsl:param name="lang"/>
        <xsl:choose>            
            <xsl:when test="$lang='ur'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">اعترافِ تعاون</xsl:when>
                    <xsl:when test="$label='acquisition'">نوادرات کا حصول</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">جس سے حاصل کیا گیا</xsl:when>
                    <xsl:when test="$label='adminDesc'">انتظامی تاریخ</xsl:when>
                    <xsl:when test="$label='appraisal'">تعریف</xsl:when>
                    <xsl:when test="$label='appraiser'">تعریف کرنے والا</xsl:when>
                    <xsl:when test="$label='auction'">نیلامی</xsl:when>
                    <xsl:when test="$label='authority'">اتھارٹی</xsl:when>
                    <xsl:when test="$label='axis'">محور</xsl:when>
                    <xsl:when test="$label='century'">صدی</xsl:when>
                    <xsl:when test="$label='chronList'">فہرست بمطابق تاریخ</xsl:when>
                    <xsl:when test="$label='chronItem'">نوادرات بمطابق تاریخ</xsl:when>
                    <xsl:when test="$label='coinType'">سکے کی قِسم (زمرہ)</xsl:when>
                    <xsl:when test="$label='collection'">مجموعہ</xsl:when>
                    <xsl:when test="$label='color'">رنگ</xsl:when>
                    <xsl:when test="$label='completeness'">جامعیت</xsl:when>
                    <xsl:when test="$label='condition'">حالت</xsl:when>
                    <xsl:when test="$label='conservationState'">تحفظ کی حالت</xsl:when>
                    <xsl:when test="$label='contents'">مشمولات</xsl:when>
                    <xsl:when test="$label='coordinates'">معددات</xsl:when>
                    <xsl:when test="$label='countermark'">بعد میں لگایا گیا نشان</xsl:when>
                    <xsl:when test="$label='date'">تاریخ</xsl:when>
                    <xsl:when test="$label='dateOnObject'">سکہ پر تاریخ</xsl:when>
                    <xsl:when test="$label='dob'">سکہ پر تاریخ</xsl:when>
                    <xsl:when test="$label='dateRange'">تاریخ کی حد</xsl:when>
                    <xsl:when test="$label='decade'">دہائی</xsl:when>
                    <xsl:when test="$label='degree'">ڈگری (درجہ)</xsl:when>
                    <xsl:when test="$label='deity'">دیوی / دیوتا</xsl:when>
                    <xsl:when test="$label='denomination'">مالیتِ سکہ کی اکائی</xsl:when>
                    <xsl:when test="$label='department'">محکمہ</xsl:when>
                    <xsl:when test="$label='deposit'">جمع/ ذخیرہ</xsl:when>
                    <xsl:when test="$label='description'">تفصیلات / وضاحت</xsl:when>
                    <xsl:when test="$label='diameter'">قُطر</xsl:when>
                    <xsl:when test="$label='discovery'">دریافت</xsl:when>
                    <xsl:when test="$label='disposition'">تقسيم و ترتيب</xsl:when>
                    <xsl:when test="$label='dynasty'">سلطنت</xsl:when>
                    <xsl:when test="$label='edge'">کنارہ</xsl:when>
                    <xsl:when test="$label='era'">دور</xsl:when>
                    <xsl:when test="$label='finder'">تلاش کرنے والا</xsl:when>
                    <xsl:when test="$label='findspot'">دریافت ھونے کی جگہ</xsl:when>
                    <xsl:when test="$label='fromDate'">از تاریخ</xsl:when>
                    <xsl:when test="$label='geographic'">جغرافیائی</xsl:when>
                    <xsl:when test="$label='grade'">گریڈ (درجہ)</xsl:when>
                    <xsl:when test="$label='height'">اونچائی</xsl:when>
                    <xsl:when test="$label='hoardDesc'">سکوں کے مجموعہ کی تفصیل</xsl:when>
                    <xsl:when test="$label='identifier'">شناخت کار</xsl:when>
                    <xsl:when test="$label='issuer'">جاری کنندہ</xsl:when>
                    <xsl:when test="$label='landowner'">زمیندار</xsl:when>
                    <xsl:when test="$label='legend'">سکہ پر لکھائی</xsl:when>
                    <xsl:when test="$label='manufacture'">سکہ بنانے کا طریقہ</xsl:when>
                    <xsl:when test="$label='material'">مواد/ دھات</xsl:when>
                    <xsl:when test="$label='measurementsSet'">پیمائش/ ناپ</xsl:when>
                    <xsl:when test="$label='mint'">دار الضرب</xsl:when>
                    <xsl:when test="$label='note'">نوٹ</xsl:when>
                    <xsl:when test="$label='noteSet'">نوٹ</xsl:when>
                    <xsl:when test="$label='objectType'">نوادرات کی قِسم (زمرہ)</xsl:when>
                    <xsl:when test="$label='obverse'">روی سکہ (سکہ کا سیدھا رُخ)</xsl:when>
                    <xsl:when test="$label='obv_leg'">سکہ کے سیدھے رُخ پرلکھائی</xsl:when>
                    <xsl:when test="$label='obv_type'">سکہ کے سیدھے رُخ کی قِسم</xsl:when>
                    <xsl:when test="$label='owner'">مالک</xsl:when>
                    <xsl:when test="$label='physDesc'">طبیعی تفصیل</xsl:when>
                    <xsl:when test="$label='portrait'">تصویر/ شبیہ</xsl:when>
                    <xsl:when test="$label='previousColl'">پچھلا مجموعہ</xsl:when>
                    <xsl:when test="$label='private'">نجی</xsl:when>
                    <xsl:when test="$label='provenance'">ماخز/ منبع</xsl:when>
                    <xsl:when test="$label='public'">عوامی</xsl:when>
                    <xsl:when test="$label='publisher'">ناشر</xsl:when>
                    <xsl:when test="$label='reference'">حوالہ</xsl:when>
                    <xsl:when test="$label='refDesc'">حوالہ جات</xsl:when>
                    <xsl:when test="$label='region'">عِلاقہ</xsl:when>
                    <xsl:when test="$label='repository'">ذخیرہ</xsl:when>
                    <xsl:when test="$label='reverse'">پُشت سکہ</xsl:when>
                    <xsl:when test="$label='rev_leg'">پُشت سکہ پرلکھائی</xsl:when>
                    <xsl:when test="$label='rev_type'">پُشت سکہ کی قِسم</xsl:when>
                    <xsl:when test="$label='saleCatalog'">قیمتِ فروخت کی کتاب</xsl:when>
                    <xsl:when test="$label='saleItem'">فروحت کے لئیے</xsl:when>
                    <xsl:when test="$label='salePrice'">قیمتِ فروخت</xsl:when>
                    <xsl:when test="$label='shape'">شکل</xsl:when>
                    <xsl:when test="$label='state'">ریاست/ سلطنت</xsl:when>
                    <xsl:when test="$label='statedAuthority'">تاریخی حق (اخیتار)</xsl:when>
                    <xsl:when test="$label='subject'">موضوع</xsl:when>
                    <xsl:when test="$label='subjectSet'">مضامین</xsl:when>
                    <xsl:when test="$label='symbol'">علامت</xsl:when>
                    <xsl:when test="$label='testmark'">پرکھ کی علامت</xsl:when>
                    <xsl:when test="$label='timestamp'">توشتہ میں ترمیم کی تاریخ</xsl:when>
                    <xsl:when test="$label='title'">عنوان/ ٹائٹل</xsl:when>
                    <xsl:when test="$label='toDate'">تا تاریخ / تاریخ تک</xsl:when>
                    <xsl:when test="$label='type'">قسم (زمرہ)</xsl:when>
                    <xsl:when test="$label='typeDesc'">تمثیلی تفصیل</xsl:when>
                    <xsl:when test="$label='thickness'">موٹائی</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">سہارا / مدد گار تفصیل</xsl:when>
                    <xsl:when test="$label='wear'">خستگی کی حالت</xsl:when>
                    <xsl:when test="$label='weight'">وزن</xsl:when>
                    <xsl:when test="$label='width'">چوڑائی</xsl:when>
                    <xsl:when test="$label='year'">سال/ سنہ</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='de'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Bestätigung</xsl:when>
                    <xsl:when test="$label='acquisition'">Erwerb</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Erworben von</xsl:when>
                    <xsl:when test="$label='adminDesc'">Administrative Geschichte</xsl:when>
                    <xsl:when test="$label='appraisal'">Schätzung</xsl:when>
                    <xsl:when test="$label='appraiser'">Schätzer</xsl:when>
                    <xsl:when test="$label='auction'">Auktion</xsl:when>
                    <xsl:when test="$label='authority'">Autorität</xsl:when>
                    <xsl:when test="$label='authorizingEntity'">Münzherrschaft</xsl:when>
                    <xsl:when test="$label='axis'">Stellung</xsl:when>
                    <xsl:when test="$label='century'">Jahrhundert</xsl:when>
                    <xsl:when test="$label='chronList'">Chronologische Liste</xsl:when>
                    <xsl:when test="$label='chronItem'">Chronologischer Gegenstand</xsl:when>
                    <xsl:when test="$label='coinType'">Münztyp</xsl:when>
                    <xsl:when test="$label='collection'">Sammlung</xsl:when>
                    <xsl:when test="$label='color'">Farbe</xsl:when>
                    <xsl:when test="$label='completeness'">Vollständigkeit</xsl:when>
                    <xsl:when test="$label='condition'">Erhaltung</xsl:when>
                    <xsl:when test="$label='conservationState'">Erhaltungszustand</xsl:when>
                    <xsl:when test="$label='contents'">Inhalt</xsl:when>
                    <xsl:when test="$label='coordinates'">Koordinaten</xsl:when>
                    <xsl:when test="$label='countermark'">Gegenstempel</xsl:when>
                    <xsl:when test="$label='date'">Datierung</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Datum auf Gegenstand</xsl:when>
                    <xsl:when test="$label='dob'">Datum auf Gegenstand</xsl:when>
                    <xsl:when test="$label='dateRange'">Datierungsspanne</xsl:when>
                    <xsl:when test="$label='decade'">Jahrzehnt</xsl:when>
                    <xsl:when test="$label='degree'">Grad</xsl:when>
                    <xsl:when test="$label='deity'">Gottheit</xsl:when>
                    <xsl:when test="$label='denomination'">Nominale</xsl:when>
                    <xsl:when test="$label='department'">Abteilung</xsl:when>
                    <xsl:when test="$label='deposit'">Depot</xsl:when>
                    <xsl:when test="$label='description'">Beschreibung</xsl:when>
                    <xsl:when test="$label='diameter'">Durchmesser</xsl:when>
                    <xsl:when test="$label='discovery'">Entdeckung</xsl:when>
                    <xsl:when test="$label='disposition'">Disposition</xsl:when>
                    <xsl:when test="$label='dynasty'">Dynastie</xsl:when>
                    <xsl:when test="$label='edge'">Rand</xsl:when>
                    <xsl:when test="$label='era'">Epoche</xsl:when>
                    <xsl:when test="$label='finder'">Finder</xsl:when>
                    <xsl:when test="$label='findspot'">Fundstelle</xsl:when>
                    <xsl:when test="$label='fromDate'">Datum von</xsl:when>
                    <xsl:when test="$label='geographic'">geographisch</xsl:when>
                    <xsl:when test="$label='grade'">Grad</xsl:when>
                    <xsl:when test="$label='height'">Höhe</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Schatzfundbeschreibung</xsl:when>
                    <xsl:when test="$label='identifier'">Inventarnummer</xsl:when>
                    <xsl:when test="$label='issuer'">Herausgeber</xsl:when>
                    <xsl:when test="$label='landowner'">Grundstückseigentümer</xsl:when>
                    <xsl:when test="$label='legend'">Legende</xsl:when>
                    <xsl:when test="$label='manufacture'">Herstellung</xsl:when>
                    <xsl:when test="$label='material'">Material</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Maße</xsl:when>
                    <xsl:when test="$label='mint'">Münzstätte</xsl:when>
                    <xsl:when test="$label='note'">Anmerkung</xsl:when>
                    <xsl:when test="$label='noteSet'">Anmerkungen</xsl:when>
                    <xsl:when test="$label='objectType'">Objekttyp</xsl:when>
                    <xsl:when test="$label='obverse'">Vorderseite</xsl:when>
                    <xsl:when test="$label='obv_leg'">Vorderseitenlegende</xsl:when>
                    <xsl:when test="$label='obv_type'">Vorderseitentyp</xsl:when>
                    <xsl:when test="$label='owner'">Eigentümer</xsl:when>
                    <xsl:when test="$label='physDesc'">Physische Beschreibung</xsl:when>
                    <xsl:when test="$label='portrait'">Porträt</xsl:when>
                    <xsl:when test="$label='previousColl'">Vormalige sammlung</xsl:when>
                    <xsl:when test="$label='private'">Privat</xsl:when>
                    <xsl:when test="$label='provenance'">Herkunft</xsl:when>
                    <xsl:when test="$label='public'">öffentlich</xsl:when>
                    <xsl:when test="$label='publisher'">Verlag</xsl:when>
                    <xsl:when test="$label='reference'">Zitat</xsl:when>
                    <xsl:when test="$label='refDesc'">Zitate</xsl:when>
                    <xsl:when test="$label='region'">Region</xsl:when>
                    <xsl:when test="$label='repository'">Depot</xsl:when>
                    <xsl:when test="$label='reverse'">Rückseite</xsl:when>
                    <xsl:when test="$label='rev_leg'">Rückseitenlegende</xsl:when>
                    <xsl:when test="$label='rev_type'">Rückseitentyp</xsl:when>
                    <xsl:when test="$label='ruler'">Prägeherr</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Auktionskatalog</xsl:when>
                    <xsl:when test="$label='saleItem'">Auktionslot</xsl:when>
                    <xsl:when test="$label='salePrice'">Verkaufspreis</xsl:when>
                    <xsl:when test="$label='shape'">Form</xsl:when>
                    <xsl:when test="$label='state'">Münzherrschaft</xsl:when>
                    <xsl:when test="$label='subject'">Subjekt</xsl:when>
                    <xsl:when test="$label='subjectSet'">Subjekte</xsl:when>
                    <xsl:when test="$label='symbol'">Symbol</xsl:when>
                    <xsl:when test="$label='testmark'">Prüfmarke</xsl:when>
                    <xsl:when test="$label='timestamp'">Moodifizierungsdatum</xsl:when>
                    <xsl:when test="$label='title'">Titel</xsl:when>
                    <xsl:when test="$label='toDate'">Datum bis</xsl:when>
                    <xsl:when test="$label='type'">Typ</xsl:when>
                    <xsl:when test="$label='typeDesc'">typologische Beschreibung</xsl:when>
                    <xsl:when test="$label='thickness'">Dicke</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Untertyp Beschreibung</xsl:when>
                    <xsl:when test="$label='wear'">Abnutzung</xsl:when>
                    <xsl:when test="$label='weight'">Gewicht</xsl:when>
                    <xsl:when test="$label='width'">Breite</xsl:when>
                    <xsl:when test="$label='year'">Jahr</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ar'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">تعريف</xsl:when>
                    <xsl:when test="$label='acquisition'">إكتساب</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">مكان الحصول عليها</xsl:when>
                    <xsl:when test="$label='adminDesc'">التاريخ الإداري</xsl:when>
                    <xsl:when test="$label='appraisal'">القيمة</xsl:when>
                    <xsl:when test="$label='appraiser'">من الذى حدد القيمة</xsl:when>
                    <xsl:when test="$label='auction'">المزاد</xsl:when>
                    <xsl:when test="$label='authority'">المسئول عنها</xsl:when>
                    <xsl:when test="$label='axis'">المحور الرأسى</xsl:when>
                    <xsl:when test="$label='century'">القرن</xsl:when>
                    <xsl:when test="$label='chronList'">قائمة بالتسلسل الزمني</xsl:when>
                    <xsl:when test="$label='chronItem'">البند حسب التسلسل الزمني</xsl:when>
                    <xsl:when test="$label='coinType'">النوع المميز للعملة</xsl:when>
                    <xsl:when test="$label='collection'">دار الكتب و الوثائق القومية المصرية</xsl:when>
                    <xsl:when test="$label='color'">لون</xsl:when>
                    <xsl:when test="$label='completeness'">الحالة الخارجية</xsl:when>
                    <xsl:when test="$label='condition'">الظروف</xsl:when>
                    <xsl:when test="$label='conservationState'">حالة الترميم</xsl:when>
                    <xsl:when test="$label='contents'">محتويات</xsl:when>
                    <xsl:when test="$label='coordinates'">الإحداثيات</xsl:when>
                    <xsl:when test="$label='countermark'">العلامة المائية</xsl:when>
                    <xsl:when test="$label='date'">التاريخ</xsl:when>
                    <xsl:when test="$label='dateOnObject'">التاريخ مسجل على القطعة</xsl:when>
                    <xsl:when test="$label='dob'">التاريخ مسجل على القطعة</xsl:when>
                    <xsl:when test="$label='dateRange'">نطاق الفترة التاريخية</xsl:when>
                    <xsl:when test="$label='decade'">العِقد</xsl:when>
                    <xsl:when test="$label='degree'">الفَرَمان</xsl:when>
                    <xsl:when test="$label='deity'">آلِهَة</xsl:when>
                    <xsl:when test="$label='denomination'">طائفة</xsl:when>
                    <xsl:when test="$label='department'">القسم</xsl:when>
                    <xsl:when test="$label='deposit'">مكان الحفظ</xsl:when>
                    <xsl:when test="$label='description'">التوصيف</xsl:when>
                    <xsl:when test="$label='diameter'">قطر</xsl:when>
                    <xsl:when test="$label='discovery'">الاكتشاف</xsl:when>
                    <xsl:when test="$label='disposition'">تقسيم و ترتيب القطع</xsl:when>
                    <xsl:when test="$label='dynasty'">الأُسرة</xsl:when>
                    <xsl:when test="$label='edge'">الحواف</xsl:when>
                    <xsl:when test="$label='era'">الفترة الزمنية</xsl:when>
                    <xsl:when test="$label='finder'">المكتشف</xsl:when>
                    <xsl:when test="$label='findspot'">مكان اكتشاف القطعة</xsl:when>
                    <xsl:when test="$label='fromDate'">التاريخ: من</xsl:when>
                    <xsl:when test="$label='geographic'">المكان</xsl:when>
                    <xsl:when test="$label='grade'">تصنيف الحالة</xsl:when>
                    <xsl:when test="$label='height'">الارتفاع</xsl:when>
                    <xsl:when test="$label='hoardDesc'">وصف الكنز</xsl:when>
                    <xsl:when test="$label='identifier'">رقم السجل</xsl:when>
                    <xsl:when test="$label='issuer'">السئول عن الضرب</xsl:when>
                    <xsl:when test="$label='landowner'">المالك</xsl:when>
                    <xsl:when test="$label='legend'">الكتابات</xsl:when>
                    <xsl:when test="$label='manufacture'">صناعة</xsl:when>
                    <xsl:when test="$label='material'">المادة الخام</xsl:when>
                    <xsl:when test="$label='measurementsSet'">القياسات</xsl:when>
                    <xsl:when test="$label='mint'">دار الضرب</xsl:when>
                    <xsl:when test="$label='note'">ملاحظات</xsl:when>
                    <xsl:when test="$label='noteSet'">ملاحظات</xsl:when>
                    <xsl:when test="$label='objectType'">تصنيف القطعة</xsl:when>
                    <xsl:when test="$label='obverse'">الوجه</xsl:when>
                    <xsl:when test="$label='obv_leg'">نقش جانب الوجه للعملة</xsl:when>
                    <xsl:when test="$label='obv_type'">نوع الوجه على للعملة</xsl:when>
                    <xsl:when test="$label='owner'">حائز القطعة</xsl:when>
                    <xsl:when test="$label='physDesc'">وصف الخواص المادية للعملة</xsl:when>
                    <xsl:when test="$label='portrait'">الصور</xsl:when>
                    <xsl:when test="$label='previousColl'">المجموعة السابقة</xsl:when>
                    <xsl:when test="$label='private'">خصوصية القطعة</xsl:when>
                    <xsl:when test="$label='provenance'">مكان وجود القطعة</xsl:when>
                    <xsl:when test="$label='public'">عمومية القطعة</xsl:when>
                    <xsl:when test="$label='publisher'">الناشر</xsl:when>
                    <xsl:when test="$label='reference'">مرجع</xsl:when>
                    <xsl:when test="$label='refDesc'">المراجع</xsl:when>
                    <xsl:when test="$label='region'">المكان</xsl:when>
                    <xsl:when test="$label='repository'">مكان وجود القطعة</xsl:when>
                    <xsl:when test="$label='reverse'">الظهر</xsl:when>
                    <xsl:when test="$label='rev_leg'">النقش على ظهر العملة</xsl:when>
                    <xsl:when test="$label='rev_type'">نوع ظهر العملة</xsl:when>
                    <xsl:when test="$label='saleCatalog'">الكتالوج</xsl:when>
                    <xsl:when test="$label='saleItem'">الرقم بالكتالوج</xsl:when>
                    <xsl:when test="$label='salePrice'">السعربالكتالوج</xsl:when>
                    <xsl:when test="$label='shape'">الشكل الخارجى</xsl:when>
                    <xsl:when test="$label='state'">السلطة</xsl:when>
                    <xsl:when test="$label='subject'">موضوع</xsl:when>
                    <xsl:when test="$label='subjectSet'">المواضيع</xsl:when>
                    <xsl:when test="$label='symbol'">الرمز</xsl:when>
                    <xsl:when test="$label='testmark'">علامات اختبارجودة القطع</xsl:when>
                    <xsl:when test="$label='timestamp'">تاريخ تعديل أو تغيير التسجيل</xsl:when>
                    <xsl:when test="$label='title'">اللقب</xsl:when>
                    <xsl:when test="$label='toDate'">التاريخ إلى</xsl:when>
                    <xsl:when test="$label='type'">الطراز</xsl:when>
                    <xsl:when test="$label='typeDesc'">الوصف الهندسى/الفراغى</xsl:when>
                    <xsl:when test="$label='thickness'">السمك</xsl:when>
                    <xsl:when test="$label='wear'">الحالة من الحفظ</xsl:when>
                    <xsl:when test="$label='weight'">الوزن</xsl:when>
                    <xsl:when test="$label='width'">العرض</xsl:when>
                    <xsl:when test="$label='year'">السنة</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='fr'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Remerciement</xsl:when>
                    <xsl:when test="$label='acquisition'">Acquisition</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Acquis de</xsl:when>
                    <xsl:when test="$label='adminDesc'">Historique administratif</xsl:when>
                    <xsl:when test="$label='appraisal'">Valorisation</xsl:when>
                    <xsl:when test="$label='appraiser'">Evaluateur</xsl:when>
                    <xsl:when test="$label='auction'">Enchère</xsl:when>
                    <xsl:when test="$label='authority'">Autorité émettrice</xsl:when>
                    <xsl:when test="$label='authorizingEntity'">Autorité émettrice</xsl:when>
                    <xsl:when test="$label='axis'">Axe</xsl:when>
                    <xsl:when test="$label='century'">Siècle</xsl:when>
                    <xsl:when test="$label='chronList'">Liste chronologique</xsl:when>
                    <xsl:when test="$label='chronItem'">Objet chronologique</xsl:when>
                    <xsl:when test="$label='coinType'">Référence typologique</xsl:when>
                    <xsl:when test="$label='collection'">Collection</xsl:when>
                    <xsl:when test="$label='color'">Couleur</xsl:when>
                    <xsl:when test="$label='completeness'">Intégrité</xsl:when>
                    <xsl:when test="$label='condition'">Condition</xsl:when>
                    <xsl:when test="$label='conservationState'">Etat de conservation</xsl:when>
                    <xsl:when test="$label='contents'">Contenu</xsl:when>
                    <xsl:when test="$label='coordinates'">Coordonnées</xsl:when>
                    <xsl:when test="$label='countermark'">Contremarque</xsl:when>
                    <xsl:when test="$label='date'">Date</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Date sur l'objet</xsl:when>
                    <xsl:when test="$label='dob'">Date sur l'objet</xsl:when>
                    <xsl:when test="$label='dateRange'">Intervalle chronologique</xsl:when>
                    <xsl:when test="$label='decade'">Décennie</xsl:when>
                    <xsl:when test="$label='degree'">Degré</xsl:when>
                    <xsl:when test="$label='deity'">Divinité</xsl:when>
                    <xsl:when test="$label='denomination'">Dénomination</xsl:when>
                    <xsl:when test="$label='department'">Département</xsl:when>
                    <xsl:when test="$label='deposit'">Dépôt</xsl:when>
                    <xsl:when test="$label='description'">Description</xsl:when>
                    <xsl:when test="$label='diameter'">Diamètre</xsl:when>
                    <xsl:when test="$label='discovery'">Découverte</xsl:when>
                    <xsl:when test="$label='disposition'">Disposition</xsl:when>
                    <xsl:when test="$label='dynasty'">Dynastie</xsl:when>
                    <xsl:when test="$label='edge'">Bordure</xsl:when>
                    <xsl:when test="$label='era'">Ere</xsl:when>
                    <xsl:when test="$label='finder'">Inventeur</xsl:when>
                    <xsl:when test="$label='findspot'">Lieu de découverte</xsl:when>
                    <xsl:when test="$label='fromDate'">A partir de l'année</xsl:when>
                    <xsl:when test="$label='geographic'">Géographique</xsl:when>
                    <xsl:when test="$label='grade'">Grade</xsl:when>
                    <xsl:when test="$label='height'">Hauteur</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Description du trésor</xsl:when>
                    <xsl:when test="$label='identifier'">Identifiant</xsl:when>
                    <xsl:when test="$label='issuer'">Emetteur</xsl:when>
                    <xsl:when test="$label='landowner'">Propriétaire du sol</xsl:when>
                    <xsl:when test="$label='legend'">Légende</xsl:when>
                    <xsl:when test="$label='manufacture'">Technique d'émission</xsl:when>
                    <xsl:when test="$label='material'">Matériau</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Dimensions</xsl:when>
                    <xsl:when test="$label='mint'">Atelier</xsl:when>
                    <xsl:when test="$label='note'">Note</xsl:when>
                    <xsl:when test="$label='noteSet'">Notes</xsl:when>
                    <xsl:when test="$label='objectType'">Type d'objet</xsl:when>
                    <xsl:when test="$label='obverse'">Avers/Droit</xsl:when>
                    <xsl:when test="$label='obv_leg'">Légende d'avers/de droit</xsl:when>
                    <xsl:when test="$label='obv_type'">Type d'avers</xsl:when>
                    <xsl:when test="$label='owner'">Propriétaire</xsl:when>
                    <xsl:when test="$label='physDesc'">Description physique</xsl:when>
                    <xsl:when test="$label='portrait'">Portrait</xsl:when>
                    <xsl:when test="$label='previousColl'">Collection antérieure</xsl:when>
                    <xsl:when test="$label='private'">Privé</xsl:when>
                    <xsl:when test="$label='provenance'">Provenance</xsl:when>
                    <xsl:when test="$label='public'">Publique</xsl:when>
                    <xsl:when test="$label='publisher'">Maison d'édition</xsl:when>
                    <xsl:when test="$label='reference'">Référence</xsl:when>
                    <xsl:when test="$label='refDesc'">Références</xsl:when>
                    <xsl:when test="$label='region'">Région</xsl:when>
                    <xsl:when test="$label='repository'">Dépositaire</xsl:when>
                    <xsl:when test="$label='reverse'">Revers</xsl:when>
                    <xsl:when test="$label='rev_leg'">Légende de revers</xsl:when>
                    <xsl:when test="$label='rev_type'">Type de revers</xsl:when>
                    <xsl:when test="$label='ruler'">Souverain</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Catalogue de vente</xsl:when>
                    <xsl:when test="$label='saleItem'">Numéro de lot</xsl:when>
                    <xsl:when test="$label='salePrice'">Prix de vente</xsl:when>
                    <xsl:when test="$label='shape'">Forme</xsl:when>
                    <xsl:when test="$label='state'">Etat</xsl:when>
                    <xsl:when test="$label='subject'">Sujet</xsl:when>
                    <xsl:when test="$label='subjectSet'">Sujets</xsl:when>
                    <xsl:when test="$label='symbol'">Symbole</xsl:when>
                    <xsl:when test="$label='testmark'">Marque de test</xsl:when>
                    <xsl:when test="$label='timestamp'">Date de l'entrée dans catalogue</xsl:when>
                    <xsl:when test="$label='title'">Titre</xsl:when>
                    <xsl:when test="$label='toDate'">Jusqu'à l'année</xsl:when>
                    <xsl:when test="$label='type'">Type</xsl:when>
                    <xsl:when test="$label='typeDesc'">Description typologique</xsl:when>
                    <xsl:when test="$label='thickness'">Epaisseur</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Description du sous-type</xsl:when>
                    <xsl:when test="$label='wear'">Usure</xsl:when>
                    <xsl:when test="$label='weight'">Poids</xsl:when>
                    <xsl:when test="$label='width'">Largeur</xsl:when>
                    <xsl:when test="$label='year'">Année</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ro'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Mulţumiri</xsl:when>
                    <xsl:when test="$label='acquisition'">Achiziție</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Achiziţionat de la</xsl:when>
                    <xsl:when test="$label='adminDesc'">Istoric administrativ</xsl:when>
                    <xsl:when test="$label='appraisal'">Evaluare</xsl:when>
                    <xsl:when test="$label='appraiser'">Evaluator</xsl:when>
                    <xsl:when test="$label='auction'">Licitație</xsl:when>
                    <xsl:when test="$label='authority'">Autoritate emitentă</xsl:when>
                    <xsl:when test="$label='axis'">Axă</xsl:when>
                    <xsl:when test="$label='century'">Secol</xsl:when>
                    <xsl:when test="$label='chronList'">Listă cronologică</xsl:when>
                    <xsl:when test="$label='chronItem'">Termen cronologic</xsl:when>
                    <xsl:when test="$label='coinType'">Tip monetar</xsl:when>
                    <xsl:when test="$label='collection'">Colecţie</xsl:when>
                    <xsl:when test="$label='color'">Culoare</xsl:when>
                    <xsl:when test="$label='completeness'">Integralitate</xsl:when>
                    <xsl:when test="$label='condition'">Stare de conservare</xsl:when>
                    <xsl:when test="$label='conservationState'">Stare de conservare</xsl:when>
                    <xsl:when test="$label='contents'">Conţinut</xsl:when>
                    <xsl:when test="$label='coordinates'">Coordonate</xsl:when>
                    <xsl:when test="$label='countermark'">Contramarcă</xsl:when>
                    <xsl:when test="$label='date'">Datare</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Datarea de pe obiect</xsl:when>
                    <xsl:when test="$label='dob'">Datarea de pe obiect</xsl:when>
                    <xsl:when test="$label='dateRange'">Interval de datare</xsl:when>
                    <xsl:when test="$label='decade'">Deceniu</xsl:when>
                    <xsl:when test="$label='degree'">Grad</xsl:when>
                    <xsl:when test="$label='deity'">Divinitate</xsl:when>
                    <xsl:when test="$label='denomination'">Nominal</xsl:when>
                    <xsl:when test="$label='department'">Departament</xsl:when>
                    <xsl:when test="$label='deposit'">Depozit</xsl:when>
                    <xsl:when test="$label='description'">Descriere</xsl:when>
                    <xsl:when test="$label='diameter'">Diametru</xsl:when>
                    <xsl:when test="$label='discovery'">Descoperire</xsl:when>
                    <xsl:when test="$label='disposition'">Dispunere</xsl:when>
                    <xsl:when test="$label='dynasty'">Dinastie</xsl:when>
                    <xsl:when test="$label='edge'">Margine</xsl:when>
                    <xsl:when test="$label='era'">Era</xsl:when>
                    <xsl:when test="$label='finder'">Descoperitor</xsl:when>
                    <xsl:when test="$label='findspot'">Loc de descoperire</xsl:when>
                    <xsl:when test="$label='fromDate'">Datare de la</xsl:when>
                    <xsl:when test="$label='geographic'">Geografic</xsl:when>
                    <xsl:when test="$label='grade'">Stadiu</xsl:when>
                    <xsl:when test="$label='height'">Înălţime</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Descrierea tezaurului</xsl:when>
                    <xsl:when test="$label='identifier'">Identificator</xsl:when>
                    <xsl:when test="$label='issuer'">Emitent</xsl:when>
                    <xsl:when test="$label='landowner'">Proprietarul locului de descoperire</xsl:when>
                    <xsl:when test="$label='legend'">Legenda</xsl:when>
                    <xsl:when test="$label='manufacture'">Mod de fabricare</xsl:when>
                    <xsl:when test="$label='material'">Material</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Dimensiuni</xsl:when>
                    <xsl:when test="$label='mint'">Monetărie</xsl:when>
                    <xsl:when test="$label='note'">Observaţie</xsl:when>
                    <xsl:when test="$label='noteSet'">Observații</xsl:when>
                    <xsl:when test="$label='objectType'">Tipul obiectului</xsl:when>
                    <xsl:when test="$label='obverse'">Avers</xsl:when>
                    <xsl:when test="$label='obv_leg'">Legenda aversului</xsl:when>
                    <xsl:when test="$label='obv_type'">Tip de avers</xsl:when>
                    <xsl:when test="$label='owner'">Proprietar</xsl:when>
                    <xsl:when test="$label='physDesc'">Descriere fizică</xsl:when>
                    <xsl:when test="$label='portrait'">Portret</xsl:when>
                    <xsl:when test="$label='previousColl'">Colecție anterioară</xsl:when>
                    <xsl:when test="$label='private'">Privat</xsl:when>
                    <xsl:when test="$label='provenance'">Provenienţă</xsl:when>
                    <xsl:when test="$label='public'">Public</xsl:when>
                    <xsl:when test="$label='reference'">Referinţă</xsl:when>
                    <xsl:when test="$label='refDesc'">Referinţe</xsl:when>
                    <xsl:when test="$label='region'">Regiune</xsl:when>
                    <xsl:when test="$label='repository'">Depozitar</xsl:when>
                    <xsl:when test="$label='reverse'">Revers</xsl:when>
                    <xsl:when test="$label='rev_leg'">Legenda reversului</xsl:when>
                    <xsl:when test="$label='rev_type'">Tip de revers</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Catalog de vânzare</xsl:when>
                    <xsl:when test="$label='saleItem'">Numărul lotului</xsl:when>
                    <xsl:when test="$label='salePrice'">Preţ de vânzare</xsl:when>
                    <xsl:when test="$label='shape'">Formă</xsl:when>
                    <xsl:when test="$label='state'">Stadiu</xsl:when>
                    <xsl:when test="$label='subject'">Subiect</xsl:when>
                    <xsl:when test="$label='subjectSet'">Subiecte</xsl:when>
                    <xsl:when test="$label='symbol'">Simbol</xsl:when>
                    <xsl:when test="$label='testmark'">Marcă de test</xsl:when>
                    <xsl:when test="$label='timestamp'">Data modificării de intrare în catalog</xsl:when>
                    <xsl:when test="$label='title'">Titlu</xsl:when>
                    <xsl:when test="$label='toDate'">Până în/la (datare)</xsl:when>
                    <xsl:when test="$label='type'">Tip</xsl:when>
                    <xsl:when test="$label='typeDesc'">Descriere tipologică</xsl:when>
                    <xsl:when test="$label='thickness'">Grosime</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Descrierea subtipului</xsl:when>
                    <xsl:when test="$label='wear'">Uzură</xsl:when>
                    <xsl:when test="$label='weight'">Greutate</xsl:when>
                    <xsl:when test="$label='width'">Lăţime</xsl:when>
                    <xsl:when test="$label='year'">An</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ru'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Благодарность</xsl:when>
                    <xsl:when test="$label='acquisition'">Приобретение</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Получены от</xsl:when>
                    <xsl:when test="$label='adminDesc'">Административная история</xsl:when>
                    <xsl:when test="$label='appraisal'">Оценка</xsl:when>
                    <xsl:when test="$label='appraiser'">Оценщик</xsl:when>
                    <xsl:when test="$label='auction'">Аукцион</xsl:when>
                    <xsl:when test="$label='authority'">Правитель</xsl:when>
                    <xsl:when test="$label='axis'">Оси</xsl:when>
                    <xsl:when test="$label='century'">Век</xsl:when>
                    <xsl:when test="$label='chronList'">Хронологический лист</xsl:when>
                    <xsl:when test="$label='chronItem'">Объект хронологии</xsl:when>
                    <xsl:when test="$label='coinType'">Монетный тип</xsl:when>
                    <xsl:when test="$label='collection'">Собрание</xsl:when>
                    <xsl:when test="$label='color'">Цвет</xsl:when>
                    <xsl:when test="$label='completeness'">Полнота</xsl:when>
                    <xsl:when test="$label='condition'">Условие</xsl:when>
                    <xsl:when test="$label='conservationState'">Состояние</xsl:when>
                    <xsl:when test="$label='contents'">Содержание</xsl:when>
                    <xsl:when test="$label='coordinates'">Координаты</xsl:when>
                    <xsl:when test="$label='countermark'">Контрмарка</xsl:when>
                    <xsl:when test="$label='date'">Датировка</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Дата на объекте</xsl:when>
                    <xsl:when test="$label='dob'">Дата на объекте</xsl:when>
                    <xsl:when test="$label='dateRange'">Диапазон дат</xsl:when>
                    <xsl:when test="$label='decade'">Десятилетие</xsl:when>
                    <xsl:when test="$label='degree'">Проба</xsl:when>
                    <xsl:when test="$label='deity'">Божество</xsl:when>
                    <xsl:when test="$label='denomination'">Номинал</xsl:when>
                    <xsl:when test="$label='department'">Отделение</xsl:when>
                    <xsl:when test="$label='deposit'">Депозит</xsl:when>
                    <xsl:when test="$label='description'">Описание</xsl:when>
                    <xsl:when test="$label='diameter'">Диаметр</xsl:when>
                    <xsl:when test="$label='discovery'">Открытие</xsl:when>
                    <xsl:when test="$label='disposition'">Размещение</xsl:when>
                    <xsl:when test="$label='dynasty'">Династия</xsl:when>
                    <xsl:when test="$label='edge'">Край</xsl:when>
                    <xsl:when test="$label='era'">Эра</xsl:when>
                    <xsl:when test="$label='finder'">Находчик</xsl:when>
                    <xsl:when test="$label='findspot'">Место находки</xsl:when>
                    <xsl:when test="$label='fromDate'">От даты</xsl:when>
                    <xsl:when test="$label='geographic'">Географический</xsl:when>
                    <xsl:when test="$label='grade'">Градус</xsl:when>
                    <xsl:when test="$label='height'">Высота</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Описание клада</xsl:when>
                    <xsl:when test="$label='identifier'">Идентификатор</xsl:when>
                    <xsl:when test="$label='issuer'">Эмитент</xsl:when>
                    <xsl:when test="$label='landowner'">Землевладелец</xsl:when>
                    <xsl:when test="$label='legend'">Легенда</xsl:when>
                    <xsl:when test="$label='manufacture'">Производство</xsl:when>
                    <xsl:when test="$label='material'">Материал</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Параметры</xsl:when>
                    <xsl:when test="$label='mint'">Монетный двор</xsl:when>
                    <xsl:when test="$label='note'">Примечание</xsl:when>
                    <xsl:when test="$label='noteSet'">Примечания</xsl:when>
                    <xsl:when test="$label='objectType'">Тип предмета</xsl:when>
                    <xsl:when test="$label='obverse'">Аверс</xsl:when>
                    <xsl:when test="$label='obv_leg'">Легенда аверса</xsl:when>
                    <xsl:when test="$label='obv_type'">Тип аверса</xsl:when>
                    <xsl:when test="$label='owner'">Владелец</xsl:when>
                    <xsl:when test="$label='physDesc'">Физическое описание</xsl:when>
                    <xsl:when test="$label='portrait'">Портрет</xsl:when>
                    <xsl:when test="$label='previousColl'">Предыдущее собрание</xsl:when>
                    <xsl:when test="$label='private'">Частный</xsl:when>
                    <xsl:when test="$label='provenance'">Происхождение</xsl:when>
                    <xsl:when test="$label='public'">Публичный</xsl:when>
                    <xsl:when test="$label='publisher'">Издательство</xsl:when>
                    <xsl:when test="$label='reference'">Ссылка</xsl:when>
                    <xsl:when test="$label='refDesc'">Ссылки</xsl:when>
                    <xsl:when test="$label='region'">Регион</xsl:when>
                    <xsl:when test="$label='repository'">Место хранения</xsl:when>
                    <xsl:when test="$label='reverse'">Реверс</xsl:when>
                    <xsl:when test="$label='rev_leg'">Легенда реверса</xsl:when>
                    <xsl:when test="$label='rev_type'">Тип реверса</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Аукционный каталог</xsl:when>
                    <xsl:when test="$label='saleItem'">Аукционный лот</xsl:when>
                    <xsl:when test="$label='salePrice'">Продажная цена</xsl:when>
                    <xsl:when test="$label='shape'">Форма</xsl:when>
                    <xsl:when test="$label='state'">Состояние</xsl:when>
                    <xsl:when test="$label='subject'">Предмет</xsl:when>
                    <xsl:when test="$label='subjectSet'">Предметы</xsl:when>
                    <xsl:when test="$label='symbol'">Символ</xsl:when>
                    <xsl:when test="$label='testmark'">Контрольная метка</xsl:when>
                    <xsl:when test="$label='timestamp'">Дата обновления</xsl:when>
                    <xsl:when test="$label='title'">Заголовок</xsl:when>
                    <xsl:when test="$label='toDate'">К дате</xsl:when>
                    <xsl:when test="$label='type'">Тип</xsl:when>
                    <xsl:when test="$label='typeDesc'">Типологическое описание</xsl:when>
                    <xsl:when test="$label='thickness'">Толщина</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Описание подтипа</xsl:when>
                    <xsl:when test="$label='wear'">Износ</xsl:when>
                    <xsl:when test="$label='weight'">Вес</xsl:when>
                    <xsl:when test="$label='width'">Ширина</xsl:when>
                    <xsl:when test="$label='year'">Год</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='uk'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Подяка</xsl:when>
                    <xsl:when test="$label='acquisition'">Придбання</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Отримані від</xsl:when>
                    <xsl:when test="$label='adminDesc'">Адміністративна історія</xsl:when>
                    <xsl:when test="$label='appraisal'">Оцінка</xsl:when>
                    <xsl:when test="$label='appraiser'">Оцінювач</xsl:when>
                    <xsl:when test="$label='auction'">Аукціон</xsl:when>
                    <xsl:when test="$label='authority'">Правитель</xsl:when>
                    <xsl:when test="$label='axis'">Осі</xsl:when>
                    <xsl:when test="$label='century'">Століття</xsl:when>
                    <xsl:when test="$label='chronList'">Хронологічний лист</xsl:when>
                    <xsl:when test="$label='chronItem'">Об'єкт хронології</xsl:when>
                    <xsl:when test="$label='coinType'">Монетний тип</xsl:when>
                    <xsl:when test="$label='collection'">Зібрання</xsl:when>
                    <xsl:when test="$label='color'">Колір</xsl:when>
                    <xsl:when test="$label='completeness'">Повнота</xsl:when>
                    <xsl:when test="$label='condition'">Умова</xsl:when>
                    <xsl:when test="$label='conservationState'">Стан</xsl:when>
                    <xsl:when test="$label='contents'">Зміст</xsl:when>
                    <xsl:when test="$label='coordinates'">Координати</xsl:when>
                    <xsl:when test="$label='countermark'">Контрмарка</xsl:when>
                    <xsl:when test="$label='date'">Датування</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Дата на об'єкті</xsl:when>
                    <xsl:when test="$label='dob'">Дата на об'єкті</xsl:when>
                    <xsl:when test="$label='dateRange'">Діапазон дат</xsl:when>
                    <xsl:when test="$label='decade'">Десятиріччя</xsl:when>
                    <xsl:when test="$label='degree'">Проба</xsl:when>
                    <xsl:when test="$label='deity'">Божество</xsl:when>
                    <xsl:when test="$label='denomination'">Номінал</xsl:when>
                    <xsl:when test="$label='department'">Відділення</xsl:when>
                    <xsl:when test="$label='deposit'">Депозит</xsl:when>
                    <xsl:when test="$label='description'">Опис</xsl:when>
                    <xsl:when test="$label='diameter'">Діаметр</xsl:when>
                    <xsl:when test="$label='discovery'">Відкриття</xsl:when>
                    <xsl:when test="$label='disposition'">Розміщення</xsl:when>
                    <xsl:when test="$label='dynasty'">Династія</xsl:when>
                    <xsl:when test="$label='edge'">Край</xsl:when>
                    <xsl:when test="$label='era'">Ера</xsl:when>
                    <xsl:when test="$label='finder'">Находчик</xsl:when>
                    <xsl:when test="$label='findspot'">Місце знахідки</xsl:when>
                    <xsl:when test="$label='fromDate'">Від дати</xsl:when>
                    <xsl:when test="$label='geographic'">Географічний</xsl:when>
                    <xsl:when test="$label='grade'">Градус</xsl:when>
                    <xsl:when test="$label='height'">Висота</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Опис скарбу</xsl:when>
                    <xsl:when test="$label='identifier'">Ідентифікатор</xsl:when>
                    <xsl:when test="$label='issuer'">Емітент</xsl:when>
                    <xsl:when test="$label='landowner'">Землевласник</xsl:when>
                    <xsl:when test="$label='legend'">Легенда</xsl:when>
                    <xsl:when test="$label='manufacture'">Виробництво</xsl:when>
                    <xsl:when test="$label='material'">Матеріал</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Параметри</xsl:when>
                    <xsl:when test="$label='mint'">Монетний двір</xsl:when>
                    <xsl:when test="$label='note'">Примітка</xsl:when>
                    <xsl:when test="$label='noteSet'">Примітки</xsl:when>
                    <xsl:when test="$label='objectType'">Тип предмета</xsl:when>
                    <xsl:when test="$label='obverse'">Аверс</xsl:when>
                    <xsl:when test="$label='obv_leg'">Легенда аверсу</xsl:when>
                    <xsl:when test="$label='obv_type'">Тип аверсу</xsl:when>
                    <xsl:when test="$label='owner'">Власник</xsl:when>
                    <xsl:when test="$label='physDesc'">Фізичний опис</xsl:when>
                    <xsl:when test="$label='portrait'">Портрет</xsl:when>
                    <xsl:when test="$label='previousColl'">Попереднє зібрання</xsl:when>
                    <xsl:when test="$label='private'">Приватний</xsl:when>
                    <xsl:when test="$label='provenance'">Походження</xsl:when>
                    <xsl:when test="$label='public'">Публічний</xsl:when>
                    <xsl:when test="$label='publisher'">Видавництво</xsl:when>
                    <xsl:when test="$label='reference'">Посилання</xsl:when>
                    <xsl:when test="$label='refDesc'">Посилання</xsl:when>
                    <xsl:when test="$label='region'">Регіон</xsl:when>
                    <xsl:when test="$label='repository'">Місце зберігання</xsl:when>
                    <xsl:when test="$label='reverse'">Реверс</xsl:when>
                    <xsl:when test="$label='rev_leg'">Легенда реверсу</xsl:when>
                    <xsl:when test="$label='rev_type'">Тип реверсу</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Аукціонний каталог</xsl:when>
                    <xsl:when test="$label='saleItem'">Аукціонний лот</xsl:when>
                    <xsl:when test="$label='salePrice'">Ціна продажу</xsl:when>
                    <xsl:when test="$label='shape'">Форма</xsl:when>
                    <xsl:when test="$label='state'">Стан</xsl:when>
                    <xsl:when test="$label='subject'">Предмет</xsl:when>
                    <xsl:when test="$label='subjectSet'">Предмети</xsl:when>
                    <xsl:when test="$label='symbol'">Символ</xsl:when>
                    <xsl:when test="$label='testmark'">Контрольна мітка</xsl:when>
                    <xsl:when test="$label='timestamp'">Дата оновлення</xsl:when>
                    <xsl:when test="$label='title'">Заголовок</xsl:when>
                    <xsl:when test="$label='toDate'">До дати</xsl:when>
                    <xsl:when test="$label='type'">Тип</xsl:when>
                    <xsl:when test="$label='typeDesc'">Типологічний опис</xsl:when>
                    <xsl:when test="$label='thickness'">Товщина</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Опис підтипу</xsl:when>
                    <xsl:when test="$label='wear'">Зношеність</xsl:when>
                    <xsl:when test="$label='weight'">Вага</xsl:when>
                    <xsl:when test="$label='width'">Ширина</xsl:when>
                    <xsl:when test="$label='year'">Рік</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='nl'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Dankbetuiging</xsl:when>
                    <xsl:when test="$label='acquisition'">Verwerving</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Verworven van</xsl:when>
                    <xsl:when test="$label='adminDesc'">Administratieve geschiedenis</xsl:when>
                    <xsl:when test="$label='appraisal'">Taxatie</xsl:when>
                    <xsl:when test="$label='appraiser'">Taxateur</xsl:when>
                    <xsl:when test="$label='auction'">Veiling</xsl:when>
                    <xsl:when test="$label='authority'">Autoriteit</xsl:when>
                    <xsl:when test="$label='axis'">Stempelstand</xsl:when>
                    <xsl:when test="$label='century'">Eeuw</xsl:when>
                    <xsl:when test="$label='chronList'">Chronologische lijst</xsl:when>
                    <xsl:when test="$label='chronItem'">Chronologisch voorwerp</xsl:when>
                    <xsl:when test="$label='coinType'">Munttype</xsl:when>
                    <xsl:when test="$label='collection'">Collectie</xsl:when>
                    <xsl:when test="$label='color'">Kleur</xsl:when>
                    <xsl:when test="$label='completeness'">Compleetheid</xsl:when>
                    <xsl:when test="$label='condition'">Conditie</xsl:when>
                    <xsl:when test="$label='conservationState'">Staat van conservering</xsl:when>
                    <xsl:when test="$label='contents'">Inhoud</xsl:when>
                    <xsl:when test="$label='coordinates'">Coördinaten</xsl:when>
                    <xsl:when test="$label='countermark'">Instempeling</xsl:when>
                    <xsl:when test="$label='date'">Datum</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Datum op voorwerp</xsl:when>
                    <xsl:when test="$label='dob'">Datum op voorwerp</xsl:when>
                    <xsl:when test="$label='dateRange'">Dateringsperiode</xsl:when>
                    <xsl:when test="$label='decade'">Decennium</xsl:when>
                    <xsl:when test="$label='degree'">Graad</xsl:when>
                    <xsl:when test="$label='deity'">Godheid</xsl:when>
                    <xsl:when test="$label='denomination'">Denominatie</xsl:when>
                    <xsl:when test="$label='department'">Afdeling</xsl:when>
                    <xsl:when test="$label='deposit'">Depot</xsl:when>
                    <xsl:when test="$label='description'">Beschrijving</xsl:when>
                    <xsl:when test="$label='diameter'">Diameter</xsl:when>
                    <xsl:when test="$label='discovery'">Vondst</xsl:when>
                    <xsl:when test="$label='disposition'">Verplaatsing</xsl:when>
                    <xsl:when test="$label='dynasty'">Dynastie</xsl:when>
                    <xsl:when test="$label='edge'">Rand</xsl:when>
                    <xsl:when test="$label='era'">Periode</xsl:when>
                    <xsl:when test="$label='finder'">Vinder</xsl:when>
                    <xsl:when test="$label='findspot'">Vindplaats</xsl:when>
                    <xsl:when test="$label='fromDate'">Datum van</xsl:when>
                    <xsl:when test="$label='geographic'">Geografisch</xsl:when>
                    <xsl:when test="$label='grade'">Kwaliteitsaanduiding</xsl:when>
                    <xsl:when test="$label='height'">Hoogte</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Schatvondstbeschrijving</xsl:when>
                    <xsl:when test="$label='identifier'">Beschrijver</xsl:when>
                    <xsl:when test="$label='issuer'">Uitgever</xsl:when>
                    <xsl:when test="$label='landowner'">Grondeigenaar</xsl:when>
                    <xsl:when test="$label='legend'">Op- of omschrift</xsl:when>
                    <xsl:when test="$label='manufacture'">Maakwijze</xsl:when>
                    <xsl:when test="$label='material'">Materiaal</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Afmetingen</xsl:when>
                    <xsl:when test="$label='mint'">Muntplaats</xsl:when>
                    <xsl:when test="$label='note'">Opmerking</xsl:when>
                    <xsl:when test="$label='noteSet'">Opmerkingen</xsl:when>
                    <xsl:when test="$label='objectType'">Objecttype</xsl:when>
                    <xsl:when test="$label='obverse'">Voorzijde</xsl:when>
                    <xsl:when test="$label='obv_leg'">Tekst voorzijde</xsl:when>
                    <xsl:when test="$label='obv_type'">Voorzijdetype</xsl:when>
                    <xsl:when test="$label='owner'">Eigenaar</xsl:when>
                    <xsl:when test="$label='physDesc'">Fysieke beschrijving</xsl:when>
                    <xsl:when test="$label='portrait'">Portret</xsl:when>
                    <xsl:when test="$label='previousColl'">Voormalige collectie</xsl:when>
                    <xsl:when test="$label='private'">Privé</xsl:when>
                    <xsl:when test="$label='provenance'">Herkomst</xsl:when>
                    <xsl:when test="$label='public'">Publiek</xsl:when>
                    <xsl:when test="$label='publisher'">Uitgever</xsl:when>
                    <xsl:when test="$label='reference'">Referentie</xsl:when>
                    <xsl:when test="$label='refDesc'">Referenties</xsl:when>
                    <xsl:when test="$label='region'">Regio</xsl:when>
                    <xsl:when test="$label='repository'">Verblijfplaats</xsl:when>
                    <xsl:when test="$label='reverse'">Keerzijde</xsl:when>
                    <xsl:when test="$label='rev_leg'">Tekst keerzijde</xsl:when>
                    <xsl:when test="$label='rev_type'">keerzijdetype</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Veilingcatalogus</xsl:when>
                    <xsl:when test="$label='saleItem'">Kavel nummer</xsl:when>
                    <xsl:when test="$label='salePrice'">Verkoopprijs</xsl:when>
                    <xsl:when test="$label='shape'">Vorm</xsl:when>
                    <xsl:when test="$label='state'">Staat</xsl:when>
                    <xsl:when test="$label='subject'">Onderwerp</xsl:when>
                    <xsl:when test="$label='subjectSet'">Onderwerpen</xsl:when>
                    <xsl:when test="$label='symbol'">Symbool</xsl:when>
                    <xsl:when test="$label='testmark'">Testmerk</xsl:when>
                    <xsl:when test="$label='timestamp'">Wijzigingsdatum record</xsl:when>
                    <xsl:when test="$label='title'">Titel</xsl:when>
                    <xsl:when test="$label='toDate'">Datum tot</xsl:when>
                    <xsl:when test="$label='type'">Type</xsl:when>
                    <xsl:when test="$label='typeDesc'">Typologische beschrijving</xsl:when>
                    <xsl:when test="$label='thickness'">Dikte</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Subtype beschrijving</xsl:when>
                    <xsl:when test="$label='wear'">Slijtage</xsl:when>
                    <xsl:when test="$label='weight'">Massa</xsl:when>
                    <xsl:when test="$label='width'">Breedte</xsl:when>
                    <xsl:when test="$label='year'">Jaar</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='sv'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Erkännande</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Förvärvat från</xsl:when>
                    <xsl:when test="$label='adminDesc'">Administrativ historia</xsl:when>
                    <xsl:when test="$label='appraisal'">Värdering</xsl:when>
                    <xsl:when test="$label='appraiser'">Värderare</xsl:when>
                    <xsl:when test="$label='auction'">Auktion</xsl:when>
                    <xsl:when test="$label='authority'">Autoritet</xsl:when>
                    <xsl:when test="$label='axis'">Axel</xsl:when>
                    <xsl:when test="$label='century'">Århundrade/tal</xsl:when>
                    <xsl:when test="$label='coinType'">Mynttyp</xsl:when>
                    <xsl:when test="$label='collection'">Samling</xsl:when>
                    <xsl:when test="$label='color'">Färg</xsl:when>
                    <xsl:when test="$label='completeness'">Fullständighet</xsl:when>
                    <xsl:when test="$label='condition'">Kondition</xsl:when>
                    <xsl:when test="$label='conservationState'">Konserveringstillstånd</xsl:when>
                    <xsl:when test="$label='contents'">Innehål</xsl:when>
                    <xsl:when test="$label='coordinates'">Koordinater</xsl:when>
                    <xsl:when test="$label='countermark'">Kontramarkering</xsl:when>
                    <xsl:when test="$label='date'">Datum</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Datum på objektet</xsl:when>
                    <xsl:when test="$label='dob'">Datum på objektet</xsl:when>
                    <xsl:when test="$label='dateRange'">Dateringsperiod</xsl:when>
                    <xsl:when test="$label='decade'">Decennium</xsl:when>
                    <xsl:when test="$label='degree'">Grad</xsl:when>
                    <xsl:when test="$label='deity'">Gudomlighet</xsl:when>
                    <xsl:when test="$label='denomination'">Valör</xsl:when>
                    <xsl:when test="$label='department'">Avdelning</xsl:when>
                    <xsl:when test="$label='deposit'">Deposition</xsl:when>
                    <xsl:when test="$label='description'">Beskrivning</xsl:when>
                    <xsl:when test="$label='diameter'">Diameter</xsl:when>
                    <xsl:when test="$label='discovery'">Fynd</xsl:when>
                    <xsl:when test="$label='disposition'">Förflyttning</xsl:when>
                    <xsl:when test="$label='dynasty'">Dynasti</xsl:when>
                    <xsl:when test="$label='edge'">Rand</xsl:when>
                    <xsl:when test="$label='era'">Period</xsl:when>
                    <xsl:when test="$label='finder'">Upphittare</xsl:when>
                    <xsl:when test="$label='findspot'">Fyndplats</xsl:when>
                    <xsl:when test="$label='fromDate'">Datum från</xsl:when>
                    <xsl:when test="$label='geographic'">Geografisk</xsl:when>
                    <xsl:when test="$label='grade'">Kvalitet</xsl:when>
                    <xsl:when test="$label='height'">Höjd</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Fynd beskrivning</xsl:when>
                    <xsl:when test="$label='identifier'">Beskrivare</xsl:when>
                    <xsl:when test="$label='issuer'">Utgivare</xsl:when>
                    <xsl:when test="$label='landowner'">Markägare</xsl:when>
                    <xsl:when test="$label='legend'">Omskrift</xsl:when>
                    <xsl:when test="$label='manufacture'">Tillverkning</xsl:when>
                    <xsl:when test="$label='material'">Material</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Mått</xsl:when>
                    <xsl:when test="$label='mint'">Myntverk</xsl:when>
                    <xsl:when test="$label='note'">Anteckning</xsl:when>
                    <xsl:when test="$label='noteSet'">Anteckningar</xsl:when>
                    <xsl:when test="$label='objectType'">Typ av objekt</xsl:when>
                    <xsl:when test="$label='obverse'">Åtsida</xsl:when>
                    <xsl:when test="$label='obv_leg'">Text på åtsidan</xsl:when>
                    <xsl:when test="$label='obv_type'">Åtsidetyp</xsl:when>
                    <xsl:when test="$label='owner'">Ägare</xsl:when>
                    <xsl:when test="$label='physDesc'">Fysisk beskrivning</xsl:when>
                    <xsl:when test="$label='portrait'">Porträtt</xsl:when>
                    <xsl:when test="$label='previousColl'">Tidigare samling</xsl:when>
                    <xsl:when test="$label='private'">Privat</xsl:when>
                    <xsl:when test="$label='provenance'">Proviniens</xsl:when>
                    <xsl:when test="$label='public'">Allmän</xsl:when>
                    <xsl:when test="$label='publisher'">Utgivare</xsl:when>
                    <xsl:when test="$label='reference'">Referens</xsl:when>
                    <xsl:when test="$label='refDesc'">Referenser</xsl:when>
                    <xsl:when test="$label='region'">Region</xsl:when>
                    <xsl:when test="$label='repository'">Förvar</xsl:when>
                    <xsl:when test="$label='reverse'">Frånsida</xsl:when>
                    <xsl:when test="$label='rev_leg'">Text på frånsidan</xsl:when>
                    <xsl:when test="$label='rev_type'">Frånsidetyp</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Försäljningskatalog</xsl:when>
                    <xsl:when test="$label='saleItem'">Lot nummer</xsl:when>
                    <xsl:when test="$label='salePrice'">Försäljningspris</xsl:when>
                    <xsl:when test="$label='shape'">Form</xsl:when>
                    <xsl:when test="$label='state'">Tillstånd</xsl:when>
                    <xsl:when test="$label='subject'">Ämne</xsl:when>
                    <xsl:when test="$label='subjectSet'">Ämnen</xsl:when>
                    <xsl:when test="$label='symbol'">symbol</xsl:when>
                    <xsl:when test="$label='testmark'">Märkestest</xsl:when>
                    <xsl:when test="$label='timestamp'">Ändringsdatum av posten</xsl:when>
                    <xsl:when test="$label='title'">Titel</xsl:when>
                    <xsl:when test="$label='toDate'">Fram till År</xsl:when>
                    <xsl:when test="$label='type'">Typ</xsl:when>
                    <xsl:when test="$label='typeDesc'">Typologisk beskrivning</xsl:when>
                    <xsl:when test="$label='thickness'">Tjocklek</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Beskrivning av undertyp</xsl:when>
                    <xsl:when test="$label='wear'">Slitage</xsl:when>
                    <xsl:when test="$label='weight'">Vikt</xsl:when>
                    <xsl:when test="$label='width'">Bredd</xsl:when>
                    <xsl:when test="$label='year'">År</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='pl'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Podziękowania</xsl:when>
                    <xsl:when test="$label='acquisition'">nabytek</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">pozyskany od</xsl:when>
                    <xsl:when test="$label='adminDesc'">historia administracyjna</xsl:when>
                    <xsl:when test="$label='appraisal'">wycena</xsl:when>
                    <xsl:when test="$label='appraiser'">wyceniający</xsl:when>
                    <xsl:when test="$label='auction'">aukcja</xsl:when>
                    <xsl:when test="$label='authority'">władca</xsl:when>
                    <xsl:when test="$label='axis'">oś</xsl:when>
                    <xsl:when test="$label='century'">stulecie</xsl:when>
                    <xsl:when test="$label='chronList'">lista chronologiczna</xsl:when>
                    <xsl:when test="$label='chronItem'">obiekt chronologii</xsl:when>
                    <xsl:when test="$label='coinType'">typ monetarny</xsl:when>
                    <xsl:when test="$label='collection'">kolekcja</xsl:when>
                    <xsl:when test="$label='color'">kolor</xsl:when>
                    <xsl:when test="$label='completeness'">kompletność</xsl:when>
                    <xsl:when test="$label='condition'">stan zachowania</xsl:when>
                    <xsl:when test="$label='conservationState'">stan konserwacji</xsl:when>
                    <xsl:when test="$label='contents'">treść</xsl:when>
                    <xsl:when test="$label='coordinates'">koordynaty</xsl:when>
                    <xsl:when test="$label='countermark'">kontramarka</xsl:when>
                    <xsl:when test="$label='date'">data</xsl:when>
                    <xsl:when test="$label='dateOnObject'">data na obiekcie</xsl:when>
                    <xsl:when test="$label='dob'">data na obiekcie</xsl:when>
                    <xsl:when test="$label='dateRange'">zakres dat</xsl:when>
                    <xsl:when test="$label='decade'">dekada</xsl:when>
                    <xsl:when test="$label='degree'">stopień</xsl:when>
                    <xsl:when test="$label='deity'">bóstwo</xsl:when>
                    <xsl:when test="$label='denomination'">nominał</xsl:when>
                    <xsl:when test="$label='department'">dział / gabinet</xsl:when>
                    <xsl:when test="$label='deposit'">depozyt</xsl:when>
                    <xsl:when test="$label='description'">opis</xsl:when>
                    <xsl:when test="$label='diameter'">średnica</xsl:when>
                    <xsl:when test="$label='discovery'">odkrycie</xsl:when>
                    <xsl:when test="$label='disposition'">rozmieszczenie</xsl:when>
                    <xsl:when test="$label='dynasty'">dynastia</xsl:when>
                    <xsl:when test="$label='edge'">rant, brzeg</xsl:when>
                    <xsl:when test="$label='era'">era</xsl:when>
                    <xsl:when test="$label='finder'">znalazca</xsl:when>
                    <xsl:when test="$label='findspot'">miejsce znalezienia</xsl:when>
                    <xsl:when test="$label='fromDate'">data od</xsl:when>
                    <xsl:when test="$label='geographic'">geograficzny</xsl:when>
                    <xsl:when test="$label='grade'">stopień</xsl:when>
                    <xsl:when test="$label='height'">wysokość</xsl:when>
                    <xsl:when test="$label='hoardDesc'">opis skarbu</xsl:when>
                    <xsl:when test="$label='identifier'">identyfikator</xsl:when>
                    <xsl:when test="$label='issuer'">emitent</xsl:when>
                    <xsl:when test="$label='landowner'">właściciel gruntu</xsl:when>
                    <xsl:when test="$label='legend'">legenda</xsl:when>
                    <xsl:when test="$label='manufacture'">technika produkcji</xsl:when>
                    <xsl:when test="$label='material'">materiał</xsl:when>
                    <xsl:when test="$label='measurementsSet'">wymiary</xsl:when>
                    <xsl:when test="$label='mint'">mennica</xsl:when>
                    <xsl:when test="$label='note'">uwaga</xsl:when>
                    <xsl:when test="$label='noteSet'">uwagi</xsl:when>
                    <xsl:when test="$label='objectType'">rodzaj obiektu</xsl:when>
                    <xsl:when test="$label='obverse'">awers</xsl:when>
                    <xsl:when test="$label='obv_leg'">legenda awersu</xsl:when>
                    <xsl:when test="$label='obv_type'">typ awersu</xsl:when>
                    <xsl:when test="$label='owner'">właściciel</xsl:when>
                    <xsl:when test="$label='physDesc'">opis fizyczny</xsl:when>
                    <xsl:when test="$label='portrait'">portret</xsl:when>
                    <xsl:when test="$label='previousColl'">poprzednia kolekcja</xsl:when>
                    <xsl:when test="$label='private'">prywatny</xsl:when>
                    <xsl:when test="$label='provenance'">proweniencja</xsl:when>
                    <xsl:when test="$label='public'">publiczny</xsl:when>
                    <xsl:when test="$label='publisher'">wydawca</xsl:when>
                    <xsl:when test="$label='reference'">odsyłacz</xsl:when>
                    <xsl:when test="$label='refDesc'">odsyłacze</xsl:when>
                    <xsl:when test="$label='region'">region</xsl:when>
                    <xsl:when test="$label='repository'">miejsce przechowywania</xsl:when>
                    <xsl:when test="$label='reverse'">rewers</xsl:when>
                    <xsl:when test="$label='rev_leg'">legenda rewersu</xsl:when>
                    <xsl:when test="$label='rev_type'">typ rewersu</xsl:when>
                    <xsl:when test="$label='saleCatalog'">katalog aukcyjny</xsl:when>
                    <xsl:when test="$label='saleItem'">numer aukcyjny</xsl:when>
                    <xsl:when test="$label='salePrice'">cena końcowa</xsl:when>
                    <xsl:when test="$label='shape'">kształt</xsl:when>
                    <xsl:when test="$label='state'">stan</xsl:when>
                    <xsl:when test="$label='subject'">temat</xsl:when>
                    <xsl:when test="$label='subjectSet'">tematy</xsl:when>
                    <xsl:when test="$label='symbol'">symbol</xsl:when>
                    <xsl:when test="$label='testmark'">znak kontrolny</xsl:when>
                    <xsl:when test="$label='timestamp'">data modyfikacji</xsl:when>
                    <xsl:when test="$label='title'">tytuł</xsl:when>
                    <xsl:when test="$label='toDate'">data do</xsl:when>
                    <xsl:when test="$label='type'">typ</xsl:when>
                    <xsl:when test="$label='typeDesc'">opis typologiczny</xsl:when>
                    <xsl:when test="$label='thickness'">grubość</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">opis podtypu</xsl:when>
                    <xsl:when test="$label='wear'">wytarcie</xsl:when>
                    <xsl:when test="$label='weight'">ciężar</xsl:when>
                    <xsl:when test="$label='width'">szerokość</xsl:when>
                    <xsl:when test="$label='year'">rok</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='it'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Riconoscimento</xsl:when>
                    <xsl:when test="$label='acquisition'">Acquisizione</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Acquisito da</xsl:when>
                    <xsl:when test="$label='adminDesc'">Storia amministrativa</xsl:when>
                    <xsl:when test="$label='appraisal'">Stima</xsl:when>
                    <xsl:when test="$label='appraiser'">Perito</xsl:when>
                    <xsl:when test="$label='auction'">Asta</xsl:when>
                    <xsl:when test="$label='authority'">Autorità emittente</xsl:when>
                    <xsl:when test="$label='authorizingEntity'">Autorità emittente</xsl:when>
                    <xsl:when test="$label='axis'">Asse</xsl:when>
                    <xsl:when test="$label='century'">Secolo</xsl:when>
                    <xsl:when test="$label='chronList'">Elenco cronologico</xsl:when>
                    <xsl:when test="$label='chronItem'">Voce cronologica</xsl:when>
                    <xsl:when test="$label='coinType'">Tipo monetale</xsl:when>
                    <xsl:when test="$label='collection'">Collezione</xsl:when>
                    <xsl:when test="$label='color'">Colore</xsl:when>
                    <xsl:when test="$label='completeness'">Integrità</xsl:when>
                    <xsl:when test="$label='condition'">Conservazione</xsl:when>
                    <xsl:when test="$label='conservationState'">Stato di conservazione</xsl:when>
                    <xsl:when test="$label='contents'">Sommario</xsl:when>
                    <xsl:when test="$label='coordinates'">Coordinate</xsl:when>
                    <xsl:when test="$label='countermark'">Contromarca</xsl:when>
                    <xsl:when test="$label='date'">Data</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Datazione dell'oggetto</xsl:when>
                    <xsl:when test="$label='dob'">Datazione dell'oggetto</xsl:when>
                    <xsl:when test="$label='dateRange'">Arco cronologico</xsl:when>
                    <xsl:when test="$label='decade'">Decennio</xsl:when>
                    <xsl:when test="$label='degree'">Grado</xsl:when>
                    <xsl:when test="$label='deity'">Divinità</xsl:when>
                    <xsl:when test="$label='denomination'">Nominale</xsl:when>
                    <xsl:when test="$label='department'">Dipartimento</xsl:when>
                    <xsl:when test="$label='deposit'">Deposito</xsl:when>
                    <xsl:when test="$label='description'">Descrizione</xsl:when>
                    <xsl:when test="$label='diameter'">Diametro</xsl:when>
                    <xsl:when test="$label='discovery'">Scoperta</xsl:when>
                    <xsl:when test="$label='disposition'">Deposizione</xsl:when>
                    <xsl:when test="$label='dynasty'">Dinastia</xsl:when>
                    <xsl:when test="$label='edge'">Bordo</xsl:when>
                    <xsl:when test="$label='era'">Periodo</xsl:when>
                    <xsl:when test="$label='finder'">Scopritore</xsl:when>
                    <xsl:when test="$label='findspot'">Luogo di rinvenimento</xsl:when>
                    <xsl:when test="$label='fromDate'">A partire dall'anno</xsl:when>
                    <xsl:when test="$label='geographic'">Geografico</xsl:when>
                    <xsl:when test="$label='grade'">Grado</xsl:when>
                    <xsl:when test="$label='height'">Altezza</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Descrizione del ripostiglio</xsl:when>
                    <xsl:when test="$label='identifier'">Numero identificativo</xsl:when>
                    <xsl:when test="$label='issuer'">Emittente</xsl:when>
                    <xsl:when test="$label='landowner'">Proprietario del terreno</xsl:when>
                    <xsl:when test="$label='legend'">Legenda</xsl:when>
                    <xsl:when test="$label='manufacture'">Tecnica di produzione</xsl:when>
                    <xsl:when test="$label='material'">Materiale</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Dimensioni</xsl:when>
                    <xsl:when test="$label='mint'">Zecca</xsl:when>
                    <xsl:when test="$label='note'">Nota</xsl:when>
                    <xsl:when test="$label='noteSet'">Annotazioni</xsl:when>
                    <xsl:when test="$label='objectType'">Tipo d'oggetto</xsl:when>
                    <xsl:when test="$label='obverse'">Dritto</xsl:when>
                    <xsl:when test="$label='obv_leg'">Legenda del dritto</xsl:when>
                    <xsl:when test="$label='obv_type'">Tipo del dritto</xsl:when>
                    <xsl:when test="$label='owner'">Proprietario</xsl:when>
                    <xsl:when test="$label='physDesc'">Descrizione fisica</xsl:when>
                    <xsl:when test="$label='portrait'">Ritratto</xsl:when>
                    <xsl:when test="$label='previousColl'">Collezione precedente</xsl:when>
                    <xsl:when test="$label='private'">Privato</xsl:when>
                    <xsl:when test="$label='provenance'">Provenienza</xsl:when>
                    <xsl:when test="$label='public'">Pubblico</xsl:when>
                    <xsl:when test="$label='publisher'">Editore</xsl:when>
                    <xsl:when test="$label='reference'">Riferimento</xsl:when>
                    <xsl:when test="$label='refDesc'">Riferimenti</xsl:when>
                    <xsl:when test="$label='region'">Regione</xsl:when>
                    <xsl:when test="$label='repository'">Deposito</xsl:when>
                    <xsl:when test="$label='reverse'">Rovescio</xsl:when>
                    <xsl:when test="$label='rev_leg'">Legenda del rovescio</xsl:when>
                    <xsl:when test="$label='rev_type'">Tipo del rovescio</xsl:when>
                    <xsl:when test="$label='ruler'">Sovrano</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Catalogo d'asta</xsl:when>
                    <xsl:when test="$label='saleItem'">Numero del lotto</xsl:when>
                    <xsl:when test="$label='salePrice'">Prezzo d'asta</xsl:when>
                    <xsl:when test="$label='shape'">Forma</xsl:when>
                    <xsl:when test="$label='state'">Stato</xsl:when>
                    <xsl:when test="$label='subject'">Soggetto</xsl:when>
                    <xsl:when test="$label='subjectSet'">Soggetti</xsl:when>
                    <xsl:when test="$label='symbol'">Simbolo</xsl:when>
                    <xsl:when test="$label='testmark'">Punzonatura</xsl:when>
                    <xsl:when test="$label='timestamp'">Data di modifica dell'inserimento nel catalogo</xsl:when>
                    <xsl:when test="$label='title'">Titolo</xsl:when>
                    <xsl:when test="$label='toDate'">Fino all'anno</xsl:when>
                    <xsl:when test="$label='type'">Tipo</xsl:when>
                    <xsl:when test="$label='typeDesc'">Descrizione del tipo</xsl:when>
                    <xsl:when test="$label='thickness'">Spessore</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Descrizione del sottotipo</xsl:when>
                    <xsl:when test="$label='wear'">Usura</xsl:when>
                    <xsl:when test="$label='weight'">Peso</xsl:when>
                    <xsl:when test="$label='width'">Larghezza</xsl:when>
                    <xsl:when test="$label='year'">Anno</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='tr'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Onay</xsl:when>
                    <xsl:when test="$label='acquisition'">Edinme</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Kimden/Nereden Geldiği</xsl:when>
                    <xsl:when test="$label='adminDesc'">İdari Geçmiş</xsl:when>
                    <xsl:when test="$label='appraisal'">Değer</xsl:when>
                    <xsl:when test="$label='appraiser'">Değer Biçen</xsl:when>
                    <xsl:when test="$label='auction'">Müzayede</xsl:when>
                    <xsl:when test="$label='authority'">Otorite</xsl:when>
                    <xsl:when test="$label='axis'">Eksen/Yön</xsl:when>
                    <xsl:when test="$label='century'">Yüzyıl</xsl:when>
                    <xsl:when test="$label='chronList'">Kronolojik Liste</xsl:when>
                    <xsl:when test="$label='chronItem'">Kronolojik Öğe</xsl:when>
                    <xsl:when test="$label='coinType'">Sikke Tipi</xsl:when>
                    <xsl:when test="$label='collection'">Koleksiyon</xsl:when>
                    <xsl:when test="$label='color'">Renk</xsl:when>
                    <xsl:when test="$label='completeness'">Eksiksizlik</xsl:when>
                    <xsl:when test="$label='condition'">Kondüsyon</xsl:when>
                    <xsl:when test="$label='conservationState'">Korunma Durumu</xsl:when>
                    <xsl:when test="$label='contents'">İçindekiler</xsl:when>
                    <xsl:when test="$label='coordinates'">Koordinatlar</xsl:when>
                    <xsl:when test="$label='countermark'">Kontrmark</xsl:when>
                    <xsl:when test="$label='date'">Tarih</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Obje Üzerindeki Tarih</xsl:when>
                    <xsl:when test="$label='dob'">Obje Üzerindeki Tarih</xsl:when>
                    <xsl:when test="$label='dateRange'">Tarih Aralığı</xsl:when>
                    <xsl:when test="$label='decade'">Onyıl</xsl:when>
                    <xsl:when test="$label='degree'">Derece</xsl:when>
                    <xsl:when test="$label='deity'">Tanrı</xsl:when>
                    <xsl:when test="$label='denomination'">Birim</xsl:when>
                    <xsl:when test="$label='department'">Bölüm</xsl:when>
                    <xsl:when test="$label='deposit'">Depolama</xsl:when>
                    <xsl:when test="$label='description'">Tanım</xsl:when>
                    <xsl:when test="$label='diameter'">Çap</xsl:when>
                    <xsl:when test="$label='discovery'">Keşif</xsl:when>
                    <xsl:when test="$label='disposition'">Tahsis</xsl:when>
                    <xsl:when test="$label='dynasty'">Hanedan</xsl:when>
                    <xsl:when test="$label='edge'">Kenar</xsl:when>
                    <xsl:when test="$label='era'">Dönem</xsl:when>
                    <xsl:when test="$label='finder'">Bulan</xsl:when>
                    <xsl:when test="$label='findspot'">Buluntu Yeri</xsl:when>
                    <xsl:when test="$label='fromDate'">…-den Sonra (Tarih)</xsl:when>
                    <xsl:when test="$label='geographic'">Coğrafi</xsl:when>
                    <xsl:when test="$label='grade'">Derece</xsl:when>
                    <xsl:when test="$label='height'">Yükseklik</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Define Tanımı</xsl:when>
                    <xsl:when test="$label='identifier'">Tanımlayan</xsl:when>
                    <xsl:when test="$label='issuer'">Basan</xsl:when>
                    <xsl:when test="$label='landowner'">Yer Sahibi</xsl:when>
                    <xsl:when test="$label='legend'">Lejand</xsl:when>
                    <xsl:when test="$label='manufacture'">Üretim Tekniği</xsl:when>
                    <xsl:when test="$label='material'">Malzeme</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Ölçüler</xsl:when>
                    <xsl:when test="$label='mint'">Darphane</xsl:when>
                    <xsl:when test="$label='note'">Not</xsl:when>
                    <xsl:when test="$label='noteSet'">Notlar</xsl:when>
                    <xsl:when test="$label='objectType'">Obje Tipi</xsl:when>
                    <xsl:when test="$label='obverse'">Ön Yüz</xsl:when>
                    <xsl:when test="$label='obv_leg'">Ön Yüz Lejandı</xsl:when>
                    <xsl:when test="$label='obv_type'">Ön Yüz Tipi</xsl:when>
                    <xsl:when test="$label='owner'">Sahibi</xsl:when>
                    <xsl:when test="$label='physDesc'">Fiziksel Tanım</xsl:when>
                    <xsl:when test="$label='portrait'">Portre</xsl:when>
                    <xsl:when test="$label='previousColl'">Önceki Koleksiyon</xsl:when>
                    <xsl:when test="$label='private'">Özel</xsl:when>
                    <xsl:when test="$label='provenance'">Buluntu Yeri</xsl:when>
                    <xsl:when test="$label='public'">Kamusal (Açık)</xsl:when>
                    <xsl:when test="$label='publisher'">Yayıncı</xsl:when>
                    <xsl:when test="$label='reference'">Referans</xsl:when>
                    <xsl:when test="$label='refDesc'">Referanslar</xsl:when>
                    <xsl:when test="$label='region'">Bölge</xsl:when>
                    <xsl:when test="$label='repository'">Depo</xsl:when>
                    <xsl:when test="$label='reverse'">Arka Yüz</xsl:when>
                    <xsl:when test="$label='rev_leg'">Arka Yüz Lejandı</xsl:when>
                    <xsl:when test="$label='rev_type'">Arka Yüz Tipi</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Satış Kataloğu</xsl:when>
                    <xsl:when test="$label='saleItem'">Satılan Öğe</xsl:when>
                    <xsl:when test="$label='salePrice'">Satış Fiyatı</xsl:when>
                    <xsl:when test="$label='shape'">Şekil</xsl:when>
                    <xsl:when test="$label='state'">Eyalet</xsl:when>
                    <xsl:when test="$label='subject'">Konu</xsl:when>
                    <xsl:when test="$label='subjectSet'">Konular</xsl:when>
                    <xsl:when test="$label='symbol'">Sembol</xsl:when>
                    <xsl:when test="$label='testmark'">Test İşareti</xsl:when>
                    <xsl:when test="$label='timestamp'">Değiştirilen Kayıt Tarihi</xsl:when>
                    <xsl:when test="$label='title'">Başlık</xsl:when>
                    <xsl:when test="$label='toDate'">…-e kadar (Tarih)</xsl:when>
                    <xsl:when test="$label='type'">Tip</xsl:when>
                    <xsl:when test="$label='typeDesc'">Tipolojik Açıklama</xsl:when>
                    <xsl:when test="$label='thickness'">Kalınlık</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Alt Tip Açıklaması</xsl:when>
                    <xsl:when test="$label='wear'">Aşınma</xsl:when>
                    <xsl:when test="$label='weight'">Ağırlık</xsl:when>
                    <xsl:when test="$label='width'">Genişlik</xsl:when>
                    <xsl:when test="$label='year'">Yıl</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='fi'">
                <xsl:choose>
                    <xsl:when test="$label='acquisition'">hankinta</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">hankittu kohteesta</xsl:when>
                    <xsl:when test="$label='adminDesc'">hallinnollinen historia</xsl:when>
                    <xsl:when test="$label='appraisal'">arviointi</xsl:when>
                    <xsl:when test="$label='appraiser'">arvioija</xsl:when>
                    <xsl:when test="$label='auction'">huutokauppa</xsl:when>
                    <xsl:when test="$label='authority'">auktoriteetti/asiantuntija</xsl:when>
                    <xsl:when test="$label='axis'">akseli</xsl:when>
                    <xsl:when test="$label='century'">vuosisata</xsl:when>
                    <xsl:when test="$label='chronList'">aikajärjestys</xsl:when>
                    <xsl:when test="$label='chronItem'">kronologinen asia</xsl:when>
                    <xsl:when test="$label='coinType'">kolikon tyyppi</xsl:when>
                    <xsl:when test="$label='collection'">kokoelma/keräelmä</xsl:when>
                    <xsl:when test="$label='color'">väri</xsl:when>
                    <xsl:when test="$label='completeness'">täydellisyys</xsl:when>
                    <xsl:when test="$label='condition'">kunto/tila</xsl:when>
                    <xsl:when test="$label='conservationState'">konservoitu tila</xsl:when>
                    <xsl:when test="$label='contents'">sisältö</xsl:when>
                    <xsl:when test="$label='coordinates'">koordinaatit</xsl:when>
                    <xsl:when test="$label='countermark'">?</xsl:when>
                    <xsl:when test="$label='date'">päivämäärä/päiväys/päivä</xsl:when>
                    <xsl:when test="$label='dateOnObject'">esineessä esiintyvä päivämäärä</xsl:when>
                    <xsl:when test="$label='dob'">esineessä esiintyvä päivämäärä</xsl:when>
                    <xsl:when test="$label='dateRange'">ajanjakso</xsl:when>
                    <xsl:when test="$label='decade'">vuosikymmen</xsl:when>
                    <xsl:when test="$label='degree'">aste</xsl:when>
                    <xsl:when test="$label='deity'">jumalolento/jumala</xsl:when>
                    <xsl:when test="$label='denomination'">nimellisarvo/nimitys</xsl:when>
                    <xsl:when test="$label='department'">osasto</xsl:when>
                    <xsl:when test="$label='deposit'">esiintymä</xsl:when>
                    <xsl:when test="$label='description'">kuvaus</xsl:when>
                    <xsl:when test="$label='diameter'">halkaisija</xsl:when>
                    <xsl:when test="$label='discovery'">löytö</xsl:when>
                    <xsl:when test="$label='disposition'">? luonteenlaatu? :)</xsl:when>
                    <xsl:when test="$label='dynasty'">dynastia/hallitsijasuku</xsl:when>
                    <xsl:when test="$label='edge'">reuna/syrjä</xsl:when>
                    <xsl:when test="$label='era'">aikakausi</xsl:when>
                    <xsl:when test="$label='finder'">löytäjä</xsl:when>
                    <xsl:when test="$label='findspot'">löytöpaikka</xsl:when>
                    <xsl:when test="$label='fromDate'">Alkaen vuodesta....</xsl:when>
                    <xsl:when test="$label='geographic'">maantieteellinen</xsl:when>
                    <xsl:when test="$label='grade'">taso/aste</xsl:when>
                    <xsl:when test="$label='height'">korkeus/pituus</xsl:when>
                    <xsl:when test="$label='hoardDesc'">rahakätkön kuvaus</xsl:when>
                    <xsl:when test="$label='identifier'">tunniste</xsl:when>
                    <xsl:when test="$label='issuer'">liikkeeseenlaskija ?</xsl:when>
                    <xsl:when test="$label='landowner'">maanomistaja</xsl:when>
                    <xsl:when test="$label='legend'">legenda? kuvateksti?</xsl:when>
                    <xsl:when test="$label='manufacture'">valmistus/tuotanto</xsl:when>
                    <xsl:when test="$label='material'">materiaali/aine/aines</xsl:when>
                    <xsl:when test="$label='measurementsSet'">mitat</xsl:when>
                    <xsl:when test="$label='mint'">rahapaja?</xsl:when>
                    <xsl:when test="$label='note'">merkintä</xsl:when>
                    <xsl:when test="$label='noteSet'">merkinnät</xsl:when>
                    <xsl:when test="$label='objectType'">esine tyyppi</xsl:when>
                    <xsl:when test="$label='obverse'">etupuoli</xsl:when>
                    <xsl:when test="$label='obv_leg'">etupuolen kuvateksti?</xsl:when>
                    <xsl:when test="$label='obv_type'">etupuolen tyyppi</xsl:when>
                    <xsl:when test="$label='owner'">omistaja</xsl:when>
                    <xsl:when test="$label='physDesc'">fyysinen kuvaus</xsl:when>
                    <xsl:when test="$label='portrait'">muotokuva</xsl:when>
                    <xsl:when test="$label='previousColl'">aikaisempi kokoelma</xsl:when>
                    <xsl:when test="$label='private'">yksityinen</xsl:when>
                    <xsl:when test="$label='provenance'">alkuperä</xsl:when>
                    <xsl:when test="$label='public'">julkinen</xsl:when>
                    <xsl:when test="$label='publisher'">julkaisija</xsl:when>
                    <xsl:when test="$label='reference'">lähdeviittaus</xsl:when>
                    <xsl:when test="$label='refDesc'">lähdeviittaukset</xsl:when>
                    <xsl:when test="$label='region'">seutu</xsl:when>
                    <xsl:when test="$label='repository'">säilytyspaikka/sijoituspaikka</xsl:when>
                    <xsl:when test="$label='reverse'">kääntöpuoli</xsl:when>
                    <xsl:when test="$label='rev_leg'">kääntöpuolen kuvateksti</xsl:when>
                    <xsl:when test="$label='rev_type'">kääntöpuolen tyyppi</xsl:when>
                    <xsl:when test="$label='saleCatalog'">myyntiluettelo</xsl:when>
                    <xsl:when test="$label='saleItem'">myynnissä oleva esine</xsl:when>
                    <xsl:when test="$label='salePrice'">myyntihinta</xsl:when>
                    <xsl:when test="$label='shape'">muoto</xsl:when>
                    <xsl:when test="$label='state'">kunto? osavaltio?</xsl:when>
                    <xsl:when test="$label='subject'">aihe</xsl:when>
                    <xsl:when test="$label='subjectSet'">aiheet</xsl:when>
                    <xsl:when test="$label='symbol'">symboli</xsl:when>
                    <xsl:when test="$label='testmark'">testimerkki?</xsl:when>
                    <xsl:when test="$label='timestamp'">muutetun merkinnän päivämäärä</xsl:when>
                    <xsl:when test="$label='title'">otsikko/nimike/titteli</xsl:when>
                    <xsl:when test="$label='toDate'">vuoteen....asti.</xsl:when>
                    <xsl:when test="$label='typeDesc'">typologinen kuvaus</xsl:when>
                    <xsl:when test="$label='thickness'">paksuus</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">alalajin kuvaus</xsl:when>
                    <xsl:when test="$label='wear'">kuluminen/kuluma</xsl:when>
                    <xsl:when test="$label='weight'">paino</xsl:when>
                    <xsl:when test="$label='width'">leveys</xsl:when>
                    <xsl:when test="$label='year'">vuosi</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='da'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">taksigelse</xsl:when>
                    <xsl:when test="$label='acquisition'">erhvervelse</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">erhvervet fra</xsl:when>
                    <xsl:when test="$label='adminDesc'">administrativ historie</xsl:when>
                    <xsl:when test="$label='appraisal'">vurdering</xsl:when>
                    <xsl:when test="$label='appraiser'">vurderet af</xsl:when>
                    <xsl:when test="$label='auction'">auktion</xsl:when>
                    <xsl:when test="$label='authority'">autoritet</xsl:when>
                    <xsl:when test="$label='axis'">stempelstilling</xsl:when>
                    <xsl:when test="$label='century'">århundrede</xsl:when>
                    <xsl:when test="$label='chronList'">kronologisk liste</xsl:when>
                    <xsl:when test="$label='coinType'">mønttype</xsl:when>
                    <xsl:when test="$label='collection'">samling</xsl:when>
                    <xsl:when test="$label='color'">farve</xsl:when>
                    <xsl:when test="$label='completeness'">fuldstændighed</xsl:when>
                    <xsl:when test="$label='condition'">tilstand</xsl:when>
                    <xsl:when test="$label='conservationState'">bevaringstilstand</xsl:when>
                    <xsl:when test="$label='contents'">indeholder</xsl:when>
                    <xsl:when test="$label='coordinates'">koordinater</xsl:when>
                    <xsl:when test="$label='countermark'">kontramarkering</xsl:when>
                    <xsl:when test="$label='date'">datering</xsl:when>
                    <xsl:when test="$label='dateOnObject'">datering af genstand</xsl:when>
                    <xsl:when test="$label='dob'">datering af genstand</xsl:when>
                    <xsl:when test="$label='dateRange'">dateringsperiode</xsl:when>
                    <xsl:when test="$label='decade'">årti</xsl:when>
                    <xsl:when test="$label='degree'">grad</xsl:when>
                    <xsl:when test="$label='deity'">guddom</xsl:when>
                    <xsl:when test="$label='denomination'">nominal</xsl:when>
                    <xsl:when test="$label='department'">afdeling</xsl:when>
                    <xsl:when test="$label='deposit'">deponering</xsl:when>
                    <xsl:when test="$label='description'">beskrivelse</xsl:when>
                    <xsl:when test="$label='diameter'">diameter</xsl:when>
                    <xsl:when test="$label='discovery'">fund</xsl:when>
                    <xsl:when test="$label='disposition'">opbevaringssted</xsl:when>
                    <xsl:when test="$label='dynasty'">dynasti</xsl:when>
                    <xsl:when test="$label='edge'">kant</xsl:when>
                    <xsl:when test="$label='era'">periode</xsl:when>
                    <xsl:when test="$label='finder'">finder</xsl:when>
                    <xsl:when test="$label='findspot'">fundsted</xsl:when>
                    <xsl:when test="$label='fromDate'">fra dato</xsl:when>
                    <xsl:when test="$label='geographic'">geografisk</xsl:when>
                    <xsl:when test="$label='grade'">kvalitet</xsl:when>
                    <xsl:when test="$label='height'">højde</xsl:when>
                    <xsl:when test="$label='hoardDesc'">beskrivelse af skattefund</xsl:when>
                    <xsl:when test="$label='identifier'">identificeret af</xsl:when>
                    <xsl:when test="$label='issuer'">udgiver</xsl:when>
                    <xsl:when test="$label='landowner'">lodsejer</xsl:when>
                    <xsl:when test="$label='legend'">indskrift/omskrift</xsl:when>
                    <xsl:when test="$label='manufacture'">fremstilling</xsl:when>
                    <xsl:when test="$label='material'">materiale</xsl:when>
                    <xsl:when test="$label='measurementsSet'">mål</xsl:when>
                    <xsl:when test="$label='mint'">møntsted</xsl:when>
                    <xsl:when test="$label='note'">note</xsl:when>
                    <xsl:when test="$label='noteSet'">notater</xsl:when>
                    <xsl:when test="$label='objectType'">genstandstype</xsl:when>
                    <xsl:when test="$label='obverse'">forside</xsl:when>
                    <xsl:when test="$label='obv_leg'">forsideindskrift</xsl:when>
                    <xsl:when test="$label='obv_type'">forsidetype</xsl:when>
                    <xsl:when test="$label='owner'">ejer</xsl:when>
                    <xsl:when test="$label='physDesc'">fysisk beskrivelse</xsl:when>
                    <xsl:when test="$label='portrait'">portræt</xsl:when>
                    <xsl:when test="$label='previousColl'">tidligere samling</xsl:when>
                    <xsl:when test="$label='private'">privat</xsl:when>
                    <xsl:when test="$label='provenance'">proveniens</xsl:when>
                    <xsl:when test="$label='public'">offentlig</xsl:when>
                    <xsl:when test="$label='publisher'">udgiver</xsl:when>
                    <xsl:when test="$label='reference'">henvisning</xsl:when>
                    <xsl:when test="$label='refDesc'">henvisninger</xsl:when>
                    <xsl:when test="$label='region'">region</xsl:when>
                    <xsl:when test="$label='repository'">opbevaringssted</xsl:when>
                    <xsl:when test="$label='reverse'">bagside</xsl:when>
                    <xsl:when test="$label='rev_leg'">bagsideindskrift</xsl:when>
                    <xsl:when test="$label='rev_type'">bagsidetype</xsl:when>
                    <xsl:when test="$label='saleCatalog'">salgskatalog</xsl:when>
                    <xsl:when test="$label='saleItem'">lot nummer</xsl:when>
                    <xsl:when test="$label='salePrice'">salgspris</xsl:when>
                    <xsl:when test="$label='shape'">form</xsl:when>
                    <xsl:when test="$label='state'">tilstand</xsl:when>
                    <xsl:when test="$label='subject'">emne</xsl:when>
                    <xsl:when test="$label='subjectSet'">emner</xsl:when>
                    <xsl:when test="$label='symbol'">symbol</xsl:when>
                    <xsl:when test="$label='testmark'">testmærke</xsl:when>
                    <xsl:when test="$label='timestamp'">ændringsdato</xsl:when>
                    <xsl:when test="$label='title'">titel</xsl:when>
                    <xsl:when test="$label='toDate'">til dato</xsl:when>
                    <xsl:when test="$label='type'">type</xsl:when>
                    <xsl:when test="$label='typeDesc'">typebeskrivelse</xsl:when>
                    <xsl:when test="$label='thickness'">tykkelse</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">beskrivelse af undertype</xsl:when>
                    <xsl:when test="$label='wear'">slid</xsl:when>
                    <xsl:when test="$label='weight'">vægt</xsl:when>
                    <xsl:when test="$label='width'">bredde</xsl:when>
                    <xsl:when test="$label='year'">år</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='hu'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Visszaigazolás</xsl:when>
                    <xsl:when test="$label='acquisition'">Vásárlás</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Tőle vásárolt</xsl:when>
                    <xsl:when test="$label='adminDesc'">Közigazgatási története</xsl:when>
                    <xsl:when test="$label='appraisal'">Értékelés</xsl:when>
                    <xsl:when test="$label='appraiser'">Becsüs</xsl:when>
                    <xsl:when test="$label='auction'">Árverés</xsl:when>
                    <xsl:when test="$label='authority'">Hatóság</xsl:when>
                    <xsl:when test="$label='axis'">Tengely</xsl:when>
                    <xsl:when test="$label='century'">Század</xsl:when>
                    <xsl:when test="$label='chronList'">Időrendi jegyzék</xsl:when>
                    <xsl:when test="$label='chronItem'">Időrendi tétel</xsl:when>
                    <xsl:when test="$label='coinType'">Érem típusa</xsl:when>
                    <xsl:when test="$label='collection'">Gyűjtemény</xsl:when>
                    <xsl:when test="$label='color'">Szín</xsl:when>
                    <xsl:when test="$label='completeness'">Teljesség</xsl:when>
                    <xsl:when test="$label='condition'">Állapot</xsl:when>
                    <xsl:when test="$label='conservationState'">Megőrzési állag</xsl:when>
                    <xsl:when test="$label='contents'">Tartalma</xsl:when>
                    <xsl:when test="$label='coordinates'">Koordináták</xsl:when>
                    <xsl:when test="$label='countermark'">Ellenjegy</xsl:when>
                    <xsl:when test="$label='date'">Dátum</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Dátum a tárgyon</xsl:when>
                    <xsl:when test="$label='dob'">Dátum a tárgyon</xsl:when>
                    <xsl:when test="$label='dateRange'">Időintervallum</xsl:when>
                    <xsl:when test="$label='decade'">Évtized</xsl:when>
                    <xsl:when test="$label='degree'">Fokozat</xsl:when>
                    <xsl:when test="$label='deity'">Istenség</xsl:when>
                    <xsl:when test="$label='denomination'">Címplet</xsl:when>
                    <xsl:when test="$label='department'">Részleg</xsl:when>
                    <xsl:when test="$label='deposit'">Letét</xsl:when>
                    <xsl:when test="$label='description'">Leírás</xsl:when>
                    <xsl:when test="$label='diameter'">Átmérő</xsl:when>
                    <xsl:when test="$label='discovery'">Felfedezés</xsl:when>
                    <xsl:when test="$label='disposition'">Elhelyezés</xsl:when>
                    <xsl:when test="$label='dynasty'">Dinasztia</xsl:when>
                    <xsl:when test="$label='edge'">Él</xsl:when>
                    <xsl:when test="$label='era'">Korszak</xsl:when>
                    <xsl:when test="$label='finder'">Kereső</xsl:when>
                    <xsl:when test="$label='findspot'">Lelőhely</xsl:when>
                    <xsl:when test="$label='fromDate'">Dátumtól</xsl:when>
                    <xsl:when test="$label='geographic'">Földrajzi</xsl:when>
                    <xsl:when test="$label='grade'">Fokozat</xsl:when>
                    <xsl:when test="$label='height'">Magasság</xsl:when>
                    <xsl:when test="$label='hoardDesc'">kincslelet Leírás</xsl:when>
                    <xsl:when test="$label='identifier'">Azonosító</xsl:when>
                    <xsl:when test="$label='issuer'">Kibocsátó</xsl:when>
                    <xsl:when test="$label='landowner'">Tulajdonos</xsl:when>
                    <xsl:when test="$label='legend'">Felirat</xsl:when>
                    <xsl:when test="$label='manufacture'">Készítési mód</xsl:when>
                    <xsl:when test="$label='material'">Anyag</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Méretek</xsl:when>
                    <xsl:when test="$label='mint'">Verde</xsl:when>
                    <xsl:when test="$label='note'">Jegyzet</xsl:when>
                    <xsl:when test="$label='noteSet'">Megjegyzések</xsl:when>
                    <xsl:when test="$label='objectType'">Tárgy típus</xsl:when>
                    <xsl:when test="$label='obverse'">Előlap</xsl:when>
                    <xsl:when test="$label='obv_leg'">Előlap felirat</xsl:when>
                    <xsl:when test="$label='obv_type'">Előlap típusa</xsl:when>
                    <xsl:when test="$label='owner'">Tulajdonos</xsl:when>
                    <xsl:when test="$label='physDesc'">Külső leírás</xsl:when>
                    <xsl:when test="$label='portrait'">Portré</xsl:when>
                    <xsl:when test="$label='previousColl'">Előző Gyűjtemény</xsl:when>
                    <xsl:when test="$label='private'">Magán</xsl:when>
                    <xsl:when test="$label='provenance'">Eredet</xsl:when>
                    <xsl:when test="$label='public'">Nyilvános</xsl:when>
                    <xsl:when test="$label='publisher'">Kiadó</xsl:when>
                    <xsl:when test="$label='reference'">Referencia</xsl:when>
                    <xsl:when test="$label='refDesc'">Referenciák</xsl:when>
                    <xsl:when test="$label='region'">Vidék</xsl:when>
                    <xsl:when test="$label='repository'">raktár</xsl:when>
                    <xsl:when test="$label='reverse'">Hátlap</xsl:when>
                    <xsl:when test="$label='rev_leg'">Hátlapi felirat</xsl:when>
                    <xsl:when test="$label='rev_type'">Hátlap típusa</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Aukció katalógus</xsl:when>
                    <xsl:when test="$label='saleItem'">Eladási szám</xsl:when>
                    <xsl:when test="$label='salePrice'">Eladási ár</xsl:when>
                    <xsl:when test="$label='shape'">Forma</xsl:when>
                    <xsl:when test="$label='state'">Állapot</xsl:when>
                    <xsl:when test="$label='subject'">Téma</xsl:when>
                    <xsl:when test="$label='subjectSet'">Témák</xsl:when>
                    <xsl:when test="$label='symbol'">Szimbólum</xsl:when>
                    <xsl:when test="$label='testmark'">Ellenjegy</xsl:when>
                    <xsl:when test="$label='timestamp'">Bejegyzési dátum modosítása</xsl:when>
                    <xsl:when test="$label='title'">Címlet</xsl:when>
                    <xsl:when test="$label='toDate'">Év végéig</xsl:when>
                    <xsl:when test="$label='type'">típus</xsl:when>
                    <xsl:when test="$label='typeDesc'">tipológiai leírás</xsl:when>
                    <xsl:when test="$label='thickness'">Vastagság</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Altípus leírás</xsl:when>
                    <xsl:when test="$label='wear'">Fenntartási állag</xsl:when>
                    <xsl:when test="$label='weight'">Súly</xsl:when>
                    <xsl:when test="$label='width'">Szélesség</xsl:when>
                    <xsl:when test="$label='year'">Év</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='el'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Ευχαριστίες</xsl:when>
                    <xsl:when test="$label='acquisition'">Πρόσκτημα</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Πρόσκτημα από</xsl:when>
                    <xsl:when test="$label='adminDesc'">Ιστορία διαχείρισης</xsl:when>
                    <xsl:when test="$label='appraisal'">Αξιολόγηση</xsl:when>
                    <xsl:when test="$label='appraiser'">Αξιολογητής</xsl:when>
                    <xsl:when test="$label='auction'">Δημοπρασία</xsl:when>
                    <xsl:when test="$label='authority'">Εκδότρια αρχή</xsl:when>
                    <xsl:when test="$label='axis'">Άξονας</xsl:when>
                    <xsl:when test="$label='century'">Αιώνας</xsl:when>
                    <xsl:when test="$label='chronList'">Χρονολογικός κατάλογος</xsl:when>
                    <xsl:when test="$label='chronItem'">Χρονολογικό στοιχείο</xsl:when>
                    <xsl:when test="$label='coinType'">Νομισματικός τύπος</xsl:when>
                    <xsl:when test="$label='collection'">Συλλογή</xsl:when>
                    <xsl:when test="$label='color'">Χρώμα</xsl:when>
                    <xsl:when test="$label='completeness'">Πληρότητα</xsl:when>
                    <xsl:when test="$label='condition'">Διατήρηση</xsl:when>
                    <xsl:when test="$label='conservationState'">Κατάσταση συντήρησης</xsl:when>
                    <xsl:when test="$label='contents'">Περιεχόμενα</xsl:when>
                    <xsl:when test="$label='coordinates'">Συντεταγμένες</xsl:when>
                    <xsl:when test="$label='countermark'">Επισήμανση</xsl:when>
                    <xsl:when test="$label='date'">Χρονολόγηση</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Χρονολογία επί του αντικειμένου</xsl:when>
                    <xsl:when test="$label='dob'">Χρονολογία επί του αντικειμένου</xsl:when>
                    <xsl:when test="$label='dateRange'">Χρονική περίοδος</xsl:when>
                    <xsl:when test="$label='decade'">Δεκαετία</xsl:when>
                    <xsl:when test="$label='degree'">Βαθμός</xsl:when>
                    <xsl:when test="$label='deity'">Θεότητα</xsl:when>
                    <xsl:when test="$label='denomination'">Νομισματική αξία</xsl:when>
                    <xsl:when test="$label='department'">Τμήμα</xsl:when>
                    <xsl:when test="$label='deposit'">Αποθέτης</xsl:when>
                    <xsl:when test="$label='description'">Περιγραφή</xsl:when>
                    <xsl:when test="$label='diameter'">Διάμετρος</xsl:when>
                    <xsl:when test="$label='discovery'">Ανεύρεση</xsl:when>
                    <xsl:when test="$label='disposition'">Διάταξη</xsl:when>
                    <xsl:when test="$label='dynasty'">Δυναστεία</xsl:when>
                    <xsl:when test="$label='edge'">Περιφέρεια</xsl:when>
                    <xsl:when test="$label='era'">Εποχή</xsl:when>
                    <xsl:when test="$label='finder'">Ευρετής</xsl:when>
                    <xsl:when test="$label='findspot'">Σημείο εύρεσης</xsl:when>
                    <xsl:when test="$label='fromDate'">Μετά από το έτος</xsl:when>
                    <xsl:when test="$label='geographic'">Γεωγραφική κατάταξη</xsl:when>
                    <xsl:when test="$label='grade'">Διαβάθμιση</xsl:when>
                    <xsl:when test="$label='height'">Ύψος</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Περιγραφή «θησαυρού»</xsl:when>
                    <xsl:when test="$label='identifier'">Υπεύθυνος ταύτισης</xsl:when>
                    <xsl:when test="$label='issuer'">Υπεύθυνος έκδοσης</xsl:when>
                    <xsl:when test="$label='landowner'">Ιδιοκτήτης χώρου ανεύρεσης</xsl:when>
                    <xsl:when test="$label='legend'">Επιγραφή</xsl:when>
                    <xsl:when test="$label='manufacture'">Τρόπος κατασκευής</xsl:when>
                    <xsl:when test="$label='material'">Υλικό</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Διαστάσεις</xsl:when>
                    <xsl:when test="$label='mint'">Νομισματοκοπείο</xsl:when>
                    <xsl:when test="$label='note'">Σημείωση</xsl:when>
                    <xsl:when test="$label='noteSet'">Σημειώσεις</xsl:when>
                    <xsl:when test="$label='objectType'">Είδος αντικειμένου</xsl:when>
                    <xsl:when test="$label='obverse'">Εμπροσθότυπος</xsl:when>
                    <xsl:when test="$label='obv_leg'">Επιγραφή εμπροσθοτύπου</xsl:when>
                    <xsl:when test="$label='obv_type'">Παράσταση εμπροσθοτύπου</xsl:when>
                    <xsl:when test="$label='owner'">Ιδιοκτήτης</xsl:when>
                    <xsl:when test="$label='physDesc'">Φυσική περιγραφή</xsl:when>
                    <xsl:when test="$label='portrait'">Πορτραίτο</xsl:when>
                    <xsl:when test="$label='previousColl'">Προηγούμενη συλλογή</xsl:when>
                    <xsl:when test="$label='private'">Ιδιωτικό</xsl:when>
                    <xsl:when test="$label='provenance'">Προέλευση</xsl:when>
                    <xsl:when test="$label='public'">Δημόσιο</xsl:when>
                    <xsl:when test="$label='publisher'">Εκδότης</xsl:when>
                    <xsl:when test="$label='reference'">Παραπομπή</xsl:when>
                    <xsl:when test="$label='refDesc'">Παραπομπές</xsl:when>
                    <xsl:when test="$label='region'">Περιοχή</xsl:when>
                    <xsl:when test="$label='repository'">Χώρος φύλαξης</xsl:when>
                    <xsl:when test="$label='reverse'">Οπισθότυπος</xsl:when>
                    <xsl:when test="$label='rev_leg'">Επιγραφή οπισθοτύπου</xsl:when>
                    <xsl:when test="$label='rev_type'">Παράσταση οπισθοτύπου</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Κατάλογος δημοπρασίας</xsl:when>
                    <xsl:when test="$label='saleItem'">Αριθμός λαχνού δημοπρασίας</xsl:when>
                    <xsl:when test="$label='salePrice'">Τιμή δημοπράτησης</xsl:when>
                    <xsl:when test="$label='shape'">Σχήμα</xsl:when>
                    <xsl:when test="$label='state'">Κατάσταση</xsl:when>
                    <xsl:when test="$label='subject'">Θέμα</xsl:when>
                    <xsl:when test="$label='subjectSet'">Θέματα</xsl:when>
                    <xsl:when test="$label='symbol'">Δηλωτικό</xsl:when>
                    <xsl:when test="$label='testmark'">Δοκιμαστική χάραξη</xsl:when>
                    <xsl:when test="$label='timestamp'">Ημερομηνία τροποποίησης εγγραφής</xsl:when>
                    <xsl:when test="$label='title'">Τίτλος</xsl:when>
                    <xsl:when test="$label='toDate'">Μέχρι το έτος</xsl:when>
                    <xsl:when test="$label='type'">Τύπος</xsl:when>
                    <xsl:when test="$label='typeDesc'">Τυπολογική περιγραφή</xsl:when>
                    <xsl:when test="$label='thickness'">Πάχος</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Περιγραφή υποκείμενου τύπου</xsl:when>
                    <xsl:when test="$label='wear'">Βαθμός φθοράς</xsl:when>
                    <xsl:when test="$label='weight'">Βάρος</xsl:when>
                    <xsl:when test="$label='width'">Πλάτος</xsl:when>
                    <xsl:when test="$label='year'">Έτος</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='es'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Agradecimiento</xsl:when>
                    <xsl:when test="$label='acquisition'">Adquisición</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Adquirido a</xsl:when>
                    <xsl:when test="$label='adminDesc'">Historia administrativa</xsl:when>
                    <xsl:when test="$label='appraisal'">Estimación</xsl:when>
                    <xsl:when test="$label='appraiser'">Perito</xsl:when>
                    <xsl:when test="$label='auction'">Subasta</xsl:when>
                    <xsl:when test="$label='authority'">Autoridad emisora</xsl:when>
                    <xsl:when test="$label='axis'">Posición de cuño</xsl:when>
                    <xsl:when test="$label='century'">Siglo</xsl:when>
                    <xsl:when test="$label='chronList'">Lista cronológica</xsl:when>
                    <xsl:when test="$label='chronItem'">Cronología del objeto</xsl:when>
                    <xsl:when test="$label='coinType'">Tipo monetal</xsl:when>
                    <xsl:when test="$label='collection'">Colección</xsl:when>
                    <xsl:when test="$label='color'">Color</xsl:when>
                    <xsl:when test="$label='completeness'">Integridad</xsl:when>
                    <xsl:when test="$label='condition'">Condición</xsl:when>
                    <xsl:when test="$label='conservationState'">Estado de conservación</xsl:when>
                    <xsl:when test="$label='contents'">Sumario</xsl:when>
                    <xsl:when test="$label='coordinates'">Coordenada</xsl:when>
                    <xsl:when test="$label='countermark'">Contramarca</xsl:when>
                    <xsl:when test="$label='date'">Fecha</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Fecha del objeto</xsl:when>
                    <xsl:when test="$label='dob'">Fecha del objeto</xsl:when>
                    <xsl:when test="$label='dateRange'">Período cronológico</xsl:when>
                    <xsl:when test="$label='decade'">Década</xsl:when>
                    <xsl:when test="$label='degree'">Grado</xsl:when>
                    <xsl:when test="$label='deity'">Divinidad</xsl:when>
                    <xsl:when test="$label='denomination'">Denominación</xsl:when>
                    <xsl:when test="$label='department'">Departamento</xsl:when>
                    <xsl:when test="$label='deposit'">Depósito</xsl:when>
                    <xsl:when test="$label='description'">Descripción</xsl:when>
                    <xsl:when test="$label='diameter'">Diámetro</xsl:when>
                    <xsl:when test="$label='discovery'">Descubierto</xsl:when>
                    <xsl:when test="$label='disposition'">Disposición</xsl:when>
                    <xsl:when test="$label='dynasty'">Dinastía</xsl:when>
                    <xsl:when test="$label='edge'">Borde</xsl:when>
                    <xsl:when test="$label='era'">Era</xsl:when>
                    <xsl:when test="$label='finder'">Descubridor</xsl:when>
                    <xsl:when test="$label='findspot'">Hallazgo</xsl:when>
                    <xsl:when test="$label='fromDate'">A partir del año</xsl:when>
                    <xsl:when test="$label='geographic'">Geográfico</xsl:when>
                    <xsl:when test="$label='grade'">Grado</xsl:when>
                    <xsl:when test="$label='height'">Altura</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Descripción del tesoro</xsl:when>
                    <xsl:when test="$label='identifier'">Identificador</xsl:when>
                    <xsl:when test="$label='issuer'">Emisor</xsl:when>
                    <xsl:when test="$label='landowner'">Propietario del terreno</xsl:when>
                    <xsl:when test="$label='legend'">Leyenda</xsl:when>
                    <xsl:when test="$label='manufacture'">Manufactura</xsl:when>
                    <xsl:when test="$label='material'">Material</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Dimensiones</xsl:when>
                    <xsl:when test="$label='mint'">Ceca</xsl:when>
                    <xsl:when test="$label='note'">Nota</xsl:when>
                    <xsl:when test="$label='noteSet'">Notas</xsl:when>
                    <xsl:when test="$label='objectType'">Tipo de objeto</xsl:when>
                    <xsl:when test="$label='obverse'">Anverso</xsl:when>
                    <xsl:when test="$label='obv_leg'">Leyenda de anverso</xsl:when>
                    <xsl:when test="$label='obv_type'">Tipo de anverso</xsl:when>
                    <xsl:when test="$label='owner'">Propietario</xsl:when>
                    <xsl:when test="$label='physDesc'">Descripción física</xsl:when>
                    <xsl:when test="$label='portrait'">Retrato</xsl:when>
                    <xsl:when test="$label='previousColl'">Colección anterior</xsl:when>
                    <xsl:when test="$label='private'">Privada</xsl:when>
                    <xsl:when test="$label='provenance'">Procedencia</xsl:when>
                    <xsl:when test="$label='public'">Público</xsl:when>
                    <xsl:when test="$label='publisher'">Editor</xsl:when>
                    <xsl:when test="$label='reference'">Referencia</xsl:when>
                    <xsl:when test="$label='refDesc'">Referencia descriptiva</xsl:when>
                    <xsl:when test="$label='region'">Región</xsl:when>
                    <xsl:when test="$label='repository'">Repositorio</xsl:when>
                    <xsl:when test="$label='reverse'">Reverso</xsl:when>
                    <xsl:when test="$label='rev_leg'">Leyenda de reverso</xsl:when>
                    <xsl:when test="$label='rev_type'">Tipo de reverso</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Catálogo de subasta</xsl:when>
                    <xsl:when test="$label='saleItem'">Número de lote</xsl:when>
                    <xsl:when test="$label='salePrice'">Precio de venta</xsl:when>
                    <xsl:when test="$label='shape'">Forma</xsl:when>
                    <xsl:when test="$label='state'">Estado</xsl:when>
                    <xsl:when test="$label='subject'">Sujeto</xsl:when>
                    <xsl:when test="$label='subjectSet'">Sujetos</xsl:when>
                    <xsl:when test="$label='symbol'">Símbolo</xsl:when>
                    <xsl:when test="$label='testmark'">Marca de comprobación</xsl:when>
                    <xsl:when test="$label='timestamp'">Fecha de modificación del registro</xsl:when>
                    <xsl:when test="$label='title'">Título</xsl:when>
                    <xsl:when test="$label='toDate'">Hasta el año</xsl:when>
                    <xsl:when test="$label='type'">Tipo</xsl:when>
                    <xsl:when test="$label='typeDesc'">Descripción del tipo</xsl:when>
                    <xsl:when test="$label='thickness'">Grosor</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Descripción del soporte</xsl:when>
                    <xsl:when test="$label='wear'">Desgaste</xsl:when>
                    <xsl:when test="$label='weight'">Peso</xsl:when>
                    <xsl:when test="$label='width'">Ancho</xsl:when>
                    <xsl:when test="$label='year'">Año</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='bg'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Потвърждение</xsl:when>
                    <xsl:when test="$label='acquisition'">Придобиване</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Придобито/а от</xsl:when>
                    <xsl:when test="$label='adminDesc'">Административна история</xsl:when>
                    <xsl:when test="$label='appraisal'">Оценяване</xsl:when>
                    <xsl:when test="$label='appraiser'">Оценител</xsl:when>
                    <xsl:when test="$label='auction'">Аукцион</xsl:when>
                    <xsl:when test="$label='authority'">Авторитет</xsl:when>
                    <xsl:when test="$label='axis'">Разположение на печата</xsl:when>
                    <xsl:when test="$label='century'">Век</xsl:when>
                    <xsl:when test="$label='chronList'">Хронологически списък</xsl:when>
                    <xsl:when test="$label='chronItem'">Хронологическа точка</xsl:when>
                    <xsl:when test="$label='coinType'">Монетен тип</xsl:when>
                    <xsl:when test="$label='collection'">Колекция</xsl:when>
                    <xsl:when test="$label='color'">Цвят</xsl:when>
                    <xsl:when test="$label='completeness'">Пълнота / Цялост</xsl:when>
                    <xsl:when test="$label='condition'">Състояние</xsl:when>
                    <xsl:when test="$label='conservationState'">Съхраненост</xsl:when>
                    <xsl:when test="$label='contents'">Съдържание</xsl:when>
                    <xsl:when test="$label='coordinates'">Координати</xsl:when>
                    <xsl:when test="$label='countermark'">Контрамарка</xsl:when>
                    <xsl:when test="$label='date'">Дата</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Дата на обекта</xsl:when>
                    <xsl:when test="$label='dob'">Дата на обекта</xsl:when>
                    <xsl:when test="$label='dateRange'">Период на датиране</xsl:when>
                    <xsl:when test="$label='decade'">Десетилетие</xsl:when>
                    <xsl:when test="$label='degree'">Степен</xsl:when>
                    <xsl:when test="$label='deity'">Божество</xsl:when>
                    <xsl:when test="$label='denomination'">Номинал</xsl:when>
                    <xsl:when test="$label='department'">Отдел</xsl:when>
                    <xsl:when test="$label='deposit'">Хранилище</xsl:when>
                    <xsl:when test="$label='description'">Описание</xsl:when>
                    <xsl:when test="$label='diameter'">Диаметър</xsl:when>
                    <xsl:when test="$label='discovery'">Находище</xsl:when>
                    <xsl:when test="$label='disposition'">Разположение</xsl:when>
                    <xsl:when test="$label='dynasty'">Династия</xsl:when>
                    <xsl:when test="$label='edge'">Външен ръб на монетата</xsl:when>
                    <xsl:when test="$label='era'">Епоха</xsl:when>
                    <xsl:when test="$label='finder'">Откривател</xsl:when>
                    <xsl:when test="$label='findspot'">Местонаходище</xsl:when>
                    <xsl:when test="$label='fromDate'">Начална дата</xsl:when>
                    <xsl:when test="$label='geographic'">географски</xsl:when>
                    <xsl:when test="$label='grade'">Градус</xsl:when>
                    <xsl:when test="$label='height'">Височина</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Описание на съкровището</xsl:when>
                    <xsl:when test="$label='identifier'">Идентифицирано/ а от</xsl:when>
                    <xsl:when test="$label='issuer'">Издател</xsl:when>
                    <xsl:when test="$label='landowner'">Собственик на земята</xsl:when>
                    <xsl:when test="$label='legend'">Легенда</xsl:when>
                    <xsl:when test="$label='manufacture'">Производство</xsl:when>
                    <xsl:when test="$label='material'">Материал</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Размери</xsl:when>
                    <xsl:when test="$label='mint'">Монетарница</xsl:when>
                    <xsl:when test="$label='note'">Бележка</xsl:when>
                    <xsl:when test="$label='noteSet'">Бележки</xsl:when>
                    <xsl:when test="$label='objectType'">Тип на обекта</xsl:when>
                    <xsl:when test="$label='obverse'">Аверс</xsl:when>
                    <xsl:when test="$label='obv_leg'">Аверсна легенда</xsl:when>
                    <xsl:when test="$label='obv_type'">Аверсен тип</xsl:when>
                    <xsl:when test="$label='owner'">Собственик</xsl:when>
                    <xsl:when test="$label='physDesc'">Физическо описание</xsl:when>
                    <xsl:when test="$label='portrait'">Портрет</xsl:when>
                    <xsl:when test="$label='previousColl'">Предишна колекция</xsl:when>
                    <xsl:when test="$label='private'">частен</xsl:when>
                    <xsl:when test="$label='provenance'">Произход</xsl:when>
                    <xsl:when test="$label='public'">публичен</xsl:when>
                    <xsl:when test="$label='publisher'">Издателство</xsl:when>
                    <xsl:when test="$label='reference'">Литература</xsl:when>
                    <xsl:when test="$label='refDesc'">Литература</xsl:when>
                    <xsl:when test="$label='region'">Регион</xsl:when>
                    <xsl:when test="$label='repository'">Депозиториум</xsl:when>
                    <xsl:when test="$label='reverse'">Реверс</xsl:when>
                    <xsl:when test="$label='rev_leg'">Реверсна легенда</xsl:when>
                    <xsl:when test="$label='rev_type'">Реверсен тип</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Аукционен каталог</xsl:when>
                    <xsl:when test="$label='saleItem'">Аукционен обект</xsl:when>
                    <xsl:when test="$label='salePrice'">Продажна цена</xsl:when>
                    <xsl:when test="$label='shape'">Форма</xsl:when>
                    <xsl:when test="$label='state'">Състояние</xsl:when>
                    <xsl:when test="$label='subject'">Субект</xsl:when>
                    <xsl:when test="$label='subjectSet'">Субекти</xsl:when>
                    <xsl:when test="$label='symbol'">Символ</xsl:when>
                    <xsl:when test="$label='testmark'">Проба</xsl:when>
                    <xsl:when test="$label='timestamp'">Дата на модифициране</xsl:when>
                    <xsl:when test="$label='title'">Заглавие</xsl:when>
                    <xsl:when test="$label='toDate'">До дата</xsl:when>
                    <xsl:when test="$label='type'">Тип</xsl:when>
                    <xsl:when test="$label='typeDesc'">Типологичне описание</xsl:when>
                    <xsl:when test="$label='thickness'">Дебелина</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Описание на подтипа</xsl:when>
                    <xsl:when test="$label='wear'">Износеност</xsl:when>
                    <xsl:when test="$label='weight'">Тегло</xsl:when>
                    <xsl:when test="$label='width'">Ширина</xsl:when>
                    <xsl:when test="$label='year'">Година</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='he'">
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">הכרת תודה</xsl:when>
                    <xsl:when test="$label='acquisition'">רכישה</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">נרכש מ-</xsl:when>
                    <xsl:when test="$label='adminDesc'">היסטוריה מנהלית</xsl:when>
                    <xsl:when test="$label='appraisal'">הערכת מחיר</xsl:when>
                    <xsl:when test="$label='appraiser'">שמאי</xsl:when>
                    <xsl:when test="$label='auction'">מכירה פומבית</xsl:when>
                    <xsl:when test="$label='authority'">סמכות</xsl:when>
                    <xsl:when test="$label='axis'">ציר</xsl:when>
                    <xsl:when test="$label='century'">מאה</xsl:when>
                    <xsl:when test="$label='chronList'">רשימה כרונולוגית</xsl:when>
                    <xsl:when test="$label='chronItem'">פריט כרונולוגי</xsl:when>
                    <xsl:when test="$label='coinType'">סוג מטבע</xsl:when>
                    <xsl:when test="$label='collection'">אוסף</xsl:when>
                    <xsl:when test="$label='color'">צבע</xsl:when>
                    <xsl:when test="$label='completeness'">שלמות</xsl:when>
                    <xsl:when test="$label='condition'">מצב</xsl:when>
                    <xsl:when test="$label='conservationState'">מצב שימור</xsl:when>
                    <xsl:when test="$label='contents'">תכנים</xsl:when>
                    <xsl:when test="$label='coordinates'">קואורדינטות</xsl:when>
                    <xsl:when test="$label='countermark'">טביעת הישבון</xsl:when>
                    <xsl:when test="$label='date'">תאריך</xsl:when>
                    <xsl:when test="$label='dateOnObject'">תאריך ע&quot;ג הפריט</xsl:when>
                    <xsl:when test="$label='dob'">תאריך לידה</xsl:when>
                    <xsl:when test="$label='dateRange'">טווח תאריכים</xsl:when>
                    <xsl:when test="$label='decade'">עשור</xsl:when>
                    <xsl:when test="$label='degree'">מעלה</xsl:when>
                    <xsl:when test="$label='deity'">אליל</xsl:when>
                    <xsl:when test="$label='denomination'">עריך</xsl:when>
                    <xsl:when test="$label='department'">מחלקה</xsl:when>
                    <xsl:when test="$label='deposit'">משקע</xsl:when>
                    <xsl:when test="$label='description'">תיאור</xsl:when>
                    <xsl:when test="$label='diameter'">קוטר</xsl:when>
                    <xsl:when test="$label='discovery'">גילוי</xsl:when>
                    <xsl:when test="$label='dynasty'">שושלת</xsl:when>
                    <xsl:when test="$label='edge'">קצה</xsl:when>
                    <xsl:when test="$label='era'">תקופה</xsl:when>
                    <xsl:when test="$label='finder'">מגלה</xsl:when>
                    <xsl:when test="$label='findspot'">מקום הגילוי</xsl:when>
                    <xsl:when test="$label='fromDate'">מתאריך</xsl:when>
                    <xsl:when test="$label='geographic'">גיאוגרפי</xsl:when>
                    <xsl:when test="$label='grade'">ציון איכות</xsl:when>
                    <xsl:when test="$label='height'">גובה</xsl:when>
                    <xsl:when test="$label='hoardDesc'">תיאור המטמון</xsl:when>
                    <xsl:when test="$label='identifier'">מזהה</xsl:when>
                    <xsl:when test="$label='issuer'">מנפיק</xsl:when>
                    <xsl:when test="$label='landowner'">גבעלי הקרקע</xsl:when>
                    <xsl:when test="$label='legend'">כתובת</xsl:when>
                    <xsl:when test="$label='manufacture'">ייצור</xsl:when>
                    <xsl:when test="$label='material'">חומר</xsl:when>
                    <xsl:when test="$label='measurementsSet'">מידות</xsl:when>
                    <xsl:when test="$label='mint'">מיטבעה</xsl:when>
                    <xsl:when test="$label='note'">הערה</xsl:when>
                    <xsl:when test="$label='noteSet'">הערות</xsl:when>
                    <xsl:when test="$label='objectType'">סוג הפריט</xsl:when>
                    <xsl:when test="$label='obverse'">פני המטבע</xsl:when>
                    <xsl:when test="$label='obv_leg'">כתובת פני המטבע</xsl:when>
                    <xsl:when test="$label='obv_type'">סוג פני המטבע</xsl:when>
                    <xsl:when test="$label='owner'">בעלים</xsl:when>
                    <xsl:when test="$label='physDesc'">תיאור פיזי</xsl:when>
                    <xsl:when test="$label='portrait'">דיוקן</xsl:when>
                    <xsl:when test="$label='previousColl'">אוסף קודם</xsl:when>
                    <xsl:when test="$label='private'">פרטי</xsl:when>
                    <xsl:when test="$label='provenance'">פרטי מוצא</xsl:when>
                    <xsl:when test="$label='public'">ציבורי</xsl:when>
                    <xsl:when test="$label='publisher'">מוציא לאור</xsl:when>
                    <xsl:when test="$label='reference'">סימוכין</xsl:when>
                    <xsl:when test="$label='refDesc'">הפנייות</xsl:when>
                    <xsl:when test="$label='region'">אזור</xsl:when>
                    <xsl:when test="$label='repository'">מקום אחסנה</xsl:when>
                    <xsl:when test="$label='reverse'">גב המטבע</xsl:when>
                    <xsl:when test="$label='rev_leg'">כתובת גב המטבע</xsl:when>
                    <xsl:when test="$label='rev_type'">סוג גב המטבע</xsl:when>
                    <xsl:when test="$label='saleCatalog'">קטלוג מכירה</xsl:when>
                    <xsl:when test="$label='saleItem'">פריט מכירה</xsl:when>
                    <xsl:when test="$label='salePrice'">מחיר מכירה</xsl:when>
                    <xsl:when test="$label='shape'">צורה</xsl:when>
                    <xsl:when test="$label='state'">מצב</xsl:when>
                    <xsl:when test="$label='subject'">נושא</xsl:when>
                    <xsl:when test="$label='subjectSet'">נושאים</xsl:when>
                    <xsl:when test="$label='symbol'">סמל</xsl:when>
                    <xsl:when test="$label='testmark'">טביעת נסיון</xsl:when>
                    <xsl:when test="$label='timestamp'">תאריך עדכון</xsl:when>
                    <xsl:when test="$label='title'">כותרת</xsl:when>
                    <xsl:when test="$label='toDate'">עד תאריך</xsl:when>
                    <xsl:when test="$label='type'">טיפוס</xsl:when>
                    <xsl:when test="$label='typeDesc'">תיאור הטיפוס</xsl:when>
                    <xsl:when test="$label='thickness'">עובי</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">תיאור סוג התחתון </xsl:when>
                    <xsl:when test="$label='wear'">שחיקה</xsl:when>
                    <xsl:when test="$label='weight'">משקל</xsl:when>
                    <xsl:when test="$label='width'">רוחב</xsl:when>
                    <xsl:when test="$label='year'">שנה</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:regularize_node($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$label='acknowledgment'">Acknowledgment</xsl:when>
                    <xsl:when test="$label='acquisition'">Acquisition</xsl:when>
                    <xsl:when test="$label='acquiredFrom'">Acquired From</xsl:when>
                    <xsl:when test="$label='adminDesc'">Administrative History</xsl:when>
                    <xsl:when test="$label='appraisal'">Appraisal</xsl:when>
                    <xsl:when test="$label='appraiser'">Appraiser</xsl:when>
                    <xsl:when test="$label='auction'">Auction</xsl:when>
                    <xsl:when test="$label='authority'">Authority</xsl:when>
                    <xsl:when test="$label='authorizingEntity'">Political/Dynastic Entity</xsl:when>
                    <xsl:when test="$label='axis'">Axis</xsl:when>
                    <xsl:when test="$label='century'">Century</xsl:when>
                    <xsl:when test="$label='chemicalAnalysis'">Chemical Analysis</xsl:when>
                    <xsl:when test="$label='chronList'">Chronological List</xsl:when>
                    <xsl:when test="$label='chronItem'">Chronological Item</xsl:when>
                    <xsl:when test="$label='closing_date'">Closing Date</xsl:when>
                    <xsl:when test="$label='coinType'">Coin Type</xsl:when>
                    <xsl:when test="$label='collection'">Collection</xsl:when>
                    <xsl:when test="$label='color'">Color</xsl:when>
                    <xsl:when test="$label='completeness'">Completeness</xsl:when>
                    <xsl:when test="$label='condition'">Condition</xsl:when>
                    <xsl:when test="$label='conservationState'">Conservation State</xsl:when>
                    <xsl:when test="$label='contents'">Contents</xsl:when>
                    <xsl:when test="$label='coordinates'">Coordinates</xsl:when>
                    <xsl:when test="$label='countermark'">Countermark</xsl:when>
                    <xsl:when test="$label='date'">Date</xsl:when>
                    <xsl:when test="$label='dateOnObject'">Date on Object</xsl:when>
                    <xsl:when test="$label='dob'">Date on Object</xsl:when>
                    <xsl:when test="$label='dateRange'">Date Range</xsl:when>
                    <xsl:when test="$label='decade'">Decade</xsl:when>
                    <xsl:when test="$label='degree'">Degree</xsl:when>
                    <xsl:when test="$label='deity'">Deity</xsl:when>
                    <xsl:when test="$label='denomination'">Denomination</xsl:when>
                    <xsl:when test="$label='department'">Department</xsl:when>
                    <xsl:when test="$label='deposit'">Deposit</xsl:when>
                    <xsl:when test="$label='depth'">Depth</xsl:when>
                    <xsl:when test="$label='description'">Description</xsl:when>
                    <xsl:when test="$label='diameter'">Diameter</xsl:when>
                    <xsl:when test="$label='discovery'">Discovery</xsl:when>
                    <xsl:when test="$label='disposition'">Disposition</xsl:when>
                    <xsl:when test="$label='dynasty'">Dynasty</xsl:when>
                    <xsl:when test="$label='edge'">Edge</xsl:when>
                    <xsl:when test="$label='era'">Era</xsl:when>
                    <xsl:when test="$label='finder'">Finder</xsl:when>
                    <xsl:when test="$label='findspotDesc'">Findspot Description</xsl:when>
                    <xsl:when test="$label='findspot'">Findspot</xsl:when>
                    <xsl:when test="$label='fromDate'">From Date</xsl:when>
                    <xsl:when test="$label='geographic'">Geographic</xsl:when>
                    <xsl:when test="$label='grade'">Grade</xsl:when>
                    <xsl:when test="$label='height'">Height</xsl:when>
                    <xsl:when test="$label='history'">Object History</xsl:when>
                    <xsl:when test="$label='hoardDesc'">Hoard Description</xsl:when>
                    <xsl:when test="$label='identifier'">Identifier</xsl:when>
                    <xsl:when test="$label='issuer'">Issuer</xsl:when>
                    <xsl:when test="$label='landowner'">Landowner</xsl:when>
                    <xsl:when test="$label='legend'">Legend</xsl:when>
                    <xsl:when test="$label='manufacture'">Manufacture</xsl:when>
                    <xsl:when test="$label='material'">Material</xsl:when>
                    <xsl:when test="$label='measurementsSet'">Measurements</xsl:when>
                    <xsl:when test="$label='mint'">Mint</xsl:when>
                    <xsl:when test="$label='note'">Note</xsl:when>
                    <xsl:when test="$label='noteSet'">Notes</xsl:when>
                    <xsl:when test="$label='objectType'">Object Type</xsl:when>
                    <xsl:when test="$label='obverse'">Obverse</xsl:when>
                    <xsl:when test="$label='obv_leg'">Obverse Legend</xsl:when>
                    <xsl:when test="$label='obv_type'">Obverse Type</xsl:when>
                    <xsl:when test="$label='origin'">Origin</xsl:when>
                    <xsl:when test="$label='owner'">Owner</xsl:when>
                    <xsl:when test="$label='physDesc'">Physical Description</xsl:when>
                    <xsl:when test="$label='portrait'">Portrait</xsl:when>
                    <xsl:when test="$label='previousColl'">Previous Collection</xsl:when>
                    <xsl:when test="$label='private'">Private</xsl:when>
                    <xsl:when test="$label='productionPlace'">Production Place</xsl:when>
                    <xsl:when test="$label='provenance'">Provenance</xsl:when>
                    <xsl:when test="$label='public'">Public</xsl:when>
                    <xsl:when test="$label='publisher'">Publisher</xsl:when>
                    <xsl:when test="$label='reference'">Reference</xsl:when>
                    <xsl:when test="$label='refDesc'">References</xsl:when>
                    <xsl:when test="$label='region'">Region</xsl:when>
                    <xsl:when test="$label='repository'">Repository</xsl:when>
                    <xsl:when test="$label='reverse'">Reverse</xsl:when>
                    <xsl:when test="$label='rev_leg'">Reverse Legend</xsl:when>
                    <xsl:when test="$label='rev_type'">Reverse Type</xsl:when>
                    <xsl:when test="$label='ruler'">Ruler</xsl:when>
                    <xsl:when test="$label='saleCatalog'">Sale Catalog</xsl:when>
                    <xsl:when test="$label='saleItem'">Sale Item</xsl:when>
                    <xsl:when test="$label='salePrice'">Sale Price</xsl:when>
                    <xsl:when test="$label='shape'">Shape</xsl:when>
                    <xsl:when test="$label='specificGravity'">Specific Gravity</xsl:when>                    
                    <xsl:when test="$label='state'">State</xsl:when>
                    <xsl:when test="$label='statedAuthority'">Stated Authority</xsl:when>
                    <xsl:when test="$label='subject'">Subject</xsl:when>
                    <xsl:when test="$label='subjectSet'">Subjects</xsl:when>
                    <xsl:when test="$label='symbol'">Symbol</xsl:when>
                    <xsl:when test="$label='testmark'">Test Mark</xsl:when>
                    <xsl:when test="$label='timestamp'">Date Record Modified</xsl:when>
                    <xsl:when test="$label='title'">Title</xsl:when>
                    <xsl:when test="$label='toDate'">To Date</xsl:when>
                    <xsl:when test="$label='type'">Type</xsl:when>
                    <xsl:when test="$label='typeDesc'">Typological Description</xsl:when>
                    <xsl:when test="$label='thickness'">Thickness</xsl:when>
                    <xsl:when test="$label='undertypeDesc'">Undertype Description</xsl:when>
                    <xsl:when test="$label='wear'">Wear</xsl:when>
                    <xsl:when test="$label='weight'">Weight</xsl:when>
                    <xsl:when test="$label='width'">Width</xsl:when>
                    <xsl:when test="$label='year'">Year</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(upper-case(substring($label, 1, 1)), substring($label, 2))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
	
	<!-- normalize solr fields -->
	<xsl:function name="numishare:normalize_fields">
		<xsl:param name="field"/>
		<xsl:param name="lang"/>
		<xsl:choose>
			<xsl:when test="contains($field, 'legendCondensed')">
				<xsl:variable name="label" select="substring-before(replace($field, 'legendCondensed', 'leg'), '_text')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="label" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="label" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_hier')">
				<xsl:variable name="label" select="substring-before($field, '_hier')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_num')">
				<xsl:variable name="label" select="substring-before($field, '_num')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="label" select="substring-before($field, '_text')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="label" select="substring-before($field, '_m')"/>
				<xsl:value-of select="numishare:normalize_fields($label, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="label" select="substring-before($field, '_display')"/>
				<xsl:value-of select="numishare:regularize_node($label, $lang)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="numishare:regularize_node($field, $lang)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="numishare:normalizeLabel">
        <xsl:param name="label"/>
        <xsl:param name="lang"/>
        <xsl:choose>            
            <xsl:when test="$lang='ur'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">ابتدائی صفحه</xsl:when>
                    <xsl:when test="$label='header_about'">سرخی کے متعلق</xsl:when>
                    <xsl:when test="$label='header_browse'">تلاش کرنا</xsl:when>
                    <xsl:when test="$label='header_search'">ڈھونڈنا</xsl:when>
                    <xsl:when test="$label='header_maps'">نقشہ جات</xsl:when>
                    <xsl:when test="$label='header_compare'">موازنہ کرنا</xsl:when>
                    <xsl:when test="$label='header_symbols'">علامتیں</xsl:when>
                    <xsl:when test="$label='header_language'">زبان</xsl:when>
                    <xsl:when test="$label='header_analyze'">سکوں کے مجموعہ جات کا تجزیہ</xsl:when>
                    <xsl:when test="$label='header_visualize'">سوالات کا تجزیہ کرنا</xsl:when>
                    <xsl:when test="$label='header_contributors'">معاونین/ حصہ ڈالنے واے</xsl:when>
                    <xsl:when test="$label='header_feedback'">رائے دینا</xsl:when>
                    <xsl:when test="$label='header_identify'">سکےکی شناحت کرنا</xsl:when>
                    <xsl:when test="$label='display_summary'">خلاصہ</xsl:when>
                    <xsl:when test="$label='display_map'">نقشہ</xsl:when>
                    <xsl:when test="$label='display_administrative'">انتظامی</xsl:when>
                    <xsl:when test="$label='display_visualization'">تصور کرنا</xsl:when>
                    <xsl:when test="$label='display_data-download'">ریکارڈ منتقل کرنا</xsl:when>
                    <xsl:when test="$label='display_quantitative'">مقداری تجزیہ</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">تاریخ کا تجزیہ</xsl:when>
                    <xsl:when test="$label='display_contents'">مشمولات</xsl:when>
                    <xsl:when test="$label='display_examples'">اس قسم کی مثالیں</xsl:when>
                    <xsl:when test="$label='results_all-terms'">تمام شرائط</xsl:when>
                    <xsl:when test="$label='results_map-results'">نقشہ کے نتائج</xsl:when>
                    <xsl:when test="$label='results_filters'">متقطرکرنا</xsl:when>
                    <xsl:when test="$label='results_keyword'">مطلوبہ الفاظ</xsl:when>
                    <xsl:when test="$label='results_type_number'">سکے کی قسم کا نمبر</xsl:when>
                    <xsl:when test="$label='results_clear-all'">تمام شرائط صاف کرنا</xsl:when>
                    <xsl:when test="$label='results_data-options'">کوائف کے اختیارات</xsl:when>
                    <xsl:when test="$label='results_refine-results'">نتائج بہتر بنانا</xsl:when>
                    <xsl:when test="$label='results_quick-search'">جلد تلاش کرنا</xsl:when>
                    <xsl:when test="$label='results_has-images'">نتائج میں تصاویر ہیں</xsl:when>
                    <xsl:when test="$label='results_refine-search'">تلاش کو بہتر بنائیں</xsl:when>
                    <xsl:when test="$label='results_select'">فہرست سے منتخب کریں</xsl:when>
                    <xsl:when test="$label='results_sort-results'">نتائج چھانٹیں</xsl:when>
                    <xsl:when test="$label='results_sort-category'">بلحاظ قسم چھانٹیں</xsl:when>
                    <xsl:when test="$label='results_ascending'">صعودی ترتیب</xsl:when>
                    <xsl:when test="$label='results_descending'">تنازلى ترتیب</xsl:when>
                    <xsl:when test="$label='results_result-desc'">کل نتائج ZZ میں سے، XX سے YY تک دکھائے جارہے ہیں</xsl:when>
                    <xsl:when test="$label='results_coin'">سکہ</xsl:when>
                    <xsl:when test="$label='results_coins'">سکے</xsl:when>
                    <xsl:when test="$label='results_hoard'">سکوں کا مجموعہ</xsl:when>
                    <xsl:when test="$label='results_hoards'">سکوں کے مجموعہ جات</xsl:when>
                    <xsl:when test="$label='results_and'">اور</xsl:when>
                    <xsl:when test="$label='maps_legend'">لکھائی</xsl:when>
                    <xsl:when test="$label='visualize_typological'">تمثیلی تجزیہ</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">پیمائش کا تجزیہ</xsl:when>
                    <xsl:when test="$label='visualize_desc'">منتخب کردہ شرائط کی بنیاد پر چارٹ تخلیق کرنے کے لئے ذیل میں دئیے گئے کوائف کا انتخاب اور تصوری اختیارات کا استعمال کریں۔ اس خصوصیت کو استعمال کرنے کے لئے ہدایات یہاں مل سکتی ہیں-</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">مندرجہ ذیل قسموں کی فیصد یا عددی تعدار کو دیکھنے کے لئے اس فیچر کا استعمال کریں</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">اس خصوصیت کا استعمال سکوں کے مجموعہ جات کے اندر پائے جانے والے، کسی خاص تاریخ کے سکوں، کی فیصد یا تعداد کو جاننے کے لئے کریں۔</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">دیئے گئے استفسار(سوال) اور منتخب کردہ سکوں کے مجموعہ جات کیلئے CSV منتقل کرنے کیلئے اس خصوصیت کا استعمال کریں</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">پیمائش منتخب کریں</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">نقشہ کی قسم منتخب کریں</xsl:when>
                    <xsl:when test="$label='visualize_categories'">تجزیہ کے لئے زمرے منتخب کریں</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">سکوں کے مجموعہ جات منتخب کریں</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">موازنہ کرنے کے لیے سکوں کے مجموعہ جات کا انتحاب کریں (اختیاری)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">زمرہ (قسم) کے لحاظ سے موازنہ کریں</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">دیگر سوالات سے موازنہ کریں (اختیاری)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">سوالات کا موازنہ کریں</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">موازناتی سوال</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">مخصوص سوالات شامل کریں</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">سوال کو مخصوص کریں</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">سوال کو ہٹائیں</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">سوال شامل کریں</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">سوالات شامل کریں</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">نیا شامل کریں</xsl:when>
                    <xsl:when test="$label='visualize_query'">استفسار (سوال)</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">فہرست کو چھانٹیں</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">سوال کو چھانٹیں</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">چھانٹی کو ختم کریں</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">اپنی پیمائش کے سوال کو ترتیب دینے کے لئے نیچے والی فہرست کا استعمال کریں۔ تاریخ کی حد ہرسوال میں صرف ایک بار متعین کی جاسکتی ہے۔</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">اختیاری ترتیبات</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">چھپائیں / دکھائیں اختیارات</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">ڈھیر لگانے کے اختیارات</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">یقینی ضابطوں کو شامل نہ کریں</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">بمطابق وقفہ (اختیاری)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">وقفہ (سال)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">دورانیہ</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">منتخب شدہ کا حساب لگائیں</xsl:when>
                    <xsl:when test="$label='visualize_generate'">نقشہ بنائیں</xsl:when>
                    <xsl:when test="$label='numeric_count'">شمار</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">فیصد</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">مجموعی</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">مجموعی فی صد</xsl:when>
                    <xsl:when test="$label='chart_bar'">نقشہ کی ترتیب</xsl:when>
                    <xsl:when test="$label='chart_column'">چارٹ کی قطاریں</xsl:when>
                    <xsl:when test="$label='chart_area'">علاقہ</xsl:when>
                    <xsl:when test="$label='chart_spline'">تختہ / سپلائن</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">علاقہ سپلائن</xsl:when>
                    <xsl:when test="$label='chart_line'">چارٹ لائن</xsl:when>
                    <xsl:when test="$label='visualize_alert'">انتباہ</xsl:when>
                    <xsl:when test="$label='visualize_error1'">وقفے اور دورانیے کی ضرورت ہے ۔</xsl:when>
                    <xsl:when test="$label='visualize_error2'">تا تاریخ، از تاریخ کے بعد کی ہونی ضروری ہے۔</xsl:when>
                    <xsl:when test="$label='visualize_error3'">ایک زمرے کا انتخاب کرنا ہوگا۔</xsl:when>
                    <xsl:when test="$label='visualize_error4'">کم از کم 1 اور زیادہ سے زیادہ 8 سکوں کے مجموعہ جات کا انتخاب ہوسکتا ہے۔</xsl:when>
                    <xsl:when test="$label='visualize_error5'">زیادہ سے زیادہ 8 سکوں کے مجموعہ جات کا انتخاب ہوسکتا ہے۔</xsl:when>
                    <xsl:when test="$label='visualize_error6'">کم از کم 1 اور زیادہ سے زیادہ 30 سکوں کے مجموعہ جات کا انتخاب ہوسکتا ہے۔</xsl:when>
                    <xsl:when test="$label='visualize_error7'">زیادہ سے زیادہ 30 سکوں کے مجموعہ جات کا انتخاب ہوسکتا ہے۔</xsl:when>
                    <xsl:when test="$label='lang_ar'">عربی زبان</xsl:when>
                    <xsl:when test="$label='lang_bg'">بلغاریہ کی زبان</xsl:when>
                    <xsl:when test="$label='lang_da'">ڈنمارک کی زبان</xsl:when>
                    <xsl:when test="$label='lang_de'">جرمن زبان</xsl:when>
                    <xsl:when test="$label='lang_el'">یونانی زبان</xsl:when>
                    <xsl:when test="$label='lang_en'">انگریزی زبان</xsl:when>
                    <xsl:when test="$label='lang_es'">ہسپانوی زبان</xsl:when>
                    <xsl:when test="$label='lang_fi'">فن لینڈ کی زبان</xsl:when>
                    <xsl:when test="$label='lang_fr'">فرانسیسی زبان</xsl:when>
                    <xsl:when test="$label='lang_he'">عبرانی زبان</xsl:when>
                    <xsl:when test="$label='lang_hu'">ہنگری کی زبان</xsl:when>
                    <xsl:when test="$label='lang_it'">اطالوی زبان</xsl:when>
                    <xsl:when test="$label='lang_nl'">ڈچ زبان</xsl:when>
                    <xsl:when test="$label='lang_nn'">ناروے کی زبان</xsl:when>
                    <xsl:when test="$label='lang_pl'">پولینڈ کی زبان</xsl:when>
                    <xsl:when test="$label='lang_ro'">رومانیہ کی زبان</xsl:when>
                    <xsl:when test="$label='lang_ru'">روسی زبان</xsl:when>
                    <xsl:when test="$label='lang_sv'">سویڈن کی زبان</xsl:when>
                    <xsl:when test="$label='lang_tr'">ترکی زبان</xsl:when>
                    <xsl:when test="$label='lang_uk'">یوکرائن کی زبان</xsl:when>
                    <xsl:when test="$label='lang_ur'">اُردو زبان</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='de'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Start</xsl:when>
                    <xsl:when test="$label='header_browse'">Browsen</xsl:when>
                    <xsl:when test="$label='header_search'">Suchen</xsl:when>
                    <xsl:when test="$label='header_maps'">Karten</xsl:when>
                    <xsl:when test="$label='header_compare'">Vergleichen</xsl:when>
                    <xsl:when test="$label='header_language'">Sprache</xsl:when>
                    <xsl:when test="$label='header_analyze'">Hortfunde analysieren</xsl:when>
                    <xsl:when test="$label='header_visualize'">Anfragen visualisieren</xsl:when>
                    <xsl:when test="$label='display_summary'">Zusammenfassung</xsl:when>
                    <xsl:when test="$label='display_map'">Karten</xsl:when>
                    <xsl:when test="$label='display_administrative'">Aadministrativ</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualisierung</xsl:when>
                    <xsl:when test="$label='display_data-download'">Datendownlaod</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Quantitative Analyse</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Datumsanalyse</xsl:when>
                    <xsl:when test="$label='display_contents'">Inhalt</xsl:when>
                    <xsl:when test="$label='display_examples'">Exemplare dieses Typs</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Alle Begriffe</xsl:when>
                    <xsl:when test="$label='results_map-results'">Kartierungsergebnisse</xsl:when>
                    <xsl:when test="$label='results_filters'">Filter</xsl:when>
                    <xsl:when test="$label='results_keyword'">Schlagwort</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Alle Begriffe löchen</xsl:when>
                    <xsl:when test="$label='results_data-options'">Datenoptionen</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Ergebnisse eingrenzen</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Schnelle Suche</xsl:when>
                    <xsl:when test="$label='results_has-images'">Hat Bilder</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Suche eingrenzen</xsl:when>
                    <xsl:when test="$label='results_select'">Aus Liste auswählen</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Ergebnisse sortieren</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sortierungskategorie</xsl:when>
                    <xsl:when test="$label='results_ascending'">Aufsteigend</xsl:when>
                    <xsl:when test="$label='results_descending'">Absteigend</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Ergebnisse von XX bis YY aus ZZ Gesamtergebnissen anzeigen</xsl:when>
                    <xsl:when test="$label='results_coin'">Münze</xsl:when>
                    <xsl:when test="$label='results_coins'">Münzen</xsl:when>
                    <xsl:when test="$label='results_hoard'">Schatzfund</xsl:when>
                    <xsl:when test="$label='results_hoards'">Schatzfunden</xsl:when>
                    <xsl:when test="$label='results_and'">und</xsl:when>
                    <xsl:when test="$label='maps_legend'">Legende</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Typologische Analyse</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analyse der Dimensionen</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Verwenden Sie die Datenauswahl- und Visualisierungsoptionen, um eine auf ausgewählten Parametern basierte Grafik zu erzeugen. Eine Gebrauchsanleitung dafür finden Sie hier</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Verwenden Sie diese Option, um Prozent- bzw. absolute Zahlen der folgenden Typologien zu visualisieren</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Verwenden Sie diese Option, um das Vorkommen von Münzen eines bestimmten Datums in Schtazfunden als Prozent- bzw. absolute Zahlen zu erhalten</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Verwenden Sie diese Option, um eine CSV-Datei für die Abfrage und die ausgewählten Schatzfunde zu downloaden</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Dimensionen auswählen</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Grafikart auswählen</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Analysekategorien auswählen</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Schatzfunde auswählen</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Schatzfunde für Verleich auswählen (optional)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Vergleich nach Kategorie</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Vergleich mit anderen Abfragen (optional)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Abfragen vergleichen</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Vergleichsabfrage</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Spezifische Abfrage hinzufügen</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Spezifische Abfrage</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Abfrage entfernen</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Abfrage hinzufügen</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Abfragen hinzufügen</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Neu hinzufügen</xsl:when>
                    <xsl:when test="$label='visualize_query'">Abfrage</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filterliste</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filterabfrage</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Filter entfernen</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Verwenden Sie die Ausklappmenüs unten, um Ihre Dimensionsabfrage zu formulieren. Ein Datumsbereich kann für jede Abfrage nur einmal angegeben werden</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Optionale Einstellungen</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Optionen ausblenden/zeigen</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Stapeloptionen</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Sicherheitscodes entfernen</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Nach Intervall anordnen (optional)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Intervall (Jahre)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Dauer</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Ausgewähltes berechnen</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Grafik erzeugen</xsl:when>
                    <xsl:when test="$label='numeric_count'">Zählen</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Prozentzahl</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulativ</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Cumulative Prozentzahl</xsl:when>
                    <xsl:when test="$label='chart_bar'">Balken</xsl:when>
                    <xsl:when test="$label='chart_column'">Säule</xsl:when>
                    <xsl:when test="$label='chart_area'">Fläche</xsl:when>
                    <xsl:when test="$label='chart_spline'">Spline</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Spline-Fläche</xsl:when>
                    <xsl:when test="$label='chart_line'">Linie</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alarm</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Intervall und Dauer werden benötigt</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Datum bis muss später als Datum von sein</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Eine Kategorie muss ausgewählt sein</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Mindestens 1 und bis zu 8 Schatzfunden können ausgewählt werden</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Bis zu 8 Schatzfunden können ausgewählt werden</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Mindestens 1 und bis zu 30 Schatzfunden können ausgewählt werden</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Bis zu 30 Schatzfunden können ausgewählt werden</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabisch</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgarisch</xsl:when>
                    <xsl:when test="$label='lang_da'">Dänisch</xsl:when>
                    <xsl:when test="$label='lang_de'">Deutsch</xsl:when>
                    <xsl:when test="$label='lang_el'">Griechisch</xsl:when>
                    <xsl:when test="$label='lang_en'">Englisch</xsl:when>
                    <xsl:when test="$label='lang_es'">Spanisch</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finnisch</xsl:when>
                    <xsl:when test="$label='lang_fr'">Französisch</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebräisch</xsl:when>
                    <xsl:when test="$label='lang_hu'">Ungarisch</xsl:when>
                    <xsl:when test="$label='lang_it'">Italienisch</xsl:when>
                    <xsl:when test="$label='lang_nl'">Niederländisch</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norwegisch</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polnisch</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumänisch</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russisch</xsl:when>
                    <xsl:when test="$label='lang_sv'">Schwedisch</xsl:when>
                    <xsl:when test="$label='lang_tr'">Türkisch</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrainisch</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ar'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">المكان</xsl:when>
                    <xsl:when test="$label='header_browse'">البحث بالتحديد</xsl:when>
                    <xsl:when test="$label='header_search'">البحث</xsl:when>
                    <xsl:when test="$label='header_maps'">الخرائط</xsl:when>
                    <xsl:when test="$label='header_compare'">المقارنة</xsl:when>
                    <xsl:when test="$label='header_language'">اللغة</xsl:when>
                    <xsl:when test="$label='header_analyze'">لتحليل الكنز</xsl:when>
                    <xsl:when test="$label='header_visualize'">التصور المرئى للإستفسارات</xsl:when>
                    <xsl:when test="$label='display_summary'">ملخص</xsl:when>
                    <xsl:when test="$label='display_map'">خريطة</xsl:when>
                    <xsl:when test="$label='display_administrative'">الإداري</xsl:when>
                    <xsl:when test="$label='display_visualization'">التصور المرئى</xsl:when>
                    <xsl:when test="$label='display_data-download'">تحميل البيانات</xsl:when>
                    <xsl:when test="$label='display_quantitative'">التحليل الكمى</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">تحليل بيانات</xsl:when>
                    <xsl:when test="$label='display_contents'">المحتويات</xsl:when>
                    <xsl:when test="$label='display_examples'">أمثلة من هذا النوع</xsl:when>
                    <xsl:when test="$label='results_all-terms'">جميع المصطلحات</xsl:when>
                    <xsl:when test="$label='results_map-results'">نتائج الخريطة</xsl:when>
                    <xsl:when test="$label='results_filters'">عوامل تصفية البحث</xsl:when>
                    <xsl:when test="$label='results_keyword'">كلمة أساسية</xsl:when>
                    <xsl:when test="$label='results_clear-all'">حذف جميع المصطلحات</xsl:when>
                    <xsl:when test="$label='results_data-options'">خيارات البيانات</xsl:when>
                    <xsl:when test="$label='results_refine-results'">تحسين النتائج</xsl:when>
                    <xsl:when test="$label='results_quick-search'">بحث سريع</xsl:when>
                    <xsl:when test="$label='results_has-images'">يشمل صور</xsl:when>
                    <xsl:when test="$label='results_refine-search'">تحسين البحث</xsl:when>
                    <xsl:when test="$label='results_select'">إختر من القائمة</xsl:when>
                    <xsl:when test="$label='results_sort-results'">ترتيب النتائج</xsl:when>
                    <xsl:when test="$label='results_sort-category'">ترتيب الفئات</xsl:when>
                    <xsl:when test="$label='results_ascending'">تصاعدى</xsl:when>
                    <xsl:when test="$label='results_descending'">تنازلى</xsl:when>
                    <xsl:when test="$label='results_result-desc'">عرض سجلات من (أ أ) إلى (ب ب) من إجمالى النتائج (ج ج) بالكامل</xsl:when>
                    <xsl:when test="$label='results_coin'">عملة معدنية</xsl:when>
                    <xsl:when test="$label='results_coins'">عملات معدنية</xsl:when>
                    <xsl:when test="$label='results_hoard'">الكنز</xsl:when>
                    <xsl:when test="$label='results_hoards'">الكنوز</xsl:when>
                    <xsl:when test="$label='results_and'">و</xsl:when>
                    <xsl:when test="$label='maps_legend'">الكتابات</xsl:when>
                    <xsl:when test="$label='visualize_typological'">تحليل الخواص الهندسية و الفراغية</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">تحليل القياسات</xsl:when>
                    <xsl:when test="$label='visualize_desc'">استخدم الخيارات و التصور المرئى للبيانات أدناه لتوليد مخطط بيانى استنادا إلى هذه المعايير. تعليمات إستخدام هذه الخاصية يمكن العثور عليها هنا</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">استخدم هذه الخاصية لإظهار التصور البصرى للنسب المئوية أو الظهور العددى للنماذج التالية</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">إستخدم هذه الخاصية لتوليد النسب المئوية أو الظهور العددى للقطع النقدية من تاريخ معين ضمن الكنوز</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">إستخدم هذه الخاصية لتحميل سى-إس-ڤى للبحث المُقَدَّم و الكنوز المختارة</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">إختر المقاس</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">حدد نوع الرسم البياني</xsl:when>
                    <xsl:when test="$label='visualize_categories'">إختر الفئات للتحليل</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">إختر الكنوز</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">إختر الكنوز للمقارنة، إستخدام بين القوسين اختيارى</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">مقارنة حسب الفئة</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">مقارنة مع الإستفسارات الأخرى، إستخدام بين القوسين إختيارى</xsl:when>
                    <xsl:when test="$label='visualize_compare'">مقارنة بين الإستفسارات</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">إستفسار للمقارنة</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">إضافة بحث/إستفسار مخصص</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">بحث/إستفسار مخصص</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">إزالة البحث</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">أضِف بحث</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">أضِف أبحاث</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">إضافة جديدة</xsl:when>
                    <xsl:when test="$label='visualize_query'">إستعلام/بحث</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">قائمة عوامل التصفية</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">أضِف عوامل تصفية للإستفسارات</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">إزالة عوامل التصفية</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">إستخدم القوائم المنسدلة أدناه لصياغة الإستعلام الخاص بك. لا يمكن تحديد نطاق التاريخ أكثر مرة واحدة في الإستعلام</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">محدِدات اختيارية</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">خيارات الإخفاء أو العرض</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">تراص الخيارات</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">إستبعاد الأكواد اليقينية</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">رَتِّب حسب الفترات الزمنية - إختيارى</xsl:when>
                    <xsl:when test="$label='visualize_interval'">رَتِّب على فترات زمنية متساوية، بالعام</xsl:when>
                    <xsl:when test="$label='visualize_duration'">المدة</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">إحسب ما تم إختياره</xsl:when>
                    <xsl:when test="$label='visualize_generate'">توليد الرسم البياني</xsl:when>
                    <xsl:when test="$label='numeric_count'">عدد</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">نسبة مئوية</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">تراكمى</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">نسبة مئوية تراكمية</xsl:when>
                    <xsl:when test="$label='chart_bar'">شريط الرسم البياني</xsl:when>
                    <xsl:when test="$label='chart_column'">عمود الرسم البياني</xsl:when>
                    <xsl:when test="$label='chart_area'">منطقة الرسم البياني</xsl:when>
                    <xsl:when test="$label='chart_spline'">المنحنى البياني</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">المنطقة المحصورة تحت المنحنى البيانى أو بين منحنيين بيانيين</xsl:when>
                    <xsl:when test="$label='chart_line'">خط الرسم البيانى</xsl:when>
                    <xsl:when test="$label='visualize_alert'">تنبيه</xsl:when>
                    <xsl:when test="$label='visualize_error1'">مطلوب الفترات المتساوية و مدتها</xsl:when>
                    <xsl:when test="$label='visualize_error2'">تاريخ نهاية المدة يجب أن يكون لاحقاً لتاريخ بدايتها</xsl:when>
                    <xsl:when test="$label='visualize_error3'">يجب إختيار الفئة/النوع</xsl:when>
                    <xsl:when test="$label='visualize_error4'">يجب إختيار كنز واحد على الأقل، و يمكن حتى ثمانية</xsl:when>
                    <xsl:when test="$label='visualize_error5'">يمكن أختيار ما يصل إلى ثمانية كنو</xsl:when>
                    <xsl:when test="$label='visualize_error6'">يجب إختيار كنز واحد على الأقل، و يمكن حتى ثلاثين</xsl:when>
                    <xsl:when test="$label='visualize_error7'">يمكن أختيار ما يصل إلى ثلاثين كنز</xsl:when>
                    <xsl:when test="$label='lang_ar'">العربيّة</xsl:when>
                    <xsl:when test="$label='lang_bg'">البلغارية</xsl:when>
                    <xsl:when test="$label='lang_da'">الدنماركية</xsl:when>
                    <xsl:when test="$label='lang_de'">ألماني</xsl:when>
                    <xsl:when test="$label='lang_el'">اللغة اليونانية</xsl:when>
                    <xsl:when test="$label='lang_en'">إنجليزي</xsl:when>
                    <xsl:when test="$label='lang_es'">الأسبانية</xsl:when>
                    <xsl:when test="$label='lang_fi'">الفنلندية</xsl:when>
                    <xsl:when test="$label='lang_fr'">فرنسي</xsl:when>
                    <xsl:when test="$label='lang_he'">اللغة العبرية</xsl:when>
                    <xsl:when test="$label='lang_hu'">المجرية</xsl:when>
                    <xsl:when test="$label='lang_it'">الإيطالي</xsl:when>
                    <xsl:when test="$label='lang_nl'">هولندي</xsl:when>
                    <xsl:when test="$label='lang_nn'">اللغة النروجية</xsl:when>
                    <xsl:when test="$label='lang_pl'">بولندي</xsl:when>
                    <xsl:when test="$label='lang_ro'">رومانيا</xsl:when>
                    <xsl:when test="$label='lang_ru'">الروسية</xsl:when>
                    <xsl:when test="$label='lang_sv'">اللغة السويدية</xsl:when>
                    <xsl:when test="$label='lang_tr'">اللغة التركية</xsl:when>
                    <xsl:when test="$label='lang_uk'">الأوكرانية</xsl:when>
                    <xsl:when test="$label='lang_ur'">الأردية</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='fr'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Accueil</xsl:when>
                    <xsl:when test="$label='header_browse'">Explorer</xsl:when>
                    <xsl:when test="$label='header_search'">Chercher</xsl:when>
                    <xsl:when test="$label='header_maps'">Cartes</xsl:when>
                    <xsl:when test="$label='header_compare'">Comparer</xsl:when>
                    <xsl:when test="$label='header_language'">Langue</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analyse des trésors</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualiser la recherche</xsl:when>
                    <xsl:when test="$label='display_summary'">Résumé</xsl:when>
                    <xsl:when test="$label='display_map'">Carte</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administratif</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualisation</xsl:when>
                    <xsl:when test="$label='display_data-download'">Récupérer les données</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Analyse quantitative</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Analyse des dates</xsl:when>
                    <xsl:when test="$label='display_contents'">Contenu</xsl:when>
                    <xsl:when test="$label='display_examples'">Exemples de ce type</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Tous les termes</xsl:when>
                    <xsl:when test="$label='results_map-results'">Résultats géographiques</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtres</xsl:when>
                    <xsl:when test="$label='results_keyword'">Mot clef</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Effacer les termes sélectionnés</xsl:when>
                    <xsl:when test="$label='results_data-options'">Options de données</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Raffiner le résultat</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Recherche rapide</xsl:when>
                    <xsl:when test="$label='results_has-images'">Images disponibles</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Raffiner la recherche</xsl:when>
                    <xsl:when test="$label='results_select'">Sélectionner à partir de la liste</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Classer les résultats</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Classer les catégories</xsl:when>
                    <xsl:when test="$label='results_ascending'">Ordre ascendant</xsl:when>
                    <xsl:when test="$label='results_descending'">Ordre descendant</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Afficher les références XX à YY à partir de ZZ résultats</xsl:when>
                    <xsl:when test="$label='results_coin'">monnaie</xsl:when>
                    <xsl:when test="$label='results_coins'">monnaies</xsl:when>
                    <xsl:when test="$label='results_hoard'">trésor</xsl:when>
                    <xsl:when test="$label='results_hoards'">trésors</xsl:when>
                    <xsl:when test="$label='results_and'">et</xsl:when>
                    <xsl:when test="$label='maps_legend'">Légende</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Analyse typologique</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analyse des mesures</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Utilisez la sélection des informations et les options de visualisation ci-dessous pour créer un graphique basés sur les paramètres sélectionnés. Les instructions d'utilisation de cette fonction peuvent être trouvés ici.</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Utilisez cette fonctionalité pour visualiser les pourcentages ou le nombre de fois où cette typologie apparaît</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Utilisez cette fonctionalité pour obtenir le pourcentage ou le nombre de fois où cette monnaie apparaît à une date particulière au sein des trésors</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Utilisez cette fonctionalité pour télécharger un CSV correspondant à la recherche et les trésors sélectionnés</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Selectionnez Mesure</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Sélectionnez Type de graphe.</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Sélectionnez Catégories pour analyse.</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Sélectionnez Trésors</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Sélectionnez Comparaison de trésors (Optionnel)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Comparez par catégorie</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Comparez aux autres recherches (optionnel)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Comparez les recherches</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Demande de comparaison</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Ajoutez des demandes spécifiques</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Demande spécifique</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Enlevez la demande</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Ajoutez une demande</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Ajoutez des demandes</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Ajoutez</xsl:when>
                    <xsl:when test="$label='visualize_query'">Demande</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filtre de liste</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Demande de filtre</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Enlevez le filtre</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Utilisez les fonctions de défilement ci-dessous pour fromuler votre demande de mesure. Une période entre deux dates ne peut être spécifiée qu'une seule fois par demande</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Cadre de travail optionnel</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Options de Cacher/Afficher</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Options de mise en ordre</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Exclure les codes certains</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Organiser par intervalles (optionnel)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Intervalle (années)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Durée</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Calculer la sélection</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Générer un graphe</xsl:when>
                    <xsl:when test="$label='numeric_count'">Dénombrer</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Pourcentage</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulé</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Pourcentage cumulé</xsl:when>
                    <xsl:when test="$label='chart_bar'">Barre</xsl:when>
                    <xsl:when test="$label='chart_column'">Colonne</xsl:when>
                    <xsl:when test="$label='chart_area'">Surface</xsl:when>
                    <xsl:when test="$label='chart_spline'">Courbe spline</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Surface spline</xsl:when>
                    <xsl:when test="$label='chart_line'">Ligne</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alerte</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Intervalle et période sont requis</xsl:when>
                    <xsl:when test="$label='visualize_error2'">La date finale doit se situer après la date initiale</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Une catégorie doit être sélectionnée</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Un minimum de 1 et un maximum de 8 trésors peuvent être sélectionnés</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Jusqu'à 8 trésors peuvent être sélectionnés</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Un minimum de 1 et un maximum de 30 trésors peuvent être sélectionnés</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Jusqu'à 30 trésors peuvent être sélectionnés</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabe</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgare</xsl:when>
                    <xsl:when test="$label='lang_da'">Danois</xsl:when>
                    <xsl:when test="$label='lang_de'">Allemand</xsl:when>
                    <xsl:when test="$label='lang_el'">Grec</xsl:when>
                    <xsl:when test="$label='lang_en'">Anglais</xsl:when>
                    <xsl:when test="$label='lang_es'">Espagnol</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finlandais</xsl:when>
                    <xsl:when test="$label='lang_fr'">Français</xsl:when>
                    <xsl:when test="$label='lang_he'">Hébreu</xsl:when>
                    <xsl:when test="$label='lang_hu'">Hongrois</xsl:when>
                    <xsl:when test="$label='lang_it'">Italien</xsl:when>
                    <xsl:when test="$label='lang_nl'">Néerlandais</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norvégien</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polonais</xsl:when>
                    <xsl:when test="$label='lang_ro'">Roumain</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russe</xsl:when>
                    <xsl:when test="$label='lang_sv'">Suédois</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turc</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrainien</xsl:when>
                    <xsl:when test="$label='lang_ur'">Ourdou</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ro'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Acasă</xsl:when>
                    <xsl:when test="$label='header_browse'">Explore</xsl:when>
                    <xsl:when test="$label='header_search'">Căutare</xsl:when>
                    <xsl:when test="$label='header_maps'">Hărţi</xsl:when>
                    <xsl:when test="$label='header_compare'">Comparativ</xsl:when>
                    <xsl:when test="$label='header_language'">Limbă</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analiza tezaurelor</xsl:when>
                    <xsl:when test="$label='header_visualize'">Vizualizarea cercetării</xsl:when>
                    <xsl:when test="$label='display_summary'">Rezumat</xsl:when>
                    <xsl:when test="$label='display_map'">Hartă</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administrativ</xsl:when>
                    <xsl:when test="$label='display_visualization'">Vizualizare</xsl:when>
                    <xsl:when test="$label='display_data-download'">Data descărcării</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Aniliza cantitativă</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Analiza datelor</xsl:when>
                    <xsl:when test="$label='display_contents'">Conţinut</xsl:when>
                    <xsl:when test="$label='display_examples'">Exemple ale acestui tip</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Toţi termenii</xsl:when>
                    <xsl:when test="$label='results_map-results'">Rezultatele geografice</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtre</xsl:when>
                    <xsl:when test="$label='results_keyword'">Cuvinte cheie</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Şterge toţi termenii</xsl:when>
                    <xsl:when test="$label='results_data-options'">Opţiuni asupra datelor</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Rafinare rezultate</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Căutare rapidă</xsl:when>
                    <xsl:when test="$label='results_has-images'">Imagini disponibile</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Căutare detaliată</xsl:when>
                    <xsl:when test="$label='results_select'">Selectare din listă</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Clasificarea rezultatelor</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sortare categorie</xsl:when>
                    <xsl:when test="$label='results_ascending'">Ordine ascendentă</xsl:when>
                    <xsl:when test="$label='results_descending'">Ordine descendentă</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Afişare rezultate de la XX la YY din totalul de ZZ rezultate</xsl:when>
                    <xsl:when test="$label='results_coin'">monedă</xsl:when>
                    <xsl:when test="$label='results_coins'">monede</xsl:when>
                    <xsl:when test="$label='results_hoard'">tezaur</xsl:when>
                    <xsl:when test="$label='results_hoards'">tezaure</xsl:when>
                    <xsl:when test="$label='results_and'">și</xsl:when>
                    <xsl:when test="$label='maps_legend'">Legenda</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Analiză tipologică</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analiză dimensiuni</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Utilizați selecția de date și opțiunile de vizualizare de mai jos pentru a genera harta pe baza parametrilor selectați. Instrucțiuni de utilizare pentru această funcție pot fi găsite aici.</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Utilizați această funcție pentru a vizualiza procentajul sau cuantificarea următoarelor tipologii</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Utilizați această funcție pentru a reda procentajul sau cuantificarea monedelor emise la o anumită dată din cadrul tezaurelor</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Utilizați această funcție pentru a descărca CSV (valori separate prin virgulă) pentru cererea adresată și tezaurele selectate</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Selectare dimensiuni</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Selectare tip de hartă</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Selectare Categorii pentru Analiză</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Selectare Tezaure</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Selectare Tezaure pentru Comparație (opțional)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Comparație pe Categorie</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Comparație cu alte Cereri (opțional)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Comparare Categorii</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Categorie de Comparație</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Adăugare Categorie aleatorie</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Categorie aleatorie</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Eliminare categorie</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Adăugare categorie</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Adăugare categorii</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Adăugare noutate</xsl:when>
                    <xsl:when test="$label='visualize_query'">Categorie</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filtrare listă</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filtrare categorie</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Eliminare filtru</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Utilizați meniul drop-down pentru a fomula criteriul de măsurare. Intervalul cronologic poate fi speificat doar o dată pe cerere</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Setări opționale</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Ascunde/arată opțiuni</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Pachet de opțiuni</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Excludere coduri de siguranță</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Aranjare pe segmente (opțional)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Interval (ani)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Perioadă</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Calcul selecție</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Generare hartă</xsl:when>
                    <xsl:when test="$label='numeric_count'">Cont</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Procentaj</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulativ</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Procentaj cumulativ</xsl:when>
                    <xsl:when test="$label='chart_bar'">bară</xsl:when>
                    <xsl:when test="$label='chart_column'">coloană</xsl:when>
                    <xsl:when test="$label='chart_area'">arie</xsl:when>
                    <xsl:when test="$label='chart_spline'">linie curbă</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">arie linie curbă</xsl:when>
                    <xsl:when test="$label='chart_line'">linie</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Atenție</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Interval și perioadă sunt necesare</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Datarea până la...trebuie să fie mai târziu decât Datare de la...</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Trebuie să fie selectată o categorie</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Pot fi selectate de la cel puțin 1 tezaur până la maxim 8</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Pot fi selectate maxim 8 tezaure</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Pot fi selectate de la cel puțin 1 tezaur până la maxim 30</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Pot fi selectate maxim 30 tezaure</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabă</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgară</xsl:when>
                    <xsl:when test="$label='lang_da'">Daneză</xsl:when>
                    <xsl:when test="$label='lang_de'">Germană</xsl:when>
                    <xsl:when test="$label='lang_el'">Greacă</xsl:when>
                    <xsl:when test="$label='lang_en'">Engleză</xsl:when>
                    <xsl:when test="$label='lang_es'">Spaniolă</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finlandeză</xsl:when>
                    <xsl:when test="$label='lang_fr'">Franceză</xsl:when>
                    <xsl:when test="$label='lang_he'">Evrei</xsl:when>
                    <xsl:when test="$label='lang_hu'">Maghiară</xsl:when>
                    <xsl:when test="$label='lang_it'">Italiană</xsl:when>
                    <xsl:when test="$label='lang_nl'">Olandeză</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norvegiană</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polonă</xsl:when>
                    <xsl:when test="$label='lang_ro'">Romană</xsl:when>
                    <xsl:when test="$label='lang_ru'">Rusă</xsl:when>
                    <xsl:when test="$label='lang_sv'">Suedeză</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turcă</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ucrainean</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='ru'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Главная</xsl:when>
                    <xsl:when test="$label='header_about'">О нас</xsl:when>
                    <xsl:when test="$label='header_browse'">Обзор</xsl:when>
                    <xsl:when test="$label='header_search'">Поиск</xsl:when>
                    <xsl:when test="$label='header_maps'">Карты</xsl:when>
                    <xsl:when test="$label='header_compare'">Сравнить</xsl:when>
                    <xsl:when test="$label='header_symbols'">Символы</xsl:when>
                    <xsl:when test="$label='header_language'">Язык</xsl:when>
                    <xsl:when test="$label='header_analyze'">Анализ кладов</xsl:when>
                    <xsl:when test="$label='header_visualize'">Отобразить запросы</xsl:when>
                    <xsl:when test="$label='header_contributors'">Партнеры</xsl:when>
                    <xsl:when test="$label='header_identify'">Определение монеты</xsl:when>
                    <xsl:when test="$label='display_summary'">Резюме</xsl:when>
                    <xsl:when test="$label='display_map'">Карта</xsl:when>
                    <xsl:when test="$label='display_administrative'">Администрирование</xsl:when>
                    <xsl:when test="$label='display_visualization'">Отображение</xsl:when>
                    <xsl:when test="$label='display_data-download'">Загрузка данных</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Количественный анализ</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Анализ датировки</xsl:when>
                    <xsl:when test="$label='display_contents'">Содержание</xsl:when>
                    <xsl:when test="$label='display_examples'">Объекты</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Все значения</xsl:when>
                    <xsl:when test="$label='results_map-results'">Показать результаты на карте</xsl:when>
                    <xsl:when test="$label='results_filters'">Фильтры</xsl:when>
                    <xsl:when test="$label='results_keyword'">Ключевое слово</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Очистить все значения</xsl:when>
                    <xsl:when test="$label='results_data-options'">Исходные данные</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Обновить результаты</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Быстрый поиск</xsl:when>
                    <xsl:when test="$label='results_has-images'">Содержит изображения</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Обновить поиск</xsl:when>
                    <xsl:when test="$label='results_select'">Выбрать из списка</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Сортировать результаты</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Сортировать категории</xsl:when>
                    <xsl:when test="$label='results_ascending'">По возрастанию</xsl:when>
                    <xsl:when test="$label='results_descending'">По убыванию</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Отображать записи XX из YY из ZZ результатов</xsl:when>
                    <xsl:when test="$label='results_coin'">монета</xsl:when>
                    <xsl:when test="$label='results_coins'">монеты</xsl:when>
                    <xsl:when test="$label='results_hoard'">клад</xsl:when>
                    <xsl:when test="$label='results_hoards'">клады</xsl:when>
                    <xsl:when test="$label='results_and'">и</xsl:when>
                    <xsl:when test="$label='maps_legend'">Легенда</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Типологический анализ</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Анализ измерений</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Использовать выбор данных и визуализацию параметров дальше для создания диаграммы на основе выбранных параметров. Инструкции по использованию этой функции можно найти здесь</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Использовать эту функцию, чтобы визуализировать проценты или числовые совпадения имеющихся типологий</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Использовать функцию, чтобы рассчитать проценты или количество монет определенной даты в рамках кладов</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Использовать функцию для загрузки CSV для данного запроса и выбранных кладов</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Выбрать измерения</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Тип диаграммы</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Выбрать категории для анализа</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Выбрать клады</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Выбрать клады для сравнения (по желанию)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Сравнить категории</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Сравнить с другими запросами (по желанию)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Сравнить запросы</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Сравнение запроса</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Добавить пользовательский запрос</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Пользовательский запрос</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Удалить запрос</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Добавить запрос</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Добавить запросы</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Добавить новый</xsl:when>
                    <xsl:when test="$label='visualize_query'">Запрос</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Фильтрация по списку</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Фильтрация по запросу</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Удалить фильтр</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Добавить описание запроса</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Дополнительные настройки</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Прятать/отображать параметры</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Параметры стека</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Исключить защитные коды</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Разместить по интервалам (по желанию)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Интервал (годы)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Продолжительность</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Обчислить выбранное</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Создать диаграмму</xsl:when>
                    <xsl:when test="$label='numeric_count'">Рассчитать</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Проценты</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Суммарный</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Суммарный процент</xsl:when>
                    <xsl:when test="$label='chart_bar'">Бар</xsl:when>
                    <xsl:when test="$label='chart_column'">Колонка</xsl:when>
                    <xsl:when test="$label='chart_area'">Область</xsl:when>
                    <xsl:when test="$label='chart_spline'">Сплайн</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Область сплайна</xsl:when>
                    <xsl:when test="$label='chart_line'">Линия</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Оповещение</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Необходимы интервал и продолжительность</xsl:when>
                    <xsl:when test="$label='visualize_error2'">&quot;К дате&quot; должно быть позднее чем &quot;От даты&quot;</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Необходимо выбрать категорию</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Можно выбрать от 1 до 8 кладов</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Можно выбрать более 8 кладов</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Можно выбрать от 1 до 30 кладов</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Можно выбрать более 30 кладов</xsl:when>
                    <xsl:when test="$label='lang_ar'">Арабский</xsl:when>
                    <xsl:when test="$label='lang_bg'">Болгарский</xsl:when>
                    <xsl:when test="$label='lang_da'">Датский</xsl:when>
                    <xsl:when test="$label='lang_de'">Немецкий</xsl:when>
                    <xsl:when test="$label='lang_el'">Греческий</xsl:when>
                    <xsl:when test="$label='lang_en'">Английский</xsl:when>
                    <xsl:when test="$label='lang_es'">Испанский</xsl:when>
                    <xsl:when test="$label='lang_fi'">Финнский</xsl:when>
                    <xsl:when test="$label='lang_fr'">Французский</xsl:when>
                    <xsl:when test="$label='lang_he'">Иврит</xsl:when>
                    <xsl:when test="$label='lang_hu'">Венгерский</xsl:when>
                    <xsl:when test="$label='lang_it'">Итальянский</xsl:when>
                    <xsl:when test="$label='lang_nl'">Голландский</xsl:when>
                    <xsl:when test="$label='lang_nn'">Норвежский</xsl:when>
                    <xsl:when test="$label='lang_pl'">Польский</xsl:when>
                    <xsl:when test="$label='lang_ro'">Румынский</xsl:when>
                    <xsl:when test="$label='lang_ru'">Русский</xsl:when>
                    <xsl:when test="$label='lang_sv'">Шведский</xsl:when>
                    <xsl:when test="$label='lang_tr'">Турецкий</xsl:when>
                    <xsl:when test="$label='lang_uk'">Украинский</xsl:when>
                    <xsl:when test="$label='lang_ur'">урду</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='uk'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Головна</xsl:when>
                    <xsl:when test="$label='header_about'">Про нас</xsl:when>
                    <xsl:when test="$label='header_browse'">Перегляд</xsl:when>
                    <xsl:when test="$label='header_search'">Пошук</xsl:when>
                    <xsl:when test="$label='header_maps'">Мапи</xsl:when>
                    <xsl:when test="$label='header_compare'">Порівняти</xsl:when>
                    <xsl:when test="$label='header_symbols'">Символи</xsl:when>
                    <xsl:when test="$label='header_language'">Мова</xsl:when>
                    <xsl:when test="$label='header_analyze'">Аналіз скарбів</xsl:when>
                    <xsl:when test="$label='header_visualize'">Відобразити запити</xsl:when>
                    <xsl:when test="$label='header_contributors'">Партнери</xsl:when>
                    <xsl:when test="$label='header_identify'">Визначення монети</xsl:when>
                    <xsl:when test="$label='display_summary'">Резюме</xsl:when>
                    <xsl:when test="$label='display_map'">Мапа</xsl:when>
                    <xsl:when test="$label='display_administrative'">Адміністрування</xsl:when>
                    <xsl:when test="$label='display_visualization'">Відображення</xsl:when>
                    <xsl:when test="$label='display_data-download'">Завантаження даних</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Кількісний аналіз</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Аналіз датування</xsl:when>
                    <xsl:when test="$label='display_contents'">Зміст</xsl:when>
                    <xsl:when test="$label='display_examples'">Об'єкти</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Всі значення</xsl:when>
                    <xsl:when test="$label='results_map-results'">Висвітлити результати на мапі</xsl:when>
                    <xsl:when test="$label='results_filters'">Фільтри</xsl:when>
                    <xsl:when test="$label='results_keyword'">Ключове слово</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Очистити всі значення</xsl:when>
                    <xsl:when test="$label='results_data-options'">Вихідні дані</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Оновити результати</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Швидкий пошук</xsl:when>
                    <xsl:when test="$label='results_has-images'">Містить зображення</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Оновити пошук</xsl:when>
                    <xsl:when test="$label='results_select'">Вибрати зі списку</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Сортувати результати</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Сортувати категорії</xsl:when>
                    <xsl:when test="$label='results_ascending'">За зростанням</xsl:when>
                    <xsl:when test="$label='results_descending'">За зменшенням</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Відображати записи ХХ з YY з ZZ результатів</xsl:when>
                    <xsl:when test="$label='results_coin'">монета</xsl:when>
                    <xsl:when test="$label='results_coins'">монети</xsl:when>
                    <xsl:when test="$label='results_hoard'">скарб</xsl:when>
                    <xsl:when test="$label='results_hoards'">скарби</xsl:when>
                    <xsl:when test="$label='results_and'">та</xsl:when>
                    <xsl:when test="$label='maps_legend'">Легенда</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Типологічний аналіз</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Аналіз вимірювань</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Використати вибір даних і візуалізацію параметрів далі для створення діаграми на основі вибраних параметрів. Інструкції з використання цієї функції можна знайти тут</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Використати функцію, щоб візуалізувати відсотки або числові збіги наступних типологій</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Використати функцію, щоб вирахувати відсотки або кількість монет певної дати в межах скарбів</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Використати функцію для завантаження CSV для даного запиту та обраних скарбів</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Обрати вимірювання</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Тип діаграми</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Обрати категорії для аналізу</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Обрати скарби</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Обрати скарби для порівняння (за бажанням)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Порівняти категорії</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Порівняти з іншими запитами (за бажанням)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Порівняти запити</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Порівняння запита</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Додати користувальницкий запит</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Користувальницький запит</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Видалити запит</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Додати запит</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Додати запити</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Додати новий</xsl:when>
                    <xsl:when test="$label='visualize_query'">Запит</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Фільтрація за списком</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Фільтрація за запитом</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Видалити фільтр</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Додати опис запиту</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Додаткові налаштування</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Ховати/відображати параметри</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Параметри стека</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Виключити захісні коди</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Розташувати по інтервалах (за бажанням)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Інтервал (роки)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Тривалість</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Обчислити вибране</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Створити діаграму</xsl:when>
                    <xsl:when test="$label='numeric_count'">Підрахувати</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Відсотки</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Сукупний</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Сукупний відсоток</xsl:when>
                    <xsl:when test="$label='chart_bar'">Бар</xsl:when>
                    <xsl:when test="$label='chart_column'">Стовпчик</xsl:when>
                    <xsl:when test="$label='chart_area'">Область</xsl:when>
                    <xsl:when test="$label='chart_spline'">Сплайн</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Область сплайна</xsl:when>
                    <xsl:when test="$label='chart_line'">Лінія</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Оповіщення</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Потрібні інтервал та тривалість</xsl:when>
                    <xsl:when test="$label='visualize_error2'">&quot;До дати&quot; повинно бути пізніше за &quot;Від дати&quot;</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Потрібно обрати категорію</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Можна обрати від 1 до 8 скарбів</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Можна обрати більше 8 скарбів</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Можна обрати від 1 до 30 скарбів</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Можна обрати більше 30 скарбів</xsl:when>
                    <xsl:when test="$label='lang_ar'">Арабська</xsl:when>
                    <xsl:when test="$label='lang_bg'">Болгарська</xsl:when>
                    <xsl:when test="$label='lang_da'">Датська</xsl:when>
                    <xsl:when test="$label='lang_de'">Німецька</xsl:when>
                    <xsl:when test="$label='lang_el'">Грецька</xsl:when>
                    <xsl:when test="$label='lang_en'">Англійська</xsl:when>
                    <xsl:when test="$label='lang_es'">Іспанська</xsl:when>
                    <xsl:when test="$label='lang_fi'">Фіннська</xsl:when>
                    <xsl:when test="$label='lang_fr'">Французька</xsl:when>
                    <xsl:when test="$label='lang_he'">Іврит</xsl:when>
                    <xsl:when test="$label='lang_hu'">Угорська</xsl:when>
                    <xsl:when test="$label='lang_it'">Італійська</xsl:when>
                    <xsl:when test="$label='lang_nl'">Голландська</xsl:when>
                    <xsl:when test="$label='lang_nn'">Норвежська</xsl:when>
                    <xsl:when test="$label='lang_pl'">Польська</xsl:when>
                    <xsl:when test="$label='lang_ro'">Румуньська</xsl:when>
                    <xsl:when test="$label='lang_ru'">Російська</xsl:when>
                    <xsl:when test="$label='lang_sv'">Швецька</xsl:when>
                    <xsl:when test="$label='lang_tr'">Турецька</xsl:when>
                    <xsl:when test="$label='lang_uk'">Українська</xsl:when>
                    <xsl:when test="$label='lang_ur'">урду</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='nl'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Start</xsl:when>
                    <xsl:when test="$label='header_about'">Over</xsl:when>
                    <xsl:when test="$label='header_browse'">Bladeren</xsl:when>
                    <xsl:when test="$label='header_search'">Zoeken</xsl:when>
                    <xsl:when test="$label='header_maps'">Kaarten</xsl:when>
                    <xsl:when test="$label='header_compare'">Vergelijken</xsl:when>
                    <xsl:when test="$label='header_symbols'">Symbolen</xsl:when>
                    <xsl:when test="$label='header_language'">Taal</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analyseer schatvondsten</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualiseer zoekvraag</xsl:when>
                    <xsl:when test="$label='display_summary'">Samenvatting</xsl:when>
                    <xsl:when test="$label='display_map'">Kaart</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administratief</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualisatie</xsl:when>
                    <xsl:when test="$label='display_data-download'">Data download</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Kwantitatieve analyse</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Data-analyse</xsl:when>
                    <xsl:when test="$label='display_contents'">Inhoud</xsl:when>
                    <xsl:when test="$label='display_examples'">Voorbeelden van dit type</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Alle termen</xsl:when>
                    <xsl:when test="$label='results_map-results'">Kaartresultaten</xsl:when>
                    <xsl:when test="$label='results_filters'">Filters</xsl:when>
                    <xsl:when test="$label='results_keyword'">Trefwoord</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Alle termen verwijderen</xsl:when>
                    <xsl:when test="$label='results_data-options'">Data-opties</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Verfijn resultaten</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Snel zoeken</xsl:when>
                    <xsl:when test="$label='results_has-images'">Met afbeeldingen</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Verfijn zoeken</xsl:when>
                    <xsl:when test="$label='results_select'">Kies uit lijst</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Sorteer resultaten</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sorteer categorie</xsl:when>
                    <xsl:when test="$label='results_ascending'">Oplopend</xsl:when>
                    <xsl:when test="$label='results_descending'">Aflopend</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Toon records XX tot YY van ZZ resultaten.</xsl:when>
                    <xsl:when test="$label='results_coin'">munt</xsl:when>
                    <xsl:when test="$label='results_coins'">munten</xsl:when>
                    <xsl:when test="$label='results_hoard'">schatvondst</xsl:when>
                    <xsl:when test="$label='results_hoards'">schatvondsten</xsl:when>
                    <xsl:when test="$label='results_and'">en</xsl:when>
                    <xsl:when test="$label='maps_legend'">Legenda</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Typologische analyse</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analyse van de afmetingen</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Gebruik de geselecteerde data en visualiseringsopties benedenaan, om een kaart te genereren op basis van de geselecteerde parameters. Een toelichting om deze functie te gebruiken vindt u hier</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Hiermee worden percentages of absolute aantallen van de volgende typologieën getoond</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Hiermee wordt de aanwezigheid van munten van een specifiek jaar in schatvondsten in percentages of absolute aantallen getoond</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Hiermee kunt u een CSV downloaden met de door u geselecteerde data en geselecteerde schatvondsten</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Selecteer formaat</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Selecteer kaartsoort</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Selecteer analysecategorieën</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Selecteer schatvondsten</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Selecteer schatvondsten om te vergelijken (optioneel)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Vergelijk per categorie</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Vergelijk met andere zoekopdrachten (optioneel)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Vergelijk zoekopdrachten</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Vergelijk zoekopdracht</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Specifieke zoekopdracht toevoegen</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Gedetailleerde zoekopdracht</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Zoekopdracht verwijderen</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Zoekopdracht toevoegen</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Zoekopdrachten toevoegen</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Voeg toe</xsl:when>
                    <xsl:when test="$label='visualize_query'">Zoekopdracht</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filter lijst</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filter zoekopdracht</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Verwijder filter</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Gebruik de drop-down menu's hieronder om de zoekvraag op basis van afmetingen samen te stellen. Per zoekvraag kan alleen één datumbereik worden opgegeven</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Optionele instellingen</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Opties tonen/verbergen</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Stapel opties</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Verwijder veiligheidscodes</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">sorteer per interval (optioneel)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Interval (jaren)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Duur</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Bereken het geselecteerde</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Maak kaart</xsl:when>
                    <xsl:when test="$label='numeric_count'">Tel</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Percentage</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulatief</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Cumulatief percentage</xsl:when>
                    <xsl:when test="$label='chart_bar'">Staaf</xsl:when>
                    <xsl:when test="$label='chart_column'">Kolom</xsl:when>
                    <xsl:when test="$label='chart_area'">Gebied</xsl:when>
                    <xsl:when test="$label='chart_spline'">Gebogen lijn</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Vlak</xsl:when>
                    <xsl:when test="$label='chart_line'">Lijn</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alarm</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Interval en tijd zijn vereist</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Einddatum moet na begindatum liggen</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Selecteer een categorie</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Minimaal 1 van de 8 vondsten moeten zijn geselecteerd</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Maximaal 8 vondsten kunnen worden geselecteerd</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Selecteer minimaal 1 en maximaal 30 vondsten</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Er kunnen maximaal 30 vondsten worden geselecteerd</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabisch</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgarian</xsl:when>
                    <xsl:when test="$label='lang_da'">Deens</xsl:when>
                    <xsl:when test="$label='lang_de'">Duits</xsl:when>
                    <xsl:when test="$label='lang_el'">Grieks</xsl:when>
                    <xsl:when test="$label='lang_en'">Engels</xsl:when>
                    <xsl:when test="$label='lang_es'">Spaans</xsl:when>
                    <xsl:when test="$label='lang_fi'">Fins</xsl:when>
                    <xsl:when test="$label='lang_fr'">Frans</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebreeuws</xsl:when>
                    <xsl:when test="$label='lang_hu'">Hongaars</xsl:when>
                    <xsl:when test="$label='lang_it'">Italiaans</xsl:when>
                    <xsl:when test="$label='lang_nl'">Nederlands</xsl:when>
                    <xsl:when test="$label='lang_nn'">Noors</xsl:when>
                    <xsl:when test="$label='lang_pl'">Pools</xsl:when>
                    <xsl:when test="$label='lang_ro'">Roemeens</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russisch</xsl:when>
                    <xsl:when test="$label='lang_sv'">Zweeds</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turks</xsl:when>
                    <xsl:when test="$label='lang_uk'">Oekraïens</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='sv'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Home</xsl:when>
                    <xsl:when test="$label='header_browse'">Skumma</xsl:when>
                    <xsl:when test="$label='header_search'">Söka</xsl:when>
                    <xsl:when test="$label='header_maps'">Kartor</xsl:when>
                    <xsl:when test="$label='header_compare'">Jämföra</xsl:when>
                    <xsl:when test="$label='header_language'">Språk</xsl:when>
                    <xsl:when test="$label='header_analyze'">Fyndanalys</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualisera sökfrågor</xsl:when>
                    <xsl:when test="$label='display_summary'">Sammanfattning</xsl:when>
                    <xsl:when test="$label='display_map'">Karta</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administrativ</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualisering</xsl:when>
                    <xsl:when test="$label='display_data-download'">nerladdning av data</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Kvantitativ analys</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Data analys</xsl:when>
                    <xsl:when test="$label='display_contents'">Innehåll</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Alla termer</xsl:when>
                    <xsl:when test="$label='results_map-results'">Kartresultat</xsl:when>
                    <xsl:when test="$label='results_filters'">Filter</xsl:when>
                    <xsl:when test="$label='results_keyword'">Träfford</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Rensa alla termer</xsl:when>
                    <xsl:when test="$label='results_data-options'">Data alternativ</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Filtrera resultaten</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Snabb sökning</xsl:when>
                    <xsl:when test="$label='results_has-images'">Bilder tillgängliga</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Filtrera sökningen</xsl:when>
                    <xsl:when test="$label='results_select'">Välja från listan</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Sortera resultaten</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sortera kategorien</xsl:when>
                    <xsl:when test="$label='results_ascending'">Stigande</xsl:when>
                    <xsl:when test="$label='results_descending'">Minskande</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Visa poster XX till YY från ZZ resultater</xsl:when>
                    <xsl:when test="$label='results_coin'">Mynt</xsl:when>
                    <xsl:when test="$label='results_coins'">Mynten</xsl:when>
                    <xsl:when test="$label='results_hoard'">Skattfynd</xsl:when>
                    <xsl:when test="$label='results_hoards'">skattfynder</xsl:when>
                    <xsl:when test="$label='results_and'">och</xsl:when>
                    <xsl:when test="$label='maps_legend'">Omskrift</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabiska</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgariska</xsl:when>
                    <xsl:when test="$label='lang_da'">Danska</xsl:when>
                    <xsl:when test="$label='lang_de'">Tyska</xsl:when>
                    <xsl:when test="$label='lang_el'">Grekiska</xsl:when>
                    <xsl:when test="$label='lang_en'">Engelska</xsl:when>
                    <xsl:when test="$label='lang_es'">Spanska</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finska</xsl:when>
                    <xsl:when test="$label='lang_fr'">Franska</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebreiska</xsl:when>
                    <xsl:when test="$label='lang_hu'">Ungerska</xsl:when>
                    <xsl:when test="$label='lang_it'">Italienska</xsl:when>
                    <xsl:when test="$label='lang_nl'">Nederländska</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norska</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polska</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumänska</xsl:when>
                    <xsl:when test="$label='lang_ru'">Ryska</xsl:when>
                    <xsl:when test="$label='lang_sv'">Svenska</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turkiska</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrainska</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='pl'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Strona startowa</xsl:when>
                    <xsl:when test="$label='header_about'">O nas</xsl:when>
                    <xsl:when test="$label='header_browse'">Przeglądaj</xsl:when>
                    <xsl:when test="$label='header_search'">Szukaj</xsl:when>
                    <xsl:when test="$label='header_maps'">Mapy</xsl:when>
                    <xsl:when test="$label='header_compare'">Porównaj</xsl:when>
                    <xsl:when test="$label='header_language'">Język</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analiza znalezisk skarbów</xsl:when>
                    <xsl:when test="$label='header_visualize'">Wizualizacja kwerend</xsl:when>
                    <xsl:when test="$label='display_summary'">streszczenie</xsl:when>
                    <xsl:when test="$label='display_map'">mapa</xsl:when>
                    <xsl:when test="$label='display_administrative'">administracyjny</xsl:when>
                    <xsl:when test="$label='display_visualization'">wizualizacja</xsl:when>
                    <xsl:when test="$label='display_data-download'">ściąganie danych</xsl:when>
                    <xsl:when test="$label='display_quantitative'">analiza ilościowa</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">analiza datowania</xsl:when>
                    <xsl:when test="$label='display_contents'">treść</xsl:when>
                    <xsl:when test="$label='display_examples'">egzemplarze w tym typie</xsl:when>
                    <xsl:when test="$label='results_all-terms'">wszystkie kategorie</xsl:when>
                    <xsl:when test="$label='results_map-results'">pokaż wyniki na mapie</xsl:when>
                    <xsl:when test="$label='results_filters'">filtruj wyniki wyszukiwania</xsl:when>
                    <xsl:when test="$label='results_keyword'">słowa kluczowe</xsl:when>
                    <xsl:when test="$label='results_clear-all'">wyczyść wszystko</xsl:when>
                    <xsl:when test="$label='results_data-options'">opcje danych</xsl:when>
                    <xsl:when test="$label='results_refine-results'">zawężone wyniki wyszukiwania</xsl:when>
                    <xsl:when test="$label='results_quick-search'">szybkie wyszukiwanie</xsl:when>
                    <xsl:when test="$label='results_has-images'">z obrazkiem</xsl:when>
                    <xsl:when test="$label='results_refine-search'">zawęź wyszukiwanie</xsl:when>
                    <xsl:when test="$label='results_select'">wybierz z listy</xsl:when>
                    <xsl:when test="$label='results_sort-results'">sortuj wyniki wyszukiwania</xsl:when>
                    <xsl:when test="$label='results_sort-category'">sortuj kategorie wyszukiwania</xsl:when>
                    <xsl:when test="$label='results_ascending'">wyniki rosnąco</xsl:when>
                    <xsl:when test="$label='results_descending'">wyniki malejąco</xsl:when>
                    <xsl:when test="$label='results_result-desc'">pokazuje rekordy od XX do YY z wszystkich wyników ZZ</xsl:when>
                    <xsl:when test="$label='results_coin'">moneta</xsl:when>
                    <xsl:when test="$label='results_coins'">monety</xsl:when>
                    <xsl:when test="$label='results_hoard'">skarb</xsl:when>
                    <xsl:when test="$label='results_hoards'">skarby</xsl:when>
                    <xsl:when test="$label='results_and'">i</xsl:when>
                    <xsl:when test="$label='maps_legend'">legenda</xsl:when>
                    <xsl:when test="$label='visualize_typological'">analiza typologiczna</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">analiza metrologiczna</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Użyj opcji wybierania i wizualizacji danych poniżej aby uzyskać wykres oparty na wybranych parametrach. Instrukcje korzystania z tej opcji znajdują się tu</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Użyj tej opcji aby wizualizować procentowe lub liczbowe proporcje dla następujących typów</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Użyj tej opcji aby przedstawić procentowe lub liczbowe proporocje monet o określonym datowaniu w skarbach</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Użyj tej opcji aby ściągnąć dokument CSV dla danej kwerendy i wybranych skarbów</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">wybierz wymiary</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">wybierz typ wykresu</xsl:when>
                    <xsl:when test="$label='visualize_categories'">wybierz kategorie do analizy</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">wybierz skarby</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">wybierz skarby do porównania (opcjonalnie)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">porównaj kategoriami</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">porównaj z innymi kwerendami (opcjonalnie)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">porównaj kwerendy</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">kwerenda porównawcza</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">dodaj kwerendę niestandardową</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">kwerenda niestandardowa</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">usuń kwerendę</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">dodaj kwerendę</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">dodaj kwerendy</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">dodaj nową</xsl:when>
                    <xsl:when test="$label='visualize_query'">kwerenda</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">filtruj wyniki na liście</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">filtruj kwerendę</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">usuń filtr</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Użyj list rozwijanych poniżej aby sformułować swoją kwerendę dotyczącą wymiarów. Zakres dat może być tylko raz określony</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">ustawienia opcjonalne</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">ukryj/pokaż opcje</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">opcje widoku</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">z wyłączeniem kodów trafności</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">organizuj w interwałach</xsl:when>
                    <xsl:when test="$label='visualize_interval'">interwał (w latach)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">czas trwania</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">policz wybrane</xsl:when>
                    <xsl:when test="$label='visualize_generate'">pokaż wykres</xsl:when>
                    <xsl:when test="$label='numeric_count'">policz</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">procent</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">sumarycznie</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">sumarycznie procentowo</xsl:when>
                    <xsl:when test="$label='chart_bar'">wykres kolumnowy</xsl:when>
                    <xsl:when test="$label='chart_column'">kolumna</xsl:when>
                    <xsl:when test="$label='chart_area'">obszar</xsl:when>
                    <xsl:when test="$label='chart_spline'">krzywa</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">krzywa na płaszczyźnie</xsl:when>
                    <xsl:when test="$label='chart_line'">linia</xsl:when>
                    <xsl:when test="$label='visualize_alert'">alert</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Interwał i czas trwania wymagane.</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Data do nie może być wcześniejsza niż data od</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Należy wybrać kategorię.</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Wybrać można co najmniej 1 i nie więcej niż 8 skarbów.</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Wybrać można do 8 skarbów.</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Wybrać można co najmniej 1 i nie więcej niż 30 skarbów.</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Wybrać można do 30 skarbów.</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabski</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bułgarski</xsl:when>
                    <xsl:when test="$label='lang_da'">Duński</xsl:when>
                    <xsl:when test="$label='lang_de'">Niemiecki</xsl:when>
                    <xsl:when test="$label='lang_el'">Grecki</xsl:when>
                    <xsl:when test="$label='lang_en'">Angielski</xsl:when>
                    <xsl:when test="$label='lang_es'">Hiszpański</xsl:when>
                    <xsl:when test="$label='lang_fi'">Fiński</xsl:when>
                    <xsl:when test="$label='lang_fr'">Francuski</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebrajski</xsl:when>
                    <xsl:when test="$label='lang_hu'">Węgierski</xsl:when>
                    <xsl:when test="$label='lang_it'">Włoski</xsl:when>
                    <xsl:when test="$label='lang_nl'">Holenderski</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norweski</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polski</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumuński</xsl:when>
                    <xsl:when test="$label='lang_ru'">Rosyjski</xsl:when>
                    <xsl:when test="$label='lang_sv'">Szwedzki</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turecki</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukraiński</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='it'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Pagina iniziale</xsl:when>
                    <xsl:when test="$label='header_browse'">Sfoglia</xsl:when>
                    <xsl:when test="$label='header_search'">Cerca</xsl:when>
                    <xsl:when test="$label='header_maps'">Mappe</xsl:when>
                    <xsl:when test="$label='header_compare'">Confronta</xsl:when>
                    <xsl:when test="$label='header_symbols'">Simboli</xsl:when>
                    <xsl:when test="$label='header_language'">Lingua</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analisi dei ripostigli</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualizza</xsl:when>
                    <xsl:when test="$label='display_summary'">Sommario</xsl:when>
                    <xsl:when test="$label='display_map'">Mappa</xsl:when>
                    <xsl:when test="$label='display_administrative'">Amministrativo</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualizzazione</xsl:when>
                    <xsl:when test="$label='display_data-download'">Scarica i dati</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Analisi quantitativa</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Analizza i dati</xsl:when>
                    <xsl:when test="$label='display_contents'">Sommario</xsl:when>
                    <xsl:when test="$label='display_examples'"> Esempi</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Tutti i termini</xsl:when>
                    <xsl:when test="$label='results_map-results'">Risultati geografici</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtri</xsl:when>
                    <xsl:when test="$label='results_keyword'">Parola chiave</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Azzera tutti i termini</xsl:when>
                    <xsl:when test="$label='results_data-options'">Opzioni dei dati</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Affina i risultati</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Ricerca veloce</xsl:when>
                    <xsl:when test="$label='results_has-images'">Immagini disponibili</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Raffina la ricerca</xsl:when>
                    <xsl:when test="$label='results_select'">Seleziona dalla lista</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Ordina i risultati</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Ordina la categoria</xsl:when>
                    <xsl:when test="$label='results_ascending'">Ordine crescente</xsl:when>
                    <xsl:when test="$label='results_descending'">Ordine decrescente</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Esporre i risultati da XX a YY su un totale di ZZ risultati</xsl:when>
                    <xsl:when test="$label='results_coin'">moneta</xsl:when>
                    <xsl:when test="$label='results_coins'">monete</xsl:when>
                    <xsl:when test="$label='results_hoard'">ripostiglio</xsl:when>
                    <xsl:when test="$label='results_hoards'">ripostigli</xsl:when>
                    <xsl:when test="$label='results_and'">e</xsl:when>
                    <xsl:when test="$label='maps_legend'">Legenda</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Analisi tipologica</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analisi dimensionale</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Utilizza le opzioni per la selezione e visualizzazione dei dati in basso per creare un grafico basato sui parametri selezionati. Le istruzioni per utilizzare questa funzione si possono consultare qui.</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Utilizza questa funzione per visualizzare le percentuali o le frequenze numeriche di queste tipologie.</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Utilizza questa funzione per rappresentare le percentuali o le frequenze numeriche di monete con una datazione specifica all'interno dei ripostigli.</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Utilizza questa funzione per scaricare CSV (valori separati da virgola) relativi alla query considerata e ai ripostigli selezionati.</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Seleziona dimensioni</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Seleziona tipo di grafico</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Seleziona categorie per le analisi</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Seleziona ripostigli</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Seleziona ripostigli per confrontare (opzionale)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Confronta per categoria</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Confronta con altre queries</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Confronta queries</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Query di confronto</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Aggiungi queries modificate</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Query modificata</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Rimuovi query</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Aggiungi query</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Aggiungi queries</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Aggiungi nuovo</xsl:when>
                    <xsl:when test="$label='visualize_query'">Query</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filtra l'elenco</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filtra la query</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Rimuovi il filtro</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Usa i menu a tendina qui sotto per elaborare la tua query di misura. Un arco cronologico può essere specificato una sola volta per ogni query.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Configurazioni opzionali</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Nascondi/mostra opzioni</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Opzioni per l'organizzazione</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Escludi i codici di sicurezza</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Organizza per periodo (opzionale)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Periodo (anni)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Durata</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Calcola la selezione</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Crea grafico</xsl:when>
                    <xsl:when test="$label='numeric_count'">Conta</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Percentuale</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulativo</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Percentuale cumulativa</xsl:when>
                    <xsl:when test="$label='chart_bar'">Barra</xsl:when>
                    <xsl:when test="$label='chart_column'">Colonna</xsl:when>
                    <xsl:when test="$label='chart_area'">Area</xsl:when>
                    <xsl:when test="$label='chart_spline'">Curva spline</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Curva spline areale</xsl:when>
                    <xsl:when test="$label='chart_line'">Linea</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Allerta</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Il periodo e la durata sono richiesti</xsl:when>
                    <xsl:when test="$label='visualize_error2'">La data finale dev'essere successiva alla data iniziale</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Dev'essere selezionata una categoria</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Possono essere selezionati da un minimo di 1 fino a un massimo di 8 ripostigli</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Possono essere selezionati fino a un massimo di 8 ripostigli</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Possono essere selezionati da un minimo di 1 fino a un massimo di 30 ripostigli</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Possono essere selezionati fino a un massimo di 30 ripostigli</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabo</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgaro</xsl:when>
                    <xsl:when test="$label='lang_da'">Danese</xsl:when>
                    <xsl:when test="$label='lang_de'">Tedesco</xsl:when>
                    <xsl:when test="$label='lang_el'">Greco</xsl:when>
                    <xsl:when test="$label='lang_en'">Inglese</xsl:when>
                    <xsl:when test="$label='lang_es'">Spagnolo</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finlandese</xsl:when>
                    <xsl:when test="$label='lang_fr'">Francese</xsl:when>
                    <xsl:when test="$label='lang_he'">Ebraico</xsl:when>
                    <xsl:when test="$label='lang_hu'">Ungherese</xsl:when>
                    <xsl:when test="$label='lang_it'">Italiano</xsl:when>
                    <xsl:when test="$label='lang_nl'">Olandese</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norvegese</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polacco</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumeno</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russo</xsl:when>
                    <xsl:when test="$label='lang_sv'">Svedese</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turco</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ucraino</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='tr'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Ana Sayfa</xsl:when>
                    <xsl:when test="$label='header_about'">Hakkında</xsl:when>
                    <xsl:when test="$label='header_browse'">Göz At</xsl:when>
                    <xsl:when test="$label='header_search'">Arama</xsl:when>
                    <xsl:when test="$label='header_maps'">Haritalar</xsl:when>
                    <xsl:when test="$label='header_compare'">Karşılaştır</xsl:when>
                    <xsl:when test="$label='header_symbols'">Semboller</xsl:when>
                    <xsl:when test="$label='header_language'">Dil</xsl:when>
                    <xsl:when test="$label='header_analyze'">Defineleri Analiz et</xsl:when>
                    <xsl:when test="$label='header_visualize'">Sorguları Görselleştir</xsl:when>
                    <xsl:when test="$label='display_summary'">Özet</xsl:when>
                    <xsl:when test="$label='display_map'">Harita</xsl:when>
                    <xsl:when test="$label='display_administrative'">Yönetim</xsl:when>
                    <xsl:when test="$label='display_visualization'">Görseller</xsl:when>
                    <xsl:when test="$label='display_data-download'">Veri İndir</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Nicel Analiz</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Tarih Analizi</xsl:when>
                    <xsl:when test="$label='display_contents'">İçindekieler</xsl:when>
                    <xsl:when test="$label='display_examples'">Bu Tipin Örnekleri</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Tüm Terimler</xsl:when>
                    <xsl:when test="$label='results_map-results'">Sonuçları Haritala</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtreler</xsl:when>
                    <xsl:when test="$label='results_keyword'">Anahtar Kelime</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Tüm Terimleri Temizle</xsl:when>
                    <xsl:when test="$label='results_data-options'">Veri Seçenekeleri</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Sonuçları Daralt</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Hızlı Arama</xsl:when>
                    <xsl:when test="$label='results_has-images'">Resimli</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Aramayı Daralt</xsl:when>
                    <xsl:when test="$label='results_select'">Listeden Seç</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Sonuçları Sırala</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sıralama Kategorisi</xsl:when>
                    <xsl:when test="$label='results_ascending'">Artan</xsl:when>
                    <xsl:when test="$label='results_descending'">Azalan</xsl:when>
                    <xsl:when test="$label='results_result-desc'">XX'ten YY'ye ZZ'nin tüm Sonuçları Gösteriliyor</xsl:when>
                    <xsl:when test="$label='results_coin'">Sikke</xsl:when>
                    <xsl:when test="$label='results_coins'">Sikkeler</xsl:when>
                    <xsl:when test="$label='results_hoard'">Define</xsl:when>
                    <xsl:when test="$label='results_hoards'">Defineler</xsl:when>
                    <xsl:when test="$label='results_and'">ve</xsl:when>
                    <xsl:when test="$label='maps_legend'">Lejand</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Tipolojik Analiz</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Ölçüm Analizi</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Seçilen Parametrelere Dayalı bir Grafik Oluşturmak için Aşağıdaki Veri Seçimi ve Görselleştirme Seçenekleri Kullanın. Bu Özelliği Kullanmak için Talimatları Burada Bulabilirsiniz</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Takip eden Tipolojilerdeki Yüzdelik veya Sayısal Oluşumları Görselleştirmek İçin bu Özelliği Kullanın</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Defineler İçindeki Belirli bir Tarihteki Yüzdelik veya Sayısal Oluşumları İşlemek İçin bu Özelliği Kullanın</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Yapılan Sorgu ve Seçilen Defineleri CSV Olarak İndirmek İçin bu Özelliği Seçin</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Ölçü Seç</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Tablo Tipi Seç</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Analiz İçin Kategorileri Seç</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Defineleri Seç</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Karşılaştırma İçin Defineleri Seç (İsteğe Bağlı)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Kategoriye göre Karşılaştır</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Diğer Sorgularla Karşılaştır (isteğe bağlı)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Sorguları Karşılaştır</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Karşılaştırma Sorgusu</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Özel Sorgu Ekle</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Özel Sorgu</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Sorguyu Kaldır</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Sorgu Ekle</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Sorgular Ekle</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Yeni Ekle</xsl:when>
                    <xsl:when test="$label='visualize_query'">Sorgu</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filtre Listesi</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Sorguyu Filtrele</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Filtreleri Kaldır</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Ölçüm sorgusunu formüle etmek için açılır menüleri kullanın. Bir tarih aralığı sorgu başına sadece bir kez belirtilebilir.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">İsteğe bağlı seçenekeler</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Seçenekleri gizle/göster</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Depolama seçenekleri</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Kesinlik kodunu kaldır</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Aralığı düzenleyin (isteğe bağlı)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Aralık (yıl)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Süre</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Seçileni hesapla</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Grafik Oluştur</xsl:when>
                    <xsl:when test="$label='numeric_count'">Sayım</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Yüzde</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Kümilatif</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Kümilatif Yüzde</xsl:when>
                    <xsl:when test="$label='chart_bar'">Çizgi</xsl:when>
                    <xsl:when test="$label='chart_column'">Sütun</xsl:when>
                    <xsl:when test="$label='chart_area'">Alan</xsl:when>
                    <xsl:when test="$label='chart_spline'">Eğri</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Alan Eğrisi</xsl:when>
                    <xsl:when test="$label='chart_line'">Çizgi</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alarm</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Aralık ve süre gereklidir.</xsl:when>
                    <xsl:when test="$label='visualize_error2'">...-e kadar tarihi, ...-den tarihinden daha sonra olmalıdır.</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Bir kategori seçilmeli.</xsl:when>
                    <xsl:when test="$label='visualize_error4'">En az 1 en fazla 8 define seçilebilir.</xsl:when>
                    <xsl:when test="$label='visualize_error5'">8 defineye kadar seçilebilir.</xsl:when>
                    <xsl:when test="$label='visualize_error6'">En az 1 en fazla 30 define seçilebilir.</xsl:when>
                    <xsl:when test="$label='visualize_error7'">30 defineye kadar seçilebilir.</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arapça</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgarca</xsl:when>
                    <xsl:when test="$label='lang_da'">Danca</xsl:when>
                    <xsl:when test="$label='lang_de'">Almanca</xsl:when>
                    <xsl:when test="$label='lang_el'">Yunanca</xsl:when>
                    <xsl:when test="$label='lang_en'">İngilizce</xsl:when>
                    <xsl:when test="$label='lang_es'">İspanyolca</xsl:when>
                    <xsl:when test="$label='lang_fi'">Fince</xsl:when>
                    <xsl:when test="$label='lang_fr'">Fransızca</xsl:when>
                    <xsl:when test="$label='lang_he'">İbranice</xsl:when>
                    <xsl:when test="$label='lang_hu'">Macarca</xsl:when>
                    <xsl:when test="$label='lang_it'">İtalyanca</xsl:when>
                    <xsl:when test="$label='lang_nl'">Flemenkçe</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norveççe</xsl:when>
                    <xsl:when test="$label='lang_pl'">Lehçe</xsl:when>
                    <xsl:when test="$label='lang_ro'">Romence</xsl:when>
                    <xsl:when test="$label='lang_ru'">Rusça</xsl:when>
                    <xsl:when test="$label='lang_sv'">İsveççe</xsl:when>
                    <xsl:when test="$label='lang_tr'">Türkçe</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrayna</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urduca</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='fi'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">kotisivu/aloistussivu</xsl:when>
                    <xsl:when test="$label='header_about'">Tietoa....-sta (e.g. tietoa Numisma.orgista)</xsl:when>
                    <xsl:when test="$label='header_browse'">selailu</xsl:when>
                    <xsl:when test="$label='header_search'">haku</xsl:when>
                    <xsl:when test="$label='header_maps'">kartat</xsl:when>
                    <xsl:when test="$label='header_compare'">vertaa</xsl:when>
                    <xsl:when test="$label='header_symbols'">symbolit</xsl:when>
                    <xsl:when test="$label='header_language'">kieli</xsl:when>
                    <xsl:when test="$label='header_analyze'">analysoi rahakätköjä/ tutki rahakätköjä</xsl:when>
                    <xsl:when test="$label='header_visualize'">havainnollista haut</xsl:when>
                    <xsl:when test="$label='display_summary'">yhteenveto/tiivistelmä</xsl:when>
                    <xsl:when test="$label='display_map'">kartta</xsl:when>
                    <xsl:when test="$label='display_administrative'">hallinto/hallinnallinen</xsl:when>
                    <xsl:when test="$label='display_visualization'">visualisointi/havainnollistaminen</xsl:when>
                    <xsl:when test="$label='display_data-download'">tietojen lataus</xsl:when>
                    <xsl:when test="$label='display_quantitative'">kvantitatiivinen analyysi/kvantitatiivinen tutkimus</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">päivämäärä analyysi</xsl:when>
                    <xsl:when test="$label='display_contents'">sisältö</xsl:when>
                    <xsl:when test="$label='display_examples'">Esimerkkejä tämäntyyppisistä esineistä/ esimerkkejä tälläisesta</xsl:when>
                    <xsl:when test="$label='results_all-terms'">kaikki termit/ kaikki hakusanat</xsl:when>
                    <xsl:when test="$label='results_map-results'">karttahaun tulokset</xsl:when>
                    <xsl:when test="$label='results_filters'">suodatin?</xsl:when>
                    <xsl:when test="$label='results_keyword'">Hakusana</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Poista kaikki hakusanat</xsl:when>
                    <xsl:when test="$label='results_data-options'">datan vaihtoehdot/tietojen vaihtoehdot</xsl:when>
                    <xsl:when test="$label='results_refine-results'">tarkenna halutuloksia</xsl:when>
                    <xsl:when test="$label='results_quick-search'">pikahaku</xsl:when>
                    <xsl:when test="$label='results_has-images'">sisältää kuvia</xsl:when>
                    <xsl:when test="$label='results_refine-search'">tarkenna hakusanoja</xsl:when>
                    <xsl:when test="$label='results_select'">valitse listasta</xsl:when>
                    <xsl:when test="$label='results_sort-results'">lajittele tulokset/järjestele tulokset</xsl:when>
                    <xsl:when test="$label='results_sort-category'">lajittele kategoria/ lajittele luokka</xsl:when>
                    <xsl:when test="$label='results_ascending'">nouseva</xsl:when>
                    <xsl:when test="$label='results_descending'">laskeva</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Näyttää merkinnät XX - YY ZZ:sta (e.g. 5-10 100:sta)</xsl:when>
                    <xsl:when test="$label='results_coin'">kolikko, metalliraha</xsl:when>
                    <xsl:when test="$label='results_coins'">kolikot, metallirahat</xsl:when>
                    <xsl:when test="$label='results_hoard'">rahakätkö</xsl:when>
                    <xsl:when test="$label='results_hoards'">rahakätköt</xsl:when>
                    <xsl:when test="$label='results_and'">ja</xsl:when>
                    <xsl:when test="$label='maps_legend'">legenda? kuvateksti?</xsl:when>
                    <xsl:when test="$label='visualize_typological'">typologinen analyysi/typologinen tutkimus</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">mittauksen analyysi/ mittauksen tutkimus</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Voit käytää alla olevia vaihtoehtoja luodaksesi valittujen rajoituksien tuottaman diagrammin. Neuvoja löydät täältä</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Havainnollista näiden typologioiden ilmenemisprosentit tai numerot diagrammina</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Havainnollista näiden typologioiden ilmenemisprosentit tai numerot tietyissa rahakätköissä diagrammina</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Lataa tiettyihin rahakätköihin rajoitettujen tiettyjen hakujen  hakutuloksien tiedot</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">valitse mitat</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">valitse taulukkotyyppi</xsl:when>
                    <xsl:when test="$label='visualize_categories'">valitse kategoriat analyysiin/valitse luokat tutkimukseen</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">valitse rahakätkö</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">valitse rahakätköt vartailuun (vapaaehtoinen)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">vertaa kategorioittain/vertaa luokittain</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">vertaa toisiin hakuihin (vapaaehtoinen)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">vertaa hakuja</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">vertailuhaku?</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">lisää tilaushaku?</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">tilaushaku?</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">poista haku</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">lisää haku</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">lisää hakuja</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">lisää uusi</xsl:when>
                    <xsl:when test="$label='visualize_query'">haku</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">suodatinlista</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">suodattava haku</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">poista suodatin</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Käytä pudotusvalikkoja mittahaun luomiseen. Ajanjakson voi määrittää vain kerran joka haulle.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">vaihtoehtoiset asetukset</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Piilota/näytä vaihtoehdot</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Kokoamisvaihtoehdot?</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Jätä tietyt koodit pois</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Järjestä aikakausittain</xsl:when>
                    <xsl:when test="$label='visualize_interval'">aikaväli</xsl:when>
                    <xsl:when test="$label='visualize_duration'">kesto</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">laske valittu</xsl:when>
                    <xsl:when test="$label='visualize_generate'">luo diagrammi</xsl:when>
                    <xsl:when test="$label='numeric_count'">lasku? määrä?</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">prosentti</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">kumulatiivinen</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">kumulatiivinen prosentti</xsl:when>
                    <xsl:when test="$label='chart_bar'">pylväs (e.g. pylväsdiagrammi for barchart)</xsl:when>
                    <xsl:when test="$label='chart_column'">sarake</xsl:when>
                    <xsl:when test="$label='chart_area'">alue</xsl:when>
                    <xsl:when test="$label='chart_spline'">??kaariviiva?</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">aluekaariviiva?</xsl:when>
                    <xsl:when test="$label='chart_line'">rivi</xsl:when>
                    <xsl:when test="$label='visualize_alert'">hälyytys</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Lisää aikaväli ja kesto</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Loppumispäiväärän on oltava myöhemmin kuin aloituspäivämäärän.</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Valitse luokka/valitse kategoria</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Valitse yhdestä kahdeksaan rahakätköä/ Valitse 1-8 rahakätköä</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Voit valita enintään 8 rahakätköä.</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Ainakin 1, ja enintään 30 rahakätköä valittavissa.</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Voit valita enintään 30 rahakätköä.</xsl:when>
                    <xsl:when test="$label='lang_ar'">arabia/arabian kieli</xsl:when>
                    <xsl:when test="$label='lang_bg'">bulgaria</xsl:when>
                    <xsl:when test="$label='lang_da'">tanska</xsl:when>
                    <xsl:when test="$label='lang_de'">saksa</xsl:when>
                    <xsl:when test="$label='lang_el'">kreikka</xsl:when>
                    <xsl:when test="$label='lang_en'">englanti</xsl:when>
                    <xsl:when test="$label='lang_es'">espanja</xsl:when>
                    <xsl:when test="$label='lang_fi'">suomi</xsl:when>
                    <xsl:when test="$label='lang_fr'">ranska</xsl:when>
                    <xsl:when test="$label='lang_he'">heprealainen</xsl:when>
                    <xsl:when test="$label='lang_hu'">unkarin kieli</xsl:when>
                    <xsl:when test="$label='lang_it'">italia</xsl:when>
                    <xsl:when test="$label='lang_nl'">hollanti</xsl:when>
                    <xsl:when test="$label='lang_nn'">norja</xsl:when>
                    <xsl:when test="$label='lang_pl'">puola</xsl:when>
                    <xsl:when test="$label='lang_ro'">romania</xsl:when>
                    <xsl:when test="$label='lang_ru'">venäjä</xsl:when>
                    <xsl:when test="$label='lang_sv'">ruotsi</xsl:when>
                    <xsl:when test="$label='lang_tr'">turkki</xsl:when>
                    <xsl:when test="$label='lang_uk'">ukraina</xsl:when>
                    <xsl:when test="$label='lang_ur'">urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='da'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Forside</xsl:when>
                    <xsl:when test="$label='header_about'">Om</xsl:when>
                    <xsl:when test="$label='header_browse'">Browse</xsl:when>
                    <xsl:when test="$label='header_search'">Søg</xsl:when>
                    <xsl:when test="$label='header_maps'">Kort</xsl:when>
                    <xsl:when test="$label='header_compare'">Sammenlign</xsl:when>
                    <xsl:when test="$label='header_symbols'">Symboler</xsl:when>
                    <xsl:when test="$label='header_language'">Sprog</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analyse af skattefund</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualisering af søgning</xsl:when>
                    <xsl:when test="$label='display_summary'">Sammenfatning</xsl:when>
                    <xsl:when test="$label='display_map'">Kort</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administrativ</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualisering</xsl:when>
                    <xsl:when test="$label='display_data-download'">Download data</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Kvantitativ analyse</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Dateringsanalyse</xsl:when>
                    <xsl:when test="$label='display_contents'">Indhold</xsl:when>
                    <xsl:when test="$label='display_examples'">Eksempler på typen</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Alle begreber</xsl:when>
                    <xsl:when test="$label='results_map-results'">Kartering</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtre</xsl:when>
                    <xsl:when test="$label='results_keyword'">Nøgleord</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Rens alle</xsl:when>
                    <xsl:when test="$label='results_data-options'">Alternative data</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Filtrer resultater</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Hurtig søgning</xsl:when>
                    <xsl:when test="$label='results_has-images'">Tilgængelige fotos</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Filtrer søgning</xsl:when>
                    <xsl:when test="$label='results_select'">Vælg fra liste</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Sorter resultater</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sorter kategorier</xsl:when>
                    <xsl:when test="$label='results_ascending'">Voksende</xsl:when>
                    <xsl:when test="$label='results_descending'">Faldende</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Vis posterne XX til YY fra ZZ resultater</xsl:when>
                    <xsl:when test="$label='results_coin'">Mønt</xsl:when>
                    <xsl:when test="$label='results_coins'">Mønter</xsl:when>
                    <xsl:when test="$label='results_hoard'">Skattefund</xsl:when>
                    <xsl:when test="$label='results_hoards'">Skattefund</xsl:when>
                    <xsl:when test="$label='results_and'">og</xsl:when>
                    <xsl:when test="$label='maps_legend'">indskrift/omskrift</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Typologisk analyse</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Analyser mål</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Anvend de udvalgte data og visualiseringsmulighederne nedenfor til at danne en grafisk fremstilling baseret på udvalgte parametre. Se instruktioner her </xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Brug dette redskab til at visualisere procenter eller absolutte tal for forekomster af de følgende typer </xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Brug dette redskab til at gengive procenter eller antal af forekomster af mønter fra en bestemt periode i skatte </xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Brug dette redskab til download af CSV for søgningen og udvalgte skattefund </xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Vælg mål</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Vælg diagramtype</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Udvælg kategorier til analyse</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Vælg skatte</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Vælg skatte til sammenligning (valgfri)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Sammenlign kategorier</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Sammenlign med andre forespørgsler (valgfri) </xsl:when>
                    <xsl:when test="$label='visualize_compare'">Sammenlign forespørgsler</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Sammenligningsforespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Tilføj særlige forespørgsler</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Særlige forespørgsler</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Fjern forespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Tilføj forespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Tilføj forespørgsler</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Tilføj ny</xsl:when>
                    <xsl:when test="$label='visualize_query'">Forespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filtre</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filtrer forespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Fjern filter</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Anvend menyerne nedenfor til at formulere forespørgsler om mål. Der kan kun defineres en periode pr. forespørgsel</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Valgfrie indstillinger</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Gem/vis</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Organisering</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Udelad sikkerhedskoder</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Arranger efter periode (valgfri)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Periode (år)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Varighed</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Beregn udvalgte</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Beregn diagram</xsl:when>
                    <xsl:when test="$label='numeric_count'">Optælling</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Procent</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Akkumuleret</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Akkumuleret procent</xsl:when>
                    <xsl:when test="$label='chart_bar'">søjle (liggende)</xsl:when>
                    <xsl:when test="$label='chart_column'">sølje</xsl:when>
                    <xsl:when test="$label='chart_area'">område</xsl:when>
                    <xsl:when test="$label='chart_spline'">spline</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">område spline</xsl:when>
                    <xsl:when test="$label='chart_line'">linje</xsl:when>
                    <xsl:when test="$label='visualize_alert'">alarm</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Periode og varighed kræves</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Til Dato skal være senere end Fra Dato.</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Vælg en kategori</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Vælg fra 1 til 8 skattefund</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Op til 8 skattefund kan vælges</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Vælg fra 1 til 30 skattefund</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Op til 30 skattefund kan vælges</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabisk</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgarsk</xsl:when>
                    <xsl:when test="$label='lang_da'">Dansk</xsl:when>
                    <xsl:when test="$label='lang_de'">Tysk</xsl:when>
                    <xsl:when test="$label='lang_el'">Græsk</xsl:when>
                    <xsl:when test="$label='lang_en'">Engelsk</xsl:when>
                    <xsl:when test="$label='lang_es'">Spansk</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finsk</xsl:when>
                    <xsl:when test="$label='lang_fr'">Fransk</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebraisk</xsl:when>
                    <xsl:when test="$label='lang_hu'">Ungarsk</xsl:when>
                    <xsl:when test="$label='lang_it'">Italiensk</xsl:when>
                    <xsl:when test="$label='lang_nl'">Hollandsk</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norsk</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polsk</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumænsk</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russisk</xsl:when>
                    <xsl:when test="$label='lang_sv'">Svensk</xsl:when>
                    <xsl:when test="$label='lang_tr'">Tyrkisk</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrainsk</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='hu'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Otthon</xsl:when>
                    <xsl:when test="$label='header_about'">Rólunk</xsl:when>
                    <xsl:when test="$label='header_browse'">Bőngészés</xsl:when>
                    <xsl:when test="$label='header_search'">Keresés</xsl:when>
                    <xsl:when test="$label='header_maps'">Térképek</xsl:when>
                    <xsl:when test="$label='header_compare'">Összehasonlítás</xsl:when>
                    <xsl:when test="$label='header_symbols'">Szimbólumok</xsl:when>
                    <xsl:when test="$label='header_language'">Nyelv</xsl:when>
                    <xsl:when test="$label='header_analyze'">Kincslelet elemzés</xsl:when>
                    <xsl:when test="$label='header_visualize'">Lekérdezések megjelenítése</xsl:when>
                    <xsl:when test="$label='display_summary'">Összefoglalás</xsl:when>
                    <xsl:when test="$label='display_map'">Térkép</xsl:when>
                    <xsl:when test="$label='display_administrative'">Közigazgatási</xsl:when>
                    <xsl:when test="$label='display_visualization'">Megjelenítés</xsl:when>
                    <xsl:when test="$label='display_data-download'">Adatok letöltése</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Mennyiségi elemzés</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Keltezés elemzés</xsl:when>
                    <xsl:when test="$label='display_contents'">Tartalom</xsl:when>
                    <xsl:when test="$label='display_examples'">Típus példa</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Összes feltétel</xsl:when>
                    <xsl:when test="$label='results_map-results'">Térkép eredmények</xsl:when>
                    <xsl:when test="$label='results_filters'">Szűrők</xsl:when>
                    <xsl:when test="$label='results_keyword'">Kulcsszó</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Összes feltételek törlése</xsl:when>
                    <xsl:when test="$label='results_data-options'">Adat opciók</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Eredmények szűkítése</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Gyors keresés</xsl:when>
                    <xsl:when test="$label='results_has-images'">Fellelhető képek</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Keresés szűkítése</xsl:when>
                    <xsl:when test="$label='results_select'">Válasszon a listából</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Eredmények rendezése</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Kategóriák rendezése</xsl:when>
                    <xsl:when test="$label='results_ascending'">Növekvő</xsl:when>
                    <xsl:when test="$label='results_descending'">Csökkenő</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Bejegyzések megjelenítése XX-től YY-ig ZZ összes eredményből.</xsl:when>
                    <xsl:when test="$label='results_coin'">érme</xsl:when>
                    <xsl:when test="$label='results_coins'">érmék</xsl:when>
                    <xsl:when test="$label='results_hoard'">kincslelet</xsl:when>
                    <xsl:when test="$label='results_hoards'">kincsleletek</xsl:when>
                    <xsl:when test="$label='results_and'">és</xsl:when>
                    <xsl:when test="$label='maps_legend'">Felirat</xsl:when>
                    <xsl:when test="$label='visualize_typological'">tipológiai elemzés</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">méret elemzés</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Használja a kiválasztott adatokat és az alábbi megjelenítési lehetőségeket, hogy létrehozz egy kiválasztott paramétereken alapuló táblázatot. Itt talál útmutatót a funkció használatáról</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Használja ezt a funkciót, hogy meghatározza a százalékos vagy numerikus előfordulását a következő tipológiáknak</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Használja ezt a funkciót a kincsleleten belül az érmek százalékos vagy numerikus előfordulásának meghatározására egy adott időpontban</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Használja ezt a funkciót, hogy a megadott lekérdezés és a kiválasztott kincslelethez letöltsön egy CSV-t</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Méretek kiválasztása</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Diagram típus kiválasztása</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Kategóriák kiválasztása az elemzéshez</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Kincsleletek kiválasztása</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Kincsleletek kiválasztása összehasonlítás céljából (választható)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Összehasonlítás kategória szerint</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Összehasonlítás más lekérdezésekkel (választható)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Lekérdezések összehasonlítása</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Lekérdezés összehasonlítása</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Specifikus lekérdezések hozzáadása</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Specifikus lekérdezés</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Lekérdezés eltávolítása</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Lekérdezés hozzáadása</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Lekérdezések hozzáadása</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Új hozzáadása</xsl:when>
                    <xsl:when test="$label='visualize_query'">Lekérdezés</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">szűrőlista</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">szűrő lekérdezés</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">szűrő eltávolítása</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Használja az alábbi legördülő menüt a mérés lekérdezés megfogalmazásához. Dátumtartományok csak egyszer adhatók meg egy lekérdezés során.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Választható beállítások</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Lehetéségek megmutatása / elrejtése</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Egymásra halmozott lehetőségek</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Bizonyos kódok kizárása</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Elrendezés Intervallum szerint (nem kötelező)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Intervallum (év)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Időtartam</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Kiválasztottak számolása</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Diagram létrehozás</xsl:when>
                    <xsl:when test="$label='numeric_count'">Számol</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Százalék</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Halmozott</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Halmozott százalék</xsl:when>
                    <xsl:when test="$label='chart_bar'">mező</xsl:when>
                    <xsl:when test="$label='chart_column'">oszlop</xsl:when>
                    <xsl:when test="$label='chart_area'">terület</xsl:when>
                    <xsl:when test="$label='chart_spline'">(grafikon) görbe</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">areaspline</xsl:when>
                    <xsl:when test="$label='chart_line'">vonal</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Figyelmeztetés</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Szükség van intervallumra és időtartamra.</xsl:when>
                    <xsl:when test="$label='visualize_error2'">A befejezési dátumnak a kezdő dátum után kell lennie</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Ki kell választani egy kategóriát</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Legalább 1, legfeljebb 8 kincslelet választható ki</xsl:when>
                    <xsl:when test="$label='visualize_error5'">legfeljebb 8 kincslelet választható ki</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Legalább 1, legfeljebb 30 kincslelet választható ki</xsl:when>
                    <xsl:when test="$label='visualize_error7'">legfeljebb 30 kincslelet választható ki</xsl:when>
                    <xsl:when test="$label='lang_ar'">arab</xsl:when>
                    <xsl:when test="$label='lang_bg'">bolgár</xsl:when>
                    <xsl:when test="$label='lang_da'">dán</xsl:when>
                    <xsl:when test="$label='lang_de'">német</xsl:when>
                    <xsl:when test="$label='lang_el'">görög</xsl:when>
                    <xsl:when test="$label='lang_en'">angol</xsl:when>
                    <xsl:when test="$label='lang_es'">spanyol</xsl:when>
                    <xsl:when test="$label='lang_fi'">finn</xsl:when>
                    <xsl:when test="$label='lang_fr'">francia</xsl:when>
                    <xsl:when test="$label='lang_he'">héber</xsl:when>
                    <xsl:when test="$label='lang_hu'">magyar</xsl:when>
                    <xsl:when test="$label='lang_it'">olasz</xsl:when>
                    <xsl:when test="$label='lang_nl'">holland</xsl:when>
                    <xsl:when test="$label='lang_nn'">norvég</xsl:when>
                    <xsl:when test="$label='lang_pl'">lengyel</xsl:when>
                    <xsl:when test="$label='lang_ro'">román</xsl:when>
                    <xsl:when test="$label='lang_ru'">orosz</xsl:when>
                    <xsl:when test="$label='lang_sv'">svéd</xsl:when>
                    <xsl:when test="$label='lang_tr'">török</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrán</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='el'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Αφετηρία</xsl:when>
                    <xsl:when test="$label='header_about'">Πληροφορίες</xsl:when>
                    <xsl:when test="$label='header_browse'">Περιήγηση</xsl:when>
                    <xsl:when test="$label='header_search'">Αναζήτηση</xsl:when>
                    <xsl:when test="$label='header_maps'">Χάρτες</xsl:when>
                    <xsl:when test="$label='header_compare'">Αντιπαραβολή</xsl:when>
                    <xsl:when test="$label='header_symbols'">Δηλωτικά</xsl:when>
                    <xsl:when test="$label='header_language'">Γλώσσα</xsl:when>
                    <xsl:when test="$label='header_analyze'">Ανάλυση «θησαυρών»</xsl:when>
                    <xsl:when test="$label='header_visualize'">Οπτικοποίηση αναζητήσεων</xsl:when>
                    <xsl:when test="$label='display_summary'">Συνοπτική παρουσίαση</xsl:when>
                    <xsl:when test="$label='display_map'">Χάρτης</xsl:when>
                    <xsl:when test="$label='display_administrative'">Διαχείριση</xsl:when>
                    <xsl:when test="$label='display_visualization'">Οπτικοποίηση</xsl:when>
                    <xsl:when test="$label='display_data-download'">Λήψη δεδομένων</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Ποσοτική ανάλυση</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Χρονολογική ανάλυση</xsl:when>
                    <xsl:when test="$label='display_contents'">Ανάλυση περιεχομένων</xsl:when>
                    <xsl:when test="$label='display_examples'">Παραδείγματα του ίδιου τύπου</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Επιλογή όλων των όρων</xsl:when>
                    <xsl:when test="$label='results_map-results'">Αποτελέσματα επί χάρτου</xsl:when>
                    <xsl:when test="$label='results_filters'">Φίλτρα</xsl:when>
                    <xsl:when test="$label='results_keyword'">Λέξη-κλειδί</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Εκκαθάριση όλων των όρων</xsl:when>
                    <xsl:when test="$label='results_data-options'">Επιλογές δεδομένων</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Περιορισμός αποτελεσμάτων</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Γρήγορη αναζήτηση</xsl:when>
                    <xsl:when test="$label='results_has-images'">Συμπερίληψη εικόνων</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Περιορισμός αναζήτησης</xsl:when>
                    <xsl:when test="$label='results_select'">Επιλογή από τη λίστα</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Ταξινόμηση αποτελεσμάτων</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Ταξινόμηση κατηγοριών</xsl:when>
                    <xsl:when test="$label='results_ascending'">Αύξουσα σειρά</xsl:when>
                    <xsl:when test="$label='results_descending'">Φθίνουσα σειρά</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Παρουσίαση αποτελεσμάτων XX έως YY από συνολικά ZZ</xsl:when>
                    <xsl:when test="$label='results_coin'">νόμισμα</xsl:when>
                    <xsl:when test="$label='results_coins'">νομίσματα</xsl:when>
                    <xsl:when test="$label='results_hoard'">«θησαυρός»</xsl:when>
                    <xsl:when test="$label='results_hoards'">«θησαυροί»</xsl:when>
                    <xsl:when test="$label='results_and'">και</xsl:when>
                    <xsl:when test="$label='maps_legend'">Επιγραφή</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Τυπολογική ανάλυση</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Ανάλυση μετρικών δεδομένων</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Χρησιμοποιείστε την επιλογή δεδομένων και τις δυνατότητες οπτικοποίησης κάτωθι για να δημιουργήσετε ένα γράφημα βασισμένο σε επιλεγμένες παραμέτρους. Οδηγίες για τη χρήση αυτού του εργαλείου υπάρχουν εδώ.</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Χρησιμοποιείστε αυτό το εργαλείο για να οπτικοποιήσετε ποσοστά ή αριθμητικά δεδομένα για τους παρακάτω τύπους</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Χρησιμοποιείστε αυτό το εργαλείο για να οπτικοποιήσετε ποσοστά ή αριθμητικά δεδομένα όσον αφορά σε νομίσματα μιας ιδιαίτερης χρονολόγησης εντός «θησαυρών»</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Χρησιμοποιείστε αυτό το εργαλείο για να κατεβάσετε ένα αρχείο CSV (δεδομένα χωρισμένα με κόμματα) για τη συγκεκριμένη αναζήτηση και τους επιλεγμένους «θησαυρούς»</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Επιλέξτε μετρικά δεδομένα</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Επιλέξτε τύπο γραφήματος</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Επιλέξτε κατηγορίες ανάλυσης</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Επιλέξτε «θησαυρούς»</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Επιλέξτε «θησαυρούς» για σύγκριση (προαιρετικά)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Σύγκριση βάσει κατηγορίας</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Αντιπαραβολή με άλλες αναζητήσεις (προαιρετικά)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Αντιπαραβολή αναζητήσεων</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Συνδυαστική αναζήτηση</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Προσθήκη συνήθων αναζητήσεων</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Συνήθης αναζήτηση</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Εκκαθάριση αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Προσθήκη αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Προσθήκη αναζητήσεων</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Προσθήκη νέας αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_query'">Υποβολή αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Λίστα φίλτρων αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Φιλτράρισμα αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Εκκαθάριση φίλτρου αναζήτησης</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Χρησιμοποιείστε τα κάτωθι μενού για να διαμορφώσετε μια αναζήτηση μετρικών δεδομένων. Μόνο μία χρονική περίοδος μπορεί να ορισθεί για κάθε αναζήτηση.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Προαιρετικές ρυθμίσεις</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Απόκρυψη/εμφάνιση επιλογών</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Επιλογές stacking</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Εξαίρεση certainty codes</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Κατάταξη βάσει χρονικού διαστήματος (προαιρετικά)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Χρονικό διάστημα (έτη)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Διάρκεια</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Υπολογισμός επιλεγμένων</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Δημιουργία γραφήματος</xsl:when>
                    <xsl:when test="$label='numeric_count'">Άθροισμα</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Ποσοστό</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Συγκεντρωτικό</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Συγκεντρωτικό ποσοστό</xsl:when>
                    <xsl:when test="$label='chart_bar'">μπάρα γραφήματος</xsl:when>
                    <xsl:when test="$label='chart_column'">στήλη γραφήματος</xsl:when>
                    <xsl:when test="$label='chart_area'">περιοχή γραφήματος</xsl:when>
                    <xsl:when test="$label='chart_spline'">πολυωνυμική καμπύλη γραφήματος</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">περιοχή πολυωνυμικής καμπύλης γραφήματος</xsl:when>
                    <xsl:when test="$label='chart_line'">γραμμή γραφήματος</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Προσοχή!</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Χρονικό διάστημα και διάρκεια είναι απαραίτητα.</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Η καταληκτήρια χρονολογία πρέπει να είναι μεταγενέστερη από την εναρκτήρια.</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Μια κατηγορία πρέπει να επιλεχθεί.</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Μπορούν να επιλεχθούν ένας (τουλάχιστον) έως οκτώ «θησαυροί».</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Μπορούν να επιλεχθούν μέχρι οκτώ «θησαυροί».</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Μπορούν να επιλεχθούν ένας (τουλάχιστον) έως τριάντα «θησαυροί».</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Μπορούν να επιλεχθούν μέχρι τριάντα «θησαυροί».</xsl:when>
                    <xsl:when test="$label='lang_ar'">αραβικά</xsl:when>
                    <xsl:when test="$label='lang_bg'">βουλγαρικά</xsl:when>
                    <xsl:when test="$label='lang_da'">δανέζικα</xsl:when>
                    <xsl:when test="$label='lang_de'">γερμανικά</xsl:when>
                    <xsl:when test="$label='lang_el'">ελληνικά</xsl:when>
                    <xsl:when test="$label='lang_en'">αγγλικά</xsl:when>
                    <xsl:when test="$label='lang_es'">ισπανικά</xsl:when>
                    <xsl:when test="$label='lang_fi'">φινλαδικά</xsl:when>
                    <xsl:when test="$label='lang_fr'">γαλλικά</xsl:when>
                    <xsl:when test="$label='lang_he'">εβραϊκά</xsl:when>
                    <xsl:when test="$label='lang_hu'">ουγγρικά</xsl:when>
                    <xsl:when test="$label='lang_it'">ιταλικά</xsl:when>
                    <xsl:when test="$label='lang_nl'">ολλανδικά</xsl:when>
                    <xsl:when test="$label='lang_nn'">νορβηγικά</xsl:when>
                    <xsl:when test="$label='lang_pl'">πολωνικά</xsl:when>
                    <xsl:when test="$label='lang_ro'">ρουμανικά</xsl:when>
                    <xsl:when test="$label='lang_ru'">ρωσικά</xsl:when>
                    <xsl:when test="$label='lang_sv'">σουηδικά</xsl:when>
                    <xsl:when test="$label='lang_tr'">τουρκικά</xsl:when>
                    <xsl:when test="$label='lang_uk'">ουκρανικά</xsl:when>
                    <xsl:when test="$label='lang_ur'">Ουρντού</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='es'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Inicio</xsl:when>
                    <xsl:when test="$label='header_about'">Acerca</xsl:when>
                    <xsl:when test="$label='header_browse'">Navegar</xsl:when>
                    <xsl:when test="$label='header_search'">Buscar</xsl:when>
                    <xsl:when test="$label='header_maps'">Mapa</xsl:when>
                    <xsl:when test="$label='header_compare'">Comparar</xsl:when>
                    <xsl:when test="$label='header_symbols'">Símbolos</xsl:when>
                    <xsl:when test="$label='header_language'">Lengua</xsl:when>
                    <xsl:when test="$label='header_analyze'">Análisis de los tesoros</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualizar la búsqueda</xsl:when>
                    <xsl:when test="$label='display_summary'">Sumario</xsl:when>
                    <xsl:when test="$label='display_map'">Mapa</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administrativo</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualización</xsl:when>
                    <xsl:when test="$label='display_data-download'">Descargar los datos</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Análisis cuantitativo</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Análisis de los datos</xsl:when>
                    <xsl:when test="$label='display_contents'">Contenido</xsl:when>
                    <xsl:when test="$label='display_examples'">Ejemplos de este tipo</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Todos los términos</xsl:when>
                    <xsl:when test="$label='results_map-results'">Resultados en el mapa</xsl:when>
                    <xsl:when test="$label='results_filters'">Filtros</xsl:when>
                    <xsl:when test="$label='results_keyword'">Palabras clave</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Limpiar</xsl:when>
                    <xsl:when test="$label='results_data-options'">Ocultar todos los términos</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Detallar resultados</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Búsqueda rápida</xsl:when>
                    <xsl:when test="$label='results_has-images'">Imágenes disponibles</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Volver a definir la búsqueda</xsl:when>
                    <xsl:when test="$label='results_select'">Seleccionar</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Ordenar los resultados</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Ordenar por categorías</xsl:when>
                    <xsl:when test="$label='results_ascending'">Ascendente</xsl:when>
                    <xsl:when test="$label='results_descending'">Descendente</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Resultados de XX a YY sobre un total de ZZ</xsl:when>
                    <xsl:when test="$label='results_coin'">Moneda</xsl:when>
                    <xsl:when test="$label='results_coins'">Monedas</xsl:when>
                    <xsl:when test="$label='results_hoard'">Tesoro</xsl:when>
                    <xsl:when test="$label='results_hoards'">Tesoros</xsl:when>
                    <xsl:when test="$label='results_and'">y</xsl:when>
                    <xsl:when test="$label='maps_legend'">Leyenda</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Tipológico</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Dimensiones</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Utiliza las opciones para la selección y visualización de los datos de debajo para crear un gráfico basado en los parámetros seleccionados. Las instrucciones para utilizar esta función se pueden consultar aquí.</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Utiliza esta función para visualizar el porcentaje o la frecuencia numérica de esta tipología.</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Utilizar esta función para obtener el porcentaje o el número de veces en los que esta moneda aparece en una fecha determinada en los tesoros</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Utiliza esta función para descargar CSV (valores separados por comas) relativos a la consulta realizada y a los tesoros seleccionados.</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Seleccionar dimensiones</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Mapa tipo</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Categorías</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Seleccionar tesoros</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Seleccionar tesoros opcional</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Comparar categoría</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Comparar opcional</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Comparar</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Comparar búsqueda</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Añadir búsquedas personales</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Búsqueda personal</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Añadir búsqueda</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Añadir búsquedas</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Anadir nuevo</xsl:when>
                    <xsl:when test="$label='visualize_query'">Búsqueda</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Lista de filtros</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filtrar la búsqueda</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Limpiar filtro</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Utiliza el menú desplegable inferior para elaborar tu consulta de medida. Se puede especificar un arco cronológico sólo una vez por cada consulta.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Parámetros opcionales</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Ocultar Mostrar</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Juntar opciones</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Excluir los códigos ciertos</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Organizar por intervalos</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Intervalo (años)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Duración</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Calcular la selección</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Generar</xsl:when>
                    <xsl:when test="$label='numeric_count'">Contar</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Porcentaje</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Acumulativo</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Porcentaje acumulativo</xsl:when>
                    <xsl:when test="$label='chart_bar'">Barra</xsl:when>
                    <xsl:when test="$label='chart_column'">Columna</xsl:when>
                    <xsl:when test="$label='chart_area'">Área</xsl:when>
                    <xsl:when test="$label='chart_spline'">Franja</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">Área de franja</xsl:when>
                    <xsl:when test="$label='chart_line'">Línea</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alerta</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Se requiere intervalo y período</xsl:when>
                    <xsl:when test="$label='visualize_error2'">La fecha final debe ser posterior a la fecha inicial</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Se debe seleccionar una categoría</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Se puede seleccionar un mínimo de 1 tesoro y un máximo de 8</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Sólo se pueden seleccionar 8 tesoros</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Sólo se puede seleccionar un mínimo de 1 tesoro y un máximo de 30</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Se pueden seleccionar hasta 30 tesoros</xsl:when>
                    <xsl:when test="$label='lang_ar'">Árabe</xsl:when>
                    <xsl:when test="$label='lang_bg'">Búlgaro</xsl:when>
                    <xsl:when test="$label='lang_da'">Danés</xsl:when>
                    <xsl:when test="$label='lang_de'">Alemán</xsl:when>
                    <xsl:when test="$label='lang_el'">Griego</xsl:when>
                    <xsl:when test="$label='lang_en'">Inglés</xsl:when>
                    <xsl:when test="$label='lang_es'">Español</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finlandés</xsl:when>
                    <xsl:when test="$label='lang_fr'">Francés</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebreo</xsl:when>
                    <xsl:when test="$label='lang_hu'">Húngaro</xsl:when>
                    <xsl:when test="$label='lang_it'">Italiano</xsl:when>
                    <xsl:when test="$label='lang_nl'">Holandés</xsl:when>
                    <xsl:when test="$label='lang_nn'">Noruego</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polaco</xsl:when>
                    <xsl:when test="$label='lang_ro'">Rumano</xsl:when>
                    <xsl:when test="$label='lang_ru'">Ruso</xsl:when>
                    <xsl:when test="$label='lang_sv'">Sueco</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turco</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ucranio</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='bg'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Начало</xsl:when>
                    <xsl:when test="$label='header_browse'">Браузване</xsl:when>
                    <xsl:when test="$label='header_search'">Търсене</xsl:when>
                    <xsl:when test="$label='header_maps'">Карти</xsl:when>
                    <xsl:when test="$label='header_compare'">Сравнение</xsl:when>
                    <xsl:when test="$label='header_language'">Езици</xsl:when>
                    <xsl:when test="$label='header_analyze'">Анализ на монетни съкровища</xsl:when>
                    <xsl:when test="$label='header_visualize'">Визуализация на запитванията</xsl:when>
                    <xsl:when test="$label='display_summary'">Обобщение</xsl:when>
                    <xsl:when test="$label='display_map'">Карта</xsl:when>
                    <xsl:when test="$label='display_administrative'">Администрация</xsl:when>
                    <xsl:when test="$label='display_visualization'">Визуализация</xsl:when>
                    <xsl:when test="$label='display_data-download'">Сваляне на данни</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Количествен анализ</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Анализ на датите</xsl:when>
                    <xsl:when test="$label='display_contents'">Съдържание</xsl:when>
                    <xsl:when test="$label='display_examples'">Примери от този тип</xsl:when>
                    <xsl:when test="$label='results_all-terms'">Всички термини</xsl:when>
                    <xsl:when test="$label='results_map-results'">Резултати за карти</xsl:when>
                    <xsl:when test="$label='results_filters'">Филтър</xsl:when>
                    <xsl:when test="$label='results_keyword'">Ключова дума</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Изчисти всички термини</xsl:when>
                    <xsl:when test="$label='results_data-options'">Възможности за данни</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Ограничи резултатите</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Бързо търсене</xsl:when>
                    <xsl:when test="$label='results_has-images'">Има изображения</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Ограничи търсенето</xsl:when>
                    <xsl:when test="$label='results_select'">Избери от списък</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Сортирай резултатите</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Сортирай категориите</xsl:when>
                    <xsl:when test="$label='results_ascending'">възходящо</xsl:when>
                    <xsl:when test="$label='results_descending'">низходящо</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Показване на записи от ХХ до YY, от общо ZZ резултата</xsl:when>
                    <xsl:when test="$label='results_coin'">Монета</xsl:when>
                    <xsl:when test="$label='results_coins'">Монети</xsl:when>
                    <xsl:when test="$label='results_hoard'">Монетно съкровище</xsl:when>
                    <xsl:when test="$label='results_hoards'">Монетно съкровище</xsl:when>
                    <xsl:when test="$label='results_and'">и</xsl:when>
                    <xsl:when test="$label='maps_legend'">Легенда</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Типологичен анализ</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Анализ на размерите</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Използвайте избранните данни и възможностите за визуализиране отдолу, за да генерирате диаграма, базирана на подбраните параметри. Инструкции за употребата на тази функция могат да бъдат намерени тук</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Използвайте тази функция, за да визуализирате процентите или броя на появата на следните типологии</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Използвайте тази функция, за да изведете процентите или броя на появата на монети с определена дата в съкровищата</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Използвайте тази функция, за да свалите CSV за конкретното запитване и избраните монетни съкровища</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Избери размери</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Избери тип диаграма</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Избери категории за анализ</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Избери монетни съкровища</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Избери монетни съкровища за сравняване (по избор)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Сравняване по категория</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Сравни с други запитвания (по избор)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Сравни запитванията</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Запитване за сравнение</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Добави специализирано запитване</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Специализирано запитване</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Премахни запитване</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Добави запитване</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Добави запитвания</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Добави (нов)</xsl:when>
                    <xsl:when test="$label='visualize_query'">Запитване</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Филтриране на списъка</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Филтриране на запитванията</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Премахни филтъра</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Използвайте падащото меню по-долу, за да формулирате своето запитване за размерите. Може да се избере само по един времеви период  на запитване.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Настройки по избор</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Покажи / скрий опциите</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Опции за комбиниране</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Изключи определящите кодове</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Подреди по периоди (по избор)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Интервал (години)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Продължителност</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Изчисли подбраното</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Генерирай диаграма</xsl:when>
                    <xsl:when test="$label='numeric_count'">Брой</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Процент</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Нарастващ</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Нарастващ процент</xsl:when>
                    <xsl:when test="$label='chart_bar'">поле</xsl:when>
                    <xsl:when test="$label='chart_column'">колона</xsl:when>
                    <xsl:when test="$label='chart_area'">област</xsl:when>
                    <xsl:when test="$label='chart_spline'">разделителна линия</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">ограничителна линия</xsl:when>
                    <xsl:when test="$label='chart_line'">линия</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Внимание!</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Необходими са интервал и продължителност</xsl:when>
                    <xsl:when test="$label='visualize_error2'">Крайната дата трябва да бъде по-късна от началната дата</xsl:when>
                    <xsl:when test="$label='visualize_error3'">Трябва да бъде избрана категория</xsl:when>
                    <xsl:when test="$label='visualize_error4'">Могат да избрани от (най-малко) 1 до (най-много) 8 съкровища</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Могат да бъдат избрани до 8 съкровища</xsl:when>
                    <xsl:when test="$label='visualize_error6'">Могат да избрани от (най-малко) 1 до (най-много) 30 съкровища</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Могат да бъдат избрани до 30 съкровища</xsl:when>
                    <xsl:when test="$label='lang_ar'">Арабски</xsl:when>
                    <xsl:when test="$label='lang_bg'">българин</xsl:when>
                    <xsl:when test="$label='lang_da'">Датски</xsl:when>
                    <xsl:when test="$label='lang_de'">Немски</xsl:when>
                    <xsl:when test="$label='lang_el'">Гръцки</xsl:when>
                    <xsl:when test="$label='lang_en'">Английски</xsl:when>
                    <xsl:when test="$label='lang_es'">Испански</xsl:when>
                    <xsl:when test="$label='lang_fi'">фински</xsl:when>
                    <xsl:when test="$label='lang_fr'">Френски</xsl:when>
                    <xsl:when test="$label='lang_he'">Иврит</xsl:when>
                    <xsl:when test="$label='lang_hu'">Унгарски</xsl:when>
                    <xsl:when test="$label='lang_it'">Италиански</xsl:when>
                    <xsl:when test="$label='lang_nl'">Холандски</xsl:when>
                    <xsl:when test="$label='lang_nn'">Норвежки</xsl:when>
                    <xsl:when test="$label='lang_pl'">Полски</xsl:when>
                    <xsl:when test="$label='lang_ro'">Румънски</xsl:when>
                    <xsl:when test="$label='lang_ru'">Руски</xsl:when>
                    <xsl:when test="$label='lang_sv'">Шведски</xsl:when>
                    <xsl:when test="$label='lang_tr'">Турски</xsl:when>
                    <xsl:when test="$label='lang_uk'">Украински</xsl:when>
                    <xsl:when test="$label='lang_ur'">урду</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang='he'">
                <xsl:choose>
                    <xsl:when test="$label='header_home'">דף הבית</xsl:when>
                    <xsl:when test="$label='header_about'">אודות</xsl:when>
                    <xsl:when test="$label='header_browse'">דיפדוף</xsl:when>
                    <xsl:when test="$label='header_search'">חיפוש</xsl:when>
                    <xsl:when test="$label='header_maps'">מפות</xsl:when>
                    <xsl:when test="$label='header_compare'">השוואה</xsl:when>
                    <xsl:when test="$label='header_symbols'">סימנים</xsl:when>
                    <xsl:when test="$label='header_language'">שפה</xsl:when>
                    <xsl:when test="$label='header_analyze'">ניתוח מטמונים</xsl:when>
                    <xsl:when test="$label='header_visualize'">תצוגת שאילתות</xsl:when>
                    <xsl:when test="$label='display_summary'">סיכום</xsl:when>
                    <xsl:when test="$label='display_map'">מפה</xsl:when>
                    <xsl:when test="$label='display_administrative'">מינהלי</xsl:when>
                    <xsl:when test="$label='display_visualization'">תצוגה</xsl:when>
                    <xsl:when test="$label='display_data-download'">הורדת נתונים</xsl:when>
                    <xsl:when test="$label='maps_legend'">כתובת</xsl:when>
                    <xsl:when test="$label='visualize_error5'">ניתן לבחור עד 8 מטמונים</xsl:when>
                    <xsl:when test="$label='visualize_error6'">יש לבחור לפחות מטמון אחד, אך לא יותר מ-30</xsl:when>
                    <xsl:when test="$label='visualize_error7'">ניתן לבחור עד 30 מטמונים</xsl:when>
                    <xsl:when test="$label='lang_ar'">ערבית</xsl:when>
                    <xsl:when test="$label='lang_bg'">גולגרית</xsl:when>
                    <xsl:when test="$label='lang_da'">דנית</xsl:when>
                    <xsl:when test="$label='lang_de'">גרמנית</xsl:when>
                    <xsl:when test="$label='lang_el'">יוונית</xsl:when>
                    <xsl:when test="$label='lang_en'">אנגלית</xsl:when>
                    <xsl:when test="$label='lang_es'">ספרדית</xsl:when>
                    <xsl:when test="$label='lang_fi'">פינית</xsl:when>
                    <xsl:when test="$label='lang_fr'">צרפתית</xsl:when>
                    <xsl:when test="$label='lang_he'">עִברִית</xsl:when>
                    <xsl:when test="$label='lang_hu'">הונגרית</xsl:when>
                    <xsl:when test="$label='lang_it'">איטלקית</xsl:when>
                    <xsl:when test="$label='lang_nl'">הולנדית</xsl:when>
                    <xsl:when test="$label='lang_nn'">נורווגית</xsl:when>
                    <xsl:when test="$label='lang_pl'">פולנית</xsl:when>
                    <xsl:when test="$label='lang_ro'">רומנית</xsl:when>
                    <xsl:when test="$label='lang_ru'">רוסית</xsl:when>
                    <xsl:when test="$label='lang_sv'">שוודית</xsl:when>
                    <xsl:when test="$label='lang_tr'">תורכית</xsl:when>
                    <xsl:when test="$label='lang_uk'">אוקראינית</xsl:when>
                    <xsl:when test="$label='lang_ur'">אורדו</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel($label, 'en')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$label='header_home'">Home</xsl:when>
                    <xsl:when test="$label='header_about'">About</xsl:when>
                    <xsl:when test="$label='header_browse'">Browse</xsl:when>
                    <xsl:when test="$label='header_search'">Search</xsl:when>
                    <xsl:when test="$label='header_maps'">Maps</xsl:when>
                    <xsl:when test="$label='header_compare'">Compare</xsl:when>
                    <xsl:when test="$label='header_symbols'">Symbols</xsl:when>
                    <xsl:when test="$label='header_language'">Language</xsl:when>
                    <xsl:when test="$label='header_analyze'">Analyze Hoards</xsl:when>
                    <xsl:when test="$label='header_visualize'">Visualize Queries</xsl:when>
                    <xsl:when test="$label='header_contributors'">Contributors</xsl:when>
                    <xsl:when test="$label='header_feedback'">Feedback</xsl:when>
                    <xsl:when test="$label='header_identify'">Identify a Coin</xsl:when>
                    <xsl:when test="$label='display_summary'">Summary</xsl:when>
                    <xsl:when test="$label='display_map'">Map</xsl:when>
                    <xsl:when test="$label='display_administrative'">Administrative</xsl:when>
                    <xsl:when test="$label='display_visualization'">Visualization</xsl:when>
                    <xsl:when test="$label='display_data-download'">Data Download</xsl:when>
                    <xsl:when test="$label='display_quantitative'">Quantitative Analysis</xsl:when>
                    <xsl:when test="$label='display_date-analysis'">Date Analysis</xsl:when>
                    <xsl:when test="$label='display_contents'">Contents</xsl:when>
                    <xsl:when test="$label='display_examples'">Examples of this type</xsl:when>
                    <xsl:when test="$label='display_die_analysis'">Die Analysis</xsl:when>
                    <xsl:when test="$label='display_die_examples'">Die Examples</xsl:when>
                    <xsl:when test="$label='results_all-terms'">All Terms</xsl:when>
                    <xsl:when test="$label='results_map-results'">Map Results</xsl:when>
                    <xsl:when test="$label='results_filters'">Filters</xsl:when>
                    <xsl:when test="$label='results_keyword'">Keyword</xsl:when>
                    <xsl:when test="$label='results_type_number'">Coin Type Number</xsl:when>
                    <xsl:when test="$label='results_clear-all'">Clear All Terms</xsl:when>
                    <xsl:when test="$label='results_data-options'">Data Options</xsl:when>
                    <xsl:when test="$label='results_refine-results'">Refine Results</xsl:when>
                    <xsl:when test="$label='results_quick-search'">Quick Search</xsl:when>
                    <xsl:when test="$label='results_has-images'">Has Images</xsl:when>
                    <xsl:when test="$label='results_refine-search'">Refine Search</xsl:when>
                    <xsl:when test="$label='results_select'">Select from List</xsl:when>
                    <xsl:when test="$label='results_sort-results'">Sort Results</xsl:when>
                    <xsl:when test="$label='results_sort-category'">Sort Category</xsl:when>
                    <xsl:when test="$label='results_ascending'">Ascending</xsl:when>
                    <xsl:when test="$label='results_descending'">Descending</xsl:when>
                    <xsl:when test="$label='results_result-desc'">Displaying records XX to YY of ZZ total results.</xsl:when>
                    <xsl:when test="$label='results_coin'">coin</xsl:when>
                    <xsl:when test="$label='results_coins'">coins</xsl:when>
                    <xsl:when test="$label='results_hoard'">hoard</xsl:when>
                    <xsl:when test="$label='results_hoards'">hoards</xsl:when>
                    <xsl:when test="$label='results_and'">and</xsl:when>
                    <xsl:when test="$label='maps_legend'">Legend</xsl:when>
                	<xsl:when test="$label = 'position_any'">Any Position</xsl:when>
                    <xsl:when test="$label='visualize_typological'">Typological Analysis</xsl:when>
                    <xsl:when test="$label='visualize_measurement'">Measurement Analysis</xsl:when>
                    <xsl:when test="$label='visualize_desc'">Use the data selection and visualization options below to generate a chart based on selected parameters. Instructions for using this feature can be found here</xsl:when>
                    <xsl:when test="$label='visualize_type_desc'">Use this feature to visualize percentages or numeric occurrences of the following typologies</xsl:when>
                    <xsl:when test="$label='visualize_date_desc'">Use this feature to render percentages or numeric occurrences of coins of a particular date within hoards</xsl:when>
                    <xsl:when test="$label='visualize_csv_desc'">Use this feature to download a CSV for the given query and selected hoards</xsl:when>
                    <xsl:when test="$label='visualize_select_measurement'">Select Measurement</xsl:when>
                    <xsl:when test="$label='visualize_chart_type'">Select Chart Type</xsl:when>
                    <xsl:when test="$label='visualize_categories'">Select Categories for Analysis</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards'">Select Hoards</xsl:when>
                    <xsl:when test="$label='visualize_select_hoards_optional'">Select Hoards to Compare (optional)</xsl:when>
                    <xsl:when test="$label='visualize_compare_category'">Compare by Category</xsl:when>
                    <xsl:when test="$label='visualize_compare_optional'">Compare to other Queries (optional)</xsl:when>
                    <xsl:when test="$label='visualize_compare'">Compare Queries</xsl:when>
                    <xsl:when test="$label='visualize_comparison_query'">Comparison Query</xsl:when>
                    <xsl:when test="$label='visualize_add_custom'">Add Custom Queries</xsl:when>
                    <xsl:when test="$label='visualize_custom_query'">Custom Query</xsl:when>
                    <xsl:when test="$label='visualize_remove_query'">Remove Query</xsl:when>
                    <xsl:when test="$label='visualize_add_query'">Add Query</xsl:when>
                    <xsl:when test="$label='visualize_add_queries'">Add Queries</xsl:when>
                    <xsl:when test="$label='visualize_add_new'">Add New</xsl:when>
                    <xsl:when test="$label='visualize_query'">Query</xsl:when>
                    <xsl:when test="$label='visualize_filter_list'">Filter List</xsl:when>
                    <xsl:when test="$label='visualize_filter_query'">Filter Query</xsl:when>
                    <xsl:when test="$label='visualize_remove_filter'">Remove Filter</xsl:when>
                    <xsl:when test="$label='visualize_add_query_desc'">Use the drop-down menus below to formulate your measurement query. A date range can only be specified once per query.</xsl:when>
                    <xsl:when test="$label='visualize_optional_settings'">Optional Settings</xsl:when>
                    <xsl:when test="$label='visualize_hide-show'">Hide/Show Options</xsl:when>
                    <xsl:when test="$label='visualize_stacking_options'">Stacking Options</xsl:when>
                    <xsl:when test="$label='visualize_exclude_certainty_codes'">Exclude Certainty Codes</xsl:when>
                    <xsl:when test="$label='visualize_arrange'">Arrange by Interval (optional)</xsl:when>
                    <xsl:when test="$label='visualize_interval'">Interval (years)</xsl:when>
                    <xsl:when test="$label='visualize_duration'">Duration</xsl:when>
                    <xsl:when test="$label='visualize_calculate'">Calculate Selected</xsl:when>
                    <xsl:when test="$label='visualize_generate'">Generate Chart</xsl:when>
                    <xsl:when test="$label='numeric_count'">Count</xsl:when>
                    <xsl:when test="$label='numeric_percentage'">Percentage</xsl:when>
                    <xsl:when test="$label='numeric_cumulative'">Cumulative</xsl:when>
                    <xsl:when test="$label='numeric_cumulative_percentage'">Cumulative Percentage</xsl:when>
                    <xsl:when test="$label='chart_bar'">bar</xsl:when>
                    <xsl:when test="$label='chart_column'">column</xsl:when>
                    <xsl:when test="$label='chart_area'">area</xsl:when>
                    <xsl:when test="$label='chart_spline'">spline</xsl:when>
                    <xsl:when test="$label='chart_areaspline'">areaspline</xsl:when>
                    <xsl:when test="$label='chart_line'">line</xsl:when>
                    <xsl:when test="$label='visualize_alert'">Alert</xsl:when>
                    <xsl:when test="$label='visualize_error1'">Interval and duration are required.</xsl:when>
                    <xsl:when test="$label='visualize_error2'">To Date must be later than From Date.</xsl:when>
                    <xsl:when test="$label='visualize_error3'">A category must be selected.</xsl:when>
                    <xsl:when test="$label='visualize_error4'">At least 1 and up to 8 hoards may be selected.</xsl:when>
                    <xsl:when test="$label='visualize_error5'">Up to 8 hoards may be selected.</xsl:when>
                    <xsl:when test="$label='visualize_error6'">At least 1 and up to 30 hoards may be selected.</xsl:when>
                    <xsl:when test="$label='visualize_error7'">Up to 30 hoards may be selected.</xsl:when>
                    <xsl:when test="$label='lang_ar'">Arabic</xsl:when>
                    <xsl:when test="$label='lang_bg'">Bulgarian</xsl:when>
                    <xsl:when test="$label='lang_da'">Danish</xsl:when>
                    <xsl:when test="$label='lang_de'">German</xsl:when>
                    <xsl:when test="$label='lang_el'">Greek</xsl:when>
                    <xsl:when test="$label='lang_en'">English</xsl:when>
                    <xsl:when test="$label='lang_es'">Spanish</xsl:when>
                    <xsl:when test="$label='lang_fi'">Finnish</xsl:when>
                    <xsl:when test="$label='lang_fr'">French</xsl:when>
                    <xsl:when test="$label='lang_he'">Hebrew</xsl:when>
                    <xsl:when test="$label='lang_hu'">Hungarian</xsl:when>
                    <xsl:when test="$label='lang_it'">Italian</xsl:when>
                    <xsl:when test="$label='lang_nl'">Dutch</xsl:when>
                    <xsl:when test="$label='lang_nn'">Norwegian</xsl:when>
                    <xsl:when test="$label='lang_pl'">Polish</xsl:when>
                    <xsl:when test="$label='lang_ro'">Romanian</xsl:when>
                    <xsl:when test="$label='lang_ru'">Russian</xsl:when>
                    <xsl:when test="$label='lang_sv'">Swedish</xsl:when>
                    <xsl:when test="$label='lang_tr'">Turkish</xsl:when>
                    <xsl:when test="$label='lang_uk'">Ukrainian</xsl:when>
                    <xsl:when test="$label='lang_ur'">Urdu</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('[', $label, ']')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

	<!-- general purpose function for rendering descriptions based on available languages -->
	<xsl:function name="numishare:display-description">
		<xsl:param name="node" as="node()*"/>
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$node/*:description[@xml:lang = $lang]">
				<xsl:value-of select="$node/*:description[@xml:lang = $lang]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$node/*:description[@xml:lang = 'en']">
						<xsl:value-of select="$node/*:description[@xml:lang = 'en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$node/*:description[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="numishare:normalizeDate">
		<xsl:param name="date"/>

		<!--<xsl:if test="substring($date, 1, 1) != '-' and number(substring($date, 1, 4)) &lt;= 400">
			<xsl:text>A.D. </xsl:text>
		</xsl:if>-->

		<xsl:choose>
			<xsl:when test="$date castable as xs:dateTime">
				<xsl:value-of select="format-dateTime($date, '[D] [MNn] [Y], [H01]:[m01]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:date">
				<xsl:value-of select="format-date($date, '[D] [MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYearMonth">
				<xsl:variable name="normalized" select="xs:date(concat($date, '-01'))"/>
				<xsl:value-of select="format-date($normalized, '[MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYear or $date castable as xs:integer">
				<xsl:value-of select="abs(number($date))"/>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="substring($date, 1, 1) = '-'">
			<xsl:text> BCE</xsl:text>
		</xsl:if>
	</xsl:function>

	<xsl:function name="numishare:normalize_century">
		<xsl:param name="name"/>
		<xsl:variable name="cleaned" select="number(translate($name, '\', ''))"/>
		<xsl:variable name="century" select="abs($cleaned)"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$century mod 10 = 1 and $century != 11">
					<xsl:text>st</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 2 and $century != 12">
					<xsl:text>nd</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 3 and $century != 13">
					<xsl:text>rd</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>th</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat($century, $suffix)"/>
		<xsl:if test="$cleaned &lt; 0">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>

	<xsl:function name="numishare:recordCount">
		<xsl:param name="lang"/>
		<xsl:param name="startRecord"/>
		<xsl:param name="endRecord"/>
		<xsl:param name="numFound"/>

		<xsl:choose>
			<xsl:when test="$lang = 'ar'">
				<xsl:value-of
					select="
						replace(replace(replace(numishare:normalizeLabel('results_result-desc', $lang), 'أ أ', string($startRecord)), 'ب ب', string($endRecord)), 'ج ج',
						string($numFound))"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
					select="
						replace(replace(replace(numishare:normalizeLabel('results_result-desc', $lang), 'XX', string($startRecord)), 'YY', string($endRecord)), 'ZZ',
						string($numFound))"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- this function will normalize a NUDS element into a nomisma property for RDFa -->
	<xsl:function name="numishare:normalizeProperty">
		<xsl:param name="recordType"/>
		<xsl:param name="name"/>

		<xsl:choose>
			<xsl:when test="$name = 'fromDate'">nmo:hasStartDate</xsl:when>
			<xsl:when test="$name = 'toDate'">nmo:hasEndDate</xsl:when>
			<xsl:when test="$name = 'subject'">dcterms:subject</xsl:when>
			<xsl:when test="$name = 'description'">dcterms:description</xsl:when>
			<xsl:when test="$name = 'objectType'">
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">nmo:representsObjectType</xsl:when>
					<xsl:otherwise>nmo:hasObjectType</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('nmo:has', upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- get the Nomisma preferred label from the $rdf variable, depending on the languaged passed by HTTP header or URL param -->
	<xsl:function name="numishare:getNomismaLabel">
		<xsl:param name="rdf" as="element()*"/>
		<xsl:param name="lang"/>
		<xsl:choose>
			<xsl:when test="string($lang)">
				<xsl:choose>
					<xsl:when test="$rdf/skos:prefLabel[@xml:lang = $lang][1]">
						<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang = $lang][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang = 'en'][1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- parse the hoard contents in order to develop a denomination-based textual description with numeric counts -->
	<xsl:function name="numishare:hoardContentsDescription">
		<xsl:param name="contents" as="element()*"/>
		<xsl:param name="nudsGroup" as="element()*"/>
		<xsl:param name="rdf" as="element()*"/>
		<xsl:param name="lang"/>

		<!-- extract the count for each entry of a denomination -->
		<xsl:variable name="total-counts" as="element()*">
			<total-counts>
				<xsl:for-each select="$contents/descendant::nuds:typeDesc">
					<xsl:choose>
						<xsl:when test="string(@xlink:href)">
							<xsl:variable name="href" select="@xlink:href"/>
							<xsl:apply-templates select="$nudsGroup//object[@xlink:href = $href]/descendant::nuds:typeDesc/nuds:denomination"
								mode="hoardContentsDescription">
								<xsl:with-param name="contents" select="$contents"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="nuds:denomination" mode="hoardContentsDescription">
								<xsl:with-param name="contents" select="$contents"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="rdf" select="$rdf"/>
								<xsl:with-param name="minCount">
									<xsl:choose>
										<xsl:when test="ancestor::nh:coin">1</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="ancestor::nh:coinGrp/@count">
													<xsl:value-of select="ancestor::nh:coinGrp/@count"/>
												</xsl:when>
												<xsl:when test="ancestor::nh:coinGrp/@minCount">
													<xsl:value-of select="ancestor::nh:coinGrp/@minCount"/>
												</xsl:when>
												<xsl:otherwise>1</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="maxCount">
									<xsl:choose>
										<xsl:when test="ancestor::nh:coin">1</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="ancestor::nh:coinGrp/@count">
													<xsl:value-of select="ancestor::nh:coinGrp/@count"/>
												</xsl:when>
												<xsl:when test="ancestor::nh:coinGrp/@maxCount">
													<xsl:value-of select="ancestor::nh:coinGrp/@maxCount"/>
												</xsl:when>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</total-counts>
		</xsl:variable>

		<!-- reduce the total denomination counts into a list of distinct denominations with minimum and maximum values -->
		<xsl:variable name="denominations" as="element()*">
			<denominations>
				<xsl:for-each select="distinct-values($total-counts//*[local-name() = 'name' and string-length(normalize-space(.)) &gt; 0])">
					<xsl:variable name="name" select="."/>
					<name>
						<xsl:attribute name="minCount">
							<xsl:value-of select="sum($total-counts//*[local-name() = 'name'][. = $name]/@minCount)"/>
						</xsl:attribute>
						<xsl:attribute name="maxCount">
							<xsl:value-of select="sum($total-counts//*[local-name() = 'name'][. = $name]/@maxCount)"/>
						</xsl:attribute>
						<xsl:value-of select="$name"/>
					</name>
				</xsl:for-each>
			</denominations>
		</xsl:variable>

		<!-- parse $denominations count list into a human-readable description -->
		<xsl:variable name="description">
			<xsl:apply-templates select="$denominations//*[local-name() = 'name']" mode="hoardContentsDescription">
				<xsl:sort select="@minCount" order="descending" data-type="number"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:value-of select="$description"/>
	</xsl:function>

	<!-- match individual denomination entries to associated counts -->
	<xsl:template match="nuds:denomination" mode="hoardContentsDescription">
		<xsl:param name="contents"/>
		<xsl:param name="lang"/>
		<xsl:param name="rdf"/>
		<xsl:param name="minCount"/>
		<xsl:param name="maxCount"/>

		<xsl:variable name="href" select="@xlink:href"/>

		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="contains($href, 'nomisma.org')">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $href], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="source" select="ancestor::object/@xlink:href"/>

		<xsl:choose>
			<xsl:when test="string($source)">
				<xsl:choose>
					<xsl:when test="$contents//nh:coin[nuds:typeDesc[@xlink:href = $source]]">
						<name>
							<xsl:attribute name="minCount" select="count($contents//nh:coin/nuds:typeDesc[@xlink:href = $source])"/>
							<xsl:attribute name="maxCount" select="count($contents//nh:coin/nuds:typeDesc[@xlink:href = $source])"/>
							<xsl:value-of select="$label"/>
						</name>
					</xsl:when>
					<xsl:when test="$contents//nh:coinGrp[nuds:typeDesc[@xlink:href = $source]]">
						<!-- to revisit later: handle proper uncertainty and min/max counts when there are coin type URIs -->
						<name>
							<xsl:attribute name="minCount" select="sum($contents//nh:coinGrp[nuds:typeDesc[@xlink:href = $source]]/@count)"/>
							<xsl:attribute name="maxCount" select="sum($contents//nh:coinGrp[nuds:typeDesc[@xlink:href = $source]]/@count)"/>
							<xsl:value-of select="$label"/>
						</name>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<name>
					<xsl:attribute name="minCount" select="$minCount"/>
					<xsl:choose>
						<xsl:when test="number($maxCount)">
							<xsl:attribute name="maxCount" select="$maxCount"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="certainty">uncertain</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:value-of select="$label"/>
				</name>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- associated template for combining the denominations and counts into a human readable phrase -->
	<xsl:template match="*[local-name() = 'name']" mode="hoardContentsDescription">
		<xsl:value-of select="."/>
		<xsl:text>: </xsl:text>

		<!-- evaluate minimum and maximum counts -->
		<xsl:choose>
			<xsl:when test="@minCount &gt; @maxCount">
				<xsl:value-of select="concat(@minCount, '+')"/>
			</xsl:when>
			<xsl:when test="@minCount = @maxCount">
				<xsl:value-of select="@minCount"/>
			</xsl:when>
			<xsl:when test="@minCount &lt; @maxCount">
				<xsl:value-of select="concat(@minCount, '-', @maxCount)"/>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="@count"/>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- evaluate datatype as string/number for JSON serialization -->
	<xsl:template name="numishare:evaluateDatatype">
		<xsl:param name="val"/>

		<xsl:choose>
			<!-- metadata fields must be a string -->
			<xsl:when test="ancestor::metadata">
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:when>
			<xsl:when test="$val castable as xs:gYear">
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:when>
			<xsl:when test="number($val) or $val = '0'">
				<xsl:choose>
					<xsl:when test="@datatype = 'xs:string'">
						<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$val"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- create human-readable label for RDF properties or classes -->
	<xsl:function name="numishare:getLabelforRDF">
		<xsl:param name="element"/>
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$lang = 'en'">
				<xsl:choose>
					<xsl:when test="$element = 'crm:P106_is_composed_of'">Constituent Letters</xsl:when>
					<xsl:when test="$element = 'crmdig:D1_Digital_Object'">Digital Object</xsl:when>
					<xsl:when test="$element = 'dcterms:creator'">Creator</xsl:when>
					<xsl:when test="$element = 'dcterms:format'">Media Type</xsl:when>
					<xsl:when test="$element = 'dcterms:isPartOf'">Field of Numismatics</xsl:when>
					<xsl:when test="$element = 'dcterms:license'">License</xsl:when>
					<xsl:when test="$element = 'dcterms:source'">Source</xsl:when>
					<xsl:when test="$element = 'skos:broader'">Broader Concept</xsl:when>
					<xsl:when test="$element = 'skos:definition'">Definition</xsl:when>
					<xsl:when test="$element = 'skos:prefLabel'">Preferred Label</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="numishare:getNudsDocument">
		<xsl:param name="uri"/>

		<!-- evaluate pattern to determine how to get the NUDS XML export -->
		<xsl:variable name="xml-url">
			<xsl:choose>
				<xsl:when test="matches($uri, '^https://rpc\.ashmus\.ox\.ac\.uk')">
					<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
					<xsl:value-of select="concat('https://rpc.ashmus.ox.ac.uk/id/rpc-', $pieces[5], '-', $pieces[6], '.xml')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($uri, '.xml')"/>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>
		<object xlink:href="{$uri}">
			<xsl:if test="doc-available($xml-url)">
				<xsl:copy-of select="document($xml-url)/nuds:nuds"/>
			</xsl:if>
		</object>
	</xsl:template>

	<!-- ***** Visualization Interface Functions ***** -->
	<!-- parse the Solr query into a human-readable string -->
	<xsl:function name="numishare:parseSolrQuery">
		<xsl:param name="query"/>
		<xsl:param name="lang"/>

		<xsl:variable name="tokenized_q" select="tokenize(normalize-space($query), ' AND ')"/>
		<xsl:variable name="pieces" as="element()*">
			<pieces>
				<xsl:for-each select="$tokenized_q">
					<xsl:variable name="piece" select="normalize-space(.)"/>

					<piece>
						<xsl:choose>
							<xsl:when test="contains($piece, ':')">
								<xsl:choose>
									<xsl:when test="$piece = '*:*'">
										<xsl:text>All records</xsl:text>
									</xsl:when>
									<xsl:when test="substring($piece, 1, 1) = '('">
										<!-- remove parentheses and parse the fields separated by 'OR' -->
										<xsl:variable name="or_frags" select="tokenize(replace(replace($piece, '\(', ''), '\)', ''), ' OR ')"/>
										<xsl:variable name="field" select="substring-before($or_frags[1], ':')"/>

										<xsl:value-of select="numishare:normalize_fields($field, $lang)"/>
										<xsl:text>: </xsl:text>
										<xsl:for-each select="$or_frags">
											<xsl:value-of select="replace(substring-after(., ':'), '&#x022;', '')"/>
											<xsl:if test="not(position() = last())">
												<xsl:text> or </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="numishare:normalize_fields(substring-before($piece, ':'), $lang)"/>
										<xsl:text>: </xsl:text>
										<xsl:value-of select="replace(substring-after($piece, ':'), '&#x022;', '')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:normalize_fields('fulltext', $lang)"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="replace($piece, '&#x022;', '')"/>
							</xsl:otherwise>
						</xsl:choose>
					</piece>
				</xsl:for-each>
			</pieces>
		</xsl:variable>

		<xsl:value-of select="string-join($pieces//piece, ' &amp; ')"/>
	</xsl:function>

	<!-- parse the SPARQL query into a human-readable string -->
	<xsl:function name="numishare:parseFilter">
		<xsl:param name="query"/>
		<xsl:param name="lang"/>

		<xsl:variable name="pieces" select="tokenize(normalize-space($query), ';')"/>
		<xsl:for-each select="$pieces">
			<xsl:choose>
				<xsl:when test="contains(., '?prop')">
					<xsl:analyze-string select="." regex="\?prop\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="concat(numishare:regularize_node('authority', $lang), '/', numishare:regularize_node('issuer', $lang))"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'portrait')">
					<xsl:analyze-string select="." regex="portrait\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('portrait', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'deity')">
					<xsl:analyze-string select="." regex="deity\s&lt;(.*)&gt;">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('deity', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'authPerson')">
					<xsl:analyze-string select="." regex="authPerson\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('authority', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'authCorp')">
					<xsl:analyze-string select="." regex="authCorp\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('state', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'dynasty')">
					<xsl:analyze-string select="." regex="authCorp\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('dynasty', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'region')">
					<xsl:analyze-string select="." regex="region\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('region', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'nmo:hasTypeSeriesItem')">
					<xsl:analyze-string select="." regex="nmo:hasTypeSeriesItem\s&lt;(.*)&gt;">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('coinType', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="tokenize(regex-group(1), '/')[last()]"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="matches(normalize-space(.), '^from\s')">
					<xsl:analyze-string select="." regex="from\s(.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('fromDate', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="numishare:normalizeDate(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="matches(normalize-space(.), '^to\s')">
					<xsl:analyze-string select="." regex="to\s(.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node('toDate', $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="numishare:normalizeDate(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<xsl:analyze-string select="." regex="nmo:has([A-Za-z]+)\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:regularize_node(lower-case(regex-group(1)), $lang)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(2), $lang)"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(position() = last())">
				<xsl:text> &amp; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="nomisma:getLabel">
		<xsl:param name="uri"/>
		<xsl:param name="lang"/>

		<xsl:variable name="service" select="concat('http://nomisma.org/apis/getLabel?uri=', $uri, '&amp;lang=', $lang)"/>

		<xsl:value-of select="document($service)/response"/>
	</xsl:function>

	<!-- ***** Functions for linked.art JSON-LD serialization ***** -->
	<!-- expand the @standardDate into a fully compliant xs:dateTime -->
	<xsl:function name="numishare:expandDatetoDateTime">
		<xsl:param name="date"/>
		<xsl:param name="range"/>

		<xsl:variable name="time" select="
				if ($range = 'begin') then
					'T00:00:00Z'
				else
					'T23:59:59Z'"/>

		<!-- the data should be assumed to be XSD 1.0 compliant, which means that in order to make BC dates compliant to ISO 8601/XSD 1.1, 
			a year should be added mathematically so that 1 BC is "0000" in the JSON output -->
		<xsl:choose>
			<xsl:when test="substring($date, 1, 1) = '-'">
				<xsl:choose>
					<xsl:when test="$date castable as xs:gYear">
						<xsl:value-of
							select="
								concat(xs:date(concat($date, if ($range = 'begin') then
									'-01-01'
								else
									'-12-31')) + xs:dayTimeDuration('P365DT0M'), $time)"
						/>
					</xsl:when>
					<xsl:when test="$date castable as xs:gYearMonth">
						<xsl:value-of
							select="
								concat(xs:date(concat($date, if ($range = 'begin') then
									'-01'
								else
									'-31')) + xs:dayTimeDuration('P365DT0M'), $time)"
						/>
					</xsl:when>
					<xsl:when test="$date castable as xs:date">
						<xsl:value-of select="concat(xs:date($date) + xs:dayTimeDuration('P365DT0M'), $time)"/>
					</xsl:when>
					<xsl:when test="$date castable as xs:dateTime">
						<xsl:value-of select="$date"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$date castable as xs:gYear">
						<xsl:value-of select="
								concat($date, if ($range = 'begin') then
									'-01-01'
								else
									'-12-31', $time)"/>
					</xsl:when>
					<xsl:when test="$date castable as xs:gYearMonth">
						<xsl:value-of select="
								concat($date, if ($range = 'begin') then
									'-01'
								else
									'-31', $time)"/>
					</xsl:when>
					<xsl:when test="$date castable as xs:date">
						<xsl:value-of select="concat($date, $time)"/>
					</xsl:when>
					<xsl:when test="$date castable as xs:dateTime">
						<xsl:value-of select="$date"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<!-- convert XSD compliant date datatypes into ISO 8601 dates (e.g., 1 B.C., "-0001"^^xsd:gYear = "0000" in ISO 8601) -->
	<xsl:function name="numishare:xsdToIso">
		<xsl:param name="date"/>

		<xsl:variable name="year" select="
				if (substring($date, 1, 1) = '-') then
					substring($date, 1, 5)
				else
					substring($date, 1, 4)"/>
		<xsl:choose>
			<xsl:when test="number($year) &lt; 0">
				<!-- convert the year to ISO -->
				<xsl:value-of select="format-number(number($year) + 1, '0000')"/>
				<!-- include month and/or day when applicable -->
				<xsl:if test="string-length($date) &gt; 5">
					<xsl:value-of select="substring($date, 5)"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- result element names into AAT curies -->
	<xsl:function name="numishare:normalizeClassification">
		<xsl:param name="name"/>

		<!-- obverse/reverse = fronts/backs in AAT, not obverse and reverse -->

		<xsl:choose>
			<xsl:when test="$name = 'axis'">http://nomisma.org/id/axis</xsl:when>
			<xsl:when test="$name = 'thickness' or $name = 'depth'">aat:300072633</xsl:when>
			<xsl:when test="$name = 'diameter'">aat:300055624</xsl:when>
			<xsl:when test="$name = 'height'">aat:300055644</xsl:when>
			<xsl:when test="$name = 'identifier'">aat:300312355</xsl:when>
			<xsl:when test="$name = 'obverse'">aat:300190703</xsl:when>
			<xsl:when test="$name = 'reverse'">aat:300190692</xsl:when>
			<xsl:when test="$name = 'weight'">aat:300056240</xsl:when>
			<xsl:when test="$name = 'width'">aat:300055647</xsl:when>
			<xsl:otherwise>UNCLASSIFIED</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- normalize Nomisma URI to Getty vocabulary curie, if available -->
	<xsl:function name="numishare:resolveUriToCurie">
		<xsl:param name="uri"/>
		<xsl:param name="concept" as="node()*"/>

		<xsl:variable name="namespaces" as="item()*">
			<namespaces>
				<namespace prefix="aat" uri="http://vocab.getty.edu/aat/"/>
				<namespace prefix="nm" uri="http://nomisma.org/id/"/>
				<namespace prefix="tgn" uri="http://vocab.getty.edu/tgn/"/>
				<namespace prefix="ulan" uri="http://vocab.getty.edu/ulan/"/>
			</namespaces>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$namespaces//namespace[contains($uri, @uri)]/@prefix">
				<xsl:choose>
					<xsl:when test="$concept/skos:*[contains(local-name(), 'Match')][contains(@rdf:resource, 'http://vocab.getty.edu')]">
						<xsl:variable name="gettyURI"
							select="$concept/skos:*[contains(local-name(), 'Match')][contains(@rdf:resource, 'http://vocab.getty.edu')][1]/@rdf:resource"/>

						<xsl:value-of
							select="replace($gettyURI, $namespaces//namespace[contains($gettyURI, @uri)]/@uri, concat($namespaces//namespace[contains($gettyURI, @uri)]/@prefix, ':'))"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$uri"/>
						<!--<xsl:value-of
							select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
						/>-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uri"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
