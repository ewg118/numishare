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
					<xsl:when test="$name='acqinfo'">وسائل الحصول عليها</xsl:when>
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
					<xsl:when test="$name='custodhist'">مكان وجود القطعة</xsl:when>
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
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$name='acqinfo'">Aquisitition Information</xsl:when>
					<xsl:when test="$name='acquiredFrom'">Acquired From</xsl:when>
					<xsl:when test="$name='conservationState'">Conservation State</xsl:when>
					<xsl:when test="$name='custodhist'">Custodial History</xsl:when>
					<xsl:when test="$name='dateOnObject'">Date on Object</xsl:when>
					<xsl:when test="$name='dateRange'">Date Range</xsl:when>
					<xsl:when test="$name='fromDate'">From Date</xsl:when>
					<xsl:when test="$name='toDate'">To Date</xsl:when>
					<xsl:when test="$name='objectType'">Object Type</xsl:when>
					<xsl:when test="$name='saleCatalog'">Sale Catalog</xsl:when>
					<xsl:when test="$name='saleItem'">Sale Item</xsl:when>
					<xsl:when test="$name='salePrice'">Sale Price</xsl:when>
					<xsl:when test="$name='testmark'">Test Mark</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
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

	<!-- normalize solr fields -->
	<xsl:function name="numishare:normalize_fields">
		<xsl:param name="field"/>
		<xsl:choose>
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="name" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="name" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="$field = 'timestamp'">Date Record Modified</xsl:when>
			<xsl:when test="$field = 'fulltext'">Keyword</xsl:when>
			<xsl:when test="$field = 'dob'">Date on Object</xsl:when>
			<xsl:when test="$field = 'imagesavailable'">Has Images</xsl:when>
			<xsl:when test="$field = 'imagesponsor_display'">Image Sponsor</xsl:when>
			<xsl:when test="$field = 'obv_leg_display'">Obv. Legend</xsl:when>
			<xsl:when test="$field = 'obv_leg_text'">Obv. Legend</xsl:when>
			<xsl:when test="$field = 'obv_type_text'">Obv. Type</xsl:when>
			<xsl:when test="$field = 'prevcoll_display'">Previous Collection</xsl:when>
			<xsl:when test="$field = 'rev_leg_display'">Rev. Legend</xsl:when>
			<xsl:when test="$field = 'rev_leg_text'">Rev. Legend</xsl:when>
			<xsl:when test="$field = 'rev_type_text'">Rev. Type</xsl:when>
			<xsl:when test="$field = 'taq_num'">Terminus Ante Quem</xsl:when>
			<xsl:when test="$field = 'tpq_num'">Terminus Post Quem</xsl:when>
			<xsl:when test="$field = 'closing_date_display'">Closing Date</xsl:when>
			<xsl:when test="contains($field, '_num')">
				<xsl:variable name="name" select="substring-before($field, '_num')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="name" select="substring-before($field, '_text')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="name" select="substring-before($field, '_m')"/>
				<xsl:value-of select="numishare:normalize_fields($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="name" select="substring-before($field, '_display')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="not(contains($field, '_'))">
				<xsl:value-of select="concat(upper-case(substring($field, 1, 1)), substring($field, 2))"/>
			</xsl:when>
			<xsl:otherwise>Undefined Category</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
