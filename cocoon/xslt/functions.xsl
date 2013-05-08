<?xml version="1.0" encoding="UTF-8"?>
<!-- Repeated functions for regularization to be used through Numishare -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:numishare="http://code.google.com/p/numishare/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<!-- ************** NORMALIZATION TEMPLATES ************** -->
	<xsl:function name="nh:normalize_date">
		<xsl:param name="start_date"/>
		<xsl:param name="end_date"/>

		<xsl:choose>
			<xsl:when test="number($start_date) = number($end_date)">
				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- start date -->

				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
				<xsl:text> - </xsl:text>

				<!-- end date -->
				<xsl:if test="number($end_date) &lt; 500 and number($end_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($end_date))"/>
				<xsl:if test="number($end_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- normalize NUDS element -->
	<!-- Google spreadsheet regular expressions
		find: ([^\s]+)\t.*\t(.*)
		replace: <xsl:when test="\$label='$1'">$2</xsl:when>
	-->
	<xsl:function name="numishare:regularize_node">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:choose>
			<xsl:when test="$lang='ar'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">تعريف</xsl:when>
					<xsl:when test="$name='acquiredFrom'">مكان الحصول عليها</xsl:when>
					<xsl:when test="$name='appraisal'">القيمة</xsl:when>
					<xsl:when test="$name='appraiser'">من الذى حدد القيمة </xsl:when>
					<xsl:when test="$name='authority'">المسئول عنها</xsl:when>
					<xsl:when test="$name='axis'">المحور الرأسى </xsl:when>
					<xsl:when test="$name='collection'">دار الكتب و الوثائق القومية المصرية </xsl:when>
					<xsl:when test="$name='completeness'"> الحالة الخارجية </xsl:when>
					<xsl:when test="$name='condition'">الظروف </xsl:when>
					<xsl:when test="$name='conservationState'">حالة الترميم </xsl:when>
					<xsl:when test="$name='coordinates'">الإحداثيات </xsl:when>
					<xsl:when test="$name='countermark'">العلامة المائية </xsl:when>
					<xsl:when test="$name='provenance'">مكان وجود القطعة</xsl:when>
					<xsl:when test="$name='date'">التاريخ </xsl:when>
					<xsl:when test="$name='dateOnObject'">التاريخ مسجل على القطعة</xsl:when>
					<xsl:when test="$name='denomination'">طائفة</xsl:when>
					<xsl:when test="$name='department'">القسم</xsl:when>
					<xsl:when test="$name='deposit'">مكان الحفظ</xsl:when>
					<xsl:when test="$name='description'">التوصيف</xsl:when>
					<xsl:when test="$name='diameter'">قطر</xsl:when>
					<xsl:when test="$name='discovery'">الاكتشاف</xsl:when>
					<xsl:when test="$name='disposition'">تقسيم و ترتيب القطع</xsl:when>
					<xsl:when test="$name='edge'">الحواف </xsl:when>
					<xsl:when test="$name='era'">الفترة الزمنية </xsl:when>
					<xsl:when test="$name='finder'"> المكتشف </xsl:when>
					<xsl:when test="$name='findspot'">مكان اكتشاف القطعة </xsl:when>
					<xsl:when test="$name='geographic'">المكان </xsl:when>
					<xsl:when test="$name='grade'">تصنيف الحالة </xsl:when>
					<xsl:when test="$name='height'">الارتفاع </xsl:when>
					<xsl:when test="$name='identifier'">رقم السجل </xsl:when>
					<xsl:when test="$name='issuer'">السئول عن الضرب</xsl:when>
					<xsl:when test="$name='landowner'">المالك</xsl:when>
					<xsl:when test="$name='legend'">الكتابات</xsl:when>
					<xsl:when test="$name='material'">المادة الخام</xsl:when>
					<xsl:when test="$name='measurementsSet'">القياسات</xsl:when>
					<xsl:when test="$name='mint'">دار الضرب</xsl:when>
					<xsl:when test="$name='note'">ملاحظات</xsl:when>
					<xsl:when test="$name='objectType'">تصنيف القطعة</xsl:when>
					<xsl:when test="$name='obverse'">الوجه</xsl:when>
					<xsl:when test="$name='owner'">حائز القطعة</xsl:when>
					<xsl:when test="$name='portrait'">الصور</xsl:when>
					<xsl:when test="$name='private'">خصوصية القطعة </xsl:when>
					<xsl:when test="$name='public'">عمومية القطعة </xsl:when>
					<xsl:when test="$name='reference'">مرجع</xsl:when>
					<xsl:when test="$name='region'">المكان</xsl:when>
					<xsl:when test="$name='repository'">مكان وجود القطعة </xsl:when>
					<xsl:when test="$name='reverse'">الظهر </xsl:when>
					<xsl:when test="$name='saleCatalog'">الكتالوج </xsl:when>
					<xsl:when test="$name='saleItem'">الرقم بالكتالوج </xsl:when>
					<xsl:when test="$name='salePrice'">السعربالكتالوج </xsl:when>
					<xsl:when test="$name='shape'">الشكل الخارجى </xsl:when>
					<xsl:when test="$name='state'">السلطة </xsl:when>
					<xsl:when test="$name='symbol'">الرمز </xsl:when>
					<xsl:when test="$name='testmark'">علامات اختبارجودة القطع </xsl:when>
					<xsl:when test="$name='title'">اللقب </xsl:when>
					<xsl:when test="$name='type'">الطراز </xsl:when>
					<xsl:when test="$name='thickness'">السمك </xsl:when>
					<xsl:when test="$name='wear'">الحالة من الحفظ </xsl:when>
					<xsl:when test="$name='weight'">الوزن </xsl:when>
					<xsl:when test="$name='width'">العرض </xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='de'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Bestätigung</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Erworben von</xsl:when>
					<xsl:when test="$name='adminDesc'">Administrativ</xsl:when>
					<xsl:when test="$name='appraisal'">Schätzung</xsl:when>
					<xsl:when test="$name='appraiser'">Schätzer</xsl:when>
					<xsl:when test="$name='auction'">Auktion</xsl:when>
					<xsl:when test="$name='authority'">Autorität</xsl:when>
					<xsl:when test="$name='axis'">Stellung</xsl:when>
					<xsl:when test="$name='century'">Jahrhundert</xsl:when>
					<xsl:when test="$name='coinType'">Münztyp</xsl:when>
					<xsl:when test="$name='collection'">Sammlung</xsl:when>
					<xsl:when test="$name='color'">Farbe</xsl:when>
					<xsl:when test="$name='completeness'">Vollständigkeit</xsl:when>
					<xsl:when test="$name='condition'">Erhaltung</xsl:when>
					<xsl:when test="$name='conservationState'">Erhaltungszustand</xsl:when>
					<xsl:when test="$name='contents'">Inhalt</xsl:when>
					<xsl:when test="$name='coordinates'">Koordinaten</xsl:when>
					<xsl:when test="$name='countermark'">Gegenstemple</xsl:when>
					<xsl:when test="$name='provenance'">Herkunft</xsl:when>
					<xsl:when test="$name='date'">Datum</xsl:when>
					<xsl:when test="$name='dateOnObject'">Datum auf Gegenstand</xsl:when>
					<xsl:when test="$name='dob'">Datum auf Gegenstand</xsl:when>
					<xsl:when test="$name='dateRange'">Datierungsspanne</xsl:when>
					<xsl:when test="$name='decade'">Jahrzehnt</xsl:when>
					<xsl:when test="$name='degree'">Grad</xsl:when>
					<xsl:when test="$name='deity'">Gottheit</xsl:when>
					<xsl:when test="$name='denomination'">Nominale</xsl:when>
					<xsl:when test="$name='department'">Abteilung</xsl:when>
					<xsl:when test="$name='deposit'">Depot</xsl:when>
					<xsl:when test="$name='description'">Beschreibung</xsl:when>
					<xsl:when test="$name='diameter'">Durchmesser</xsl:when>
					<xsl:when test="$name='discovery'">Entdeckung</xsl:when>
					<xsl:when test="$name='disposition'">Disposition</xsl:when>
					<xsl:when test="$name='dynasty'">Dynastie</xsl:when>
					<xsl:when test="$name='edge'">Rand</xsl:when>
					<xsl:when test="$name='era'">Epoche</xsl:when>
					<xsl:when test="$name='finder'">Finder</xsl:when>
					<xsl:when test="$name='findspot'">Fundstelle</xsl:when>
					<xsl:when test="$name='fromDate'">Datum von</xsl:when>
					<xsl:when test="$name='geographic'">Geographisch</xsl:when>
					<xsl:when test="$name='grade'">Grad</xsl:when>
					<xsl:when test="$name='height'">Höhe</xsl:when>
					<xsl:when test="$name='hoardDes'">Schatzfundbeschreibung</xsl:when>
					<xsl:when test="$name='identifier'">Bestimmt von</xsl:when>
					<xsl:when test="$name='issuer'">Herausgeber</xsl:when>
					<xsl:when test="$name='landowner'">Grundstückseigentümer</xsl:when>
					<xsl:when test="$name='legend'">Legende</xsl:when>
					<xsl:when test="$name='manufacture'">Herstellung</xsl:when>
					<xsl:when test="$name='material'">Material</xsl:when>
					<xsl:when test="$name='measurementsSet'">Maße</xsl:when>
					<xsl:when test="$name='mint'">Münzstätte</xsl:when>
					<xsl:when test="$name='note'">Anmerkung</xsl:when>
					<xsl:when test="$name='notes'">Anmerkungen</xsl:when>
					<xsl:when test="$name='objectType'">Objekttyp</xsl:when>
					<xsl:when test="$name='obverse'">Vorderseite</xsl:when>
					<xsl:when test="$name='obv_leg'"> Vorderseitenlegende</xsl:when>
					<xsl:when test="$name='obv_type'">Vorderseitentyp</xsl:when>
					<xsl:when test="$name='owner'">Eigentümer</xsl:when>
					<xsl:when test="$name='physDesc'">Physische Beschreibung</xsl:when>
					<xsl:when test="$name='portrait'">Porträt</xsl:when>
					<xsl:when test="$name='previousColl'">Vormalige sammlung</xsl:when>
					<xsl:when test="$name='private'">Privat</xsl:when>
					<xsl:when test="$name='public'">öffentlich</xsl:when>
					<xsl:when test="$name='publisher'">Verlag</xsl:when>
					<xsl:when test="$name='reference'">Zitat</xsl:when>
					<xsl:when test="$name='refDesc'">Zitate</xsl:when>
					<xsl:when test="$name='region'">Region</xsl:when>
					<xsl:when test="$name='repository'">Depot</xsl:when>
					<xsl:when test="$name='reverse'">Rückseite</xsl:when>
					<xsl:when test="$name='rev_leg'">Rückseitenlegende</xsl:when>
					<xsl:when test="$name='rev_type'">Rückseitentyp</xsl:when>
					<xsl:when test="$name='saleCatalog'">Auktionskatalog</xsl:when>
					<xsl:when test="$name='saleItem'">Auktionslot</xsl:when>
					<xsl:when test="$name='salePrice'">Verkaufspreis</xsl:when>
					<xsl:when test="$name='shape'">Form</xsl:when>
					<xsl:when test="$name='state'">Zustand</xsl:when>
					<xsl:when test="$name='subject'">Subjekt</xsl:when>
					<xsl:when test="$name='subjectSet'">Subjekte</xsl:when>
					<xsl:when test="$name='symbol'">Symbol</xsl:when>
					<xsl:when test="$name='testmark'">Prüfmarke</xsl:when>
					<xsl:when test="$name='timestamp'">Moodifizierungsdatum</xsl:when>
					<xsl:when test="$name='title'">Titel</xsl:when>
					<xsl:when test="$name='toDate'">Datum bis</xsl:when>
					<xsl:when test="$name='type'">Typ</xsl:when>
					<xsl:when test="$name='typeDesc'">Typologische Beschreibung</xsl:when>
					<xsl:when test="$name='thickness'">Dicke</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Untertyp Beschreibung</xsl:when>
					<xsl:when test="$name='wear'">Abnutzung</xsl:when>
					<xsl:when test="$name='weight'">Gewicht</xsl:when>
					<xsl:when test="$name='width'">Breite</xsl:when>
					<xsl:when test="$name='year'">Jahr</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='el'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Ευχαριστίες</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Πρόσκτημα από</xsl:when>
					<xsl:when test="$name='adminDesc'">Ιστορία διαχείρισης</xsl:when>
					<xsl:when test="$name='appraisal'">Αξιολόγηση</xsl:when>
					<xsl:when test="$name='appraiser'">Αξιολογητής</xsl:when>
					<xsl:when test="$name='auction'">Δημοπρασία</xsl:when>
					<xsl:when test="$name='authority'">Εκδότρια αρχή</xsl:when>
					<xsl:when test="$name='axis'">Άξονας</xsl:when>
					<xsl:when test="$name='century'">Αιώνας</xsl:when>
					<xsl:when test="$name='coinType'">Νομισματικός τύπος</xsl:when>
					<xsl:when test="$name='collection'">Συλλογή</xsl:when>
					<xsl:when test="$name='color'">Χρώμα</xsl:when>
					<xsl:when test="$name='completeness'">Πληρότητα</xsl:when>
					<xsl:when test="$name='condition'">Διατήρηση</xsl:when>
					<xsl:when test="$name='conservationState'">Κατάσταση συντήρησης</xsl:when>
					<xsl:when test="$name='contents'">Περιεχόμενα</xsl:when>
					<xsl:when test="$name='coordinates'">Συντεταγμένες</xsl:when>
					<xsl:when test="$name='countermark'">Επισήμανση</xsl:when>
					<xsl:when test="$name='date'">Χρονολόγηση</xsl:when>
					<xsl:when test="$name='dateOnObject'">Χρονολογία επί του αντικειμένου</xsl:when>
					<xsl:when test="$name='dob'">Χρονολογία επί του αντικειμένου</xsl:when>
					<xsl:when test="$name='dateRange'">Χρονική περίοδος</xsl:when>
					<xsl:when test="$name='decade'">Δεκαετία</xsl:when>
					<xsl:when test="$name='degree'">Βαθμός</xsl:when>
					<xsl:when test="$name='deity'">Θεότητα</xsl:when>
					<xsl:when test="$name='denomination'">Νομισματική αξία</xsl:when>
					<xsl:when test="$name='department'">Τμήμα</xsl:when>
					<xsl:when test="$name='deposit'">Αποθέτης</xsl:when>
					<xsl:when test="$name='description'">Περιγραφή</xsl:when>
					<xsl:when test="$name='diameter'">Διάμετρος</xsl:when>
					<xsl:when test="$name='discovery'">Ανεύρεση</xsl:when>
					<xsl:when test="$name='disposition'">Διάταξη</xsl:when>
					<xsl:when test="$name='dynasty'">Δυναστεία</xsl:when>
					<xsl:when test="$name='edge'">Περιφέρεια</xsl:when>
					<xsl:when test="$name='era'">Εποχή</xsl:when>
					<xsl:when test="$name='finder'">Ευρετής</xsl:when>
					<xsl:when test="$name='findspot'">Σημείο εύρεσης</xsl:when>
					<xsl:when test="$name='fromDate'">Μετά από το έτος</xsl:when>
					<xsl:when test="$name='geographic'">Γεωγραφικό</xsl:when>
					<xsl:when test="$name='grade'">Διαβάθμιση</xsl:when>
					<xsl:when test="$name='height'">Ύψος</xsl:when>
					<xsl:when test="$name='hoardDesc'">Περιγραφή «θησαυρού»</xsl:when>
					<xsl:when test="$name='identifier'">Υπεύθυνος ταύτισης</xsl:when>
					<xsl:when test="$name='issuer'">Υπεύθυνος έκδοσης</xsl:when>
					<xsl:when test="$name='landowner'">Ιδιοκτήτης χώρου ανεύρεσης</xsl:when>
					<xsl:when test="$name='legend'">Επιγραφή</xsl:when>
					<xsl:when test="$name='manufacture'">Τρόπος κατασκευής</xsl:when>
					<xsl:when test="$name='material'">Υλικό</xsl:when>
					<xsl:when test="$name='measurementsSet'">Διαστάσεις</xsl:when>
					<xsl:when test="$name='mint'">Νομισματοκοπείο</xsl:when>
					<xsl:when test="$name='note'">Σημείωση</xsl:when>
					<xsl:when test="$name='noteSet'">Σημειώσεις</xsl:when>
					<xsl:when test="$name='objectType'">Είδος αντικειμένου</xsl:when>
					<xsl:when test="$name='obverse'">Εμπροσθότυπος</xsl:when>
					<xsl:when test="$name='obv_leg'">Επιγραφή εμπροσθοτύπου</xsl:when>
					<xsl:when test="$name='obv_type'">Παράσταση εμπροσθοτύπου</xsl:when>
					<xsl:when test="$name='owner'">Ιδιοκτήτης</xsl:when>
					<xsl:when test="$name='physDesc'">Φυσική περιγραφή</xsl:when>
					<xsl:when test="$name='portrait'">Πορτραίτο</xsl:when>
					<xsl:when test="$name='previousColl'">Προηγούμενη συλλογή</xsl:when>
					<xsl:when test="$name='private'">Ιδιωτικό</xsl:when>
					<xsl:when test="$name='provenance'">Προέλευση</xsl:when>
					<xsl:when test="$name='public'">Δημόσιο</xsl:when>
					<xsl:when test="$name='publisher'">Εκδότης</xsl:when>
					<xsl:when test="$name='reference'">Παραπομπή</xsl:when>
					<xsl:when test="$name='refDesc'">Παραπομπές</xsl:when>
					<xsl:when test="$name='region'">Περιοχή</xsl:when>
					<xsl:when test="$name='repository'">Χώρος φύλαξης</xsl:when>
					<xsl:when test="$name='reverse'">Οπισθότυπος</xsl:when>
					<xsl:when test="$name='rev_leg'">Επιγραφή οπισθοτύπου</xsl:when>
					<xsl:when test="$name='rev_type'">Παράσταση οπισθοτύπου</xsl:when>
					<xsl:when test="$name='saleCatalog'">Κατάλογος δημοπρασίας</xsl:when>
					<xsl:when test="$name='saleItem'">Αριθμός λαχνού δημοπρασίας</xsl:when>
					<xsl:when test="$name='salePrice'">Τιμή δημοπράτησης</xsl:when>
					<xsl:when test="$name='shape'">Σχήμα</xsl:when>
					<xsl:when test="$name='state'">Κατάσταση</xsl:when>
					<xsl:when test="$name='subject'">Θέμα</xsl:when>
					<xsl:when test="$name='subjectSet'">Θέματα</xsl:when>
					<xsl:when test="$name='symbol'">Σύμβολο</xsl:when>
					<xsl:when test="$name='testmark'">Δοκιμαστική χάραξη</xsl:when>
					<xsl:when test="$name='timestamp'">Ημερομηνία τροποποίησης εγγραφής</xsl:when>
					<xsl:when test="$name='title'">Τίτλος</xsl:when>
					<xsl:when test="$name='toDate'">Μέχρι το έτος</xsl:when>
					<xsl:when test="$name='type'">Τύπος</xsl:when>
					<xsl:when test="$name='typeDesc'">Τυπολογική περιγραφή</xsl:when>
					<xsl:when test="$name='thickness'">Πάχος</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Περιγραφή υποκείμενου τύπου</xsl:when>
					<xsl:when test="$name='wear'">Βαθμός φθοράς</xsl:when>
					<xsl:when test="$name='weight'">Βάρος</xsl:when>
					<xsl:when test="$name='width'">Πλάτος</xsl:when>
					<xsl:when test="$name='year'">Έτος</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='fr'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Remerciement</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Acquis de </xsl:when>
					<xsl:when test="$name='adminDesc'">Historique administratif</xsl:when>
					<xsl:when test="$name='appraisal'">Valorisation</xsl:when>
					<xsl:when test="$name='appraiser'">Evaluateur</xsl:when>
					<xsl:when test="$name='authority'">Autorité émettrice</xsl:when>
					<xsl:when test="$name='axis'">Axe</xsl:when>
					<xsl:when test="$name='century'">Siècle</xsl:when>
					<xsl:when test="$name='coinType'">Type de monnaie</xsl:when>
					<xsl:when test="$name='collection'">Collection</xsl:when>
					<xsl:when test="$name='color'">Couleur</xsl:when>
					<xsl:when test="$name='completeness'">Intégrité</xsl:when>
					<xsl:when test="$name='condition'">Etat de conservation</xsl:when>
					<xsl:when test="$name='conservationState'">Etat de conservation</xsl:when>
					<xsl:when test="$name='contents'">Contenu</xsl:when>
					<xsl:when test="$name='coordinates'">Coordonnées</xsl:when>
					<xsl:when test="$name='countermark'">Contremarque</xsl:when>
					<xsl:when test="$name='date'">Date</xsl:when>
					<xsl:when test="$name='dateRange'">Intervalle chronologique</xsl:when>
					<xsl:when test="$name='dateOnObject'">Date sur l'objet</xsl:when>
					<xsl:when test="$name='decade'">Décennie</xsl:when>
					<xsl:when test="$name='degree'">Degré</xsl:when>
					<xsl:when test="$name='deity'">Divinité</xsl:when>
					<xsl:when test="$name='dob'">Date sur l'objet</xsl:when>
					<xsl:when test="$name='denomination'">Dénomination</xsl:when>
					<xsl:when test="$name='department'">Département</xsl:when>
					<xsl:when test="$name='deposit'">Dépôt</xsl:when>
					<xsl:when test="$name='description'">Description</xsl:when>
					<xsl:when test="$name='diameter'">Diamètre</xsl:when>
					<xsl:when test="$name='discovery'">Découverte</xsl:when>
					<xsl:when test="$name='disposition'">Disposition</xsl:when>
					<xsl:when test="$name='dynasty'">Dynastie</xsl:when>
					<xsl:when test="$name='edge'">Bordure</xsl:when>
					<xsl:when test="$name='era'">Ere</xsl:when>
					<xsl:when test="$name='finder'">Inventeur</xsl:when>
					<xsl:when test="$name='findspot'">Lieu de découverte</xsl:when>
					<xsl:when test="$name='fromDate'">A partir de l'année</xsl:when>
					<xsl:when test="$name='geographic'">Géographique</xsl:when>
					<xsl:when test="$name='grade'">Etat</xsl:when>
					<xsl:when test="$name='height'">Hauteur</xsl:when>
					<xsl:when test="$name='hoard'">Trésor</xsl:when>
					<xsl:when test="$name='hoardDesc'">Description du trésor</xsl:when>
					<xsl:when test="$name='identifier'">Identifiant</xsl:when>
					<xsl:when test="$name='issuer'">Emetteur</xsl:when>
					<xsl:when test="$name='landowner'">Propriétaire du sol</xsl:when>
					<xsl:when test="$name='legend'">Légende</xsl:when>
					<xsl:when test="$name='manufacture'">Technique d'émission</xsl:when>
					<xsl:when test="$name='material'">Matériau</xsl:when>
					<xsl:when test="$name='measurementsSet'">Mesures</xsl:when>
					<xsl:when test="$name='mint'">Atelier</xsl:when>
					<xsl:when test="$name='note'">Note</xsl:when>
					<xsl:when test="$name='objectType'">Type d'objet</xsl:when>
					<xsl:when test="$name='obverse'">Avers/Droit</xsl:when>
					<xsl:when test="$name='obv_leg'"> Légende d'avers/de droit</xsl:when>
					<xsl:when test="$name='obv_type'">Type d'avers</xsl:when>
					<xsl:when test="$name='owner'">Propriétaire</xsl:when>
					<xsl:when test="$name='physDesc'">Description physique</xsl:when>
					<xsl:when test="$name='portrait'">Portrait</xsl:when>
					<xsl:when test="$name='private'">Privé</xsl:when>
					<xsl:when test="$name='provenance'">Provenance</xsl:when>
					<xsl:when test="$name='public'">Publique</xsl:when>
					<xsl:when test="$name='publisher'">Maison d'édition</xsl:when>
					<xsl:when test="$name='reference'">Référence</xsl:when>
					<xsl:when test="$name='refDesc'">Références</xsl:when>
					<xsl:when test="$name='region'">Région</xsl:when>
					<xsl:when test="$name='repository'">Dépositaire</xsl:when>
					<xsl:when test="$name='reverse'">Revers</xsl:when>
					<xsl:when test="$name='rev_leg'">Légende de revers</xsl:when>
					<xsl:when test="$name='rev_type'">Type de revers</xsl:when>
					<xsl:when test="$name='saleCatalog'">Catalogue de vente</xsl:when>
					<xsl:when test="$name='saleItem'">Numéro de lot</xsl:when>
					<xsl:when test="$name='salePrice'">Prix de vente</xsl:when>
					<xsl:when test="$name='shape'">Forme</xsl:when>
					<xsl:when test="$name='state'">Etat</xsl:when>
					<xsl:when test="$name='subject'">Sujet</xsl:when>
					<xsl:when test="$name='subjectSet'">Sujets</xsl:when>
					<xsl:when test="$name='symbol'">Symbole</xsl:when>
					<xsl:when test="$name='testmark'">Marque de test</xsl:when>
					<xsl:when test="$name='timestamp'">Date de modification de l'entrée catalogue</xsl:when>
					<xsl:when test="$name='title'">Titre</xsl:when>
					<xsl:when test="$name='toDate'">Jusqu'à l'année</xsl:when>
					<xsl:when test="$name='type'">Type</xsl:when>
					<xsl:when test="$name='typeDesc'">Description typologique</xsl:when>
					<xsl:when test="$name='thickness'">Epaisseur</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Description du sous-type</xsl:when>
					<xsl:when test="$name='wear'">Usure</xsl:when>
					<xsl:when test="$name='weight'">Poids</xsl:when>
					<xsl:when test="$name='width'">Largeur</xsl:when>
					<xsl:when test="$name='year'">Année</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='it'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Riconoscimento</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Acqusito da</xsl:when>
					<xsl:when test="$name='adminDesc'">Storia amministrativa</xsl:when>
					<xsl:when test="$name='appraisal'">Stima</xsl:when>
					<xsl:when test="$name='appraiser'">Perito</xsl:when>
					<xsl:when test="$name='auction'">Asta</xsl:when>
					<xsl:when test="$name='authority'">Autorità emittente</xsl:when>
					<xsl:when test="$name='axis'">Asse</xsl:when>
					<xsl:when test="$name='century'">Secolo</xsl:when>
					<xsl:when test="$name='coinType'">Tipo monetale</xsl:when>
					<xsl:when test="$name='collection'">Collezione</xsl:when>
					<xsl:when test="$name='color'">Colore</xsl:when>
					<xsl:when test="$name='completeness'">Integrità</xsl:when>
					<xsl:when test="$name='condition'">Conservazione</xsl:when>
					<xsl:when test="$name='conservationState'">Stato di conservazione</xsl:when>
					<xsl:when test="$name='contents'">Sommario</xsl:when>
					<xsl:when test="$name='coordinates'">Coordinate</xsl:when>
					<xsl:when test="$name='countermark'">Contromarca</xsl:when>
					<xsl:when test="$name='date'">Data</xsl:when>
					<xsl:when test="$name='dateOnObject'">Datazione dell'oggetto</xsl:when>
					<xsl:when test="$name='dob'">Datazione dell'oggetto</xsl:when>
					<xsl:when test="$name='dateRange'">Arco cronologico</xsl:when>
					<xsl:when test="$name='decade'">Decennio</xsl:when>
					<xsl:when test="$name='degree'">Grado</xsl:when>
					<xsl:when test="$name='deity'">Divinità</xsl:when>
					<xsl:when test="$name='denomination'">Nominale</xsl:when>
					<xsl:when test="$name='department'">Dipartimento</xsl:when>
					<xsl:when test="$name='deposit'">Deposito</xsl:when>
					<xsl:when test="$name='description'">Descrizione</xsl:when>
					<xsl:when test="$name='diameter'">Diametro</xsl:when>
					<xsl:when test="$name='discovery'">Scoperta</xsl:when>
					<xsl:when test="$name='disposition'">Deposizione</xsl:when>
					<xsl:when test="$name='dynasty'">Dinastia</xsl:when>
					<xsl:when test="$name='edge'">Bordo</xsl:when>
					<xsl:when test="$name='era'">Periodo</xsl:when>
					<xsl:when test="$name='finder'">Scopritore</xsl:when>
					<xsl:when test="$name='findspot'">Luogo di rinvenimento</xsl:when>
					<xsl:when test="$name='fromDate'">A partire dall'anno</xsl:when>
					<xsl:when test="$name='geographic'">Geografico</xsl:when>
					<xsl:when test="$name='grade'">Grado</xsl:when>
					<xsl:when test="$name='height'">Altezza</xsl:when>
					<xsl:when test="$name='hoardDesc'">Descrizione del ripostiglio</xsl:when>
					<xsl:when test="$name='identifier'">[]</xsl:when>
					<xsl:when test="$name='issuer'">Emittente</xsl:when>
					<xsl:when test="$name='landowner'">Proprietario del terreno</xsl:when>
					<xsl:when test="$name='legend'">Legenda</xsl:when>
					<xsl:when test="$name='manufacture'">Tecnica di produzione</xsl:when>
					<xsl:when test="$name='material'">Materiale</xsl:when>
					<xsl:when test="$name='measurementsSet'">Dimensioni</xsl:when>
					<xsl:when test="$name='mint'">Zecca</xsl:when>
					<xsl:when test="$name='note'">Nota</xsl:when>
					<xsl:when test="$name='noteSet'">Annotazioni</xsl:when>
					<xsl:when test="$name='objectType'">Tipo d'oggetto</xsl:when>
					<xsl:when test="$name='obverse'">Dritto</xsl:when>
					<xsl:when test="$name='obv_leg'">Legenda del dritto</xsl:when>
					<xsl:when test="$name='obv_type'">Tipo del dritto</xsl:when>
					<xsl:when test="$name='owner'">Proprietario</xsl:when>
					<xsl:when test="$name='physDesc'">Descrizione fisica</xsl:when>
					<xsl:when test="$name='portrait'">Ritratto</xsl:when>
					<xsl:when test="$name='previousColl'">Collezione precedente</xsl:when>
					<xsl:when test="$name='private'">Privato</xsl:when>
					<xsl:when test="$name='provenance'">Provenienza</xsl:when>
					<xsl:when test="$name='public'">Pubblico</xsl:when>
					<xsl:when test="$name='publisher'">Editore</xsl:when>
					<xsl:when test="$name='reference'">Riferimento</xsl:when>
					<xsl:when test="$name='refDesc'">Riferimenti</xsl:when>
					<xsl:when test="$name='region'">Regione</xsl:when>
					<xsl:when test="$name='repository'">Deposito</xsl:when>
					<xsl:when test="$name='reverse'">Rovescio</xsl:when>
					<xsl:when test="$name='rev_leg'">Legenda del rovescio</xsl:when>
					<xsl:when test="$name='rev_type'">Tipo del rovescio</xsl:when>
					<xsl:when test="$name='saleCatalog'">Catalogo d'asta</xsl:when>
					<xsl:when test="$name='saleItem'">Numero del lotto</xsl:when>
					<xsl:when test="$name='salePrice'">Prezzo d'asta</xsl:when>
					<xsl:when test="$name='shape'">Forma</xsl:when>
					<xsl:when test="$name='state'">Stato</xsl:when>
					<xsl:when test="$name='subject'">Soggetto</xsl:when>
					<xsl:when test="$name='subjectSet'">Soggetti</xsl:when>
					<xsl:when test="$name='symbol'">Simbolo</xsl:when>
					<xsl:when test="$name='testmark'">Punzonatura</xsl:when>
					<xsl:when test="$name='timestamp'">[]</xsl:when>
					<xsl:when test="$name='title'">Titolo</xsl:when>
					<xsl:when test="$name='toDate'">Fino all'anno</xsl:when>
					<xsl:when test="$name='type'">Tipo</xsl:when>
					<xsl:when test="$name='typeDesc'">Descrizione del tipo</xsl:when>
					<xsl:when test="$name='thickness'">Spessore</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Descrizione del sottotipo</xsl:when>
					<xsl:when test="$name='wear'">Usura</xsl:when>
					<xsl:when test="$name='weight'">Peso</xsl:when>
					<xsl:when test="$name='width'">Larghezza</xsl:when>
					<xsl:when test="$name='year'">Anno</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='nl'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Dankbetuiging</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Verworven van</xsl:when>
					<xsl:when test="$name='adminDesc'">Administratieve geschiedenis</xsl:when>
					<xsl:when test="$name='appraisal'">Taxatie</xsl:when>
					<xsl:when test="$name='appraiser'">Taxateur</xsl:when>
					<xsl:when test="$name='auction'">Veiling</xsl:when>
					<xsl:when test="$name='authority'">Autoriteit</xsl:when>
					<xsl:when test="$name='axis'">Stempelstand</xsl:when>
					<xsl:when test="$name='century'">Eeuw</xsl:when>
					<xsl:when test="$name='coinType'">Munttype</xsl:when>
					<xsl:when test="$name='collection'">Collectie</xsl:when>
					<xsl:when test="$name='color'">Kleur</xsl:when>
					<xsl:when test="$name='completeness'">Compleetheid</xsl:when>
					<xsl:when test="$name='condition'">Conditie</xsl:when>
					<xsl:when test="$name='conservationState'">Staat van conservering</xsl:when>
					<xsl:when test="$name='contents'">Inhoud</xsl:when>
					<xsl:when test="$name='coordinates'">Coördinaten</xsl:when>
					<xsl:when test="$name='countermark'">Instempeling</xsl:when>
					<xsl:when test="$name='date'">Datum</xsl:when>
					<xsl:when test="$name='dateOnObject'">Datum op voorwerp</xsl:when>
					<xsl:when test="$name='dob'">Datum op voorwerp</xsl:when>
					<xsl:when test="$name='dateRange'">Dateringsperiode</xsl:when>
					<xsl:when test="$name='decade'">Decennium</xsl:when>
					<xsl:when test="$name='degree'">Graad</xsl:when>
					<xsl:when test="$name='deity'">Godheid</xsl:when>
					<xsl:when test="$name='denomination'">Denominatie</xsl:when>
					<xsl:when test="$name='department'">Afdeling</xsl:when>
					<xsl:when test="$name='deposit'">Depot</xsl:when>
					<xsl:when test="$name='description'">Beschrijving</xsl:when>
					<xsl:when test="$name='diameter'">Diameter</xsl:when>
					<xsl:when test="$name='discovery'">Vondst</xsl:when>
					<xsl:when test="$name='disposition'">Verplaatsing</xsl:when>
					<xsl:when test="$name='dynasty'">Dynastie</xsl:when>
					<xsl:when test="$name='edge'">Rand</xsl:when>
					<xsl:when test="$name='era'">Periode</xsl:when>
					<xsl:when test="$name='finder'">Vinder</xsl:when>
					<xsl:when test="$name='findspot'">Vindplaats</xsl:when>
					<xsl:when test="$name='fromDate'">Datum van</xsl:when>
					<xsl:when test="$name='geographic'">Geografisch</xsl:when>
					<xsl:when test="$name='grade'">Kwaliteitsaanduiding</xsl:when>
					<xsl:when test="$name='height'">Hoogte</xsl:when>
					<xsl:when test="$name='hoardDesc'">Schatvondstbeschrijving</xsl:when>
					<xsl:when test="$name='identifier'">Beschrijver</xsl:when>
					<xsl:when test="$name='issuer'">Uitgever</xsl:when>
					<xsl:when test="$name='landowner'">Grondeigenaar</xsl:when>
					<xsl:when test="$name='legend'">Om- of opschrift</xsl:when>
					<xsl:when test="$name='manufacture'">Maakwijze</xsl:when>
					<xsl:when test="$name='material'">Materiaal</xsl:when>
					<xsl:when test="$name='measurementsSet'">Afmetingen</xsl:when>
					<xsl:when test="$name='mint'">Muntplaats</xsl:when>
					<xsl:when test="$name='note'">Opmerking</xsl:when>
					<xsl:when test="$name='noteSet'">Opmerkingen</xsl:when>
					<xsl:when test="$name='objectType'">Objecttype</xsl:when>
					<xsl:when test="$name='obverse'">Voorzijde</xsl:when>
					<xsl:when test="$name='obv_leg'">Tekst voorzijde</xsl:when>
					<xsl:when test="$name='obv_type'">Voorzijdetype</xsl:when>
					<xsl:when test="$name='owner'">Eigenaar</xsl:when>
					<xsl:when test="$name='physDesc'">Fysieke beschrijving</xsl:when>
					<xsl:when test="$name='portrait'">Portret</xsl:when>
					<xsl:when test="$name='previousColl'">Voormalige collectie</xsl:when>
					<xsl:when test="$name='private'">Privé</xsl:when>
					<xsl:when test="$name='provenance'">Herkomst</xsl:when>
					<xsl:when test="$name='public'">Publiek</xsl:when>
					<xsl:when test="$name='publisher'">Uitgever</xsl:when>
					<xsl:when test="$name='reference'">Referentie</xsl:when>
					<xsl:when test="$name='refDesc'">Referenties</xsl:when>
					<xsl:when test="$name='region'">Regio</xsl:when>
					<xsl:when test="$name='repository'">Verblijfplaats</xsl:when>
					<xsl:when test="$name='reverse'">Keerzijde</xsl:when>
					<xsl:when test="$name='rev_leg'">Tekst keerzijde</xsl:when>
					<xsl:when test="$name='rev_type'">keerzijdetype</xsl:when>
					<xsl:when test="$name='saleCatalog'">Veilingcatalogus</xsl:when>
					<xsl:when test="$name='saleItem'">Kavel nummer</xsl:when>
					<xsl:when test="$name='salePrice'">Verkoopprijs</xsl:when>
					<xsl:when test="$name='shape'">Vorm</xsl:when>
					<xsl:when test="$name='state'">Staat</xsl:when>
					<xsl:when test="$name='subject'">Onderwerp</xsl:when>
					<xsl:when test="$name='subjectSet'">Onderwerpen</xsl:when>
					<xsl:when test="$name='symbol'">Symbool</xsl:when>
					<xsl:when test="$name='testmark'">Testmerk</xsl:when>
					<xsl:when test="$name='timestamp'">Wijzigingsdatum record</xsl:when>
					<xsl:when test="$name='title'">Titel</xsl:when>
					<xsl:when test="$name='toDate'">Datum tot</xsl:when>
					<xsl:when test="$name='type'">Type</xsl:when>
					<xsl:when test="$name='typeDesc'">Typologische beschrijving</xsl:when>
					<xsl:when test="$name='thickness'">Dikte</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Subtype beschrijving</xsl:when>
					<xsl:when test="$name='wear'">Slijtage</xsl:when>
					<xsl:when test="$name='weight'">Massa</xsl:when>
					<xsl:when test="$name='width'">Breedte</xsl:when>
					<xsl:when test="$name='year'">Jaar</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='ro'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Mulţumiri</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Achiziţionat de la</xsl:when>
					<xsl:when test="$name='adminDesc'">Istoric administrativ</xsl:when>
					<xsl:when test="$name='appraisal'">Evaluare</xsl:when>
					<xsl:when test="$name='appraiser'">Evaluator</xsl:when>
					<xsl:when test="$name='authority'">Autoritate emitentă</xsl:when>
					<xsl:when test="$name='axis'">Axă</xsl:when>
					<xsl:when test="$name='century'">Secol</xsl:when>
					<xsl:when test="$name='coinType'">Tip monetar</xsl:when>
					<xsl:when test="$name='collection'">Colecţie</xsl:when>
					<xsl:when test="$name='color'">Culoare</xsl:when>
					<xsl:when test="$name='completeness'">Integralitate</xsl:when>
					<xsl:when test="$name='condition'">Stare de conservare</xsl:when>
					<xsl:when test="$name='conservationState'">Stare de conservare</xsl:when>
					<xsl:when test="$name='contents'">Conţinut</xsl:when>
					<xsl:when test="$name='coordinates'">Coordonate</xsl:when>
					<xsl:when test="$name='countermark'">Contramarcă</xsl:when>
					<xsl:when test="$name='provenance'">Provenienţă</xsl:when>
					<xsl:when test="$name='date'">Datare</xsl:when>
					<xsl:when test="$name='dateOnObject'">Datarea de pe obiect</xsl:when>
					<xsl:when test="$name='dob'">Datarea de pe obiect</xsl:when>
					<xsl:when test="$name='dateRange'">Interval de datare</xsl:when>
					<xsl:when test="$name='decade'">Deceniu</xsl:when>
					<xsl:when test="$name='degree'">Grad</xsl:when>
					<xsl:when test="$name='deity'">Divinitate</xsl:when>
					<xsl:when test="$name='denomination'">Nominal</xsl:when>
					<xsl:when test="$name='department'">Departament</xsl:when>
					<xsl:when test="$name='deposit'">Depozit</xsl:when>
					<xsl:when test="$name='description'">Descriere</xsl:when>
					<xsl:when test="$name='diameter'">Diametru</xsl:when>
					<xsl:when test="$name='discovery'">Descoperire</xsl:when>
					<xsl:when test="$name='disposition'">Dispunere</xsl:when>
					<xsl:when test="$name='dynasty'">Dinastie</xsl:when>
					<xsl:when test="$name='edge'">Margine</xsl:when>
					<xsl:when test="$name='era'">Era</xsl:when>
					<xsl:when test="$name='finder'">Descoperitor</xsl:when>
					<xsl:when test="$name='findspot'">Loc de descoperire</xsl:when>
					<xsl:when test="$name='fromDate'">[]</xsl:when>
					<xsl:when test="$name='fulltext'">Cuvinte cheie</xsl:when>
					<xsl:when test="$name='geographic'">Geografic</xsl:when>
					<xsl:when test="$name='grade'">Stadiu</xsl:when>
					<xsl:when test="$name='height'">Înălţime</xsl:when>
					<xsl:when test="$name='hoardDes'">Descrierea tezaurului</xsl:when>
					<xsl:when test="$name='identifier'">Identificator</xsl:when>
					<xsl:when test="$name='issuer'">Emitent</xsl:when>
					<xsl:when test="$name='landowner'">Proprietarul locului de descoperire</xsl:when>
					<xsl:when test="$name='legend'">Legenda</xsl:when>
					<xsl:when test="$name='manufacture'">Mod de fabricare</xsl:when>
					<xsl:when test="$name='material'">Material</xsl:when>
					<xsl:when test="$name='measurementsSet'">Dimensiuni</xsl:when>
					<xsl:when test="$name='mint'">Monetărie</xsl:when>
					<xsl:when test="$name='note'">Observaţie</xsl:when>
					<xsl:when test="$name='objectType'">Tipul obiectului</xsl:when>
					<xsl:when test="$name='obverse'">Avers</xsl:when>
					<xsl:when test="$name='obv_leg'"> Legenda aversului</xsl:when>
					<xsl:when test="$name='obv_type'">Tip de avers</xsl:when>
					<xsl:when test="$name='owner'">Proprietar</xsl:when>
					<xsl:when test="$name='physDesc'">Descriere fizică</xsl:when>
					<xsl:when test="$name='portrait'">Portret</xsl:when>
					<xsl:when test="$name='private'">Privat</xsl:when>
					<xsl:when test="$name='public'">Public</xsl:when>
					<xsl:when test="$name='reference'">Referinţă</xsl:when>
					<xsl:when test="$name='refDesc'">Referinţe</xsl:when>
					<xsl:when test="$name='region'">Regiune</xsl:when>
					<xsl:when test="$name='repository'">Depozitar</xsl:when>
					<xsl:when test="$name='reverse'">Revers</xsl:when>
					<xsl:when test="$name='rev_leg'">Legenda reversului</xsl:when>
					<xsl:when test="$name='rev_type'">Tip de revers</xsl:when>
					<xsl:when test="$name='saleCatalog'">Catalog de vânzare</xsl:when>
					<xsl:when test="$name='saleItem'">Numărul lotului</xsl:when>
					<xsl:when test="$name='salePrice'">Preţ de vânzare</xsl:when>
					<xsl:when test="$name='shape'">Formă</xsl:when>
					<xsl:when test="$name='state'">Stadiu</xsl:when>
					<xsl:when test="$name='subject'">Subiect</xsl:when>
					<xsl:when test="$name='subjectSet'">Subiecte</xsl:when>
					<xsl:when test="$name='symbol'">Simbol</xsl:when>
					<xsl:when test="$name='testmark'">Marcă de test</xsl:when>
					<xsl:when test="$name='timestamp'">Data modificării de intrare în catalog</xsl:when>
					<xsl:when test="$name='title'">Titlu</xsl:when>
					<xsl:when test="$name='toDate'">Până în/la (datare)</xsl:when>
					<xsl:when test="$name='type'">Tip</xsl:when>
					<xsl:when test="$name='typeDesc'">Descriere tipologică</xsl:when>
					<xsl:when test="$name='thickness'">Grosime</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Descrierea subtipului</xsl:when>
					<xsl:when test="$name='wear'">Uzură</xsl:when>
					<xsl:when test="$name='weight'">Greutate</xsl:when>
					<xsl:when test="$name='width'">Lăţime</xsl:when>
					<xsl:when test="$name='year'">An</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='ru'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">Благодарность</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Получены от</xsl:when>
					<xsl:when test="$name='adminDesc'">Административная история</xsl:when>
					<xsl:when test="$name='appraisal'">Оценка</xsl:when>
					<xsl:when test="$name='appraiser'">Оценщик</xsl:when>
					<xsl:when test="$name='auction'">Аукцион</xsl:when>
					<xsl:when test="$name='authority'">Полномочия</xsl:when>
					<xsl:when test="$name='axis'">Ось</xsl:when>
					<xsl:when test="$name='century'">Век</xsl:when>
					<xsl:when test="$name='coinType'">Монетный тип</xsl:when>
					<xsl:when test="$name='collection'">Собрание</xsl:when>
					<xsl:when test="$name='color'">Цвет</xsl:when>
					<xsl:when test="$name='completeness'">Полнота</xsl:when>
					<xsl:when test="$name='condition'">Условие</xsl:when>
					<xsl:when test="$name='conservationState'">Состояние</xsl:when>
					<xsl:when test="$name='contents'">Содержание</xsl:when>
					<xsl:when test="$name='coordinates'">Координаты</xsl:when>
					<xsl:when test="$name='countermark'">Контрамарка</xsl:when>
					<xsl:when test="$name='date'">Датировка</xsl:when>
					<xsl:when test="$name='dateOnObject'">Датировка предмета</xsl:when>
					<xsl:when test="$name='dob'">Датировка предмета</xsl:when>
					<xsl:when test="$name='dateRange'">Диапазон дат</xsl:when>
					<xsl:when test="$name='decade'">Десятилетие</xsl:when>
					<xsl:when test="$name='degree'">Степень</xsl:when>
					<xsl:when test="$name='deity'">Божество</xsl:when>
					<xsl:when test="$name='denomination'">Номинал</xsl:when>
					<xsl:when test="$name='department'">Отделение</xsl:when>
					<xsl:when test="$name='deposit'">Депозит</xsl:when>
					<xsl:when test="$name='description'">Описание</xsl:when>
					<xsl:when test="$name='diameter'">Диаметр</xsl:when>
					<xsl:when test="$name='discovery'">Открытие</xsl:when>
					<xsl:when test="$name='disposition'">Размещение</xsl:when>
					<xsl:when test="$name='dynasty'">Династия</xsl:when>
					<xsl:when test="$name='edge'">Край</xsl:when>
					<xsl:when test="$name='era'">Эра</xsl:when>
					<xsl:when test="$name='finder'">Находчик</xsl:when>
					<xsl:when test="$name='findspot'">Место находки</xsl:when>
					<xsl:when test="$name='fromDate'">Датировка с </xsl:when>
					<xsl:when test="$name='geographic'">Географический</xsl:when>
					<xsl:when test="$name='grade'">Градус</xsl:when>
					<xsl:when test="$name='height'">Высота</xsl:when>
					<xsl:when test="$name='hoardDesc'">Описание клада</xsl:when>
					<xsl:when test="$name='identifier'">Идентификатор</xsl:when>
					<xsl:when test="$name='issuer'">Издатель</xsl:when>
					<xsl:when test="$name='landowner'">Землевладелец</xsl:when>
					<xsl:when test="$name='legend'">Легенда</xsl:when>
					<xsl:when test="$name='manufacture'">Производство</xsl:when>
					<xsl:when test="$name='material'">Материал</xsl:when>
					<xsl:when test="$name='measurementsSet'">Параметры</xsl:when>
					<xsl:when test="$name='mint'">Монетный двор</xsl:when>
					<xsl:when test="$name='note'">Примечание</xsl:when>
					<xsl:when test="$name='noteSet'">Примечания</xsl:when>
					<xsl:when test="$name='objectType'">Тип предмета</xsl:when>
					<xsl:when test="$name='obverse'">Аверс</xsl:when>
					<xsl:when test="$name='obv_leg'">Легенда аверса</xsl:when>
					<xsl:when test="$name='obv_type'">Тип аверса</xsl:when>
					<xsl:when test="$name='owner'">Владелец</xsl:when>
					<xsl:when test="$name='physDesc'">Физическое описание</xsl:when>
					<xsl:when test="$name='portrait'">Портрет</xsl:when>
					<xsl:when test="$name='previousColl'">Предыдущее собрание</xsl:when>
					<xsl:when test="$name='private'">Частный</xsl:when>
					<xsl:when test="$name='provenance'">Происхождение</xsl:when>
					<xsl:when test="$name='public'">Публичный</xsl:when>
					<xsl:when test="$name='publisher'">Издательство</xsl:when>
					<xsl:when test="$name='reference'">Ссылка</xsl:when>
					<xsl:when test="$name='refDesc'">Ссылки</xsl:when>
					<xsl:when test="$name='region'">Регион </xsl:when>
					<xsl:when test="$name='repository'">Место хранения</xsl:when>
					<xsl:when test="$name='reverse'">Реверс</xsl:when>
					<xsl:when test="$name='rev_leg'">Легенда реверса</xsl:when>
					<xsl:when test="$name='rev_type'">Тип реверса</xsl:when>
					<xsl:when test="$name='saleCatalog'">Аукционный каталог</xsl:when>
					<xsl:when test="$name='saleItem'">Аукционный лот</xsl:when>
					<xsl:when test="$name='salePrice'">Продажная цена</xsl:when>
					<xsl:when test="$name='shape'">Форма</xsl:when>
					<xsl:when test="$name='state'">Состояние</xsl:when>
					<xsl:when test="$name='subject'">Предмет</xsl:when>
					<xsl:when test="$name='subjectSet'">Предметы</xsl:when>
					<xsl:when test="$name='symbol'">Символ</xsl:when>
					<xsl:when test="$name='testmark'">Контрольная метка</xsl:when>
					<xsl:when test="$name='timestamp'">Дата обновления</xsl:when>
					<xsl:when test="$name='title'">Заголовок</xsl:when>
					<xsl:when test="$name='toDate'">К дате</xsl:when>
					<xsl:when test="$name='type'">Тип</xsl:when>
					<xsl:when test="$name='typeDesc'">Типологическое описание</xsl:when>
					<xsl:when test="$name='thickness'">Толщина</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Описание подтипа</xsl:when>
					<xsl:when test="$name='wear'">Износ</xsl:when>
					<xsl:when test="$name='weight'">Вес</xsl:when>
					<xsl:when test="$name='width'">Ширина</xsl:when>
					<xsl:when test="$name='year'">Год</xsl:when>
					<xsl:otherwise>[<xsl:value-of select="$name"/>] </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$name='acquiredFrom'">Acquired From</xsl:when>
					<xsl:when test="$name='adminDesc'">Administrative History</xsl:when>
					<xsl:when test="$name='coinType'">Coin Type</xsl:when>
					<xsl:when test="$name='closing_date'">Closing Date</xsl:when>
					<xsl:when test="$name='conservationState'">Conservation State</xsl:when>
					<xsl:when test="$name='provenance'">Provenance</xsl:when>
					<xsl:when test="$name='dateOnObject'">Date on Object</xsl:when>
					<xsl:when test="$name='dob'">Date on Object</xsl:when>
					<xsl:when test="$name='dateRange'">Date Range</xsl:when>
					<xsl:when test="$name='findspotDesc'">Findspot Description</xsl:when>
					<xsl:when test="$name='fulltext'">Keyword</xsl:when>
					<xsl:when test="$name='hoardDesc'">Hoard Description</xsl:when>
					<xsl:when test="$name='fromDate'">From Date</xsl:when>
					<xsl:when test="$name='toDate'">To Date</xsl:when>
					<xsl:when test="$name='measurementsSet'">Measurements</xsl:when>
					<xsl:when test="$name='noteSet'">Notes</xsl:when>
					<xsl:when test="$name='objectType'">Object Type</xsl:when>
					<xsl:when test="$name='obv_leg'">Obverse Legend</xsl:when>
					<xsl:when test="$name='obv_type'">Obverse Type</xsl:when>
					<xsl:when test="$name='physDesc'">Physical Description</xsl:when>
					<xsl:when test="$name='previousColl'">Previous Collection</xsl:when>
					<xsl:when test="$name='refDesc'">References</xsl:when>
					<xsl:when test="$name='rev_leg'">Reverse Legend</xsl:when>
					<xsl:when test="$name='rev_type'">Reverse Type</xsl:when>
					<xsl:when test="$name='saleCatalog'">Sale Catalog</xsl:when>
					<xsl:when test="$name='saleItem'">Sale Item</xsl:when>
					<xsl:when test="$name='salePrice'">Sale Price</xsl:when>
					<xsl:when test="$name='subjectSet'">SubjectSet</xsl:when>
					<xsl:when test="$name='tpq'">Opening Date</xsl:when>
					<xsl:when test="$name='taq'">Closing Date</xsl:when>
					<xsl:when test="$name='testmark'">Test Mark</xsl:when>
					<xsl:when test="$name='typeDesc'">Typological Description</xsl:when>
					<xsl:when test="$name = 'timestamp'">Date Record Modified</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Undertype Description</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
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
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="name" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="name" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_hier')">
				<xsl:variable name="name" select="substring-before($field, '_hier')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_num')">
				<xsl:variable name="name" select="substring-before($field, '_num')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="name" select="substring-before($field, '_text')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="name" select="substring-before($field, '_m')"/>
				<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="name" select="substring-before($field, '_display')"/>
				<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
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
			<xsl:when test="$lang='ar'">
				<xsl:choose>
					<!-- header menu labels -->
					<xsl:when test="$label='header_home'">المكان</xsl:when>
					<xsl:when test="$label='header_search'">البحث</xsl:when>
					<xsl:when test="$label='header_browse'">البحث بالتحديد</xsl:when>
					<xsl:when test="$label='header_maps'">الخرائط</xsl:when>
					<xsl:when test="$label='header_compare'">المقارنة</xsl:when>
					<xsl:when test="$label='header_language'">اللغة</xsl:when>
					<xsl:when test="$label='lang_ar'">العربيّة</xsl:when>
					<xsl:when test="$label='lang_de'">ألماني</xsl:when>
					<xsl:when test="$label='lang_en'">إنجليزي</xsl:when>
					<xsl:when test="$label='lang_fr'">فرنسي</xsl:when>
					<xsl:when test="$label='lang_ro'">رومانيا</xsl:when>
					<xsl:when test="$label='lang_pl'">بولندي</xsl:when>
					<xsl:when test="$label='lang_ru'">الروسية</xsl:when>
					<xsl:when test="$label='lang_nl'">هولندي</xsl:when>
					<xsl:when test="$label='lang_sv'">اللغة السويدية</xsl:when>
					<xsl:when test="$label='lang_el'">اللغة اليونانية</xsl:when>
					<xsl:when test="$label='lang_tr'">اللغة التركية</xsl:when>
					<xsl:when test="$label='lang_it'">الإيطالي</xsl:when>
					<xsl:when test="$label='lang_da'">نوع كعك</xsl:when>
					<xsl:when test="$label='lang_nn'">اللغة النروجية</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='de'">
				<xsl:choose>
					<!-- header menu labels -->
					<xsl:when test="$label='header_home'">Start</xsl:when>
					<xsl:when test="$label='header_search'">Suchen</xsl:when>
					<xsl:when test="$label='header_browse'">Browsen</xsl:when>
					<xsl:when test="$label='header_maps'">Karten</xsl:when>
					<xsl:when test="$label='header_compare'">Vergleichen</xsl:when>
					<xsl:when test="$label='header_analyze'">Hortfunde analysieren</xsl:when>
					<xsl:when test="$label='header_visualize'">Anfragen visualisieren</xsl:when>
					<xsl:when test="$label='header_language'">Sprache</xsl:when>
					<xsl:when test="$label='display_summary'">Zusammenfassung</xsl:when>
					<xsl:when test="$label='display_map'">Karten</xsl:when>
					<xsl:when test="$label='display_administrative'">Administrativ</xsl:when>
					<xsl:when test="$label='display_contents'">Inhalt</xsl:when>
					<xsl:when test="$label='display_quantitative'">Quantitative Analyse</xsl:when>
					<xsl:when test="$label='display_visualization'">Visualisierung</xsl:when>
					<xsl:when test="$label='display_data-download'">Datendownload</xsl:when>
					<xsl:when test="$label='display_date-analysis'">Datumsanalyse</xsl:when>
					<xsl:when test="$label='results_all-terms'">Alle Begriffe</xsl:when>
					<xsl:when test="$label='results_keyword'">Schlagwort</xsl:when>
					<xsl:when test="$label='results_clear-all'">Alle Begriffe löchen</xsl:when>
					<xsl:when test="$label='results_map-results'">Kartierungsergebnisse</xsl:when>
					<xsl:when test="$label='results_filters'">Filter</xsl:when>
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
					<xsl:when test="$label='lang_ar'">Arabisch</xsl:when>
					<xsl:when test="$label='lang_de'">Deutsch</xsl:when>
					<xsl:when test="$label='lang_en'">Englisch</xsl:when>
					<xsl:when test="$label='lang_fr'">Französisch</xsl:when>
					<xsl:when test="$label='lang_ro'">Rumänisch</xsl:when>
					<xsl:when test="$label='lang_pl'">Polnische </xsl:when>
					<xsl:when test="$label='lang_ru'">Russisch</xsl:when>
					<xsl:when test="$label='lang_nl'">Holländisch</xsl:when>
					<xsl:when test="$label='lang_sv'">Schwedisch</xsl:when>
					<xsl:when test="$label='lang_el'">Griechisch</xsl:when>
					<xsl:when test="$label='lang_tr'">Türkisch</xsl:when>
					<xsl:when test="$label='lang_it'">Italienisch</xsl:when>
					<xsl:when test="$label='lang_da'">Dänisch</xsl:when>
					<xsl:when test="$label='lang_nn'">Norwegisch</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='el'">
				<xsl:choose>
					<xsl:when test="$label='header_home'">Αφετηρία</xsl:when>
					<xsl:when test="$label='header_browse'">Περιήγηση</xsl:when>
					<xsl:when test="$label='header_search'">Αναζήτηση</xsl:when>
					<xsl:when test="$label='header_maps'">Χάρτες</xsl:when>
					<xsl:when test="$label='header_compare'">Αντιπαραβολή</xsl:when>
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
					<xsl:when test="$label='visualize_typological'"/>
					<xsl:when test="$label='visualize_measurement'"/>
					<xsl:when test="$label='visualize_error1'"/>
					<xsl:when test="$label='visualize_error2'"/>
					<xsl:when test="$label='lang_ar'">Αραβικά</xsl:when>
					<xsl:when test="$label='lang_de'">Γερμανικά</xsl:when>
					<xsl:when test="$label='lang_en'">Αγγλικά</xsl:when>
					<xsl:when test="$label='lang_fr'">Γαλλικά</xsl:when>
					<xsl:when test="$label='lang_ro'">Ρουμανικά</xsl:when>
					<xsl:when test="$label='lang_pl'">Πολωνικά</xsl:when>
					<xsl:when test="$label='lang_ru'">Ρωσικά</xsl:when>
					<xsl:when test="$label='lang_nl'">Ολλανδικά</xsl:when>
					<xsl:when test="$label='lang_sv'">Σουηδικά</xsl:when>
					<xsl:when test="$label='lang_el'">Ελληνικά</xsl:when>
					<xsl:when test="$label='lang_tr'">Τουρκικά</xsl:when>
					<xsl:when test="$label='lang_it'">Ιταλικά</xsl:when>
					<xsl:when test="$label='lang_da'">Δανικά</xsl:when>
					<xsl:when test="$label='lang_nn'">Νορβηγικά</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='fr'">
				<xsl:choose>
					<!-- header menu labels -->
					<xsl:when test="$label='header_home'">Accueil</xsl:when>
					<xsl:when test="$label='header_search'">Chercher</xsl:when>
					<xsl:when test="$label='header_browse'">Explorer</xsl:when>
					<xsl:when test="$label='header_maps'">Cartes</xsl:when>
					<xsl:when test="$label='header_compare'">Comparer</xsl:when>
					<xsl:when test="$label='header_analyze'">Analyse des trésors</xsl:when>
					<xsl:when test="$label='header_visualize'">Visualiser la recherche</xsl:when>
					<xsl:when test="$label='header_language'">Langue</xsl:when>
					<xsl:when test="$label='display_summary'">Résumé</xsl:when>
					<xsl:when test="$label='display_map'">Carte</xsl:when>
					<xsl:when test="$label='display_administrative'">Administratif</xsl:when>
					<xsl:when test="$label='display_quantitative'">Analyse quantitative</xsl:when>
					<xsl:when test="$label='display_visualization'">Visualisation</xsl:when>
					<xsl:when test="$label='display_data-download'">Récupérer les données</xsl:when>
					<xsl:when test="$label='results_all-terms'">Tous les termes</xsl:when>
					<xsl:when test="$label='results_map-results'">Résultats géographiques</xsl:when>
					<xsl:when test="$label='results_data-options'">Options de données</xsl:when>
					<xsl:when test="$label='results_refine-results'">Raffiner le résultat</xsl:when>
					<xsl:when test="$label='results_quick-search'">Recherche rapide</xsl:when>
					<xsl:when test="$label='results_has-images'">Images disponibles</xsl:when>
					<xsl:when test="$label='results_refine-search'">Raffiner la recherche</xsl:when>
					<xsl:when test="$label='results_select'">Sélectionner à partir de la liste</xsl:when>
					<xsl:when test="$label='results_sort-results'">Classer les résultats</xsl:when>
					<xsl:when test="$label='results_sort-category'">Sort Category</xsl:when>
					<xsl:when test="$label='results_ascending'">Ordre ascendant</xsl:when>
					<xsl:when test="$label='results_descending'">Ordre descendant</xsl:when>
					<xsl:when test="$label='results_result-desc'">Afficher les références XX à YY à partir de ZZ résultats</xsl:when>
					<xsl:when test="$label='results_filters'">Filtres</xsl:when>
					<xsl:when test="$label='results_clear-all'">Effacer les termes sélectionnés</xsl:when>
					<xsl:when test="$label='results_keyword'">Mot clef</xsl:when>
					<xsl:when test="$label='results_sort-category'">Classer les catégories</xsl:when>
					<xsl:when test="$label='results_coin'">monnaie</xsl:when>
					<xsl:when test="$label='results_coins'">monnaies</xsl:when>
					<xsl:when test="$label='results_hoard'">trésor</xsl:when>
					<xsl:when test="$label='results_hoards'">trésors</xsl:when>
					<xsl:when test="$label='results_and'">et</xsl:when>
					<xsl:when test="$label='lang_ar'">Arabe</xsl:when>
					<xsl:when test="$label='lang_de'">Allemand</xsl:when>
					<xsl:when test="$label='lang_en'">Anglais</xsl:when>
					<xsl:when test="$label='lang_fr'">Français</xsl:when>
					<xsl:when test="$label='lang_ro'">Roumain</xsl:when>
					<xsl:when test="$label='lang_pl'">Polonais</xsl:when>
					<xsl:when test="$label='lang_ru'">Russe</xsl:when>
					<xsl:when test="$label='lang_nl'">Néerlandais</xsl:when>
					<xsl:when test="$label='lang_sv'">Suédois</xsl:when>
					<xsl:when test="$label='lang_el'">Grec</xsl:when>
					<xsl:when test="$label='lang_tr'">Turc</xsl:when>
					<xsl:when test="$label='lang_it'">Italien</xsl:when>
					<xsl:when test="$label='lang_da'">Danois</xsl:when>
					<xsl:when test="$label='lang_nn'">Norvégien</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='it'">
				<xsl:choose>
					<xsl:when test="$label='header_home'">[]</xsl:when>
					<xsl:when test="$label='header_browse'">[]</xsl:when>
					<xsl:when test="$label='header_search'">Cerca</xsl:when>
					<xsl:when test="$label='header_maps'">Mappe</xsl:when>
					<xsl:when test="$label='header_compare'">Confronta</xsl:when>
					<xsl:when test="$label='header_language'">Lingua</xsl:when>
					<xsl:when test="$label='header_analyze'">Analisi dei ripostigli</xsl:when>
					<xsl:when test="$label='header_visualize'"/>
					<xsl:when test="$label='display_summary'">Sommario</xsl:when>
					<xsl:when test="$label='display_map'">Mappa</xsl:when>
					<xsl:when test="$label='display_administrative'">Amministrativo</xsl:when>
					<xsl:when test="$label='display_visualization'">Visualizzazione</xsl:when>
					<xsl:when test="$label='display_data-download'">Scarica i dati</xsl:when>
					<xsl:when test="$label='display_quantitative'">Analisi quantitativa</xsl:when>
					<xsl:when test="$label='display_date-analysis'"/>
					<xsl:when test="$label='display_contents'"/>
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
					<xsl:when test="$label='visualize_typological'">[]</xsl:when>
					<xsl:when test="$label='visualize_measurement'">[]</xsl:when>
					<xsl:when test="$label='visualize_error1'">[]</xsl:when>
					<xsl:when test="$label='visualize_error2'">[]</xsl:when>
					<xsl:when test="$label='lang_ar'">Arabo</xsl:when>
					<xsl:when test="$label='lang_de'">Tedesco</xsl:when>
					<xsl:when test="$label='lang_en'">Inglese</xsl:when>
					<xsl:when test="$label='lang_fr'">Francese</xsl:when>
					<xsl:when test="$label='lang_ro'">Rumeno</xsl:when>
					<xsl:when test="$label='lang_pl'">Polacco</xsl:when>
					<xsl:when test="$label='lang_ru'">Russo</xsl:when>
					<xsl:when test="$label='lang_nl'">Olandese</xsl:when>
					<xsl:when test="$label='lang_sv'">Svedese</xsl:when>
					<xsl:when test="$label='lang_el'">Greco</xsl:when>
					<xsl:when test="$label='lang_tr'">Turco</xsl:when>
					<xsl:when test="$label='lang_it'">Italiano</xsl:when>
					<xsl:when test="$label='lang_da'">Danese</xsl:when>
					<xsl:when test="$label='lang_nn'">Norvegese</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='nl'">
				<xsl:choose>
					<xsl:when test="$label='header_home'">Start</xsl:when>
					<xsl:when test="$label='header_browse'">Bladeren</xsl:when>
					<xsl:when test="$label='header_search'">Zoeken</xsl:when>
					<xsl:when test="$label='header_maps'">Kaarten</xsl:when>
					<xsl:when test="$label='header_compare'">Vergelijken</xsl:when>
					<xsl:when test="$label='header_language'">Taal</xsl:when>
					<xsl:when test="$label='header_analyze'">Analyseer schatvondsten</xsl:when>
					<xsl:when test="$label='header_visualize'">Visualiseer zoekvraag</xsl:when>
					<xsl:when test="$label='display_summary'">Samenvatting</xsl:when>
					<xsl:when test="$label='display_map'">Kaart</xsl:when>
					<xsl:when test="$label='display_administrative'">Administratief</xsl:when>
					<xsl:when test="$label='display_visualization'">Visualisatie</xsl:when>
					<xsl:when test="$label='display_data-download'">Data download</xsl:when>
					<xsl:when test="$label='display_quantitative'">Quantitatieve analyse</xsl:when>
					<xsl:when test="$label='display_date-analysis'">Data-analyse</xsl:when>
					<xsl:when test="$label='display_contents'">Inhoud</xsl:when>
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
					<xsl:when test="$label='lang_ar'">Arabisch</xsl:when>
					<xsl:when test="$label='lang_de'">Duits</xsl:when>
					<xsl:when test="$label='lang_en'">Engels</xsl:when>
					<xsl:when test="$label='lang_fr'">Frans</xsl:when>
					<xsl:when test="$label='lang_ro'">Roemeens</xsl:when>
					<xsl:when test="$label='lang_pl'">Pools</xsl:when>
					<xsl:when test="$label='lang_ru'">Russisch</xsl:when>
					<xsl:when test="$label='lang_nl'">Nederlands</xsl:when>
					<xsl:when test="$label='lang_sv'">Zweeds</xsl:when>
					<xsl:when test="$label='lang_el'">Grieks</xsl:when>
					<xsl:when test="$label='lang_tr'">Turks</xsl:when>
					<xsl:when test="$label='lang_it'">Italiaans</xsl:when>
					<xsl:when test="$label='lang_da'">Deens</xsl:when>
					<xsl:when test="$label='lang_nn'">Noors</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='ro'">
				<xsl:choose>
					<!-- header menu labels -->
					<xsl:when test="$label='header_home'">Acasă</xsl:when>
					<xsl:when test="$label='header_search'">Căutare</xsl:when>
					<xsl:when test="$label='header_browse'">Explorare</xsl:when>
					<xsl:when test="$label='header_maps'">Hărţi</xsl:when>
					<xsl:when test="$label='header_compare'">Comparativ</xsl:when>
					<xsl:when test="$label='header_analyze'">Analiza tezaurelor</xsl:when>
					<xsl:when test="$label='header_visualize'">Vizualizarea cercetării</xsl:when>
					<xsl:when test="$label='header_language'">Limbă</xsl:when>
					<xsl:when test="$label='display_summary'">Rezumat</xsl:when>
					<xsl:when test="$label='display_map'">Hartă</xsl:when>
					<xsl:when test="$label='display_administrative'">Administrativ</xsl:when>
					<xsl:when test="$label='display_contents'">Conţinut</xsl:when>
					<xsl:when test="$label='display_quantitative'">Aniliza cantitativă</xsl:when>
					<xsl:when test="$label='display_visualization'">Vizualizare</xsl:when>
					<xsl:when test="$label='display_data-download'">Data descărcării</xsl:when>
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
					<xsl:when test="$label='lang_ar'">Arabă</xsl:when>
					<xsl:when test="$label='lang_de'">Germană</xsl:when>
					<xsl:when test="$label='lang_en'">Engleză</xsl:when>
					<xsl:when test="$label='lang_fr'">Franceză</xsl:when>
					<xsl:when test="$label='lang_ro'">Romană</xsl:when>
					<xsl:when test="$label='lang_pl'">Polonă</xsl:when>
					<xsl:when test="$label='lang_ru'">Rusă</xsl:when>
					<xsl:when test="$label='lang_nl'">Olandeză</xsl:when>
					<xsl:when test="$label='lang_sv'">Suedeză</xsl:when>
					<xsl:when test="$label='lang_el'">Greacă</xsl:when>
					<xsl:when test="$label='lang_tr'">Turcă</xsl:when>
					<xsl:when test="$label='lang_it'">Italiană</xsl:when>
					<xsl:when test="$label='lang_da'">Daneză</xsl:when>
					<xsl:when test="$label='lang_nn'">Norvegiană</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='ru'">
				<xsl:choose>
					<xsl:when test="$label='header_home'">На главную</xsl:when>
					<xsl:when test="$label='header_browse'">Обзор</xsl:when>
					<xsl:when test="$label='header_search'">Поиск</xsl:when>
					<xsl:when test="$label='header_maps'">Карты</xsl:when>
					<xsl:when test="$label='header_compare'">Сравнить</xsl:when>
					<xsl:when test="$label='header_language'">Язык</xsl:when>
					<xsl:when test="$label='header_analyze'">Анализ кладов</xsl:when>
					<xsl:when test="$label='header_visualize'">Отобразить запросы</xsl:when>
					<xsl:when test="$label='Display'"/>
					<xsl:when test="$label='display_summary'">Резюме</xsl:when>
					<xsl:when test="$label='display_map'">Карта</xsl:when>
					<xsl:when test="$label='display_administrative'">Администрирование</xsl:when>
					<xsl:when test="$label='display_visualization'">Отображение</xsl:when>
					<xsl:when test="$label='display_data-download'">Загрузка данных</xsl:when>
					<xsl:when test="$label='display_quantitative'">Количественный анализ</xsl:when>
					<xsl:when test="$label='display_date-analysis'">Анализ датировки</xsl:when>
					<xsl:when test="$label='display_contents'">Содержание</xsl:when>
					<xsl:when test="$label='Browse/Results'"/>
					<xsl:when test="$label='results_all-terms'">Все значения</xsl:when>
					<xsl:when test="$label='results_map-results'">Карта результатов</xsl:when>
					<xsl:when test="$label='results_filters'">Фильтры</xsl:when>
					<xsl:when test="$label='results_keyword'">Ключевое слово</xsl:when>
					<xsl:when test="$label='results_clear-all'">Очистить все значения</xsl:when>
					<xsl:when test="$label='results_data-options'">Исходные данные </xsl:when>
					<xsl:when test="$label='results_refine-results'">Обновить результаты</xsl:when>
					<xsl:when test="$label='results_quick-search'">Быстрый поиск</xsl:when>
					<xsl:when test="$label='results_has-images'">Содержит изображения</xsl:when>
					<xsl:when test="$label='results_refine-search'">Обновить поиск</xsl:when>
					<xsl:when test="$label='results_select'">Выбрать из списка</xsl:when>
					<xsl:when test="$label='results_sort-results'">Сортировать результаты</xsl:when>
					<xsl:when test="$label='results_sort-category'">Сортировать категории</xsl:when>
					<xsl:when test="$label='results_ascending'">Возрастание</xsl:when>
					<xsl:when test="$label='results_descending'">Убывание</xsl:when>
					<xsl:when test="$label='results_result-desc'">Отображать записи XX из YY из ZZ результатов </xsl:when>
					<xsl:when test="$label='results_coin'">монета</xsl:when>
					<xsl:when test="$label='results_coins'">монеты</xsl:when>
					<xsl:when test="$label='results_hoard'">клад</xsl:when>
					<xsl:when test="$label='results_hoards'">клады</xsl:when>
					<xsl:when test="$label='results_and'">и </xsl:when>
					<xsl:when test="$label='Languages'"/>
					<xsl:when test="$label='lang_ar'">Арабский</xsl:when>
					<xsl:when test="$label='lang_de'">Немецкий</xsl:when>
					<xsl:when test="$label='lang_en'">Английский</xsl:when>
					<xsl:when test="$label='lang_fr'">Французский</xsl:when>
					<xsl:when test="$label='lang_ro'">Румынский</xsl:when>
					<xsl:when test="$label='lang_pl'">Польский</xsl:when>
					<xsl:when test="$label='lang_ru'">Русский</xsl:when>
					<xsl:when test="$label='lang_nl'">Голландский</xsl:when>
					<xsl:when test="$label='lang_sv'">Шведский</xsl:when>
					<xsl:when test="$label='lang_el'">Греческий</xsl:when>
					<xsl:when test="$label='lang_tr'">Турецкий</xsl:when>
					<xsl:when test="$label='lang_it'">Итальянский</xsl:when>
					<xsl:when test="$label='lang_da'">Датский</xsl:when>
					<xsl:when test="$label='lang_nn'">Норвежский</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- header menu labels -->
					<xsl:when test="$label='header_home'">Home</xsl:when>
					<xsl:when test="$label='header_search'">Search</xsl:when>
					<xsl:when test="$label='header_browse'">Browse</xsl:when>
					<xsl:when test="$label='header_maps'">Maps</xsl:when>
					<xsl:when test="$label='header_compare'">Compare</xsl:when>
					<xsl:when test="$label='header_analyze'">Analyze Hoards</xsl:when>
					<xsl:when test="$label='header_visualize'">Visualize Queries</xsl:when>
					<xsl:when test="$label='header_language'">Language</xsl:when>
					<xsl:when test="$label='display_summary'">Summary</xsl:when>
					<xsl:when test="$label='display_administrative'">Administrative</xsl:when>
					<xsl:when test="$label='display_commentary'">Commentary</xsl:when>
					<xsl:when test="$label='display_map'">Map</xsl:when>
					<xsl:when test="$label='display_contents'">Contents</xsl:when>
					<xsl:when test="$label='display_quantitative'">Quantitative Analysis</xsl:when>
					<xsl:when test="$label='display_visualization'">Visualization</xsl:when>
					<xsl:when test="$label='display_data-download'">Data Download</xsl:when>
					<xsl:when test="$label='display_date-analysis'">Date Analysis</xsl:when>
					<xsl:when test="$label='results_all-terms'">All Terms</xsl:when>
					<xsl:when test="$label='results_map-results'">Map Results</xsl:when>
					<xsl:when test="$label='results_filters'">Filters</xsl:when>
					<xsl:when test="$label='results_keyword'">Keyword</xsl:when>
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
					<xsl:when test="$label='visualize_typological'">Typological Analysis</xsl:when>
					<xsl:when test="$label='visualize_measurement'">Measurement Analysis</xsl:when>
					<xsl:when test="$label='visualize_error1'">Interval and duration are required.</xsl:when>
					<xsl:when test="$label='visualize_error2'">To Date must be later than From Date.</xsl:when>
					<xsl:when test="$label='lang_ar'">Arabic</xsl:when>
					<xsl:when test="$label='lang_de'">German</xsl:when>
					<xsl:when test="$label='lang_en'">English</xsl:when>
					<xsl:when test="$label='lang_fr'">French</xsl:when>
					<xsl:when test="$label='lang_ro'">Romanian</xsl:when>
					<xsl:when test="$label='lang_pl'">Polish</xsl:when>
					<xsl:when test="$label='lang_ru'">Russian</xsl:when>
					<xsl:when test="$label='lang_nl'">Dutch</xsl:when>
					<xsl:when test="$label='lang_sv'">Swedish</xsl:when>
					<xsl:when test="$label='lang_el'">Greek</xsl:when>
					<xsl:when test="$label='lang_tr'">Turkish</xsl:when>
					<xsl:when test="$label='lang_it'">Italian</xsl:when>
					<xsl:when test="$label='lang_da'">Danish</xsl:when>
					<xsl:when test="$label='lang_nn'">Norwegian</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', $label, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="numishare:normalizeYear">
		<xsl:param name="year" as="xs:integer"/>

		<xsl:choose>
			<xsl:when test="$year &lt; 0">
				<xsl:value-of select="abs($year)"/>
				<xsl:text> B.C.</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$year &lt;=400">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="$year"/>
			</xsl:otherwise>
		</xsl:choose>
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

	<xsl:function name="numishare:getNomismaLabel">
		<xsl:param name="rdf" as="element()*"/>
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="string($lang)">
				<xsl:choose>
					<xsl:when test="$rdf/skos:prefLabel[@xml:lang=$lang]">
						<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang=$lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang='en']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$rdf/skos:prefLabel[@xml:lang='en']"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

</xsl:stylesheet>
