<?xml version="1.0" encoding="UTF-8"?>
<!-- Repeated functions for regularization to be used through Numishare -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:numishare="http://code.google.com/p/numishare/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:function name="numishare:get_flickr_uri">
		<xsl:param name="photo_id"/>
		<xsl:value-of
			select="document(concat('http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', $flickr-api-key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']"
		/>
	</xsl:function>


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
					<xsl:otherwise> Unlabeled field: <xsl:value-of select="$name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$lang='de'">
				<xsl:choose>
					<xsl:when test="$name='acknowledgment'">[]</xsl:when>					
					<xsl:when test="$name='acquiredFrom'">Erworben von</xsl:when>
					<xsl:when test="$name='adminDesc'">Administrativ</xsl:when>
					<xsl:when test="$name='appraisal'">[]</xsl:when>
					<xsl:when test="$name='appraiser'">[]</xsl:when>
					<xsl:when test="$name='authority'">[]</xsl:when>
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
					<xsl:when test="$name='dateRange'">[]</xsl:when>
					<xsl:when test="$name='decade'">Jahrzehnt</xsl:when>
					<xsl:when test="$name='degree'">Grad</xsl:when>
					<xsl:when test="$name='deity'">Gottheit</xsl:when>
					<xsl:when test="$name='denomination'">Nominale</xsl:when>
					<xsl:when test="$name='department'">Abteilung</xsl:when>
					<xsl:when test="$name='deposit'">Depot</xsl:when>
					<xsl:when test="$name='description'">Beschreibung</xsl:when>
					<xsl:when test="$name='diameter'">Durchmesser</xsl:when>
					<xsl:when test="$name='discovery'">Entdeckung</xsl:when>
					<xsl:when test="$name='disposition'">[]</xsl:when>
					<xsl:when test="$name='dynasty'">Dynastie</xsl:when>
					<xsl:when test="$name='edge'">Rand</xsl:when>
					<xsl:when test="$name='era'">[]</xsl:when>
					<xsl:when test="$name='finder'">Finder</xsl:when>
					<xsl:when test="$name='findspot'">Fundstelle</xsl:when>
					<xsl:when test="$name='fromDate'">Datum von</xsl:when>
					<xsl:when test="$name='geographic'">Geographisch</xsl:when>
					<xsl:when test="$name='grade'">[]</xsl:when>
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
					<xsl:when test="$name='objectType'">[]</xsl:when>
					<xsl:when test="$name='obverse'">Vorderseite</xsl:when>
					<xsl:when test="$name='obv_leg'"> Vorderseitenlegende</xsl:when>
					<xsl:when test="$name='obv_type'">Vorderseitentyp</xsl:when>
					<xsl:when test="$name='owner'">Eigentümer</xsl:when>
					<xsl:when test="$name='physDesc'">Physische Beschreibung</xsl:when>
					<xsl:when test="$name='portrait'">Porträt</xsl:when>
					<xsl:when test="$name='private'">privat</xsl:when>
					<xsl:when test="$name='public'">öffentlich</xsl:when>
					<xsl:when test="$name='reference'">Zitat</xsl:when>
					<xsl:when test="$name='refDesc'">Zitate</xsl:when>
					<xsl:when test="$name='region'">Region</xsl:when>
					<xsl:when test="$name='repository'">[]</xsl:when>
					<xsl:when test="$name='reverse'">Rückseite</xsl:when>
					<xsl:when test="$name='rev_leg'">Rückseitenlegende</xsl:when>
					<xsl:when test="$name='rev_type'">Rückseitentyp</xsl:when>
					<xsl:when test="$name='saleCatalog'">Auktionskatalog</xsl:when>
					<xsl:when test="$name='saleItem'"></xsl:when>
					<xsl:when test="$name='salePrice'">Verkaufspreis</xsl:when>
					<xsl:when test="$name='shape'">Form</xsl:when>
					<xsl:when test="$name='state'">Zustand</xsl:when>
					<xsl:when test="$name='subject'">Subjekt</xsl:when>
					<xsl:when test="$name='subjectSet'">Subjekte</xsl:when>
					<xsl:when test="$name='symbol'">Symbol</xsl:when>
					<xsl:when test="$name='testmark'">Prüfmarke</xsl:when>
					<xsl:when test="$name='timestamp'">Moodifizierungsdatum</xsl:when>
					<xsl:when test="$name='title'">[]</xsl:when>
					<xsl:when test="$name='toDate'">Datum bis</xsl:when>
					<xsl:when test="$name='type'">Typ</xsl:when>
					<xsl:when test="$name='typeDesc'">Typologische Beschreibung</xsl:when>
					<xsl:when test="$name='thickness'">Dicke</xsl:when>
					<xsl:when test="$name='undertypeDesc'">Untertyp Beschreibung</xsl:when>
					<xsl:when test="$name='wear'">Abnutzung</xsl:when>
					<xsl:when test="$name='weight'">Gewicht</xsl:when>
					<xsl:when test="$name='width'">Breite</xsl:when>
					<xsl:when test="$name='year'">Jahr</xsl:when>
					<xsl:otherwise> Unlabeled field: <xsl:value-of select="$name"/>
					</xsl:otherwise>
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
					<xsl:when test="$name='collection'">Collection</xsl:when>
					<xsl:when test="$name='color'">Couleur</xsl:when>
					<xsl:when test="$name='completeness'">Intégrité</xsl:when>
					<xsl:when test="$name='condition'">Etat de conservation</xsl:when>
					<xsl:when test="$name='conservationState'">Etat de conservation</xsl:when>
					<xsl:when test="$name='coordinates'">Coordonnées</xsl:when>
					<xsl:when test="$name='countermark'">Contremarque</xsl:when>
					<xsl:when test="$name='provenance'">Provenance</xsl:when>
					<xsl:when test="$name='date'">Date</xsl:when>
					<xsl:when test="$name='dateOnObject'">Date sur l'objet</xsl:when>
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
					<xsl:when test="$name='identifier'">Identifiant</xsl:when>
					<xsl:when test="$name='issuer'">Emetteur</xsl:when>
					<xsl:when test="$name='landowner'">Propriétaire du sol</xsl:when>
					<xsl:when test="$name='legend'">Légende</xsl:when>
					<xsl:when test="$name='material'">Matériau</xsl:when>
					<xsl:when test="$name='measurementsSet'">Mesures</xsl:when>
					<xsl:when test="$name='mint'">Atelier</xsl:when>
					<xsl:when test="$name='note'">Note</xsl:when>
					<xsl:when test="$name='objectType'">Type d'objet</xsl:when>
					<xsl:when test="$name='obverse'">Avers/Droit</xsl:when>
					<xsl:when test="$name='obv_leg'"> Légende d'avers/de droit</xsl:when>
					<xsl:when test="$name='owner'">Propriétaire</xsl:when>
					<xsl:when test="$name='physDesc'">Description physique</xsl:when>
					<xsl:when test="$name='portrait'">Portrait</xsl:when>
					<xsl:when test="$name='private'">Privé</xsl:when>
					<xsl:when test="$name='public'">Publique</xsl:when>
					<xsl:when test="$name='reference'">Référence</xsl:when>
					<xsl:when test="$name='refDesc'">Références</xsl:when>
					<xsl:when test="$name='region'">Région</xsl:when>
					<xsl:when test="$name='repository'">Dépositaire</xsl:when>
					<xsl:when test="$name='reverse'">Revers</xsl:when>
					<xsl:when test="$name='rev_leg'">Légende de revers</xsl:when>
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
					<xsl:otherwise> Unlabeled field: <xsl:value-of select="$name"/>
					</xsl:otherwise>
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
					<xsl:otherwise> Unlabeled field: <xsl:value-of select="$name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>					
					<xsl:when test="$name='acquiredFrom'">Acquired From</xsl:when>
					<xsl:when test="$name='adminDesc'">Administrative History</xsl:when>
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
					<xsl:when test="$name='objectType'">Object Type</xsl:when>
					<xsl:when test="$name = 'obv_leg'">Obverse Legend</xsl:when>
					<xsl:when test="$name = 'obv_type'">Obverse Type</xsl:when>
					<xsl:when test="$name='physDesc'">Physical Description</xsl:when>
					<xsl:when test="$name='previousColl'">Previous Collection</xsl:when>
					<xsl:when test="$name='refDesc'">References</xsl:when>
					<xsl:when test="$name = 'rev_leg'">Reverse Legend</xsl:when>
					<xsl:when test="$name = 'rev_type'">Reverse Type</xsl:when>
					<xsl:when test="$name='saleCatalog'">Sale Catalog</xsl:when>
					<xsl:when test="$name='saleItem'">Sale Item</xsl:when>
					<xsl:when test="$name='salePrice'">Sale Price</xsl:when>
					<xsl:when test="$name='subjectSet'">SubjectSet</xsl:when>
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
			<xsl:when test="$lang='ar'">
				<xsl:choose>
					<xsl:when test="contains($field, '_uri')">
						<xsl:variable name="name" select="substring-before($field, '_uri')"/>
						<xsl:text> URI</xsl:text>
						<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
					</xsl:when>
					<xsl:when test="contains($field, '_facet')">
						<xsl:variable name="name" select="substring-before($field, '_facet')"/>
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
			</xsl:when>
			<xsl:when test="$lang='fr'">
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
			</xsl:when>
			<xsl:otherwise>
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
					<xsl:otherwise>
						<xsl:value-of select="concat('No label for ', $label)"/>
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
					<xsl:when test="$label='results_all-terms'">Alle Begriffe</xsl:when>
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
					<xsl:otherwise>
						<xsl:value-of select="concat('No label for ', $label)"/>
					</xsl:otherwise>
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
					<xsl:otherwise>
						<xsl:value-of select="concat('No label for ', $label)"/>
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
					<xsl:otherwise>
						<xsl:value-of select="concat('No label for ', $label)"/>
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
					<xsl:otherwise>
						<xsl:value-of select="concat('No label for ', $label)"/>
					</xsl:otherwise>
				</xsl:choose>
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

</xsl:stylesheet>
